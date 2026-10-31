assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='NavigationIconQA';gui.Parent=game.CoreGui
local report={kind='LOBBY_NAVIGATION_ICON_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local nav=require(client.LobbyNavigation).create(gui,{open=function()end,close=function()end})
 local shop=nav.rail.DiamondShop.NavigationIcon
 local function fittedWidth(img)
  local crop=img.ImageRectSize;local target=img.AbsoluteSize
  return math.min(target.X,target.Y*crop.X/crop.Y)
 end
 local hero=nav.rail.Heroes.NavigationIcon
 check(shop.Image=='rbxassetid://135608370136189','uses original TD shop image')
 check(shop.ImageRectSize.Y<336,'source caption excluded from fit')
 check(math.abs(fittedWidth(shop)-fittedWidth(hero))<4,'fitted visual width matches other navigation icons')
 check(shop.AbsoluteSize==hero.AbsoluteSize,'navigation icon hit-area layout remains consistent')
 check(nav.rail.LoginRewards:FindFirstChild('TDIcon_login_rewards')~=nil,'TD login reward icon is connected')
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok
return report
