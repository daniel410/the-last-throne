local compiled = 0
for _, node in ipairs(game:GetDescendants()) do
	if node:IsA('LuaSourceContainer') and node:IsDescendantOf(game.ServerScriptService)
		or node:IsA('ModuleScript') and node:IsDescendantOf(game.ReplicatedStorage) then
		assert(loadstring(node.Source, node:GetFullName()))
		compiled += 1
	end
end
print('ROAD_COMPILED', compiled)

local themes = {'Deepwood', 'Gloamwood', 'FrozenVale', 'EmberCaldera'}
local cameras = {}
local function addCamera(id, origin, aim, theme)
	table.insert(cameras, {id = id, origin = {origin.X, origin.Y, origin.Z},
		aim = {aim.X, aim.Y, aim.Z}, theme = theme})
end
for i, edge in ipairs(C.overlandLinks) do
	local id = edge[1] .. '_' .. edge[2]
	local road = roads[id]
	local floor = road.JourneyPass
	local aa, bb = B.ends(edge)
	local a, b = vec(aa), vec(bb)
	local across = floor.CFrame.RightVector
	local shoulders = road:FindFirstChild('RoadShoulders')
	assert((shoulders ~= nil) == candidate)
	local count, inner, buried, top = 0, 48, 0, 0
	if shoulders then
		for _, part in ipairs(shoulders:GetChildren()) do
			count += 1
			assert(part.Anchored and not part.CanCollide and not part.CanQuery and not part.CanTouch)
			local minY = math.huge
			for _, x in ipairs({-.5, .5}) do
				for _, y in ipairs({-.5, .5}) do
					for _, z in ipairs({-.5, .5}) do
						local point = floor.CFrame:PointToObjectSpace(part.CFrame * (part.Size * V(x,y,z)))
						inner = math.min(inner, math.abs(point.X))
						assert(math.abs(point.X) < floor.Size.X / 2)
						minY = math.min(minY, point.Y - floor.Size.Y / 2)
						top = math.max(top, point.Y - floor.Size.Y / 2)
					end
				end
			end
			assert(minY < -.20)
			buried += 1
		end
		assert(count == 12 and inner >= 32 and top <= 3)
	end
	print('ROAD_SHOULDERS ' .. game.HttpService:JSONEncode({
		id = id, count = count, buried = buried, inner = inner, top = top,
		floorSize = tostring(floor.Size), floorTransform = tostring(floor.CFrame),
	}))
	addCamera(id, a:Lerp(b, .31) + across * 27 + V(0, 7.5, 0),
		a:Lerp(b, .67) + across * 39 + V(0, 1.5, 0), themes[i])
end
local carrier = assert(world.folder:FindFirstChild('EC-07_exp_2_step1_Art', true))
assert(carrier:GetAttribute('StoryObjective') == 'EC-07:exp_2:step1')
local count = 0
for _, part in ipairs(carrier:GetDescendants()) do
	if part:IsA('BasePart') then
		count += 1
		assert(part:GetAttribute('ExpansionOriginalColor') == part.Color and not part.CanCollide)
	end
end
assert(count == (candidate and 18 or 11))
local pivot = carrier:GetPivot()
local _, size = carrier:GetBoundingBox()
print('ROAD_CARRIER ' .. game.HttpService:JSONEncode({
	count = count, pivot = tostring(pivot), size = {size.X,size.Y,size.Z},
}))
addCamera('EC-07_carrier', pivot * V(4, 4.1, -6.8), pivot * V(0, 1.1, 0), 'EmberCaldera')

if candidate then
	local Presentation = require(game.StarterPlayer.StarterPlayerScripts.Client.CampaignExpansionPresentation)
	Presentation.update({journal = {clues = {['EC-07:exp_2'] = {step1 = true}}}})
	for _, part in ipairs(carrier:GetChildren()) do
		assert(part.Color == Color3.fromRGB(103, 205, 184))
	end
	Presentation.update({journal = {clues = {['EC-07:exp_2'] = {}}}})
	for _, part in ipairs(carrier:GetChildren()) do
		assert(part.Color == part:GetAttribute('ExpansionOriginalColor'))
	end
	print('ROAD_CARRIER_COLOR_PASS', count)
end
