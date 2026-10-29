-- Presentation only: the server broadcasts confirmed health loss. Effects
-- never decide hits or damage and stay bounded on busy multiplayer clients.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local HitEffects = {}
local started = false
local active = {}
local lastSound = -math.huge
local MAX_ACTIVE = 24
local SOUND_COOLDOWN = 0.07

-- Existing TD prototype uses these built-in Roblox sounds for impacts. They
-- are temporary profiles, not uploaded or claimed as final custom audio.
local profiles = {
	knight = { color = Color3.fromRGB(255, 232, 150), secondary = Color3.fromRGB(255, 255, 240), sound = "rbxasset://sounds/action_jump_land.mp3", volume = 0.15, speed = 1.35 },
	dwarf = { color = Color3.fromRGB(255, 157, 65), secondary = Color3.fromRGB(255, 219, 132), sound = "rbxasset://sounds/action_jump_land.mp3", volume = 0.18, speed = 0.9 },
	mage = { color = Color3.fromRGB(190, 127, 255), secondary = Color3.fromRGB(237, 192, 255), sound = "rbxasset://sounds/impact_water.mp3", volume = 0.12, speed = 1.25 },
	elf = { color = Color3.fromRGB(173, 246, 161), secondary = Color3.fromRGB(247, 255, 224), sound = "rbxasset://sounds/action_jump_land.mp3", volume = 0.12, speed = 1.65 },
}

-- Skill-specific palettes and impact silhouettes. IDs are supplied by the
-- server's confirmed damage event; unknown IDs use the class baseline.
local skillProfiles = {
	["knight.common.bash"] = { class = "knight", color = Color3.fromRGB(255, 193, 82), secondary = Color3.fromRGB(255, 245, 190), shape = "shield" },
	["knight.common.whirlwind"] = { class = "knight", color = Color3.fromRGB(255, 219, 122), secondary = Color3.fromRGB(244, 251, 255), shape = "sweep" },
	["dwarf.common.overhead"] = { class = "dwarf", color = Color3.fromRGB(255, 151, 63), secondary = Color3.fromRGB(255, 224, 157), shape = "chop" },
	["dwarf.common.throw"] = { class = "dwarf", color = Color3.fromRGB(255, 182, 76), secondary = Color3.fromRGB(237, 241, 255), shape = "axe" },
	["dwarf.common.ground"] = { class = "dwarf", color = Color3.fromRGB(223, 125, 55), secondary = Color3.fromRGB(255, 214, 128), shape = "shockwave" },
	["elf.common.aimed"] = { class = "elf", color = Color3.fromRGB(231, 248, 156), secondary = Color3.fromRGB(255, 255, 226), shape = "precision" },
	["elf.common.rapid"] = { class = "elf", color = Color3.fromRGB(134, 237, 165), secondary = Color3.fromRGB(224, 255, 210), shape = "rapid" },
	["elf.common.multi"] = { class = "elf", color = Color3.fromRGB(111, 209, 187), secondary = Color3.fromRGB(210, 255, 230), shape = "multi" },
	["mage.common.mana_bolt"] = { class = "mage", color = Color3.fromRGB(129, 212, 255), secondary = Color3.fromRGB(225, 251, 255), shape = "mana" },
	["mage.common.water_ball"] = { class = "mage", color = Color3.fromRGB(69, 155, 255), secondary = Color3.fromRGB(174, 232, 255), shape = "water" },
	["mage.common.gravity"] = { class = "mage", color = Color3.fromRGB(126, 65, 211), secondary = Color3.fromRGB(214, 169, 255), shape = "gravity" },
}

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < 10000000
end

local function part(parent, name, position, size, color)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position, p.Color = name, size, position, color
	p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.CastShadow = true, false, false, false, false
	p.Material, p.Shape = Enum.Material.Neon, Enum.PartType.Ball
	p.Parent = parent
	return p
end

local function playSound(parent, profile)
	local current = os.clock()
	if current - lastSound < SOUND_COOLDOWN then return end
	lastSound = current
	local sound = Instance.new("Sound")
	sound.Name = "K0HitSound"
	sound.SoundId, sound.Volume, sound.PlaybackSpeed = profile.sound, profile.volume, profile.speed
	sound.RollOffMode, sound.RollOffMinDistance, sound.RollOffMaxDistance = Enum.RollOffMode.Linear, 8, 70
	sound.Parent = parent
	sound:Play()
