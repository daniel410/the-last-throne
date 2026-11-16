assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local w=_G.PassWorld;local group=w.folder.QuestSetpieces.Epic4
local scene=group['EC-01_FreightMachinery'];local head=scene.FreightHeadframe
local base=scene.FreightCarrier:GetPivot().Position;local V=Vector3.new
local n=0;for _,p in head:GetDescendants()do if p:IsA('BasePart')then
 n+=1;assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch)
 assert(p:GetAttribute('TLTDecorative')==true)
end end;assert(n==28)
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={w.terrain,workspace.Terrain}
local feet=0;local maxGap=0
for _,p in head:GetChildren()do if p.Name=='PierFoot'then
 local hit=workspace:Raycast(p.Position+V(0,5,0),V(0,-10,0),ray);assert(hit)
 local gap=p.Position.Y-p.Size.Y/2-hit.Position.Y;maxGap=math.max(maxGap,math.abs(gap));assert(math.abs(gap)<.1);feet+=1
end end;assert(feet==2)
assert(scene.FreightCarrier:GetAttribute('ExpansionEvent')=='EC-01:lift')
assert(scene.FreightCarrier:GetAttribute('ExpansionMin')==0)
assert(scene.FreightCarrier:GetAttribute('ExpansionTransitionSeconds')==4)
assert((scene.FreightCarrier:GetAttribute('ExpansionPose3').Position-base-V(0,12,0)).Magnitude<.001)
assert(scene.InstalledRecoveredGear:GetAttribute('ExpansionRequires')=='EC-01:gear')
assert(scene.FreightLandingReady:GetAttribute('ExpansionRequires')=='EC-01:gear')
local module=require(game.ServerScriptService.Server.World.CampaignQuestSetpieces)
module.create(w,4);assert(w.folder.QuestSetpieces.Epic4==group)
local groups=0;for _,m in w.folder.QuestSetpieces:GetChildren()do if m.Name=='Epic4'then groups+=1 end end;assert(groups==1)
local drum=head.HoistDrum;assert(drum.Shape==Enum.PartType.Cylinder)
return {parts=n,feet=feet,maxFootGap=maxGap,poseDelta=12,transitionSeconds=4,groupCount=groups,flags=true,savedTags=true}
