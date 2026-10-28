-- Temporary K0 visuals. These parts are presentation only and are not combat hitboxes.
local Players = game:GetService("Players")

local KnightAppearance = {}
local started = false
local bindings = {}
local syncing = {}

local MODEL_NAME = "TLT_K0_KnightAppearance"
local OWNED_ATTRIBUTE = "TLT_K0_KnightAppearance"
local SILVER = Color3.fromRGB(194, 205, 218)
local EDGE = Color3.fromRGB(231, 237, 243)
local BLUE = Color3.fromRGB(38, 85, 165)
local DEEP_BLUE = Color3.fromRGB(26, 48, 97)
local GOLD = Color3.fromRGB(217, 174, 73)
local GRIP = Color3.fromRGB(64, 48, 46)

local function makePart(model, anchor, name, size, offset, color, material, weldName)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CFrame = anchor.CFrame * offset
	part.Parent = model

	if weldName ~= false then
		local weld = Instance.new("WeldConstraint")
		weld.Name = weldName or (name .. "Weld")
		weld.Part0 = anchor
		weld.Part1 = part
		weld.Parent = part
	end
	return part
end

local function buildAppearance(character, rightHand, leftHand)
	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	model:SetAttribute(OWNED_ATTRIBUTE, true)
	model:SetAttribute("TemporaryVisual", true)

	local ok, result = pcall(function()
		-- The grip is at the bottom of either an R15 hand or an R6 arm.
		local sword = CFrame.new(0, -rightHand.Size.Y / 2 + 0.12, -0.08)
			* CFrame.Angles(0, 0, math.rad(-8))
		local grip = makePart(model, rightHand, "SwordGrip", Vector3.new(0.24, 0.64, 0.24),
			sword, GRIP, Enum.Material.SmoothPlastic, false)
		local swordJoint = Instance.new("Motor6D")
		swordJoint.Name = "K0SwordJoint"
		swordJoint.Part0 = rightHand
		swordJoint.Part1 = grip
		swordJoint.C0 = sword
		swordJoint.C1 = CFrame.new()
		swordJoint.Parent = grip
		makePart(model, grip, "SwordPommel", Vector3.new(0.3, 0.16, 0.3),
			CFrame.new(0, -0.38, 0), GOLD, Enum.Material.Metal)
		makePart(model, grip, "SwordGuard", Vector3.new(0.78, 0.14, 0.3),
			CFrame.new(0, 0.38, 0), GOLD, Enum.Material.Metal)
		makePart(model, grip, "SwordBlade", Vector3.new(0.38, 1.65, 0.16),
			CFrame.new(0, 1.27, 0), SILVER, Enum.Material.Metal)
		makePart(model, grip, "SwordEdge", Vector3.new(0.07, 1.55, 0.17),
			CFrame.new(0.205, 1.27, 0), EDGE, Enum.Material.Metal)

		-- A separate left-hand shield makes the guard direction visible in K0.
		local shield = CFrame.new(-0.22, -leftHand.Size.Y / 2 + 0.22, -0.32)
			* CFrame.Angles(0, math.rad(-12), math.rad(-6))
		makePart(model, leftHand, "ShieldRim", Vector3.new(1.35, 1.65, 0.18),
			shield, SILVER, Enum.Material.Metal, "K0ShieldHandWeld")
		makePart(model, leftHand, "ShieldFace", Vector3.new(1.10, 1.39, 0.11),
			shield * CFrame.new(0, 0, -0.13), BLUE, Enum.Material.SmoothPlastic)
		makePart(model, leftHand, "ShieldBand", Vector3.new(0.18, 1.32, 0.08),
			shield * CFrame.new(0, 0, -0.23), DEEP_BLUE, Enum.Material.SmoothPlastic)
		makePart(model, leftHand, "ShieldEmblem", Vector3.new(0.31, 0.31, 0.10),
			shield * CFrame.new(0, 0, -0.28) * CFrame.Angles(0, 0, math.rad(45)),
			GOLD, Enum.Material.Metal)

		model.Parent = character
	end)
	if not ok then
		model:Destroy()
		warn("K0 Knight appearance could not be attached: " .. tostring(result))
	end
end

local function findHands(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil, nil end
	local rightName, leftName
	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		rightName, leftName = "RightHand", "LeftHand"
	else
		rightName, leftName = "Right Arm", "Left Arm"
	end
	local rightHand = character:FindFirstChild(rightName)
	local leftHand = character:FindFirstChild(leftName)
	if not rightHand or not rightHand:IsA("BasePart") or not leftHand or not leftHand:IsA("BasePart") then
		return nil, nil
	end
	return rightHand, leftHand
end

local function isAttached(model, rightHand, leftHand)
	local swordWeld = model:FindFirstChild("K0SwordJoint", true)
	local shieldWeld = model:FindFirstChild("K0ShieldHandWeld", true)
	return swordWeld ~= nil and swordWeld:IsA("Motor6D") and swordWeld.Part0 == rightHand
		and swordWeld.Part1 ~= nil and shieldWeld ~= nil and shieldWeld:IsA("WeldConstraint")
		and shieldWeld.Part0 == leftHand and shieldWeld.Part1 ~= nil
end

local function syncAppearance(character)
	if syncing[character] then return end
	syncing[character] = true
	local ok, err = pcall(function()
		local rightHand, leftHand = findHands(character)
		local attached = false
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Model") and child.Name == MODEL_NAME and child:GetAttribute(OWNED_ATTRIBUTE) == true then
				if not attached and rightHand and leftHand and isAttached(child, rightHand, leftHand) then
					attached = true
				else
					child:Destroy()
				end
			end
		end
		if rightHand and leftHand and not attached then
			buildAppearance(character, rightHand, leftHand)
		end
	end)
	syncing[character] = nil
	if not ok then warn("K0 Knight appearance could not be synchronized: " .. tostring(err)) end
end

local function disconnectCharacter(binding)
	if binding.childAdded then binding.childAdded:Disconnect() end
	if binding.childRemoved then binding.childRemoved:Disconnect() end
	binding.childAdded = nil
	binding.childRemoved = nil
	binding.character = nil
end

local function watchCharacter(player, character)
	local binding = bindings[player]
	if not binding or player.Character ~= character then return end
	disconnectCharacter(binding)
	binding.character = character
	binding.childAdded = character.ChildAdded:Connect(function() syncAppearance(character) end)
	binding.childRemoved = character.ChildRemoved:Connect(function() syncAppearance(character) end)
	syncAppearance(character)
end

local function bindPlayer(player)
	if bindings[player] then return end
	local binding = {}
	bindings[player] = binding
	binding.characterAdded = player.CharacterAdded:Connect(function(character)
		watchCharacter(player, character)
	end)
	binding.characterRemoving = player.CharacterRemoving:Connect(function(character)
		if binding.character == character then disconnectCharacter(binding) end
	end)
	if player.Character then watchCharacter(player, player.Character) end
end

local function unbindPlayer(player)
	local binding = bindings[player]
	if not binding then return end
	disconnectCharacter(binding)
	binding.characterAdded:Disconnect()
	binding.characterRemoving:Disconnect()
	bindings[player] = nil
end

function KnightAppearance.start()
	if started then return end
	started = true
	Players.PlayerAdded:Connect(bindPlayer)
	Players.PlayerRemoving:Connect(unbindPlayer)
	for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return KnightAppearance
