assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Use an isolated local place")
local client = game.StarterPlayer.StarterPlayerScripts.Client
local catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local finalBeat = require(client.SkillFinalBeat)
local melee = require(client.AdvancedSkillMotion)
local mage = require(client.K0MageMotion)
local fx = require(client.HeroVFX)
local visual = require(client.AdvancedSkillVisual)
local camera = workspace.CurrentCamera
local originalCamera, originalCompact, originalWeight = camera.CFrame, fx.isOtherHero, finalBeat.weight
local origin = Vector3.new(0, 745, 0)
local target = origin - Vector3.zAxis * 10
local floor = Instance.new("Part")
floor.Size = Vector3.new(140, 1, 140)
floor.Position = origin - Vector3.yAxis * 3
floor.Anchored = true
floor.Parent = workspace

local checks, failures, budget = 0, {}, {}
local function check(ok, message)
    checks += 1
    if not ok then table.insert(failures, message) end
end

local function pieces(model, name)
    local result = {}
    for _, part in model:GetDescendants() do
        if part.Name == name then table.insert(result, part) end
    end
    return result
end

local function top(model, name)
    local value = -math.huge
    for _, beam in pieces(model, name) do
        value = math.max(value, beam.Attachment0.WorldPosition.Y, beam.Attachment1.WorldPosition.Y)
    end
    return value
end

local function widest(model, name)
    local value = 0
    for _, beam in pieces(model, name) do
        for _, attachment in {beam.Attachment0, beam.Attachment1} do
            local offset = (attachment.WorldPosition - target) * Vector3.new(1, 0, 1)
            value = math.max(value, offset.Magnitude)
        end
    end
    return value
end

local accents = {
    ["knight.steel_knight.unyielding_front"] = {"leftKnee", "FrontWallCrest"},
    ["knight.paladin.oath_of_dawn"] = {"right", "IconDawnCrest"},
    ["mage.pyro.caldera_s_judgment"] = {"right", "CalderaMagmaSpine"},
    ["mage.cryo.eternal_tempest"] = {"leftElbow", "TempestSpiral"},
}

local ok, err = xpcall(function()
    camera.CFrame = CFrame.lookAt(origin + Vector3.new(8, 18, 24), target)
    for id, item in accents do
        local row = catalog.byId[id]
        local d = row.definition
        for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
            local function sample(age)
                if row.classId == "knight" then return melee.sample(row.classId, d, age, rig) end
                return mage.sample(d, mage.profile(d), age)
            end
            local first = d.windup + (d.hitDelay or 0)
            local last = first + (d.pulses - 1) * d.interval
            local ages = {first + .06, last, last + .06, d.windup + d.active + d.recovery}
            local poses = {}
            for i, age in ages do poses[i] = sample(age).angles[item[1]] end
            finalBeat.weight = function() return 0 end
            for i, age in ages do
                local delta = (poses[i] - sample(age).angles[item[1]]).Magnitude
                check(i == 3 and delta > 15 or i ~= 3 and delta < .001, id .. " final pose envelope " .. i)
            end
            finalBeat.weight = originalWeight
        end

        local function cast(pulse)
            local now = workspace:GetServerTimeNow()
            local model = assert(fx.skill(nil, id, origin, target, pulse))
            fx.step(now + .17)
            return model
        end
        local first = cast(1)
        local firstHeight = top(first, item[2])
        local firstZ = first:FindFirstChild(item[2], true).Attachment0.WorldPosition.Z
        local firstWidth = widest(first, item[2])
        fx.clear()
        local finish = cast(d.pulses)
        if id == "knight.steel_knight.unyielding_front" then
            check(finish:FindFirstChild(item[2], true).Attachment0.WorldPosition.Z < firstZ - .65,
                "The shield wall drives forward on the second strike")
        elseif id == "mage.cryo.eternal_tempest" then
            check(widest(finish, item[2]) < firstWidth * .70, "The final frost eye contracts")
        else
            check(top(finish, item[2]) > firstHeight + 1, id .. " has a taller final release")
        end
        fx.clear()
    end

    local count = 0
    for id, row in catalog.byId do
        local d = row.definition
        if d.ultimate then
            count += 1
            for _, compact in {false, true} do
                fx.isOtherHero = function() return compact end
                local now = workspace:GetServerTimeNow()
                local first = assert(fx.skill(nil, id, origin, target, 1))
                fx.step(now + d.interval + .02)
                check(not first.Parent, id .. " first signature clears before the next beat")
                fx.clear()
                local model = assert(fx.skill(nil, id, origin, target, d.pulses))
                check(model:GetAttribute("UltimateSignature") ~= nil, id .. " retains its silhouette")
                local _, beams, _, glows, particles, surfaces = fx.count()
                local measured = budget[id] or {}
                measured[compact and "ally" or "own"] = {beams = beams, surfaces = surfaces, particles = particles}
                budget[id] = measured
                if compact then
                    check(glows == 0 and particles == 0, id .. " ally avoids transparent accents")
                    check(beams <= 12 and surfaces <= 9, id .. " ally limits overlapping draws")
                end
                fx.clear()
            end
        end
    end
    check(count == 8, "All branch ultimates are covered")

    -- Exercise the production event consumer with a bow-tip fixture.
    fx.isOtherHero = function() return false end
    local actor = Instance.new("Model")
    actor.Parent = workspace
    local grip = Instance.new("Part")
    grip.Name = "WeaponGrip"
    grip.Position = origin + Vector3.new(.5, .75, -.7)
    grip.Anchored = true
    grip.Parent = actor
    local tip = Instance.new("Attachment")
    tip.Name = "WeaponTip"
    tip.Parent = grip
    local volley = "elf.marksman.grand_volley"
    visual.play(actor, volley, origin, target, 1)
    local model = workspace:FindFirstChild("HeroVFX")
    local wake = model and model:FindFirstChild("UltimateArrowWake", true)
    check(wake and (wake.Attachment0.WorldPosition - tip.WorldPosition).Magnitude < .001, "Volley starts at the bow")
    check(not workspace:FindFirstChild("ArrowWake"), "Volley uses a single primary fan")
    fx.clear()

    fx.isOtherHero = function() return true end
    for i = 1, 10 do
        fx.skill(nil, "mage.cryo.eternal_tempest", origin, target, 1)
    end
    visual.play(actor, volley, origin, target, 1)
    check(workspace:FindFirstChild("ArrowWake") ~= nil, "Volley retains a fallback when the primary is culled")
    actor:Destroy()
end, debug.traceback)
if not ok then table.insert(failures, err) end
fx.clear()
fx.isOtherHero, finalBeat.weight, camera.CFrame = originalCompact, originalWeight, originalCamera
floor:Destroy()
print("HERO_ULTIMATE_FINISH_NATIVE " .. game.HttpService:JSONEncode({
    pass = #failures == 0, checks = checks, failures = failures, budget = budget,
}))
assert(#failures == 0, "Ultimate presentation verification failed")
