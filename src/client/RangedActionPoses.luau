-- Angles are additive in the existing bow/staff rig channels. Bow nock,
-- string length and the staff grip come from their original authored clips.
local Presentation = require(game.ReplicatedStorage.Shared.SkillPresentation)
local FinalBeat = require(script.Parent.SkillFinalBeat)
local Poses = {}
local v = Vector3.new

local function smooth(x)
    x = math.clamp(x,0,1)
    return x*x*(3-2*x)
end

local function add(pose, joint, offset)
    local value = (pose.angles[joint] or Vector3.zero) + offset
    pose.angles[joint] = value
    pose[joint] = CFrame.Angles(math.rad(value.X),math.rad(value.Y),math.rad(value.Z))
end

-- Shoulder line, bow cant, planted knee bend and draw-elbow follow-through.
local function stance(chest, cant, bend, elbow)
    return {chest=chest, cant=cant, bend=bend, elbow=elbow}
end
local bow = {
    field=stance(v(7,-15,-7), -12, 15, 22),
    sight=stance(v(9,-23,-10), -5, 24, 14),
    pin=stance(v(12,-16,3), 8, 27, 10),
    pierce=stance(v(14,-31,-3), -2, 28, 31),
    elementalPierce=stance(v(9,-25,13), 23, 24, 35),
    heavy=stance(v(15,-32,-13), -17, 31, 34),
    snap=stance(v(5,14,9), 20, 15, 23),
    crossfire=stance(v(9,-8,8), 12, 24, 26),
    fan=stance(v(10,-20,15), 39, 22, 32),
    fanBreak=stance(v(18,-28,12), 29, 28, 38),
    broadside=stance(v(16,-33,18), 47, 32, 39),
    retreat=stance(v(-15,20,9), 22, 29, 28),
    advance=stance(v(16,-12,-8), -20, 24, 19),
    glide=stance(v(14,-19,12), 32, 22, 25),
    sky=stance(v(-16,-12,-10), -23, 24, 32),
    weave=stance(v(-6,24,-14), 25, 19, 28),
    canopy=stance(v(-24,20,-15), 34, 30, 38),
}
local function bowStance(d)
    if d.form=="ground" then return d.ultimate and bow.canopy or bow.sky end
    if d.ultimate and d.form=="cone" then return bow.broadside end
    if d.id=="elf.magic_archer.gliding_shot" then return bow.glide end
    local step = d.move or d.pulseMove
    if step then return step<0 and bow.retreat or bow.advance end
    if d.id=="elf.marksman.fan_break" then return bow.fanBreak end
    if d.form=="cone" or d.effect=="multi" then return bow.fan end
    if d.crosscut then return bow.crossfire end
    if d.effect=="rapid" or (d.pulses or 1)>1 then return bow.snap end
    if d.id=="elf.marksman.heavy_draw" then return bow.heavy end
    if d.id=="elf_pinning_shot" then return bow.pin end
    if d.id=="elf.magic_archer.elemental_pierce" then return bow.elementalPierce end
    if d.form=="line" then return bow.pierce end
    if d.branch=="magic_archer" then return bow.weave end
    return d.id and bow.sight or bow.field
end

