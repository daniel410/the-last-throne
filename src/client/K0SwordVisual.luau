-- Weapon presentation driven by server combat attributes. Dwarf axes and Mage
-- staves stay in the hand. Elf arrows are local, non-colliding visual effects;
-- this module never chooses a class or determines damage or hit geometry.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Visual = {}
local started = false
local effects = {}
local seenShots = {}
local arrows = {}
local seenSpells = {}
local spells = {}
local bowRest = setmetatable({}, { __mode = "k" })
local armPoses = setmetatable({}, { __mode = "k" })
local weaponPoses = setmetatable({}, { __mode = "k" })
local MELEE = {
	knight = { grip = "SwordGrip", joint = "K0SwordJoint", windup = 38, active = -85, recovery = -10, side = 45 },
	dwarf = { grip = "WeaponGrip", joint = "PlayerWeaponJoint", windup = 58, active = -105, recovery = -15, side = 60 },
	mage = { grip = "WeaponGrip", joint = "PlayerWeaponJoint", windup = 32, active = -92, recovery = -8, side = 48 },
	elf = { grip = "WeaponGrip", joint = "PlayerWeaponJoint", bow = true },
}


local function classFor(model)
	local classId = model:GetAttribute("WeaponClassId")
	-- The explicitly marked temporary Knight fallback predates class metadata.
	if classId == nil and model.Name == "TLT_K0_KnightAppearance" then classId = "knight" end
	return classId
end

local function clearEffect(model)
	local previous = effects[model]
	if previous then
		previous.trail:Destroy()
		effects[model] = nil
	end
end

local function meleeEffect(model, joint, classId)
	local blade = classId == "knight" and model:FindFirstChild("SwordBlade") or joint.Part1
	if not blade or not blade:IsA("BasePart") then clearEffect(model); return nil end
	local previous = effects[model]
	if previous and previous.joint == joint and previous.blade == blade and previous.trail.Parent == blade then return previous end
	clearEffect(model)
	local bottom = blade:FindFirstChild("K0TrailBottom")
	if not bottom or not bottom:IsA("Attachment") then
		bottom = Instance.new("Attachment")
		bottom.Name = "K0TrailBottom"
		bottom.Position = classId == "knight" and Vector3.new(0, -blade.Size.Y / 2, 0) or Vector3.zero
		bottom.Parent = blade
	end
	local top = blade:FindFirstChild("K0TrailTop")
	if not top or not top:IsA("Attachment") then
		top = Instance.new("Attachment")
		top.Name = "K0TrailTop"
		local tip = blade:FindFirstChild("WeaponTip")
		top.Position = classId == "knight" and Vector3.new(0, blade.Size.Y / 2, 0)
			or (tip and tip:IsA("Attachment") and tip.Position or Vector3.new(0, 2.3, 0))
		top.Parent = blade
	end
	local trail = Instance.new("Trail")
	trail.Name = classId == "knight" and "K0SwordTrail" or "K0WeaponTrail"
	trail.Attachment0, trail.Attachment1 = bottom, top
	trail.Lifetime = 0.15
	trail.LightEmission = 0.6
	local colors = {
		knight = { Color3.fromRGB(255, 235, 171), Color3.fromRGB(114, 183, 255) },
		dwarf = { Color3.fromRGB(255, 221, 123), Color3.fromRGB(236, 123, 53) },
		mage = { Color3.fromRGB(225, 168, 255), Color3.fromRGB(103, 172, 255) },
	}
	local pair = colors[classId]
	trail.Color = ColorSequence.new(pair[1], pair[2])
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 1) })
	trail.Enabled = false
	trail.Parent = blade
	local effect = { joint = joint, blade = blade, trail = trail }
	effects[model] = effect
	return effect
end

