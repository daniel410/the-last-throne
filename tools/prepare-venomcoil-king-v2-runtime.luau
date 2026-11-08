-- Prepare a local unlinked runtime copy of the eight approved imports. No Place publication.
local storage=game:GetService('ServerStorage')
local imported=storage
local prior=assert(storage:FindFirstChild('GloamwoodMeshyModels'))
local specs={VenomcoilKing={axis='Z',extent=11.32,bones=14}}
local folder=prior:Clone();folder.VenomcoilKing:Destroy()
local report={}
for kind,spec in pairs(specs)do
 local original=assert(imported:FindFirstChild('VenomcoilKingV2Imported'));local meshes={}
 for _,o in original:GetDescendants()do if o:IsA('MeshPart')then table.insert(meshes,o)end end
 assert(#meshes==1,'Expected one intact skinned mesh per kind')
 local source=meshes[1];local model=Instance.new('Model');model.Name=kind
 local body=source:Clone();body.Name='Body'
 for _,o in body:GetDescendants()do if not o:IsA('Bone') and not o:IsA('SurfaceAppearance')then o:Destroy()end end
 local count=0;local bones={}
 for _,b in body:GetDescendants()do if b:IsA('Bone')then count+=1;b.Transform=CFrame.identity;table.insert(bones,{name=b.Name,parent=b.Parent.Name,cf={b.CFrame:GetComponents()}})end end
 assert(count==spec.bones,'Bone count mismatch '..kind)
 assert(body.MeshId~='' and (body.TextureID~='' or body:FindFirstChildOfClass('SurfaceAppearance')),'Missing mesh/texture')
 body.DoubleSided=true -- Preserve the source glTF material's doubleSided flag.
 body.RenderFidelity=Enum.RenderFidelity.Precise -- Preserve the thin tail silhouette at combat distance.
 body.Color=Color3.new(1,1,1) -- Source glTF baseColorFactor defaults to white.
 body.CFrame=CFrame.new(0,body.Size.Y/2,0);body.Anchored=true;body.Massless=true;body.CanCollide=false;body.CanTouch=false;body.CanQuery=false;body.Parent=model
 local root=Instance.new('Part');root.Name='VisualRoot';root.Size=Vector3.new(.01,.01,.01);root.CFrame=CFrame.identity;root.Transparency=1;root.Anchored=true;root.Massless=true;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.Parent=model
 local weld=Instance.new('WeldConstraint');weld.Name='MeshRootWeld';weld.Part0=root;weld.Part1=body;weld.Parent=body
 model.PrimaryPart=root;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local scale=spec.extent/body.Size[spec.axis]
 for name,value in pairs({SourceHeight=body.Size.Y,SourceToStudScale=scale,TargetHeight=body.Size.Y*scale,HoverHeight=kind=='Gloambat' and 1.2 or 0})do local n=Instance.new('NumberValue');n.Name=name;n.Value=value;n.Parent=model end
 model:SetAttribute('GloamwoodMeshyVersion',2);model:SetAttribute('ExpectedBones',spec.bones)
 model.Parent=folder
 table.insert(report,{kind=kind,meshId=body.MeshId,textureId=body.TextureID,size={body.Size.X,body.Size.Y,body.Size.Z},cf={body.CFrame:GetComponents()},bones=bones,scale=scale,targetHeight=body.Size.Y*scale,axis=spec.axis,targetExtent=spec.extent})
end
folder.Name='VenomcoilKingV2Runtime';folder.Parent=storage
local export=folder:Clone();export.Name='GloamwoodMeshyModels'
local binary=game:GetService('SerializationService'):SerializeInstancesAsync({export})
export:Destroy()
local chunks=Instance.new('Folder');chunks.Name='VenomcoilKingV2Export'
for start=0,buffer.len(binary)-1,8000 do
 local hex={};for i=start,math.min(start+7999,buffer.len(binary)-1)do table.insert(hex,string.format('%02x',buffer.readu8(binary,i)))end
 local v=Instance.new('StringValue');v.Name='Chunk'..math.floor(start/8000+1);v.Value=table.concat(hex);v.Parent=chunks
end
chunks.Parent=storage
game:GetService('ChangeHistoryService'):SetWaypoint('Prepared Venomcoil King v2 runtime')
return game.HttpService:JSONEncode({bytes=buffer.len(binary),chunks=math.ceil(buffer.len(binary)/8000),models=report})
