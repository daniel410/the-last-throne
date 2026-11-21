assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Hits = require(Client.K0HitEffects)
local camera = workspace.CurrentCamera
local original, originalCompact = camera.CFrame, FX.isOtherHero
local at, dir = Vector3.new(0, 930, 0), -Vector3.zAxis
camera.CFrame = CFrame.lookAt(at + Vector3.new(8, 13, 18), at)
local stage = Instance.new("Folder", workspace)
local report = {checks = 0, failures = {}, releases = {}}

local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end
local function actor(offset)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, at+offset
    return model
end
local owner = actor(Vector3.zero)
local allies = {actor(Vector3.xAxis*4), actor(Vector3.xAxis*8), actor(Vector3.xAxis*12)}
FX.isOtherHero = function(character) return character ~= nil and character ~= owner end
local function fillContacts()
    local first, last, count
    count = 0
    for _ = 1, 16 do
        local effect = FX.contact(at, "elf", nil, dir, 1, true)
        if not effect then break end
        first, last = first or effect, effect
        count += 1
    end
    return first, last, count
end
local function allReleased()
    local records, beams, chips, glows, particles, faces = FX.count()
    return records + beams + chips + glows + particles + faces == 0
end
local function definition(id) return Catalog.byId[id].definition end

for i, id in ipairs({
    "knight.steel_knight.vanguard_strike",
    "dwarf.iron_axe.returning_echo",
    "elf.marksman.grand_volley",
    "mage.cryo.chain_lightning",
}) do
    local firstHit, lastHit, count = fillContacts()
    local caster = allies[(i-1)%#allies+1]
    local effect = FX.skill(caster, id, at, at+dir*7, 1, {at+dir*7, at+dir*10})
    report.releases[id] = effect ~= nil
    check(count >= 6 and effect and effect:FindFirstChildWhichIsA("Beam", true), id .. " keeps the release after the compact hit queue fills")
    check(firstHit and not firstHit.Parent and lastHit and lastHit.Parent, id .. " replaces the oldest compact contact")
    check(FX.count() == count, id .. " stays within the same record budget")
    FX.step(workspace:GetServerTimeNow()+4)
    check(allReleased(), id .. " releases all reclaimed allocations")
end

fillContacts()
local hail = definition("mage.cryo.hailfall")
local landing = workspace:GetServerTimeNow()+.16
local incoming = FX.incoming(allies[1], hail, at, 2, 1, landing, function() return true end)
check(incoming and incoming:FindFirstChildWhichIsA("Beam", true), "Ally Hailfall keeps its incoming silhouette")
FX.endIncoming(allies[1], 2, 1)
check(not incoming or not incoming.Parent, "The corresponding confirmation removes the incoming effect")
FX.clear()

local charge = definition("elf.marksman.heavy_draw")
local cue = Presentation.get(charge)
local firstAlly = FX.windup(allies[1], charge, cue.motion, cue.effect, at, 1, workspace:GetServerTimeNow())
check(firstAlly ~= nil, "At least one ally windup is readable")
for i = 2, 3 do FX.windup(allies[i], charge, cue.motion, cue.effect, at, 1, workspace:GetServerTimeNow()) end
local mine = FX.windup(owner, charge, cue.motion, cue.effect, at, 1, workspace:GetServerTimeNow())
check(mine and mine:FindFirstChildWhichIsA("Beam", true), "Other windups reserve space for the owner's weapon cue")
FX.endWindup(owner, 1)
check(not mine or not mine.Parent, "Owner windup still clears on interrupt")
FX.clear()

local occupied = {}
local shot = "dwarf.gunner.gunner_shot"
for _ = 1, 16 do
    local effect = FX.skill(allies[1], shot, at, at+dir*8, 1, {})
    if not effect then break end
    table.insert(occupied, effect)
end
local before = {}
for _, obj in ipairs(workspace:GetChildren()) do before[obj] = true end
Visual.play(allies[1], shot, at, at+dir*8, 1, {at+dir*3, at+dir*5, at+dir*8})
local impacts, tracers = 0, 0
for _, obj in ipairs(workspace:GetChildren()) do
    if not before[obj] then
        if obj.Name == "SkillContact" then impacts += 1 end
        if obj.Name == "RifleTracer" then tracers += 1 end
    end
end
check(impacts == 1 and tracers == 1, "Saturated Gunner shot has one fallback muzzle flash and a tracer")
check(#occupied >= 6 and occupied[1].Parent, "Existing release geometry survives later releases")
check(Hits.show(owner, at, 42, "elf", "Goblin", dir, "elf.common.aimed", {attacker = allies[1]}), "Culled ally hit still presents confirmed damage")
local hit = workspace:FindFirstChild("K0HitEffect")
check(hit and hit.K0DamageNumber.Amount.Text == "42" and not hit:FindFirstChild("K0ImpactFlash"), "Culled ally hit keeps damage without a redundant flash")
local localHit = FX.contact(at, "knight", nil, dir, 1)
check(localHit ~= nil, "Local contacts still use their reserved slots")
local denied = FX.skill(allies[1], shot, at+Vector3.yAxis*200, at+Vector3.yAxis*200+dir*8, 1, {})
check(denied == nil and localHit and localHit.Parent, "Distant effects leave local and nearby allocations intact")
FX.clear()
check(allReleased(), "All record, beam and surface counters return to zero")
FX.isOtherHero, camera.CFrame = originalCompact, original
if hit then hit:Destroy() end
stage:Destroy()
report.pass = #report.failures == 0
print("HERO_VFX_PRIORITY_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero VFX priority regression")
