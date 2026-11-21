local CollectionService = game:GetService('CollectionService')
local RunService = game:GetService('RunService')
local Flow = {}
local tag = 'TLTScenicFlow'
local tracks = {}
local started = false

local function read(part)
	if not part:IsA('BasePart') then return end
	local from = part:GetAttribute('ScenicFlowStart')
	local to = part:GetAttribute('ScenicFlowEnd')
	if not from or not to then return end
	local length = (to - from).Magnitude
	if length <= .05 then return end
	tracks[part] = {
		from = from,
		to = to,
		rotation = part.CFrame.Rotation,
		rate = part:GetAttribute('ScenicFlowSpeed') / length,
		phase = part:GetAttribute('ScenicFlowPhase'),
		size = part:GetAttribute('ScenicFlowSize'),
		alpha = part:GetAttribute('ScenicFlowAlpha'),
		splash = part:GetAttribute('ScenicFlowMode') == 'splash',
		distance = (part:GetAttribute('TLTSceneryDistance') or 350) + length,
	}
end

local function updateTrack(part, track, time)
	local t = (time * track.rate + track.phase) % 1
	local fadeIn = math.min(t * 8, 1)
	local fadeOut = math.min((1 - t) * (track.splash and 2.5 or 6), 1)
	part.CFrame = CFrame.new(track.from:Lerp(track.to, t)) * track.rotation
	part.Transparency = 1 - (1 - track.alpha) * fadeIn * fadeOut
	if track.splash then
		part.Size = track.size * Vector3.new(1 + t * 1.4, 1, 1 + t * .7)
	end
end

function Flow.update(time, eye)
	for part, track in pairs(tracks) do
		if part:IsDescendantOf(workspace) then
			if (track.from - eye).Magnitude <= track.distance then
				updateTrack(part, track, time)
			elseif part.Transparency < 1 then
				part.Transparency = 1
			end
		end
	end
end

function Flow.start()
	if started then return end
	started = true
	CollectionService:GetInstanceAddedSignal(tag):Connect(read)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(part)
		tracks[part] = nil
	end)
	for _, part in ipairs(CollectionService:GetTagged(tag)) do read(part) end
	if not RunService:IsClient() then return end
	local last = 0
	RunService.PreRender:Connect(function()
		local camera = workspace.CurrentCamera
		local now = os.clock()
		if camera and now - last >= 1 / 30 then
			last = now
			Flow.update(now, camera.CFrame.Position)
		end
	end)
end

return Flow
