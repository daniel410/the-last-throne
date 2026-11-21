
local cameras = {}
local themes = {'Deepwood', 'Gloamwood', 'FrozenVale', 'EmberCaldera', 'HauntedGraveyard'}
local function shot(id, from, aim, theme)
	table.insert(cameras, {id = id, origin = {from.X, from.Y, from.Z}, aim = {aim.X, aim.Y, aim.Z}, theme = theme})
end

for index, edge in ipairs(C.overlandLinks) do
	local id = edge[1] .. '_' .. edge[2]
	local road = roads[id]
	local floor = road.JourneyPass
	local along, across = floor.CFrame.LookVector, floor.CFrame.RightVector
	local aa, bb = B.ends(edge)
	local a, b = vec(aa), vec(bb)
	local parts = road.RoadShoulders:GetChildren()
	local inner, top = math.huge, 0
	local previous
	for _, part in ipairs(parts) do
		assert(part.Anchored and not part.CanCollide and not part.CanQuery and not part.CanTouch)
		local lowest = math.huge
		for _, x in ipairs({-.5, .5}) do
			for _, y in ipairs({-.5, .5}) do
				for _, z in ipairs({-.5, .5}) do
					local p = floor.CFrame:PointToObjectSpace(part.CFrame * (part.Size * V(x, y, z)))
					local height = p.Y - floor.Size.Y / 2
					inner = math.min(inner, math.abs(p.X))
					lowest = math.min(lowest, height)
					top = math.max(top, height)
					assert(math.abs(p.X) < floor.Size.X / 2)
					assert(math.abs(p.Z) < floor.Size.Z / 2)
				end
			end
		end
		if part.Name == 'BasaltFracture' then
			assert(previous and previous.Name == 'JointedBasalt')
			local bottom = part.CFrame * V(0, -part.Size.Y / 2, 0)
			local point = previous.CFrame:PointToObjectSpace(bottom)
			assert(math.abs(point.X) < .01 and math.abs(point.Z) < .01)
			assert(math.abs(point.Y - previous.Size.Y / 2 + .09) < .005)
		else
			assert(lowest < -.2, part:GetFullName())
		end
		previous = part
	end
	assert(inner >= 32 and top <= 6.5)
	print('BOUNDARY_GEOMETRY ' .. game.HttpService:JSONEncode({
		id = id, parts = #parts, inner = inner, top = top, floor = tostring(floor.CFrame), size = tostring(floor.Size),
	}))
	local approach = ({.08, .08, .31, .70})[index]
	local target = ({.215, .215, .67, .855})[index]
	shot(id, a:Lerp(b, approach) + across * 27 + V(0, 7.5, 0),
		a:Lerp(b, target) + across * 39 + V(0, 1.5, 0), themes[index])
	if index == 3 then
		shot(id .. '_mid', a:Lerp(b, .53) - along * 18 + across * 17 + V(0, 6.5, 0),
			a:Lerp(b, .71) + across * 39 + V(0, 2.5, 0), themes[index])
		shot(id .. '_return', a:Lerp(b, .91) + across * 20 + V(0, 6.5, 0),
			a:Lerp(b, .76) + across * 39 + V(0, 2.5, 0), themes[index + 1])
	end
end
