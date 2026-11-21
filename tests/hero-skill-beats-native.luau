-- Isolated Studio regression for confirmed hit rhythm and scatter previews.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Stop = require(Client.K0HitStop)
local Visual = require(Client.AdvancedSkillVisual)
local FX = require(Client.HeroVFX)
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local result = {checks = 0, failures = {}, rhythm = {}, scatter = {}}
local function check(ok, label)
    result.checks += 1
    if not ok then table.insert(result.failures, label) end
end
local function near(a, b)
    return math.abs(a - b) < .00001
end
local actor = Instance.new("Model")
actor.Name = "SkillBeatsFixture"
actor.Parent = workspace
local origin = Vector3.new(20000, 1000, 20000)
local root = Instance.new("Part")
root.Anchored, root.CanCollide = true, false
root.Name, root.Position, root.Parent = "HumanoidRootPart", origin, actor
local started, seq = 100, 0
local function attack(classId, id)
    seq += 1
    actor:SetAttribute("K0AttackSeq", seq)
    actor:SetAttribute("K0AttackStartedAt", started)
    actor:SetAttribute("K0ClassId", classId)
    actor:SetAttribute("K0SkillId", id)
    actor:SetAttribute("K0State", "Attack")
    actor:SetAttribute("TLTDeathFalling", nil)
    return Catalog.get(classId, id).definition
end

local clock = Stop.new(function() return actor end)
for _, row in {
    {"knight", "knight.steel_knight.blade_storm", .022, .046},
    {"dwarf", "dwarf.iron_axe.mountain_collapse", .027, .060},
    {"elf", "elf.marksman.grand_volley", .020, .028},
    {"mage", "mage.pyro.molten_line", .020, .028},
} do
    local classId, id = row[1], row[2]
    local d = attack(classId, id)
    local timings = {}
    for pulse = 1, d.pulses do
        local at = started + d.windup + (d.hitDelay or 0) + (pulse - 1) * d.interval + .002
        local meta = {classId = classId, skillId = id, startedAt = started, seq = seq, confirmedAt = at, pulse = pulse}
        local hold = pulse == d.pulses and row[4] or row[3]
        local accepted = clock.record(actor, meta, at)
        table.insert(timings, accepted)
        check(accepted, id .. " accepts hit " .. pulse)
        check(not clock.record(actor, meta, at + .001), id .. " cannot extend a beat for another target")
        check(near(clock.sample(actor, at + hold - .002), at), id .. " holds through the authored beat")
        check(clock.sample(actor, at + hold + .003) > at, id .. " starts catch-up at the intended time")
        check(near(clock.sample(actor, at + hold * 3), at + hold * 3), id .. " catches up to server time")
        if pulse == 1 then
            local future = table.clone(meta); future.pulse = 2
            check(not clock.record(actor, future, at + .001), id .. " cannot pause an unreached beat")
        end
    end
    result.rhythm[classId] = timings
end

for _, row in {{"elf", "elf.marksman.heavy_draw"}, {"mage", "mage.cryo.frost_lance"},
    {"dwarf", "dwarf.gunner.siege_barrage"}} do
    local d = attack(row[1], row[2])
    local at = started + d.windup + .01
    local meta = {classId = row[1], skillId = d.id, startedAt = started, seq = seq, confirmedAt = at, pulse = 1}
    check(not clock.record(actor, meta, at), d.id .. " releases payload without pausing the rig")
end

local d = attack("dwarf", "dwarf.gunner.shrapnel_toss")
local target = origin + Vector3.new(0, 0, -20)
local function rings()
    local positions = {}
    for _, p in workspace:GetChildren() do
        if p.Name == "SkillTelegraph" and p:IsA("BasePart") and (p.Position - target).Magnitude < 90 then
            table.insert(positions, p.Position)
        end
    end
    return positions
end
local function center(positions)
    local sum = Vector3.zero
    for _, position in positions do sum += position end
    return #positions > 0 and sum / #positions or sum
end
local function nearXZ(a, b)
    return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude < .02
end
local now = workspace:GetServerTimeNow()
local first = target + Vector3.new(-3, 0, -2)
local second = target + Vector3.new(3, 0, 0)
local third = target + Vector3.new(-3, 0, 2)
Visual.play(actor, d.id, origin, target, 0, nil, seq, now, now)
local opening = rings()
result.scatter.openingSegments = #opening
check(#opening == 24 and nearXZ(center(opening), first), "first scatter preview is one ring at the first landing")
Visual.play(actor, d.id, origin, first, 1, {}, seq, now, now)
local following = rings()
result.scatter.secondSegments = #following
check(#following == 24 and nearXZ(center(following), second), "first contact clears its preview and reveals the next scatter")
Visual.play(actor, d.id, origin, first, 1, {}, seq, now, now)
check(#rings() == #following, "duplicate pulse leaves the next preview intact")
Visual.play(actor, d.id, origin, second, 2, {}, seq, now, now)
check(#rings() == 24 and nearXZ(center(rings()), third), "second contact reveals the last scatter")
actor:SetAttribute("K0State", "Dodge")
task.wait()
result.scatter.afterDodgeSegments = #rings()
check(#rings() == 0, "dodge clears unfinished ground effects")
Visual.play(actor, d.id, origin, third, 3, {}, seq, now, now)
check(#rings() == 0, "a late confirmation cannot recreate a canceled preview")

local frost = attack("mage", "mage.cryo.froststorm")
now = workspace:GetServerTimeNow()
Visual.play(actor, frost.id, origin, target, 0, nil, seq, now, now)
check(#rings() == 24, "single landing still gets a full preview")
actor:SetAttribute("TLTDeathFalling", true)
task.wait()
check(#rings() == 0, "death clears the ground cue")
actor:Destroy()
FX.clear()
result.pass = #result.failures == 0
print("HERO_SKILL_BEATS_NATIVE " .. game.HttpService:JSONEncode(result))
assert(result.pass, table.concat(result.failures, "\n"))
