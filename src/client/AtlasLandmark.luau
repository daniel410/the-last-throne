-- Small isometric illustrations of the structures placed in CampaignWorld.
local Landmark = {}

function Landmark.draw(parent, signature, position)
 local view = Instance.new("ViewportFrame")
 view.Name = "LandmarkPortrait"
 view.BackgroundTransparency = 1
 view.AnchorPoint = Vector2.new(.5, .5)
 view.Position = position
 view.Ambient = Color3.fromRGB(170, 178, 188)
 view.LightColor = Color3.fromRGB(255, 232, 192)
 view.LightDirection = Vector3.new(-1, -1, -.6)
 view.ZIndex = 7

 local model = Instance.new("Model")
 for _, row in ipairs(signature.parts) do
  local part = Instance.new(row[1] == "Wedge" and "WedgePart" or "Part")
  if part:IsA("Part") then part.Shape = Enum.PartType[row[1]] end
  part.Anchored = true
  part.Size = Vector3.new(row[2], row[3], row[4])
  part.CFrame = CFrame.new(row[5], row[6], row[7]) * CFrame.fromOrientation(row[8], row[9], row[10])
  part.Color = Color3.fromRGB(row[11], row[12], row[13])
  part.Parent = model
 end
 model.Parent = view
 local center, size = model:GetBoundingBox()
 local camera = Instance.new("Camera")
 camera.FieldOfView = 24
 local direction = Vector3.new(.52, .60, 1).Unit
 camera.CFrame = CFrame.lookAt(center.Position + direction * size.Magnitude * 2.25, center.Position)
 camera.Parent = view
 view.CurrentCamera = camera
 view.Parent = parent
 return view
end

return Landmark
