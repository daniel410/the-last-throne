-- The server owns combat, damage, stamina and target selection. This client only
-- sends intentions and renders replicated state.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local hud = require(script.K0Hud).create()
hud.setVisible(false)
require(script.K0Telegraphs).start()
require(script.K0SwordVisual).start()
require(script.K0EnemyVisual).start()
local actionRemote
local heldBlock = false
local blockGeneration = 0
local touchBlockInput
local attackInputs = {}
local attackGeneration = 0
local characterConnections = {}
local showingSpawnRetry = false
local focused = true
local heroSnapshot
local heroRequestRemote
local lobby
local pendingRequest
local requestSequence = 0
local lastRevision = -1

local function combatInputAllowed()
	local character = player.Character
	return focused and not GuiService.MenuIsOpen and not UserInputService:GetFocusedTextBox()
		and player:GetAttribute("K0SessionPhase") == "Tutorial"
		and character and character:GetAttribute("K0SpawnReady") == true
		and character:GetAttribute("K0State") ~= nil and character:GetAttribute("K0State") ~= "Dead"
end

local function isKnight()
	local character = player.Character
	return character and character:GetAttribute("K0ClassId") == "knight"
end

local function updateSpawnStatus()
	local status = player:GetAttribute("K0SpawnStatus")
	if status == "Retrying" then
		showingSpawnRetry = true
		hud.setState(Text.State.Retrying)
		hud.showFeedback(Text.SpawnRetry, 60)
	elseif status == "Loading" or status == "Respawning" then
		if showingSpawnRetry then hud.clearFeedback() end
		showingSpawnRetry = false
		hud.setState(Text.State.Loading)
	elseif status == "Ready" then
		if showingSpawnRetry then hud.clearFeedback() end
		showingSpawnRetry = false
		local character = player.Character
		hud.setState(character and Text.State[character:GetAttribute("K0State")] or Text.State.Idle)
	end
end
player:GetAttributeChangedSignal("K0SpawnStatus"):Connect(updateSpawnStatus)
updateSpawnStatus()

local function sendAction(action, direction)
	if actionRemote and (action == "BlockEnd" or combatInputAllowed()) then
		actionRemote:FireServer(action, direction)
	end
end

local function movementDirection()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.MoveDirection.Magnitude > 0.01 then
		return humanoid.MoveDirection
	end
	return nil
end

local function attack()
	sendAction("Attack")
end

local function attackKey(input)
	if input.UserInputType == Enum.UserInputType.Touch then return input end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then return "mouse" end
	if input.KeyCode == Enum.KeyCode.ButtonR2 then return "gamepad" end
	return nil
end

local function startAttack(input)
	if not combatInputAllowed() then return end
	local key = attackKey(input)
	if not key or attackInputs[key] then return end
	local wasHeld = next(attackInputs) ~= nil
	attackInputs[key] = true
	if wasHeld then return end
	if not heldBlock then attack() end
	attackGeneration += 1
	local generation = attackGeneration
	task.spawn(function()
		while generation == attackGeneration and next(attackInputs) do
			task.wait(0.14)
			if generation == attackGeneration and next(attackInputs) and not heldBlock then attack() end
		end
	end)
end

local function endAttack(input)
	local key = attackKey(input)
	if not key then return end
	attackInputs[key] = nil
	if not next(attackInputs) then attackGeneration += 1 end
end

local function clearAttacks()
	table.clear(attackInputs)
	attackGeneration += 1
end

local function dodge()
	sendAction("Dodge", movementDirection())
end

local function castArcane()
	local character = player.Character
	if character and character:GetAttribute("K0ClassId") == "mage" and combatInputAllowed() then
		sendAction("CastArcane")
	end
end

local function startBlock()
	if heldBlock or not isKnight() or not combatInputAllowed() then return end
	heldBlock = true
	blockGeneration += 1
	local generation = blockGeneration
	sendAction("BlockStart")
	task.spawn(function()
		while heldBlock and generation == blockGeneration do
			task.wait(0.14)
			local character = player.Character
			if heldBlock and generation == blockGeneration and character and character:GetAttribute("K0State") ~= "Block" then
				sendAction("BlockStart")
			end
		end
	end)
end

local function endBlock()
	if not heldBlock then return end
	heldBlock = false
	blockGeneration += 1
	touchBlockInput = nil
	sendAction("BlockEnd")
end

local function clearCharacterConnections()
	for _, connection in characterConnections do
		connection:Disconnect()
	end
	table.clear(characterConnections)
end

local function bindCharacter(character)
	clearCharacterConnections()
	endBlock()
	clearAttacks()
	hud.setHealth(nil, nil)
	hud.setStamina(nil, nil)
	hud.setState(Text.State.Loading)

	local function updateStamina()
		hud.setStamina(character:GetAttribute("K0Stamina"), character:GetAttribute("K0MaxStamina"))
	end
	local function updateState()
		local value = character:GetAttribute("K0State")
		if value then hud.setState(Text.State[value] or Text.State.Idle) end
	end
	local function showFeedback()
		local message = Text.Feedback[character:GetAttribute("K0Feedback")]
		if message then hud.showFeedback(message) end
	end
	local function updateClass()
		hud.setClass(character:GetAttribute("K0ClassId"))
		if not isKnight() then endBlock() end
	end
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0Stamina"):Connect(updateStamina))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0MaxStamina"):Connect(updateStamina))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0State"):Connect(updateState))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0FeedbackSeq"):Connect(showFeedback))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0ClassId"):Connect(updateClass))
	updateStamina()
	updateState()
	updateClass()

	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 15)
		if not humanoid or player.Character ~= character then return end
		local function updateHealth()
			hud.setHealth(humanoid.Health, humanoid.MaxHealth)
		end
		table.insert(characterConnections, humanoid.HealthChanged:Connect(updateHealth))
		table.insert(characterConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth))
		updateHealth()
	end)
