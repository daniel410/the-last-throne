-- Blender-authored round heads and individual decals projected onto the head surface.
local Recipes = require(game:GetService('ReplicatedStorage').Shared.NPCHeadRecipes)
local Head = {}

function Head.create(model, id, spirit)
 local recipe = assert(Recipes.characters[id], 'Missing NPC head: '..id)
 local rig = Instance.new('Model'); rig.Name = 'FaceRig'; rig.Parent = model
 for _, p in ipairs(recipe.parts) do
  local part = Instance.new('Part'); part.Name = p.name
  part.Size = Vector3.new(table.unpack(p.size))
  part.CFrame = CFrame.new(table.unpack(p.position)) * CFrame.Angles(0, 0, p.roll)
  part.Color = Color3.fromHex(p.color); part.Material = Enum.Material.SmoothPlastic
  part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
  part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
  part.CastShadow = not spirit; part:SetAttribute('TLTDecorative', true)
  if p.kind == 'sphere' then
   local mesh = Instance.new('SpecialMesh'); mesh.MeshType = Enum.MeshType.Sphere; mesh.Parent = part
  end
  if spirit then part.Transparency = .22 end
  part.Parent = rig
  if p.name == 'Head' then rig.PrimaryPart = part end
 end
 local decal = Instance.new('Decal'); decal.Name = 'FaceDecal'
 decal.Face = Enum.NormalId.Front; decal.Texture = recipe.face
 decal.Transparency = spirit and .12 or 0; decal.Parent = rig.PrimaryPart
 model:SetAttribute('NPCFaceTexture', recipe.face); model:SetAttribute('NPCFaceTile', recipe.tile)
 return rig
end

return Head
