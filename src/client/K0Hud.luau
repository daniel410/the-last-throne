-- Deepwood training HUD. Values are supplied by the local character's replicated state.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local Config = require(ReplicatedStorage.Shared.K0Config)
local Growth = require(ReplicatedStorage.Shared.HeroProgression)

local Theme = require(script.Parent.TDInventoryTheme)
local BattleArt = require(ReplicatedStorage.Shared.TDUI.BattleChromeArtAssets)
local Catalog = require(ReplicatedStorage.Shared.ItemCatalog)
local PotionIcon = require(script.Parent.PotionIcon)
local SkillIcon = require(script.Parent.SkillIcon)
local MiniMap=require(script.Parent.BattleMinimap)
local StoryHeading=require(script.Parent.StoryHeading)
local TrainingTutorial = require(ReplicatedStorage.Shared.TrainingTutorial)
local Hud = {}
local SLOT_ICON_POSITION = UDim2.fromOffset(12, 22)
local SLOT_ICON_SIZE = UDim2.fromOffset(40, 40)
local SLOT_HEIGHT = 94
local TALL_SLOT_HEIGHT = 118
local ULTIMATE_TOP = -SLOT_HEIGHT - 8
local SLOT_ROW_WIDTH = 528
local COMPACT_ROW_WIDTH = 472

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
	label.TextSize = fontSize <= 11 and fontSize + 1 or fontSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.AutoLocalize = false
	label.Parent = parent
	return label
end

local function panel(parent, name, position, size)
	return Theme.frame(parent, name, position, size)
end

local function bar(parent, title, top, color)
	local titleLabel = text(parent, title .. "Label", title, UDim2.fromOffset(14, top), UDim2.fromOffset(105, 16), 11, COLORS.muted)
	titleLabel.TextSize = 11
	local value = text(parent, title .. "Value", "--", UDim2.new(1, -119, 0, top), UDim2.fromOffset(105, 16), 11)
	value.TextXAlignment = Enum.TextXAlignment.Right
	Theme.fitText(value)
	local track = Instance.new("Frame")
	track.Name = title .. "Track"
	track.Position = UDim2.new(0, 14, 0, top + 19)
	track.Size = UDim2.new(1, -28, 0, 28)
	track.BackgroundTransparency = 1
	track.BorderSizePixel = 0
	track.ClipsDescendants = false
	track.Parent = parent
	local window=Instance.new("Frame")
	window.Name,window.Position,window.Size="FillWindow",UDim2.fromOffset(14,8),UDim2.new(1,-28,1,-16)
	window.BackgroundColor3,window.BorderSizePixel,window.ClipsDescendants=COLORS.ink,0,true
	window.Parent=track
	round(window,3)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = window
	round(fill, 5)
	-- The TD resource frame surrounds both the original HP art and the native MP fill.
	if title == Text.Health then
		local art=Theme.sprite(fill, "TDFill", "healthFill", UDim2.new(), UDim2.fromScale(1, 1), BattleArt)
		art.SliceScale=.15
	else
		fill.BackgroundColor3=Color3.new(1,1,1)
		local sheen=Instance.new("UIGradient")
		sheen.Name,sheen.Rotation="ManaSheen",90
		sheen.Color=ColorSequence.new({
			ColorSequenceKeypoint.new(0,Color3.fromRGB(139,249,255)),
			ColorSequenceKeypoint.new(.38,color),
			ColorSequenceKeypoint.new(1,Color3.fromRGB(21,115,217)),
		})
		sheen.Parent=fill
	end
	local resourceFrame=Theme.sprite(track, "TDResourceFrame", "healthFrame", UDim2.new(), UDim2.fromScale(1,1), BattleArt)
	resourceFrame.SliceScale=.18
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
	local title = text(button, "Caption", caption, UDim2.new(0, 7, 0.5, -17), UDim2.new(1, -14, 0, 17), 12)
	title.TextXAlignment = Enum.TextXAlignment.Center
	local key = text(button, "Hint", hint, UDim2.new(0, 7, 0.5, 1), UDim2.new(1, -14, 0, 16), 10, COLORS.muted)
	key.TextXAlignment = Enum.TextXAlignment.Center
	Theme.fitText(title)
	Theme.fitText(key)
	return button, key
