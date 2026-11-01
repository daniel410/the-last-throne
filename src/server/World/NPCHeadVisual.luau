-- Blender-authored round heads and a shared transparent face atlas.
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
 local carrier = Instance.new('Part'); carrier.Name = 'FaceDecalCarrier'
 carrier.Size = Vector3.new(1.72, 1.86, .02); carrier.CFrame = CFrame.new(0, 5.18, -.673)
 carrier.Transparency = 1; carrier.Anchored = true; carrier.CanCollide = false
 carrier.CanTouch = false; carrier.CanQuery = false; carrier.CastShadow = false
 carrier:SetAttribute('TLTDecorative', true); carrier.Parent = rig
 local gui = Instance.new('SurfaceGui'); gui.Name = 'FaceDecal'; gui.Face = Enum.NormalId.Front
 gui.CanvasSize = Vector2.new(Recipes.tileSize, Recipes.tileSize)
 gui.AlwaysOnTop = false; gui.LightInfluence = 1; gui.MaxDistance = 90
 gui.Parent = carrier
 local image = Instance.new('ImageLabel'); image.Name = 'Expression'; image.BackgroundTransparency = 1
 image.Size = UDim2.fromScale(1, 1); image.Image = Recipes.atlas
 image.ImageRectSize = Vector2.new(Recipes.tileSize, Recipes.tileSize)
 image.ImageRectOffset = Vector2.new(recipe.tile % 5, math.floor(recipe.tile / 5)) * Recipes.tileSize
 image.ImageTransparency = spirit and .12 or 0; image.Parent = gui
 model:SetAttribute('NPCFaceAtlas', Recipes.atlas); model:SetAttribute('NPCFaceTile', recipe.tile)
 return rig
end

return Head
