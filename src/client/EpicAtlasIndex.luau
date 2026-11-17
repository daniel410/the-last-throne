local Shared = game.ReplicatedStorage.Shared
local Content = require(Shared.CampaignContent)
local Theme = require(script.Parent.TDInventoryTheme)
local Index = {}

function Index.create(parent, inspect)
 local frame = Instance.new("Frame")
 frame.Name = "EpicIndex"
 frame.BackgroundColor3 = Theme.color.ink
 frame.BorderSizePixel = 0
 frame.ClipsDescendants = true
 frame.Parent = parent
 local title = Theme.label(frame,"Region","",UDim2.new(),UDim2.new(),16,Theme.color.gold)
 title.Font = Enum.Font.GothamBold
 local list = Instance.new("ScrollingFrame")
 list.Name = "Regions"
 list.BackgroundTransparency = 1
 list.BorderSizePixel = 0
 list.ScrollBarThickness = 3
 list.CanvasSize = UDim2.new()
 list.Parent = frame
 local epic
 local function show(index)
  if index == epic then return end
  epic = index
  list:ClearAllChildren()
  local e = Content.epics[epic]
  title.Text = e.region
  local ids = {}
  for id,z in pairs(Content.zones) do if z.epic == epic then table.insert(ids,id) end end
  table.sort(ids)
  for i,id in ipairs(ids) do
   local button = Instance.new("TextButton")
   button.Name = id
   button.BackgroundColor3 = Theme.color.navy
   button.BorderSizePixel = 0
   button.Text = ""
   button.Position = UDim2.fromOffset(0,(i-1)*45)
   button.Size = UDim2.new(1,-4,0,44)
   button.Parent = list
   local c = Content.byId[id]
   local order = c and string.format("%02d",(c.number-1)%7+1) or "+"
   Theme.label(button,"Order",order,UDim2.fromOffset(6,0),UDim2.fromOffset(22,44),10,Theme.color.gold)
   Theme.label(button,"Name",Content.zones[id].name,UDim2.fromOffset(30,0),UDim2.new(1,-34,1,0),11)
   button.Activated:Connect(function() inspect(id) end)
  end
  list.CanvasPosition = Vector2.zero
  list.CanvasSize = UDim2.fromOffset(0,#ids*45)
 end
 local function arrange(area,journey)
  -- Both map menus first assign their full chart rectangle in parent space.
  local besideJourney = journey and journey.Visible
  if besideJourney then
   frame.Visible = false
   return
  end
  local outer = parent.AbsoluteSize
  local pos, size = area.Position, area.Size
  local w = size.X.Scale*outer.X+size.X.Offset
  local h = size.Y.Scale*outer.Y+size.Y.Offset
  local side = w >= 425
  frame.Visible = w > 170 and h > (side and 95 or 205)
  if not frame.Visible then return end
  frame.Position = pos
  if side then
   local width = math.clamp(math.floor(w*.28),125,245)
   frame.Size = UDim2.fromOffset(width,h)
   area.Position = pos + UDim2.fromOffset(width+5,0)
   area.Size = size - UDim2.fromOffset(width+5,0)
   title.Position = UDim2.fromOffset(7,0)
   title.Size = UDim2.new(1,-12,0,30)
   list.Position = UDim2.fromOffset(3,32)
   list.Size = UDim2.new(1,-6,1,-35)
  else
   local height = math.clamp(math.floor(h*.24),68,105)
   frame.Size = UDim2.fromOffset(w,height)
   area.Position = pos + UDim2.fromOffset(0,height+4)
   area.Size = size - UDim2.fromOffset(0,height+4)
   title.Position = UDim2.fromOffset(7,0)
   title.Size = UDim2.new(1,-12,0,23)
   list.Position = UDim2.fromOffset(3,24)
   list.Size = UDim2.new(1,-6,1,-24)
  end
 end
 return {show=show,arrange=arrange}
end

return Index
