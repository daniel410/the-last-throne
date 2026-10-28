-- Presentation-only equipment. Class selection, ownership and combat stay with
-- their server owners; this adapter never grants a class or changes hit geometry.
local ServerStorage = game:GetService("ServerStorage")

local Appearance = {}
local OWNED = "TLTPlayerWeaponPart"
local SHIELD_OWNED = "TLTPlayerShieldPart"
local SHIELD_SOURCE = "td:SwordsmanShield"
local SHIELD_MESH = "rbxassetid://86935256146675"
local SHIELD_TEXTURE = "rbxassetid://97596525220590"
local VERSION = 1
local SPECS = {
	knight = { template = "KnightSword", parts = { "Weapon" }, gripName = "SwordGrip", jointName = "K0SwordJoint", sourceKey = "td:KnightSword" },
	elf = { template = "ElfBow", parts = { "Bow", "String", "NockedArrow" }, gripName = "WeaponGrip", jointName = "PlayerWeaponJoint", sourceKey = "td:ElfBow" },
	dwarf = { template = "DwarfAxe", parts = { "Weapon" }, gripName = "WeaponGrip", jointName = "PlayerWeaponJoint", sourceKey = "td:DwarfAxe" },
	mage = { gripName = "WeaponGrip", jointName = "PlayerWeaponJoint", sourceKey = "authored:WoodenStaff" },
}

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < 10000
end

local function validFrame(frame)
	for _, value in ipairs({ frame:GetComponents() }) do
		if not finite(value) then return false end
	end
	return true
end

local function visualPart(part)
	return part:IsA("BasePart") and finite(part.Size.X) and finite(part.Size.Y) and finite(part.Size.Z)
		and part.Size.X > 0 and part.Size.Y > 0 and part.Size.Z > 0 and validFrame(part.CFrame)
end

local function inert(part)
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
end

local function gripFor(model)
	local grip = model:FindFirstChild("Grip")
	if not grip or not visualPart(grip) or model.PrimaryPart ~= grip then return nil end
	return grip
end

local function attachmentCopy(sourceGrip, targetGrip, name)
	local source = sourceGrip:FindFirstChild(name)
	if not source then return nil end
	assert(source:IsA("Attachment") and validFrame(source.CFrame), "Invalid weapon attachment: " .. name)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.CFrame = source.CFrame
	attachment.Parent = targetGrip
	return attachment
end

local function marker(source, name)
	local value = source:GetAttribute(name)
	if value ~= nil then return value end
	local child = source:FindFirstChild(name)
	if child and (child:IsA("Vector3Value") or child:IsA("NumberValue") or child:IsA("StringValue")) then return child.Value end
	return nil
end

local function addSwordTrail(blade)
	-- Templates already use the grip as their origin and +Y as the blade axis.
	-- Do not apply TD's old import rotation/scale a second time. Only the visual
	-- trail uses these bounds; server range and target selection remain unchanged.
	local highest = -math.huge
	for _, x in ipairs({ -1, 1 }) do
		for _, y in ipairs({ -1, 1 }) do
			for _, z in ipairs({ -1, 1 }) do
				local corner = blade.CFrame:PointToWorldSpace(Vector3.new(blade.Size.X * x / 2, blade.Size.Y * y / 2, blade.Size.Z * z / 2))
				highest = math.max(highest, corner.Y)
			end
		end
	end
	assert(finite(highest) and highest > 0, "Sword blade does not extend above its grip")
	for _, endpoint in ipairs({ { "K0TrailBottom", 0 }, { "K0TrailTop", highest } }) do
		local attachment = Instance.new("Attachment")
		attachment.Name = endpoint[1]
		attachment.Position = blade.CFrame:PointToObjectSpace(Vector3.new(0, endpoint[2], 0))
		attachment.Parent = blade
	end
end

