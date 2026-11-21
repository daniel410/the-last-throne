-- Authored visual water on the existing server-owned ground.
local Kit = require(script.Parent.EpicEnvironmentKit)
local Motion = require(script.Parent.ScenicFlowMarkers)
local Water = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local deepWater = C(44, 99, 113)
local shallowWater = C(84, 154, 168)
local foam = C(192, 225, 223)
local wetSilt = C(64, 72, 54)

local function film(parent, name, from, to, width, thickness, color, overlap)
	local frame = CFrame.lookAt((from + to) / 2, to)
	local part = Kit.part(parent, name, V(width, thickness, (to - from).Magnitude + overlap),
		frame, color, M.SmoothPlastic)
	part.CastShadow = false
	return part
end

local function current(parent, name, from, to, size, color, transparency, speed, phase, mode, shape)
	local position = from:Lerp(to, phase)
	local frame = CFrame.lookAt(position, position + (to - from))
	local build = shape == 'Ball' and Kit.ellipsoid or Kit.part
	local part = build(parent, name, size, frame, color, M.SmoothPlastic)
	part.CastShadow = false
	part.Transparency = transparency
	Motion.track(part, from, to, speed, phase, mode)
end

local function runnel(parent, points, widths)
	for i, width in ipairs(widths) do
		local from, to = points[i], points[i + 1]
		local bearing = (to - from).Unit
		local cross = V(-bearing.Z, 0, bearing.X)
		for _, side in ipairs({-1, 1}) do
			local turn = i % 2 == 0 and side or -side
			local bank = from:Lerp(to, .50 + turn * .09) + cross * (width * .42 * side) - V(0, .06, 0)
			local wetEdge = Kit.ellipsoid(parent, 'WetSiltMargin',
				V(2.5 + .48 * turn, .15, (to - from).Magnitude * (.72 + turn * .14)),
				CFrame.lookAlong(bank, bearing) * CFrame.Angles(0, turn * .075, 0),
				wetSilt:Lerp(C(102, 96, 63), .25 + turn * .15), M.Mud)
			wetEdge.CastShadow = false
		end
		local tint = shallowWater:Lerp(deepWater, .37)
		local depth = film(parent, 'RunnelDepth', from - V(0, .057, 0), to - V(0, .057, 0),
			width * .68, .065, deepWater:Lerp(C(36, 66, 68), .55), .3)
		depth.Transparency = .11
		local surface = film(parent, 'RunnelSurface', from, to, width, .12, tint, .2)
		surface.Transparency = .42
		if i > 1 then
			local joint = Kit.ellipsoid(parent, 'RunnelBend', V(width, .12, width), from - V(0, .004, 0), tint, M.SmoothPlastic)
			joint.Transparency = .42
			joint.CastShadow = false
		end
		for lane = -1, 1, 2 do
			local height = lane == -1 and .11 or .14
			local offset = cross * (width * .21 * lane) + V(0, height, 0)
			local phase = (i * .31 + lane * .15) % 1
			current(parent, 'RunnelCurrent', from:Lerp(to, .13) + offset, from:Lerp(to, .87) + offset,
				V(lane == -1 and .51 or .31, .055, math.min(3.9, (to - from).Magnitude * .35)),
				lane == -1 and shallowWater:Lerp(foam, .62) or shallowWater, .12, 4.8 + lane * .6, phase)
		end
	end
end

