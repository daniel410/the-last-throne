-- Angles are additive in the existing bow/staff rig channels. Bow nock,
-- string length and the staff grip come from their original authored clips.
local Presentation = require(game.ReplicatedStorage.Shared.SkillPresentation)
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
    pierce=stance(v(14,-31,-3), -2, 28, 31),
    heavy=stance(v(15,-32,-13), -17, 31, 34),
    snap=stance(v(5,14,9), 20, 15, 23),
    fan=stance(v(10,-20,15), 39, 22, 32),
    broadside=stance(v(16,-33,18), 47, 32, 39),
    retreat=stance(v(-15,20,9), 22, 29, 28),
    advance=stance(v(16,-12,-8), -20, 24, 19),
    sky=stance(v(-16,-12,-10), -23, 24, 32),
    weave=stance(v(-6,24,-14), 25, 19, 28),
    canopy=stance(v(-24,20,-15), 34, 30, 38),
}
local function bowStance(d)
    if d.form=="ground" then return d.ultimate and bow.canopy or bow.sky end
    if d.ultimate and d.form=="cone" then return bow.broadside end
    local step = d.move or d.pulseMove
    if step then return step<0 and bow.retreat or bow.advance end
    if d.form=="cone" or d.effect=="multi" then return bow.fan end
    if d.effect=="rapid" or (d.pulses or 1)>1 then return bow.snap end
    if d.id=="elf.marksman.heavy_draw" then return bow.heavy end
    if d.form=="line" then return bow.pierce end
    if d.branch=="magic_archer" then return bow.weave end
    return d.id and bow.sight or bow.field
end

function Poses.bow(pose,d,age,since,betweenShots)
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
        local recoilTime = s == bow.heavy and .29 or s == bow.sky and .26 or s == bow.snap and .15 or .22
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
    orb=gesture(v(-19,22,16),v(38,-24,-20),v(12,19,-6),v(22,7,26),19),
    ring=gesture(v(-11,-33,-14),v(13,20,33),v(8,-29,-7),v(18,19,37),22),
    frost=gesture(v(17,19,-14),v(35,-19,-24),v(-8,16,-8),v(25,-15,3),16),
    storm=gesture(v(29,-20,19),v(48,13,27),v(-14,-18,10),v(47,-18,-14),20),
    iceRing=gesture(v(14,27,-18),v(-20,-11,-20),v(-12,23,5),v(22,-32,-41),20),
    cinder=gesture(v(-27,-20,15),v(16,26,22),v(17,-18,-6),v(41,24,18),27),
    earth=gesture(v(-34,16,-14),v(-22,18,23),v(21,12,-11),v(47,-8,19),32),
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
    if cue.effect=="lightning" then return spells.storm end
    if cue.effect=="earth" or cue.effect=="lava" or d.effect=="gravity" then return spells.earth end
    if profile=="water_orb" or cue.effect=="steam" then return spells.orb end
    if d.form=="area" or d.form=="ground" then
        if cue.effect=="frost" then return spells.iceRing end
        if cue.effect=="fire" then return spells.cinder end
        return spells.ring
    end
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
    local follow = 0
    local recovery = 1-smooth((age-d.windup-d.active)/d.recovery)
    if age>=d.windup+(d.hitDelay or 0) then
        local pulse,since = Presentation.beat(d,age)
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
        or (s == spells.earth or s == spells.caldera) and v(-16,0,7)
        or s == spells.ashfall and v(-8,14,12)
        or s == spells.hailfall and v(21,-6,-8)
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
end
return Poses
