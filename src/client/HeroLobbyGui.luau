-- English session-roster UI. Requests carry intentions; only the server creates
-- heroes, validates ownership and makes a new playable Character.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))

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

local function button(parent, name, value, position, size)
	local result = Instance.new("TextButton")
	result.Name, result.Text = name, value
	result.Position, result.Size = position, size
	result.BackgroundColor3 = COLOR.blue
	result.BorderSizePixel = 0
	result.Font, result.TextSize = Enum.Font.GothamBold, 13
	result.TextColor3 = COLOR.cream
	result.TextWrapped = true
	result.Selectable = true
	result.Parent = parent
	rounded(result, 7)
	return result
end

function LobbyGui.create(request)
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
	local shell = Instance.new("Frame")
	shell.Name = "HeroPanel"
	shell.AnchorPoint = Vector2.new(0.5, 0.5)
	shell.Position = UDim2.fromScale(0.5, 0.5)
	shell.Size = UDim2.new(1, -24, 1, -24)
	shell.BackgroundColor3 = COLOR.panel
	shell.BorderSizePixel = 0
	shell.Parent = shade
	rounded(shell, 12)
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(920, 670)
	constraint.Parent = shell
	local stroke = Instance.new("UIStroke")
	stroke.Color, stroke.Thickness = COLOR.gold, 1.5
	stroke.Parent = shell
	label(shell, "Title", Text.Lobby.Title, UDim2.fromOffset(18, 12), UDim2.new(1, -36, 0, 30), 24, COLOR.gold)
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
		card.BackgroundColor3 = COLOR.ink
		card.BorderSizePixel = 0
		card.Parent = cards
		rounded(card, 8)
		local border = Instance.new("UIStroke")
		border.Color, border.Thickness = COLOR.blue, 1
		border.Parent = card
		local image = Instance.new("ImageLabel")
		image.Name = "Portrait"
		image.BackgroundTransparency = 1
		image.Position, image.Size = UDim2.fromOffset(8, 8), UDim2.fromOffset(104, 142)
		image.Image = PORTRAITS[classId]
		image.ScaleType = Enum.ScaleType.Fit
		image.Parent = card
		local fallback = label(card, "PortraitFallback", Text.Class[classId], UDim2.fromOffset(8, 20), UDim2.fromOffset(104, 110), 14, COLOR.gold)
		fallback.TextXAlignment = Enum.TextXAlignment.Center
		label(card, "ClassName", Text.Class[classId], UDim2.fromOffset(122, 10), UDim2.new(1, -132, 0, 36), 15, COLOR.gold)
		label(card, "Role", Text.Lobby.Role[classId], UDim2.fromOffset(122, 47), UDim2.new(1, -132, 0, 40), 11, COLOR.muted)
		local status = label(card, "Ownership", Text.Lobby.NewHero, UDim2.fromOffset(122, 90), UDim2.new(1, -132, 0, 18), 10, COLOR.muted)
		local choose = button(card, "ChooseHero", Text.Lobby.Create, UDim2.fromOffset(122, 115), UDim2.new(1, -132, 0, 33))
		cardViews[classId] = { button = choose, border = border, status = status }
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
	local start = button(shell, "StartTutorial", Text.Lobby.Start, UDim2.new(1, -214, 1, -66), UDim2.fromOffset(196, 46))
	start.Activated:Connect(function()
		if busy or not current then return end
		if current.phase == "SpawnFailed" then request("ReturnLobby")
		elseif current.canStart then request("StartTutorial") end
	end)

	refresh = function()
		if not current then return end
		gui.Enabled = current.phase ~= "Tutorial"
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
			view.border.Color = isSelected and COLOR.gold or COLOR.blue
			view.border.Thickness = isSelected and 2 or 1
			view.status.Text = owned and Text.Lobby.Owned or Text.Lobby.NewHero
		end
		roster.Text = string.format(Text.Lobby.RosterFormat, #current.heroes, current.maxHeroes or 4)
		selection.Text = selected and string.format(Text.Lobby.SelectedFormat, Text.Class[selected.classId]) or Text.Lobby.Choose
		start.Text = current.phase == "LoadingTutorial" and Text.Lobby.Starting
			or current.phase == "SpawnFailed" and Text.Lobby.Retry or Text.Lobby.Start
		start.Active = not busy and (current.canStart or current.phase == "SpawnFailed")
		start.Selectable, start.AutoButtonColor = start.Active, start.Active
		start.BackgroundTransparency = start.Active and 0 or 0.6
		if not gui.Enabled and GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(gui) then
			GuiService.SelectedObject = nil
		elseif gui.Enabled and UserInputService:GetLastInputType().Name:match("^Gamepad") then
			local focused = GuiService.SelectedObject
			if not focused or not focused:IsDescendantOf(gui) or not focused.Selectable then
				GuiService.SelectedObject = start.Selectable and start or cardViews.knight.button.Selectable and cardViews.knight.button or nil
			end
		end
	end

	local function resize()
		local width = shell.AbsoluteSize.X
		grid.CellSize = width < 670 and UDim2.new(1, -6, 0, 158) or UDim2.new(0.5, -7, 0, 158)
		-- Scroll the cards on small screens; the start action stays in reach.
		local compact = shell.AbsoluteSize.Y < 480
		subtitle.Visible = not compact
		cards.Position = UDim2.fromOffset(18, compact and 121 or 142)
		cards.Size = UDim2.new(1, -36, 1, compact and -230 or -300)
		classLock.Visible = not compact
		errorLabel.Position = UDim2.new(0, 18, 1, compact and -106 or -151)
		roster.Visible = not compact
		selection.Visible = width >= 420
		start.Size = width < 420 and UDim2.new(1, -36, 0, 42) or UDim2.fromOffset(196, 46)
		start.Position = width < 420 and UDim2.new(0, 18, 1, -58) or UDim2.new(1, -214, 1, -66)
	end
	shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resize)
	UserInputService.LastInputTypeChanged:Connect(function() refresh() end)
	resize()
	return {
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