function Water.creek(parent, center, width, depth, palette)
	local group = Instance.new('Folder')
	group.Name = 'CreekScenery'
	local points = {}
	for _, at in ipairs({{-.43, -.35}, {-.29, -.29}, {-.13, -.16}, {0, 0}, {.18, .07}, {.29, .24}, {.40, .35}}) do
		table.insert(points, center + V(at[1] * width, .096, at[2] * depth))
	end
	runnel(group, points, {6.6, 7.5, 7.8, 8.4, 7.2, 5.9})
	for i = -1, 1 do
		Kit.part(group, 'CreekCrossingStone', V(7, .25, 5),
			CFrame.new(center + V(i * 6, .12, i * 3)) * CFrame.Angles(0, i * .1, 0),
			palette.rock:Lerp(C(62, 93, 85), .48), M.Slate)
	end
	for i, bed in ipairs({V(-6.1, .034, -1.1), V(-3.5, .032, .54), V(4.9, .033, -1.05), V(8.25, .034, 2.5)}) do
		local gravel = Kit.ellipsoid(group, 'CreekGravelPatch', V(1.8 + i * .19, .10, .51 + i * .09),
			CFrame.new(center + bed) * CFrame.Angles(0, i * -.15, 0), wetSilt:Lerp(palette.trim, .47), M.Pebble)
		gravel.CastShadow = false
	end
	for i, side in ipairs({-1, 1}) do
		local edge = center + V(3.2, .23, side * 1.65)
		current(group, 'CrossingStoneWake', edge, edge + V(3.0, 0, .7 + side * .8),
			V(.38, .055, 1.45), foam, .28, 3.5, .29 * i)
	end
	group.Parent = parent
end

local function site(center, size, safe, ground)
	-- Reserve an outer quarry shelf away from the hauling and combat routes.
	for _, offset in ipairs({{-.36, -.52}, {-.38, -.56}, {-.44, .12}}) do
		local origin = center + V(size[1] * offset[1], 0, size[2] * offset[2])
		if safe(origin + V(0, 0, 14), 61) then
			local surface, valid = ground(origin)
			if valid then
				local low, high = surface.Y, surface.Y
				for _, corner in ipairs({V(-24, 0, -20), V(24, 0, -20), V(-20, 0, 12), V(20, 0, 12), V(20, 0, 57)}) do
					local floor, found = ground(origin + corner)
					if not found then
						valid = false
						break
					end
					low, high = math.min(low, floor.Y), math.max(high, floor.Y)
				end
				if valid and high - low < 3 then
					return V(surface.X, high, surface.Z), high - low
				end
			end
		end
	end
end