end

-- Public for isolated native fixture QA; live calls come only from OnClientEvent.
function HitEffects.show(model, position, damage, classId, enemyKind, direction, skillId)
	local profile = profiles[classId]
	if not profile or typeof(position) ~= "Vector3" or not finite(position.X) or not finite(position.Y) or not finite(position.Z)
		or not finite(damage) or damage <= 0 or damage > 1000000 or type(enemyKind) ~= "string" then return false end
	if model ~= nil and (typeof(model) ~= "Instance" or not model:IsA("Model")) then return false end
	local skill = type(skillId) == "string" and skillProfiles[skillId] or nil
	if skill and skill.class == classId then
		profile = table.clone(profile)
		profile.color, profile.secondary = skill.color, skill.secondary
	else
		skill = nil
	end
	for i = #active, 1, -1 do if not active[i].Parent then table.remove(active, i) end end
	if #active >= MAX_ACTIVE then table.remove(active, 1):Destroy() end
	local holder = part(workspace, "K0HitEffect", position, Vector3.new(0.1, 0.1, 0.1), profile.color)
	holder.Transparency = 1
	if skill then holder:SetAttribute("K0SkillEffectId", skillId) end
	table.insert(active, holder)
	Debris:AddItem(holder, 1.2)
	local scale = enemyKind == "Ogre" and 1.3 or 1
	if model and model:GetAttribute("SlimeSplitGeneration") == 1 then scale = 0.7 end
	local flash = part(holder, "K0ImpactFlash", position, Vector3.one * 0.25 * scale, profile.secondary)
	TweenService:Create(flash, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.one * 1.1 * scale, Transparency = 1 }):Play()
	if model and model:IsDescendantOf(workspace) then
		local highlight = Instance.new("Highlight")
		highlight.Name, highlight.Adornee = "K0HitFlash", model
		highlight.FillColor, highlight.FillTransparency, highlight.OutlineTransparency = profile.secondary, 0.55, 1
		highlight.DepthMode, highlight.Parent = Enum.HighlightDepthMode.Occluded, holder
		TweenService:Create(highlight, TweenInfo.new(0.15), { FillTransparency = 1 }):Play()
	end
	if skill then
		local accent = part(holder, "K0SkillImpact", position, Vector3.new(0.12, 0.45, 0.45) * scale, skill.color)
		accent:SetAttribute("Style", skill.shape)
		local isRing = skill.shape == "shield" or skill.shape == "sweep" or skill.shape == "shockwave" or skill.shape == "gravity" or skill.shape == "water"
		if isRing then
			accent.Shape = Enum.PartType.Cylinder
			accent.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
			TweenService:Create(accent, TweenInfo.new(0.28), { Size = Vector3.new(0.12, 2.5, 2.5) * scale, Transparency = 1 }):Play()
		else
			accent.Shape = Enum.PartType.Block
			local flat = typeof(direction) == "Vector3" and finite(direction.X) and finite(direction.Z)
				and Vector3.new(direction.X, 0, direction.Z) or Vector3.new(0, 0, -1)
			if flat.Magnitude < 0.001 then flat = Vector3.new(0, 0, -1) end
			accent.Size = Vector3.new(0.12, skill.shape == "chop" and 2.4 or 1.4, 0.12) * scale
			accent.CFrame = CFrame.lookAt(position, position + flat) * CFrame.Angles(0, 0, math.rad(skill.shape == "chop" and 0 or 45))
			TweenService:Create(accent, TweenInfo.new(0.22), { Size = accent.Size * 1.35, Transparency = 1 }):Play()
		end
		if skill.shape == "water" then
			for index = 1, 6 do
				local angle = (index - 1) * math.pi / 3
				local splash = part(holder, "K0WaterSplash", position, Vector3.one * 0.22 * scale, Color3.fromRGB(128, 215, 255))
				splash.Material = Enum.Material.Glass
				local destination = position + Vector3.new(math.cos(angle) * 1.4, 0.8 + (index % 2) * 0.5, math.sin(angle) * 1.4) * scale
				TweenService:Create(splash, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = destination, Size = Vector3.one * 0.07 * scale, Transparency = 1 }):Play()
			end
		end
		if skill.shape == "rapid" or skill.shape == "multi" or skill.shape == "mana" or skill.shape == "water" or skill.shape == "gravity" or skill.shape == "shockwave" then
			for index = 1, 3 do
				local angle = (index - 1) * math.pi * 2 / 3
				local offset = Vector3.new(math.cos(angle), skill.shape == "water" and 0.8 or 0.2, math.sin(angle)) * scale
				local particle = part(holder, "K0SkillAccent", position + offset * 0.25, Vector3.one * 0.14 * scale, skill.secondary)
				if skill.shape ~= "water" and skill.shape ~= "gravity" then particle.Shape = Enum.PartType.Block end
				if skill.shape == "rapid" or skill.shape == "multi" then particle.Size = Vector3.new(0.07, 0.55, 0.07) * scale end
				if skill.shape == "gravity" then offset = -offset * 0.6 end
				TweenService:Create(particle, TweenInfo.new(0.26), { Position = position + offset, Size = particle.Size * 0.5, Transparency = 1 }):Play()
			end
		end
	end
	local slime = enemyKind == "Slime"
	local particleColor = slime and Color3.fromRGB(130, 224, 155) or profile.color
	if not slime and (classId == "knight" or classId == "elf") then
		local flat = typeof(direction) == "Vector3" and finite(direction.X) and finite(direction.Z)
			and Vector3.new(direction.X, 0, direction.Z) or Vector3.new(0, 0, -1)
		if flat.Magnitude < 0.001 then flat = Vector3.new(0, 0, -1) end
		local streak = part(holder, "K0ImpactStreak", position, Vector3.new(0.08, 1.2, 0.08) * scale, profile.secondary)
		streak.Shape = Enum.PartType.Block
		streak.CFrame = CFrame.lookAt(position, position + flat) * CFrame.Angles(0, 0, math.rad(classId == "knight" and 45 or -35))
		TweenService:Create(streak, TweenInfo.new(0.18), { Transparency = 1, Size = streak.Size * 1.2 }):Play()
	end
	for index = 1, 5 do
		local angle = (index - 1) * (math.pi * 2 / 5) + 0.35
		local offset = Vector3.new(math.cos(angle), 0.45 + (index % 2) * 0.4, math.sin(angle)) * scale
		local particle = part(holder, slime and "K0GelDroplet" or "K0ImpactSpark", position,
			Vector3.one * (slime and 0.18 or 0.1) * scale, particleColor)
		if not slime and classId ~= "mage" then
			particle.Shape = Enum.PartType.Block
			if classId == "elf" then particle.Size = Vector3.new(0.06, 0.22, 0.06) * scale end
		end
		TweenService:Create(particle, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = position + offset, Size = particle.Size * 0.5, Transparency = 1 }):Play()
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Name, billboard.Size = "K0DamageNumber", UDim2.fromOffset(100, 32)
	local bar = model and model:FindFirstChild("EnemyHealthBar")
	local numberHeight = bar and bar:IsA("BillboardGui") and math.max(1.5, bar.StudsOffsetWorldSpace.Y + 0.9) or 1.5
	billboard.StudsOffsetWorldSpace, billboard.MaxDistance, billboard.AlwaysOnTop = Vector3.new(0, numberHeight, 0), 80, false
	billboard.Parent = holder
	local label = Instance.new("TextLabel")
	label.Name, label.Size, label.BackgroundTransparency = "Amount", UDim2.fromScale(1, 1), 1
	label.Font, label.TextSize, label.TextColor3 = Enum.Font.GothamBold, 18, Color3.fromRGB(255, 247, 222)
	label.TextStrokeTransparency, label.Text = 0.35, tostring(math.floor(damage + 0.5))
	label.Parent = billboard
	TweenService:Create(billboard, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ StudsOffsetWorldSpace = Vector3.new(0, numberHeight + 0.7, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(0.65), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	playSound(holder, profile)
	return true
end

function HitEffects.start()
	if started then return end
	started = true
	task.spawn(function()
		local remotes = ReplicatedStorage:WaitForChild("Remotes")
		local hit = remotes:WaitForChild("K0HitEffect")
		if hit:IsA("RemoteEvent") then hit.OnClientEvent:Connect(HitEffects.show) end
	end)
end

return HitEffects