function Poses.bow(pose,d,age,since,betweenShots,pulse)
    local s = bowStance(d)
    local phase = age/d.windup
    local load = smooth(phase/.55)*(1-smooth((phase-.55)/.45))
    if d.id=="elf.marksman.heavy_draw" then
        load = smooth(phase/.42)*(1-.6*smooth((phase-.48)/.52))
        load *= 1-smooth((age-d.windup)/.09)
    end
    local support = smooth(phase/.64)*(1-smooth((age-d.windup-d.active)/d.recovery))
    local recoil, redraw = 0,0
    if since then
        local recoilTime = s == bow.heavy and .29 or s == bow.sky and .26
            or s == bow.snap and .15 or s == bow.pin and .13 or .22
        local span = math.min(recoilTime, d.interval or d.shotInterval or recoilTime)
        recoil = smooth(since/(span*.23))*(1-smooth((since/span-.23)/.77))
        if betweenShots then
            local cycle = since/(d.interval or d.shotInterval)
            redraw = smooth((cycle-.24)/.32)*(1-smooth((cycle-.56)/.44))
        end
    end
    local settle = 1-smooth((age-d.windup-d.active)/d.recovery)
    local coil = load+.44*redraw
    recoil *= settle
    -- The bow hand stays on the sight line while the release elbow travels
    -- behind the cheek. Rotation about the arrow axis changes cant, not aim.
    local releaseLift = s == bow.sky and -9 or s == bow.canopy and -13 or s == bow.heavy and 5 or 0
    add(pose,"torso",s.chest*(coil-.36*recoil)+v(releaseLift*recoil,0,0))
    add(pose,"neck",s.chest*(-.58*coil+.18*recoil))
    add(pose,"left",v(-12*coil+4*recoil,4*coil,s.cant*.45*coil))
    add(pose,"right",v(13*coil-9*recoil,-15*coil+s.elbow*recoil,12*coil+9*recoil))
    add(pose,"elbow",v(-12*coil+18*recoil,0,0))
    add(pose,"weapon",v(0,0,s.cant*(.70*coil+.30*support-.20*recoil)))
    local knees = s.bend*(.6*support+.4*coil+.26*recoil)
    add(pose,"rightHip",v(-.65*knees,0,6*support))
    add(pose,"leftHip",v(-.36*knees,0,-7*support))
    add(pose,"rightKnee",v(knees,0,0))
    add(pose,"leftKnee",v(knees*.65,0,0))
    if s == bow.crossfire and since then
        -- The chest follows the sweep while the bow stays on its locked line.
        local pivot = betweenShots and redraw or .55*recoil
        add(pose,"torso",v(0,d.crosscutAngle,7)*pivot)
        add(pose,"leftKnee",v(11*pivot,0,0))
    end
    if s == bow.heavy and since then
        local settle = smooth(since/.08)*(1-smooth((since-.08)/.15))
        add(pose,"right",v(3,12,11)*settle)
        add(pose,"neck",v(-4,-6,2)*settle)
        add(pose,"leftKnee",v(10,0,0)*settle)
    end
    if s == bow.fanBreak then
        -- Brace the lead leg through the spread while the draw hand opens.
        add(pose,"torso",v(-7,10,-8)*recoil)
        add(pose,"leftHip",v(-9,0,-6)*recoil)
        add(pose,"leftKnee",v(15,0,0)*recoil)
        add(pose,"right",v(-4,16,12)*recoil)
    end
    if d.id=="elf_retreating_shot" then
        -- Leave the bow on the sight line while the rear leg takes the step.
        add(pose,"torso",v(-11,-4,8)*load+v(12,6,-4)*recoil)
        add(pose,"rightHip",v(-14,0,-5)*recoil)
        add(pose,"rightKnee",v(20,0,0)*recoil)
        add(pose,"right",v(-6,18,11)*recoil)
    end
    if s == bow.glide then
        -- Extend the trailing leg during the draw and catch the release on the lead foot.
        add(pose,"rightHip",v(24,0,8)*load)
        add(pose,"rightKnee",v(-17,0,0)*load)
        add(pose,"leftHip",v(-18,0,-5)*recoil)
        add(pose,"leftKnee",v(23,0,0)*recoil)
    end
    local finish = since and FinalBeat.weight(d,pulse,since) or 0
    if finish>0 then
        if d.form=="ground" then
            -- The last lob ends with the empty hand dropping away from the bow.
            add(pose,"right",v(-14,12,-18)*finish)
            add(pose,"torso",v(9,0,-4)*finish)
        else
            -- On the final volley the elbow opens and the lead knee takes the weight.
            add(pose,"right",v(-8,21,13)*finish)
            add(pose,"elbow",v(13,0,0)*finish)
            add(pose,"leftKnee",v(12,0,0)*finish)
        end
    end
end

-- The staff hand traces the preparation arc, the guiding palm shapes the
-- spell at release. These silhouettes also work on single-segment R6 arms.
local function gesture(staff, palm, chest, openPalm, bend)
    return {staff=staff,palm=palm,chest=chest,openPalm=openPalm,bend=bend}
