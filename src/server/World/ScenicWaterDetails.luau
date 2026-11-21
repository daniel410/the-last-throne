-- Authored visual water on the existing server-owned ground.
local Kit = require(script.Parent.EpicEnvironmentKit)
local Water = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local deepWater = C(62, 119, 127)
local shallowWater = C(95, 157, 158)
local foam = C(178, 214, 209)

local function film(parent, name, from, to, width, thickness, color, overlap)
	local frame = CFrame.lookAt((from + to) / 2, to)
	local part = Kit.part(parent, name, V(width, thickness, (to - from).Magnitude + overlap),
		frame, color, M.SmoothPlastic)
	part.CastShadow = false
	return part
end

local function ripple(parent, point, width, length, heading, color)
	local part = Kit.part(parent, 'SurfaceRipple', V(width, .045, length),
		CFrame.new(point) * CFrame.Angles(0, heading, 0), color, M.SmoothPlastic, 'Ball')
	part.CastShadow = false
end

local function runnel(parent, points, widths)
	for i, width in ipairs(widths) do
		local from, to = points[i], points[i + 1]
		film(parent, 'RunnelSurface', from, to, width, .12, deepWater, .2)
		if i > 1 then
			local joint = Kit.part(parent, 'RunnelBend', V(width, .12, width), from, deepWater, M.SmoothPlastic, 'Ball')
			joint.CastShadow = false
		end
		local upstream = from:Lerp(to, .22) + V(0, .09, 0)
		local downstream = from:Lerp(to, .73) + V(0, .09, 0)
		film(parent, 'ShallowCurrent', upstream, downstream, width * .22, .035, shallowWater, 0)
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
			palette.rock, M.Slate)
	end
	ripple(group, points[3]:Lerp(points[4], .58) + V(0, .097, 0), 2.7, .34, -.47, foam)
	ripple(group, points[5]:Lerp(points[6], .62) + V(0, .097, 0), 2.2, .37, -.47, foam)
	group.Parent = parent
end

local function site(center, size, safe, ground)
	-- The southeast shelf is offset from the fight and the western incident wing.
	for _, offset in ipairs({{.28, -.36}, {.32, -.39}, {.35, -.33}, {-.31, -.37}}) do
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
	film(model, 'SpringRun', origin + V(-2, 27.58, -18), origin + V(-2, 27.58, -.7),
		9.5, .15, shallowWater, .25)
	for i, lane in ipairs({{-5.4, 3.15}, {-2.4, 3.1}, {.38, 2.8}}) do
		local x, width = table.unpack(lane)
		local from = origin + V(x, 27.59, -.8)
		local to = origin + V(x + .7, .42, 6.0 + i * .33)
		local strip = film(model, 'FallingWater', from, to, width, .37,
			i == 2 and C(118, 181, 189) or shallowWater, .38)
		strip.Transparency = .07
		film(model, 'FallCurrent', from:Lerp(to, .10) + V(.55, 0, .40),
			from:Lerp(to, .78) + V(.55, 0, .40), .36, .13, foam, 0)
	end

	local pool = Kit.part(model, 'PlungePool', V(27, .38, 24),
		CFrame.new(origin + V(0, .16, 11)) * CFrame.Angles(0, -.12, 0), deepWater, M.SmoothPlastic, 'Ball')
	pool.CastShadow = false
	local stones = {
		{V(-12.9, .15, 9), V(5.5, 2.4, 9), .23}, {V(-10.5, -.05, 17), V(5.3, 2.5, 6), -.45},
		{V(13, .11, 13), V(6, 2.1, 9), -.33}, {V(9.8, .33, 19), V(4, 1.8, 5), -.3},
	}
	for _, bank in ipairs(stones) do
		rock('PoolBank', bank[1], bank[2] + V(0, groundSpread, 0), bank[3], wetRock, 'Wedge')
	end
	for i, span in ipairs({{9.5, 1.1}, {12, .6}, {8.3, .46}}) do
		ripple(model, origin + V(-1 + i * .8, .40, 4.3 + i * 2.7), span[1], span[2], -.14 * i, foam)
	end
	runnel(model, {
		origin + V(3.6, .21, 19), origin + V(7, .18, 27), origin + V(13.5, .14, 35),
		origin + V(15.3, .11, 45), origin + V(21, .10, 55),
	}, {8.5, 7.7, 6.7, 4.9})
	rock('OutflowGravel', V(21.4, .10, 55), V(7, .7, 6), -.28, wetRock, 'Wedge')
	model.WorldPivot = CFrame.new(origin)
	model.Parent = parent
	return model
end

return Water
