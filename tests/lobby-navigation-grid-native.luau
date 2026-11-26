assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='NavigationGridQA';gui.IgnoreGuiInset=true;gui.Parent=game.CoreGui
local report={kind='LOBBY_NAVIGATION_GRID_NATIVE',checks=0,failures={},sizes={}}
local names={'DiamondShop','LoginRewards','ItemShop','Blacksmith','Heroes','Maps','Quest','Party'}
local function check(value,message) report.checks+=1;assert(value,message) end
local ok,err=xpcall(function()
 local host=Instance.new('Frame');host.Parent=gui
 local nav=require(client.LobbyNavigation).create(host,{open=function()end,close=function()end})
 for _,viewport in ipairs({Vector2.new(3840,2160),Vector2.new(2560,1440),Vector2.new(1920,1080),Vector2.new(1500,900),Vector2.new(1499,900),Vector2.new(1280,800),Vector2.new(750,323),Vector2.new(529,323),Vector2.new(530,323),Vector2.new(390,317),Vector2.new(844,390),Vector2.new(1024,768),Vector2.new(1280,800),Vector2.new(1920,1080)}) do
  host.Size=UDim2.fromOffset(viewport.X,viewport.Y)
  local expected=require(client.LobbyNavigationSizing).measure(viewport.X,viewport.Y)
  task.wait(.2)
  local buttons={}
  for index,name in ipairs(names) do
   local button=nav.rail:FindFirstChild(name);check(button~=nil,name..' exists');buttons[index]=button
   check(button.LayoutOrder==index,name..' retains order')
   check(button.AbsoluteSize==Vector2.new(expected.width,expected.height),name..' matches TD size')
   check(button.Caption.TextFits,name..' caption fits')
   check(button.Caption.TextSize>=(name=='Blacksmith' and 8 or 10),name..' caption remains readable')
   check(button.NavigationPlaqueArt.Image==buttons[1].NavigationPlaqueArt.Image,name..' same TD plaque')
   local picture=button.PictureViewport.NavigationIcon
   local plate=button.NavigationPlaqueArt
   local pictureBottom=picture.AbsolutePosition.Y+picture.AbsoluteSize.Y
   local plateTop=plate.AbsolutePosition.Y
   check(pictureBottom>=plateTop and pictureBottom<=plateTop+plate.AbsoluteSize.X*.02+1,name..' picture touches the nameplate')
   check(math.abs(picture.AbsolutePosition.X+picture.AbsoluteSize.X*.5-plate.AbsolutePosition.X-plate.AbsoluteSize.X*.5)<1,name..' picture and plaque stay centered')
   local crop=button.PictureViewport:GetAttribute('PictureSize') or picture.ImageRectSize
   check(math.abs(picture.AbsoluteSize.Y-picture.AbsoluteSize.X*crop.Y/crop.X)<=1,name..' picture has no bottom fit padding')
   local plateCrop=plate.ImageRectSize
   local tdPictureWidth=math.min(button.AbsoluteSize.X*.98,button.AbsoluteSize.Y*.72*crop.X/crop.Y)
   local tdPlaqueWidth=math.min(button.AbsoluteSize.X*.98,button.AbsoluteSize.Y*.30*plateCrop.X/plateCrop.Y)
   check(math.abs(picture.AbsoluteSize.X-tdPictureWidth)<1,name..' visible picture matches TD fitted size')
   check(math.abs(plate.AbsoluteSize.X-tdPlaqueWidth)<1,name..' visible nameplate matches TD fitted size')
   check(math.abs(plate.AbsoluteSize.Y-plate.AbsoluteSize.X*plateCrop.Y/plateCrop.X)<=1,name..' plaque has no top fit padding')
   check(picture.AbsolutePosition.Y>=button.AbsolutePosition.Y-1 and plate.AbsolutePosition.Y+plate.AbsoluteSize.Y<=button.AbsolutePosition.Y+button.AbsoluteSize.Y+1,name..' complete art stays inside cell')
   check(button.Caption.TextBounds.X<=plate.AbsoluteSize.X*.88+1,name..' text stays inside plaque corners')
   local caption=button.Caption
   check(caption.AbsolutePosition.X>plate.AbsolutePosition.X and caption.AbsolutePosition.X+caption.AbsoluteSize.X<plate.AbsolutePosition.X+plate.AbsoluteSize.X,name..' caption clears both beveled ends')
   check(caption.AbsolutePosition.Y>plate.AbsolutePosition.Y and caption.AbsolutePosition.Y+caption.AbsoluteSize.Y<plate.AbsolutePosition.Y+plate.AbsoluteSize.Y,name..' caption clears the top and bottom frame')
  end
  check(nav.rail.UIGridLayout.FillDirectionMaxCells==2,'navigation uses two columns')
  for index=2,#buttons do
   local previous,button=buttons[index-1],buttons[index]
   if index%2==1 then
    check(button.AbsolutePosition.Y>=previous.AbsolutePosition.Y+previous.AbsoluteSize.Y-1,'rows do not overlap')
   else
    check(math.abs(previous.AbsolutePosition.Y-button.AbsolutePosition.Y)<1,'icons share a row')
    check(button.AbsolutePosition.X>=previous.AbsolutePosition.X+previous.AbsoluteSize.X-1,'columns do not overlap')
   end
  end
  local rewards=nav.rail.LoginRewards
  local last=buttons[#buttons]
  local first=buttons[1]
  check(first.AbsolutePosition.Y>=64 or buttons[2].AbsolutePosition.X+buttons[2].AbsoluteSize.X<=viewport.X-340,'navigation clears the top wallet')
  check(last.AbsolutePosition.Y+last.AbsoluteSize.Y<=viewport.Y-12,'navigation stays within safe bottom margin')
  check(rewards.NavigationPlaqueArt.Image=='rbxassetid://127394633978202','login uses TD shared plaque')
  check(not buttons[1].TDButtonArt.Visible,'framed navigation artwork does not get an extra background')
  local art=last.PictureViewport:FindFirstChild('NavigationIcon')
  check(art~=nil and art.ZIndex>last.TDButtonArt.ZIndex and last.Caption.ZIndex>art.ZIndex,'icon and caption appear above the background')
  nav.dailyAvailable(true);check(rewards.Caption.Text=='REWARDS','reward availability does not add punctuation')
  nav.dailyAvailable(false);check(rewards.Caption.Text=='REWARDS','reward caption remains stable')
  check(nav.rail.ItemShop.Caption.Text=='POTIONS' and nav.rail.DiamondShop.Caption.Text=='DIAMONDS','requested icon-only captions')
  nav.showGuide('Maps');task.wait()
  local title,side,close=nav.panel.Title,nav.panel.TessaGuide,nav.panel.Close
  check(title.TextFits and title.AbsolutePosition.X+title.AbsoluteSize.X<side.AbsolutePosition.X,'map heading fits beside the Tessa button')
  check(side.Caption.TextFits and side.AbsolutePosition.X+side.AbsoluteSize.X<close.AbsolutePosition.X,'Tessa button clears close')
  table.insert(report.sizes,{width=viewport.X,height=viewport.Y,cell={expected.width,expected.height},captionSize=nav.rail.Blacksmith.Caption.TextSize})
 end
 nav.panel.Visible=false
 local player=Instance.new('Folder');player.Parent=gui
 local dock=require(client.LobbyHeroDock).create(host,player,function()end,function()end)
 dock.update({phase='Lobby',canManage=true,heroes={}},false)
 for _,viewport in ipairs({Vector2.new(390,844),Vector2.new(490,700),Vector2.new(390,568),Vector2.new(320,568)})do
  host.Size=UDim2.fromOffset(viewport.X,viewport.Y);task.wait(.2)
  check(nav.rail.UIGridLayout.FillDirectionMaxCells==2,'portrait navigation uses two columns')
  check(nav.rail.AbsolutePosition.Y>=host.AbsolutePosition.Y+116,'portrait rail clears the wallet')
  check(nav.rail.AbsolutePosition.Y+nav.rail.AbsoluteSize.Y<=dock.play.AbsolutePosition.Y-4,'portrait rail clears PLAY at '..tostring(viewport))
  for index=1,#names,2 do
   local left,right=nav.rail[names[index]],nav.rail[names[index+1]]
   check(left.AbsolutePosition.Y==right.AbsolutePosition.Y and right.AbsolutePosition.X>left.AbsolutePosition.X,'portrait pair '..left.Name..' / '..right.Name)
   if index>1 then
    local previous=nav.rail[names[index-2]]
    check(left.AbsolutePosition.Y>=previous.AbsolutePosition.Y+previous.AbsoluteSize.Y,'portrait rows follow the requested order')
   end
   for _,tile in ipairs({left,right})do
    check(tile.AbsoluteSize.Y>=44 and tile.Caption.TextFits,'portrait tap target and nameplate fit '..tile.Name)
   end
  end
 end
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok

print(game:GetService('HttpService'):JSONEncode(report))
assert(report.pass,table.concat(report.failures,'\n'))
return report
