-- Roadside facilities sit on the existing JourneyPass top outside its visual travel line.
local Kit = require(script.Parent.EpicEnvironmentKit)
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local palette = Kit.palette

local function convoyDrain(part)
	local deepwood = palette.Deepwood
	local shale = deepwood.rock:Lerp(deepwood.wood, .39)
	local oldTimber = deepwood.wood:Lerp(deepwood.trim, .24)
	part('SedimentApron', V(8.4, 1.4, 12.2), V(-.7, .42, 0), shale, M.Ground, 'Wedge', 0, math.pi / 2)
	part('DrainBed', V(3.8, .42, 11.7), V(1.1, .42, 0), C(63, 63, 50), M.Ground)
	part('BuriedDrainBack', V(2.2, 2.4, 13.2), V(3.4, .87, 0), shale, M.Slate)
	for _, endZ in ipairs({-1, 1}) do
		part('SplitTimberFlume', V(1.15, 1.34, 6.7), V(-1, 1.32, endZ * 3.5), oldTimber, M.Wood, nil, 0, endZ * .045)
		part('FlumeEndgrain', V(1.16, 1.23, .25), V(-1.13, 1.31, endZ * 6.77), C(144, 104, 76), M.Wood)
		part('FlumeFoot', V(4.4, .85, 1.8), V(.5, .51, endZ * 4.6), deepwood.wood, M.Wood, nil, 0, endZ * -.08)
	end
	part('SplitTimberFlume', V(1.3, 1.35, 12.75), V(2.66, 1.38, 0), oldTimber, M.Wood)
end

local function surveyRest(part)
	local forest = palette.Gloamwood
	local vale = palette.FrozenVale
	local silverwood = forest.wood:Lerp(vale.trim, .49)
	part('SurveyBallast', V(8.6, 2.15, 10.8), V(0, .77, 0), forest.rock, M.Slate, 'Wedge', 0, math.pi / 2)
	part('LeeSideSnow', V(4.9, 1.26, 11.1), V(-2.45, .57, .2), vale.ground, M.Snow, 'Wedge', 0, -math.pi / 2)
	part('LeaningSurveyStake', V(1.22, 7.4, 1.3), V(.12, 3.82, .28), silverwood, M.Wood, nil, -.06, .12, -.16)
	part('StakeBrace', V(1.04, 5.1, 1.25), V(1.63, 2.37, .25), forest.wood:Lerp(silverwood, .39), M.Wood, nil, -.04, -.14, -.45)
	part('SurveySightVane', V(4.4, .92, 1.13), V(-.55, 5.92, .52), silverwood, M.Wood, nil, .02, .06, .11)
	for index = 1, 3 do
		part('SurveyGraduation', V(.71, .21, 1.34), V(-.19 - index * .1, 5.32 - index * .64, .22),
			forest.wood, M.Wood, nil, -.06, .12, -.16)
	end
end

local function culvertHeadwall(part)
	local vale = palette.FrozenVale
	local caldera = palette.EmberCaldera
	local cut = vale.trim:Lerp(caldera.rock, .28)
	part('MeltApron', V(12.6, 1.15, 9.8), V(-.15, .48, 0), caldera.rock:Lerp(cut, .19), M.Basalt, 'Wedge', 0, math.pi / 2)
	part('ShadowedCulvertBed', V(9.22, .33, 4.25), V(-.9, .45, 0), C(61, 65, 77), M.Slate)
	part('BuriedCulvertBack', V(1.1, 3.2, 6.5), V(4, 1.53, 0), caldera.rock, M.Basalt)
	for _, side in ipairs({-1, 1}) do
		part('RetainingWing', V(8.4, 3.05, 1.72), V(.5, 1.43, side * 3.15),
			vale.rock, M.Slate, 'Wedge', 0, side * .15)
		part('AbutmentStone', V(2.85, 3.14, 2.35), V(-.33, 1.45, side * 2.99), cut, M.Slate)
		part('FrozenWingFoot', V(6.37, 1.85, 3.05), V(1.14, .73, side * 4.9), vale.ground, M.Snow, 'Wedge', 0, side * math.pi / 2)
	end
	part('CulvertLintel', V(3.8, 1.05, 8.8), V(-.34, 3.38, 0), cut, M.Slate)
	part('CulvertCrownSnow', V(3.1, .47, 8.2), V(.03, 3.95, .13), vale.ground, M.Snow, 'Wedge', 0, math.pi / 2)
