-- Additive weight transfer in character space. The held weapon keeps its
-- authored hand socket. Locomotion owns the legs whenever the actor is moving.
local shared = game:GetService("ReplicatedStorage").Shared
local Config = require(shared.K0Config)
local Presentation = require(shared.SkillPresentation)
local WeightShift = {}

local function stroke(pitch, twist, roll, compression, step, counterArm)
    return {coil = Vector3.new(pitch, twist, roll), compression = compression,
        step = step, counterArm = counterArm or 0}
end

local basics = {
    knight = {stroke(6, -8, -6, 15, .14), stroke(-8, 7, 7, 24, -.16), stroke(4, -5, -9, 19, .22)},
    dwarf = {stroke(14, -10, -9, 25, .16, 27), stroke(-4, 19, 11, 20, -.22, -32),
        stroke(11, -23, -12, 28, .27, 38)},
}
local skills = {
    slash = stroke(8,-14,-7,16,.18), cross = stroke(4,-15,-9,19,.21),
    sweep = stroke(8,-22,-10,22,.24,25), spin = stroke(8,-18,-8,25,.18),
    counter = stroke(13,18,7,24,-.17), chop = stroke(17,-14,-10,26,.19,30),
    thrust = stroke(6,-14,-5,22,.22), shield = stroke(12,16,7,27,-.20),
    throw = stroke(-7,-24,-10,18,.24,35), slam = stroke(19,-9,-8,30,.18,32),
    shoot = stroke(4,8,3,13,-.10), mortar = stroke(12,10,5,26,-.16),
    lob = stroke(-6,-18,-8,20,.20,28), challenge = stroke(10,12,6,23,-.14),
}
local byId = {}
for classId in basics do
    for _, skill in Config.Skills[classId] do
        local kind = skill.id == "knight.common.provoke" and "challenge" or Presentation.get(skill).motion
        byId[skill.id] = {definition = skill, stroke = assert(skills[kind]), classId = classId}
    end
end

local function smooth(x)
    x = math.clamp(x, 0, 1)
    return x*x*(3-2*x)
end

local function angles(x,y,z)
    return CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
end

function WeightShift.apply(pose, classId, skillId, combo, age)
    if not basics[classId] then return end
    local d, style
    if skillId then
        local row = byId[skillId]
        if not row or row.classId ~= classId then return end
        d, style = row.definition, row.stroke
    else
        combo = math.clamp(combo or 1, 1, 3)
        d, style = Config.BasicAttackProfiles[classId].attacks[combo], basics[classId][combo]
    end
    local contact = d.windup + (d.hitDelay or 0)
    -- The hips initiate the stroke. The chest catches up, the off hand
    -- balances the weapon, and the planted leg absorbs its momentum.
    local phase = age / contact
    local load = smooth(phase/.48) * (1-smooth((phase-.48)/.49))
    local since = age-contact
    local pulses = d.pulses or 1
    if pulses > 1 and since >= 0 then
        local index = math.min(pulses-1, math.floor(since/d.interval))
        since -= index*d.interval
        if index < pulses-1 then
            local cycle = since/d.interval
            load += .56*smooth((cycle-.28)/.35)*(1-smooth((cycle-.63)/.37))
        end
    end
    local follow = d.active - (pulses-1)*(d.interval or 0)
    local brakeTime = math.min(follow + d.recovery*.35, d.interval or .32)
    local brake = smooth(since/(brakeTime*.32))*(1-smooth((since/brakeTime-.32)/.68))
    local transfer = load - .68*brake
    local coil = style.coil * transfer
    local shift = style.step * transfer
    local crouch = style.compression * (load+.85*brake)
    local center = Vector3.new(shift, -.006*crouch, .09*load-.14*brake)
    local chest = coil
    if not skillId and combo == 1 then
        -- Both openers already accelerate rapidly out of the high guard.
        chest *= .48
        center *= .48
    elseif not skillId and classId == "knight" and combo == 3 then
        -- Keep the finishing edge level as the hips pivot under it.
        chest = Vector3.new(0,coil.Y*.24,0)
        center = Vector3.new(shift*.32,0,0)
    end
    pose.torso = CFrame.new(center) * angles(chest.X,chest.Y,chest.Z) * (pose.torso or CFrame.identity)
    pose.neck = (pose.neck or CFrame.identity) * angles(-coil.X*.5,-coil.Y*.62,-coil.Z*.5)
    pose.rightHip = (pose.rightHip or CFrame.identity) * angles(-crouch*.72,0,-shift*32)
    pose.leftHip = (pose.leftHip or CFrame.identity) * angles(-crouch*.35,0,shift*23)
    pose.rightKnee = (pose.rightKnee or CFrame.identity) * angles(crouch,0,0)
    pose.leftKnee = (pose.leftKnee or CFrame.identity) * angles(crouch*.64,0,0)
    if classId == "knight" and not skillId then
        pose.left = (pose.left or CFrame.identity) * angles(14*load,0,9*transfer)
        pose.leftElbow = (pose.leftElbow or CFrame.identity) * angles(16*load-6*brake,0,0)
    elseif classId == "dwarf" and style.counterArm ~= 0 then
        pose.left = (pose.left or CFrame.identity) * angles(9*load,0,style.counterArm*transfer)
        pose.leftElbow = (pose.leftElbow or CFrame.identity) * angles(14*load-8*brake,0,0)
    end
end
return WeightShift
