-- Surveyed world surfaces, stored locally at build time.
local encoding = game:GetService("EncodingService")
local Plate = {}

-- Render baked terrain with UI gradients so published maps work with the
-- default experience security settings.
local function drawTerrain(frame, data, width, height, detail)
 -- Bound the number of UI objects when several zones share the overview.
 local columns, rows, stops = detail and 8 or 3, detail and 64 or 18, 16
 local colors = {}
 for i = 0, 254 do
  local p = 4 + i * 3
  colors[i] = Color3.fromRGB(buffer.readu8(data,p), buffer.readu8(data,p+1), buffer.readu8(data,p+2))
 end
 colors[255] = Color3.new()
 for y = 0, rows-1 do
  for x = 0, columns-1 do
   local band = Instance.new("Frame")
   band.BorderSizePixel = 0
   band.BackgroundColor3 = Color3.new(1,1,1)
   band.Position = UDim2.fromScale(x/columns, y/rows)
   band.Size = UDim2.new(1/columns,1,1/rows,1)
   local keys, alpha = {}, {}
   local visible = false
   for i = 0, stops-1 do
    local u = (x + i/(stops-1))/columns
    local pixel = math.floor((y+.5)/rows * height)*width + math.round(u*(width-1))
    local index = buffer.readu8(data,772+pixel)
    keys[i+1] = ColorSequenceKeypoint.new(i/(stops-1), colors[index])
    alpha[i+1] = NumberSequenceKeypoint.new(i/(stops-1),index==255 and 1 or 0)
    if index~=255 then visible = true end
   end
   if not visible then band:Destroy();continue end
   local gradient = Instance.new("UIGradient")
   gradient.Color = ColorSequence.new(keys)
   gradient.Transparency = NumberSequence.new(alpha)
   gradient.Parent = band
   band.Parent = frame
  end
 end
end

function Plate.draw(parent, zoneId, detail)
 -- A replicated sibling is not guaranteed to be available when the
 -- menu first opens. Let the canvas use its surveyed geometry until it is.
 local plates = script.Parent:FindFirstChild("AtlasPlates")
 local entry = plates and plates:FindFirstChild("Relief_"..zoneId)
 if not entry or not entry:IsA("StringValue") or entry.Value == "" then return nil end
 local decoded, data = pcall(function()
  return encoding:DecompressBuffer(encoding:Base64Decode(buffer.fromstring(entry.Value)), Enum.CompressionAlgorithm.Zstd)
 end)
 if not decoded or buffer.len(data)<772 then return nil end
 local width, height = buffer.readu16(data,0), buffer.readu16(data,2)
 if width<1 or height<1 or width>1024 or height>1024 or buffer.len(data)~=772+width*height then return nil end
 local frame = Instance.new("Frame")
 frame.Name = "Relief"
 frame.BackgroundTransparency = 1
 frame.ClipsDescendants = true
 frame.Size = UDim2.fromScale(1,1)
 drawTerrain(frame,data,width,height,detail)
 frame.Parent = parent
 return frame
end

return Plate
