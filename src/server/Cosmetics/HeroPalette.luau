-- Apply only TD HeroSystem's torso/arm colors to an already loaded avatar.
-- The server-owned K0ClassId attribute is observed, never written or granted.
-- Clothing, accessories, face, body proportions, head and leg colors stay owned
-- by the avatar. A missing BodyColors instance is awaited, never synthesized.
local Players = game:GetService("Players")

local HeroPalette = {}
local started = false
local bindings = {}

-- Source: Throne Defense src/Shared/Config.lua HERO_CLASSES and
-- src/Server/HeroSystem.lua customizeCharacter. These are palette values,
-- not a claim that a custom TD hero body/rig has been installed.
local PALETTES = {
	knight = { torso = Color3.fromRGB(175, 180, 190), arms = Color3.fromRGB(55, 110, 215) },
	elf = { torso = Color3.fromRGB(70, 140, 70), arms = Color3.fromRGB(70, 140, 70) },
	dwarf = { torso = Color3.fromRGB(130, 90, 55), arms = Color3.fromRGB(200, 120, 50) },
	mage = { torso = Color3.fromRGB(90, 50, 140), arms = Color3.fromRGB(70, 40, 110) },
}

local function restoreColors(binding)
	local original = binding.original
	binding.original = nil
	if not original then return end
	-- The old instance can already be detached/destroying when Roblox changes
	-- characters. Restore that exact instance if still writable; never touch a
	-- replacement BodyColors object with a previous avatar's snapshot.
	local ok, reason = pcall(function()
		original.colors.TorsoColor3 = original.torso
		original.colors.LeftArmColor3 = original.leftArm
		original.colors.RightArmColor3 = original.rightArm
	end)
	if not ok then warn("Hero palette could not restore detached avatar colors: " .. tostring(reason)) end
end

local function clearCharacter(binding)
	for _, connection in ipairs(binding.characterConnections) do connection:Disconnect() end
	binding.characterConnections = {}
	restoreColors(binding)
	binding.character = nil
	binding.appearanceReady = false
	binding.syncing = false
end

local function ownsCurrentCharacter(binding, character)
	return bindings[binding.player] == binding and binding.player.Parent == Players
		and binding.character == character and binding.player.Character == character
end

local function syncColors(binding)
	local character = binding.character
	if not character or not ownsCurrentCharacter(binding, character) or binding.syncing then return end
	binding.syncing = true
	local ok, reason = pcall(function()
		local classId = character:GetAttribute("K0ClassId")
		local palette = type(classId) == "string" and PALETTES[classId] or nil
		if not binding.appearanceReady or not palette then
			restoreColors(binding)
			return
		end
		local colors = character:FindFirstChildOfClass("BodyColors")
		if binding.original and binding.original.colors ~= colors then restoreColors(binding) end
		if not colors then return end
		if not binding.original then
			binding.original = {
				colors = colors,
				torso = colors.TorsoColor3,
				leftArm = colors.LeftArmColor3,
				rightArm = colors.RightArmColor3,
			}
		end
		colors.TorsoColor3 = palette.torso
		colors.LeftArmColor3 = palette.arms
		colors.RightArmColor3 = palette.arms
	end)
	binding.syncing = false
	if not ok then warn("Hero palette could not synchronize avatar colors: " .. tostring(reason)) end
end

local function watchCharacter(binding, character)
	if bindings[binding.player] ~= binding or binding.player.Character ~= character then return end
	if binding.character == character then return end
	clearCharacter(binding)
	binding.character = character
	-- HasAppearanceLoaded is checked only against the actual current Character.
	-- This handles start() after the event while still protecting first loads.
	binding.appearanceReady = binding.player:HasAppearanceLoaded()
	local function changed()
		if ownsCurrentCharacter(binding, character) then syncColors(binding) end
	end
	table.insert(binding.characterConnections, character:GetAttributeChangedSignal("K0ClassId"):Connect(changed))
	table.insert(binding.characterConnections, character.ChildAdded:Connect(function(child)
		if child:IsA("BodyColors") then changed() end
	end))
	table.insert(binding.characterConnections, character.ChildRemoved:Connect(function(child)
		if child:IsA("BodyColors") then changed() end
	end))
	table.insert(binding.characterConnections, character.Destroying:Connect(function()
		if binding.character == character then clearCharacter(binding) end
	end))
	syncColors(binding)
end

local function bindPlayer(player)
	if bindings[player] then return end
	local binding = { player = player, character = nil, characterConnections = {}, original = nil, appearanceReady = false, syncing = false }
	bindings[player] = binding
	binding.characterAdded = player.CharacterAdded:Connect(function(character)
		watchCharacter(binding, character)
	end)
	binding.characterRemoving = player.CharacterRemoving:Connect(function(character)
		if binding.character == character then clearCharacter(binding) end
	end)
	binding.appearanceLoaded = player.CharacterAppearanceLoaded:Connect(function(character)
		-- An old life's late appearance event must not recolor a replacement.
		if not ownsCurrentCharacter(binding, character) then return end
		binding.appearanceReady = true
		syncColors(binding)
	end)
	if player.Character then watchCharacter(binding, player.Character) end
end

local function unbindPlayer(player)
	local binding = bindings[player]
	if not binding then return end
	clearCharacter(binding)
	bindings[player] = nil
	binding.characterAdded:Disconnect()
	binding.characterRemoving:Disconnect()
	binding.appearanceLoaded:Disconnect()
end

function HeroPalette.start()
	if started then return end
	started = true
	Players.PlayerAdded:Connect(bindPlayer)
	Players.PlayerRemoving:Connect(unbindPlayer)
	for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return HeroPalette
