local spec=game.HttpService:JSONDecode([==[__SPEC_JSON__]==])
local function v(a)return Vector3.new(a[1],a[2],a[3])end
local source=assert(game.ServerStorage:FindFirstChild(spec.importName))
local meshes={};for _,p in source:GetDescendants()do if p:IsA('MeshPart')then table.insert(meshes,p)end end
assert(#meshes==1);local raw=meshes[1]
assert((raw.Size-v(spec.size)).Magnitude<.0005)
local e=assert(game.AssetService:CreateEditableMeshAsync(Content.fromUri(raw.MeshId)))
local vertices={};for _,id in e:GetVertices()do table.insert(vertices,e:GetPosition(id))end
local best,count=0,-1
for turn=0,3 do
 local rotation=CFrame.Angles(0,turn*math.pi/2,0);local n=0
 for _,sample in spec.samples do
  for _,p in vertices do if (rotation:VectorToWorldSpace(p)-(v(sample)-v(spec.center))).Magnitude<.0005 then n+=1;break end end
 end
 if n>count then best,count=turn,n end
end
e:Destroy();assert(count==48,'Hair source geometry mismatch')
local p=raw:Clone();p.Name=spec.template
for _,c in p:GetChildren()do c:Destroy()end
p.Size=v(spec.size);p.CFrame=CFrame.new(v(spec.center))*CFrame.Angles(0,best*math.pi/2,0)
p.TextureID='';p.Color=Color3.new(1,1,1);p.Material=Enum.Material.SmoothPlastic
p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
p:SetAttribute('ArmorAnchor','Head');p:SetAttribute('ArmorReferenceAnchor',v(spec.referenceAnchor))
p:SetAttribute('ArmorLocalCenter',v(spec.center));p:SetAttribute('HeadgearHair',true)
local folder=assert(game.ServerStorage:FindFirstChild('HeadgearHairModels'))
local old=folder:FindFirstChild(spec.template);if old then old:Destroy()end
p.Parent=folder
game:GetService('ChangeHistoryService'):SetWaypoint('Prepare verified headgear hair '..spec.template)
return game.HttpService:JSONEncode({template=spec.template,meshId=p.MeshId,textureId=p.TextureID,
 modelAssetId=spec.modelAssetId,matchedSourceSamples=count,rotationToSource=best*90,
 size=spec.size,center=spec.center,nativeVertices=#vertices})
