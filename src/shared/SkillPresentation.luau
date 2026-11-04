-- Presentation contracts only. Explicit rows follow the stable branch order;
-- combat geometry, damage, statuses and unlocks remain in K0Config.
local Advanced = require(script.Parent.AdvancedSkills)
local P = {byId = {}}
local rows = {
 steel_knight = {"counter:slash", "sweep:slash", "slash:slash", "spin:slash", "shield:shield", "counter:shield", "sweep:slash", "shield:shield", "thrust:slash", "spin:slash", "sweep:slash", "slash:slash", "shield:shield"},
 paladin = {"slash:slash", "sweep:slash", "sweep:slash", "spin:holy", "chop:slash", "shield:shield", "sweep:slash", "shield:shield", "shield:shield", "spin:holy", "cross:slash", "slash:slash", "shield:holy"},
 iron_axe = {"chop:slash", "throw:axe", "sweep:earth", "chop:slash", "throw:axe", "slam:earth", "shield:shield", "throw:axe", "slam:earth", "slam:earth", "throw:axe", "slam:earth", "slam:earth"},
 gunner = {"shoot:bullet", "lob:bomb", "mortar:shell", "shoot:bullet", "lob:bomb", "mortar:shell", "shoot:bullet", "lob:bomb", "mortar:shell", "shoot:bullet", "lob:bomb", "mortar:shell", "mortar:shell"},
 marksman = {"draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "draw:arrow", "rain:rain", "draw:arrow"},
 magic_archer = {"draw:arrow", "draw:arrow", "rain:vine", "draw:arrow", "rain:lightning", "draw:vine", "draw:arrow", "draw:arrow", "rain:rain", "draw:arrow", "draw:arrow", "rain:vine", "rain:rain"},
 pyro = {"cast:fire", "area:steam", "area:fire", "cast:fire", "area:earth", "area:fire", "cast:earth", "ward:fire", "area:lava", "cast:fire", "cast:fire", "rain:ash", "area:lava"},
 cryo = {"cast:frost", "cast:frost", "area:frost", "cast:frost", "cast:lightning", "area:frost", "cast:lightning", "ward:frost", "area:frost", "cast:frost", "cast:lightning", "rain:hail", "area:frost"},
}
local function add(id, text)
 local motion, effect = text:match("^(%w+):(%w+)$")
 assert(motion and effect, "Invalid skill presentation: " .. id)
 P.byId[id] = {motion = motion, effect = effect}
end
for branch, list in pairs(rows) do
 local definitions = Advanced.branches[branch].skills
 assert(#list == #definitions, "Presentation coverage: " .. branch)
 for i, text in ipairs(list) do add(definitions[i].id, text) end
end
local common = {
 knight_driving_thrust="thrust:slash", knight_crescent_cut="sweep:slash", knight_guarded_strike="shield:shield",
 dwarf_hooking_chop="chop:slash", dwarf_low_sweep="sweep:slash", dwarf_braced_throw="throw:axe",
 elf_retreating_shot="draw:arrow", elf_pinning_shot="draw:arrow", elf_arrow_screen="rain:rain",
 mage_wind_lance="cast:wind", mage_tidal_ring="area:water", mage_arcane_ward="ward:arcane",
 ["knight.common.bash"]="shield:shield", ["knight.common.whirlwind"]="spin:slash", ["knight.common.provoke"]="shield:taunt",
 ["dwarf.common.overhead"]="chop:slash", ["dwarf.common.throw"]="throw:axe", ["dwarf.common.ground"]="slam:earth",
 ["elf.common.aimed"]="draw:arrow", ["elf.common.rapid"]="draw:arrow", ["elf.common.multi"]="draw:arrow",
 ["mage.common.mana_bolt"]="cast:arcane", ["mage.common.water_ball"]="cast:water", ["mage.common.gravity"]="area:gravity",
}
for id, text in pairs(common) do add(id, text) end
function P.get(d) return P.byId[d.id] end
-- A volley fills the actual sector. A melee sector never becomes a full disc.
function P.sector(d)
 return d.form == "area" and 360 or d.angle or 80
end
function P.radius(d) return d.form == "ground" and d.radius or d.range end
-- First contact and each following impulse match the server pulse schedule.
function P.beat(d, age)
 local contact = d.windup + (d.hitDelay or 0)
 if age < contact then return 0, age / contact end
 local interval = d.interval or .3
 local pulse = math.min(d.pulses or 1, math.floor((age-contact)/interval)+1)
 return pulse, age-contact-(pulse-1)*interval
end
return P
