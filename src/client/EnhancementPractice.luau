local Shared = game:GetService("ReplicatedStorage").Shared
local Enhancement = require(Shared.Enhancement)
local Text = require(Shared.AdventureText)
local Theme = require(script.Parent.TDInventoryTheme)

local Practice = {}
local sample = {stats = {power = 100}}
local cost = Enhancement.cost(sample, 1)
local basePower = Enhancement.stats(sample, {enhancementLevel = 0}).power
local enhancedPower = Enhancement.stats(sample, {enhancementLevel = 1}).power

function Practice.create(parent, onFinish)
	local content = Instance.new("Frame")
	content.Name = "EnhancementPractice"
	content.BackgroundTransparency = 1
	content.Visible = false
	content.Parent = parent

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Instructions"
	scroll.Size = UDim2.new(1, 0, 1, -52)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.Parent = content

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 6), UDim.new(0, 12)
	padding.Parent = scroll
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local progress = Theme.label(scroll, "Progress", "", UDim2.new(), UDim2.new(1, 0, 0, 0), 14, Theme.color.gold)
	local title = Theme.label(scroll, "Title", "", UDim2.new(), UDim2.new(1, 0, 0, 0), 20)
	local body = Theme.label(scroll, "Description", "", UDim2.new(), UDim2.new(1, 0, 0, 0), 14)
	for index, label in ipairs({progress, title, body}) do
		label.AutomaticSize = Enum.AutomaticSize.Y
		label.LayoutOrder = index
	end
	local action = Theme.button(content, "Next", "", UDim2.new(0, 6, 1, -44), UDim2.new(1, -12, 0, 44), true)

	local step = 1
	local function render()
		local lesson = Text.EnhancementPracticeSteps[step]
		progress.Text = string.format(Text.EnhancementPracticeProgress, step)
		title.Text, action.Caption.Text = lesson.title, lesson.button
		body.Text = if step == 2
			then string.format(lesson.body, basePower, enhancedPower, Enhancement.successPercent(1), cost.gold, cost.gems)
			elseif step == 3 then string.format(lesson.body, cost.gold, cost.gems)
			elseif step == 4 then string.format(lesson.body, enhancedPower)
			else lesson.body
		scroll.CanvasPosition = Vector2.zero
	end
	action.Activated:Connect(function()
		if not content.Visible or not parent.Visible then return end
		if step == #Text.EnhancementPracticeSteps then
			onFinish()
		else
			step += 1
			render()
		end
	end)
	return {frame = content, reset = function() step = 1; render() end}
end

return Practice