end

local function freightGauge(part)
	local caldera = palette.EmberCaldera
	local iron = caldera.rock:Lerp(C(122, 113, 101), .38)
	local scale = caldera.trim:Lerp(C(195, 159, 119), .35)
	part('BasaltGaugeBed', V(11.9, 1.3, 9.8), V(0, .54, -.38), caldera.rock, M.Basalt, 'Wedge', 0, math.pi / 2)
	part('FreightGaugeCap', V(8.5, .9, 1.85), V(.36, 7.35, 0), iron, M.Metal)
	for _, side in ipairs({-1, 1}) do
		local x = .36 + side * 3.3
		part('BallastFoot', V(2.72, 1.5, 4), V(x, 1.26, 0), caldera.trim, M.Basalt)
		part('FreightGaugeUpright', V(1.2, 6, 1.9), V(x, 4.3, 0), iron, M.Metal)
		part('GaugeHeelBrace', V(.9, 3.65, .95), V(x, 2.53, -1.09), iron, M.Metal, nil, -.49)
	end
	part('OxidizedMeasurePlate', V(1.08, 4.7, 1.98), V(-2.94, 4.22, 0), scale, M.Metal)
	for height = 3, 6 do
		part('GaugeGraduation', V(.78, .22, 2.02), V(-2.94, height, 0), iron, M.Metal)
	end
end

local function keeperWaypoint(part)
	local graveyard = palette.HauntedGraveyard
	local stone = graveyard.trim:Lerp(graveyard.rock, .19)
	local worn = stone:Lerp(graveyard.rock, .45)
	part('WaypointPackedBed', V(10.8, 1.45, 11.8), V(.3, .46, 0), graveyard.rock, M.Slate, 'Wedge', 0, math.pi / 2)
	part('DressedWaypointFoot', V(7.8, 1.3, 9.55), V(.4, .64, -.05), worn, M.Slate)
	part('DressedWaypointBody', V(5.7, 2.9, 7.8), V(.95, 2.45, .04), stone, M.Limestone)
	part('WornWaypointCap', V(6.15, 1.08, 8.25), V(1, 4.36, .04), stone, M.Limestone, 'Wedge', 0, math.pi / 2)
	part('KeeperRoadSeat', V(4.2, .42, 7.25), V(-1.5, 1.76, .28), worn, M.Slate)
	for _, endZ in ipairs({-1, 1}) do
		part('WaypointDressingBand', V(5.04, .56, .19), V(.95, 2.11, .04 + endZ * 3.89),
			graveyard.rock, M.Slate)
	end
end

local profiles = {
	['DW-07'] = {{'ConvoyVergeDrain', .33, -34, convoyDrain}},
	['GW-07'] = {{'WindgapSurveyRest', .34, 34, surveyRest}},
	['FV-07'] = {{'ThawCulvertHeadwall', .32, -34, culvertHeadwall}},
	['EC-07'] = {
		{'FreightRoadGauge', .34, 34, freightGauge},
		{'KeeperRoadWaypoint', .65, -34, keeperWaypoint},
	},
}

local Fixtures = {}

function Fixtures.build(floor, edge, a, b)
	local profile = profiles[edge[1]]
	if not profile then return end
	local root = Instance.new('Folder')
	root.Name = 'ApproachFixtures'
	for _, spec in ipairs(profile) do
		local name, t, lateral, build = table.unpack(spec)
		local z = floor.CFrame:PointToObjectSpace(a:Lerp(b, t)).Z
		local base = floor.CFrame * CFrame.new(lateral, floor.Size.Y / 2, z)
		local side = math.sign(lateral)
		local fixture = Instance.new('Model')
		fixture.Name = name
		fixture.WorldPivot = base
		build(function(partName, size, offset, color, material, shape, pitch, yaw, roll)
			local cf = base * CFrame.new(V(side * offset.X, offset.Y, offset.Z))
				* CFrame.Angles(pitch or 0, side * (yaw or 0), side * (roll or 0))
			Kit.part(fixture, partName, size, cf, color, material, shape)
		end)
		fixture.Parent = root
	end
	root.Parent = floor.Parent
end

return Fixtures
