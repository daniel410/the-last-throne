-- Presentation-only equipment. Class selection, ownership and combat stay with
-- their server owners; this adapter never grants a class or changes hit geometry.
local ServerStorage = game:GetService("ServerStorage")
local BowGeometry = require(game:GetService("ReplicatedStorage").Shared.ElfBowGeometry)
local ElfQuiver = require(script.Parent.ElfQuiverAppearance)
local FourFamily = require(game:GetService("ReplicatedStorage").Shared.FourFamilyWeaponVisuals)

local FourFamilyShields = require(game:GetService("ReplicatedStorage").Shared.FourFamilyShieldVisuals)

local Appearance = {}
local OWNED = "TLTPlayerWeaponPart"
local SHIELD_OWNED = "TLTPlayerShieldPart"
local SHIELD_SOURCE = "td:SwordsmanShield"
local SHIELD_MESH = "rbxassetid://86935256146675"
local SHIELD_TEXTURE = "rbxassetid://97596525220590"
local VERSION = 2
local SPECS = {
	knight = { template = "KnightSword", parts = { "Weapon" }, gripName = "SwordGrip", jointName = "K0SwordJoint", sourceKey = "td:v2:AzureOathblade" },
	elf = { template = "ElfBow", parts = { "Bow", "String", "NockedArrow" }, gripName = "WeaponGrip", jointName = "PlayerWeaponJoint", sourceKey = "td:ElfBow" },
	dwarf = { template = "DwarfAxe", parts = { "Weapon" }, gripName = "WeaponGrip", jointName = "PlayerWeaponJoint", sourceKey = "td:v2:Embercleaver:inward3" },
	mage = { gripName = "WeaponGrip", jointName = "PlayerWeaponJoint", sourceKey = "authored:WoodenStaff" },
}
for classId, spec in pairs(SPECS) do spec.classId = classId end

local function specFor(classId, definitionId)
 local base = SPECS[classId]
 if not base then return nil end
 local visual = type(definitionId) == "string" and FourFamily.models[definitionId]
 if not visual or visual.classId ~= classId then return base end
 local spec = table.clone(base)
 spec.template, spec.sourceKey = visual.template, visual.sourceKey
 spec.folderName, spec.definitionId = FourFamily.folderName, definitionId
 if classId == "mage" then spec.parts = {"Weapon"} end
 return spec
end

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
	local folder = ServerStorage:FindFirstChild(spec.folderName or "TDRefinedPlayerWeaponModels")
	assert(folder and folder:IsA("Folder"), "Missing ServerStorage.TDRefinedPlayerWeaponModels")
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
		if spec.classId == "dwarf" then
			for _, name in ipairs({"AxeCuttingEdge", "AxeCuttingDirection", "AxeFaceNormal"}) do
				assert(attachmentCopy(sourceGrip, grip, name), "Missing reviewed axe cutting marker: " .. name)
			end
		end
		if spec.classId == "elf" and spec.definitionId then
			for _, name in ipairs({"BowNockRest", "BowUpperRest", "BowLowerRest"}) do
				assert(attachmentCopy(sourceGrip, grip, name), "Missing Meshy bow geometry: " .. name)
			end
		end
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
			if spec.classId == "elf" and (name == "String" or name == "NockedArrow") then
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
			if spec.classId == "knight" then
				copy.Name = "SwordBlade"
				blade = copy
			end
		end
		if spec.classId == "elf" then BowGeometry.install(model,grip) end
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

function Appearance.build(classId, definitionId)
	local spec = specFor(classId, definitionId)
	if not spec then return nil, "unsupported_class" end
	local ok, result = pcall(function()
		return classId == "mage" and not spec.definitionId and buildStaff(spec) or buildTd(spec)
	end)
	if not ok then return nil, tostring(result) end
	result.model:SetAttribute("WeaponClassId", classId)
	result.model:SetAttribute("WeaponSourceKey", spec.sourceKey)
	result.model:SetAttribute("WeaponVisualVersion", VERSION)
	result.model:SetAttribute("WeaponDefinitionId", spec.definitionId)
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

local function attachedResult(model, classId, hand, definitionId)
	local spec = specFor(classId, definitionId)
	if classId=="elf" and model:GetAttribute("ElfBowRigVersion")~=BowGeometry.version then return nil end
	if model:GetAttribute("WeaponClassId") ~= classId or model:GetAttribute("WeaponSourceKey") ~= spec.sourceKey
		or model:GetAttribute("WeaponVisualVersion") ~= VERSION then return nil end
	local grip = model:FindFirstChild(spec.gripName)
	local joint = grip and grip:FindFirstChild(spec.jointName)
	if not grip or not grip:IsA("BasePart") or grip:GetAttribute(OWNED) ~= true
		or not joint or not joint:IsA("Motor6D") or joint.Part0 ~= hand or joint.Part1 ~= grip then return nil end
	if classId=="elf" and not BowGeometry.valid(model,grip) then return nil end
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
		-- Turn the held blade forward and another 20 degrees inward.
		-- Keep the palm position, tilt and original TD geometry unchanged.
		offset = offset * CFrame.Angles(math.rad(-35), 0, 0) * CFrame.Angles(0, math.rad(20), 0)
	end
	return offset
