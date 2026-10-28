-- Presentation-only K0 equipment. The historical module/model name is retained,
-- but the server's resolved class attribute selects the matching owned visual.
-- This module never selects a combat class or changes damage/hit geometry.
local Players = game:GetService("Players")
local WeaponAppearance = require(script.Parent.WeaponAppearance)

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
local SUPPORTED_CLASSES = { knight = true, elf = true, dwarf = true, mage = true }

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

local function buildAppearance(character, rightHand, leftHand, classId)
	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	model:SetAttribute(OWNED_ATTRIBUTE, true)
	model:SetAttribute("WeaponClassId", classId)
	model:SetAttribute("TemporaryVisual", classId == "knight")

	local ok, result = pcall(function()
		local weapon, reason = WeaponAppearance.attachInto(model, character, classId, { right = rightHand, left = leftHand })
		if not weapon then
			assert(classId == "knight", "K0 " .. classId .. " appearance is unavailable: " .. tostring(reason))
			-- Preserve a playable prototype if its reviewed source is absent,
			-- but make the fallback explicit to verification and development.
			model:SetAttribute("WeaponSourceKey", "temporary:K0Sword")
			model:SetAttribute("WeaponFallbackReason", reason)
			model:SetAttribute("UsesTdPlayerWeapon", false)
			warn("K0 is using temporary sword geometry: " .. tostring(reason))
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
		else
			model:SetAttribute("UsesTdPlayerWeapon", classId ~= "mage")
			model:SetAttribute("UsesAuthoredPlayerWeapon", classId == "mage")
		end

		if classId == "knight" then
			-- Only Knight's combat profile can guard. Other classes keep just
			-- their own held weapon rather than inheriting Knight equipment.
			local shieldResult, shieldReason = WeaponAppearance.attachShieldInto(model, character, { left = leftHand })
			if not shieldResult then
				model:SetAttribute("ShieldSourceKey", "temporary:K0Shield")
				model:SetAttribute("UsesTdPlayerShield", false)
				model:SetAttribute("ShieldFallbackReason", shieldReason)
				warn("K0 is using temporary shield geometry: " .. tostring(shieldReason))
				local shield = CFrame.new(-0.22, -leftHand.Size.Y / 2 + 0.22, -0.32)
					* CFrame.Angles(0, math.rad(-12), math.rad(-6))
				local function fallbackPart(name, size, frame, color, material, weldName)
					local part = makePart(model, leftHand, name, size, frame, color, material, weldName)
					part:SetAttribute("TLTPlayerShieldPart", true)
				end
				fallbackPart("ShieldRim", Vector3.new(1.35, 1.65, 0.18),
					shield, SILVER, Enum.Material.Metal, "K0ShieldHandWeld")
				fallbackPart("ShieldFace", Vector3.new(1.10, 1.39, 0.11),
					shield * CFrame.new(0, 0, -0.13), BLUE, Enum.Material.SmoothPlastic)
				fallbackPart("ShieldBand", Vector3.new(0.18, 1.32, 0.08),
					shield * CFrame.new(0, 0, -0.23), DEEP_BLUE, Enum.Material.SmoothPlastic)
				fallbackPart("ShieldEmblem", Vector3.new(0.31, 0.31, 0.10),
					shield * CFrame.new(0, 0, -0.28) * CFrame.Angles(0, 0, math.rad(45)),
					GOLD, Enum.Material.Metal)
			end
			model:SetAttribute("TemporaryVisual", not weapon or not shieldResult)
		end

		model.Parent = character
	end)
	if not ok then
		model:Destroy()
		warn("K0 " .. classId .. " appearance could not be attached: " .. tostring(result))
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
	if not rightHand or not rightHand:IsA("BasePart") then rightHand = nil end
	if not leftHand or not leftHand:IsA("BasePart") then leftHand = nil end
	return rightHand, leftHand
end