end

player.CharacterAdded:Connect(bindCharacter)
player.CharacterRemoving:Connect(function()
	clearCharacterConnections()
	endBlock()
	clearAttacks()
end)
if player.Character then bindCharacter(player.Character) end

hud.attack.InputBegan:Connect(startAttack)
hud.attack.InputEnded:Connect(endAttack)
hud.dodge.Activated:Connect(dodge)
hud.skill.Activated:Connect(castArcane)
hud.block.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		touchBlockInput = input
		startBlock()
	end
end)
hud.block.InputEnded:Connect(function(input)
	if input == touchBlockInput then endBlock() end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or UserInputService:GetFocusedTextBox() then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		startAttack(input)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		startBlock()
	elseif input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonY then
		castArcane()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	endAttack(input)
	if input == touchBlockInput or input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		endBlock()
	end
end)
UserInputService.WindowFocusReleased:Connect(function()
	focused = false
	endBlock()
	clearAttacks()
end)
UserInputService.WindowFocused:Connect(function() focused = true end)
UserInputService.TextBoxFocused:Connect(function()
	endBlock()
	clearAttacks()
end)
GuiService.MenuOpened:Connect(function()
	endBlock()
	clearAttacks()
end)

-- Space is dodge in the flat K0 arena, so consume the default keyboard jump.
ContextActionService:BindActionAtPriority("K0Dodge", function(_, state)
	if not combatInputAllowed() then return Enum.ContextActionResult.Pass end
	if state == Enum.UserInputState.Begin then dodge() end
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Space, Enum.KeyCode.ButtonB)

local function updateHints()
	local input = UserInputService:GetLastInputType()
	if input.Name:match("^Gamepad") then
		hud.setHints(Text.HintR2, Text.HintL2, Text.HintB, Text.HintY)
	elseif UserInputService.TouchEnabled and (input == Enum.UserInputType.Touch or not UserInputService.KeyboardEnabled) then
		hud.setHints(Text.HintTap, Text.HintHold, Text.HintTap, Text.HintTap)
	else
		hud.setHints(Text.HintClick, Text.HintRightClick, Text.HintSpace, Text.HintQ)
	end
end
UserInputService.LastInputTypeChanged:Connect(updateHints)
updateHints()

local function requestHero(action, argument)
	if pendingRequest then return end
	if not heroRequestRemote then
		if lobby then lobby.showError("Unavailable") end
		return
	end
	endBlock()
	clearAttacks()
	requestSequence += 1
	local requestId = "ui-" .. tostring(requestSequence)
	pendingRequest = requestId
	lobby.setBusy(true)
	heroRequestRemote:FireServer(action, requestId, argument)
	task.delay(8, function()
		if pendingRequest ~= requestId then return end
		pendingRequest = nil
		lobby.setBusy(false)
		lobby.showError("Unavailable")
	end)
end

lobby = require(script.HeroLobbyGui).create(requestHero)
hud.back.Activated:Connect(function() requestHero("ReturnLobby") end)

local function updateSessionView()
	local playing = player:GetAttribute("K0SessionPhase") == "Tutorial"
	hud.setVisible(playing)
	if not playing then endBlock(); clearAttacks() end
	if heroSnapshot then
		for _, hero in ipairs(heroSnapshot.heroes) do
			if hero.heroId == heroSnapshot.selectedHeroId then
				hud.setPractice(hero.practice, hero.classId)
				break
			end
		end
	end
end
player:GetAttributeChangedSignal("K0SessionPhase"):Connect(updateSessionView)
updateSessionView()

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
	local remote = remotes and remotes:WaitForChild("K0Action", 15)
	if remote and remote:IsA("RemoteEvent") then
		actionRemote = remote
	else
		hud.showFeedback(Text.Unavailable, 8)
	end
end)

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
	local requestRemote = remotes and remotes:WaitForChild("K0HeroRequest", 15)
	local responseRemote = remotes and remotes:WaitForChild("K0HeroState", 15)
	if not requestRemote or not requestRemote:IsA("RemoteEvent") or not responseRemote or not responseRemote:IsA("RemoteEvent") then
		lobby.showError("Unavailable")
		return
	end
	heroRequestRemote = requestRemote
	responseRemote.OnClientEvent:Connect(function(value, requestId, errorCode)
		if type(value) ~= "table" or type(value.revision) ~= "number" or value.revision < lastRevision then return end
		if type(value.heroes) ~= "table" then return end
		lastRevision, heroSnapshot = value.revision, value
		if requestId == pendingRequest or errorCode and requestId == nil then
			pendingRequest = nil
			lobby.setBusy(false)
		end
		lobby.setState(value, errorCode)
		updateSessionView()
	end)
	requestHero("GetState")
end)
