-- Inject uploaded skin-manifest records into __SPEC_JSON__; process a few NPCs per call.
local specs=game.HttpService:JSONDecode([==[__SPEC_JSON__]==])
local storage=game:GetService('ServerStorage')
local folder=storage:FindFirstChild('NPCMeshyModels')
if not folder then folder=Instance.new('Folder');folder.Name='NPCMeshyModels';folder.Parent=storage end
local report={}
local function vector(a)return Vector3.new(a[1],a[2],a[3])end
for _,spec in specs do
 assert(spec.id~='selene','Excluded source')
 assert(not folder:FindFirstChild(spec.id),'Do not duplicate an existing template')
 local imported=assert(storage:FindFirstChild('TLT_NPC_'..spec.id..'_Import'),'Missing uploaded model '..spec.id)
 local meshes={}
 for _,p in imported:GetDescendants()do if p:IsA('MeshPart')then table.insert(meshes,p)end end
 assert(#meshes==1,'Expected one continuous skinned mesh '..spec.id)
 local raw=meshes[1]
 assert(raw.MeshId~='' and (raw.TextureID~='' or raw:FindFirstChildWhichIsA('SurfaceAppearance')),'Missing texture '..spec.id)
 local editable=game:GetService('AssetService'):CreateEditableMeshAsync(Content.fromUri(raw.MeshId))
 local vertices={};for _,id in editable:GetVertices()do table.insert(vertices,editable:GetPosition(id))end
 local faceCount=#editable:GetFaces()
 local matches={};local best,bestCount=0,-1
 for turn=0,3 do
  local rotation=CFrame.Angles(0,turn*math.pi/2,0)
  local count=0
  for _,sample in spec.samples do
   local wanted=vector(sample)-vector(spec.center)
   for _,p in vertices do if (rotation:VectorToWorldSpace(p)-wanted).Magnitude<.0004 then count+=1;break end end
  end
  matches[tostring(turn)]=count
  if count>bestCount then best,bestCount=turn,count end
 end
 editable:Destroy()
 assert(bestCount==#spec.samples,'Geometry/orientation mismatch '..spec.id..' '..game.HttpService:JSONEncode(matches))
 assert(faceCount==spec.triangles and faceCount<=5000,'Triangle mismatch '..spec.id)
 local m=Instance.new('Model');m.Name=spec.id
 local root=Instance.new('Part');root.Name='ActorRoot';root.Size=Vector3.one*.01
 root.Transparency=1;root.CastShadow=false;root.CFrame=CFrame.identity;root.Parent=m;m.PrimaryPart=root
 local mesh=raw:Clone();mesh.Name='BodyMesh'
 for _,p in mesh:GetDescendants()do
  if p:IsA('LuaSourceContainer') or p:IsA('PackageLink') then p:Destroy() end
 end
 mesh.Size=vector(spec.size)
 -- Blender -Y 정면은 glTF +Z다. 게임의 -Z 정면으로 한 번 더 돌린다.
 mesh.CFrame=CFrame.Angles(0,math.pi,0)*CFrame.new(vector(spec.center))*CFrame.Angles(0,best*math.pi/2,0)
 mesh.Color=Color3.new(1,1,1);mesh.RenderFidelity=Enum.RenderFidelity.Precise;mesh.Parent=m
 local bones={}
 for _,bone in mesh:GetDescendants()do if bone:IsA('Bone')then bones[bone.Name]=bone end end
 for _,name in spec.bones do assert(bones[name],'Missing native bone '..name..' for '..spec.id)end
 for _,p in m:GetDescendants()do if p:IsA('BasePart')then
  p.Anchored=true;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 end end
 m:SetAttribute('NPCMeshyTemplateVersion',1);m:SetAttribute('NPCSourceHeight',spec.sourceHeight)
 m:SetAttribute('NPCSourceSha256',spec.sourceSha256);m:SetAttribute('NPCSkinSha256',spec.sha256)
 m:SetAttribute('NPCTriangles',spec.triangles);m.Parent=folder
 local surface=mesh:FindFirstChildWhichIsA('SurfaceAppearance')
 table.insert(report,{id=spec.id,modelAssetId=spec.modelAssetId,meshId=mesh.MeshId,textureId=mesh.TextureID,
  colorMap=surface and surface.ColorMap or '',triangles=faceCount,bones=spec.bones,
  sourceSamplesMatched=bestCount,orientationMatches=matches,rotationToSource=best*90,gameFacingAdjustment=180,
  size=spec.size,center=spec.center})
 task.wait()
end
game:GetService('ChangeHistoryService'):SetWaypoint('Prepared approved NPC mesh templates')
return game.HttpService:JSONEncode(report)
