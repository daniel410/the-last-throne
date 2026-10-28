-- Deepwood training HUD. Values are supplied by the local character's replicated state.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local Config = require(ReplicatedStorage.Shared.K0Config)

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
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = COLORS.panel
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0
	frame.Parent = parent
	round(frame, 10)
	outline(frame, COLORS.gold, 1.5)
	return frame
end

local function bar(parent, title, top, color)
	local titleLabel = text(parent, title .. "Label", title, UDim2.fromOffset(14, top), UDim2.fromOffset(105, 16), 11, COLORS.muted)
	titleLabel.TextSize = 10
	local value = text(parent, title .. "Value", "--", UDim2.new(1, -119, 0, top), UDim2.fromOffset(105, 16), 11)
	value.TextXAlignment = Enum.TextXAlignment.Right
	local track = Instance.new("Frame")
	track.Name = title .. "Track"
	track.Position = UDim2.new(0, 14, 0, top + 19)
	track.Size = UDim2.new(1, -28, 0, 10)
	track.BackgroundColor3 = COLORS.ink
	track.BorderSizePixel = 0
	track.ClipsDescendants = true
	track.Parent = parent
	round(track, 5)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = track
	round(fill, 5)
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
	circle.CornerRadius = UDim.new(1, 0)
	circle.Parent = button
	outline(button, COLORS.gold, 2)
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
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local root = Instance.new("Frame")
	root.Name = "Root"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui

	local status = panel(root, "Status", UDim2.fromOffset(16, 16), UDim2.fromOffset(248, 132))
	local statusScale = Instance.new("UIScale")
	statusScale.Parent = status
	local classLabel = text(status, "Class", "", UDim2.fromOffset(14, 8), UDim2.fromOffset(120, 20), 11, COLORS.gold)
	classLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local state = text(status, "State", Text.State.Idle, UDim2.new(1, -109, 0, 8), UDim2.fromOffset(95, 20), 10, COLORS.muted)
	state.TextXAlignment = Enum.TextXAlignment.Right
	local setHealth = bar(status, Text.Health, 32, COLORS.red)
	local setMana = bar(status, Text.Mana, 77, Color3.fromRGB(75, 151, 235))

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
	local block, blockHint = action(actions, "Block", Text.Block, Text.HintHold, UDim2.fromOffset(72, 0), 68)
	local skillButtons, skillHints = {}, {}
	for index, hint in ipairs({ Text.HintQ, Text.HintE, Text.HintR }) do
		local button, key = action(actions, "Skill" .. index, "", hint, UDim2.fromOffset(-125 + (index - 1) * 64, -72), 58)
		button.Caption.TextSize = 9
		button.Caption.TextWrapped = true
		skillButtons[index], skillHints[index] = button, key
	end
	local dodge, dodgeHint = action(actions, "Dodge", Text.Dodge, Text.HintV, UDim2.fromOffset(0, 91), 68)
	local attack, attackHint = action(actions, "Attack", Text.Attack, Text.HintClick, UDim2.fromOffset(134, 71), 88)
	local back = Instance.new("TextButton")
	back.Name = "BackToLobby"
	back.AnchorPoint = Vector2.new(1, 0)
	back.Position = UDim2.new(1, -16, 0, 16)
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
	outline(back, COLORS.gold, 1)
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
		local viewport = camera.ViewportSize
		local scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 550), 0.72, 1)
		statusScale.Scale = scale
		headingScale.Scale = scale
		actionScale.Scale = scale
		practiceScale.Scale = scale
		backScale.Scale = scale
		back.Size = UDim2.fromOffset(viewport.X < 500 and 126 or 168, 42)
		back.TextSize = viewport.X < 500 and 10 or 12
		practice.Position = UDim2.fromOffset(16, 16 + status.Size.Y.Offset * scale + 12)
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
	bindCamera()

	return {
		attack = attack,
		block = block,
		skills = skillButtons,
		dodge = dodge,
		back = back,
		setVisible = function(visible)
			gui.Enabled = visible
		end,
		setClass = function(classId)
			classLabel.Text = Text.Class[classId] or ""
			block.Visible = classId == "knight"
			local classSkills = Config.Skills[classId]
			local showMana = false
			for _, ability in ipairs(classSkills or {}) do
				if ability.magic then showMana = true; break end
			end
			status.Size = UDim2.fromOffset(248, showMana and 132 or 87)
			for _, suffix in ipairs({ "Label", "Value", "Track" }) do status[Text.Mana .. suffix].Visible = showMana end
			for index, button in ipairs(skillButtons) do
				button.Visible = classSkills ~= nil
				button.Caption.Text = classSkills and classSkills[index].name or ""
			end
			updateScale()
		end,
		setPractice = function(value, classId)
			value = value or {}
			objective.Text = not value.moved and Text.Practice.Move
				or not value.attacked and (classId == "elf" and Text.Practice.ElfAttack or Text.Practice.Attack)
				or not value.dodged and Text.Practice.Dodge or Text.Practice.Complete
		end,
		setHealth = setHealth,
		setMana = setMana,
		setCooldowns = function(character)
			for index, button in ipairs(skillButtons) do
				local ready = character and character:GetAttribute("K0SkillReady" .. index) or 0
				local remaining = math.max(0, (ready or 0) - Workspace:GetServerTimeNow())
				button.BackgroundTransparency = remaining > 0 and 0.45 or 0
				local label = button:FindFirstChild("Cooldown")
				if not label then
					label = text(button, "Cooldown", "", UDim2.fromOffset(0, -14), UDim2.new(1, 0, 0, 18), 12, COLORS.cream)
					label.TextXAlignment = Enum.TextXAlignment.Center
				end
				label.Text = remaining > 0 and string.format("%.1fs", remaining) or ""
			end
		end,
		setState = function(value)
			state.Text = value
		end,
		setHints = function(attackText, blockText, dodgeText, skillText, skill2Text, skill3Text)
			attackHint.Text, blockHint.Text, dodgeHint.Text = attackText, blockText, dodgeText
			skillHints[1].Text = skillText or Text.HintQ
			skillHints[2].Text = skill2Text or Text.HintE
			skillHints[3].Text = skill3Text or Text.HintR
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
