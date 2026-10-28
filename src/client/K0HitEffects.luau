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
function HitEffects.show(model, position, damage, classId, enemyKind, direction)
	local profile = profiles[classId]
	if not profile or typeof(position) ~= "Vector3" or not finite(position.X) or not finite(position.Y) or not finite(position.Z)
		or not finite(damage) or damage <= 0 or damage > 1000000 or type(enemyKind) ~= "string" then return false end
	if model ~= nil and (typeof(model) ~= "Instance" or not model:IsA("Model")) then return false end
	for i = #active, 1, -1 do if not active[i].Parent then table.remove(active, i) end end
	if #active >= MAX_ACTIVE then table.remove(active, 1):Destroy() end
	local holder = part(workspace, "K0HitEffect", position, Vector3.new(0.1, 0.1, 0.1), profile.color)
	holder.Transparency = 1
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
