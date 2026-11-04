assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='NavigationGridQA';gui.IgnoreGuiInset=true;gui.Parent=game.CoreGui
local report={kind='LOBBY_NAVIGATION_GRID_NATIVE',checks=0,failures={},sizes={}}
local function check(value,message) report.checks+=1;assert(value,message) end
local ok,err=xpcall(function()
 local host=Instance.new('Frame');host.Parent=gui
 local nav=require(client.LobbyNavigation).create(host,{open=function()end,close=function()end})
 for _,viewport in ipairs({Vector2.new(3840,2160),Vector2.new(2560,1440),Vector2.new(1920,1080),Vector2.new(1500,900),Vector2.new(1499,900),Vector2.new(1280,800),Vector2.new(750,323),Vector2.new(529,323),Vector2.new(530,323),Vector2.new(390,317),Vector2.new(844,390),Vector2.new(1024,768),Vector2.new(1280,800),Vector2.new(1920,1080)}) do
  host.Size=UDim2.fromOffset(viewport.X,viewport.Y)
  local expected=require(client.LobbyNavigationSizing).measure(viewport.X,viewport.Y)
  task.wait(.2)
  local names={'Heroes','ItemShop','Blacksmith','Quest','Maps','DiamondShop','LoginRewards'}
  local buttons={}
  for index,name in ipairs(names) do
   local button=nav.rail:FindFirstChild(name);check(button~=nil,name..' exists');buttons[index]=button
   check(button.LayoutOrder==index,name..' retains order')
   check(button.AbsoluteSize==Vector2.new(expected.width,expected.height),name..' matches TD size')
   check(button.Caption.TextFits,name..' caption fits')
   check(button.Caption.TextSize>=(name=='Blacksmith' and 8 or 10),name..' caption remains readable')
   if name=='Blacksmith'then check(button.Caption.TextBounds.X<=button.NavigationPlaqueArt.AbsoluteSize.X*.82+1,'blacksmith clears beveled nameplate corners')end
   check(button.NavigationPlaqueArt.Image==buttons[1].NavigationPlaqueArt.Image,name..' same TD plaque')
   local picture=button.PictureViewport.NavigationIcon
   local plate=button.NavigationPlaqueArt
   local pictureBottom=picture.AbsolutePosition.Y+picture.AbsoluteSize.Y
   local plateTop=plate.AbsolutePosition.Y
   check(pictureBottom>=plateTop and pictureBottom<=plateTop+plate.AbsoluteSize.X*.02+1,name..' picture touches the nameplate')
   check(math.abs(picture.AbsolutePosition.X+picture.AbsoluteSize.X*.5-plate.AbsolutePosition.X-plate.AbsoluteSize.X*.5)<1,name..' picture and plaque stay centered')
   local crop=picture.ImageRectSize
   check(math.abs(picture.AbsoluteSize.Y-picture.AbsoluteSize.X*crop.Y/crop.X)<=1,name..' picture has no bottom fit padding')
   local plateCrop=plate.ImageRectSize
   check(math.abs(plate.AbsoluteSize.Y-plate.AbsoluteSize.X*plateCrop.Y/plateCrop.X)<=1,name..' plaque has no top fit padding')
   check(picture.AbsolutePosition.Y>=button.AbsolutePosition.Y-1 and plate.AbsolutePosition.Y+plate.AbsoluteSize.Y<=button.AbsolutePosition.Y+button.AbsoluteSize.Y+1,name..' complete art stays inside cell')
   check(button.Caption.TextBounds.X<=plate.AbsoluteSize.X*.92+1,name..' text stays inside plaque corners')
   check(button.Caption.AbsolutePosition.Y==plate.AbsolutePosition.Y and button.Caption.AbsoluteSize.Y==plate.AbsoluteSize.Y,name..' caption follows the fitted plaque')
  end
  for index=1,6,2 do
   local left,right=buttons[index],buttons[index+1]
   check(math.abs(left.AbsolutePosition.Y-right.AbsolutePosition.Y)<1,'paired icons share a row')
   check(right.AbsolutePosition.X>=left.AbsolutePosition.X+left.AbsoluteSize.X-1,'columns do not overlap')
   if index>1 then check(left.AbsolutePosition.Y>=buttons[index-2].AbsolutePosition.Y+buttons[index-2].AbsoluteSize.Y-1,'rows do not overlap') end
  end
  local last=buttons[7]
  local first=buttons[1]
  check(first.AbsolutePosition.Y>=64 or buttons[2].AbsolutePosition.X+buttons[2].AbsoluteSize.X<=viewport.X-340,'navigation clears the top wallet')
  check(last.AbsolutePosition.Y>=buttons[5].AbsolutePosition.Y+buttons[5].AbsoluteSize.Y-1,'last icon has its own row')
  check(last.AbsolutePosition.Y+last.AbsoluteSize.Y<=viewport.Y-12,'navigation stays within safe bottom margin')
  check(last.NavigationPlaqueArt.Image=='rbxassetid://127394633978202','login uses TD shared plaque')
  check(not buttons[1].TDButtonArt.Visible,'framed navigation artwork does not get an extra background')
  local art=last.PictureViewport:FindFirstChild('NavigationIcon')
  check(art~=nil and art.ZIndex>last.TDButtonArt.ZIndex and last.Caption.ZIndex>art.ZIndex,'icon and caption appear above the background')
  nav.dailyAvailable(true);check(last.Caption.Text=='REWARDS','reward availability does not add punctuation')
  nav.dailyAvailable(false);check(last.Caption.Text=='REWARDS','reward caption remains stable')
  check(buttons[2].Caption.Text=='POTIONS' and buttons[6].Caption.Text=='DIAMONDS','requested icon-only captions')
  table.insert(report.sizes,{width=viewport.X,height=viewport.Y,cell={expected.width,expected.height},captionSize=buttons[3].Caption.TextSize})
 end
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok

print(game:GetService('HttpService'):JSONEncode(report))
assert(report.pass,table.concat(report.failures,'\n'))
return report