function Visual.samplePose(classId, phase, combo, attackKind)
	local spec = MELEE[classId]
	if not spec then return nil end
	if spec.bow then
		-- Idle is lowered; the raised arm and this grip pose combine into an
		-- upright bow while drawing and releasing.
		if phase == "Windup" or phase == "Active" or phase == "Recovery" then
			return CFrame.Angles(math.rad(-70), 0, 0)
		end
		return CFrame.Angles(math.rad(-105), 0, math.rad(-8))
	end
	if classId == "mage" and attackKind == "Arcane" then
		if phase == "Windup" or phase == "Active" then return CFrame.Angles(math.rad(-145), 0, 0) end
		if phase == "Recovery" then return CFrame.Angles(math.rad(-90), 0, 0) end
		return CFrame.new()
	end
	local side = combo == 2 and -1 or 1
	if classId == "knight" then
		-- Combine with the raised shoulder and -30 degree hand pose: the
		-- blade points outward while sweeping across the forward arc.
		if phase == "Windup" then return CFrame.Angles(math.rad(-115), 0, math.rad(-35 * side)) end
		if phase == "Active" then return CFrame.Angles(math.rad(-125), 0, math.rad(35 * side)) end
		if phase == "Recovery" then return CFrame.Angles(math.rad(-55), 0, 0) end
		return CFrame.new()
	end
	if phase == "Windup" then
		return CFrame.Angles(math.rad(spec.windup), 0, math.rad(-25 * side))
	elseif phase == "Active" then
		return CFrame.Angles(math.rad(spec.active), 0, math.rad(spec.side * side))
	elseif phase == "Recovery" then
		return CFrame.Angles(math.rad(spec.recovery), 0, 0)
	end
	return CFrame.new()
end

local function shoulder(character, side)
	local joint = character:FindFirstChild(side .. "Shoulder", true)
		or character:FindFirstChild(side .. " Shoulder", true)
	if joint and (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) then return joint end
	return nil
end

-- Avatar arms are presentation-only. PreSimulation runs after animation
-- evaluation for both classic Motor6D and modern AnimationConstraint rigs.
function Visual.renderArms(character, dt)
	local classId = character:GetAttribute("K0ClassId")
	local mode = character:GetAttribute("K0State")
	local phase = character:GetAttribute("K0AttackPhase")
	local kind = character:GetAttribute("K0AttackKind")
	local right, left
	if classId == "knight" and mode == "Block" then
		left = CFrame.Angles(0, math.rad(-75), 0) * CFrame.Angles(math.rad(110), 0, 0)
	elseif mode == "Attack" and (phase == "Windup" or phase == "Active" or phase == "Recovery") then
		if classId == "elf" then
			right = CFrame.Angles(math.rad(70), 0, math.rad(-10))
			left = CFrame.Angles(math.rad(65), math.rad(-25), math.rad(15))
		elseif classId == "mage" and kind == "Arcane" then
			right = CFrame.Angles(math.rad(70), 0, math.rad(-8))
		elseif classId == "knight" then
			local pitch = phase == "Windup" and 55 or phase == "Active" and 65 or 20
			right = CFrame.Angles(math.rad(pitch), 0, 0)
		else
			local pitch = phase == "Windup" and -50 or phase == "Active" and 95 or 20
			local roll = classId == "dwarf" and 18 or 8
			right = CFrame.Angles(math.rad(pitch), 0, math.rad(phase == "Active" and roll or -roll))
		end
	end
	local elapsed = type(dt) == "number" and dt == dt and dt > 0 and dt < math.huge and math.min(dt, 0.1) or 1 / 60
	local function apply(joint, target)
		if not joint then return end
		local previous = armPoses[joint]
		if not target and not previous then return end
		local pose = previous and previous.pose or CFrame.new()
		local returning = target == nil and ((previous and previous.returning or 0) + elapsed) or 0
		pose = pose:Lerp(target or CFrame.new(), math.clamp(elapsed * 24, 0, 1))
		if not target and returning >= 0.25 then pose = CFrame.new(); armPoses[joint] = nil
		else armPoses[joint] = { pose = pose, returning = returning } end
		joint.Transform = pose
	end
	apply(shoulder(character, "Right"), right)
	apply(shoulder(character, "Left"), left)
end

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < 10000000
end