end
local spells = {
    strike=gesture(v(22,-29,-14),v(33,11,24),v(12,-24,-9),v(-16,-8,21),22),
    bolt=gesture(v(-12,16,-10),v(22,-20,12),v(5,14,-5),v(21,5,-14),13),
    lance=gesture(v(-25,-21,10),v(39,7,22),v(9,-21,7),v(37,-10,-17),22),
    dart=gesture(v(8,18,-22),v(-13,-18,10),v(-4,15,6),v(13,23,-6),12),
    shatter=gesture(v(14,19,-23),v(29,-26,10),v(-5,17,6),v(31,10,-9),16),
    orb=gesture(v(-19,22,16),v(38,-24,-20),v(12,19,-6),v(22,7,26),19),
    ring=gesture(v(-11,-33,-14),v(13,20,33),v(8,-29,-7),v(18,19,37),22),
    frost=gesture(v(17,19,-14),v(35,-19,-24),v(-8,16,-8),v(25,-15,3),16),
    glacialSpike=gesture(v(-26,24,-18),v(31,-28,-12),v(15,10,6),v(42,-16,-10),27),
    storm=gesture(v(29,-20,19),v(48,13,27),v(-14,-18,10),v(47,-18,-14),20),
    thunderSpear=gesture(v(-26,-15,17),v(39,26,-22),v(9,-22,9),v(40,-13,-16),23),
    chain=gesture(v(34,-21,26),v(26,23,-30),v(-9,17,-6),v(31,-37,-13),19),
    iceRing=gesture(v(14,27,-18),v(-20,-11,-20),v(-12,23,5),v(22,-32,-41),20),
    frostStep=gesture(v(-28,22,16),v(-9,18,-36),v(19,-17,12),v(-24,27,-32),26),
    cinder=gesture(v(-27,-20,15),v(16,26,22),v(17,-18,-6),v(41,24,18),27),
    earth=gesture(v(-34,16,-14),v(-22,18,23),v(21,12,-11),v(47,-8,19),32),
    stone=gesture(v(-32,-19,12),v(22,17,34),v(17,-19,-7),v(50,-14,5),26),
    ward=gesture(v(13,-24,17),v(47,-16,-28),v(11,14,-10),v(34,12,30),23),
    ashfall=gesture(v(37,-22,-24),v(43,25,25),v(-18,-20,12),v(-12,13,34),23),
    hailfall=gesture(v(28,17,-10),v(48,-13,10),v(-22,14,-5),v(12,-18,15),26),
    caldera=gesture(v(-40,-24,-17),v(-27,22,32),v(25,-24,-12),v(72,-17,20),35),
    tempest=gesture(v(46,19,16),v(57,-27,-22),v(-23,25,12),v(29,20,41),30),
}
local function spellGesture(d,profile)
    if profile=="staff_strike" then return spells.strike end
    if d.ultimate then return d.branch=="pyro" and spells.caldera or spells.tempest end
    if profile=="ward" then return spells.ward end
    local cue = Presentation.get(d)
    if not cue then return spells.bolt end
    if cue.motion=="rain" then return cue.effect=="hail" and spells.hailfall or spells.ashfall end
    if d.form=="chain" then return spells.chain end
    if d.id=="mage.pyro.stone_lance" then return spells.stone end
    if d.id=="mage.cryo.thunder_spear" then return spells.thunderSpear end
    if cue.effect=="lightning" then return spells.storm end
    if cue.effect=="earth" or cue.effect=="lava" or d.effect=="gravity" then return spells.earth end
    if profile=="water_orb" or cue.effect=="steam" then return spells.orb end
    if d.form=="area" or d.form=="ground" then
        if d.id=="mage.cryo.frost_step" then return spells.frostStep end
        if cue.effect=="frost" then return spells.iceRing end
        if cue.effect=="fire" then return spells.cinder end
        return spells.ring
    end
    if d.id=="mage.cryo.shatter_dart" then return spells.shatter end
    if d.id=="mage.cryo.glacial_spike" then return spells.glacialSpike end
    if d.id:find("dart",1,true) then return spells.dart end
    if cue.effect=="frost" then return spells.frost end
    if d.form=="line" or d.branch=="pyro" then return spells.lance end
    return spells.bolt
