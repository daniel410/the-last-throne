-- K0 owns character loading only in the isolated RPG prototype.
-- The serialized Players.CharacterAutoLoads setting prevents an early spawn.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SpawnService = {}
local RESPAWN_DELAY = 5
local POSITION_GRACE = 3
local SAFE_RADIUS = 14
local APPEARANCE_GRACE = 30
local states = {}
local spawnLocation
local lifecycle = {}
local started = false

local function connected(state)
	return states[state.player] == state and state.player.Parent == Players
end

local function isSafeSpawnAvailable(destination)
	return destination and destination:IsA("SpawnLocation") and destination:IsDescendantOf(Workspace) and destination.Enabled
end

local function notify(name, state, character, generation, requestId, reason)
	local callback = lifecycle[name]
	if not callback then return end
	local ok, err = pcall(callback, state.player, character, generation, requestId, reason)
	if not ok then warn("K0 spawn lifecycle callback failed (" .. name .. "): " .. tostring(err)) end
end

local function endLife(state, character, generation, requestId, reason)
	if state.endedGeneration == generation then return end
	state.endedGeneration = generation
	character:SetAttribute("K0SpawnReady", false)
	notify("onLifeEnded", state, character, generation, requestId, reason)
end

local function disconnectCharacter(state)
	if state.humanoidConnection then state.humanoidConnection:Disconnect() end
	if state.childConnection then state.childConnection:Disconnect() end
	state.humanoidConnection = nil
	state.childConnection = nil
	state.humanoid = nil
end

local requestLoad
local function scheduleLoad(state, delaySeconds, generation)
	if not connected(state) or state.scheduledGeneration == generation then
		return
	end
	state.scheduleToken = state.scheduleToken + 1
	local token = state.scheduleToken
	state.scheduledGeneration = generation
	task.delay(delaySeconds, function()
		if not connected(state) or token ~= state.scheduleToken then
			return
		end
		state.scheduledGeneration = nil
		if state.generation == generation then
			requestLoad(state, generation)
		end
	end)
end

local function scheduleRetry(state, generation)
	state.retryCount = state.retryCount + 1
	state.player:SetAttribute("K0SpawnStatus", "Retrying")
	local delaySeconds = math.min(2 ^ math.min(state.retryCount, 3), 8)
	scheduleLoad(state, delaySeconds, generation)
end

requestLoad = function(state, generation)
	if not connected(state) or state.generation ~= generation then
		return
	end
	if state.loading then
		scheduleLoad(state, 1, generation)
		return
	end
	local current = state.player.Character
	if current then
		local humanoid = current:FindFirstChildOfClass("Humanoid")
		local root = current:FindFirstChild("HumanoidRootPart")
		local incomplete = state.incompleteRetryGeneration == generation and current:GetAttribute("K0SpawnReady") ~= true
		local replacement = state.characterRequest ~= state.desiredRequest
		if (not humanoid or humanoid.Health > 0) and not incomplete and not replacement then
			-- Another live or still-loading character already owns this life.
			return
		end
		if incomplete and not replacement and humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") and current:IsDescendantOf(Workspace) then
			-- The original load recovered while the retry was waiting.
			return
		end
		-- Roblox recommends waiting for the previous appearance to load before
		-- asking for another character. A bounded fallback handles a stuck load.
		if not state.appearanceReady and not state.player:HasAppearanceLoaded()
			and os.clock() - state.characterStartedAt < APPEARANCE_GRACE then
			scheduleLoad(state, 1, generation)
			return
		end
	end
	local request = state.desiredRequest
	if not isSafeSpawnAvailable(request.destination) then
		warn("K0 safe spawn is unavailable; character loading will retry.")
		scheduleRetry(state, generation)
		return
	end
	state.player.RespawnLocation = request.destination
	state.loading = true
	state.loadRequest = request
	state.player:SetAttribute("K0SpawnStatus", "Loading")
	task.spawn(function()
		local ok, err = pcall(function()
			state.player:LoadCharacterAsync()
		end)
		state.loading = false
		state.loadRequest = nil
		if not connected(state) then
			return
		end
		if not ok then
			warn("K0 character loading failed; retrying when safe: " .. tostring(err))
		end
		if state.desiredRequest ~= request then
			-- A newer destination may have arrived while LoadCharacterAsync yielded.
			-- Finish the old load before issuing exactly one replacement.
			scheduleLoad(state, 0, state.generation)
		elseif state.generation == generation then
			-- No new CharacterAdded event: do not assume an unsuccessful or
			-- incomplete load created a playable character.
			warn("K0 character loading did not create a new character; retrying.")
			scheduleRetry(state, generation)
		elseif state.characterRequest ~= state.desiredRequest then
			scheduleLoad(state, 0, state.generation)
		else
			-- A new life exists, even if the API response was uncertain. Its
			-- readiness watcher owns the outcome and avoids a duplicate load.
			state.retryCount = 0
		end
	end)
