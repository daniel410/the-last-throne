-- Rendered skill direction and motion must agree with the server's confirmed pulse.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local Visual = require(Client.AdvancedSkillVisual)
local FX = require(Client.HeroVFX)
local Bow = require(Client.K0BowMotion)
local Mage = require(Client.K0MageMotion)
local Melee = require(Client.AdvancedSkillMotion)
local camera = workspace.CurrentCamera
local originalCamera = camera.CFrame
local originalCompact = FX.isOtherHero
local stage = Instance.new("Folder", workspace)
local origin, forward = Vector3.new(0, 860, 0), -Vector3.zAxis
local checks = 0

local function check(condition, label)
    checks += 1
    assert(condition, label)
end

local function near(a, b)
    return (a - b).Magnitude < .002
end

local function actor(position)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name = "HumanoidRootPart"
    root.Anchored, root.CanCollide, root.Position = true, false, position
    return model, root
end

local function skill(id)
    return Catalog.byId[id].definition
end

local function beams(model, name)
    local matches = {}
    for _, object in model:GetDescendants() do
        if object:IsA("Beam") and object.Name == name then
            table.insert(matches, object)
        end
    end
    return matches
end

local function namedWorldParts(name, fn)
    local existing = {}
    for _, child in workspace:GetChildren() do existing[child] = true end
    fn()
    local positions = {}
    for _, child in workspace:GetChildren() do
        if not existing[child] and child.Name == name then
            table.insert(positions, child.Position)
            child:Destroy()
        end
    end
    return positions
end

