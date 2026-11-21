assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local Collection = game:GetService('CollectionService')
local C = require(game.ReplicatedStorage.Shared.CampaignContent)
local worldModules = game.ServerScriptService.Server.World
local client = game.StarterPlayer.StarterPlayerScripts.Client
local world = require(worldModules.CampaignWorld).create()
local presentation

for _, parent in ipairs({worldModules, client}) do
	for _, name in ipairs({'ScenicWaterDetails', 'CalderaLavaFlows', 'ScenicFlowMarkers', 'ScenicFlowPresentation'}) do
		local source = parent:FindFirstChild(name)
		if source then assert(loadstring(source.Source, name)) end
	end
end

local markers = Collection:GetTagged('TLTScenicFlow')
assert((#markers > 0) == candidate)
if candidate then
	presentation = require(client.ScenicFlowPresentation)
	presentation.start()
	local groups = {}
	local modes = {}
	for _, marker in ipairs(markers) do
		assert(marker.Anchored and not marker.CanCollide and not marker.CanQuery and not marker.CanTouch)
		local from = marker:GetAttribute('ScenicFlowStart')
		local to = marker:GetAttribute('ScenicFlowEnd')
		local speed = marker:GetAttribute('ScenicFlowSpeed')
		local phase = marker:GetAttribute('ScenicFlowPhase')
		local length = (to - from).Magnitude
		assert(length > .05 and speed > 0 and phase >= 0 and phase < 1)
		local startTime = (.2 - phase) / (speed / length)
		presentation.update(startTime, from)
		local p = marker.Position
		assert((p - from:Lerp(to, .2)).Magnitude < .01)
		local delta = length * .2 / speed
		presentation.update(startTime + delta, from)
		assert((marker.Position - from:Lerp(to, .4)).Magnitude < .01)
		assert(math.abs((marker.Position - p).Magnitude - speed * delta) < .01)
		local mode = marker:GetAttribute('ScenicFlowMode')
		modes[mode] = (modes[mode] or 0) + 1
		local root = marker.Parent.Name
		groups[root] = (groups[root] or 0) + 1
	end
	assert(modes.splash and modes.current and next(groups))
	print('TLT_LIQUID_TRACKS ' .. game.HttpService:JSONEncode({
		count = #markers, groups = groups, modes = modes,
	}))
end

local cameras = {}
local function coords(p) return {p.X, p.Y, p.Z} end
local function view(name, origin, aim, theme, frames, dt)
	for i = 1, frames do
		table.insert(cameras, {id = string.format('%s_%02d', name, i),
			origin = coords(origin), aim = coords(aim), theme = theme, first = i == 1, time = (i - 1) * dt + .31})
	end
end
local creek = V(table.unpack(C.zones['DW-01'].expansionAreas[1].center))
view('creek', creek + V(-17, 6, 18), creek + V(2, 0, -3), 'Deepwood', candidate and 10 or 1, .115)
view('falls', V(-1198, 34, -1943), V(-1228, 32, -1975), 'Deepwood', candidate and 10 or 1, .115)
local mine = C.zones['EC-03']
local vent = V(table.unpack(mine.center)) + V(-(mine.size[1]/2 + 77), 0, 142)
view('lava', vent + V(88, 11, -24), vent + V(0, 3.5, 0), 'EmberCaldera', candidate and 10 or 1, .23)
