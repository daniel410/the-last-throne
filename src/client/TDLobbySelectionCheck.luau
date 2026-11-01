--!strict
-- Native geometry avoids platform emoji/font fallback; callers own selection state.
local SelectionCheck = {}
SelectionCheck.color = Color3.fromRGB(222, 185, 106)
SelectionCheck.glyph = "✔"

local function stroke(label: TextLabel, name: string): Frame
 local old = label:FindFirstChild(name)
 local part = if old and old:IsA("Frame") then old else Instance.new("Frame")
 part:SetAttribute("TDCustomArtSurface", true)
 part.Name, part.BackgroundColor3, part.BackgroundTransparency = name, SelectionCheck.color, 0
 part.BorderSizePixel, part.Active, part.Selectable = 0, false, false
 part.AnchorPoint = Vector2.new(.5, .5)
 if not part:FindFirstChild("SelectionCheckCorner") then
  local corner = Instance.new("UICorner")
  corner.Name, corner.CornerRadius, corner.Parent = "SelectionCheckCorner", UDim.new(1, 0), part
 end
 part.Parent = label
 return part
end

local function layout(label: TextLabel)
 local side = math.min(label.AbsoluteSize.X, label.AbsoluteSize.Y)
 if side <= 0 then side = 20 end
 local thickness = side * .2
 local function place(name: string, x1: number, y1: number, x2: number, y2: number)
  local part = label:FindFirstChild(name) :: Frame
  local dx, dy = x2-x1, y2-y1
  part.Position = UDim2.new(.5, ((x1+x2)/2-.5)*side, .5, ((y1+y2)/2-.5)*side)
  part.Size = UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)*side, thickness)
  part.Rotation, part.ZIndex = math.deg(math.atan2(dy, dx)), label.ZIndex+1
 end
 place("SelectionCheckShortStroke", .20, .49, .42, .71)
 place("SelectionCheckLongStroke", .42, .71, .82, .27)
end

function SelectionCheck.apply(label: TextLabel, size: number?)
 label:SetAttribute("TDCustomArtSurface", true)
 label:SetAttribute("TDSelectionCheck", true)
 label.Text, label.Font = SelectionCheck.glyph, Enum.Font.GothamBlack
 label.TextColor3, label.TextStrokeColor3 = SelectionCheck.color, SelectionCheck.color
 -- Keep semantic text available while rendering only the two Gold strokes.
 label.TextStrokeTransparency, label.TextTransparency = 1, 1
 label.TextSize = size or 18
 label.RichText, label.TextScaled, label.TextWrapped = false, false, false
 label.TextXAlignment, label.TextYAlignment = Enum.TextXAlignment.Center, Enum.TextYAlignment.Center
 label.Active, label.Selectable = false, false
 stroke(label, "SelectionCheckShortStroke")
 stroke(label, "SelectionCheckLongStroke")
 if label:GetAttribute("TDSelectionGeometryBound") ~= true then
  label:SetAttribute("TDSelectionGeometryBound", true)
  label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() layout(label) end)
  label:GetPropertyChangedSignal("ZIndex"):Connect(function() layout(label) end)
 end
 layout(label)
end

return SelectionCheck