local function isAttached(model, rightHand, leftHand, classId)
	if model:GetAttribute("WeaponClassId") ~= classId then return false end
	local fallback = classId == "knight" and model:GetAttribute("WeaponSourceKey") == "temporary:K0Sword"
	if not fallback and not WeaponAppearance.isAttached(model, rightHand.Parent, classId, { right = rightHand, left = leftHand }) then return false end
	if classId ~= "knight" then return model:FindFirstChild("K0ShieldHandWeld", true) == nil end
	local swordWeld = model:FindFirstChild("K0SwordJoint", true)
	local shieldWeld = model:FindFirstChild("K0ShieldHandWeld", true)
	local blade = model:FindFirstChild("SwordBlade")
	if model:GetAttribute("UsesTdPlayerShield") == true
		and not WeaponAppearance.isShieldAttached(model, rightHand.Parent, { left = leftHand }) then return false end
	if model:GetAttribute("UsesTdPlayerShield") ~= true then
		for _, name in ipairs({ "ShieldRim", "ShieldFace", "ShieldBand", "ShieldEmblem" }) do
			local part = model:FindFirstChild(name)
			if not part or not part:IsA("BasePart") or part:GetAttribute("TLTPlayerShieldPart") ~= true then return false end
		end
	end
	return swordWeld ~= nil and swordWeld:IsA("Motor6D") and swordWeld.Part0 == rightHand
		and swordWeld.Part1 ~= nil and swordWeld.Part1:IsDescendantOf(model)
		and blade ~= nil and blade:IsA("BasePart") and shieldWeld ~= nil and shieldWeld:IsA("WeldConstraint")
		and shieldWeld.Part0 == leftHand and shieldWeld.Part1 ~= nil and shieldWeld.Part1:IsDescendantOf(model)
end

local function syncAppearance(character)
	if syncing[character] then return end
	syncing[character] = true
	local ok, err = pcall(function()
		-- CombatService resolves the class from server-owned state and writes
		-- this presentation attribute. A missing/unsupported value is not a
		-- request to guess Knight; wait for that server decision instead.
		local classId = character:GetAttribute("K0ClassId")
		local supported = type(classId) == "string" and SUPPORTED_CLASSES[classId] == true
		local rightHand, leftHand = findHands(character)
		local ready = supported and rightHand ~= nil and (classId ~= "knight" or leftHand ~= nil)
		local attached = false
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Model") and child.Name == MODEL_NAME and child:GetAttribute(OWNED_ATTRIBUTE) == true then
				if not attached and ready and isAttached(child, rightHand, leftHand, classId) then
					attached = true
				else
					child:Destroy()
				end
			end
		end
		if ready and not attached then
			buildAppearance(character, rightHand, leftHand, classId)
		end
	end)
	syncing[character] = nil
	if not ok then warn("K0 equipment appearance could not be synchronized: " .. tostring(err)) end
end

local function disconnectCharacter(binding)
	if binding.childAdded then binding.childAdded:Disconnect() end
	if binding.childRemoved then binding.childRemoved:Disconnect() end
	if binding.classChanged then binding.classChanged:Disconnect() end
	if binding.descendantRemoving then binding.descendantRemoving:Disconnect() end
	binding.childAdded = nil
	binding.childRemoved = nil
	binding.classChanged = nil
	binding.descendantRemoving = nil
	binding.syncToken = (binding.syncToken or 0) + 1
	binding.syncQueued = false
	binding.character = nil
end

local function watchCharacter(player, character)
	local binding = bindings[player]
	if not binding or player.Character ~= character then return end
	disconnectCharacter(binding)
	binding.character = character
	binding.childAdded = character.ChildAdded:Connect(function() syncAppearance(character) end)
	binding.childRemoved = character.ChildRemoved:Connect(function() syncAppearance(character) end)
	binding.classChanged = character:GetAttributeChangedSignal("K0ClassId"):Connect(function() syncAppearance(character) end)
	binding.descendantRemoving = character.DescendantRemoving:Connect(function(item)
		local cursor = item
		local owned = false
		while cursor and cursor ~= character do
			if cursor:IsA("Model") and cursor.Name == MODEL_NAME and cursor:GetAttribute(OWNED_ATTRIBUTE) == true then owned = true; break end
			cursor = cursor.Parent
		end
		if not owned or binding.syncQueued then return end
		binding.syncQueued = true
		local token = binding.syncToken
		-- DescendantRemoving fires before the old parent reference is cleared.
		-- Defer and coalesce so validation sees the final detached state and
		-- an old life cannot rebuild equipment after CharacterRemoving.
		task.defer(function()
			if bindings[player] ~= binding or binding.syncToken ~= token or binding.character ~= character then return end
			binding.syncQueued = false
			if player.Character == character then syncAppearance(character) end
		end)
	end)
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
