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
		local lean = i % 2 == 0 and -.39 or .47
		beam('RaiderPalisadeStake', V(x, 2.05, .56), V(x + lean, top, .86), 1.24,
			timber:Lerp(palette.wood, i * .042), M.Wood)
	end
	beam('ReusedCrossRail', V(-7.65, 4.9, -.18), V(7.65, 4.6, -.18), .84, timber, M.Wood)
	beam('PalisadeKickBrace', V(-5.45, .83, -2.9), V(-4.22, 4.62, .13), .82, timber, M.Wood)
	beam('PalisadeKickBrace', V(5.45, .83, 2.9), V(4.25, 4.47, 1.02), .82, timber, M.Wood)
	for _, x in ipairs({-4.1, 4.05}) do
		part('PalisadeFootStrap', V(1.18, .9, .32), V(x, 2.87, .01), iron, M.CorrodedMetal)
	end
end

local function scouredBank(palette, part, beam)
	local slate = palette.rock:Lerp(palette.trim, .26)
	local earth = palette.ground:Lerp(palette.wood, .46)
	local exposedSoil = Color3.fromRGB(176, 149, 117)
	local weatheredBark = palette.wood:Lerp(Color3.fromRGB(133, 99, 76), .64)
	local splinteredWood = Color3.fromRGB(180, 135, 96)
	local crown = CFrame.new(.35, 2.07, 1.2) * CFrame.Angles(0, .16, -.06)
	local rise, frontToe, crest, rearToe = 4.3, -3.75, 1.15, 3.75
	local function fit(name, size, cf, color, material, shape)
		local rx, ry, rz = cf:ToEulerAnglesXYZ()
		part(name, size, cf.Position, color, material, false, V(rx, ry, rz), shape)
	end

	part('ExposedShaleFoot', V(17, 2.1, 9), V(0, .45, 0), slate, M.Slate)
	fit('ShearedBankFace', V(15.8, rise, crest - frontToe), crown * CFrame.new(0, 0, (frontToe + crest) / 2),
		earth, M.Ground, 'Wedge')
	fit('SlumpedBankFace', V(15.8, rise, rearToe - crest), crown * CFrame.new(0, 0, (rearToe + crest) / 2)
		* CFrame.Angles(0, math.pi, 0), earth:Lerp(slate, .21), M.Ground, 'Wedge')

	-- The thin, joined soil exposures follow the two slopes over the same crest.
	local function scarFace(toePoint, crestPoint, toe, width, color)
		local normal = crown:VectorToWorldSpace(V(0, 1, -rise / (crest - toe)).Unit)
		local a = crown:PointToWorldSpace(toePoint)
		local b = crown:PointToWorldSpace(crestPoint)
		local cf = CFrame.lookAlong((a + b) / 2 - normal * .055, b - a, normal)
		fit('PaleScouredSoil', V(width, .25, (b - a).Magnitude), cf, color, M.Ground)
	end
	for _, scar in ipairs({
		{ridgeX = -3.55, frontX = -5.6, rearX = -2.85, width = .88, color = exposedSoil},
		{ridgeX = -.38, frontX = -1.9, rearX = .83, width = .72, color = exposedSoil:Lerp(earth, .2)},
	}) do
		local ridge = V(scar.ridgeX, rise / 2, crest)
		for _, side in ipairs({
			{toe = frontToe, x = scar.frontX, length = .81},
			{toe = rearToe, x = scar.rearX, length = .76},
		}) do
			local endPoint = V(side.x, rise / 2 - rise * side.length, crest + (side.toe - crest) * side.length)
			scarFace(endPoint, ridge, side.toe, scar.width, scar.color)
		end
	end

	beam('UprootedAnchorRoot', V(6, 4.1, 1.9), V(4.4, 2.62, -.55), 1.8, weatheredBark, M.Wood)
	beam('ShearedRootTip', V(4.4, 2.62, -.55), V(3.45, 1.61, -3.57), 1.12, splinteredWood, M.Wood)
end

local function circuitPrototype(palette, part)
	local dressed = palette.rock:Lerp(palette.trim, .36)
	local copper = Color3.fromRGB(151, 106, 72)
	local patina = Color3.fromRGB(81, 126, 119)
	local castIron = Color3.fromRGB(78, 66, 62)
	local function pipe(name, length, diameter, at, color)
		local cylinder = part(name, V(length, diameter, diameter), at, color, M.Metal)
		cylinder.Shape = Enum.PartType.Cylinder
	end
	part('PrototypeBasaltPlinth', V(14.8, 2, 9), V(0, .35, 0), palette.rock, M.Basalt)
	part('PrototypeDressedBed', V(13.8, .64, 8.1), V(0, 1.58, 0), dressed, M.Slate)
	for _, x in ipairs({-4.85, 4.85}) do
		part('TrialManifoldSaddle', V(2.9, 1.22, 6.7), V(x, 2.42, 0), dressed, M.Basalt)
		part('TrialManifoldEnd', V(1.26, 1.32, 6.2), V(x, 3.58, 0), castIron, M.Metal)
	end
	for _, run in ipairs({
		{name = 'Supply', z = -1.98, y = 3.48, width = .94, color = copper},
		{name = 'Return', z = 2.12, y = 3.89, width = 1.28, color = patina},
	}) do
		pipe(run.name .. 'CircuitPipe', 9.7, run.width, V(0, run.y, run.z), run.color)
		for _, x in ipairs({-4.85, 4.85}) do
			pipe(run.name .. 'ManifoldFlange', 1.6, run.width + .38, V(x, run.y, run.z),
				run.color:Lerp(Color3.fromRGB(189, 173, 159), .32))
		end
	end
	part('SampleChamber', V(3.25, 2.62, 3.45), V(0, 3.17, 0), palette.rock, M.Basalt)
	part('SampleChamberLid', V(3.65, .35, 3.55), V(0, 4.61, 0), copper, M.Metal)
end

function Models.compose(id, palette, part, beam)
	if id == 'DW-05' then
		prisonPalisade(palette, part, beam)
	elseif id == 'GW-05' then
		scouredBank(palette, part, beam)
	else
		circuitPrototype(palette, part)
	end
end

return Models
