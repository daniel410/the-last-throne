-- Surveyed world surfaces, stored locally at build time.
local assets = game:GetService("AssetService")
local encoding = game:GetService("EncodingService")
local plates = script.Parent.AtlasPlates
local Plate = {}

local function fallback(frame, data, width, height, detail)
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
 local data = encoding:DecompressBuffer(encoding:Base64Decode(buffer.fromstring(plates["Relief_"..zoneId].Value)), Enum.CompressionAlgorithm.Zstd)
 local width, height = buffer.readu16(data,0), buffer.readu16(data,2)
 local scale = detail and 1 or math.min(1,160/math.max(width,height))
 local size = Vector2.new(math.max(1,math.round(width*scale)),math.max(1,math.round(height*scale)))
 local ok, image = pcall(function() return assets:CreateEditableImage({Size=size}) end)
 if not ok or not image then
  local frame = Instance.new("Frame")
  frame.Name = "Relief"
  frame.BackgroundTransparency = 1
  frame.ClipsDescendants = true
  frame.Size = UDim2.fromScale(1,1)
  fallback(frame,data,width,height,detail)
  frame.Parent = parent
  return frame
 end
 local palette = {}
 for i = 0, 254 do
  local offset = 4+i*3
  palette[i] = buffer.readu8(data,offset)+buffer.readu8(data,offset+1)*256+buffer.readu8(data,offset+2)*65536+0xFF000000
 end
 palette[255] = 0
 local pixels = buffer.create(size.X*size.Y*4)
 for y = 0, size.Y-1 do
  local row = math.floor((y+.5)*height/size.Y)*width
  for x = 0, size.X-1 do
   local source = row + math.floor((x+.5)*width/size.X)
   buffer.writeu32(pixels,(y*size.X+x)*4,palette[buffer.readu8(data,772+source)])
  end
 end
 image:WritePixelsBuffer(Vector2.zero,size,pixels)
 local label = Instance.new("ImageLabel")
 label.Name = "Relief"
 label.ImageContent = Content.fromObject(image)
 label.BackgroundTransparency = 1
 label.Size = UDim2.fromScale(1,1)
 label.ScaleType = Enum.ScaleType.Stretch
 label.Destroying:Connect(function() image:Destroy() end)
 label.Parent = parent
 return label
end

return Plate
