-- 승인된 실제 업로드 모델의 생성·접지·호위 표시 계약 검증.
local Catalog=require(game.ReplicatedStorage.Shared.NPCCatalog)
local modules=game.ServerStorage:FindFirstChild('TLT_NPC_ValidationModules')
local Visual=require(modules and modules.NPCMeshVisual or game.ServerScriptService.Server.World.NPCMeshVisual)
local Motion=require(modules and modules.NPCMeshMotion or game.StarterPlayer.StarterPlayerScripts.Client.NPCMeshMotion)
local templates=assert(game.ServerStorage:FindFirstChild('NPCMeshyModels'))
local report={checks=0,models=0,fixture='uploaded-models',uploadedModelsVerified=true,assets={}}
local function check(v,message)report.checks+=1;assert(v,message)end
local actors=Instance.new('Folder');actors.Name='TLT_NPC_RuntimeTest';actors.Parent=workspace
local ok,err=xpcall(function()
 check(#templates:GetChildren()==29,'29 approved models')
 check(not templates:FindFirstChild('selene'),'Selene excluded')
 for _,c in Catalog.characters do if c.id~='selene' then
  local at=Vector3.new(12,5,20)
  local actor=Visual.tryCreate(actors,c,at,{yaw=.7})
  check(actor~=nil,'template present '..c.id)
  check(actor:GetAttribute('NPCId')==c.id and actor:GetAttribute('NPCVisualVersion')==6,'identity '..c.id)
  check(actor.PrimaryPart.NPCLabel.TextLabel.Text==c.name..' · '..c.role,'label '..c.id)
  check(actor.ModelStreamingMode==Enum.ModelStreamingMode.Atomic,'atomic streaming')
  check(game.CollectionService:HasTag(actor,'TLTAnimatedNPC'),'motion registration')
  local mesh=assert(actor:FindFirstChild('BodyMesh'))
  check(mesh:IsA('MeshPart') and mesh.MeshId~='' and mesh.TextureID~='','uploaded surface')
  check(actor:GetAttribute('NPCTriangles')<=5000,'triangle budget')
  local bottom=actor.PrimaryPart.CFrame:PointToObjectSpace(mesh.Position).Y-mesh.Size.Y/2
  check(math.abs(bottom)<.005,'feet at anchor '..c.id..' '..bottom)
  local r=Motion.bind(actor);check(r~=nil,'native Bone binding '..c.id)
  for i=1,24 do
   local cf=CFrame.new(at+Vector3.new(0,0,-i*.12))*CFrame.Angles(0,.7,0)
   actor:PivotTo(cf);r:update(1/60,i/60)
   check((actor.PrimaryPart.Position-cf.Position).Magnitude<.00001,'client preserves server root')
   for _,p in r.parts do check(p.part.Anchored and not p.part.CanCollide and not p.part.CanQuery,'decorative collision')end
  end
  check(r.weight>0 and r.bones.LegL.Transform~=CFrame.identity,'escort gait')
  check(r.bones.Body.Transform.Rotation==CFrame.identity,'held props remain rigid')
  r:reset();for _,b in r.bones do check(b.Transform==CFrame.identity,'reset pose')end
  actor:PivotTo(CFrame.new(1000,5,0));r:update(1/60,5);check(r.weight==0,'teleport resets gait')
  table.insert(report.assets,{id=c.id,height=actor:GetAttribute('NPCMeshHeight'),feetOffset=bottom,triangles=actor:GetAttribute('NPCTriangles')})
  actor:Destroy();report.models+=1
 end end
end,debug.traceback)
actors:Destroy();report.pass=ok;report.failure=not ok and tostring(err) or nil
print('NPC_MESHY_RUNTIME '..game.HttpService:JSONEncode(report));assert(ok,err)
return game.HttpService:JSONEncode(report)
