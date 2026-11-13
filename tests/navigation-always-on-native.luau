local Run=game:GetService('RunService')
local center=require(game.ReplicatedStorage.Shared.CampaignContent).zones['DW-01'].center
local origin=Vector3.new(table.unpack(center))
local function at(x,y,z)return origin+Vector3.new(x,y,z)end
local client=game:GetService('StarterPlayer').StarterPlayerScripts.Client
local module=client.DeepwoodNavigation:Clone()
module.Name='NavigationAlwaysOnQA'
module.Source=module.Source:gsub("local Players=game:GetService%('Players'%)", "local Players={LocalPlayer=script.Player.Value}")
local player=Instance.new('Folder');player:SetAttribute('K0SessionPhase','Tutorial')
local character=Instance.new('Model');character.Name='Character';character.Parent=player
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=at(0,3,0);root.Parent=character
local human=Instance.new('Humanoid');human.Parent=character
player.Parent=workspace
local value=Instance.new('ObjectValue');value.Name='Player';value.Value=player;value.Parent=module;module.Parent=client
local field=Instance.new('Folder');field.Name='DeepwoodCampaign';field.Parent=workspace
local terrain=Instance.new('Folder');terrain.Name='TerrainBlockout';terrain.Parent=field
local ground=Instance.new('Part');ground.Name='ForestGround';ground.Position=origin;ground.Anchored=true;ground.Size=Vector3.new(200,1,200);ground.Parent=terrain
Run:Run()
local nav=require(module).start()
local function visible()
 local count=0
 for _,p in ipairs(workspace.DeepwoodNavigation:GetChildren()) do if p.Transparency<1 then count+=1 end end
 return count
end
local function awaitVisible(expected)
 local started=os.clock();local deadline=started+4
 repeat task.wait() until (os.clock()-started>.1 and (visible()>0)==expected) or os.clock()>deadline
end
for _,distance in ipairs({60,10,6,1,0}) do
 nav.setTarget(at(distance,3,0));awaitVisible(true)
 assert(visible()>0,'guide hidden at distance '..distance)
end
-- Native chevrons stay on the direct bearing after lateral player movement.
root.Position=at(5,3,20)
local destination=at(60,3,-10)
nav.setTarget(destination);awaitVisible(true)
local delta=Vector3.new(destination.X-root.Position.X,0,destination.Z-root.Position.Z).Unit
local rendered=workspace.DeepwoodNavigation:GetChildren();local pairsChecked=0
for i=1,#rendered,2 do
 local a,b=rendered[i],rendered[i+1]
 if a.Transparency<1 and b and b.Transparency<1 then
  local midpoint=(a.Position+b.Position)/2
  local offset=Vector3.new(midpoint.X-root.Position.X,0,midpoint.Z-root.Position.Z)
  assert(math.abs(offset:Cross(delta).Y)<.01,'chevron detours away from direct bearing')
  local facing=a.CFrame.LookVector+b.CFrame.LookVector
  assert(facing.Unit:Dot(delta)>.99,'chevron faces objective after player moves')
  pairsChecked+=1
 end
end
assert(pairsChecked>0,'moving player keeps visible direct guidance')
-- Navigation retains its active/hidden contract while its overlay obeys
-- world depth, so it cannot paint over a foreground enemy or warning.
local occluder=Instance.new('Part');occluder.Name='NavigationOccluder';occluder.Anchored=true
occluder.Size=Vector3.new(200,6,200);occluder.Position=at(0,12,0);occluder.Parent=field
local function checkOverlay()
 for _,p in ipairs(workspace.DeepwoodNavigation:GetChildren())do
  local overlay=p:FindFirstChild('GuideOverlay')
  assert(overlay and overlay:IsA('BoxHandleAdornment') and overlay.Adornee==p,'each chevron has an overlay')
  assert(not overlay.AlwaysOnTop and overlay.ZIndex>=0,'foreground world geometry can occlude the overlay')
  assert(overlay.Transparency==p.Transparency,'overlay follows active/hidden state')
 end
