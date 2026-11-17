-- Synthetic engine fixture: verifies wiring and authority, not uploaded mesh appearance.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local Catalog=require(game.ReplicatedStorage.Shared.NPCCatalog)
local Visual=require(game.ServerScriptService.Server.World.NPCMeshVisual)
local Motion=require(game.StarterPlayer.StarterPlayerScripts.Client.NPCMotionPresentation)
local storage=game.ServerStorage
assert(not storage:FindFirstChild('NPCMeshyModels'),'Synthetic test must not overwrite real templates')
local report={checks=0,models=0,fixture='synthetic',uploadedModelsVerified=false}
local function check(value,message)report.checks+=1;assert(value,message)end
local folder=Instance.new('Folder');folder.Name='NPCMeshyModels'
local actors=Instance.new('Folder');actors.Name='NPCMeshContractTest';actors.Parent=workspace
local ok,err=xpcall(function()
 check(Visual.tryCreate(actors,Catalog.byId.aldric,Vector3.zero,{})==nil,'missing templates preserve old visual fallback')
 folder.Parent=storage
 for _,c in Catalog.characters do if c.id~='selene' then
  local m=Instance.new('Model');m.Name=c.id
  local root=Instance.new('Part');root.Name='ActorRoot';root.Size=Vector3.one*.01;root.Transparency=1;root.Parent=m;m.PrimaryPart=root
  local surface=Instance.new('Part');surface.Name='SyntheticSurface';surface.Size=Vector3.new(1,2,.5);surface.Position=Vector3.new(0,1,0);surface.Parent=m
  local body=Instance.new('Bone');body.Name='Body';body.Parent=surface
  for _,side in {'L','R'}do
   local leg=Instance.new('Bone');leg.Name='Leg'..side;leg.Parent=body
   local foot=Instance.new('Bone');foot.Name='Foot'..side;foot.Parent=leg
  end
  m:SetAttribute('NPCMeshyTemplateVersion',1);m:SetAttribute('NPCSourceHeight',2);m.Parent=folder
  local at=Vector3.new(12,5,20)
  local actor=Visual.tryCreate(actors,c,at,{yaw=.7})
  check(actor:GetAttribute('NPCId')==c.id and actor:GetAttribute('NPCVisualVersion')==6,'identity preserved')
  check(actor.PrimaryPart.Name=='ActorRoot' and actor.PrimaryPart.NPCLabel.TextLabel.Text==c.name..' · '..c.role,'prompt and label anchor')
  check(game.CollectionService:HasTag(actor,'TLTAnimatedNPC'),'motion registration')
  local r=Motion.bind(actor);check(r~=nil,'native Bone motion binding '..c.id)
  for i=1,24 do
   local cf=CFrame.new(at+Vector3.new(0,0,-i*.12))*CFrame.Angles(0,.7,0)
   actor:PivotTo(cf);r:update(1/60,i/60)
   check((actor.PrimaryPart.Position-cf.Position).Magnitude<.00001,'client never changes authoritative root')
   for _,p in r.parts do check(p.part.Anchored and not p.part.CanCollide and not p.part.CanQuery,'decorative collision contract')end
  end
  check(r.weight>0 and r.bones.LegL.Transform~=CFrame.identity,'escort locomotion animates skin')
  r:reset();for _,b in r.bones do check(b.Transform==CFrame.identity,'reset restores original surface pose')end
  actor:PivotTo(CFrame.new(1000,5,0));r:update(1/60,5)
  check(r.weight==0,'teleport is not walking')
  actor:Destroy();report.models+=1
 end end
 check(not folder:FindFirstChild('selene'),'Selene excluded')
end,debug.traceback)
actors:Destroy();folder:Destroy()
report.pass=ok;report.failure=not ok and tostring(err) or nil
print('NPC_MESHY_CONTRACT '..game.HttpService:JSONEncode(report))
assert(ok,err)
return report
