-- Weapon presentation driven by server combat attributes. Dwarf axes and Mage
-- staves stay in the hand. Elf arrows are local, non-colliding visual effects;
-- this module never chooses a class or determines damage or hit geometry.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Visual = {}
local started = false
local effects = {}
local seenShots = {}
local arrows = {}
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

local function swordEffect(model, joint)
	local blade = model:FindFirstChild("SwordBlade")
	if not blade or not blade:IsA("BasePart") then clearEffect(model); return nil end
	local previous = effects[model]
	if previous and previous.joint == joint and previous.blade == blade and previous.trail.Parent == blade then return previous end
	clearEffect(model)
	local bottom = blade:FindFirstChild("K0TrailBottom")
	if not bottom or not bottom:IsA("Attachment") then
		bottom = Instance.new("Attachment")
		bottom.Name = "K0TrailBottom"
		bottom.Position = Vector3.new(0, -blade.Size.Y / 2, 0)
		bottom.Parent = blade
	end
	local top = blade:FindFirstChild("K0TrailTop")
	if not top or not top:IsA("Attachment") then
		top = Instance.new("Attachment")
		top.Name = "K0TrailTop"
		top.Position = Vector3.new(0, blade.Size.Y / 2, 0)
		top.Parent = blade
	end
	local trail = Instance.new("Trail")
	trail.Name = "K0SwordTrail"
	trail.Attachment0, trail.Attachment1 = bottom, top
	trail.Lifetime = 0.15
	trail.LightEmission = 0.6
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 235, 171), Color3.fromRGB(114, 183, 255))
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 1) })
	trail.Enabled = false
	trail.Parent = blade
	local effect = { joint = joint, blade = blade, trail = trail }
	effects[model] = effect
	return effect
end

function Visual.samplePose(classId, phase, combo)
	local spec = MELEE[classId]
	if not spec then return nil end
	if spec.bow then
		if phase == "Windup" then return CFrame.Angles(math.rad(-12), 0, math.rad(-12)) end
		if phase == "Active" then return CFrame.Angles(math.rad(5), 0, math.rad(4)) end
		return CFrame.new()
	end
	local side = combo == 2 and -1 or 1
	if phase == "Windup" then
		return CFrame.Angles(math.rad(spec.windup), 0, math.rad(-25 * side))
	elseif phase == "Active" then
		return CFrame.Angles(math.rad(spec.active), 0, math.rad(spec.side * side))
	elseif phase == "Recovery" then
		return CFrame.Angles(math.rad(spec.recovery), 0, 0)
	end
	return CFrame.new()
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
				arrow.model:Destroy()
				table.remove(arrows, index)
			end
		end
	end
end

local function bowOrigin(character, snapshotOrigin, endpoint)
	for _, model in ipairs(character:GetChildren()) do
		if model:IsA("Model") and classFor(model) == "elf" then
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
	if first then emitArrow(character, bowOrigin(character, first, last), last, payload) end
end

-- Native fixtures may call this directly without installing a class-selection
-- flow or making a preview character a persistent RPG character.
function Visual.render(model, phase, combo, dt)
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
	local target = Visual.samplePose(classId, phase, combo)
	joint.Transform = joint.Transform:Lerp(target, math.clamp(elapsed * 22, 0, 1))
	if classId == "knight" then
		local effect = swordEffect(model, joint)
		if effect then effect.trail.Enabled = phase == "Active" end
	else
		clearEffect(model)
	end
	return true
end

function Visual.renderCharacter(character, dt)
	local classId = character:GetAttribute("K0ClassId") or "knight"
	if classId == "elf" then consumeArrow(character) end
	local rendered = 0
	for _, model in ipairs(character:GetChildren()) do
		if model:IsA("Model") and classFor(model) == classId then
			if Visual.render(model, character:GetAttribute("K0AttackPhase"), character:GetAttribute("K0Combo"), dt) then
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
	RunService.RenderStepped:Connect(function(dt)
		advanceArrows(dt)
		for model in pairs(effects) do
			if not model:IsDescendantOf(game) then clearEffect(model) end
		end
		for character in pairs(seenShots) do
			if not character:IsDescendantOf(game) then seenShots[character] = nil end
		end
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then Visual.renderCharacter(player.Character, dt) end
		end
	end)
end

return Visual
