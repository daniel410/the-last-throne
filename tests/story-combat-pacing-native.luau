-- Real generated objective anchors and HUD, isolated edit engine only.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local RS=game.ReplicatedStorage
local C=require(RS.Shared.CampaignContent)
local world=assert(workspace:FindFirstChild('DeepwoodCampaign'))
local report={kind='STORY_COMBAT_PACING_NATIVE',checks=0,patrols=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world,workspace.Terrain};ray.RespectCanCollide=true
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.pacingGoals or {})do
 report.patrols+=1
 local folder=world.Objectives
 local marker=folder:FindFirstChild(c.zone..'_'..g.id)or folder:FindFirstChild(c.id..'_'..g.id)
 if not marker then
  for _,p in ipairs(folder:GetDescendants())do if p:IsA('ProximityPrompt')and p.ObjectText==g.title then marker=p.Parent;break end end
 end
 check(marker~=nil,'real patrol objective '..c.id..':'..g.id)
 local prompt=marker:FindFirstChildOfClass('ProximityPrompt')
 check(prompt and prompt.ActionText=='Begin encounter','real combat interaction prompt')
 local p=Vector3.new(table.unpack(g.position));local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),ray)
 check(hit and math.abs(hit.Position.Y-p.Y)<1.1,'patrol trigger on supported ground')
end end
check(report.patrols==13,'all new patrol anchors instantiated')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local player=Instance.new('Folder');player.Name='PacingHudPlayer';player.Parent=workspace
local source=client.K0Hud.Source:gsub('local Players = game:GetService%("Players"%)',[[local fixturePlayer=workspace.PacingHudPlayer;local Players={LocalPlayer={WaitForChild=function()return game.CoreGui end,GetAttribute=function(_,k)return fixturePlayer:GetAttribute(k)end,GetAttributeChangedSignal=function(_,k)return fixturePlayer:GetAttributeChangedSignal(k)end}}]])
local module=Instance.new('ModuleScript');module.Name='PacingHudFixture';module.Source=source;module.Parent=client
local hud=require(module).create()
for _,prefix in ipairs({'DW','GW','FV','EC','HG'})do
 hud.setStory({region=C.epics[C.byId[prefix..'-01'].epic].region,title='MAIN STORY',objective='Follow the marked route.',note='Continue along the trail.'})
 hud.setVisible(true);task.wait(.05)
 local gui=game.CoreGui.DeepwoodTrainingHud
 check(gui.Enabled and game.CoreGui.DeepwoodTopHud.Enabled,'HUD remains enabled in '..prefix)
 check(gui.Root.SkillBar.Visible and gui.Root.Actions.Visible,'combat bar and actions remain visible between battles '..prefix)
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(844,390)})do
  gui.Root.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.05)
  local bar=gui.Root.SkillBar
  check(bar.AbsoluteSize.X>0 and bar.AbsoluteSize.Y>0 and bar.AbsolutePosition.Y>=gui.Root.AbsolutePosition.Y,'combat bar has visible on-screen geometry '..prefix)
 end
end
hud.setVisible(false);check(not game.CoreGui.DeepwoodTrainingHud.Enabled,'lobby does not expose battle controls')
game.CoreGui.DeepwoodTrainingHud:Destroy();game.CoreGui.DeepwoodTopHud:Destroy();module:Destroy();player:Destroy()
print('STORY_COMBAT_PACING_NATIVE '..game.HttpService:JSONEncode(report))
return report