end
checkOverlay()
player:SetAttribute('TLTNavigationEnabled',false);task.wait(.1);assert(visible()==0,'option hides trail');checkOverlay()
player:SetAttribute('TLTNavigationEnabled',true);task.wait(.1);assert(visible()>0,'option restores trail')
-- Story paths use persistent support outside TerrainBlockout after older roads
-- have been disabled; goals can be much higher than the current floor.
ground:Destroy()
local foundation=Instance.new('Folder');foundation.Name='GroundedForest';foundation.Parent=field
local support=Instance.new('Part');support.Name='TrailSupport_4';support.Position=origin;support.Anchored=true;support.Size=Vector3.new(200,1,200);support.Parent=foundation
root.Position=at(0,3,0);nav.setTarget(at(80,150,0));task.wait(.2)
assert(visible()>0,'story 4 support and a high destination still show navigation')
local projected=false
for _,p in ipairs(workspace.DeepwoodNavigation:GetChildren())do if p.Transparency<1 and math.abs(p.Position.Y-.64)<.3 then projected=true;break end end
assert(projected,'guide projects onto persistent story path')
support:Destroy()
-- Terrain must also be a navigation floor in every epic, not just named Parts.
workspace.Terrain:FillBlock(CFrame.new(at(0,6,0)),Vector3.new(160,8,160),Enum.Material.Grass)
task.wait(.2)
local onTerrain=false
for _,p in ipairs(workspace.DeepwoodNavigation:GetChildren())do if p.Transparency<1 and p.Position.Y>9 then onTerrain=true end end
assert(onTerrain,'arrows project onto smooth Terrain rather than underneath it');checkOverlay()
workspace.Terrain:Clear();occluder:Destroy()
task.wait(.2);assert(visible()>0,'guide remains visible while ground is not streamed')
player:SetAttribute('TLTNavigationEnabled',false);task.wait(.1);assert(visible()==0,'settings also hide the fallback')
player:SetAttribute('TLTNavigationEnabled',true);task.wait(.1);assert(visible()>0,'settings restore the fallback')
nav.setTarget(nil);task.wait(.1);assert(visible()==0,'stale guide');checkOverlay()
nav.setTarget(at(6,3,0));player:SetAttribute('TLTRoute','Training');task.wait(.1);assert(visible()==0,'training guide')
player:SetAttribute('TLTRoute',nil);human.Health=0;task.wait(.1);assert(visible()==0,'dead guide')
local gui=Instance.new('Folder');gui.Name='PlayerGui';gui.Parent=player
local mapModule=client.DeepwoodMap:Clone();mapModule.Name='NavigationMapQA'
mapModule.Source=mapModule.Source:gsub("local Players=game:GetService%('Players'%)", "local Players={LocalPlayer=script.Player.Value}")
local mapPlayer=value:Clone();mapPlayer.Parent=mapModule;mapModule.Parent=client
player:SetAttribute('TLTNavigationEnabled',nil)
local map=require(mapModule).start()
local toggle=map.panel.NavigationTrail
assert(toggle.Caption.Text=='Navigation Trail: ON','map defaults on')
assert(toggle.Size.Y.Offset>=40 and toggle.Selectable,'accessible toggle target')
player:SetAttribute('TLTNavigationEnabled',false);task.wait(.1)
assert(toggle.Caption.Text=='Navigation Trail: OFF','map reflects off')
player:SetAttribute('TLTNavigationEnabled',true);task.wait(.1)
assert(toggle.Caption.Text=='Navigation Trail: ON','map reflects on')
nav.destroy();Run:Stop();player:Destroy();field:Destroy();module:Destroy();mapModule:Destroy()
print('NAVIGATION_ALWAYS_ON PASS: distance, direct bearing, story support and elevation, streamed-floor fallback, settings, training and death')
