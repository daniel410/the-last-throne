-- Inject one small batch of audited prepared geometry records in Edit mode.
local specs=game.HttpService:JSONDecode([==[__SPEC_JSON__]==])
local storage=game:GetService("ServerStorage")
local folder=storage:FindFirstChild("FourFamilyArmorModels")
if not folder then folder=Instance.new("Folder");folder.Name="FourFamilyArmorModels";folder.Parent=storage end
local function v(a)return Vector3.new(a[1],a[2],a[3])end
local report={}
for _,spec in specs do
 local source=assert(storage:FindFirstChild("TLT_"..spec.id.."_Import"),"Missing import "..spec.id)
 local rawParts={};local rawCount=0
 for _,part in source:GetDescendants() do
  if part:IsA("MeshPart") then
   local name=part.Name:match("^[^.]+")
   assert(not rawParts[name],"Duplicate mesh "..name)
   rawParts[name]=part;rawCount+=1
  elseif part:IsA("LuaSourceContainer") then error("Unexpected imported code") end
 end
 assert(rawCount==#spec.parts,"Mesh count changed "..spec.id)
 local model=Instance.new("Model");model.Name=spec.id
 local row={id=spec.id,definitionId=spec.definitionId,meshyTaskId=spec.meshyTaskId,parts={}}
 for _,piece in spec.parts do
  local raw=assert(rawParts[piece.name],"Missing panel "..piece.name)
  assert((raw.Size-v(piece.size)).Magnitude<.0005,"Native size changed "..spec.id.."/"..piece.name)
  assert(raw.MeshId~="" and raw.TextureID~="","Missing mesh/color texture")
  local editable=game:GetService("AssetService"):CreateEditableMeshAsync(Content.fromUri(raw.MeshId))
  assert(editable,"Editable mesh allocation failed")
  local vertices={};for _,id in editable:GetVertices()do table.insert(vertices,editable:GetPosition(id))end
  local best,bestCount=0,-1
  for turn=0,3 do
   local rotation=CFrame.Angles(0,turn*math.pi/2,0);local rotated={}
   for _,p in vertices do table.insert(rotated,rotation:VectorToWorldSpace(p))end
   local count=0
   for _,sample in piece.samples do
    local wanted=v(sample)-v(piece.center)
    for _,p in rotated do if (p-wanted).Magnitude<.0005 then count+=1;break end end
   end
   if count>bestCount then best,bestCount=turn,count end
  end
  editable:Destroy()
  assert(bestCount==#piece.samples,"Native geometry/orientation mismatch "..spec.id.."/"..piece.name.." "..bestCount)
  local mesh=raw:Clone();mesh.Name=piece.name
  for _,child in mesh:GetChildren()do if not child:IsA("SurfaceAppearance")then child:Destroy()end end
  mesh.Size=v(piece.size);mesh.CFrame=CFrame.new(v(piece.center))*CFrame.Angles(0,best*math.pi/2,0)
  mesh.Color=Color3.new(1,1,1);mesh.DoubleSided=true;mesh.Transparency=0
  mesh.Anchored=true;mesh.Massless=true;mesh.CanCollide=false;mesh.CanTouch=false;mesh.CanQuery=false
  mesh:SetAttribute("ArmorAnchor",piece.anchor)
  mesh:SetAttribute("ArmorReferenceAnchor",v(piece.referenceAnchor))
  mesh:SetAttribute("ArmorLocalCenter",v(piece.center))
  mesh.Parent=model
  table.insert(row.parts,{name=piece.name,meshId=mesh.MeshId,textureId=mesh.TextureID,
   size=piece.size,center=piece.center,nativeVertices=#vertices,matchedSourceSamples=bestCount,rotationToSource=best*90})
 end
 model:SetAttribute("MeshyTaskId",spec.meshyTaskId)
 model:SetAttribute("ArmorPartCount",#spec.parts)
 model:SetAttribute("ArmorVisualVersion",1)
 assert(not folder:FindFirstChild(model.Name),"Do not overwrite reviewed templates")
 model.Parent=folder;table.insert(report,row);task.wait()
end
game:GetService("ChangeHistoryService"):SetWaypoint("Prepared four-family armor templates")
return game.HttpService:JSONEncode(report)
