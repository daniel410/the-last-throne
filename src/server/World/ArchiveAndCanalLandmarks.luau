-- Service works beside the interactive relays and valves. Their mechanisms own the story state.
local Models = {}

Models.profiles = {
	['FV-04'] = {
		{name = 'WestArchiveConduitBed', goal = 'relay_west', form = 'archive'},
		{name = 'EastArchiveConduitBed', goal = 'relay_east', form = 'archive'},
	},
	['EC-04'] = {
		{name = 'WesternIntakeSluice', goal = 'west_valve', form = 'intake'},
		{name = 'EasternReturnRace', goal = 'east_valve', form = 'return'},
	},
}

local V = Vector3.new
local M = Enum.Material

local function archive(profile, palette, part)
	local stone = palette.rock:Lerp(palette.trim, .17)
	local channel = palette.rock:Lerp(palette.wood, .56)
	local east = profile.goal == 'relay_east'
	local length = east and 22 or 18

	part('RelayBedFoundation', V(10, 1.3, length), V(0, .29, 0), stone, M.Slate)
	part('RecessedCableBed', V(3.5, .27, length - 1), V(0, 1.01, 0), channel, M.Slate)
	for _, side in ipairs({-1, 1}) do
		local x = side * 3.55
		part('DressedArchiveCurb', V(2.8, 1.55, length - 1), V(x, 1.63, 0), stone, M.Slate)
		for _, z in ipairs({-length * .29, length * .30}) do
			part('FrostedStoneShoulder', V(3.65, 1.2, 4.5), V(x, 2.42, z), palette.trim, M.Glacier,
				false, V(0, side * .12, 0), 'Wedge')
		end
	end
	for _, x in ipairs({-.68, .68}) do
		part('BuriedSignalLead', V(.52, .39, length - 2), V(x, 1.23, .1), palette.wood, M.Metal)
	end
	part('RelayStoneSaddle', V(10.8, 2.7, east and 5.4 or 4.2), V(0, 1.91, length / 2 - 3),
		palette.rock, M.Slate)
	part('SaddleFrostCap', V(10, .38, 4), V(.16, 3.37, length / 2 - 3), palette.ground, M.Snow)
end

local function intake(palette, part)
	local stone = palette.rock:Lerp(palette.trim, .32)
	local metal = palette.wood:Lerp(palette.trim, .25)
	part('MasonryIntakeFoundation', V(11, 1.4, 21), V(0, .28, 0), palette.rock, M.Basalt)
	part('DressedIntakeInvert', V(5.7, .38, 19.6), V(0, 1.03, 0), stone, M.Slate)
	for _, side in ipairs({-1, 1}) do
		for _, z in ipairs({-6.65, 0, 6.65}) do
			part('DressedIntakeCourse', V(2.6, 2.68, 6.45), V(side * 4.1, 1.61, z), stone, M.Basalt)
		end
		part('IntakeClampPier', V(3.1, 3.5, 3.1), V(side * 4.1, 2.2, 5.2), palette.trim, M.Slate)
	end
	for _, x in ipairs({-1.9, 0, 1.9}) do
		part('FixedIntakeScreenBar', V(.42, 2.15, .54), V(x, 2.2, 5.2), metal, M.CorrodedMetal)
	end
	part('FixedIntakeScreenHeader', V(6.2, .58, .86), V(0, 3.36, 5.2), palette.trim, M.Metal)
end

local function returnRace(palette, part)
	local stone = palette.rock:Lerp(palette.trim, .19)
	local silt = palette.ground:Lerp(palette.rock, .67)
	part('ReturnRaceFoundation', V(16.5, 1.28, 21), V(0, .25, 0), palette.rock, M.Basalt)
	part('SedimentApron', V(10.6, .32, 18.8), V(0, .97, 0), silt, M.Slate)
	for _, side in ipairs({-1, 1}) do
		part('ReturnFlaredCheek', V(4.9, 2.45, 13.8), V(side * 5.95, 1.18, -2.5), stone, M.Basalt,
			false, V(0, side * .20, 0), 'Wedge')
		part('ReturnBasaltAbutment', V(4.4, 3.1, 8.1), V(side * 5.9, 1.7, 5.3), palette.rock, M.Basalt,
			false, V(0, -side * .11, 0))
		part('WornOverflowCoping', V(4.1, .46, 7.6), V(side * 5.9, 3.46, 5.3), palette.trim, M.Slate,
			false, V(0, -side * .11, 0))
	end
	for i = -1, 1 do
		part('SettledBasaltRubble', V(2.1, 1, 2.8), V(i * 2.8, 1.2, -5 + math.abs(i) * 1.15),
			stone, M.Basalt, false, V(0, i * .7, 0), 'Corner')
	end
end

function Models.compose(profile, palette, part)
	if profile.form == 'archive' then
		archive(profile, palette, part)
	elseif profile.form == 'intake' then
		intake(palette, part)
	else
		returnRace(palette, part)
	end
end

return Models