end

local function quickKey(label)
	label.Position=UDim2.fromOffset(5,5);label.Size=UDim2.fromOffset(20,16)
	label.BackgroundColor3=Color3.fromRGB(11,18,29);label.BackgroundTransparency=.12
	label.Font=Enum.Font.GothamBold;label.TextColor3=Color3.new(1,1,1)
	label.TextSize=12;label.TextXAlignment=Enum.TextXAlignment.Center
	label.TextStrokeColor3=Color3.new(0,0,0);label.TextStrokeTransparency=.1;label.ZIndex=5
	round(label,4)
end

local function slotCaption(label)
	local top = SLOT_ICON_POSITION.Y.Offset + SLOT_ICON_SIZE.Y.Offset + 2
	label.Position=UDim2.fromOffset(5,top)
	label.Size=UDim2.new(1,-10,1,-top-6)
	label.TextSize=12
	label.TextWrapped=true
	label.TextStrokeColor3=COLORS.ink
	label.TextStrokeTransparency=.2
end

function Hud.create()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("DeepwoodTrainingHud")
	if old then old:Destroy() end
	local oldTop=playerGui:FindFirstChild("DeepwoodTopHud");if oldTop then oldTop:Destroy() end
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
 require(script.Parent.StoryRegionNotice).create(root,Players.LocalPlayer)
 require(script.Parent.DeathPenaltyNotice).create(root,Players.LocalPlayer)

	local topGui=Instance.new("ScreenGui")
	topGui.Name,topGui.ResetOnSpawn,topGui.DisplayOrder="DeepwoodTopHud",false,1
	topGui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets;topGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;topGui.Parent=playerGui
	local topRoot=Instance.new("Frame");topRoot.Name="Root";topRoot.BackgroundTransparency=1;topRoot.Size=UDim2.fromScale(1,1);topRoot.Parent=topGui
	local status = panel(root, "Status", UDim2.fromOffset(16, 16), UDim2.fromOffset(248, 100))
	local statusScale = Instance.new("UIScale")
	statusScale.Parent = status
	local classLabel = text(status, "Class", "", UDim2.fromOffset(14, 5), UDim2.fromOffset(120, 12), 10, COLORS.gold)
	classLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local state = text(status, "State", Text.State.Idle, UDim2.new(1, -109, 0, 5), UDim2.fromOffset(95, 12), 10, COLORS.muted)
	state.TextXAlignment = Enum.TextXAlignment.Right
	local xpLabel=text(status,"XP","",UDim2.fromOffset(14,19),UDim2.new(1,-28,0,12),10,COLORS.gold)
	Theme.fitText(xpLabel)
	local growthPoints=Instance.new("TextButton");growthPoints.Name="GrowthPoints";growthPoints.BackgroundTransparency=1;growthPoints.Size=UDim2.new(1,0,0,26);growthPoints.Position=UDim2.new(0,0,1,3);growthPoints.TextColor3=COLORS.gold;growthPoints.Font=Enum.Font.GothamBold;growthPoints.TextSize=11;growthPoints.TextStrokeTransparency=.2;growthPoints.AutoLocalize=false;growthPoints.Visible=false;growthPoints.Parent=status
	Theme.fitText(growthPoints)
 local setHealth = bar(status, Text.Health, 32, COLORS.red)
	local setManaValue = bar(status, Text.Mana, 77, Theme.color.mana)
	for _, suffix in ipairs({ "Label", "Value", "Track" }) do
		status[Text.Mana .. suffix].Visible = false
	end

	local heading = panel(topRoot, "Heading", UDim2.new(0.5, -108, 0, 4), UDim2.fromOffset(216, 55))
	heading.BackgroundTransparency=1
	local headingArt=heading:FindFirstChild("TDPanelArt");if headingArt then headingArt:Destroy() end
	local headingOutline=heading:FindFirstChildOfClass("UIStroke");if headingOutline then headingOutline.Transparency=1 end
	local headingScale = Instance.new("UIScale")
	headingScale.Parent = heading
	local headingTitle = text(heading, "Title", Text.Title, UDim2.fromOffset(8, 5), UDim2.new(1, -16, 0, 24), 17, COLORS.gold)
	headingTitle.TextXAlignment = Enum.TextXAlignment.Center
	Theme.fitText(headingTitle)
	headingTitle.TextStrokeTransparency=.25;headingTitle.TextStrokeColor3=Color3.new(0,0,0)
	local subtitle = text(heading, "Subtitle", Text.Subtitle, UDim2.fromOffset(8, 30), UDim2.new(1, -16, 0, 16), 10, COLORS.muted)
	subtitle.TextXAlignment = Enum.TextXAlignment.Center
	Theme.fitText(subtitle)
	subtitle.TextStrokeTransparency=.35;subtitle.TextStrokeColor3=Color3.new(0,0,0)

	local feedback = text(root, "Feedback", "", UDim2.new(0.5, 0, 0.55, 0), UDim2.new(0.8, 0, 0, 52), 20, COLORS.cream)
	feedback.AnchorPoint = Vector2.new(0.5, 0.5)
	feedback.TextXAlignment = Enum.TextXAlignment.Center
	feedback.TextWrapped = true
	feedback.Font=Enum.Font.GothamBlack;feedback.TextColor3=Color3.new(1,1,1)
	feedback.TextStrokeColor3=Color3.new(0,0,0);feedback.TextStrokeTransparency=0.1
	feedback.BackgroundColor3=COLORS.ink;feedback.BackgroundTransparency=.6
	Theme.fitText(feedback)
	local feedbackLimit=Instance.new('UISizeConstraint');feedbackLimit.MaxSize=Vector2.new(620,52);feedbackLimit.Parent=feedback
	round(feedback,6)
	feedback.Visible = false
	local feedbackSequence = 0

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.BackgroundTransparency = 1
	actions.AnchorPoint = Vector2.new(1, 1)
	-- Preserve space for Roblox's default mobile jump control.
	actions.Position = UDim2.new(1, -20, 1, 0)
	actions.Size = UDim2.fromOffset(172, 188)
	actions.Parent = root
	local actionScale = Instance.new("UIScale")
	actionScale.Parent = actions
	local block, blockHint = action(actions, "Block", Text.Block, Text.HintHold, UDim2.fromOffset(8, 66), 56)
	local skillBar = Instance.new("Frame")
	skillBar.Name = "SkillBar"
	skillBar.BackgroundTransparency = 1
	skillBar.AnchorPoint = Vector2.new(0.5, 1)
	skillBar.Position = UDim2.new(0.5, 0, 1, -24)
	skillBar.Size = UDim2.fromOffset(SLOT_ROW_WIDTH, SLOT_HEIGHT)
	skillBar.Parent = root
	local skillScale = Instance.new("UIScale")
	skillScale.Parent = skillBar
	local itemButtons = {}
	for index, item in ipairs({ {"HP", "Z"}, {"MP", "C"} }) do
		local button = action(skillBar, "Item" .. index, item[1], item[2], UDim2.fromOffset((index - 1) * 72, 0), 64)
		button.Size = UDim2.fromOffset(64, SLOT_HEIGHT)
		button.UICorner.CornerRadius = UDim.new(0, 8)
		slotCaption(button.Caption)
		quickKey(button.Hint)
		local count = text(button, "ItemCount", "x0", UDim2.new(1, -34, 0, 5), UDim2.fromOffset(29, 16), 11)
		count.TextXAlignment, count.TextStrokeTransparency = Enum.TextXAlignment.Right, .3
		Theme.fitText(count)
		itemButtons[index] = button
	end
	local skillButtons, skillHints = {}, {}
	for index = 1, 5 do
		local button, key = action(skillBar, "Skill" .. index, "", tostring(index), UDim2.fromOffset((index + 1) * 72 + 24, 0), 64)
		button.Size = UDim2.fromOffset(64, SLOT_HEIGHT)
		button.UICorner.CornerRadius = UDim.new(0, 8)
		slotCaption(button.Caption)
		quickKey(key)
		SkillIcon.create(button, SLOT_ICON_POSITION, SLOT_ICON_SIZE)
		local cooldown = text(button, "Cooldown", "", UDim2.new(1, -31, 0, 5), UDim2.fromOffset(26, 16), 11)
		cooldown.TextXAlignment = Enum.TextXAlignment.Right
		cooldown.TextStrokeTransparency = .2
		cooldown.Visible = false
		Theme.fitText(cooldown)
		skillButtons[index], skillHints[index] = button, key
	end
	local sprint, sprintHint = action(actions, "Sprint", Text.Sprint, "E", UDim2.fromOffset(8, 0), 56)
	local dodge, dodgeHint = action(actions, "Dodge", Text.Dodge, Text.HintR, UDim2.fromOffset(8, 132), 56)
	local attack, attackHint = action(actions, "Attack", Text.Attack, Text.HintClick, UDim2.fromOffset(90, 0), 64)
	local ultimate,ultimateHint=action(actions,'Ultimate',Text.Ultimate,require(game.ReplicatedStorage.Shared.NavigationText).ultimateKey,UDim2.fromOffset(90,ULTIMATE_TOP),64)
	ultimate.Size=UDim2.fromOffset(64,SLOT_HEIGHT)
	SkillIcon.create(ultimate,SLOT_ICON_POSITION,SLOT_ICON_SIZE)
	slotCaption(ultimate.Caption)
	quickKey(ultimateHint)
	ultimate.Visible=false
	local minimap=MiniMap.create(topRoot)
	local mapScale=Instance.new("UIScale");mapScale.Parent=minimap.frame
	local back = Instance.new("TextButton")
	back.Name = "BackToLobby"
	back.AnchorPoint = Vector2.zero
	back.Position = UDim2.fromOffset(10,190)
	back.Size = UDim2.fromOffset(148, 40)
	back.BackgroundColor3 = COLORS.blue
	back.BorderSizePixel = 0
	back.Font = Enum.Font.GothamBold
	back.TextSize = 12
	back.TextColor3 = COLORS.cream
	back.Text = Text.BackToLobby
	back.Selectable = true
	back.Parent = minimap.menu
	local backScale = Instance.new("UIScale")
	backScale.Parent = back
	round(back, 8)
	Theme.sprite(back, "TDButtonArt", "shellDetails", UDim2.new(), UDim2.fromScale(1, 1)).SliceScale = .3
	back.Text = ""
	local backCaption = text(back, "Caption", Text.BackToLobby, UDim2.fromOffset(12, 6), UDim2.new(1, -24, 1, -12), 12)
	backCaption.TextXAlignment = Enum.TextXAlignment.Center
	Theme.fitText(backCaption)
	local storyTracker, practiceProgress
	local practiceInput = "keyboard"
	local practice = Instance.new("Frame")
 practice.Name = "Practice"
 practice.Position = UDim2.fromOffset(16, 162)
 practice.Size = UDim2.fromOffset(248, 120)
 practice.BackgroundTransparency = 1
 practice.BorderSizePixel = 0
 practice.Parent = root
 practice.Visible = false
 local coachArt = Theme.sprite(practice, "TrainingPanelArt", "panel", UDim2.new(), UDim2.fromScale(1, 1))
 coachArt.SliceScale = .3
 coachArt.Visible = false
	local practiceScale = Instance.new("UIScale")
	practiceScale.Parent = practice
	local practiceTitle = text(practice, "Title", Text.PracticeTitle, UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 20), 15, COLORS.gold)
	local objective = text(practice, "Objective", "", UDim2.fromOffset(12, 31), UDim2.new(1, -24, 0, 48), 16)
	objective.TextWrapped = true
	local note = text(practice, "Note", "", UDim2.fromOffset(12, 83), UDim2.new(1, -24, 0, 34), 13, COLORS.cream)
	note.TextWrapped = true
 for _,label in ipairs(practice:GetChildren()) do if label:IsA("TextLabel") then
  label.TextStrokeColor3 = Color3.new(0,0,0)
  label.TextStrokeTransparency = .3
  label.ZIndex = coachArt.ZIndex + 1
  Theme.fitText(label)
 end end

	local function renderTracker()
		local coaching = practiceProgress ~= nil
		practice.Visible = coaching or storyTracker ~= nil
		coachArt.Visible = coaching
		practice.Size = UDim2.fromOffset(status.Size.X.Offset, coaching and 100 or 120)
		objective.Size = UDim2.new(1, -24, 0, coaching and 24 or 48)
		note.Position = UDim2.fromOffset(12, coaching and 55 or 83)
		if practiceProgress then
			local key, index = TrainingTutorial.current(practiceProgress)
			local lesson = Text.Practice[key]
			practiceTitle.Text = string.format(Text.Practice.Progress, index, #TrainingTutorial.order, Text.PracticeTitle)
			objective.Text, note.Text = lesson.title, lesson[practiceInput] or lesson.keyboard
		elseif storyTracker then
			practiceTitle.Text, objective.Text, note.Text = storyTracker.title, storyTracker.objective, storyTracker.note
		end
	end

	local function updateScale()
		local camera = Workspace.CurrentCamera
		if not camera then return end
		local viewport = root.AbsoluteSize
		if viewport.X <= 0 or viewport.Y <= 0 then viewport = camera.ViewportSize end
		local scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 550), 0.72, 1)
		statusScale.Scale = scale
		headingScale.Scale = scale
		actionScale.Scale = UserInputService.TouchEnabled and math.max(.8,scale) or scale
		practiceScale.Scale = scale
		backScale.Scale = 1
		mapScale.Scale=viewport.X<500 and math.max(.62,scale*.85) or scale
		back.Size = UDim2.fromOffset(148,45)
		local compactRow = viewport.X < 780
		local rowWidth = compactRow and COMPACT_ROW_WIDTH or SLOT_ROW_WIDTH
		for i,button in ipairs(itemButtons) do button.Position=UDim2.fromOffset((i-1)*(compactRow and 68 or 72),0) end
		for i,button in ipairs(skillButtons) do
			button.Position=UDim2.fromOffset(compactRow and (i+1)*68 or (i+1)*72+24,0)
		end
		local touch = UserInputService.TouchEnabled
		local bottomInset = touch and 12 or 24
		if viewport.X < 548 and viewport.Y > viewport.X then
			-- Keep the full row above the thumb controls in portrait.
			skillScale.Scale=math.min(scale,(viewport.X-24)/rowWidth)
			skillBar.Position=UDim2.new(.5,0,1,-math.max(180,(actions.Size.Y.Offset-ULTIMATE_TOP)*actionScale.Scale+8))
		elseif compactRow then
			local left = touch and 76 or 12
			local right = viewport.X-30-164*actionScale.Scale
			skillScale.Scale=math.min(scale,math.max(1,right-left)/rowWidth)
			skillBar.Position=UDim2.new(0,(left+right)*.5,1,-bottomInset)
		else
			skillScale.Scale=math.min(scale,(viewport.X-math.max(320,2*(30+164*actionScale.Scale)))/rowWidth)
			skillBar.Position=UDim2.new(.5,not touch and viewport.X>=1100 and -55 or 0,1,-bottomInset)
		end
		local slotHeight=skillScale.Scale<.85 and TALL_SLOT_HEIGHT or SLOT_HEIGHT
		skillBar.Size=UDim2.fromOffset(rowWidth,slotHeight+4)
		for _,button in ipairs(itemButtons) do button.Size=UDim2.fromOffset(64,slotHeight) end
		for _,button in ipairs(skillButtons) do button.Size=UDim2.fromOffset(64,slotHeight) end
		-- Reset after input-mode changes; a hidden mobile JumpButton must not lift Attack.
		attack.Position=UDim2.fromOffset(90,0)
		if touch then
			local jump=playerGui:FindFirstChild('JumpButton',true)
			actions.Size=UDim2.fromOffset(172,188)
			actions.Position=UDim2.new(1,-20,1,0)
			dodge.Position=UDim2.fromOffset(8,132);dodge.Size=UDim2.fromOffset(56,56)
			block.Position=UDim2.fromOffset(8,66);block.Size=UDim2.fromOffset(56,56)
			sprint.Position=UDim2.fromOffset(8,0);sprint.Size=UDim2.fromOffset(56,56)
			attack.Position=UDim2.fromOffset(90,0);attack.Size=UDim2.fromOffset(64,64)
			local jumpVisible=jump and jump:IsA('GuiObject') and jump.AbsoluteSize.Y>0
			local ancestor=jump
			while jumpVisible and ancestor and ancestor~=playerGui do
				if ancestor:IsA('GuiObject') and not ancestor.Visible or ancestor:IsA('ScreenGui') and not ancestor.Enabled then jumpVisible=false end
				ancestor=ancestor.Parent
			end
			if jumpVisible then
				local controlScale=actionScale.Scale
				local left=root.AbsolutePosition.X+viewport.X-20+(90-172)*controlScale
				local top=root.AbsolutePosition.Y+viewport.Y-188*controlScale
				local pos,size=jump.AbsolutePosition,jump.AbsoluteSize
				if left<pos.X+size.X and left+64*controlScale>pos.X and top<pos.Y+size.Y and top+64*controlScale>pos.Y then
					-- Keep Attack beside Sprint; use its left side if jump occupies the right.
					attack.Position=UDim2.fromOffset(-68,0)
				end
			end
		end
  practice.Position = UDim2.fromOffset(status.Position.X.Offset, 16 + status.Size.Y.Offset * scale + 8 + (growthPoints.Visible and 30*scale or 0))
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
	-- Default mobile controls can be mounted after our HUD and move on rotation.
	local jumpConnection
	local function bindJump(child)
		if child.Name~='JumpButton' or not child:IsA('GuiObject') then return end
		if jumpConnection then jumpConnection:Disconnect() end
		jumpConnection=child:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateScale)
		updateScale()
	end
	playerGui.DescendantAdded:Connect(bindJump)
	local jump=playerGui:FindFirstChild('JumpButton',true);if jump then bindJump(jump) end
	bindCamera()

	return {
		attack = attack,
  growthPoints = growthPoints,
		block = block,
		sprint = sprint,
		skills = skillButtons,
		ultimate = ultimate,
		items = itemButtons,
		dodge = dodge,
		back = back,
		mapMenu=minimap.fullMap,heroMenu=minimap.hero,bagMenu=minimap.bag,journalMenu=minimap.journal,settingsMenu=minimap.settings,
		setVisible = function(visible)
			gui.Enabled = visible
			topGui.Enabled=visible
			if not visible then minimap.menu.Visible=false end
		end,
		setClass = function(classId)
			classLabel.Text = Text.Class[classId] or ""
		end,
		setStory = function(value)
   headingTitle.Text,subtitle.Text=StoryHeading.resolve(value)
   storyTracker=value
   renderTracker()
  end,
  setPractice = function(value)
			practiceProgress = value
			renderTracker()
		end,
		setPracticeInput = function(value)
			if value == practiceInput then return end
			practiceInput = value
			renderTracker()
		end,
		setHealth = setHealth,
		setMana = function(current, maximum)
			local showMana = typeof(maximum) == "number" and maximum > 0
			setManaValue(current, maximum)
			status.Size = UDim2.fromOffset(248, showMana and 145 or 100)
			for _, suffix in ipairs({ "Label", "Value", "Track" }) do
				status[Text.Mana .. suffix].Visible = showMana
			end
			updateScale()
		end,
		setCooldowns = function(character)
			if gui.Enabled then minimap.update(character) end
			if character then
				classLabel.Text=Text.Class[character:GetAttribute("K0ClassId")] or ""
    local st,kp=character:GetAttribute("K0StatPoints") or 0,character:GetAttribute("K0SkillPoints") or 0
    local showPoints=st>0 or kp>0
    local changed=growthPoints.Visible~=showPoints
    growthPoints.Visible=showPoints;growthPoints.Text=string.format(Text.AvailableGrowth,st,kp)
    if changed then updateScale() end
				local level=character:GetAttribute("K0Level") or 1
				local total=Growth.totalXP({level=level,xp=character:GetAttribute("K0XP") or 0})
				local progress=level<Growth.maxLevel and string.format(Text.TotalXP,total,Growth.xpAtLevel(level+1)) or string.format(Text.TotalXPMax,total)
				xpLabel.Text=string.format(Text.LevelXP,level,progress)
			end
			for index, button in ipairs(itemButtons) do
				local count = character and character:GetAttribute("K0ItemCount" .. index) or 0
				local definitionId = character and character:GetAttribute("K0ItemDefinition" .. index)
				local definition = Catalog.items[definitionId or (index == 1 and "health_potion" or "mana_potion")]
				if definition and definition.potionTier then
					if button:GetAttribute("DefinitionId") ~= definition.id then
						local old = button:FindFirstChild("PotionIcon"); if old then old:Destroy() end
						PotionIcon.create(button, definition, SLOT_ICON_POSITION, SLOT_ICON_SIZE)
						button:SetAttribute("DefinitionId", definition.id)
					end
					button.Caption.Text = definition.potionSize .. " " .. definition.glyph
					button.Caption.TextColor3 = definition.restore == "health" and Color3.fromRGB(255, 210, 195) or Color3.fromRGB(181, 235, 255)
				end
				button.ItemCount.Text = count > 99 and "99+" or "x" .. tostring(count)
				button.TDButtonArt.ImageTransparency = count > 0 and 0 or .45
				button.ItemCount.TextColor3 = count > 0 and COLORS.cream or COLORS.muted
			end
   local ultimateId=character and character:GetAttribute('K0UltimateId')
   local ultimateSkill
   for _,d in ipairs(Config.Skills[character and character:GetAttribute('K0ClassId')] or {}) do if d.id==ultimateId and d.ultimate then ultimateSkill=d end end
   -- No locked placeholder or reserved combat slot before the final advancement.
   ultimate.Visible=ultimateSkill~=nil
   if not ultimateSkill then SkillIcon.set(ultimate.SkillIcon,nil,false,false) end
   if ultimateSkill then
    local remaining=math.max(0,(character:GetAttribute('K0UltimateReady') or 0)-Workspace:GetServerTimeNow())
    ultimate.Active=remaining<=0;ultimate.Caption.Text=remaining>0 and string.format('%.1fs',remaining) or Text.Ultimate
    ultimateHint.Text=UserInputService.TouchEnabled and 'TAP' or UserInputService.GamepadEnabled and 'D-PAD UP' or 'T'
    ultimateHint.Size=UDim2.fromOffset(#ultimateHint.Text>2 and 48 or 20,16)
    ultimate.TDButtonArt.ImageTransparency=remaining>0 and .45 or 0
    SkillIcon.set(ultimate.SkillIcon,ultimateSkill,true,remaining>0)
   end
			for index, button in ipairs(skillButtons) do
				local classId = character and character:GetAttribute("K0ClassId")
				local equipped = character and character:GetAttribute("K0EquippedSkill" .. index)
				local count = character and character:GetAttribute("K0SkillSlotCount") or 3
				local ability
				for _, candidate in ipairs(Config.Skills[classId] or {}) do if candidate.id == equipped then ability = candidate; break end end
				button.Caption.Text = index > count and "LOCKED" or ability and ability.name or "EMPTY"
				button.Active = index <= count and ability ~= nil
				local ready = character and character:GetAttribute("K0SkillReady" .. index) or 0
				local remaining = math.max(0, (ready or 0) - Workspace:GetServerTimeNow())
				button.BackgroundTransparency = remaining > 0 and 0.45 or 0
				button.TDButtonArt.ImageTransparency = index > count and .6 or remaining > 0 and .35 or 0
				SkillIcon.set(button.SkillIcon,index<=count and ability or nil,index<=count,remaining>0)
				local label = button.Cooldown
				label.Visible = remaining > 0
				label.Text = if remaining <= 0 then "" elseif skillScale.Scale < .85 then string.format("%ds",math.ceil(remaining)) else string.format("%.1fs",remaining)
			end
		end,
		setState = function(value)
			state.Text = value
		end,
		setHints = function(attackText, blockText, dodgeText, sprintText, keys)
			attackHint.Text, blockHint.Text, dodgeHint.Text = attackText, blockText, dodgeText
			sprintHint.Text = sprintText or "E"
			for index, hint in ipairs(skillHints) do
				hint.Text = keys and keys[index] or tostring(index)
				hint.Size=UDim2.fromOffset(#hint.Text>2 and 27 or 20,16)
			end
		end,
		showFeedback = function(value, duration, transparentBackground)
			feedbackSequence += 1
			local sequence = feedbackSequence
			feedback.Text = value
			feedback.BackgroundTransparency = if transparentBackground then 1 else .6
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
