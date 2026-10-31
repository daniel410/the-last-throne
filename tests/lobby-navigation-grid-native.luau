assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='NavigationGridQA';gui.IgnoreGuiInset=true;gui.Parent=game.CoreGui
local report={kind='LOBBY_NAVIGATION_GRID_NATIVE',checks=0,failures={}}
local function check(value,message) report.checks+=1;assert(value,message) end
local ok,err=xpcall(function()
 for _,viewport in ipairs({Vector2.new(1280,800),Vector2.new(750,323),Vector2.new(529,323),Vector2.new(530,323),Vector2.new(390,317)}) do
  local host=Instance.new('Frame');host.Size=UDim2.fromOffset(viewport.X,viewport.Y);host.Parent=gui
  local copy=Instance.new('ModuleScript');copy.Name='NavigationGridFixture';copy.Parent=client
  local signal=Instance.new('BindableEvent');signal.Name='CameraChanged';signal.Parent=copy
  local source=client.LobbyNavigation.Source:gsub('workspace.CurrentCamera','fixtureCamera')
  copy.Source=('local fixtureCamera={ViewportSize=Vector2.new(%d,%d),GetPropertyChangedSignal=function() return script.CameraChanged.Event end}\n'):format(viewport.X,viewport.Y)..source
  local nav=require(copy).create(host,{open=function()end,close=function()end})
  task.wait(.2)
  local names={'Heroes','ItemShop','Blacksmith','Quest','Maps','DiamondShop','LoginRewards'}
  local buttons={}
  for index,name in ipairs(names) do
   local button=nav.rail:FindFirstChild(name);check(button~=nil,name..' exists');buttons[index]=button
   check(button.LayoutOrder==index,name..' retains order')
   check(button.AbsoluteSize.Y>=44,name..' has a usable touch height')
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
  check(last.AbsolutePosition.Y+last.AbsoluteSize.Y<=viewport.Y-60,'navigation clears bottom action')
  check(last.TDButtonArt.Visible,'login reward background is visible')
  check(not buttons[1].TDButtonArt.Visible,'framed navigation artwork does not get an extra background')
  local art=last:FindFirstChild('TDIcon_login_rewards')
  check(art~=nil and art.ZIndex>last.TDButtonArt.ZIndex and last.Caption.ZIndex>art.ZIndex,'icon and caption appear above the background')
  nav.dailyAvailable(true);check(last.Caption.Text=='LOGIN REWARDS !','available reward indicator remains visible')
  host:Destroy();copy:Destroy()
 end
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok
return report
