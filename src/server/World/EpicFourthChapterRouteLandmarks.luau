-- Route-side maintenance fixtures for the secondary chapter-four incidents.
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material

local function returnRopeGuide(pal, part, beam)
	local stone = pal.rock:Lerp(C(142, 125, 96), .55)
	local oak = pal.wood:Lerp(C(138, 91, 61), .65)
	local rope = C(184, 150, 100)
	part('RopeGuideTerrace', V(5.8, .64, 3.3), V(0, .09, .1), pal.ground, M.Ground, 'Corner')
	for _, x in ipairs({-1.52, 1.52}) do
		part('GuidePostSocket', V(1.28, .62, 1.44), V(x, .38, .22), stone, M.Cobblestone)
		part('GuidePost', V(.59, 1.65, .62), V(x, 1.22, .22), oak, M.Wood)
		part('GuideRopeWrap', V(.69, .33, .74), V(x, 1.87, .22), rope, M.Fabric)
	end
	beam('GuideRopeLeft', V(-1.51, 1.88, .22), V(0, 1.5, .22), .19, rope, M.Fabric)
	beam('GuideRopeRight', V(0, 1.5, .22), V(1.51, 1.88, .22), .19, rope, M.Fabric)
end

local function refugeBoardRest(pal, part, beam)
	local shale = pal.rock:Lerp(C(130, 137, 123), .66)
	local root = pal.wood:Lerp(C(123, 90, 62), .66)
	local cut = root:Lerp(C(184, 152, 112), .68)
	part('BoardRestShaleFan', V(5.4, .62, 3.3), V(0, .10, .1), shale, M.Slate, 'Corner', V(0, -.2, 0))
	part('BoardRestSplitStone', V(3.77, .81, 1.98), V(-.42, .49, .28), shale, M.Slate, 'Wedge', V(0, .4, 0))
	beam('BoardRestRoot', V(-1.9, .46, .65), V(.65, 1.46, .42), .67, root, M.Wood)
	part('BoardRestUpright', V(.44, 1.88, .46), V(.71, 1.29, .36), root:Lerp(cut, .38), M.Wood)
	part('BoardRestCrossbar', V(2.65, .34, .52), V(.14, 2.11, .30), cut, M.WoodPlanks, nil, V(0, 0, -.12))
	for _, x in ipairs({-.71, .92}) do
		part('BoardRestPin', V(.23, .23, .14), V(x, 2.11 - x * .12, -.02), C(115, 111, 89), M.CorrodedMetal)
	end
end

local function relayPlateCradle(pal, part)
	local ice = pal.rock:Lerp(C(108, 161, 181), .56)
	local snow = pal.ground:Lerp(C(222, 235, 237), .77)
	local stone = pal.trim:Lerp(C(143, 123, 94), .58)
	local steel = C(108, 130, 137)
	part('CradleIceLip', V(5.9, .73, 3.55), V(0, .14, 0), ice, M.Glacier, 'Corner')
	part('CradlePackedSnow', V(3.12, .57, 2.65), V(-1.18, .31, .36), snow, M.Snow, 'Wedge', V(0, math.pi / 2, 0))
	part('RelayCradleStone', V(3.45, .61, 1.96), V(.62, .52, .22), stone, M.Slate)
	for _, x in ipairs({-.32, 1.56}) do
		part('RelayPlateGuide', V(.32, .43, 1.56), V(x, .99, .22), steel, M.Metal)
	end
	part('StowedRelayPlate', V(1.58, .17, 1.42), V(.62, 1.13, .19), steel:Lerp(snow, .25), M.Metal, nil, V(.16, 0, 0))
	part('RelayPlateHandle', V(.63, .16, .19), V(.62, 1.29, -.10), stone, M.Metal)
end

local function pressureLineSaddle(pal, part)
	local basalt = pal.rock:Lerp(C(75, 62, 56), .67)
	local brick = pal.ground:Lerp(C(167, 106, 73), .69)
	local iron = C(102, 96, 90)
	part('SaddleAshRunoff', V(6.3, .65, 3.60), V(0, .09, .1), basalt, M.Basalt, 'Corner', V(0, .18, 0))
	for _, x in ipairs({-1.53, 1.53}) do
		part('PressureSaddleBasaltFoot', V(1.67, .50, 1.58), V(x, .40, .26), basalt, M.Basalt)
		part('PressureSaddleFirebrick', V(1.28, .66, 1.34), V(x, .95, .26), brick, M.Brick)
	end
	part('PressureLineSpareCoupling', V(4.28, .92, .92), V(0, 1.65, .26), iron, M.CorrodedMetal, 'Cylinder')
	for _, x in ipairs({-.53, .53}) do
		part('PressureLineCollar', V(.22, 1.23, 1.23), V(x, 1.65, .26), iron:Lerp(brick, .27), M.Metal, 'Cylinder')
	end
end

local function gateSurveyLedge(pal, part, beam)
	local stone = pal.rock:Lerp(C(133, 135, 127), .63)
	local cut = pal.trim:Lerp(C(187, 174, 150), .71)
	local iron = C(106, 104, 94)
	part('SurveyLedgeChippedFooting', V(5.45, .63, 3.51), V(0, .10, .12), stone, M.Cobblestone, 'Corner')
	part('SurveyLedgeBack', V(3.94, 1.52, .67), V(0, .87, .83), stone, M.Limestone)
	part('SurveyLedgeSlab', V(4.21, .35, 1.77), V(0, 1.74, .28), cut, M.Limestone)
	for _, x in ipairs({-1.30, 1.30}) do
		beam('SurveyLedgeBrace', V(x, .75, .71), V(x, 1.60, -.40), .28, iron, M.CorrodedMetal)
	end
	part('SurveyLedgeWearStrip', V(2.59, .12, .32), V(.05, 1.93, -.29), cut:Lerp(stone, .22), M.Slate)
	part('SurveyLedgeSpall', V(.98, .31, .86), V(1.69, .31, -.76), stone, M.Slate, 'Corner', V(0, -.41, 0))
end

return {
	['DW-04'] = {goal = 'exp_2', step = 2, name = 'ReturnRopeGuide', side = 14, compose = returnRopeGuide},
	['GW-04'] = {goal = 'exp_2', step = 2, name = 'RefugeBoardRest', side = 14, compose = refugeBoardRest},
	['FV-04'] = {goal = 'exp_1', step = 2, name = 'RelayPlateCradle', side = 14, compose = relayPlateCradle},
	['EC-04'] = {goal = 'exp_2', step = 2, name = 'PressureLineSaddle', side = 14, compose = pressureLineSaddle},
	['HG-04'] = {goal = 'exp_1', step = 2, name = 'GateSurveyLedge', side = -14, compose = gateSurveyLedge},
}