-- The entire shot is one server-published string to prevent combining two
-- replicated attribute updates. Nothing here sends targets or damage upstream.
local function decodeShot(payload)
	if type(payload) ~= "string" or #payload > 256 then return nil end
	local fields = string.split(payload, "|")
	if #fields ~= 7 then return nil end
	local values = {}
	for index, field in ipairs(fields) do
		values[index] = tonumber(field)
		if not finite(values[index]) then return nil end
	end
	if values[1] < 1 or values[1] % 1 ~= 0 then return nil end
	local first = Vector3.new(values[2], values[3], values[4])
	local last = Vector3.new(values[5], values[6], values[7])
	local length = (last - first).Magnitude
	if length < 0.05 or length > 55.1 then return nil end
	return first, last
end

local function arrowPart(model, name, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.Transparency = 0
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = model
	return part
end

local function emitArrow(character, first, last, payload)
	-- Keep presentation bounded even if a spectator observes many characters.
	if #arrows >= 32 then
		table.remove(arrows, 1).model:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = "K0VisualArrow"
	local shaft = arrowPart(model, "Shaft", Vector3.new(0.10, 0.10, 1.6), Color3.fromRGB(133, 86, 46), Enum.Material.Wood)
	local tip = arrowPart(model, "Arrowhead", Vector3.new(0.20, 0.20, 0.35), Color3.fromRGB(220, 226, 232), Enum.Material.Metal)
	local feather = arrowPart(model, "Fletching", Vector3.new(0.27, 0.06, 0.35), Color3.fromRGB(234, 234, 213), Enum.Material.SmoothPlastic)
	local tipTrail = Instance.new("Attachment"); tipTrail.Position = Vector3.new(0, 0, -0.5); tipTrail.Parent = shaft
	local tailTrail = Instance.new("Attachment"); tailTrail.Position = Vector3.new(0, 0, 0.5); tailTrail.Parent = shaft
	local trail = Instance.new("Trail")
	trail.Attachment0, trail.Attachment1 = tipTrail, tailTrail
	trail.Color = ColorSequence.new(Color3.fromRGB(170, 255, 178), Color3.fromRGB(255, 242, 180))
	trail.Transparency, trail.Lifetime, trail.LightEmission = NumberSequence.new(0.25), 0.16, 0.5
	trail.Parent = shaft
	local pose = CFrame.lookAt(first, last)
	shaft.CFrame = pose
	tip.CFrame = pose * CFrame.new(0, 0, -0.93)
	feather.CFrame = pose * CFrame.new(0, 0, 0.70)
	model.Parent = workspace
	local distance = (last - first).Magnitude
	local arrow = { model = model, shaft = shaft, tip = tip, feather = feather, character = character,
		owner = Players:GetPlayerFromCharacter(character), payload = payload,
		first = first, direction = (last - first).Unit, distance = distance, elapsed = 0,
		duration = math.clamp(distance / 100, 0.12, 0.55) }
	table.insert(arrows, arrow)
	return arrow
end

local function impact(position, color)
	local part = arrowPart(workspace, "K0VisualImpact", Vector3.new(0.35, 0.35, 0.35), color, Enum.Material.Neon)
	part.Shape, part.Position = Enum.PartType.Ball, position
	local tween = TweenService:Create(part, TweenInfo.new(0.24), { Size = Vector3.new(1.5, 1.5, 1.5), Transparency = 1 })
	tween:Play()
	task.delay(0.3, function() part:Destroy() end)
end

local function advanceArrows(dt)
	local elapsed = type(dt) == "number" and dt == dt and dt > 0 and dt < math.huge and math.min(dt, 0.1) or 1 / 60
	for index = #arrows, 1, -1 do
		local arrow = arrows[index]
		if not arrow.character:IsDescendantOf(workspace) or not arrow.model.Parent
			or arrow.character:GetAttribute("K0ClassId") ~= "elf"
			or arrow.character:GetAttribute("K0ArrowVisual") ~= arrow.payload
			or (arrow.owner and arrow.owner.Character ~= arrow.character) then
			arrow.model:Destroy()
			table.remove(arrows, index)
		else
			arrow.elapsed = arrow.elapsed + elapsed
			local position = arrow.first + arrow.direction * arrow.distance * math.min(1, arrow.elapsed / arrow.duration)
			local pose = CFrame.lookAt(position, position + arrow.direction)
			arrow.shaft.CFrame = pose
			arrow.tip.CFrame = pose * CFrame.new(0, 0, -0.93)
			arrow.feather.CFrame = pose * CFrame.new(0, 0, 0.70)
			if arrow.elapsed >= arrow.duration then
				impact(arrow.first + arrow.direction * arrow.distance, Color3.fromRGB(196, 255, 178))
				arrow.model:Destroy()
				table.remove(arrows, index)
			end
		end
	end
end

local function weaponOrigin(character, snapshotOrigin, endpoint, wantedClass)
	for _, model in ipairs(character:GetChildren()) do
		if model:IsA("Model") and classFor(model) == wantedClass then
			local grip = model:FindFirstChild("WeaponGrip")
			local tip = grip and grip:FindFirstChild("WeaponTip")
			local nocked = model:FindFirstChild("NockedArrow")
			local position
			if tip and tip:IsA("Attachment") and grip:IsA("BasePart") then
				position = tip.WorldPosition
			elseif nocked and nocked:IsA("BasePart") then
				position = nocked.Position
			elseif grip and grip:IsA("BasePart") then
				position = grip.Position
			end
			if position and finite(position.X) and finite(position.Y) and finite(position.Z)
				and (position - snapshotOrigin).Magnitude <= 8 and (position - endpoint).Magnitude >= 0.05
				and (endpoint - snapshotOrigin):Dot(endpoint - position) > 0 then
				return position
			end
		end
	end
	-- Missing or late weapon replication never changes the server shot.
	return snapshotOrigin
end

local function consumeArrow(character)
	local payload = character:GetAttribute("K0ArrowVisual")
	if payload == nil or seenShots[character] == payload then return end
	seenShots[character] = payload
	local first, last = decodeShot(payload)
	if first then emitArrow(character, weaponOrigin(character, first, last, "elf"), last, payload) end
end

local function consumeSpell(character)
	local payload = character:GetAttribute("K0SpellVisual")
	if payload == nil or seenSpells[character] == payload then return end
	seenSpells[character] = payload
	local first, last = decodeShot(payload)
	if not first then return end
	first = weaponOrigin(character, first, last, "mage")
	if #spells >= 32 then table.remove(spells, 1).part:Destroy() end
	local orb = arrowPart(workspace, "K0VisualArcaneBolt", Vector3.new(0.65, 0.65, 0.65), Color3.fromRGB(182, 111, 255), Enum.Material.Neon)
	orb.Shape, orb.Position = Enum.PartType.Ball, first
	local light = Instance.new("PointLight"); light.Color = orb.Color; light.Brightness = 2; light.Range = 8; light.Parent = orb
	local front = Instance.new("Attachment"); front.Position = Vector3.new(0, 0, -0.3); front.Parent = orb
	local back = Instance.new("Attachment"); back.Position = Vector3.new(0, 0, 0.3); back.Parent = orb
	local trail = Instance.new("Trail"); trail.Attachment0, trail.Attachment1 = front, back
	trail.Color = ColorSequence.new(Color3.fromRGB(224, 183, 255), Color3.fromRGB(99, 152, 255))
	trail.Transparency, trail.Lifetime, trail.LightEmission = NumberSequence.new(0.2), 0.25, 1
	trail.Parent = orb
	local distance = (last - first).Magnitude
	table.insert(spells, { part = orb, character = character, owner = Players:GetPlayerFromCharacter(character),
		payload = payload, first = first, direction = (last - first).Unit, distance = distance, elapsed = 0,
		duration = math.clamp(distance / 75, 0.15, 0.60) })
end

local function advanceSpells(dt)
	local elapsed = type(dt) == "number" and dt == dt and dt > 0 and dt < math.huge and math.min(dt, 0.1) or 1 / 60
	for index = #spells, 1, -1 do
		local spell = spells[index]
		if not spell.part.Parent or not spell.character:IsDescendantOf(workspace)
			or spell.character:GetAttribute("K0ClassId") ~= "mage"
			or spell.character:GetAttribute("K0SpellVisual") ~= spell.payload
			or (spell.owner and spell.owner.Character ~= spell.character) then
			spell.part:Destroy(); table.remove(spells, index)
		else
			spell.elapsed = spell.elapsed + elapsed
			local position = spell.first + spell.direction * spell.distance * math.min(1, spell.elapsed / spell.duration)
			spell.part.CFrame = CFrame.lookAt(position, position + spell.direction)
			if spell.elapsed >= spell.duration then
				impact(position, Color3.fromRGB(196, 144, 255))
				spell.part:Destroy(); table.remove(spells, index)
			end
		end
	end
end

local function drawBow(model, phase, elapsed)
	local stringPart, arrow = model:FindFirstChild("String"), model:FindFirstChild("NockedArrow")
	local stringJoint = stringPart and stringPart:FindFirstChild("StringVisualJoint")
	local arrowJoint = arrow and arrow:FindFirstChild("NockedArrowVisualJoint")
	if not stringPart or not stringPart:IsA("BasePart") or not stringJoint or not stringJoint:IsA("Motor6D")
		or not arrowJoint or not arrowJoint:IsA("Motor6D") then return end
	local state = bowRest[model]
	if not state or state.part ~= stringPart then
		state = { part = stringPart, size = stringPart.Size, draw = 0 }
		bowRest[model] = state
	end
	local target = phase == "Windup" and 0.48 or 0
	state.draw = state.draw + (target - state.draw) * math.clamp(elapsed * 22, 0, 1)
	stringPart.Size = Vector3.new(state.size.X, state.size.Y, state.size.Z + state.draw)
	stringJoint.Transform = CFrame.new(0, 0, state.draw / 2)
	arrowJoint.Transform = CFrame.new(0, 0, state.draw)
end

-- Native fixtures may call this directly without installing a class-selection
-- flow or making a preview character a persistent RPG character.
function Visual.render(model, phase, combo, dt, attackKind)
	local classId = classFor(model)
	local spec = MELEE[classId]
	if not spec then clearEffect(model); return false end
	local grip = model:FindFirstChild(spec.grip)
	local joint = grip and grip:FindFirstChild(spec.joint)
	if not grip or not grip:IsA("BasePart") or not joint or not joint:IsA("Motor6D") or joint.Part1 ~= grip then
		clearEffect(model)
		return false
	end
	local elapsed = type(dt) == "number" and dt == dt and dt > 0 and dt < math.huge and dt or 1 / 60
	local target = Visual.samplePose(classId, phase, combo, attackKind)
	local pose = (weaponPoses[joint] or CFrame.new()):Lerp(target, math.clamp(elapsed * 22, 0, 1))
	weaponPoses[joint] = pose
	joint.Transform = pose
	if classId == "elf" then
		drawBow(model, phase, elapsed)
		clearEffect(model)
	else
		local effect = meleeEffect(model, joint, classId)
		if effect then effect.trail.Enabled = phase == "Active" and attackKind ~= "Arcane" end
	end
	return true
end

function Visual.renderCharacter(character, dt)
	local classId = character:GetAttribute("K0ClassId") or "knight"
	if classId == "elf" then consumeArrow(character) end
	if classId == "mage" then consumeSpell(character) end
	local rendered = 0
	for _, model in ipairs(character:GetChildren()) do
		if model:IsA("Model") and classFor(model) == classId then
			if Visual.render(model, character:GetAttribute("K0AttackPhase"), character:GetAttribute("K0Combo"), dt, character:GetAttribute("K0AttackKind")) then
				rendered = rendered + 1
			end
		elseif model:IsA("Model") and effects[model] then
			clearEffect(model)
		end
	end
	return rendered
end

function Visual.start()
	if started then return end
	started = true
	RunService.PreSimulation:Connect(function(dt)
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then
				Visual.renderArms(player.Character, dt)
				Visual.renderCharacter(player.Character, dt)
			end
		end
	end)
	RunService.RenderStepped:Connect(function(dt)
		advanceArrows(dt)
		advanceSpells(dt)
		for model in pairs(effects) do
			if not model:IsDescendantOf(game) then clearEffect(model) end
		end
		for character in pairs(seenShots) do
			if not character:IsDescendantOf(game) then seenShots[character] = nil end
		end
		for character in pairs(seenSpells) do
			if not character:IsDescendantOf(game) then seenSpells[character] = nil end
		end
	end)
end

return Visual
