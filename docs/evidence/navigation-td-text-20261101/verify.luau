local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='NavigationTextQA';gui.IgnoreGuiInset=true;gui.Parent=game.CoreGui
local report={checks=0,profiles={},failures={}}
local function check(v,m)assert(v,m);report.checks+=1 end
local ok,err=xpcall(function()
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(1920,1080),Vector2.new(750,323),Vector2.new(390,317)})do
  local host=Instance.new('Frame');host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(size.X,size.Y);host.Parent=gui
  local nav=require(client.LobbyNavigation).create(host,{open=function()end,close=function()end})
  task.wait(.3)
  local rows={}
  for _,name in ipairs({'Heroes','ItemShop','Blacksmith','Quest','Maps','DiamondShop','LoginRewards'})do
   local button=nav.rail[name];local c=button.Caption
   check(c.Font==Enum.Font.GothamBlack,name..' bold TD font')
   check(c.TextColor3==Color3.new(1,1,1),name..' white')
   check(c.TextStrokeColor3==Color3.new(0,0,0) and c.TextStrokeTransparency==0,name..' opaque black stroke')
   check(c.TextFits,name..' fits '..tostring(size)..' bounds '..tostring(c.TextBounds)..' size '..tostring(c.AbsoluteSize))
   check(c.AbsolutePosition.Y+c.AbsoluteSize.Y<=button.AbsolutePosition.Y+button.AbsoluteSize.Y+1,name..' label within tile')
   if size.Y>=400 then
    check(not c.TextScaled and not c.TextWrapped,name..' desktop fixed single line')
    check(c.Position.Y.Offset>=button.AbsoluteSize.Y*.65,name..' lower caption')
   end
   table.insert(rows,{id=name,fontSize=c.TextSize,textBounds=tostring(c.TextBounds),labelSize=tostring(c.AbsoluteSize)})
  end
  local art=nav.rail.DiamondShop.NavigationIcon
  check(art.ImageRectSize.Y>250,'diamond original caption region retained')
  nav.dailyAvailable(true);task.wait(.1);check(nav.rail.LoginRewards.Caption.TextFits,'reward indicator fits')
  table.insert(report.profiles,{size=tostring(size),labels=rows})
  host:Destroy()
 end
end,debug.traceback)
gui:Destroy();report.pass=ok;if not ok then table.insert(report.failures,err)end
return report
