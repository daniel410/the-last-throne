-- Blender-authored round heads and individual decals projected onto the head surface.
local Recipes = require(game:GetService('ReplicatedStorage').Shared.NPCHeadRecipes)
local Head = {}

local function decorate(part, tint, spirit, parent)
 part.Color = Color3.fromHex(tint); part.Material = Enum.Material.SmoothPlastic
 part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
 part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
 part.CastShadow = not spirit; part:SetAttribute('TLTDecorative', true)
 if spirit then part.Transparency = .22 end
 part.Parent = parent
end

-- Reconstruct the small ear/hat/hoop surfaces from their Blender triangles.
-- Hair uses smooth, tapered curve segments; it does not use triangle wedges.
local function triangle(parent, name, a, b, c, tint, spirit)
 local ab, ac, bc = b-a, c-a, c-b
 if ab:Dot(ab) > ac:Dot(ac) and ab:Dot(ab) > bc:Dot(bc) then a,c = c,a
 elseif ac:Dot(ac) > bc:Dot(bc) then a,b = b,a end
 ab, ac, bc = b-a, c-a, c-b
 local normal = ac:Cross(ab)
 if normal.Magnitude < .00001 or bc.Magnitude < .00001 then return end
 local right, back = normal.Unit, bc.Unit
 local up = back:Cross(right).Unit
 local height = math.abs(ab:Dot(up))
 for _, p in ipairs({
  {size=Vector3.new(.012,height,math.abs(ab:Dot(back))), cf=CFrame.fromMatrix((a+b)*.5,right,up,back)},
  {size=Vector3.new(.012,height,math.abs(ac:Dot(back))), cf=CFrame.fromMatrix((a+c)*.5,-right,up,-back)},
 }) do
  if p.size.Y > .00001 and p.size.Z > .00001 then
   local wedge = Instance.new('WedgePart'); wedge.Name = name
   wedge.Size = p.size; wedge.CFrame = p.cf
   decorate(wedge, tint, spirit, parent)
  end
 end
end

function Head.create(model, id, spirit)
 local recipe = assert(Recipes.characters[id], 'Missing NPC head: '..id)
 local rig = Instance.new('Model'); rig.Name = 'FaceRig'; rig.Parent = model
 for _, p in ipairs(recipe.parts) do
  local part = Instance.new('Part'); part.Name = p.name
  part.Size = Vector3.new(table.unpack(p.size))
  local rotation = p.frame and CFrame.new(0,0,0,table.unpack(p.frame)) or CFrame.Angles(0,0,p.roll)
  part.CFrame = CFrame.new(table.unpack(p.position)) * rotation
  if p.kind == 'sphere' then
   local mesh = Instance.new('SpecialMesh'); mesh.MeshType = Enum.MeshType.Sphere; mesh.Parent = part
  end
  decorate(part, p.color, spirit, rig)
  if p.surface == 'hair' and Recipes.hairSurface then
   local fibers = Instance.new('Decal'); fibers.Name = 'HairFibers'
   fibers.Face = Enum.NormalId.Front; fibers.Texture = Recipes.hairSurface
   fibers.Color3 = part.Color; fibers.Transparency = .55; fibers.Parent = part
  end
  if p.name == 'Head' then rig.PrimaryPart = part end
 end
 for _, surface in ipairs(recipe.meshes or {}) do
  local vertices = {}
  for _, xyz in ipairs(surface.vertices) do table.insert(vertices, Vector3.new(table.unpack(xyz))) end
  for _, indices in ipairs(surface.triangles) do
   triangle(rig, surface.name, vertices[indices[1]+1],vertices[indices[2]+1],vertices[indices[3]+1],surface.color,spirit)
  end
 end
 local decal = Instance.new('Decal'); decal.Name = 'FaceDecal'
 decal.Face = Enum.NormalId.Front; decal.Texture = recipe.face
 decal.Transparency = spirit and .12 or 0; decal.Parent = rig.PrimaryPart
 model:SetAttribute('NPCFaceTexture', recipe.face); model:SetAttribute('NPCFaceTile', recipe.tile)
 return rig
end

return Head
