-- Owner-local presentation clock. Never pauses input, roots or server combat.
local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage").Shared.K0Config)
local HitStop = {}
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < 1e12 end

local function definition(classId, skillId, combo)
    if skillId then
        for _, d in ipairs(Config.Skills[classId] or {}) do if d.id == skillId then return d end end
    else
        local p = Config.BasicAttackProfiles[classId]
        return p and p.attacks[combo]
    end
end

local function duration(classId, skillId, combo, d)
    if not d or d.ranged or d.magic or classId == "elf" then return 0 end
    if skillId then
        if classId ~= "knight" and classId ~= "dwarf" then return 0 end
        if d.form and d.form ~= "melee" and d.form ~= "cone" and d.form ~= "area" then return 0 end
        if (d.pulses or 1) > 1 then return .03 end
        return classId == "dwarf" and .065 or .045
    end
    return classId == "dwarf" and .05 or classId == "mage" and .025
        or classId == "knight" and (combo == 3 and .045 or .03) or 0
end

-- Separate controllers permit deterministic native fixtures without a fake Player.
function HitStop.new(owner)
    local record
    local controller = {}
    local function matches(character)
        return record and character == owner() and record.character == character
            and character.Parent ~= nil and character:GetAttribute("K0State") == "Attack"
            and not character:GetAttribute("TLTDeathFalling")
            and character:GetAttribute("K0AttackSeq") == record.seq
            and character:GetAttribute("K0AttackStartedAt") == record.startedAt
            and character:GetAttribute("K0SkillId") == record.skillId
    end
    function controller.record(character, meta, now)
        if character ~= owner() or typeof(character) ~= "Instance" or not character:IsA("Model")
            or type(meta) ~= "table" or not finite(now) or not finite(meta.seq)
            or not finite(meta.startedAt) or not finite(meta.confirmedAt)
            or now - meta.confirmedAt < -.05 or now - meta.confirmedAt > .18
            or character:GetAttribute("K0State") ~= "Attack" or character:GetAttribute("TLTDeathFalling")
            or character:GetAttribute("K0AttackSeq") ~= meta.seq
            or character:GetAttribute("K0AttackStartedAt") ~= meta.startedAt
            or character:GetAttribute("K0ClassId") ~= meta.classId
            or character:GetAttribute("K0SkillId") ~= meta.skillId then return false end
        if record and record.character == character and record.seq == meta.seq
            and record.startedAt == meta.startedAt then return false end
        local combo = character:GetAttribute("K0Combo") or 1
        local d = definition(meta.classId, meta.skillId, combo)
        local hold = duration(meta.classId, meta.skillId, combo, d)
        if hold <= 0 then return false end
        local rate = meta.skillId and 1 or character:GetAttribute("K0BasicAttackRate") or 1
        if not finite(rate) or rate <= 0 then return false end
        local ending = meta.startedAt + (d.windup + d.active + d.recovery) / rate
        local contact = meta.startedAt + (d.windup + (d.hitDelay or 0)) / rate
        if now < contact or meta.confirmedAt < contact - .01 then return false end
        -- Hold + catch-up must finish before the existing action ends.
        hold = math.min(hold, (ending - now) / 3)
        if hold < .012 then return false end
        record = {character = character, seq = meta.seq, startedAt = meta.startedAt,
            skillId = meta.skillId, at = now, hold = hold}
        return true
    end
    function controller.sample(character, now)
        if not finite(now) then return now end
        if not matches(character) then
            -- Sampling another player's rig must not consume the owner's hold.
            if record and character == record.character then record = nil end
            return now
        end
        local age, hold = now - record.at, record.hold
        if age < 0 or age >= hold * 3 then return now end
        if age <= hold then return record.at end
        local t = (age - hold) / (hold * 2)
        local smooth = t * t * (3 - 2 * t)
        return now - hold * (1 - smooth)
    end
    return controller
end

local live = HitStop.new(function() return Players.LocalPlayer and Players.LocalPlayer.Character end)
HitStop.record, HitStop.sample = live.record, live.sample
return HitStop
