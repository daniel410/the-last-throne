-- Inject audited JSON into specs; run in Edit in small batches.
local specs=game.HttpService:JSONDecode([==[__SPEC_JSON__]==])
local storage=game:GetService('ServerStorage')
local folder=storage:FindFirstChild('FourFamilyShieldModels')
if not folder then folder=Instance.new('Folder');folder.Name='FourFamilyShieldModels';folder.Parent=storage end
local report={}
local function vector(v)return Vector3.new(v[1],v[2],v[3])end
local function attachment(grip,name,position)
 local a=Instance.new('Attachment');a.Name=name;a.Position=position;a.Parent=grip;return a
end
for _,spec in specs do
 local name='TLT_'..spec.id..'_Import'
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
   local wanted=vector(sample)-vector(spec.center)
   for _,p in rotated do if (p-wanted).Magnitude<.0003 then count+=1;break end end
  end
  matched[tostring(turn)]=count
  if count>bestCount then best,bestCount=turn,count end
 end
 editable:Destroy()
 assert(bestCount==#spec.samples,'Native mesh geometry/orientation mismatch '..spec.id..' '..game.HttpService:JSONEncode(matched))
 local model=Instance.new('Model');model.Name=spec.definitionId
 local grip=Instance.new('Part');grip.Name='Grip';grip.Size=Vector3.new(.12,.12,.12);grip.Transparency=1;grip.CastShadow=false;grip.CFrame=CFrame.identity;grip.Parent=model;model.PrimaryPart=grip
 local mesh=raw:Clone();mesh.Name='Shield'
 for _,child in mesh:GetDescendants()do if not child:IsA('SurfaceAppearance')then child:Destroy()end end
 mesh.Size=size;mesh.CFrame=CFrame.new(vector(spec.center))*CFrame.Angles(0,best*math.pi/2,0)
 mesh.Color=Color3.new(1,1,1);mesh.DoubleSided=true;mesh.RenderFidelity=Enum.RenderFidelity.Precise;mesh.Parent=model
 attachment(grip,'GripSocket',Vector3.zero)
 for _,p in model:GetDescendants()do if p:IsA('BasePart')then
  p.Anchored=true;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 end end
 model:SetAttribute('MeshyTaskId',spec.meshyTaskId);model:SetAttribute('ShieldDefinitionId',spec.definitionId);model:SetAttribute('FourFamilyShieldVersion',1)
 assert(not folder:FindFirstChild(model.Name),'Do not overwrite an existing reviewed template')
 model.Parent=folder
 table.insert(report,{id=spec.id,definitionId=spec.definitionId,meshId=mesh.MeshId,textureId=mesh.TextureID,size=spec.size,center=spec.center,rotationToSource=best*90,nativeVertices=#vertices,matchedSourceSamples=bestCount,orientationMatches=matched,modelAssetId=spec.modelId})
 task.wait()
end
game:GetService('ChangeHistoryService'):SetWaypoint('Prepared whitelisted four-family shield templates')
local binary=game:GetService('SerializationService'):SerializeInstancesAsync({folder})
local chunks=Instance.new('Folder');chunks.Name='FourFamilyShieldExport'
for start=0,buffer.len(binary)-1,8000 do
 local hex={};for i=start,math.min(start+7999,buffer.len(binary)-1)do table.insert(hex,string.format('%02x',buffer.readu8(binary,i)))end
 local v=Instance.new('StringValue');v.Name='Chunk'..math.floor(start/8000+1);v.Value=table.concat(hex);v.Parent=chunks
end
chunks.Parent=storage
return game.HttpService:JSONEncode({models=report,bytes=buffer.len(binary),chunks=math.ceil(buffer.len(binary)/8000)})