end

local function beginCharacter(state, character)
	if not connected(state) or state.player.Character ~= character or state.character == character then
		return
	end
	disconnectCharacter(state)
	state.generation = state.generation + 1
	local generation = state.generation
	local request = state.loadRequest or state.desiredRequest
	state.characterRequest = request
	state.character = character
	state.characterStartedAt = os.clock()
	state.appearanceReady = false
	state.incompleteRetryGeneration = nil
	state.retryCount = 0
	state.scheduleToken = state.scheduleToken + 1
	state.scheduledGeneration = nil
	character:SetAttribute("K0SpawnReady", false)
	state.player:SetAttribute("K0SpawnStatus", "Loading")
	notify("onLifeStarted", state, character, generation, request.id)

	local function died()
		if not connected(state) or state.generation ~= generation or state.player.Character ~= character then
			return
		end
		state.player:SetAttribute("K0SpawnStatus", "Respawning")
		endLife(state, character, generation, request.id, "Died")
		scheduleLoad(state, RESPAWN_DELAY, generation)
	end

	local function bindHumanoid(humanoid)
		if not humanoid:IsA("Humanoid") or state.humanoid == humanoid then
			return
		end
		if state.humanoidConnection then state.humanoidConnection:Disconnect() end
		state.humanoid = humanoid
		state.humanoidConnection = humanoid.Died:Connect(died)
		if humanoid.Health <= 0 then died() end
	end

	state.childConnection = character.ChildAdded:Connect(bindHumanoid)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then bindHumanoid(humanoid) end

	task.spawn(function()
		while connected(state) and state.generation == generation and state.player.Character == character
			and state.desiredRequest == request do
			local root = character:FindFirstChild("HumanoidRootPart")
			local human = character:FindFirstChildOfClass("Humanoid")
			local rescueOwned = false
			if not state.loading and os.clock() - state.characterStartedAt >= APPEARANCE_GRACE
				and (not root or not root:IsA("BasePart") or not human or not character:IsDescendantOf(Workspace))
				and state.incompleteRetryGeneration ~= generation then
				-- Wait for late rig parts first; only a persistently incomplete
				-- character may request a fresh life, with generation fencing.
				state.incompleteRetryGeneration = generation
				warn("K0 character remained incomplete; retrying its load.")
				scheduleRetry(state, generation)
			end
			local destination = request.destination
			if not state.loading and isSafeSpawnAvailable(destination) and character:IsDescendantOf(Workspace)
				and root and root:IsA("BasePart") and human and human.Health > 0 then
				local delta = root.Position - destination.Position
				local horizontalDistance = Vector3.new(delta.X, 0, delta.Z).Magnitude
				local nearSpawn = horizontalDistance <= SAFE_RADIUS and delta.Y >= -2 and delta.Y <= 20
				if not nearSpawn and os.clock() - state.characterStartedAt >= POSITION_GRACE then
					-- Existing or mispositioned characters are rescued to the safe
					-- spawn after the engine has finished its own load attempt.
					local height = math.max(3, human.HipHeight + root.Size.Y / 2) + 0.5
					local target = destination.Position + Vector3.new(0, destination.Size.Y / 2 + height, 0)
					rescueOwned = pcall(function() root:SetNetworkOwner(nil) end)
					character:PivotTo(character:GetPivot() + (target - root.Position))
					root.AssemblyLinearVelocity = Vector3.zero
					nearSpawn = true
				end
				if nearSpawn then
					-- Let the spawn/physics step settle before combat takes a
					-- movement baseline; the player may immediately move normally.
					RunService.Heartbeat:Wait()
					if rescueOwned and root.Parent then
						pcall(function() root:SetNetworkOwnershipAuto() end)
					end
					if connected(state) and state.generation == generation and state.player.Character == character
						and state.desiredRequest == request and character:IsDescendantOf(Workspace) and human.Health > 0 then
						local finalDelta = root.Position - destination.Position
						local finalDistance = Vector3.new(finalDelta.X, 0, finalDelta.Z).Magnitude
						if finalDistance <= SAFE_RADIUS and finalDelta.Y >= -2 and finalDelta.Y <= 20 then
							character:SetAttribute("K0SpawnReady", true)
							state.player:SetAttribute("K0SpawnStatus", "Ready")
							notify("onReady", state, character, generation, request.id)
							return
						end
					end
				end
			end
			task.wait(0.1)
		end
	end)
