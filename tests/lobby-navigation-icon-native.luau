assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='NavigationIconQA';gui.Parent=game.CoreGui
local report={kind='LOBBY_NAVIGATION_ICON_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local nav=require(client.LobbyNavigation).create(gui,{open=function()end,close=function()end})
 task.wait(.2)
 local shop=nav.rail.DiamondShop.PictureViewport.NavigationIcon
 local function fittedWidth(img)
  local crop=img.ImageRectSize;local target=img.AbsoluteSize
  return math.min(target.X,target.Y*crop.X/crop.Y)
 end
 local hero=nav.rail.Heroes.PictureViewport.NavigationIcon
 check(shop.Image=='rbxassetid://135608370136189','uses original TD shop image')
 check(hero.Image=='rbxassetid://101441413467224','uses actual TD hero override')
 check(nav.rail.Maps.PictureViewport.NavigationIcon.Image=='rbxassetid://127394633978202','uses actual TD map')
 check(shop.ImageRectSize.Y==262,'TD body crop excludes original plaque')
 for _,entry in ipairs(nav.rail:GetChildren())do if entry:IsA('TextButton')then
  check(entry.NavigationPlaqueArt.Image=='rbxassetid://127394633978202','same Maps nameplate for every entry')
  check(entry.NavigationPlaqueArt.AbsoluteSize.X<=entry.AbsoluteSize.X,'TD plaque stays inside tile')
  check(entry.PictureViewport.NavigationIcon.ScaleType==Enum.ScaleType.Fit,'TD picture keeps aspect ratio')
  check(entry.Caption.Position==entry.NavigationPlaqueArt.Position,'caption on TD plaque')
 end end
 check(nav.rail.LoginRewards.PictureViewport.NavigationIcon.Image=='rbxassetid://96946740539077','new RPG-only subjects use matching TD frame')
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok
print(game:GetService('HttpService'):JSONEncode(report))
assert(report.pass,table.concat(report.failures,'\n'))
return report
