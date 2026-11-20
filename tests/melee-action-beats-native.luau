assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local client = game.StarterPlayer.StarterPlayerScripts.Client
local config = require(game.ReplicatedStorage.Shared.K0Config)
local advanced = require(client.AdvancedSkillMotion)
local melee = require(client.K0MeleeMotion)
local shield = require(client.K0ShieldBashMotion)
local body = require(client.MeleeWeightShift)
local checks, actions, seams = 0, 0, 0
local function check(value, message)
    checks += 1
    assert(value, message)
end
local function delta(a,b)
    local _, angle = a:ToObjectSpace(b):ToAxisAngle()
    return math.deg(math.abs(angle)), (a.Position-b.Position).Magnitude
end
for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
    for _, classId in {"knight","dwarf"} do
        local function review(d, combo)
            local function sample(age)
                local pose
                if d.id == "knight.common.bash" then pose = shield.sample(age,rig)
                elseif d.advanced or d.id == "knight.common.provoke" then pose = advanced.sample(classId,d,age,rig)
                else pose = melee.sample(classId,combo,age,nil,nil,d.id,rig) end
                return pose
            end
            local contact = d.windup+(d.hitDelay or 0)
            local duration = d.windup+d.active+d.recovery
            local function weighted(age)
                local pose = sample(age)
                body.apply(pose,classId,d.id,combo,age)
                return pose
            end
            local loaded = sample(contact*.48)
            local accent = weighted(contact*.48)
            local hipAngle = delta(loaded.rightHip or CFrame.identity,accent.rightHip)
            check(hipAngle>8,"Weight must load the supporting leg: "..tostring(d.id or combo))
            local finish, released = sample(duration), weighted(duration)
            for _, joint in {"torso","left","neck","rightHip","leftHip","rightKnee","leftKnee"} do
                local angle, offset = delta(finish[joint] or CFrame.identity,released[joint] or CFrame.identity)
                check(angle<.06 and offset<.0001,"Body settles: "..joint)
            end
            for pulse=1,d.pulses or 1 do
                local beat=contact+(pulse-1)*(d.interval or 0)
                local before,after=weighted(beat-1e-5),weighted(beat+1e-5)
                for _,joint in {"torso","left","right","weapon","root"} do
                    local angle,offset=delta(before[joint] or CFrame.identity,after[joint] or CFrame.identity)
                    check(angle<.4 and offset<.005,string.format("%s/%s pulse %d %s: %.3f deg, %.4f studs",classId,tostring(d.id or combo),pulse,joint,angle,offset))
                end
                seams+=1
            end
            actions+=1
        end
        for combo,d in config.BasicAttackProfiles[classId].attacks do review(d,combo) end
        for _,d in config.Skills[classId] do review(d,1) end
    end
end
-- Pairs used to share a base clip. Their preparation should identify the
-- role even with particle effects disabled.
for _, pair in {
    {"knight","knight.paladin.oath_of_dawn","knight.steel_knight.unyielding_front"},
    {"knight","knight.steel_knight.shield_breaker","knight.paladin.shield_verdict"},
    {"dwarf","dwarf.iron_axe.shatter_blow","dwarf.iron_axe.tremor_guard"},
    {"dwarf","dwarf.gunner.field_mortar","dwarf.gunner.blast_step"},
} do
    local shoulders={}
    for _,d in config.Skills[pair[1]] do
        if d.id==pair[2] or d.id==pair[3] then
            local age=d.windup*.48
            local pose=advanced.sample(pair[1],d,age,Enum.HumanoidRigType.R15)
            body.apply(pose,pair[1],d.id,1,age)
            shoulders[d.id]=pose.right
        end
    end
    check(delta(shoulders[pair[2]],shoulders[pair[3]])>18,"Distinct anticipation: "..pair[2])
end
local skills = require(game.ReplicatedStorage.Shared.AdvancedSkills).branches
local rig = Enum.HumanoidRigType.R15
for _, index in {1,12} do
    local d = skills.paladin.skills[index]
    local first = advanced.sample("knight",d,d.windup+.04,rig)
    local second = advanced.sample("knight",d,d.windup+d.interval+.04,rig)
    check(delta(first.right,second.right)>15,"Alternating follow-through: "..d.id)
end
local single = skills.gunner.skills[1]
local scatter = skills.gunner.skills[7]
local function kick(d)
    local aim = advanced.sample("dwarf",d,d.windup,rig)
    local recoil = advanced.sample("dwarf",d,d.windup+.04,rig)
    return delta(aim.elbow,recoil.elbow)
end
check(kick(scatter)>kick(single)+3,"Scatter Shot shoulder absorbs a heavier recoil")
print("MELEE_ACTION_BEATS_NATIVE "..game.HttpService:JSONEncode({pass=true,checks=checks,rigActions=actions,contacts=seams}))