local ok, err = xpcall(function()
    camera.CFrame = CFrame.lookAt(origin + Vector3.new(8, 13, 18), origin)
    local model, root = actor(origin + Vector3.xAxis * 3)
    local bowSkill = skill("elf.marksman.crossfire")
    local axeSkill = skill("dwarf.iron_axe.crosscut_axe")
    local angled = CFrame.Angles(0, math.rad(18), 0):VectorToWorldSpace(forward)
    local cast = {origin = origin, center = origin + forward * 4}
    local wall = Instance.new("Part", stage)
    wall.Anchored, wall.Size = true, Vector3.new(2, 5, 1)
    wall.CFrame = CFrame.lookAt(root.Position + angled * 24, root.Position + angled * 25)
    local target, targetRoot = actor(root.Position + angled * 16)
    local targetHumanoid = Instance.new("Humanoid", target)

    local function resolve(d, pulse)
        local hit, start, endpoint, points
        local state = {character = model, root = root}
        Combat.resolve(state, {definition = d, direction = forward, advancedCast = cast}, 2, {
            enemies = {[target] = {id = 1, model = target, root = targetRoot, humanoid = targetHumanoid}},
            clear = function() return true end,
            damage = function(_, enemy, _, _, heading, index)
                check(enemy.model == target and index == pulse, "Damage keeps its target and pulse")
                hit = heading
            end,
            visual = function(_, _, at, to, _, targets) start, endpoint, points = at, to, targets end,
        }, pulse)
        return start, endpoint, points, hit
    end

    local start, endpoint = resolve(bowSkill, 1)
    check(near(start, root.Position) and near(endpoint, start + forward * bowSkill.range), "First shot uses current origin and its own visibility")
    start, endpoint = resolve(bowSkill, 2)
    check(near(endpoint, start + angled * 23.3), "Rotated shot stops at its own wall")
    local _, _, confirmed, heading = resolve(bowSkill, 2)
    check(#confirmed == 1 and near(confirmed[1], targetRoot.Position) and near(heading, angled), "Line presentation agrees with the confirmed hit direction")
    wall:Destroy()
    targetRoot.Position = origin + angled * 15
    local axeStart, axeEnd, _, returnHeading = resolve(axeSkill, 2)
    check(near(axeStart, origin) and near(axeEnd, origin + angled * axeSkill.range) and near(returnHeading, -angled), "Returning axe keeps the cast origin and reverses contact direction")

    model:SetAttribute("K0ClassId", "elf")
    model:SetAttribute("K0State", "Attack")
    model:SetAttribute("K0SkillId", bowSkill.id)
    model:SetAttribute("K0AttackStartedAt", 10)
    model:SetAttribute("K0AttackSeq", 4)
    model:SetAttribute("K0AttackAim", "4|0|0|-1")
    local first = 10 + bowSkill.windup
    local second = first + bowSkill.interval
    check(near(Bow.forCharacter(model, first + .02).aimDirection, forward), "Unconfirmed shot keeps first aim")
    Bow.confirmPulse(model, bowSkill.id, 1, 4, first, 10, first)
    local redraw = Bow.forCharacter(model, first + .16)
    check(not near(redraw.aimDirection, forward) and not near(redraw.aimDirection, angled) and redraw.nocked, "Nocked redraw sweeps toward the next line")
    Bow.confirmPulse(model, bowSkill.id, 2, 4, second, 10, second)
    check(near(Bow.forCharacter(model, second + .03).aimDirection, angled), "Second shot holds the confirmed angle")
    local legacyArrows = namedWorldParts("ArrowWake", function()
        Visual.play(model, bowSkill.id, start, endpoint, 2, {targetRoot.Position})
    end)
    local shot = assert(workspace:FindFirstChild("HeroVFX"))
    local trace = beams(shot, "IconCrossfireTrace")
    check(#trace == 1 and #legacyArrows == 0 and not shot:FindFirstChild("IconPairedPath", true), "Crossfire uses a single primary trace")
    local visibleDirection = (trace[1].Attachment1.WorldPosition - trace[1].Attachment0.WorldPosition).Unit
    check(near(visibleDirection, angled), "Crossfire trace follows the rotated line")
    FX.clear()

    local counter = skill("knight.steel_knight.counter_slash")
    local knight = assert(FX.skill(nil, counter.id, origin, origin + forward * counter.range, 1, {}))
    local edge = beams(knight, "IconCounterSlashEdge")
    check(#edge == 10 and edge[#edge].Attachment1.WorldPosition.Y - edge[1].Attachment0.WorldPosition.Y > 2, "Counter Slash climbs above the guard")
    local brace = Melee.sample("knight", counter, counter.windup * .46, Enum.HumanoidRigType.R15)
    local recover = Melee.sample("knight", counter, counter.windup + .06, Enum.HumanoidRigType.R15)
    check((brace.angles.left - recover.angles.left).Magnitude > 12, "Shield arm opens from brace to follow-through")
    FX.clear()

    local axe = assert(FX.skill(nil, axeSkill.id, axeStart, axeEnd, 2, {}))
    local blade = assert(axe:FindFirstChild("CrosscutCatchEdge", true))
    check(not axe:FindFirstChild("IconPairedPath", true), "Crosscut does not render a parallel false line")
    local mesh = assert(axe:FindFirstChild("ThrownAxeBronzeHub", true))
    local approach = (blade.Attachment0.WorldPosition - origin).Magnitude
    check((blade.Attachment0.WorldPosition - mesh.Position).Magnitude < 1.8, "Returning axe and light share the same approach")
    FX.step(workspace:GetServerTimeNow() + .106)
    check(approach > 4 and (blade.Attachment0.WorldPosition - origin).Magnitude < 1.8, "Returning edge reaches the catch")
    local catch = Melee.sample("dwarf", axeSkill, axeSkill.windup + axeSkill.interval + .055, Enum.HumanoidRigType.R15)
    local echo = skill("dwarf.iron_axe.returning_echo")
    local straightCatch = Melee.sample("dwarf", echo, echo.windup + echo.interval + .055, Enum.HumanoidRigType.R15)
    check(catch.angles.rightKnee.X - straightCatch.angles.rightKnee.X > 18, "Crosscut absorbs the catch through the knee")
    FX.clear()

    local chain = skill("mage.cryo.chain_lightning")
    local caster = actor(origin)
    local tip = Instance.new("Attachment")
    local grip = Instance.new("Part", caster)
    grip.Name, grip.Position = "WeaponGrip", origin + Vector3.new(.6, .8, -.4)
    grip.Anchored, grip.CanCollide = true, false
    tip.Name, tip.Parent = "WeaponTip", grip
    local targets = {origin + forward * 5, origin + Vector3.new(2, 1, -8), origin + Vector3.new(-2, 0, -11)}
    local castCenter = origin + forward * chain.range
    local legacy = namedWorldParts("LightningFork", function()
        Visual.play(caster, chain.id, origin, castCenter, 1, targets)
    end)
    local chainModel = assert(workspace:FindFirstChild("HeroVFX"))
    local core = beams(chainModel, "ElectricCore")
    check(chainModel:GetAttribute("ChainCore") and #core == 18 and #legacy == 0, "Full chain replaces the duplicate legacy bolts")
    check(near(core[1].Attachment0.WorldPosition, tip.WorldPosition), "First hop starts at the staff tip")
    for i, to in ipairs(targets) do
        check(near(core[i * 6].Attachment1.WorldPosition, to), "Chain reaches confirmed target " .. i)
    end
    check(core[1].Width0 > core[7].Width0 and core[7].Width0 > core[13].Width0, "Chain attenuates across jumps")
    local sweep = Mage.sample(chain, Mage.profile(chain), chain.windup + .06)
    local bolt = skill("mage.cryo.lightning_line")
    local straight = Mage.sample(bolt, Mage.profile(bolt), bolt.windup + .06)
    check((sweep.angles.left - straight.angles.left).Magnitude > 20, "Chain uses a distinct guiding palm")
    FX.clear()

    FX.isOtherHero = function(character) return character == caster end
    Visual.play(caster, chain.id, origin, castCenter, 1, targets)
    local ally = assert(workspace:FindFirstChild("HeroVFX"))
    local compact = beams(ally, "ElectricCore")
    check(#compact == 12 and not ally:FindFirstChild("LightningSurface", true), "Party chain simplifies each link")
    for i, to in ipairs(targets) do
        check(near(compact[i * 4].Attachment1.WorldPosition, to), "Party chain reaches confirmed target " .. i)
    end
    FX.clear()

    camera.CFrame = CFrame.new(origin + Vector3.yAxis * 500)
    local fallback = namedWorldParts("ChainFallback", function()
        Visual.play(caster, chain.id, origin, castCenter, 1, targets)
    end)
    check(#fallback == 3 and near(fallback[1], (tip.WorldPosition + targets[1]) / 2), "Culled chain falls back to one segment per hop")
    local noTargets = namedWorldParts("ChainFallback", function()
        Visual.play(caster, chain.id, origin, castCenter, 1, {})
    end)
    check(#noTargets == 0, "Unconfirmed chain renders no fallback bolt")
end, debug.traceback)
FX.clear()
FX.isOtherHero = originalCompact
stage:Destroy()
camera.CFrame = originalCamera
print("HERO_SKILL_DIRECTION_NATIVE " .. game.HttpService:JSONEncode({pass = ok, checks = checks, error = not ok and err or nil}))
assert(ok, err)