function Water.build(parent, id, center, size, palette, safe, ground)
	if id ~= 'DW-S2' then return end
	local origin, groundSpread = site(center, size, safe, ground)
	if not origin then return end

	local model = Instance.new('Model')
	model.Name = 'QuarryCascade'
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	model:SetAttribute('GroundOrigin', origin)
	model:SetAttribute('GroundSpread', groundSpread)
	local wetRock = palette.rock:Lerp(C(63, 75, 73), .66)
	local stone = palette.rock:Lerp(palette.trim, .19)
	local function rock(name, at, dimensions, yaw, color, shape)
		return Kit.part(model, name, dimensions, CFrame.new(origin + at) * CFrame.Angles(0, yaw, 0),
			color, M.Slate, shape)
	end
	-- Broken strata under the spring bed and a dark wet face behind the water.
	rock('QuarryFooting', V(-2, 4.3 - groundSpread * .5, -12), V(39, 10 + groundSpread, 25), -.08, wetRock)
	rock('QuarryStratum', V(-3, 14.5, -13), V(32, 15, 21), -.10, stone)
	rock('QuarryStratum', V(-5, 22.3, -13.4), V(26, 8, 18.5), .12, palette.rock)
	rock('SpringSill', V(-2, 26, -10), V(21, 3, 18), -.02, wetRock)
	rock('QuarryFracture', V(-19, 8, -9), V(12, 17, 16), .34, stone, 'Wedge')
	rock('QuarryFracture', V(15, 7, -10), V(13, 15, 20), -.27, stone, 'Wedge')
	rock('MossyLedge', V(-12, 26.8, -15), V(9, .9, 11), .12, palette.ground, 'Wedge')

	-- Irregular shoulders expose the wet seam below the spring lip.
	rock('FracturedSpringShoulder', V(-12.3, 23.7, -4.7), V(9.3, 6.4, 8.8), -.58, stone, 'Wedge')
	rock('ExposedQuarrySeam', V(12.0, 16.3, -8.3), V(9.2, 7.1, 8.2), .81, wetRock:Lerp(stone, .44), 'Wedge')
	rock('QuarryTalus', V(-14.2, 6.2, .4), V(10.1, 12.4, 12.7), -.63, wetRock, 'Wedge')
	rock('QuarryTalus', V(13.7, 4.5, -5.8), V(8.2, 8.9, 9.0), .55, wetRock:Lerp(stone, .30), 'Wedge')
	-- A low bed lifts the waterline above the quarry's grass overlay at the strike point.
	local poolHeight = .67
	for _, sample in ipairs({V(-5, 0, 6), V(3, 0, 8), V(-3, 0, 14)}) do
		local floor, found = ground(origin + sample)
		if found then poolHeight = math.max(poolHeight, floor.Y - origin.Y + .56) end
	end
	-- The spring feeds three narrow streams. Constant-section spans preserve
	-- their silhouettes, with small rounded seams only at changes in direction.
	local streams = {
		{width = 1.63, alpha = .21, points = {
			V(-6.5, 27.57, -.9), V(-6.8, 23.4, 1.2), V(-7.0, 14.1, 2.55),
			V(-6.65, 6.8, 4.7), V(-5.3, poolHeight, 7.2),
		}},
		{width = 2.42, alpha = .12, points = {
			V(-2.2, 27.59, -.63), V(-2, 22.1, 1.65), V(-1.4, 14.2, 3.9),
			V(-1.8, 6.3, 5.8), V(-2.7, poolHeight, 9.3),
		}},
		{width = 1.18, alpha = .26, points = {
			V(2.45, 27.39, -1.0), V(2.8, 23.1, .88), V(3.05, 13.7, 2.25),
			V(2.65, 5.15, 4.45), V(2.1, poolHeight, 6.5),
		}},
	}
	for i, stream in ipairs(streams) do
		local lip = origin + stream.points[1]
		local head = lip + V(-.4 * (i - 2), 0, -14 + i)
		local spring = Kit.ellipsoid(model, 'SpringRun', V(stream.width * 1.65, .19, (lip - head).Magnitude * 1.20),
			CFrame.lookAt((head + lip) * .5, lip), shallowWater, M.SmoothPlastic)
		spring.CastShadow = false
		current(model, 'SpringCurrent', head:Lerp(lip, .16) + V(0, .13, 0), head:Lerp(lip, .80) + V(0, .13, 0),
			V(.42, .06, 2.4), foam, .22, 7, .22 * i)
		local widths = {1.03, .98, .94, 1.04}
		for j = 1, #stream.points - 1 do
			local from, to = origin + stream.points[j], origin + stream.points[j + 1]
			local aerated = j == #stream.points - 1
			local tint = shallowWater:Lerp(foam, aerated and .39 or i * .065)
			local diameter = .83 * stream.width * widths[j]
			local centerline = CFrame.lookAt((from + to) * .5, to)
			local body = Kit.part(model, aerated and 'AeratedWater' or 'FallingWater',
				V((to - from).Magnitude + .16, diameter, diameter),
				centerline * CFrame.Angles(0, math.pi / 2, 0), tint, M.SmoothPlastic)
			body.Shape = Enum.PartType.Cylinder
			body.Transparency = stream.alpha * .78
			body.CastShadow = false
			if j > 1 then
				local axis = (to - (origin + stream.points[j - 1])).Unit
				local join = Kit.ellipsoid(model, 'FallBendBlend',
					V(.83 * stream.width * (widths[j - 1] + widths[j]) * .5, diameter, .48),
					CFrame.lookAlong(from, axis), tint, M.SmoothPlastic)
				join.Transparency = body.Transparency
				join.CastShadow = false
				local front = V(.08 * (i - 2), 0, diameter * .55)
				current(model, 'DescendingWater', from:Lerp(to, .13) + front, from:Lerp(to, .90) + front,
					V(.27 + stream.width * .06, .065, 1.45 + j * .22), foam, .11 + i * .065,
					13 + j * 1.7 + i, (j * .29 + i * .16) % 1)
			end
		end
	end

	-- Lay one water plane over the uneven bed; the shallow ledges show beneath it.
	local level = origin + V(0, poolHeight, 0)
	local heart = level + V(-1.35, 0, 10.7)
	local rim = {
		V(-11.1, 0, 4.8), V(-6.2, 0, 2.0), V(2.7, 0, 2.4), V(9.1, 0, 5.1),
		V(11.0, 0, 10.9), V(8.8, 0, 16.5), V(6.5, 0, 21.25),
		V(1.35, 0, 20.5), V(-4.9, 0, 18), V(-9.7, 0, 14.7), V(-11.9, 0, 9.8),
	}
	local waterColor = deepWater:Lerp(C(46, 117, 110), .45)
	for i, point in ipairs(rim) do
		local name = i == 1 and 'PlungePool' or 'QuarryPoolSurface'
		local inset = V(0, .045, 0)
		Kit.triangle(model, name, heart - inset, level + point - inset, level + rim[i % #rim + 1] - inset,
			.09, waterColor, M.SmoothPlastic, .18)
	end
	local pocketBed = Kit.ellipsoid(model, 'QuarryPoolBed', V(22, poolHeight + .95, 17.5),
		CFrame.new(heart - V(0, .72 + poolHeight * .5, 0)) * CFrame.Angles(0, .16, 0),
		wetRock:Lerp(waterColor, .40), M.Slate)
	pocketBed.CastShadow = false
	for _, shelf in ipairs({
		{V(-7.75, -.145, 8.3), V(7.4, .22, 9.2), -.40},
		{V(6.55, -.15, 12.55), V(6.15, .24, 10.0), -.36},
		{V(3.65, -.125, 18.7), V(5.65, .19, 5.5), -.32},
	}) do
		local submerged = Kit.ellipsoid(model, 'SubmergedGravelShelf', shelf[2],
			CFrame.new(level + shelf[1]) * CFrame.Angles(0, shelf[3], 0),
			wetRock:Lerp(palette.trim, .32), M.Pebble)
		submerged.CastShadow = false
	end
	model:SetAttribute('PoolSurfaceHeight', origin.Y + poolHeight)
	local churn = Kit.ellipsoid(model, 'FallImpactFoam', V(10.3, .08, 4.8),
		CFrame.new(origin + V(-2.1, poolHeight + .18, 7.6)), shallowWater:Lerp(foam, .62), M.SmoothPlastic)
	churn.CastShadow = false
	churn.Transparency = .35
	local stones = {
		{V(-11.9, .25, 6.6), V(7.2, 3.15, 9.5), .44}, {V(-12, .12, 12.8), V(5.4, 2.3, 7.6), -.63},
		{V(-7.1, .34, 16.65), V(8.6, 2.1, 6.4), .54}, {V(-2.8, .18, 19.6), V(5.2, 1.8, 5), -.5},
		{V(10.7, .32, 9.2), V(7.3, 3.3, 10.3), -.41}, {V(10.95, .28, 15.3), V(5.1, 2.45, 7.7), .68},
		{V(9.45, .41, 20.4), V(4.9, 2.65, 7.1), -.35},
	}
	for _, bank in ipairs(stones) do
		rock('PoolBank', bank[1] + V(0, poolHeight * .35, 0), bank[2] + V(0, groundSpread, 0),
			bank[3], wetRock:Lerp(stone, .18 + math.abs(bank[3]) * .45), 'Wedge')
	end
	for i, side in ipairs({-1, 0, 1}) do
		local impact = origin + V(-1 + side, poolHeight + .21, 7)
		current(model, 'PoolFoamFan', impact, origin + V(-1 + side * 7, poolHeight + .21, 12.5 + (1 - math.abs(side)) * 3),
			V(3.5 + i * .45, .07, .63), foam, .16, 4.2, i / 4, 'splash', 'Ball')
	end
	for _, side in ipairs({-1, 1}) do
		local impact = origin + V(-1 + side, poolHeight + .22, 7.4)
		current(model, 'ImpactSpray', impact, impact + V(side * 3.1, 1.25, 2.7),
			V(.45, .23, .76), foam, .24, 6, .48 + side * .22, 'splash', 'Ball')
	end
	runnel(model, {
		origin + V(3.6, poolHeight, 18.5), origin + V(7, .18, 27), origin + V(13.5, .14, 35),
		origin + V(15.3, .11, 45), origin + V(21, .10, 55),
	}, {8.5, 7.7, 6.7, 4.9})
	rock('OutflowGravel', V(21.4, .10, 55), V(7, .7, 6), -.28, wetRock, 'Wedge')
	model.WorldPivot = CFrame.new(origin)
	model.Parent = parent
	return model
end

return Water
