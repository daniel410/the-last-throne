-- Replace __SPEC_JSON__ with audited JSON; run in Edit in small batches.
local specs=game.HttpService:JSONDecode([==[__SPEC_JSON__]==])
local storage=game:GetService('ServerStorage')
local folder=storage:FindFirstChild('FourFamilyWeaponModels')
if not folder then folder=Instance.new('Folder');folder.Name='FourFamilyWeaponModels';folder.Parent=storage end
local report={}
local function vector(v)return Vector3.new(v[1],v[2],v[3])end
local function attachment(grip,name,position)
 local a=Instance.new('Attachment');a.Name=name;a.Position=position;a.Parent=grip;return a
end
for _,spec in specs do
 local name=spec.id=='sentinel_axe' and 'TLT_SentinelAxe_Import' or 'TLT_'..spec.id..'_Import'
 local source=assert(storage:FindFirstChild(name),'Missing import '..spec.id)
 local meshes={};for _,p in source:GetDescendants()do if p:IsA('MeshPart')then table.insert(meshes,p)end end
 assert(#meshes==1,'Only one mesh per source')
 local raw=meshes[1];local size=vector(spec.size)
 assert((raw.Size-size).Magnitude<.0002,'Native size changed '..spec.id)
 assert(raw.MeshId~='' and raw.TextureID~='','Missing mesh/color texture '..spec.id)
 local editable=game:GetService('AssetService'):CreateEditableMeshAsync(Content.fromUri(raw.MeshId))
 local vertices={};for _,id in editable:GetVertices()do table.insert(vertices,editable:GetPosition(id))end
 local matched={};local best,bestCount=0,-1
 for turn=0,3 do
  local rotation=CFrame.Angles(0,turn*math.pi/2,0);local rotated={}
  for _,p in vertices do table.insert(rotated,rotation:VectorToWorldSpace(p))end
  local count=0
  for _,sample in spec.samples do
   local wanted=vector(sample)
   for _,p in rotated do if (p-wanted).Magnitude<.0003 then count+=1;break end end
  end
  matched[tostring(turn)]=count
  if count>bestCount then best,bestCount=turn,count end
 end
 editable:Destroy()
 assert(bestCount==#spec.samples,'Native mesh geometry/orientation mismatch '..spec.id..' '..game.HttpService:JSONEncode(matched))
 local model=Instance.new('Model');model.Name=spec.definitionId
 local grip=Instance.new('Part');grip.Name='Grip';grip.Size=Vector3.new(.12,.12,.12);grip.Transparency=1;grip.CastShadow=false;grip.CFrame=CFrame.identity;grip.Parent=model;model.PrimaryPart=grip
 local mesh=raw:Clone();mesh.Name=spec.classId=='elf' and 'Bow' or 'Weapon'
 for _,child in mesh:GetDescendants()do if not child:IsA('SurfaceAppearance')then child:Destroy()end end
 mesh.Size=size;mesh.CFrame=CFrame.new(vector(spec.center))*CFrame.Angles(0,best*math.pi/2,0)
 mesh.Color=Color3.new(1,1,1);mesh.DoubleSided=true;mesh.RenderFidelity=Enum.RenderFidelity.Precise;mesh.Parent=model
 attachment(grip,'GripSocket',Vector3.zero);attachment(grip,'WeaponTip',vector(spec.tip))
 if spec.classId=='dwarf' then
  attachment(grip,'AxeCuttingDirection',Vector3.new(math.sqrt(.5),0,-math.sqrt(.5)))
  attachment(grip,'AxeFaceNormal',Vector3.new(-math.sqrt(.5),0,-math.sqrt(.5)))
  attachment(grip,'AxeCuttingEdge',Vector3.new(spec.center[1]+spec.size[1]/2,spec.tip[2]-.2,spec.center[3]-spec.size[3]/2))
 elseif spec.classId=='elf' then
  local original=storage.TDRefinedPlayerWeaponModels.ElfBow
  local originalGrip=original.Grip
  for _,partName in {'String','NockedArrow'}do
   local copy=original[partName]:Clone()
   for _,child in copy:GetDescendants()do if not child:IsA('SurfaceAppearance')then child:Destroy()end end
   copy.CFrame=originalGrip.CFrame:ToObjectSpace(original[partName].CFrame);copy.Parent=model
   if partName=='String'then copy.Transparency=1 end
  end
  for _,pair in {{'BowUpperRest','upper'},{'BowLowerRest','lower'},{'BowNockRest','nock'}}do attachment(grip,pair[1],vector(spec.bow[pair[2]]))end
 end
 for _,p in model:GetDescendants()do if p:IsA('BasePart')then
  p.Anchored=true;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 end end
 model:SetAttribute('MeshyTaskId',spec.meshyTaskId);model:SetAttribute('WeaponDefinitionId',spec.definitionId);model:SetAttribute('FourFamilyWeaponVersion',1)
 assert(not folder:FindFirstChild(model.Name),'Do not overwrite an existing reviewed template')
 model.Parent=folder
 table.insert(report,{id=spec.id,definitionId=spec.definitionId,meshId=mesh.MeshId,textureId=mesh.TextureID,size=spec.size,center=spec.center,rotationToSource=best*90,nativeVertices=#vertices,matchedSourceSamples=bestCount,orientationMatches=matched,modelAssetId=spec.modelId})
 task.wait()
end
game:GetService('ChangeHistoryService'):SetWaypoint('Prepared whitelisted four-family weapon templates')
return game.HttpService:JSONEncode(report)