end

function Appearance.isAttached(appearanceModel, character, classId, hands)
	if not SPECS[classId] or not appearanceModel or not appearanceModel:IsA("Model")
		or not character or not character:IsA("Model") then return false end
	local hand = weaponHandFor(character, hands, classId)
 return hand ~= nil and attachedResult(appearanceModel, classId, hand, character:GetAttribute("TLTEquippedWeapon")) ~= nil
  and (classId~="elf" or ElfQuiver.valid(appearanceModel,character))
end

function Appearance.attachInto(appearanceModel, character, classId, hands)
	local definitionId = typeof(character) == "Instance" and character:IsA("Model") and character:GetAttribute("TLTEquippedWeapon") or nil
	local spec = specFor(classId, definitionId)
	if not spec then return nil, "unsupported_class" end
	if not appearanceModel or not appearanceModel:IsA("Model") or not character or not character:IsA("Model") then
		return nil, "invalid_character_or_appearance" end
	local hand = weaponHandFor(character, hands, classId)
	if not hand then return nil, classId == "elf" and "left_hand_not_ready" or "right_hand_not_ready" end
	local existing = attachedResult(appearanceModel, classId, hand, definitionId)
 if existing then
  if classId=="elf" then ElfQuiver.ensure(appearanceModel,character) else ElfQuiver.remove(appearanceModel) end
  return existing
 end
	local result, reason = Appearance.build(classId, definitionId)
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
		appearanceModel:SetAttribute("WeaponDefinitionId", spec.definitionId)
		appearanceModel:SetAttribute("ElfBowRigVersion",classId=="elf" and BowGeometry.version or nil)
		appearanceModel:SetAttribute("WeaponPartNames", table.concat(names, "|"))
		appearanceModel:SetAttribute("WeaponPartCount", #names)
		for _, child in ipairs(owned) do child:Destroy() end
  if classId=="elf" then ElfQuiver.ensure(appearanceModel,character) else ElfQuiver.remove(appearanceModel) end
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

local function shieldSpec(definitionId)
 local visual=type(definitionId)=='string' and FourFamilyShields.models[definitionId]
 if visual then return {folder=FourFamilyShields.folderName,template=visual.template,sourceKey=visual.sourceKey,meshId=visual.meshId,textureId=visual.textureId,taskId=visual.taskId,visualScale=FourFamilyShields.visualScale,definitionId=definitionId} end
 return {folder='TDKnightShieldModels',template='KnightShield',sourceKey=SHIELD_SOURCE,meshId=SHIELD_MESH,textureId=SHIELD_TEXTURE,visualScale=1}
end

local function buildShield(definitionId)
 local spec=shieldSpec(definitionId)
	local folder = ServerStorage:FindFirstChild(spec.folder)
	assert(folder and folder:IsA("Folder"), "Missing shield template folder: " .. spec.folder)
	local source = folder:FindFirstChild(spec.template)
	assert(source and source:IsA("Model"), "Missing shield template: " .. spec.template)
	if spec.definitionId then
  assert(source:GetAttribute('ShieldDefinitionId')==spec.definitionId and source:GetAttribute('MeshyTaskId')==spec.taskId,'Shield template provenance mismatch')
 end
 local sourceGrip = gripFor(source)
	local sourceShield = source:FindFirstChild("Shield")
	assert(sourceGrip, "Player shield requires PrimaryPart Grip")
	assert(sourceShield and sourceShield:IsA("MeshPart") and visualPart(sourceShield) and sourceShield.Archivable,
		"Player shield requires a valid direct Shield MeshPart")
	assert(sourceShield.MeshId == spec.meshId and sourceShield.TextureID == spec.textureId,
		"Shield must use its approved mesh and original color map")
	local count = 0
	for _, item in ipairs(source:GetDescendants()) do
		assert(not item:IsA("LuaSourceContainer"), "Executable content is not allowed in shield templates")
		if item:IsA("BasePart") then
			assert(item == sourceGrip or item == sourceShield, "Unexpected shield part: " .. item.Name)
			count = count + 1
		end
	end
	assert(count == 2, "Shield template must contain exactly Grip and Shield")
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
		assert(attachmentCopy(sourceGrip, grip, "GripSocket"), "Player shield requires Grip.GripSocket")
		local shield = sourceShield:Clone()
		for _, child in ipairs(shield:GetDescendants()) do
			if not child:IsA("SurfaceAppearance") then child:Destroy() end
		end
		shield:SetAttribute("SourceMeshId", sourceShield.MeshId)
		shield:SetAttribute("SourceTextureId", sourceShield.TextureID)
		-- Scale the visual around its back socket; the left-hand anchor stays fixed.
		local frame = sourceGrip.CFrame:ToObjectSpace(sourceShield.CFrame)
		shield.Size = sourceShield.Size * spec.visualScale
		shield.CFrame = CFrame.new(frame.Position * spec.visualScale) * frame.Rotation
		inert(shield)
		shield.Parent = model
		local weld = Instance.new("WeldConstraint")
		weld.Name = "ShieldVisualWeld"
		weld.Part0 = grip
		weld.Part1 = shield
		weld.Parent = shield
		model:SetAttribute("ShieldSourceKey", spec.sourceKey)
		model:SetAttribute("ShieldDefinitionId", spec.definitionId)
		model:SetAttribute("ShieldVisualScale", spec.visualScale)
		model:SetAttribute("ShieldVisualVersion", VERSION)
		return { model = model, grip = grip, shield = shield, sourceKey = spec.sourceKey, definitionId = spec.definitionId, visualScale = spec.visualScale }
	end)
	if not ok then model:Destroy(); error(result) end
	return result
