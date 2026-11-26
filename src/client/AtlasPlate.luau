-- Surveyed world surfaces, stored locally at build time.
local encoding = game:GetService("EncodingService")
local assets = game:GetService("AssetService")
-- Published places must opt in after enabling Mesh / Image APIs.
local useTextures = game:GetService("RunService"):IsStudio() or script:GetAttribute("EnableAtlasTextures") == true
local Plate = {}

local paletteSize = 255
local pixelOffset = 4 + paletteSize * 3 + 3

local function drawTexture(data, width, height)
 local size = Vector2.new(width, height)
 local image, label
 local ok = pcall(function()
  image = assets:CreateEditableImage({Size = size})
  if not image then return end
  local palette = {}
  for i = 0, paletteSize-1 do
   palette[i] = buffer.readu32(data,4+i*3) % 0x1000000 + 0xFF000000
  end
  palette[255] = 0
  local pixels = buffer.create(width*height*4)
  for i = 0, width*height-1 do
   buffer.writeu32(pixels,i*4,palette[buffer.readu8(data,pixelOffset+i)])
  end
  image:WritePixelsBuffer(Vector2.zero,size,pixels)
  label = Instance.new("ImageLabel")
  label.ImageContent = Content.fromObject(image)
 end)
 if not ok or not label then
  if label then label:Destroy() end
  if image then image:Destroy() end
  return nil
 end
 label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
  local displayed = label.AbsoluteSize
  label.ResampleMode = (displayed.X > width or displayed.Y > height)
   and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default
 end)
 label.Destroying:Connect(function() image:Destroy() end)
 return label
end

-- Keep a bounded terrain layer for clients without editable-image support.
local function drawTerrain(frame, data, width, height, detail)
 local columns, rows, stops = detail and 8 or 6, detail and 64 or 48, 16
 local colors = {}
 for i = 0, paletteSize-1 do
  local p = 4 + i * 3
  colors[i] = Color3.fromRGB(buffer.readu8(data,p), buffer.readu8(data,p+1), buffer.readu8(data,p+2))
 end
 colors[255] = Color3.new()
 for y = 0, rows-1 do
  for x = 0, columns-1 do
   local band = Instance.new("Frame")
   band.Name = "TerrainBand"
   band.BorderSizePixel = 0
   band.BackgroundColor3 = Color3.new(1,1,1)
   band.Position = UDim2.fromScale(x/columns, y/rows)
   band.Size = UDim2.new(1/columns,1,1/rows,1)
   local keys, alpha = {}, {}
   local visible = false
   for i = 0, stops-1 do
    local u = (x + i/(stops-1))/columns
    local pixel = math.floor((y+.5)/rows * height)*width + math.round(u*(width-1))
    local index = buffer.readu8(data,pixelOffset+pixel)
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
 if not decoded or buffer.len(data)<pixelOffset then return nil end
 local width, height = buffer.readu16(data,0), buffer.readu16(data,2)
 if width<1 or height<1 or width>1024 or height>1024 or buffer.len(data)~=pixelOffset+width*height then return nil end
 local relief = useTextures and drawTexture(data,width,height)
 if not relief then
  relief = Instance.new("Frame")
  drawTerrain(relief,data,width,height,detail)
 end
 relief.Name = "Relief"
 relief.BackgroundTransparency = 1
 relief.ClipsDescendants = true
 relief.Size = UDim2.fromScale(1,1)
 relief.Parent = parent
 return relief
end

function Plate.shade(relief, tint)
 if relief:IsA("ImageLabel") then
  relief.ImageColor3 = tint
 else
  for _, band in ipairs(relief:GetChildren()) do
   if band.Name == "TerrainBand" then band.BackgroundColor3 = tint end
  end
 end
end

return Plate
