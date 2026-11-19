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
	local cutStone = palette.rock:Lerp(palette.trim, .52)
	local timber = palette.wood:Lerp(Color3.fromRGB(124, 81, 53), .51)
	local iron = Color3.fromRGB(127, 113, 99)
	part('BuriedRuinSill', V(16.6, 2, 6), V(0, .36, 0), palette.rock, M.Cobblestone)
	for i, x in ipairs({-6, -2, 2, 6}) do
		local height = i % 2 == 0 and 1.28 or 1.48
		part('SalvagedFoundationAshlar', V(3.84, height, 4), V(x, 1.23 + height / 2, .4),
			cutStone:Lerp(palette.rock, i * .075), M.Slate)
	end
	for i, x in ipairs({-6.8, -4.1, -1.45, 1.3, 4.05, 6.7}) do
		local top = 7.2 + (i % 3) * .42
		beam('RaiderPalisadeStake', V(x, 2.05, .7), V(x + .22, top, .94), 1.45,
			timber:Lerp(palette.wood, i * .055), M.Wood)
	end
	beam('ReusedCrossRail', V(-7.65, 4.9, -.18), V(7.65, 4.6, -.18), .84, timber, M.Wood)
	for _, x in ipairs({-5.45, 5.45}) do
		beam('PalisadeKickBrace', V(x, .83, -2.9), V(x, 4.65, .42), .82, timber, M.Wood)
	end
	for _, x in ipairs({-4.1, 4.05}) do
		part('PalisadeFootStrap', V(1.18, .9, .32), V(x + .08, 2.87, .02), iron, M.CorrodedMetal)
	end
end

local function scouredBank(palette, part, beam)
	local slate = palette.rock:Lerp(palette.trim, .26)
	local earth = palette.ground:Lerp(palette.wood, .46)
	local exposedSoil = Color3.fromRGB(176, 149, 117)
	local weatheredBark = palette.wood:Lerp(Color3.fromRGB(133, 99, 76), .64)
	local splinteredWood = Color3.fromRGB(180, 135, 96)
	local crownAt, crownAngles = V(.35, 2.07, 1.2), V(0, .16, -.06)
	local crown = CFrame.new(crownAt) * CFrame.Angles(crownAngles.X, crownAngles.Y, crownAngles.Z)
	part('ExposedShaleFoot', V(17, 2.1, 9), V(0, .45, 0), slate, M.Slate)
	part('ShearedBankCrown', V(15.8, 4.3, 7.5), crownAt, earth, M.Ground, false, crownAngles, 'Wedge')
	-- Keep each soil streak embedded in the wedge's sloped face.
	local function slope(x, z)
		return crown:PointToWorldSpace(V(x, z * 4.3 / 7.5 - .19, z))
	end
	beam('PaleScouredSoil', slope(-5.8, -1.08), slope(-4.15, 2.34), 1.04, exposedSoil, M.Sand)
	beam('PaleScouredSoil', slope(-2.85, -.9), slope(-1.2, 2.48), .91, exposedSoil:Lerp(earth, .08), M.Sand)
	beam('PaleScouredSoil', slope(.25, -.48), slope(1.12, 1.78), .8, exposedSoil:Lerp(earth, .16), M.Sand)
	beam('UprootedAnchorRoot', V(6, 4.1, 2.9), V(4.4, 2.28, -.55), 1.8, weatheredBark, M.Wood)
	beam('ShearedRootTip', V(4.4, 2.28, -.55), V(3.45, 1.61, -3.57), 1.12, splinteredWood, M.Wood)
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
		part('TrialManifoldEnd', V(1.26, 1.26, 6.2), V(x, 3.6, 0), dressed, M.Metal)
	end
	for _, run in ipairs({
		{name = 'Supply', z = -2.12, width = .94, color = copper},
		{name = 'Return', z = 2.12, width = 1.28, color = patina},
	}) do
		beam(run.name .. 'CircuitPipe', V(-4.85, 3.65, run.z), V(4.85, 3.65, run.z), run.width, run.color, M.Metal)
		for _, x in ipairs({-4.18, 4.18}) do
			local flangeWidth = run.width + .46
			part(run.name .. 'ManifoldFlange', V(.68, flangeWidth, flangeWidth), V(x, 3.65, run.z),
				run.color:Lerp(Color3.fromRGB(189, 173, 159), .32), M.Metal)
		end
	end
	part('SampleChamber', V(3.25, 2.62, 2.35), V(0, 3.17, 0), palette.rock, M.Basalt)
	part('SampleChamberLid', V(3.65, .35, 2.65), V(0, 4.61, 0), copper, M.Metal)
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
