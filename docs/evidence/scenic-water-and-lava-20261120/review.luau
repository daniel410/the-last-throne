assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local C = require(game.ReplicatedStorage.Shared.CampaignContent)
local world = require(game.ServerScriptService.Server.World.CampaignWorld).create()
local cameras = {}
local worldModules = game.ServerScriptService.Server.World
for _, name in ipairs({'EpicWorldArt', 'CampaignIncidentScenes', 'ScenicWaterDetails', 'CalderaLavaFlows'}) do
	local module = worldModules:FindFirstChild(name)
	if module then assert(loadstring(module.Source, name)) end
end
local function shot(id, origin, aim, theme)
	table.insert(cameras, {id = id, origin = {origin.X, origin.Y, origin.Z},
		aim = {aim.X, aim.Y, aim.Z}, theme = theme})
end
local function center(id)
	return V(table.unpack(C.zones[id].center))
end
local function audit(name, expected)
	local root = world.folder:FindFirstChild(name, true)
	assert((root ~= nil) == expected, name)
	if not root then return end
	local count = 0
	for _, part in ipairs(root:GetDescendants()) do
		if part:IsA('BasePart') then
			count += 1
			assert(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery, part:GetFullName())
		end
	end
	assert(count > 0, name)
	local source, outlet = root:GetAttribute('Source'), root:GetAttribute('Outlet')
	if source and outlet then
		assert(source.Y > outlet.Y, name)
	end
	print('TLT_FLOW_MODEL ' .. game.HttpService:JSONEncode({name = name, parts = count,
		source = source and tostring(source), outlet = outlet and tostring(outlet),
		origin = root:GetAttribute('GroundOrigin') and tostring(root:GetAttribute('GroundOrigin')),
		groundSpread = root:GetAttribute('GroundSpread')}))
end
for _, row in ipairs({
	{'EC-01', 1, 110, 'AshSpireVent', 19},
	{'EC-03', -1, 142, 'MineFractureFlow'},
	{'EC-04', 1, -153, 'CoolingRiftFlow'},
	{'EC-07', -1, -132, 'FurnaceRimVent'},
}) do
	local id, side, z, name, rimOffset = table.unpack(row)
	audit(name, candidate)
	local at = center(id) + V(side * (C.zones[id].size[1] / 2 + (rimOffset or 77)), 0, z)
	shot(name, at + V(-side * 107, 13, id == 'EC-01' and 34 or -34), at + V(0, 5, 0), 'EmberCaldera')
end
local creek = C.zones['DW-01'].expansionAreas[1]
local at = V(table.unpack(creek.center))
shot('CreeksideCargo', at + V(-25, 8, 24), at + V(3, 0, -4), 'Deepwood')
audit('QuarryCascade', candidate)
audit('CreekScenery', candidate)
shot('QuarryCascade', V(-1177, 36, -1917), V(-1230, 31, -1984), 'Deepwood')