end

function Appearance.buildShield(definitionId)
	local ok, result = pcall(buildShield, definitionId)
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

local function shieldAttachedResult(model, hand, definitionId)
 local spec=shieldSpec(definitionId)
	if model:GetAttribute("ShieldSourceKey") ~= spec.sourceKey or model:GetAttribute("ShieldVisualVersion") ~= VERSION
  or (model:GetAttribute("ShieldVisualScale") or 1) ~= spec.visualScale then return nil end
	local grip = ownedShieldPart(model, "ShieldGrip")
	local shield = ownedShieldPart(model, "Shield")
	if not grip or not grip:IsA("BasePart") or not shield or not shield:IsA("MeshPart") then return nil end
	local handWeld = grip:FindFirstChild("K0ShieldHandWeld")
	local visualWeld = shield:FindFirstChild("ShieldVisualWeld")
	if not handWeld or not handWeld:IsA("WeldConstraint") or not handWeld.Enabled or handWeld.Part0 ~= hand or handWeld.Part1 ~= grip
		or not visualWeld or not visualWeld:IsA("WeldConstraint") or not visualWeld.Enabled or visualWeld.Part0 ~= grip or visualWeld.Part1 ~= shield
		or shield.MeshId ~= spec.meshId or shield.TextureID ~= spec.textureId then return nil end
	local count = 0
	for _, child in ipairs(model:GetChildren()) do
		if child:GetAttribute(SHIELD_OWNED) == true then count = count + 1 end
	end
	if count ~= 2 then return nil end
	for _, part in ipairs({ grip, shield }) do
		if part.Anchored or not part.Massless or part.CanCollide or part.CanTouch or part.CanQuery then return nil end
	end
	return { model = model, grip = grip, shield = shield, joint = handWeld, sourceKey = spec.sourceKey, definitionId = spec.definitionId, visualScale = spec.visualScale }
end

function Appearance.isShieldAttached(appearanceModel, character, hands)
	if not appearanceModel or not appearanceModel:IsA("Model") or not character or not character:IsA("Model") then return false end
	local hand = leftHandFor(character, hands)
	return hand ~= nil and shieldAttachedResult(appearanceModel, hand, character:GetAttribute("TLTEquippedOffhand")) ~= nil
end

function Appearance.detachShield(appearanceModel)
	if not appearanceModel or not appearanceModel:IsA("Model") then return false end
	for _, child in ipairs(appearanceModel:GetChildren()) do
		if child:GetAttribute(SHIELD_OWNED) == true then child:Destroy() end
	end
	for _, name in ipairs({ "ShieldSourceKey", "ShieldVisualVersion", "UsesTdPlayerShield", "UsesFourFamilyShield", "ShieldDefinitionId", "ShieldVisualScale", "ShieldFallbackReason" }) do
		appearanceModel:SetAttribute(name, nil)
	end
	return true
end

function Appearance.attachShieldInto(appearanceModel, character, hands)
	if not appearanceModel or not appearanceModel:IsA("Model") or not character or not character:IsA("Model") then
		return nil, "invalid_character_or_appearance" end
	local hand = leftHandFor(character, hands)
	if not hand then return nil, "left_hand_not_ready" end
	local definitionId = character:GetAttribute("TLTEquippedOffhand")
	local existing = shieldAttachedResult(appearanceModel, hand, definitionId)
	if existing then return existing end
	local result, reason = Appearance.buildShield(definitionId)
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
		appearanceModel:SetAttribute("ShieldSourceKey", result.sourceKey)
		appearanceModel:SetAttribute("ShieldDefinitionId", result.definitionId)
		appearanceModel:SetAttribute("ShieldVisualScale", result.visualScale)
		appearanceModel:SetAttribute("UsesFourFamilyShield", result.definitionId ~= nil)
		appearanceModel:SetAttribute("ShieldVisualVersion", VERSION)
		appearanceModel:SetAttribute("UsesTdPlayerShield", result.definitionId == nil)
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
