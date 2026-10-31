-- Real HUD constructors and engine rectangles; isolated Studio, no saved state.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local attributes=Instance.new('Folder');attributes.Parent=workspace
local module=Instance.new('ModuleScript');module.Name='BattleMenuQA'
local mock=[[local attributes=script.Attributes.Value
local Players={LocalPlayer={WaitForChild=function()return game:GetService('CoreGui')end,
GetAttribute=function(_,k)return attributes:GetAttribute(k)end,
GetAttributeChangedSignal=function(_,k)return attributes:GetAttributeChangedSignal(k)end}}
]]
module.Source=client.K0Hud.Source:gsub('local Players = game:GetService%("Players"%)',function()return mock end)
local ref=Instance.new('ObjectValue');ref.Name='Attributes';ref.Value=attributes;ref.Parent=module;module.Parent=client
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local hud=require(module).create()
 local menu=hud.settingsMenu.Parent;menu.Visible=true
 check(hud.settingsMenu.Caption.Text=='SETTINGS','English settings caption')
 check(hud.settingsMenu.Active and hud.settingsMenu.Selectable,'settings accepts pointer and gamepad')
 local rows={hud.heroMenu,hud.bagMenu,hud.journalMenu,hud.settingsMenu,hud.back}
 local scale=menu.Parent:FindFirstChildOfClass('UIScale')
 for _,value in ipairs({1,.72,.62})do
  scale.Scale=value;task.wait()
  for i,a in ipairs(rows)do
   check(a.Visible,'visible row '..a.Name)
   local p,s=a.AbsolutePosition,a.AbsoluteSize
   local mp,ms=menu.AbsolutePosition,menu.AbsoluteSize
   check(p.X>=mp.X-.1 and p.Y>=mp.Y-.1 and p.X+s.X<=mp.X+ms.X+.1 and p.Y+s.Y<=mp.Y+ms.Y+.1,'row fits menu '..a.Name)
   for j=i+1,#rows do
    local b=rows[j];local bp,bs=b.AbsolutePosition,b.AbsoluteSize
    check(p.X+s.X<=bp.X+.1 or bp.X+bs.X<=p.X+.1 or p.Y+s.Y<=bp.Y+.1 or bp.Y+bs.Y<=p.Y+.1,'overlap '..a.Name..' / '..b.Name)
   end
  end
 end
end,debug.traceback)
for _,name in ipairs({'DeepwoodTrainingHud','DeepwoodTopHud'})do local g=game.CoreGui:FindFirstChild(name);if g then g:Destroy()end end
attributes:Destroy();module:Destroy()
local report={kind='BATTLE_MENU_NATIVE',checks=checks,pass=ok,error=not ok and tostring(err)or nil}
print(game.HttpService:JSONEncode(report))
return report
