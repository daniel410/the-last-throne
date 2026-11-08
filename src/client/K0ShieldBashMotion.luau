-- Shield-first contact, authored through Blender MCP; in-place presentation.
local Clip = require(script.Parent.K0ShieldBashClip)
local Definition = require(game.ReplicatedStorage.Shared.K0Config).Skills.knight[1]
local Motion = {}
local Melee = require(script.Parent.K0MeleeMotion)
function Motion.sample(age, rigType)
    local w, a, r = Definition.windup, Definition.active, Definition.recovery
    local current = {0, w, w + a, w + a + r}
    local authored = {0, Clip.windup, Clip.windup + Clip.active, Clip.duration}
    local section = 1
    for i = 1, 3 do
        if age >= current[i] then section = i end
    end
    local alpha = math.clamp((age - current[section]) / (current[section + 1] - current[section]), 0, 1)
    local time = authored[section] + (authored[section + 1] - authored[section]) * alpha
    local f = time * Clip.fps
    local n = math.min(#Clip.samples - 1, math.floor(f))
    local t = f - n
    local x, y = Clip.samples[n + 1], Clip.samples[math.min(n + 2, #Clip.samples)]
    local pose = {cutting = false}
    for _, channel in ipairs(Clip.channels) do
        local v = {}
        for i = 1, 6 do v[i] = x[channel][i] + (y[channel][i] - x[channel][i]) * t end
        pose[channel] = CFrame.new(v[1], v[2], v[3])
            * CFrame.Angles(0, math.rad(v[5]), 0)
            * CFrame.Angles(math.rad(v[4]), 0, math.rad(v[6]))
    end
    if rigType ~= Enum.HumanoidRigType.R6 then
        -- Mixamo bracing supplies anticipation/recovery; the shield-first strike
        -- and sheathed sword remain exactly on their reviewed contact path.
        local basic=require(game.ReplicatedStorage.Shared.K0Config).BasicAttackProfiles.knight.attacks[1]
        local duration=basic.windup+basic.active+basic.recovery
        local brace=Melee.sample("knight",1,math.clamp(age/(w+a+r),0,1)*duration,nil,nil,"knight.mixamo.brace",rigType)
        local load=age<w*.7 and math.sin(math.pi*math.clamp(age/(w*.7),0,1)) or 0
        local release=age>w+a+r*.35 and math.sin(math.pi*math.clamp((age-w-a-r*.35)/(r*.65),0,1)) or 0
        local weight=(load+release)*.20
        for _,channel in ipairs({"torso","right","elbow","neck"})do
            if pose[channel] and brace[channel] then pose[channel]=pose[channel]:Lerp(brace[channel],weight) end
        end
    end
    return pose
end
function Motion.forCharacter(character, current)
    if character:GetAttribute("K0ClassId") ~= "knight"
        or character:GetAttribute("K0State") ~= "Attack"
        or character:GetAttribute("K0SkillId") ~= "knight.common.bash" then return nil end
    local started = character:GetAttribute("K0AttackStartedAt") or character:GetAttribute("K0SkillStartedAt")
    local phase = character:GetAttribute("K0AttackPhase")
    local fallback = phase == "Windup" and Definition.windup * .45
        or phase == "Active" and Definition.windup
        or Definition.windup + Definition.active + Definition.recovery * .5
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    return Motion.sample(type(started) == "number" and math.max(0, current - started) or fallback,humanoid and humanoid.RigType)
end
return Motion
