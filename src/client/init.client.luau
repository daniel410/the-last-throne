-- The client may suggest a target. The server validates combat, damage,
-- mana, range and obstruction before rendering its replicated result.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local StarterGui=game:GetService("StarterGui")
local function hideDefaultHealth()
	task.spawn(function()
		for _=1,20 do
			local ok=pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false) end)
			if ok then return end
			task.wait(.25)
		end
		warn("Default health UI could not be hidden; custom health HUD remains active.")
	end)
end
hideDefaultHealth()
player.CharacterAdded:Connect(hideDefaultHealth)
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))
local Targeting = require(script.K0Targeting)
local hud = require(script.K0Hud).create()
hud.setVisible(false)
require(script.K0BackgroundMusic).start()
require(script.K0Telegraphs).start()
require(script.K0SwordVisual).start()
require(script.K0EnemyVisual).start()
require(script.K0HitEffects).start()
local actionRemote
local heldBlock = false
local heldSprint = false
local sprintGeneration = 0
local touchSprintInput
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
local selectedEnemy
local inventory
local growthGui
local targetHighlight
local targetConnections = {}

local function clearTarget()
	for _, connection in ipairs(targetConnections) do connection:Disconnect() end
	table.clear(targetConnections)
	selectedEnemy = nil
	if targetHighlight then targetHighlight:Destroy(); targetHighlight = nil end
end

local function selectAt(screenPosition)
	local part = Targeting.pick(screenPosition, player.Character)
	if not part then return false end
	if selectedEnemy ~= part then
		clearTarget()
		selectedEnemy = part
		targetHighlight = Instance.new("Highlight")
		targetHighlight.Name = "K0TargetHighlight"
		targetHighlight.Adornee = part
		targetHighlight.FillTransparency, targetHighlight.OutlineTransparency = 0.8, 0
		targetHighlight.FillColor, targetHighlight.OutlineColor = Color3.fromRGB(255, 200, 80), Color3.fromRGB(255, 235, 170)
		targetHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
		targetHighlight.Parent = part
		local humanoid = part:FindFirstChildOfClass("Humanoid")
		table.insert(targetConnections, humanoid.Died:Connect(function() if selectedEnemy == part then clearTarget() end end))
		table.insert(targetConnections, part.AncestryChanged:Connect(function() if selectedEnemy == part and not Targeting.valid(part) then clearTarget() end end))
		hud.showFeedback(string.format(Text.TargetSelected, humanoid.DisplayName))
	end
	return true
end

local function combatInputAllowed()
	local character = player.Character
	return focused and not GuiService.MenuIsOpen and not UserInputService:GetFocusedTextBox()
		and not player:GetAttribute("TLTStoryOpen") and not player:GetAttribute("TLTInventoryOpen") and not player:GetAttribute("TLTProgressionOpen")
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
	if action == "Item1" or action == "Item2" then
		if inventory and combatInputAllowed() then inventory.use(action == "Item1" and 1 or 2) end
		return
	end
	if actionRemote and (action == "BlockEnd" or action == "SprintEnd" or combatInputAllowed()) then
		local character = player.Character
		local classId = character and character:GetAttribute("K0ClassId")
		local canTarget = action == "Attack" or action:match("^Skill[12345]$") or (action == "CastArcane" and classId == "mage")
		local target = canTarget and selectedEnemy or nil
		if target and not Targeting.valid(target) then clearTarget(); target = nil end
		-- Avoid turning mid-swing when held input repeats. The server turns
		-- again when a buffered melee attack actually begins.
		local state = character and character:GetAttribute("K0State")
		if target and (classId == "elf" or action == "CastArcane" or state == "Idle" or state == "Block") then
			local root, enemyRoot = character:FindFirstChild("HumanoidRootPart"), target:FindFirstChild("HumanoidRootPart")
			if root and enemyRoot then
				local delta = enemyRoot.Position - root.Position
				local flat = Vector3.new(delta.X, 0, delta.Z)
				if flat.Magnitude > 0.01 then root.CFrame = CFrame.lookAt(root.Position, root.Position + flat) end
			end
		end
		actionRemote:FireServer(action, direction, target)
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

local function useSkill(slot)
	if combatInputAllowed() then sendAction("Skill" .. slot) end
end

local function startBlock()
	if heldBlock or not combatInputAllowed() then return end
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

local function startSprint()
	if heldSprint or not combatInputAllowed() then return end
	heldSprint = true
	sprintGeneration += 1
	local generation = sprintGeneration
	sendAction("SprintStart")
	task.spawn(function()
		while heldSprint and generation == sprintGeneration do
			task.wait(0.4)
			if heldSprint and generation == sprintGeneration then sendAction("SprintStart") end
		end
	end)
end

local function endSprint()
	if not heldSprint then return end
	heldSprint = false
	sprintGeneration += 1
	touchSprintInput = nil
	sendAction("SprintEnd")
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
	endSprint()
	clearAttacks()
	hud.setHealth(nil, nil)
	hud.setMana(nil, nil)
	hud.setState(Text.State.Loading)

	local function updateMana()
		hud.setMana(character:GetAttribute("K0Mana"), character:GetAttribute("K0MaxMana"))
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
	end
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0Mana"):Connect(updateMana))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0MaxMana"):Connect(updateMana))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0State"):Connect(updateState))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0FeedbackSeq"):Connect(showFeedback))
	table.insert(characterConnections, character:GetAttributeChangedSignal("K0ClassId"):Connect(updateClass))
	updateMana()
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
	clearTarget()
	clearCharacterConnections()
	endBlock()
	endSprint()
	clearAttacks()
