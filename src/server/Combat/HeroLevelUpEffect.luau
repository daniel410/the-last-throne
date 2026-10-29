-- TD tower-upgrade algorithm adapted for server-confirmed RPG hero levels.
-- Source hashes and adaptation scope: assets/shared/td-level-up-effect/manifest.json.
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local Effect={}
local tuning = {
	MAX_ACTIVE = 4,
	DURATION = 1.3,
	PARTICLE_COUNT = 28,
	PARTICLE_SIZE = 0.42,
	SPEED_MIN = 2.5,
	SPEED_MAX = 4.5,
	SPREAD = 22,
	LIGHT_EMISSION = 0.85,
	FLASH_DURATION = 0.22,
	FLASH_FILL_TRANSPARENCY = 0.78,
	FLASH_OUTLINE_TRANSPARENCY = 0.35,
	MIN_HEIGHT = 2,
	MAX_HEIGHT = 6,
	MIN_RADIUS = 0.8,
	MAX_RADIUS = 1.6,
	RADIUS_SCALE = 0.55,
	BASE_OFFSET = 0.15,
	RISE_ABOVE_HEAD = 0.6,
	RING_SEGMENTS = 8,
	STROKE = 0.13,
	CHEVRON_ROWS = 2,
	CHEVRON_WIDTH = 1.2,
	CHEVRON_GAP = 0.55,
	CHEVRON_RISE = 2.1,
	GOLD = Color3.fromRGB(255, 215, 110),
	WHITE = Color3.fromRGB(255, 250, 235),
}
local function fxPart(parent: Instance, name: string, size: Vector3, frame: CFrame, color: Color3, material: Enum.Material, wedge: boolean?): BasePart
	local part = Instance.new(if wedge then "WedgePart" else "Part") :: BasePart
	part.Name = name
	part.Size = size
	part.CFrame = frame
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide, part.CanTouch, part.CanQuery, part.CastShadow = false, false, false, false
	part.Parent = parent
	return part
end

local count=0
local function emitterHolder(position, _category)
 if count>=tuning.MAX_ACTIVE then return nil end
 local folder=workspace:FindFirstChild("TLTHeroLevelUpEffects")
 if not folder then folder=Instance.new("Folder");folder.Name="TLTHeroLevelUpEffects";folder.Parent=workspace end
 local p=Instance.new("Part");p.Name="FxHolder";p.Size=Vector3.new(.5,.5,.5);p.CFrame=CFrame.new(position);p.Transparency=1
 p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
 count=count+1;p.Destroying:Connect(function() count=count-1 end);p.Parent=folder
 return p
end
local upgradeHolders={}
function Effect.play(tower: Model?)
	if tower == nil or tower.Parent == nil then return end
	local root = tower.PrimaryPart or tower:FindFirstChildWhichIsA("BasePart", true)
	if root == nil then return end
	local previous = upgradeHolders[tower]
	if previous then previous:Destroy() end
	local cfg = tuning
	local holder = emitterHolder(root.Position, "upgrade")
	if holder == nil then return end
	upgradeHolders[tower] = holder
	Debris:AddItem(holder, cfg.DURATION)
	local connection = tower.Destroying:Connect(function() holder:Destroy() end)
	holder.Destroying:Connect(function()
		connection:Disconnect()
		if upgradeHolders[tower] == holder then upgradeHolders[tower] = nil end
	end)
	holder.Name = "HeroLevelUpSparkle"
	local boundsFrame, boundsSize = tower:GetBoundingBox()
	local height = math.clamp(boundsSize.Y, cfg.MIN_HEIGHT, cfg.MAX_HEIGHT)
	local radius = math.clamp(math.max(boundsSize.X, boundsSize.Z) * cfg.RADIUS_SCALE, cfg.MIN_RADIUS, cfg.MAX_RADIUS)
	local base = CFrame.new(root.Position.X, boundsFrame.Position.Y - boundsSize.Y / 2 + cfg.BASE_OFFSET, root.Position.Z)
	holder.CFrame = base * CFrame.new(0, height * 0.45, 0)
	holder.Size = Vector3.new(radius * 1.4, height * 0.65, radius * 1.4)
	local flash = Instance.new("Highlight")
	flash.Name = "UpgradeFlash"
	flash.Adornee = tower
	flash.FillColor, flash.OutlineColor = cfg.WHITE, cfg.GOLD
	flash.FillTransparency, flash.OutlineTransparency = cfg.FLASH_FILL_TRANSPARENCY, cfg.FLASH_OUTLINE_TRANSPARENCY
	flash.DepthMode = Enum.HighlightDepthMode.Occluded
	flash.Parent = holder
	TweenService:Create(flash, TweenInfo.new(cfg.FLASH_DURATION), { FillTransparency = 1, OutlineTransparency = 1 }):Play()
	Debris:AddItem(flash, cfg.FLASH_DURATION)
	-- Eight ring segments and four chevron bars: at most 12 parts per holder.
	for i = 1, cfg.RING_SEGMENTS do
		local angle = i * math.pi * 2 / cfg.RING_SEGMENTS
		local frame = base * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, radius)
		local ring = fxPart(holder, "UpgradeRiseRing", Vector3.new(radius * 0.83, cfg.STROKE, cfg.STROKE), frame, cfg.GOLD, Enum.Material.Neon)
		TweenService:Create(ring, TweenInfo.new(cfg.DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = frame + Vector3.new(0, height + cfg.RISE_ABOVE_HEAD, 0), Transparency = 1 }):Play()
	end
	for row = 1, cfg.CHEVRON_ROWS do
		for _, side in { -1, 1 } do
			local frame = base * CFrame.new(side * cfg.CHEVRON_WIDTH * 0.25, height * 0.45 + row * cfg.CHEVRON_GAP, 0)
				* CFrame.Angles(0, 0, -side * math.pi / 4)
			local arrow = fxPart(holder, "UpgradeRiseChevron", Vector3.new(cfg.CHEVRON_WIDTH * 0.7, cfg.STROKE, cfg.STROKE), frame, cfg.WHITE, Enum.Material.Neon)
			TweenService:Create(arrow, TweenInfo.new(cfg.DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = frame + Vector3.new(0, cfg.CHEVRON_RISE, 0), Transparency = 1 }):Play()
		end
	end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "UpgradeSparkles"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Enabled, emitter.Rate = false, 0
	emitter.Color = ColorSequence.new(cfg.GOLD, cfg.WHITE)
	emitter.Transparency = NumberSequence.new(0, 1)
	emitter.Size = NumberSequence.new(cfg.PARTICLE_SIZE, 0)
	emitter.Lifetime = NumberRange.new(cfg.DURATION)
	emitter.Speed = NumberRange.new(cfg.SPEED_MIN, cfg.SPEED_MAX)
	emitter.SpreadAngle = Vector2.new(cfg.SPREAD, cfg.SPREAD)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.LightEmission = cfg.LIGHT_EMISSION
	emitter.Parent = holder
	emitter:Emit(cfg.PARTICLE_COUNT)
end

return Effect