end
function Poses.mage(pose,d,profile,age)
    local s = spellGesture(d,profile)
    local phase = age/d.windup
    local wind = smooth(phase/.58)*(1-smooth((phase-.58)/.42))
    local guide = smooth((phase-.48)/.52)
    local follow, finish = 0, 0
    local recovery = 1-smooth((age-d.windup-d.active)/d.recovery)
    if age>=d.windup+(d.hitDelay or 0) then
        local pulse,since = Presentation.beat(d,age)
        finish = FinalBeat.weight(d,pulse,since)
        local span = math.min(.22,d.interval or .22)
        follow = smooth(since/(span*.28))*(1-smooth((since/span-.28)/.72))
        if pulse<(d.pulses or 1) then
            local cycle = since/d.interval
            wind = .52*smooth((cycle-.25)/.34)*(1-smooth((cycle-.59)/.41))
        end
        local channel = (d.form=="area" or d.form=="ground") and (d.pulses or 1)>1
        guide = 1-(channel and .23 or .64)*wind
    end
    guide *= recovery
    follow *= recovery
    add(pose,"right",s.staff*(wind-.43*follow))
    local palmRelease = s == spells.iceRing and v(0,-9,-20)
        or s == spells.cinder and v(17,0,8)
        or s == spells.storm and v(-10,14,0)
        or s == spells.thunderSpear and v(-17,-19,23)
        or s == spells.chain and v(-22,-18,37)
        or (s == spells.earth or s == spells.caldera) and v(-16,0,7)
        or s == spells.stone and v(-24,-14,-8)
        or s == spells.ashfall and v(-8,14,12)
        or s == spells.hailfall and v(21,-6,-8)
        or s == spells.shatter and v(-26,15,20)
        or s == spells.glacialSpike and v(23,-12,-13)
        or Vector3.zero
    add(pose,"left",s.palm*wind+s.openPalm*guide+palmRelease*follow)
    add(pose,"torso",s.chest*(wind-.48*follow))
    add(pose,"neck",s.chest*(-.45*wind+.21*follow))
    add(pose,"elbow",v(-16*wind+11*follow,0,0))
    add(pose,"leftElbow",v(-22*wind+14*guide,0,0))
    local knees = s.bend*(wind+.38*guide+.37*follow)
    add(pose,"rightHip",v(-.64*knees,0,-7*wind))
    add(pose,"leftHip",v(-.4*knees,0,7*wind))
    add(pose,"rightKnee",v(knees,0,0))
    add(pose,"leftKnee",v(.7*knees,0,0))
    if d.id=="mage.cryo.frost_lance" then
        add(pose,"leftElbow",v(24,0,0)*follow)
        add(pose,"left",v(-12,-8,-14)*follow)
        add(pose,"torso",v(-5,8,-3)*follow)
    end
    if s == spells.frostStep then
        -- Sweep the guiding palm back as the front leg checks the slide.
        add(pose,"left",v(-30,29,-12)*follow)
        add(pose,"rightHip",v(20,0,-5)*wind)
        add(pose,"rightKnee",v(-18,0,0)*wind)
        add(pose,"leftKnee",v(21,0,0)*follow)
    end
    if s == spells.stone then
        add(pose,"leftElbow",v(20,0,0)*follow)
        add(pose,"torso",v(10,0,5)*follow)
    end
    if s == spells.thunderSpear then
        add(pose,"right",v(21,7,-14)*follow)
        add(pose,"leftElbow",v(21,0,0)*follow)
    end
    if finish>0 then
        if s == spells.caldera then
            -- Drive the staff down and push the other palm up with the eruption.
            add(pose,"right",v(-33,-8,-8)*finish)
            add(pose,"left",v(24,-6,9)*finish)
            add(pose,"torso",v(14,-8,-6)*finish)
            add(pose,"rightKnee",v(18*finish,0,0))
        elseif s == spells.tempest then
            -- Pull the guiding arm inward as the storm closes around its eye.
            add(pose,"left",v(-23,26,-32)*finish)
            add(pose,"leftElbow",v(-26*finish,0,0))
            add(pose,"torso",v(-7,18,8)*finish)
        else
            local ash = s == spells.ashfall
            add(pose,"left",(ash and v(-12,22,23) or v(26,-5,-10))*finish)
            add(pose,"torso",(ash and v(7,13,5) or v(16,0,-5))*finish)
            add(pose,"rightKnee",v((ash and 6 or 14)*finish,0,0))
        end
    end
end
return Poses
