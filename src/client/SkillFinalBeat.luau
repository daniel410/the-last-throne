-- Follow-through timing for the skills with an authored final pulse.
local FinalBeat = {}
local durations = {
    ["knight.steel_knight.blade_storm"] = .23,
    ["knight.paladin.oathbound_assault"] = .22,
    ["dwarf.iron_axe.mountain_collapse"] = .28,
    ["dwarf.gunner.siege_barrage"] = .30,
    ["elf.marksman.grand_volley"] = .25,
    ["elf.magic_archer.spirit_arrowfall"] = .23,
    ["mage.pyro.ashfall"] = .24,
    ["mage.cryo.hailfall"] = .22,
}

function FinalBeat.isFinal(d, pulse)
    return durations[d.id] ~= nil and d.pulses > 1 and pulse == d.pulses
end

function FinalBeat.weight(d, pulse, elapsed)
    if not FinalBeat.isFinal(d, pulse) then return 0 end
    local phase = math.clamp(elapsed / durations[d.id], 0, 1)
    local rise = math.min(1, phase / .22)
    local fall = math.max(0, (phase - .22) / .78)
    return rise * rise * (3 - 2 * rise) * (1 - fall * fall * (3 - 2 * fall))
end

return FinalBeat
