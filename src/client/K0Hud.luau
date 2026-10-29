-- Deepwood training HUD. Values are supplied by the local character's replicated state.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local Config = require(ReplicatedStorage.Shared.K0Config)

local Theme = require(script.Parent.TDInventoryTheme)
local BattleArt = require(ReplicatedStorage.Shared.TDUI.BattleChromeArtAssets)
local Catalog = require(ReplicatedStorage.Shared.ItemCatalog)
local PotionIcon = require(script.Parent.PotionIcon)
local Hud = {}

local COLORS = {
	ink = Color3.fromRGB(12, 24, 43),
	panel = Color3.fromRGB(20, 33, 53),
	gold = Color3.fromRGB(226, 190, 116),
	cream = Color3.fromRGB(255, 246, 220),
	muted = Color3.fromRGB(180, 194, 205),
	red = Color3.fromRGB(198, 66, 65),
	green = Color3.fromRGB(97, 174, 104),
	blue = Color3.fromRGB(48, 91, 137),
}

local function round(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function outline(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

local function text(parent, name, value, position, size, fontSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = size
	label.Font = Enum.Font.GothamBold
	label.Text = value
	label.TextColor3 = color or COLORS.cream
	label.TextSize = fontSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function panel(parent, name, position, size)
	return Theme.frame(parent, name, position, size)
end

local function bar(parent, title, top, color)
	local titleLabel = text(parent, title .. "Label", title, UDim2.fromOffset(14, top), UDim2.fromOffset(105, 16), 11, COLORS.muted)
	titleLabel.TextSize = 10
	local value = text(parent, title .. "Value", "--", UDim2.new(1, -119, 0, top), UDim2.fromOffset(105, 16), 11)
	value.TextXAlignment = Enum.TextXAlignment.Right
	local track = Instance.new("Frame")
	track.Name = title .. "Track"
	track.Position = UDim2.new(0, 14, 0, top + 19)
	track.Size = UDim2.new(1, -28, 0, 18)
	track.BackgroundColor3 = COLORS.ink
	track.BorderSizePixel = 0
	track.ClipsDescendants = false
	track.Parent = parent
	round(track, 5)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = track
	round(fill, 5)
	-- TD's authored red fill stays red; MP uses a blue native fill with the same silver frame.
	if title == Text.Health then
		Theme.sprite(fill, "TDFill", "healthFill", UDim2.new(), UDim2.fromScale(1, 1), BattleArt)
	end
	Theme.sprite(track, "TDResourceFrame", "healthFrame", UDim2.fromOffset(-4, -5), UDim2.new(1, 8, 1, 10), BattleArt)
	return function(current, maximum)
		if typeof(current) ~= "number" or typeof(maximum) ~= "number" or maximum <= 0 then
			value.Text = "--"
			fill.Size = UDim2.fromScale(0, 1)
			return
		end
		current = math.clamp(current, 0, maximum)
		value.Text = string.format("%d / %d", math.floor(current + 0.5), math.floor(maximum + 0.5))
		fill.Size = UDim2.fromScale(current / maximum, 1)
	end
end

local function action(parent, name, caption, hint, position, diameter)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = UDim2.fromOffset(diameter, diameter)
	button.BackgroundColor3 = COLORS.blue
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Text = ""
	button.Selectable = false
	button.Parent = parent
	local circle = Instance.new("UICorner")
	circle.CornerRadius = UDim.new(0, 10)
	circle.Parent = button
	local art = Theme.sprite(button, "TDButtonArt", name == "Attack" and "shellUpgrade" or string.sub(name, 1, 4) == "Item" and "shellSell" or "shellDetails", UDim2.new(), UDim2.fromScale(1, 1))
	art.SliceScale = 0.26
	button.AutoButtonColor = false
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			art.ImageColor3 = Color3.fromRGB(175, 200, 230)
		end
	end)
	button.InputEnded:Connect(function() art.ImageColor3 = Color3.new(1, 1, 1) end)
	local title = text(button, "Caption", caption, UDim2.new(0, 4, 0.5, -15), UDim2.new(1, -8, 0, 20), 12)
	title.TextXAlignment = Enum.TextXAlignment.Center
	local key = text(button, "Hint", hint, UDim2.new(0, 4, 0.5, 5), UDim2.new(1, -8, 0, 16), 10, COLORS.muted)
	key.TextXAlignment = Enum.TextXAlignment.Center
	return button, key
end

function Hud.create()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("DeepwoodTrainingHud")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "DeepwoodTrainingHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui

	local status = panel(root, "Status", UDim2.fromOffset(16, 16), UDim2.fromOffset(248, 87))
	local statusScale = Instance.new("UIScale")
	statusScale.Parent = status
	local classLabel = text(status, "Class", "", UDim2.fromOffset(14, 8), UDim2.fromOffset(120, 20), 11, COLORS.gold)
	classLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local state = text(status, "State", Text.State.Idle, UDim2.new(1, -109, 0, 8), UDim2.fromOffset(95, 20), 10, COLORS.muted)
	state.TextXAlignment = Enum.TextXAlignment.Right
	local xpLabel=text(status,"XP","",UDim2.fromOffset(14,72),UDim2.new(1,-28,0,12),9,COLORS.gold)
	local setHealth = bar(status, Text.Health, 32, COLORS.red)
	local setManaValue = bar(status, Text.Mana, 77, Color3.fromRGB(75, 151, 235))
	for _, suffix in ipairs({ "Label", "Value", "Track" }) do
		status[Text.Mana .. suffix].Visible = false
	end

	local heading = panel(root, "Heading", UDim2.new(0.5, -108, 0, 16), UDim2.fromOffset(216, 55))
	local headingScale = Instance.new("UIScale")
	headingScale.Parent = heading
	local headingTitle = text(heading, "Title", Text.Title, UDim2.fromOffset(8, 6), UDim2.new(1, -16, 0, 20), 15, COLORS.gold)
	headingTitle.TextXAlignment = Enum.TextXAlignment.Center
	local subtitle = text(heading, "Subtitle", Text.Subtitle, UDim2.fromOffset(8, 28), UDim2.new(1, -16, 0, 16), 10, COLORS.muted)
	subtitle.TextXAlignment = Enum.TextXAlignment.Center

	local feedback = text(root, "Feedback", "", UDim2.new(0.5, 0, 0.55, 0), UDim2.new(0.8, 0, 0, 52), 16, COLORS.cream)
	feedback.AnchorPoint = Vector2.new(0.5, 0.5)
	feedback.TextXAlignment = Enum.TextXAlignment.Center
	feedback.TextWrapped = true
	feedback.TextStrokeTransparency = 0.3
	feedback.Visible = false
	local feedbackSequence = 0

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.BackgroundTransparency = 1
	actions.AnchorPoint = Vector2.new(1, 1)
	-- Preserve space for Roblox's default mobile jump control.
	actions.Position = UDim2.new(1, UserInputService.TouchEnabled and -100 or -20, 1, -22)
	actions.Size = UDim2.fromOffset(226, 163)
	actions.Parent = root
	local actionScale = Instance.new("UIScale")
	actionScale.Parent = actions
	local block, blockHint = action(actions, "Block", Text.Block, Text.HintHold, UDim2.fromOffset(6, 6), 56)
	local skillBar = Instance.new("Frame")
	skillBar.Name = "SkillBar"
	skillBar.BackgroundTransparency = 1
	skillBar.AnchorPoint = Vector2.new(0.5, 1)
	skillBar.Position = UDim2.new(0.5, 0, 1, -24)
	skillBar.Size = UDim2.fromOffset(528, 68)
	skillBar.Parent = root
	local skillScale = Instance.new("UIScale")
	skillScale.Parent = skillBar
	local itemButtons = {}
	for index, item in ipairs({ {"HP", "Z"}, {"MP", "C"} }) do
		local button = action(skillBar, "Item" .. index, item[1], item[2], UDim2.fromOffset((index - 1) * 72, 0), 64)
		button.UICorner.CornerRadius = UDim.new(0, 8)
		button.Caption.Position, button.Caption.Size = UDim2.fromOffset(2, 47), UDim2.new(1, -4, 0, 14)
		button.Caption.TextSize = 9
		button.Hint.Position, button.Hint.Size = UDim2.fromOffset(4, 2), UDim2.fromOffset(16, 14)
		local count = text(button, "ItemCount", "x0", UDim2.new(1, -32, 0, 2), UDim2.fromOffset(28, 14), 11)
		count.TextXAlignment, count.TextStrokeTransparency = Enum.TextXAlignment.Right, .3
		itemButtons[index] = button
	end
	local skillButtons, skillHints = {}, {}
	for index = 1, 5 do
		local button, key = action(skillBar, "Skill" .. index, "", tostring(index), UDim2.fromOffset((index + 1) * 72 + 24, 0), 64)
		button.UICorner.CornerRadius = UDim.new(0, 8)
		button.Caption.TextSize = 8
		button.Caption.Position = UDim2.fromOffset(3, 36)
		button.Caption.Size = UDim2.new(1, -6, 0, 25)
		button.Caption.TextWrapped = true
		key.Position = UDim2.fromOffset(4, 2)
		key.Size = UDim2.fromOffset(19, 16)
		local icon = text(button, "Icon", "", UDim2.new(0.5, -15, 0, 5), UDim2.fromOffset(30, 28), 17, COLORS.gold)
		icon.TextXAlignment = Enum.TextXAlignment.Center
		skillButtons[index], skillHints[index] = button, key
	end
	local sprint, sprintHint = action(actions, "Sprint", Text.Sprint, "E", UDim2.fromOffset(92, 6), 56)
	local dodge, dodgeHint = action(actions, "Dodge", Text.Dodge, Text.HintR, UDim2.fromOffset(0, 91), 68)
	local attack, attackHint = action(actions, "Attack", Text.Attack, Text.HintClick, UDim2.fromOffset(76, 71), 88)
	local back = Instance.new("TextButton")
	back.Name = "BackToLobby"
	back.AnchorPoint = Vector2.new(1, 0)
	back.Position = UDim2.new(1, -16, 0, 68)
	back.Size = UDim2.fromOffset(168, 42)
	back.BackgroundColor3 = COLORS.blue
	back.BorderSizePixel = 0
	back.Font = Enum.Font.GothamBold
	back.TextSize = 12
	back.TextColor3 = COLORS.cream
	back.Text = Text.BackToLobby
	back.Selectable = true
	back.Parent = root
	local backScale = Instance.new("UIScale")
	backScale.Parent = back
	round(back, 8)
	Theme.sprite(back, "TDButtonArt", "shellDetails", UDim2.new(), UDim2.fromScale(1, 1)).SliceScale = .3
	back.Text = ""
	local backCaption = text(back, "Caption", Text.BackToLobby, UDim2.fromOffset(10, 0), UDim2.new(1, -20, 1, 0), 12)
	backCaption.TextXAlignment = Enum.TextXAlignment.Center
	local practice = panel(root, "Practice", UDim2.fromOffset(16, 162), UDim2.fromOffset(344, 112))
	local practiceScale = Instance.new("UIScale")
	practiceScale.Parent = practice
	text(practice, "Title", Text.PracticeTitle, UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 18), 11, COLORS.gold)
	local objective = text(practice, "Objective", Text.Practice.Move, UDim2.fromOffset(12, 30), UDim2.new(1, -24, 0, 42), 12)
	objective.TextWrapped = true
	local note = text(practice, "Note", Text.Practice.Note, UDim2.fromOffset(12, 76), UDim2.new(1, -24, 0, 28), 10, COLORS.muted)
	note.TextWrapped = true

	local function updateScale()
		local camera = Workspace.CurrentCamera
		if not camera then return end
		local viewport = root.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then viewport = camera.ViewportSize end
		local scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 550), 0.72, 1)
		statusScale.Scale = scale
		headingScale.Scale = scale
		actionScale.Scale = scale
		skillScale.Scale = math.min(scale, viewport.X / 560)
		practiceScale.Scale = scale
		backScale.Scale = scale
		back.Size = UDim2.fromOffset(viewport.X < 500 and 126 or 168, 42)
		backCaption.TextSize = viewport.X < 500 and 10 or 12
		-- Below 1100px, reserve a separate row above held-action controls.
		skillBar.Position = UDim2.new(.5, 0, 1, viewport.X < 1100 and -(190 * scale + 24) or -24)
		if viewport.X >= 1100 then skillBar.Position = UDim2.new(.5, -55, 1, -24) end
		practice.Size = UDim2.fromOffset(viewport.X < 600 and 248 or 344, 112)
		practice.Position = UDim2.fromOffset(16, 16 + status.Size.Y.Offset * scale + 12)
		if viewport.Y < 450 and viewport.X >= 600 then
			practice.Position = UDim2.fromOffset(28 + 248 * scale, 16)
			local available = viewport.X - (28 + 248 * scale) - back.Size.X.Offset * scale - 28
			practice.Size = UDim2.fromOffset(math.min(344, available / scale), 112)
		end
		-- On narrow screens, keep the title clear of the status panel.
		heading.Visible = viewport.X >= 860
	end
	local cameraConnection
	local function bindCamera()
		if cameraConnection then cameraConnection:Disconnect() end
		local camera = Workspace.CurrentCamera
		if camera then cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
		updateScale()
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
	root:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
	bindCamera()

	return {
		attack = attack,
		block = block,
		sprint = sprint,
		skills = skillButtons,
		items = itemButtons,
		dodge = dodge,
		back = back,
		setVisible = function(visible)
			gui.Enabled = visible
		end,
		setClass = function(classId)
			classLabel.Text = Text.Class[classId] or ""
		end,
		setPractice = function(value, classId)
			value = value or {}
			objective.Text = not value.moved and Text.Practice.Move
				or not value.attacked and (classId == "elf" and Text.Practice.ElfAttack or Text.Practice.Attack)
				or not value.dodged and Text.Practice.Dodge or Text.Practice.Complete
		end,
		setHealth = setHealth,
		setMana = function(current, maximum)
			local showMana = typeof(maximum) == "number" and maximum > 0
			setManaValue(current, maximum)
			status.Size = UDim2.fromOffset(248, showMana and 132 or 87)
			for _, suffix in ipairs({ "Label", "Value", "Track" }) do
				status[Text.Mana .. suffix].Visible = showMana
			end
			updateScale()
		end,
		setCooldowns = function(character)
			if character then
				classLabel.Text=(Text.Class[character:GetAttribute("K0ClassId")] or "").." · LV "..tostring(character:GetAttribute("K0Level") or 1)
				xpLabel.Position=UDim2.fromOffset(14,character:GetAttribute("K0MaxMana") and 117 or 72)
				xpLabel.Text=string.format("XP %d / %d",character:GetAttribute("K0XP") or 0,character:GetAttribute("K0XPToNext") or 100)
			end
			for index, button in ipairs(itemButtons) do
				local count = character and character:GetAttribute("K0ItemCount" .. index) or 0
				local definitionId = character and character:GetAttribute("K0ItemDefinition" .. index)
				local definition = Catalog.items[definitionId or (index == 1 and "health_potion" or "mana_potion")]
				if definition and definition.potionTier then
					if button:GetAttribute("DefinitionId") ~= definition.id then
						local old = button:FindFirstChild("PotionIcon"); if old then old:Destroy() end
						PotionIcon.create(button, definition, UDim2.fromOffset(14, 7), UDim2.fromOffset(36, 39))
						button:SetAttribute("DefinitionId", definition.id)
					end
					button.Caption.Text = definition.potionSize .. " " .. definition.glyph
					button.Caption.TextColor3 = definition.restore == "health" and Color3.fromRGB(255, 210, 195) or Color3.fromRGB(181, 235, 255)
				end
				button.ItemCount.Text = "x" .. tostring(count)
				button.TDButtonArt.ImageTransparency = count > 0 and 0 or .45
				button.ItemCount.TextColor3 = count > 0 and COLORS.cream or COLORS.muted
			end
			for index, button in ipairs(skillButtons) do
				local classId = character and character:GetAttribute("K0ClassId")
				local equipped = character and character:GetAttribute("K0EquippedSkill" .. index)
				local count = character and character:GetAttribute("K0SkillSlotCount") or 3
				local ability
				for _, candidate in ipairs(Config.Skills[classId] or {}) do if candidate.id == equipped then ability = candidate; break end end
				button.Caption.Text = index > count and "LOCKED" or ability and ability.name or "EMPTY"
				button.Icon.Text = ability and (ability.glyph or string.sub(ability.name,1,2)) or ""
				button.Active = index <= count and ability ~= nil
				local ready = character and character:GetAttribute("K0SkillReady" .. index) or 0
				local remaining = math.max(0, (ready or 0) - Workspace:GetServerTimeNow())
				button.BackgroundTransparency = remaining > 0 and 0.45 or 0
				button.TDButtonArt.ImageTransparency = index > count and .6 or remaining > 0 and .35 or 0
				button.Icon.Visible = remaining <= 0
				local label = button:FindFirstChild("Cooldown")
				if not label then
					label = text(button, "Cooldown", "", UDim2.fromOffset(24, 5), UDim2.new(1, -26, 0, 27), 12, COLORS.cream)
					label.TextXAlignment = Enum.TextXAlignment.Center
					label.TextStrokeTransparency = 0.3
				end
				label.Visible = remaining > 0
				label.Text = remaining > 0 and string.format("%.1fs", remaining) or ""
			end
		end,
		setState = function(value)
			state.Text = value
		end,
		setHints = function(attackText, blockText, dodgeText, sprintText, keys)
			attackHint.Text, blockHint.Text, dodgeHint.Text = attackText, blockText, dodgeText
			sprintHint.Text = sprintText or "E"
			for index, hint in ipairs(skillHints) do hint.Text = keys and keys[index] or tostring(index) end
		end,
		showFeedback = function(value, duration)
			feedbackSequence += 1
			local sequence = feedbackSequence
			feedback.Text = value
			feedback.Visible = true
			task.delay(duration or 1.2, function()
				if feedbackSequence == sequence and feedback.Parent then feedback.Visible = false end
			end)
		end,
		clearFeedback = function()
			feedbackSequence += 1
			feedback.Visible = false
		end,
	}
end

return Hud
