
local cameras = {}
local themes = {'Deepwood', 'Gloamwood', 'FrozenVale', 'EmberCaldera', 'HauntedGraveyard'}
local anchors = {
	{{'ConvoyVergeDrain', .33, -34, 1}},
	{{'WindgapSurveyRest', .34, 34, 2}},
	{{'ThawCulvertHeadwall', .32, -34, 3}},
	{{'FreightRoadGauge', .34, 34, 4}, {'KeeperRoadWaypoint', .65, -34, 5}},
}

for index, edge in ipairs(C.overlandLinks) do
	local id = table.concat(edge, '_', 1, 2)
	local road = roads[id]
	local floor = road.JourneyPass
	local aa, bb = B.ends(edge)
	local a, b = vec(aa), vec(bb)
	local along, across = floor.CFrame.LookVector, floor.CFrame.RightVector
	local fixtures = road:FindFirstChild('ApproachFixtures')
	local modelRows = {}
	for _, anchor in ipairs(anchors[index]) do
		local name, fraction, lateral, theme = table.unpack(anchor)
		local middle = a:Lerp(b, fraction)
		local side = math.sign(lateral)
		for _, view in ipairs({{'approach', -1}, {'return', 1}}) do
			local from = middle + along * (view[2] * 20) + across * (side * 16) + V(0, 7.5, 0)
			local aim = middle + across * (lateral - side * 3) + V(0, 2.5, 0)
			table.insert(cameras, {id = name .. '_' .. view[1], origin = {from.X, from.Y, from.Z},
				aim = {aim.X, aim.Y, aim.Z}, theme = themes[theme]})
		end
		if fixtures then
			local assembly = assert(fixtures:FindFirstChild(name))
			local inner, low, high, count = math.huge, math.huge, -math.huge, 0
			for _, part in ipairs(assembly:GetDescendants()) do
				if not part:IsA('BasePart') then continue end
				assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery,
					part:GetFullName())
				count += 1
				for _, x in ipairs({-.5, .5}) do
					for _, y in ipairs({-.5, .5}) do
						for _, z in ipairs({-.5, .5}) do
							local corner = floor.CFrame:PointToObjectSpace(part.CFrame * (part.Size * V(x, y, z)))
							local h = corner.Y - floor.Size.Y / 2
							inner, low, high = math.min(inner, math.abs(corner.X)), math.min(low, h), math.max(high, h)
							assert(math.abs(corner.X) < floor.Size.X / 2 and math.abs(corner.Z) < floor.Size.Z / 2,
								part:GetFullName())
						end
					end
				end
			end
			assert(count > 0 and inner > 23 and low < -.1 and high < 10, name)
			table.insert(modelRows, {name = name, parts = count, inner = inner, buried = -low, height = high})
		end
	end
	local unchanged = {}
	for _, part in ipairs(road.RoadShoulders:GetChildren()) do
		table.insert(unchanged, table.concat({part.Name, tostring(part.CFrame), tostring(part.Size)}, '|'))
	end
	table.sort(unchanged)
	print('FIXTURE_GEOMETRY ' .. game.HttpService:JSONEncode({
		id = id, floor = tostring(floor.CFrame), size = tostring(floor.Size),
		gallery = unchanged, models = modelRows,
	}))
end
