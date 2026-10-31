-- English session-roster UI. Requests carry intentions; only the server creates
-- heroes, validates ownership and makes a new playable Character.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local Config = require(ReplicatedStorage.Shared.K0Config)
local Theme=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)

local LobbyGui = {}
local CLASS_ORDER = { "knight", "elf", "dwarf", "mage" }
-- Reviewed Throne Defense HERO_PORTRAITS. Runtime permissions are environment-specific.
local PORTRAITS = {
	knight = "rbxassetid://103255177842108", elf = "rbxassetid://80894238854345",
	dwarf = "rbxassetid://74628903359757", mage = "rbxassetid://91907986271282",
}
local COLOR = {
	ink = Color3.fromRGB(12, 24, 43), panel = Color3.fromRGB(20, 33, 53),
	blue = Color3.fromRGB(48, 91, 137), gold = Color3.fromRGB(226, 190, 116),
	cream = Color3.fromRGB(255, 246, 220), muted = Color3.fromRGB(180, 194, 205),
	error = Color3.fromRGB(255, 178, 155),
}

local function rounded(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function label(parent, name, value, position, size, fontSize, color)
	local result = Instance.new("TextLabel")
	result.Name, result.Text = name, value
	result.Position, result.Size = position, size
	result.BackgroundTransparency = 1
	result.Font, result.TextSize = Enum.Font.GothamBold, fontSize
	result.TextColor3 = color or COLOR.cream
	result.TextXAlignment = Enum.TextXAlignment.Left
	result.TextWrapped = true
	result.Parent = parent
	return result
end

local function button(parent,name,value,position,size)
	local result=Theme.button(parent,name,"",position,size)
	result.Caption.Text=value
	result.TextTransparency=1
	result:GetPropertyChangedSignal("Text"):Connect(function() result.Caption.Text=result.Text end)
	result:GetPropertyChangedSignal("TextSize"):Connect(function() result.Caption.TextSize=result.TextSize end)
	result.Text,result.TextSize,result.Font,result.TextColor3,result.TextWrapped=value,13,Enum.Font.GothamBold,COLOR.cream,true
	return result
end

function LobbyGui.create(request,onManage)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local previous = playerGui:FindFirstChild("HeroLobbyGui")
	if previous then previous:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "HeroLobbyGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 30
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui
	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = COLOR.ink
	shade.BackgroundTransparency = 0.18
	shade.BorderSizePixel = 0
	shade.Active = true
	shade.Parent = gui
	local minimized, suppressed = false, false
	local reopen = button(gui, "OpenHeroes", "HEROES", UDim2.fromOffset(14,10), UDim2.fromOffset(120,44))
	reopen.Visible = false
	-- Leave space above the panel for the lobby buttons and wallet.
	local shell=Menu.frame(shade,"HeroPanel",UDim2.new(.5,0,.5,58),UDim2.new(1,-120,1,-164))
	shell.AnchorPoint=Vector2.new(.5,.5)
	local constraint=Instance.new("UISizeConstraint");constraint.MaxSize=Vector2.new(900,560);constraint.Parent=shell
	local explore = button(shell, "ExploreCourtyard", "X", UDim2.new(1,-58,0,12), UDim2.fromOffset(40,40))
	explore.Activated:Connect(function() minimized=true; shade.Visible=false; reopen.Visible=not suppressed end)
	reopen.Activated:Connect(function() minimized=false; shade.Visible=not suppressed; reopen.Visible=false end)
	local titlePlaque=Menu.plaque(shell,"TitlePlaque","THE LAST THRONE",UDim2.new(.5,-200,0,-26),UDim2.fromOffset(400,64))
	local subtitle = label(shell, "Subtitle", Text.Lobby.Subtitle, UDim2.fromOffset(18, 46), UDim2.new(1, -36, 0, 23), 13, COLOR.cream)
	label(shell, "SessionNotice", Text.Lobby.Notice, UDim2.fromOffset(18, 75), UDim2.new(1, -36, 0, 34), 12, COLOR.gold)
	local roster = label(shell, "Roster", string.format(Text.Lobby.RosterFormat, 0, 4), UDim2.fromOffset(18, 113), UDim2.new(1, -36, 0, 20), 12, COLOR.muted)

	local cards = Instance.new("ScrollingFrame")
	cards.Name = "HeroCards"
	cards.Position = UDim2.fromOffset(18, 142)
	cards.Size = UDim2.new(1, -36, 1, -300)
	cards.BackgroundTransparency = 1
	cards.BorderSizePixel = 0
	cards.ScrollBarThickness = 5
	cards.ScrollBarImageColor3 = COLOR.gold
	cards.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cards.CanvasSize = UDim2.new()
	cards.ScrollingDirection = Enum.ScrollingDirection.Y
	cards.Parent = shell
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.5, -7, 0, 158)
	grid.CellPadding = UDim2.fromOffset(12, 12)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = cards
	local cardViews = {}
	local current
	local busy = false
	local refresh
	for index, classId in ipairs(CLASS_ORDER) do
		local card = Instance.new("Frame")
		card.Name, card.LayoutOrder = classId, index
		card:Destroy()
		card=Menu.frame(cards,classId,UDim2.new(),UDim2.new());card.LayoutOrder=index
		local border=card:FindFirstChildOfClass("UIStroke")
		local selectedMark=label(card,"SelectedMark","✓",UDim2.fromOffset(12,10),UDim2.fromOffset(40,40),32,COLOR.gold)
		selectedMark.ZIndex=3;selectedMark.Visible=false
		local image = Instance.new("ImageLabel")
		image.Name = "Portrait"
		image.BackgroundTransparency = 1
		image.Position, image.Size = UDim2.fromOffset(9, 9), UDim2.new(1,-18,1,-142)
		image.Image = PORTRAITS[classId]
		image.ScaleType = Enum.ScaleType.Crop
		image.Parent = card
		local fallback = label(card, "PortraitFallback", Text.Class[classId], UDim2.fromOffset(12,20), UDim2.new(1,-24,1,-152), 14, COLOR.gold)
		fallback.TextXAlignment = Enum.TextXAlignment.Center
		local plaque=Menu.plaque(card,"ClassPlaque",classId=="dwarf" and "Dwarf" or Text.Class[classId],UDim2.new(0,0,1,-146),UDim2.new(1,0,0,48))
		plaque.Caption.TextSize=20
		local role=label(card,"Role",({knight="Sword & Shield",elf="Bow & Arrow",dwarf="Axe Thrower",mage="Arcane & Elements"})[classId],UDim2.new(0,10,1,-99),UDim2.new(1,-20,0,24),11,COLOR.muted);role.TextXAlignment=Enum.TextXAlignment.Center
		local status=label(card,"Ownership",Text.Lobby.NewHero,UDim2.new(0,10,1,-76),UDim2.new(1,-20,0,20),10,COLOR.gold);status.TextXAlignment=Enum.TextXAlignment.Center
		local choose=button(card,"ChooseHero",Text.Lobby.Create,UDim2.new(0,10,1,-52),UDim2.new(1,-20,0,42))
		cardViews[classId]={button=choose,border=border,status=status,mark=selectedMark,portrait=image}
		choose.Activated:Connect(function()
			if busy or not current or not current.canManage then return end
			local existing
			for _, hero in ipairs(current.heroes) do if hero.classId == classId then existing = hero end end
			request(existing and "SelectHero" or "CreateHero", existing and existing.heroId or classId)
		end)
		task.spawn(function()
			local loaded = false
			local ok = pcall(function()
				ContentProvider:PreloadAsync({ image }, function(_, statusValue)
					if statusValue == Enum.AssetFetchStatus.Success then loaded = true end
				end)
			end)
			if image.Parent and fallback.Parent then
				image.Visible = ok and loaded
				fallback.Visible = not (ok and loaded)
			end
		end)
	end

	local errorLabel = label(shell, "Message", Text.Lobby.Loading, UDim2.new(0, 18, 1, -151), UDim2.new(1, -36, 0, 36), 12, COLOR.error)
	local classLock = label(shell, "ClassLock", Text.Lobby.ClassLock, UDim2.new(0, 18, 1, -112), UDim2.new(1, -36, 0, 30), 11, COLOR.muted)
	local selection = label(shell, "Selection", Text.Lobby.Choose, UDim2.new(0, 18, 1, -76), UDim2.new(1, -242, 0, 58), 12, COLOR.cream)
	local training = button(shell, "StartTraining", Text.Lobby.Training, UDim2.new(.3,0,1,-56), UDim2.new(.26,-8,0,44))
 training.Activated:Connect(function() if not busy and current and current.canStart then request("StartTraining") end end)
 local start = button(shell, "StartTutorial", Text.Lobby.Start, UDim2.new(1, -214, 1, -66), UDim2.fromOffset(196, 46))
	start.Activated:Connect(function()
		if busy or not current then return end
		if current.phase == "SpawnFailed" then request("ReturnLobby")
		elseif current.canStart then request("StartTutorial") end
	end)

	local manage = button(shell, "ManageSkills", "MANAGE SKILLS", UDim2.new(0, 18, 1, -64), UDim2.fromOffset(150, 42))
	local skillPanel = Instance.new("Frame")
	skillPanel.Name = "SkillManagement"
	skillPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	skillPanel.Position = UDim2.fromScale(0.5, 0.5)
	skillPanel.Size = UDim2.new(1, -24, 1, -24)
	skillPanel.BackgroundColor3 = COLOR.ink
	skillPanel.BorderSizePixel = 0
	skillPanel.Visible = false
	skillPanel.ZIndex = 10
	skillPanel.Parent = shell
	rounded(skillPanel, 10)
	local title = label(skillPanel, "Title", "SKILL MANAGEMENT", UDim2.fromOffset(16, 10), UDim2.new(1, -100, 0, 30), 18, COLOR.gold)
	title.ZIndex = 11
	local instructions = label(skillPanel, "Instructions", Text.Lobby.SkillInstructions, UDim2.fromOffset(16, 42), UDim2.new(1, -32, 0, 48), 12, COLOR.muted)
	instructions.ZIndex = 11
	local close = button(skillPanel, "Close", "CLOSE", UDim2.new(1, -90, 0, 10), UDim2.fromOffset(76, 32))
	close.ZIndex = 11
	close.Activated:Connect(function() skillPanel.Visible = false; refresh() end)
	local skillList = Instance.new("ScrollingFrame")
	skillList.Name = "SkillSlots"
	skillList.Position = UDim2.fromOffset(16, 96)
	skillList.Size = UDim2.new(1, -32, 1, -160)
	skillList.BackgroundTransparency = 1
	skillList.BorderSizePixel = 0
	skillList.ScrollBarThickness = 5
	skillList.CanvasSize = UDim2.fromOffset(0, 250)
	skillList.ZIndex = 11
	skillList.Parent = skillPanel
	local slotButtons = {}
	for index = 1, 5 do
		local slot = button(skillList, "Slot" .. index, "", UDim2.fromOffset(0, (index - 1) * 48), UDim2.new(1, -8, 0, 40))
		slot.ZIndex = 12
		slotButtons[index] = slot
		slot.Activated:Connect(function()
			if busy or not current or not current.canManage then return end
			for _, hero in ipairs(current.heroes) do
				if hero.heroId == current.selectedHeroId and index <= (hero.practiceAdvanced and 5 or 3) then
					request("SetSkillSlot", tostring(index) .. ":" .. tostring(((hero.skillSlots[index] or 0) + 1) % 4))
					return
				end
			end
		end)
	end
	local practiceAdvance = button(skillPanel, "PracticeAdvancement", "PRACTICE: UNLOCK 5 SLOTS", UDim2.new(0, 16, 1, -52), UDim2.new(1, -32, 0, 38))
	practiceAdvance.ZIndex = 11
	practiceAdvance.Activated:Connect(function() if not busy then request("PracticeAdvance") end end)
	manage.Activated:Connect(function() if current and current.canStart and not busy then if onManage then onManage() else skillPanel.Visible = true; refresh() end end end)

	refresh = function()
		if not current then return end
		gui.Enabled = current.phase ~= "Tutorial" and current.phase~="Respawning" and current.phase~="LoadingTutorial"
		shade.Visible = not minimized and not suppressed
		reopen.Visible = minimized and not suppressed
		shell.SessionNotice.Text = current.inventoryMode == "RPG test save"
			and "Hero level, stats, skills and items are saved. Control practice resets."
			or "Studio session: heroes, equipment and items reset when this test ends."
		local selected
		for classId, view in pairs(cardViews) do
			local owned
			for _, hero in ipairs(current.heroes) do if hero.classId == classId then owned = hero end end
			local isSelected = owned and owned.heroId == current.selectedHeroId
			if isSelected then selected = owned end
			view.button.Text = isSelected and Text.Lobby.Selected or owned and Text.Lobby.Select or Text.Lobby.Create
			view.button.Active = current.canManage and not busy
			view.button.Selectable = view.button.Active
			view.button.AutoButtonColor = view.button.Active
			view.button.BackgroundTransparency = view.button.Active and 0 or 0.6
			view.mark.Visible=isSelected==true
			view.border.Color = isSelected and Color3.fromRGB(89,202,255) or Theme.color.silver
			view.border.Thickness = isSelected and 4 or 2
			view.status.Text = owned and Text.Lobby.Owned or Text.Lobby.NewHero
		end
		manage.Visible = selected ~= nil and current.phase == "Lobby"
		manage.Active = selected ~= nil and current.canManage and not busy
		if not selected or current.phase ~= "Lobby" then skillPanel.Visible = false end
		if selected then
			local skills = Config.Skills[selected.classId]
			for index, slot in ipairs(slotButtons) do
				local enabled = index <= (selected.practiceAdvanced and 5 or 3)
				local skill = skills[(selected.skillSlots or {})[index] or 0]
				local description = skill and (skill.magic
					and string.format(Text.Lobby.MagicSkillFormat, skill.name, skill.manaCost, skill.cooldown)
					or string.format(Text.Lobby.PhysicalSkillFormat, skill.name, skill.cooldown))
				slot.Text = tostring(index) .. "  " .. (not enabled and "LOCKED" or description or "EMPTY")
				slot.Active = enabled and current.canManage and not busy
				slot.Selectable = slot.Active
				slot.BackgroundTransparency = slot.Active and 0 or 0.6
			end
			practiceAdvance.Text = selected.practiceAdvanced and "PRACTICE ONLY: RESET TO 3 SLOTS" or "PRACTICE ONLY: TRY 5 SLOTS"
		end
		roster.Text = string.format(Text.Lobby.RosterFormat, #current.heroes, current.maxHeroes or 4)
		selection.Text = selected and string.format(Text.Lobby.SelectedFormat, Text.Class[selected.classId]) or Text.Lobby.Choose
		start.Text = current.phase == "LoadingTutorial" and Text.Lobby.Starting
			or current.phase == "SpawnFailed" and Text.Lobby.Retry or Text.Lobby.Start
		start.Active = not busy and (current.canStart or current.phase == "SpawnFailed")
		start.Selectable, start.AutoButtonColor = start.Active, start.Active
		start.BackgroundTransparency = start.Active and 0 or 0.6
  training.Active=not busy and current.canStart;training.Selectable=training.Active;training.AutoButtonColor=training.Active;training.BackgroundTransparency=training.Active and 0 or .6
		if not gui.Enabled and GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(gui) then
			GuiService.SelectedObject = nil
		elseif gui.Enabled and UserInputService:GetLastInputType().Name:match("^Gamepad") then
			local focused = GuiService.SelectedObject
			if skillPanel.Visible then
				if not focused or not focused:IsDescendantOf(skillPanel) or not focused.Selectable then GuiService.SelectedObject = slotButtons[1] end
			elseif not focused or not focused:IsDescendantOf(gui) or not focused.Selectable or focused:IsDescendantOf(skillPanel) then
				GuiService.SelectedObject = start.Selectable and start or cardViews.knight.button.Selectable and cardViews.knight.button or nil
			end
		end
	end

	local function resize()
		local width,height=shell.AbsoluteSize.X,shell.AbsoluteSize.Y
		local compact=width<720
		local short=height<480
		titlePlaque.Position=UDim2.new(.5,-math.min(200,width*.36),0,-22)
		titlePlaque.Size=UDim2.fromOffset(math.min(400,width*.72),56)
		titlePlaque.Caption.TextSize=compact and 17 or 24
		subtitle.Position,subtitle.Size=UDim2.fromOffset(22,38),UDim2.new(1,-86,0,24)
		subtitle.Text="CHOOSE YOUR HERO  /  Begin your adventure."
		subtitle.Visible=not short
		shell.SessionNotice.Position,shell.SessionNotice.Size=UDim2.fromOffset(22,short and 36 or 65),UDim2.new(1,-44,0,28)
		shell.SessionNotice.TextSize=10
		roster.Visible=false
		cards.Position=UDim2.fromOffset(22,short and 72 or 104)
		cards.Size=UDim2.new(1,-44,1,short and -170 or -218)
		local columns=compact and 2 or 4
		grid.CellSize=UDim2.new(1/columns,-(columns==4 and 12 or 9),0,compact and 282 or math.max(260,cards.AbsoluteSize.Y-8))
		grid.CellPadding=UDim2.fromOffset(14,16)
		classLock.Position,classLock.Size=UDim2.new(0,22,1,-106),UDim2.new(1,-44,0,28)
		classLock.TextSize=10;classLock.Visible=not short
		errorLabel.Position,errorLabel.Size=UDim2.new(0,22,1,-78),UDim2.new(1,-44,0,20)
		selection.Visible=false
		manage.Position,manage.Size=UDim2.new(0,22,1,-56),UDim2.new(.28,-28,0,44);manage.TextSize=compact and 10 or 13
		training.Position,training.Size=UDim2.new(.29,0,1,-56),UDim2.new(.25,-8,0,44)
  training.TextSize=compact and 10 or 13
  start.Position,start.Size=UDim2.new(.55,0,1,-56),UDim2.new(.45,-22,0,44)
		start.BackgroundColor3=Color3.fromRGB(20,120,46)
		explore.Position,explore.Size=UDim2.new(1,-54,0,52),UDim2.fromOffset(44,44)
		explore.BackgroundColor3=Color3.fromRGB(170,29,46)
	end

	shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resize)
	UserInputService.LastInputTypeChanged:Connect(function() refresh() end)
	resize()
	return {
		setSuppressed = function(value)
			suppressed=value
			shade.Visible=not value and not minimized
			reopen.Visible=not value and minimized
		end,
		setState = function(value, errorCode)
			if type(value) ~= "table" or type(value.heroes) ~= "table" then return end
			current = value
			if errorCode then errorLabel.Text = Text.Lobby.Errors[errorCode] or Text.Lobby.Errors.InvalidRequest
			elseif value.phase == "LoadingLobby" then errorLabel.Text = Text.Lobby.Loading
			elseif value.phase == "ReturningLobby" then errorLabel.Text = Text.Lobby.Returning
			elseif value.phase == "LoadingTutorial" then errorLabel.Text = Text.Lobby.Starting
			elseif value.phase == "SpawnFailed" then errorLabel.Text = Text.Lobby.Errors.SpawnUnavailable
			else errorLabel.Text = "" end
			refresh()
		end,
		setBusy = function(value)
			busy = value
			if busy then errorLabel.Text = Text.Lobby.Waiting end
			refresh()
		end,
		showError = function(errorCode)
			errorLabel.Text = Text.Lobby.Errors[errorCode] or Text.Lobby.Errors.InvalidRequest
		end,
	}
end

return LobbyGui
