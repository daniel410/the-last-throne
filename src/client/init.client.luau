-- The server owns combat, damage, stamina and target selection. This client only
-- sends intentions and renders replicated state.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local hud = require(script.K0Hud).create()
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

local function sendAction(action, direction)
	if actionRemote then
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

local function startBlock()
	if heldBlock then return end
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
	hud.setState(Text.State.Idle)

	local function updateStamina()
		hud.setStamina(character:GetAttribute("K0Stamina"), character:GetAttribute("K0MaxStamina"))
	end
	local function updateState()
		hud.setState(Text.State[character:GetAttribute("K0State")] or Text.State.Idle)
	end
	local function showFeedback()
		local message = Text.Feedback[character:GetAttribute("K0Feedback")]
		if message then hud.showFeedback(message) end
	end
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0Stamina"):Connect(updateStamina))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0MaxStamina"):Connect(updateStamina))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0State"):Connect(updateState))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0FeedbackSeq"):Connect(showFeedback))
	updateStamina()
	updateState()

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
if player.Character then bindCharacter(player.Character) end

hud.attack.InputBegan:Connect(startAttack)
hud.attack.InputEnded:Connect(endAttack)
hud.dodge.Activated:Connect(dodge)
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
	end
end)
UserInputService.InputEnded:Connect(function(input)
	endAttack(input)
	if input == touchBlockInput or input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 then
		endBlock()
	end
end)
UserInputService.WindowFocusReleased:Connect(function()
	endBlock()
	clearAttacks()
end)

-- Space is dodge in the flat K0 arena, so consume the default keyboard jump.
ContextActionService:BindActionAtPriority("K0Dodge", function(_, state)
	if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
	if state == Enum.UserInputState.Begin then dodge() end
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Space, Enum.KeyCode.ButtonB)

local function updateHints()
	local input = UserInputService:GetLastInputType()
	if input.Name:match("^Gamepad") then
		hud.setHints(Text.HintR2, Text.HintL2, Text.HintB)
	elseif UserInputService.TouchEnabled and (input == Enum.UserInputType.Touch or not UserInputService.KeyboardEnabled) then
		hud.setHints(Text.HintTap, Text.HintHold, Text.HintTap)
	else
		hud.setHints(Text.HintClick, Text.HintRightClick, Text.HintSpace)
	end
end
UserInputService.LastInputTypeChanged:Connect(updateHints)
updateHints()

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
	local remote = remotes and remotes:WaitForChild("K0Action", 15)
	if remote and remote:IsA("RemoteEvent") then
		actionRemote = remote
	else
		hud.showFeedback(Text.Unavailable, 8)
	end
end)
