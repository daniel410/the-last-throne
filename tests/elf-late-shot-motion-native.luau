assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Motion = require(game.StarterPlayer.StarterPlayerScripts.Client.K0BowMotion)
local Config = require(game.ReplicatedStorage.Shared.K0Config)
local specs = {}
for _, def in ipairs(Config.Skills.elf) do specs[def.id] = def end
local stage = Instance.new("Folder", workspace)
local report = {checks = 0, failures = {}, timeline = {}}

local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end

local function archer(id, started, rate)
    local character = Instance.new("Model", stage)
    Instance.new("Humanoid", character)
    character:SetAttribute("K0ClassId", "elf")
    character:SetAttribute("K0State", "Attack")
    character:SetAttribute("K0SkillId", id)
    character:SetAttribute("K0AttackSeq", 1)
    character:SetAttribute("K0AttackStartedAt", started)
    character:SetAttribute("K0ArrowReleaseProtocol", 1)
    character:SetAttribute("K0BasicAttackRate", rate or 1)
    character:SetAttribute("K0AttackAim", "1|0|0|-1")
    return character
end

local function confirmed(character, def, at, received, pulse)
    local started = character:GetAttribute("K0AttackStartedAt")
    if def.advanced then
        Motion.confirmPulse(character, def.id, pulse, 1, at, started, received)
    elseif def.shotCount then
        character:SetAttribute("K0RapidShotAt", at)
        character:SetAttribute("K0RapidShotCount", pulse)
    else
        character:SetAttribute("K0ArrowRelease", string.format("1|%.6f|%.6f|1", started, at))
        character:SetAttribute("K0ArrowVisual", "1|0|0|0|0|0|-20")
    end
end

for _, item in ipairs({
    {nil, 1.35},
    {"elf.common.aimed", 1},
    {"elf.marksman.heavy_draw", 1},
    {"elf.common.rapid", 1},
    {"elf.marksman.crossfire", 1},
    {"elf.marksman.grand_volley", 1},
}) do
    local id, rate = item[1], item[2]
    local label = id or "basic"
    local def = id and specs[id] or Config.BasicAttackProfiles.elf.attacks[1]
    local character = archer(id, 100, rate)
    local fires = 100 + def.windup/rate
    local visibleAt = fires+.085
    local held = Motion.forCharacter(character, fires+.045)
    check(held.nocked and held.ikWeight == 1, label .. " holds at the anchor before a confirmed release")
    confirmed(character, def, fires, visibleAt, 1)
    local release = Motion.forCharacter(character, visibleAt)
    local snap = Motion.forCharacter(character, visibleAt+.020/rate)
    local caughtUp = Motion.forCharacter(character, visibleAt+.095)
    report.timeline[label] = {release = release.time, snap = snap.time, after = caughtUp.time}
    check(not release.nocked and math.abs(release.time-.8) < .001, label .. " launches once with the hand at the anchor")
    check(not snap.nocked and snap.draw < release.draw and snap.time>.82 and snap.time<.895,
        label .. " shows the bowstring moving forward before recovery")
    local observedLate = archer(id, 100, rate)
    confirmed(observedLate, def, fires, visibleAt, 1)
    local lateEntry = Motion.forCharacter(observedLate, visibleAt)
    check(math.abs(lateEntry.time-.8)>.01, label .. " a newly visible archer does not replay an old release")
    local reference = Motion.forCharacter(observedLate, visibleAt+.095)
    check(math.abs(reference.time-caughtUp.time)<.002 and reference.nocked==caughtUp.nocked,
        label .. " rejoins the confirmed attack timeline")
    character:SetAttribute("K0State", "Dodge")
    check(Motion.forCharacter(character, visibleAt+.11)==nil, label .. " cancelled pose is discarded")
end

local rapid = specs["elf.common.rapid"]
local nearlyNext = archer(rapid.id, 200)
local shot = 200+rapid.windup
Motion.forCharacter(nearlyNext, shot+.03)
confirmed(nearlyNext, rapid, shot, shot+.15, 1)
local tooLate = Motion.forCharacter(nearlyNext, shot+.15)
check(tooLate.nocked, "A release too close to the next Rapid Fire shot preserves the next draw")
confirmed(nearlyNext, rapid, shot+rapid.shotInterval, shot+rapid.shotInterval+.01, 2)
local second = Motion.forCharacter(nearlyNext, shot+rapid.shotInterval+.01)
check(not second.nocked and second.time>.8 and second.time<.9, "A fresh second confirmation uses its authoritative beat")

local heavy = specs["elf.marksman.heavy_draw"]
local queued = archer(nil, 300)
queued:SetAttribute("K0AttackSeq", 0)
local queuedAt = 301+heavy.windup
Motion.confirmPulse(queued, heavy.id, 1, 1, queuedAt, 301, queuedAt+.085)
queued:SetAttribute("K0AttackSeq", 1)
queued:SetAttribute("K0SkillId", heavy.id)
queued:SetAttribute("K0AttackStartedAt", 301)
local lateAttributes = Motion.forCharacter(queued, queuedAt+.09)
check(not lateAttributes.nocked and lateAttributes.time>.9, "Queued confirmation never invents a previously rendered draw")

stage:Destroy()
report.pass = #report.failures == 0
print("ELF_LATE_SHOT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Elf late shot motion regression")
