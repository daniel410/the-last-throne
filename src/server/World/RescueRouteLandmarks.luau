-- Native scenery for the rescue and repair routes. Interactive props are built separately.
local Models = {}
local V = Vector3.new
local M = Enum.Material

Models.profiles = {
	['DW-05'] = {name = 'RuinedPrisonPalisade', goal = 'prisoners'},
	['GW-05'] = {name = 'VenomcoilScouredBank', goal = 'rope'},
	['EC-05'] = {name = 'VaultCircuitPrototype', goal = 'crew'},
}

local function prisonPalisade(palette, part, beam)
	local cutStone = palette.rock:Lerp(palette.trim, .31)
	local timber = palette.wood:Lerp(Color3.fromRGB(112, 74, 49), .45)
	local iron = Color3.fromRGB(97, 83, 72)
	part('BuriedRuinSill', V(16.6, 2, 6), V(0, .36, 0), palette.rock, M.Cobblestone)
	for i, x in ipairs({-6, -2, 2, 6}) do
		part('SalvagedFoundationAshlar', V(3.85, 1.25, 4), V(x, 1.75, .4),
			cutStone:Lerp(palette.rock, i * .11), M.Slate)
	end
	for i, x in ipairs({-6.8, -4.1, -1.45, 1.3, 4.05, 6.7}) do
		local top = 7.2 + (i % 3) * .42
		beam('RaiderPalisadeStake', V(x, 2.05, .7), V(x + .22, top, .94), 1.45,
			timber:Lerp(palette.wood, i * .055), M.Wood)
	end
	beam('ReusedCrossRail', V(-7.65, 4.9, -.18), V(7.65, 4.6, -.18), .84, timber, M.Wood)
	for _, x in ipairs({-5.45, 5.45}) do
		beam('PalisadeKickBrace', V(x, .83, -2.9), V(x, 4.65, .42), .82, timber, M.Wood)
		part('SalvagedRailStrap', V(.64, 1.42, .25), V(x, 4.75, -.66), iron, M.CorrodedMetal)
	end
end

local function scouredBank(palette, part, beam)
	local slate = palette.rock:Lerp(palette.trim, .26)
	local earth = palette.ground:Lerp(palette.wood, .46)
	local cut = Color3.fromRGB(142, 116, 94)
	part('ExposedShaleFoot', V(17, 2.1, 9), V(0, .45, 0), slate, M.Slate)
	part('ShearedBankCrown', V(15.8, 4.3, 7.5), V(.35, 2.07, 1.2), earth, M.Ground,
		false, V(0, .16, -.06), 'Wedge')
	for i, x in ipairs({-5.7, -2, 1.65}) do
		local z = -2.8 + i * .61
		beam('PaleScouredSoil', V(x - .75, 1.55, z - 1.65), V(x + 1.1, 2.4, z + 1.68),
			.68, cut:Lerp(earth, i * .12), M.Ground)
	end
	beam('UprootedAnchorRoot', V(6, 4.1, 2.9), V(4.4, 2.2, -.55), 1.8, palette.wood, M.Wood)
	beam('ShearedRootTip', V(4.4, 2.2, -.55), V(3.45, .68, -3.7), 1, cut, M.Wood)
	part('DisplacedShaleFlake', V(3.2, 1.65, 3.4), V(-6.1, .47, -3.5), slate, M.Slate,
		false, V(0, -.26, .09), 'Corner')
end

local function circuitPrototype(palette, part, beam)
	local dressed = palette.rock:Lerp(palette.trim, .36)
	local copper = Color3.fromRGB(151, 106, 72)
	local patina = Color3.fromRGB(81, 126, 119)
	part('PrototypeBasaltPlinth', V(14.8, 2, 9), V(0, .35, 0), palette.rock, M.Basalt)
	part('PrototypeDressedBed', V(13.8, .64, 8.1), V(0, 1.58, 0), dressed, M.Slate)
	for _, x in ipairs({-4.85, 4.85}) do
		part('TrialManifoldSaddle', V(2.9, 1.22, 6.7), V(x, 2.42, 0), dressed, M.Basalt)
		part('TrialManifoldEnd', V(1.42, 1.5, 6.2), V(x, 3.35, 0), copper, M.Metal)
	end
	for _, run in ipairs({{z = -2.12, metal = copper}, {z = 2.12, metal = patina}}) do
		beam('ClosedCircuitPipe', V(-4.85, 3.65, run.z), V(4.85, 3.65, run.z), 1.1, run.metal, M.Metal)
		for _, x in ipairs({-2.9, 2.9}) do
			part('PrototypePipeCoupling', V(.67, 1.44, 1.44), V(x, 3.65, run.z), dressed, M.Metal)
		end
	end
	part('SampleChamber', V(3.25, 2.25, 3), V(0, 3.65, 0), palette.rock, M.Basalt)
	part('SampleChamberLid', V(3.65, .35, 3.35), V(0, 4.91, 0), copper, M.Metal)
end

function Models.compose(id, palette, part, beam)
	if id == 'DW-05' then
		prisonPalisade(palette, part, beam)
	elseif id == 'GW-05' then
		scouredBank(palette, part, beam)
	else
		circuitPrototype(palette, part, beam)
	end
end

return Models