end)
if player.Character then bindCharacter(player.Character) end

hud.attack.InputBegan:Connect(startAttack)
hud.attack.InputEnded:Connect(endAttack)
hud.dodge.Activated:Connect(dodge)
for slot, button in ipairs(hud.skills) do
	button.Activated:Connect(function() useSkill(slot) end)
end
for slot, button in ipairs(hud.items) do
	button.Activated:Connect(function() sendAction("Item" .. slot) end)
end
local deathCamera=require(script.HeroDeathCamera)
RunService:BindToRenderStep("HeroDeathCamera",Enum.RenderPriority.Camera.Value+1,function()
	deathCamera.update(player.Character,player:GetAttribute("K0SessionPhase")=="Respawning")
end)
RunService.RenderStepped:Connect(function() hud.setCooldowns(player.Character) end)
hud.sprint.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		touchSprintInput = input
		startSprint()
	end
end)
hud.sprint.InputEnded:Connect(function(input) if input == touchSprintInput then endSprint() end end)
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
	local character = player.Character
	local classId = character and character:GetAttribute("K0ClassId")
	if combatInputAllowed() and (classId == "knight" or classId == "elf" or classId == "dwarf" or classId == "mage")
		and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		local picked = selectAt(input.Position)
		-- A world tap selects; touch combat uses its dedicated HUD buttons.
		if picked and input.UserInputType == Enum.UserInputType.Touch then return end
	end
	if input.KeyCode == Enum.KeyCode.X and selectedEnemy then
		clearTarget(); hud.showFeedback(Text.TargetCleared)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		startAttack(input)
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.ButtonL2 then
		startBlock()
	elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonL3 then
		startSprint()
	elseif input.KeyCode == Enum.KeyCode.Z then
		sendAction("Item1")
	elseif input.KeyCode == Enum.KeyCode.C then
		sendAction("Item2")
	elseif input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.ButtonY then
		useSkill(1)
	elseif input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.ButtonX then
		useSkill(2)
	elseif input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.ButtonL1 then
		useSkill(3)
	elseif input.KeyCode == Enum.KeyCode.Four or input.KeyCode == Enum.KeyCode.DPadLeft then
		useSkill(4)
	elseif input.KeyCode == Enum.KeyCode.Five or input.KeyCode == Enum.KeyCode.DPadRight then
		useSkill(5)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	endAttack(input)
	if input == touchBlockInput or input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2 or input.KeyCode == Enum.KeyCode.Q then
		endBlock()
	end
	if input == touchSprintInput or input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonL3 then endSprint() end
end)
UserInputService.WindowFocusReleased:Connect(function()
	focused = false
	endBlock()
	endSprint()
	clearAttacks()
end)
UserInputService.WindowFocused:Connect(function() focused = true end)
UserInputService.TextBoxFocused:Connect(function()
	endBlock()
	endSprint()
	clearAttacks()
end)
GuiService.MenuOpened:Connect(function()
	endBlock()
	endSprint()
	clearAttacks()
end)

-- Keep the standard Space jump available; R is the keyboard dodge action.
ContextActionService:BindActionAtPriority("K0Dodge", function(_, state)
	if not combatInputAllowed() then return Enum.ContextActionResult.Pass end
	if state == Enum.UserInputState.Begin then dodge() end
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.R, Enum.KeyCode.ButtonB)

local function updateHints()
	local input = UserInputService:GetLastInputType()
	if input.Name:match("^Gamepad") then
		hud.setHints(Text.HintR2, Text.HintL2, Text.HintB, "L3", {"Y", "X", "L1", "LEFT", "RIGHT"})
	elseif UserInputService.TouchEnabled and (input == Enum.UserInputType.Touch or not UserInputService.KeyboardEnabled) then
		hud.setHints(Text.HintTap, Text.HintHold, Text.HintTap, Text.HintHold, {"1", "2", "3", "4", "5"})
	else
		hud.setHints(Text.HintClick, "Q / RMB", Text.HintR, "E", {"1", "2", "3", "4", "5"})
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
	endSprint()
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

lobby = require(script.HeroLobbyGui).create(requestHero,function() if growthGui then growthGui.open("Skills") end end)
inventory = require(script.InventoryGui).create(function(opened)
	if opened then
		if growthGui and growthGui.isOpen() then growthGui.close() end
		endBlock(); endSprint(); clearAttacks(); clearTarget()
	end
	lobby.setSuppressed(opened)
end, function(message) hud.showFeedback(message) end)
require(script.AdvancedSkillVisual).start()
growthGui = require(script.HeroGrowthGui).create(function(opened)
	if opened then
		if inventory.isOpen() then inventory.close() end
		endBlock(); endSprint(); clearAttacks(); clearTarget()
	end
	lobby.setSuppressed(opened)
end)
hud.back.Activated:Connect(function() requestHero("ReturnLobby") end)
hud.heroMenu.Activated:Connect(function() growthGui.open("Stats") end)
hud.bagMenu.Activated:Connect(function() inventory.open() end)

local function updateSessionView()
	local phase=player:GetAttribute("K0SessionPhase")
	local playing = phase == "Tutorial" or phase=="Respawning"
	if phase=="Respawning" then
		if inventory and inventory.isOpen() then inventory.close() end
		if growthGui and growthGui.isOpen() then growthGui.close() end
	end
	hud.setVisible(playing)
	if not playing then endBlock(); endSprint(); clearAttacks(); clearTarget() end
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
		if inventory then inventory.refresh() end
		updateSessionView()
	end)
	requestHero("GetState")
end)

require(script.DeepwoodJournal).start(hud)
