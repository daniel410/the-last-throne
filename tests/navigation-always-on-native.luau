local Run=game:GetService('RunService')
local client=game:GetService('StarterPlayer').StarterPlayerScripts.Client
local module=client.DeepwoodNavigation:Clone()
module.Name='NavigationAlwaysOnQA'
module.Source=module.Source:gsub("local Players=game:GetService%('Players'%)", "local Players={LocalPlayer=script.Player.Value}")
local player=Instance.new('Folder');player:SetAttribute('K0SessionPhase','Tutorial')
local character=Instance.new('Model');character.Name='Character';character.Parent=player
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(0,3,0);root.Parent=character
local human=Instance.new('Humanoid');human.Parent=character
player.Parent=workspace
local value=Instance.new('ObjectValue');value.Name='Player';value.Value=player;value.Parent=module;module.Parent=client
local field=Instance.new('Folder');field.Name='DeepwoodCampaign';field.Parent=workspace
local terrain=Instance.new('Folder');terrain.Name='TerrainBlockout';terrain.Parent=field
local ground=Instance.new('Part');ground.Name='ForestGround';ground.Anchored=true;ground.Size=Vector3.new(200,1,200);ground.Parent=terrain
Run:Run()
local nav=require(module).start()
local function visible()
 local count=0
 for _,p in ipairs(workspace.DeepwoodNavigation:GetChildren()) do if p.Transparency<1 then count+=1 end end
 return count
end
for _,distance in ipairs({60,10,6,1,0}) do
 nav.setTarget(Vector3.new(distance,3,0));task.wait(.15)
 assert(visible()>0,'guide hidden at distance '..distance)
end
nav.setTarget(nil);task.wait(.1);assert(visible()==0,'stale guide')
nav.setTarget(Vector3.new(6,3,0));player:SetAttribute('TLTRoute','Training');task.wait(.1);assert(visible()==0,'training guide')
player:SetAttribute('TLTRoute',nil);human.Health=0;task.wait(.1);assert(visible()==0,'dead guide')
nav.destroy();Run:Stop()
print('NAVIGATION_ALWAYS_ON PASS: 5 distances, no target, training, death')