end

local function bindPlayer(player)
	if states[player] or player.Parent ~= Players then
		return
	end
	local state = {
		player = player, generation = 0, loading = false, scheduleToken = 0, retryCount = 0,
		characterStartedAt = 0, appearanceReady = false,
		desiredRequest = { id = 0, destination = spawnLocation },
	}
	states[player] = state
	player.RespawnLocation = spawnLocation
	state.addedConnection = player.CharacterAdded:Connect(function(character)
		beginCharacter(state, character)
	end)
	state.appearanceConnection = player.CharacterAppearanceLoaded:Connect(function(character)
		if state.character == character then state.appearanceReady = true end
	end)
	state.removingConnection = player.CharacterRemoving:Connect(function(character)
		if state.character ~= character then return end
		endLife(state, character, state.generation, state.characterRequest.id, "Removing")
		disconnectCharacter(state)
		player:SetAttribute("K0SpawnStatus", "Respawning")
		scheduleLoad(state, RESPAWN_DELAY, state.generation)
	end)
	if player.Character then
		beginCharacter(state, player.Character)
		state.appearanceReady = player:HasAppearanceLoaded()
	else
		requestLoad(state, state.generation)
	end
end

local function unbindPlayer(player)
	local state = states[player]
	if not state then return end
	states[player] = nil
	state.scheduleToken = state.scheduleToken + 1
	disconnectCharacter(state)
	state.addedConnection:Disconnect()
	state.removingConnection:Disconnect()
	state.appearanceConnection:Disconnect()
end

-- Server-only destination changes. Each request owns a fresh Character; an old
-- asynchronous load cannot make a newer lobby/tutorial request ready.
function SpawnService.requestSpawn(player, destination, requestId)
	local state = states[player]
	if not started or not state or not connected(state) then return false, "Unavailable" end
	if not isSafeSpawnAvailable(destination) then return false, "Unavailable" end
	if type(requestId) ~= "number" or requestId < 1 or requestId % 1 ~= 0 then return false, "InvalidRequest" end
	if requestId <= state.desiredRequest.id then return false, "StaleRequest" end
	state.desiredRequest = { id = requestId, destination = destination }
	state.scheduleToken = state.scheduleToken + 1
	state.scheduledGeneration = nil
	if state.character then
		endLife(state, state.character, state.generation, state.characterRequest.id, "Replaced")
	end
	state.player:SetAttribute("K0SpawnStatus", "Loading")
	scheduleLoad(state, 0, state.generation)
	return true
end

function SpawnService.start(safeSpawn, callbacks)
	assert(not started, "K0 spawn service already started")
	assert(safeSpawn and safeSpawn:IsA("SpawnLocation") and safeSpawn:IsDescendantOf(Workspace) and safeSpawn.Enabled,
		"K0 spawn service requires an enabled SpawnLocation in Workspace")
	assert(Players.CharacterAutoLoads == false, "K0 requires serialized CharacterAutoLoads=false before players join")
	started = true
	spawnLocation = safeSpawn
	lifecycle = callbacks or {}
	Players.PlayerAdded:Connect(bindPlayer)
	Players.PlayerRemoving:Connect(unbindPlayer)
	for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return SpawnService