local function buildTd(spec)
	local folder = ServerStorage:FindFirstChild("TDPlayerWeaponModels")
	assert(folder and folder:IsA("Folder"), "Missing ServerStorage.TDPlayerWeaponModels")
	local source = folder:FindFirstChild(spec.template)
	assert(source and source:IsA("Model"), "Missing TD weapon template: " .. spec.template)
	local sourceGrip = gripFor(source)
	assert(sourceGrip, "TD weapon requires a valid PrimaryPart named Grip: " .. spec.template)
	local allowed = {}
	for _, name in ipairs(spec.parts) do allowed[name] = true end
	local count = 0
	for _, item in ipairs(source:GetDescendants()) do
		assert(not item:IsA("LuaSourceContainer"), "Executable content is not allowed in TD weapon templates")
		if item:IsA("BasePart") and item ~= sourceGrip then
			assert(item.Parent == source and item:IsA("MeshPart") and allowed[item.Name], "Unexpected TD weapon part: " .. item.Name)
			assert(visualPart(item) and item.Archivable and item.MeshId ~= "", "Invalid TD weapon mesh: " .. item.Name)
			count = count + 1
		end
	end
	assert(count == #spec.parts, "TD weapon template has missing or duplicate parts")
	local model = Instance.new("Model")
	model.Name = spec.template
	local ok, result = pcall(function()
		local grip = Instance.new("Part")
		grip.Name = "Grip"
		grip.Size = Vector3.new(0.12, 0.12, 0.12)
		grip.CFrame = CFrame.new()
		grip.Transparency = 1
		grip.CastShadow = false
		inert(grip)
		grip.Parent = model
		model.PrimaryPart = grip
		attachmentCopy(sourceGrip, grip, "GripSocket")
		local tip = attachmentCopy(sourceGrip, grip, "WeaponTip")
		if not tip then
			local position = marker(source, "WeaponTip") or marker(source, "WeaponTipPosition")
			if position ~= nil then
				assert(typeof(position) == "Vector3" and finite(position.X) and finite(position.Y) and finite(position.Z), "Invalid TD weapon tip")
				tip = Instance.new("Attachment")
				tip.Name = "WeaponTip"
				tip.Position = sourceGrip.CFrame:PointToObjectSpace(position)
				tip.Parent = grip
			end
		end
		local blade
		for _, name in ipairs(spec.parts) do
			local original = source:FindFirstChild(name)
			assert(original and original:IsA("MeshPart"), "Missing TD weapon mesh: " .. name)
			local copy = original:Clone()
			-- Copy reviewed geometry/PBR only. Neither scripts nor source welds,
			-- metadata instances or remote references enter the character.
			for _, child in ipairs(copy:GetDescendants()) do
				if not child:IsA("SurfaceAppearance") then child:Destroy() end
			end
			copy:SetAttribute("SourcePartName", original.Name)
			copy:SetAttribute("SourceMeshId", original.MeshId)
			copy:SetAttribute("SourceTextureId", original.TextureID)
			copy.CFrame = sourceGrip.CFrame:ToObjectSpace(original.CFrame)
			inert(copy)
			copy.Parent = model
			if spec.template == "ElfBow" and (name == "String" or name == "NockedArrow") then
				-- The original string and arrow retain their geometry and grip
				-- offsets. A local-only Transform can now show the draw/release.
				local joint = Instance.new("Motor6D")
				joint.Name = name .. "VisualJoint"
				joint.Part0, joint.Part1 = grip, copy
				joint.C0 = copy.CFrame
				joint.C1 = CFrame.new()
				joint.Parent = copy
			else
				local weld = Instance.new("WeldConstraint")
				weld.Name = name .. "VisualWeld"
				weld.Part0 = grip
				weld.Part1 = copy
				weld.Parent = copy
			end
			if spec.template == "KnightSword" then
				copy.Name = "SwordBlade"
				blade = copy
			end
		end
		if blade then addSwordTrail(blade) end
		return { model = model, grip = grip, trailPart = blade, tip = tip, sourceKey = spec.sourceKey }
	end)
	if not ok then model:Destroy(); error(result) end
	return result
end

local function buildStaff(spec)
	local module = script.Parent:FindFirstChild("WoodenStaffBuilder")
	assert(module and module:IsA("ModuleScript"), "Missing WoodenStaffBuilder")
	local builder = require(module)
	assert(type(builder) == "table" and type(builder.build) == "function", "WoodenStaffBuilder.build is required")
	local model = builder.build()
	assert(typeof(model) == "Instance" and model:IsA("Model") and model.Parent == nil, "Staff builder must return an unparented Model")
	local ok, result = pcall(function()
		local grip = gripFor(model)
		assert(grip, "Staff builder requires PrimaryPart Grip")
		for _, item in ipairs(model:GetDescendants()) do
			assert(not item:IsA("LuaSourceContainer"), "Executable content is not allowed inside a staff")
			if item:IsA("BasePart") then
				assert(visualPart(item), "Invalid staff part: " .. item.Name)
				inert(item)
			end
		end
		local tip = grip:FindFirstChild("WeaponTip")
		assert(tip and tip:IsA("Attachment") and validFrame(tip.CFrame), "Staff builder requires Grip.WeaponTip")
		return { model = model, grip = grip, tip = tip, sourceKey = spec.sourceKey }
	end)
	if not ok then model:Destroy(); error(result) end
	return result
end

function Appearance.build(classId)
	local spec = SPECS[classId]
	if not spec then return nil, "unsupported_class" end
	local ok, result = pcall(function()
		if classId == "mage" then return buildStaff(spec) end
		return buildTd(spec)
	end)
	if not ok then return nil, tostring(result) end
	result.model:SetAttribute("WeaponClassId", classId)
	result.model:SetAttribute("WeaponSourceKey", spec.sourceKey)
	result.model:SetAttribute("WeaponVisualVersion", VERSION)
	return result
end

local function rightHandFor(character, hands)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local name = humanoid.RigType == Enum.HumanoidRigType.R15 and "RightHand" or "Right Arm"
	local hand = character:FindFirstChild(name)
	if not hand or not hand:IsA("BasePart") then return nil end
	if hands and hands.right ~= hand then return nil end
	return hand
end

local function weaponHandFor(character, hands, classId)
	if classId ~= "elf" then return rightHandFor(character, hands) end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local name = humanoid.RigType == Enum.HumanoidRigType.R15 and "LeftHand" or "Left Arm"
	local hand = character:FindFirstChild(name)
	if not hand or not hand:IsA("BasePart") or (hands and hands.left ~= hand) then return nil end
	return hand
end

local function attachedResult(model, classId, hand)
	local spec = SPECS[classId]
	if model:GetAttribute("WeaponClassId") ~= classId or model:GetAttribute("WeaponSourceKey") ~= spec.sourceKey
		or model:GetAttribute("WeaponVisualVersion") ~= VERSION then return nil end
	local grip = model:FindFirstChild(spec.gripName)
	local joint = grip and grip:FindFirstChild(spec.jointName)
	if not grip or not grip:IsA("BasePart") or grip:GetAttribute(OWNED) ~= true
		or not joint or not joint:IsA("Motor6D") or joint.Part0 ~= hand or joint.Part1 ~= grip then return nil end
	local names = model:GetAttribute("WeaponPartNames")
	local expectedCount = model:GetAttribute("WeaponPartCount")
	if type(names) ~= "string" or #names == 0 or #names > 2048
		or type(expectedCount) ~= "number" or expectedCount < 1 or expectedCount % 1 ~= 0 then return nil end
	local seen, count = {}, 0
	for name in string.gmatch(names, "[^|]+") do
		if seen[name] then return nil end
		seen[name] = true
		local part = model:FindFirstChild(name)
		if not part or not part:IsA("BasePart") or part:GetAttribute(OWNED) ~= true then return nil end
		if part ~= grip then
			local welded = false
			for _, item in ipairs(part:GetChildren()) do
				local movableBowPart = classId == "elf" and (name == "String" or name == "NockedArrow")
				if ((movableBowPart and item:IsA("Motor6D")) or (not movableBowPart and item:IsA("WeldConstraint")))
					and item.Part0 == grip and item.Part1 == part then welded = true; break end
			end
			if not welded then return nil end
		end
		count = count + 1
	end
	if count ~= expectedCount then return nil end
	local ownedCount = 0
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") and child:GetAttribute(OWNED) == true then ownedCount = ownedCount + 1 end
	end
	if ownedCount ~= expectedCount then return nil end
	for _, sourceName in ipairs(spec.parts or {}) do
		local name = classId == "knight" and "SwordBlade" or sourceName
		local part = model:FindFirstChild(name)
		if not part or not part:IsA("MeshPart") or not seen[name] then return nil end
	end
	local blade = classId == "knight" and model:FindFirstChild("SwordBlade") or nil
	if classId == "knight" and (not blade or not blade:IsA("MeshPart") or blade:GetAttribute(OWNED) ~= true) then return nil end
	if classId == "mage" then
		local tip = grip:FindFirstChild("WeaponTip")
		if not tip or not tip:IsA("Attachment") then return nil end
	end
	return { model = model, grip = grip, joint = joint, trailPart = blade, tip = grip:FindFirstChild("WeaponTip"), sourceKey = spec.sourceKey }
end

local function handPoseFor(hand, classId)
	-- Match TD HeroWeaponVisuals' authored hand pose, separately from the
	-- import normalization already present in the source templates.
	if classId == "knight" then
		-- The original sword's blade axis is +Y. Keep it upright in the hand
		-- and tip it toward character-forward (-Z) without a sideways lean.
		return CFrame.new(0, hand.Name == "Right Arm" and -0.95 or -0.12, -hand.Size.Z / 2)
			* CFrame.Angles(math.rad(-30), 0, 0)
	end
	if classId == "mage" then
		return CFrame.new(0, hand.Name == "Right Arm" and -0.95 or -0.12, -hand.Size.Z / 2)
			* CFrame.Angles(math.rad(-20), 0, math.rad(-8))
	end
	local offset = CFrame.new(0, (hand.Name == "Right Arm" or hand.Name == "Left Arm") and -0.95 or -0.12, -0.12)
		* CFrame.Angles(0, 0, math.rad(classId == "elf" and 0 or -23))
	if classId ~= "elf" then offset = offset * CFrame.new(0, 0, -hand.Size.Z / 2 + 0.12) end
	if classId == "dwarf" then
		-- Reverse the previously backward axe head while preserving its
		-- original TD mesh and grip-relative shape.
		offset = offset * CFrame.Angles(math.rad(-35), 0, 0) * CFrame.Angles(0, -math.pi / 2, 0)
	end
	return offset
end

function Appearance.isAttached(appearanceModel, character, classId, hands)
	if not SPECS[classId] or not appearanceModel or not appearanceModel:IsA("Model")
		or not character or not character:IsA("Model") then return false end
	local hand = weaponHandFor(character, hands, classId)
	return hand ~= nil and attachedResult(appearanceModel, classId, hand) ~= nil
end

function Appearance.attachInto(appearanceModel, character, classId, hands)
	local spec = SPECS[classId]
	if not spec then return nil, "unsupported_class" end
	if not appearanceModel or not appearanceModel:IsA("Model") or not character or not character:IsA("Model") then
		return nil, "invalid_character_or_appearance" end
	local hand = weaponHandFor(character, hands, classId)
	if not hand then return nil, classId == "elf" and "left_hand_not_ready" or "right_hand_not_ready" end
	local existing = attachedResult(appearanceModel, classId, hand)
	if existing then return existing end
	local result, reason = Appearance.build(classId)
	if not result then return nil, reason end
	local owned = {}
	for _, child in ipairs(appearanceModel:GetChildren()) do
		if child:GetAttribute(OWNED) == true then table.insert(owned, child) end
	end
	local inserted = {}
	local ok, err = pcall(function()
		-- This is the hand-to-grip pose only. The authored local coordinates
		-- remain unchanged; the mesh is not re-scaled or import-rotated.
		local offset = handPoseFor(hand, classId)
		local target = hand.CFrame * offset
		local frames = {}
		for _, item in ipairs(result.model:GetDescendants()) do
			if item:IsA("BasePart") then frames[item] = result.grip.CFrame:ToObjectSpace(item.CFrame) end
		end
		for part, frame in pairs(frames) do part.CFrame = target * frame end
		result.grip.Name = spec.gripName
		local joint = Instance.new("Motor6D")
		joint.Name = spec.jointName
		joint.Part0 = hand
		joint.Part1 = result.grip
		joint.C0 = offset
		joint.C1 = CFrame.new()
		joint.Parent = result.grip
		result.joint = joint
		local names = {}
		for _, child in ipairs(result.model:GetChildren()) do
			child:SetAttribute(OWNED, true)
			child.Parent = appearanceModel
			table.insert(inserted, child)
			if child:IsA("BasePart") then
				assert(not string.find(child.Name, "|", 1, true), "Weapon part names must not contain a separator")
				table.insert(names, child.Name)
			end
		end
		table.sort(names)
		appearanceModel:SetAttribute("WeaponClassId", classId)
		appearanceModel:SetAttribute("WeaponSourceKey", spec.sourceKey)
		appearanceModel:SetAttribute("WeaponVisualVersion", VERSION)
		appearanceModel:SetAttribute("WeaponPartNames", table.concat(names, "|"))
		appearanceModel:SetAttribute("WeaponPartCount", #names)
		for _, child in ipairs(owned) do child:Destroy() end
	end)
	result.model:Destroy()
	if not ok then
		for _, child in ipairs(inserted) do child:Destroy() end
		return nil, tostring(err)
	end
	result.model = appearanceModel
	return result
end

local function leftHandFor(character, hands)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end
	local name = humanoid.RigType == Enum.HumanoidRigType.R15 and "LeftHand" or "Left Arm"
	local hand = character:FindFirstChild(name)
	if not hand or not hand:IsA("BasePart") then return nil end
	if hands and hands.left ~= hand then return nil end
	return hand
end

local function buildShield()
	local folder = ServerStorage:FindFirstChild("TDKnightShieldModels")
	assert(folder and folder:IsA("Folder"), "Missing ServerStorage.TDKnightShieldModels")
	local source = folder:FindFirstChild("KnightShield")
	assert(source and source:IsA("Model"), "Missing TD KnightShield template")
	local sourceGrip = gripFor(source)
	local sourceShield = source:FindFirstChild("Shield")
	assert(sourceGrip, "TD shield requires PrimaryPart Grip")
	assert(sourceShield and sourceShield:IsA("MeshPart") and visualPart(sourceShield) and sourceShield.Archivable,
		"TD shield requires a valid direct Shield MeshPart")
	assert(sourceShield.MeshId == SHIELD_MESH and sourceShield.TextureID == SHIELD_TEXTURE,
		"TD shield must use the approved extracted shield mesh and original color map")
	local count = 0
	for _, item in ipairs(source:GetDescendants()) do
		assert(not item:IsA("LuaSourceContainer"), "Executable content is not allowed in shield templates")
		if item:IsA("BasePart") then
			assert(item == sourceGrip or item == sourceShield, "Unexpected TD shield part: " .. item.Name)
			count = count + 1
		end
	end
	assert(count == 2, "TD shield template must contain exactly Grip and Shield")
	local model = Instance.new("Model")
	model.Name = "KnightShield"
	local ok, result = pcall(function()
		local grip = Instance.new("Part")
		grip.Name = "Grip"
		grip.Size = Vector3.new(0.12, 0.12, 0.12)
		grip.CFrame = CFrame.new()
		grip.Transparency = 1
		grip.CastShadow = false
		inert(grip)
		grip.Parent = model
		model.PrimaryPart = grip
		assert(attachmentCopy(sourceGrip, grip, "GripSocket"), "TD shield requires Grip.GripSocket")
		local shield = sourceShield:Clone()
		for _, child in ipairs(shield:GetDescendants()) do
			if not child:IsA("SurfaceAppearance") then child:Destroy() end
		end
		shield:SetAttribute("SourceMeshId", sourceShield.MeshId)
		shield:SetAttribute("SourceTextureId", sourceShield.TextureID)
		-- Native Studio import already converted the original GLB front. The
		-- reviewed wrapper faces -Z and its center is behind the back socket
		-- along -Z; preserve that frame and scale exactly.
		shield.CFrame = sourceGrip.CFrame:ToObjectSpace(sourceShield.CFrame)
		inert(shield)
		shield.Parent = model
		local weld = Instance.new("WeldConstraint")
		weld.Name = "ShieldVisualWeld"
		weld.Part0 = grip
		weld.Part1 = shield
		weld.Parent = shield
		model:SetAttribute("ShieldSourceKey", SHIELD_SOURCE)
		model:SetAttribute("ShieldVisualVersion", VERSION)
		return { model = model, grip = grip, shield = shield, sourceKey = SHIELD_SOURCE }
	end)
	if not ok then model:Destroy(); error(result) end
	return result
end

function Appearance.buildShield()
	local ok, result = pcall(buildShield)
	if not ok then return nil, tostring(result) end
	return result
end

local function ownedShieldPart(model, name)
	local found
	for _, child in ipairs(model:GetChildren()) do
		if child.Name == name and child:GetAttribute(SHIELD_OWNED) == true then
			if found then return nil end
			found = child
		end
	end
	return found
end

local function shieldAttachedResult(model, hand)
	if model:GetAttribute("ShieldSourceKey") ~= SHIELD_SOURCE or model:GetAttribute("ShieldVisualVersion") ~= VERSION then return nil end
	local grip = ownedShieldPart(model, "ShieldGrip")
	local shield = ownedShieldPart(model, "Shield")
	if not grip or not grip:IsA("BasePart") or not shield or not shield:IsA("MeshPart") then return nil end
	local handWeld = grip:FindFirstChild("K0ShieldHandWeld")
	local visualWeld = shield:FindFirstChild("ShieldVisualWeld")
	if not handWeld or not handWeld:IsA("WeldConstraint") or not handWeld.Enabled or handWeld.Part0 ~= hand or handWeld.Part1 ~= grip
		or not visualWeld or not visualWeld:IsA("WeldConstraint") or not visualWeld.Enabled or visualWeld.Part0 ~= grip or visualWeld.Part1 ~= shield
		or shield.MeshId ~= SHIELD_MESH or shield.TextureID ~= SHIELD_TEXTURE then return nil end
	local count = 0
	for _, child in ipairs(model:GetChildren()) do
		if child:GetAttribute(SHIELD_OWNED) == true then count = count + 1 end
	end
	if count ~= 2 then return nil end
	for _, part in ipairs({ grip, shield }) do
		if part.Anchored or not part.Massless or part.CanCollide or part.CanTouch or part.CanQuery then return nil end
	end
	return { model = model, grip = grip, shield = shield, joint = handWeld, sourceKey = SHIELD_SOURCE }
end

function Appearance.isShieldAttached(appearanceModel, character, hands)
	if not appearanceModel or not appearanceModel:IsA("Model") or not character or not character:IsA("Model") then return false end
	local hand = leftHandFor(character, hands)
	return hand ~= nil and shieldAttachedResult(appearanceModel, hand) ~= nil
end

function Appearance.detachShield(appearanceModel)
	if not appearanceModel or not appearanceModel:IsA("Model") then return false end
	for _, child in ipairs(appearanceModel:GetChildren()) do
		if child:GetAttribute(SHIELD_OWNED) == true then child:Destroy() end
	end
	for _, name in ipairs({ "ShieldSourceKey", "ShieldVisualVersion", "UsesTdPlayerShield", "ShieldFallbackReason" }) do
		appearanceModel:SetAttribute(name, nil)
	end
	return true
end

function Appearance.attachShieldInto(appearanceModel, character, hands)
	if not appearanceModel or not appearanceModel:IsA("Model") or not character or not character:IsA("Model") then
		return nil, "invalid_character_or_appearance" end
	local hand = leftHandFor(character, hands)
	if not hand then return nil, "left_hand_not_ready" end
	local existing = shieldAttachedResult(appearanceModel, hand)
	if existing then return existing end
	local result, reason = Appearance.buildShield()
	if not result then return nil, reason end
	local owned = {}
	for _, child in ipairs(appearanceModel:GetChildren()) do
		if child:GetAttribute(SHIELD_OWNED) == true then table.insert(owned, child) end
	end
	local inserted = {}
	local ok, err = pcall(function()
		-- The shield's native front is -Z. Turn that face toward the
		-- character's left side while keeping its back socket at the hand.
		local offset = CFrame.new(-hand.Size.X / 2 - 0.02, hand.Name == "Left Arm" and -0.65 or 0, 0)
			* CFrame.Angles(0, math.rad(90), 0)
		local target = hand.CFrame * offset
		local frames = {}
		for _, item in ipairs(result.model:GetDescendants()) do
			if item:IsA("BasePart") then frames[item] = result.grip.CFrame:ToObjectSpace(item.CFrame) end
		end
		for part, frame in pairs(frames) do part.CFrame = target * frame end
		result.grip.Name = "ShieldGrip"
		local weld = Instance.new("WeldConstraint")
		weld.Name = "K0ShieldHandWeld"
		weld.Part0 = hand
		weld.Part1 = result.grip
		weld.Parent = result.grip
		result.joint = weld
		for _, child in ipairs(result.model:GetChildren()) do
			child:SetAttribute(SHIELD_OWNED, true)
			child.Parent = appearanceModel
			table.insert(inserted, child)
		end
		appearanceModel:SetAttribute("ShieldSourceKey", SHIELD_SOURCE)
		appearanceModel:SetAttribute("ShieldVisualVersion", VERSION)
		appearanceModel:SetAttribute("UsesTdPlayerShield", true)
		appearanceModel:SetAttribute("ShieldFallbackReason", nil)
		for _, child in ipairs(owned) do child:Destroy() end
	end)
	result.model:Destroy()
	if not ok then
		for _, child in ipairs(inserted) do child:Destroy() end
		return nil, tostring(err)
	end
	result.model = appearanceModel
	return result
end

return Appearance
