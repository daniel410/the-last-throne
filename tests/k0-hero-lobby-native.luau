-- Independent isolated engine fixture. Run through make_k0_source_probe.py or
-- run-in-roblox --place <fixed local build> --script this-file.
-- Original server handlers/lifecycle functions are exposed ONLY by replacing
-- each QA copy's final return. No production hooks or algorithms are copied.
-- Identity, FireClient transport and LoadCharacterAsync are explicit doubles;
-- rigs, Humanoid death, BindableEvents, placement and Heartbeat are native.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "Lobby QA requires an empty isolated local place")
assert(Players.CharacterAutoLoads == false, "Lobby QA must preserve serialized CharacterAutoLoads=false")
assert(not workspace:FindFirstChild("K0HeroLobbyQaFixture"), "Lobby QA fixture already exists")
local report = { kind = "K0_HERO_LOBBY_NATIVE", checks = 0, cases = {}, failures = {}, players = 0,
	coverage = "Original HeroSessionService request handler and public lifecycle/SpawnService paths; native minimal rigs, Humanoid death, events, CFrame placement and Heartbeat; identity/load/FireClient doubles",
	limits = "No real Player LoadCharacterAsync, OnServerEvent transport, client UI/input, per-class combat, final world layout, published permissions, persistent storage or device acceptance" }
local fixture, session, spawn, lobbySpawn, tutorialSpawn, options
local privateModules, eventObjects, fakePlayers, loadJobs, connections = {}, {}, {}, {}, {}
local counter, requestCounter = 0, 0

local function check(condition, label)
	report.checks += 1
	assert(condition, label)
end
local function equal(actual, expected, label)
	check(actual == expected, label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function waitFor(predicate, label, timeout)
	local deadline = os.clock() + (timeout or 3)
	repeat
		local value = predicate()
		if value then return value end
		task.wait(0.025)
	until os.clock() >= deadline
	error("Timed out: " .. label)
end
local function event()
	local result = Instance.new("BindableEvent")
	table.insert(eventObjects, result)
	return result
end
local function privateCopy(source, name, moduleName, exports)
	local instrumented, count = source.Source:gsub("\nreturn " .. moduleName .. "%s*$", function() return "\nreturn {" .. exports .. "}\n" end)
	assert(count == 1, moduleName .. " return boundary changed")
	local module = Instance.new("ModuleScript")
	module.Name, module.Source, module.Parent = name, instrumented, source.Parent
	table.insert(privateModules, module)
	return require(module)
end
local function nativeRig(name, position)
	local character = Instance.new("Model")
	character.Name = name
	local root = Instance.new("Part")
	root.Name, root.Size, root.CFrame = "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(position)
	root.Anchored, root.CanCollide = true, false
	root.Parent = character
	character.PrimaryPart = root
	local human = Instance.new("Humanoid")
	human.RequiresNeck, human.BreakJointsOnDeath = false, false
	human.MaxHealth, human.Health = 1000, 1000
	human.Parent = character
	character.Parent = fixture
	return character
end
local function fakePlayer(userId)
	counter += 1
	local added, removing, appearance = event(), event(), event()
	local player = { Parent = Players, UserId = userId or -counter, Name = "QaIdentity" .. counter,
		CharacterAdded = added.Event, CharacterRemoving = removing.Event, CharacterAppearanceLoaded = appearance.Event,
		attributes = {}, responses = {}, loads = 0, simultaneous = 0, maxSimultaneous = 0 }
	function player:SetAttribute(name, value) self.attributes[name] = value end
	function player:GetAttribute(name) return self.attributes[name] end
	function player:HasAppearanceLoaded() return true end
	function player:LoadCharacterAsync()
		self.loads += 1
		self.simultaneous += 1
		self.maxSimultaneous = math.max(self.maxSimultaneous, self.simultaneous)
		local job = { player = self, destination = self.RespawnLocation, before = self.holdBefore,
			after = self.holdAfter, fail = self.failNext, noPlacement = self.noPlacement, finished = false }
		self.holdBefore, self.holdAfter, self.failNext = nil, nil, nil
		table.insert(loadJobs, job)
		self.lastJob = job
		local ok, err = xpcall(function()
			if job.before then job.waitingBefore = true; job.before.Event:Wait(); job.waitingBefore = false end
			if job.fail then error("QA injected LoadCharacterAsync failure") end
			local previous = self.Character
			if previous then removing:Fire(previous) end
			local position = job.noPlacement and Vector3.new(0, 3, 0) or job.destination.Position + Vector3.new(0, 4, 0)
			local character = nativeRig(self.Name .. "_life" .. self.loads, position)
			job.character = character
			self.Character = character
			added:Fire(character)
			task.wait(0.025)
			appearance:Fire(character)
			if job.after then job.waitingAfter = true; job.after.Event:Wait(); job.waitingAfter = false end
			task.wait(0.025)
		end, debug.traceback)
		self.simultaneous -= 1
		job.finished = true
		if not ok then error(err) end
	end
	table.insert(fakePlayers, player)
	return player
end
local function unbind(player)
	if session then session.unbind(player) end
	if spawn then spawn.unbind(player) end
	player.Parent = nil
end
local function newSession(player)
	player = player or fakePlayer()
	session.bind(player)
	spawn.bind(player)
	waitFor(function()
		local state = session.states[player]
		return state and state.phase == "Lobby" and state.ready
	end, "initial lobby readiness", player.noPlacement and 5 or 3)
	return player, session.states[player]
end
local function send(player, action, argument, id, ...)
	requestCounter += 1
	id = id or "qa_" .. requestCounter
	local before = #player.responses
	-- Isolate validation/state cases from the independently tested rate limiter.
	local state = session.states[player]
	state.tokens, state.lastRefill = 10, os.clock()
	session.request(player, action, id, argument, ...)
	check(#player.responses > before, "server handler responds to " .. tostring(action))
	return player.responses[#player.responses], id
end
local function create(player, classId, id)
	local response = send(player, "CreateHero", classId, id)
	equal(response.errorCode, nil, "create " .. classId)
	local hero = session.states[player].byClass[classId]
	check(hero and type(hero.heroId) == "string" and #hero.heroId > 0, "server generates " .. classId .. " hero identity")
	return hero
end
local function ready(player, phase, timeout)
	return waitFor(function()
		local state = session.states[player]
		return state and state.ready and state.phase == phase and player.Character:GetAttribute("K0SpawnReady") == true
	end, phase .. " readiness", timeout)
end
local function nearDestination(player, destination)
	local delta = player.Character.HumanoidRootPart.Position - destination.Position
	check(Vector3.new(delta.X, 0, delta.Z).Magnitude <= 14 and delta.Y >= -2 and delta.Y <= 20, "native root is inside selected spawn readiness volume")
	equal(player.RespawnLocation, destination, "engine respawn destination follows server request")
end
local function beginTutorial(player)
	local response, id = send(player, "StartTutorial")
	equal(response.errorCode, nil, "tutorial start accepted")
	ready(player, "Tutorial")
	return id
end
local function returnLobby(player)
	local response = send(player, "ReturnLobby")
	equal(response.errorCode, nil, "return lobby accepted")
	ready(player, "Lobby")
end
local function case(id, body)
	local beforeChecks, firstPlayer = report.checks, #fakePlayers + 1
	local ok, err = xpcall(body, debug.traceback)
	for index = firstPlayer, #fakePlayers do unbind(fakePlayers[index]) end
	lobbySpawn.Enabled, tutorialSpawn.Enabled = true, true
	table.insert(report.cases, { id = id, pass = ok, checks = report.checks - beforeChecks, error = not ok and tostring(err) or nil })
	if not ok then table.insert(report.failures, id .. ": " .. tostring(err)) end
end

local ok, fatal = xpcall(function()
	local server = assert(ServerScriptService:FindFirstChild("Server"), "server sources missing")
	local sessionSource = assert(server:FindFirstChild("Lobby")):FindFirstChild("HeroSessionService")
	local spawnSource = assert(server:FindFirstChild("Spawn")):FindFirstChild("SpawnService")
	assert(sessionSource and spawnSource, "lobby/spawn modules missing")
	session = privateCopy(sessionSource, "QaHeroSessionPrivate", "HeroSessionService",
		"service=HeroSessionService,states=sessions,snapshot=snapshot,bind=bindPlayer,unbind=unbindPlayer,request=handleRequest,setResponseRemote=function(value) stateRemote=value end")
	spawn = privateCopy(spawnSource, "QaLobbySpawnPrivate", "SpawnService",
		"service=SpawnService,states=states,bind=bindPlayer,unbind=unbindPlayer")
	fixture = Instance.new("Folder")
	fixture.Name, fixture.Parent = "K0HeroLobbyQaFixture", workspace
	local function destination(name, position)
		local part = Instance.new("SpawnLocation")
		part.Name, part.Position, part.Size = name, position, Vector3.new(10, 1, 10)
		part.Anchored, part.CanCollide, part.Enabled = true, false, true
		part.Parent = fixture
		return part
	end
	lobbySpawn = destination("QaLobbySpawn", Vector3.new(15000, 50, 15000))
	tutorialSpawn = destination("QaTutorialSpawn", Vector3.new(15300, 50, 15000))
	options = { lobbySpawn = lobbySpawn, tutorialSpawn = tutorialSpawn,
		lobbyBounds = { center = lobbySpawn.Position, size = Vector3.new(100, 30, 100) }, requestSpawn = spawn.service.requestSpawn }
	session.service.start(options)
	session.setResponseRemote({ FireClient = function(_, player, state, requestId, errorCode)
		assert(player.Parent == Players, "cannot publish to departed identity")
		table.insert(player.responses, { snapshot = state, requestId = requestId, errorCode = errorCode })
	end })
	spawn.service.start(lobbySpawn, { onLifeStarted = session.service.onLifeStarted, onReady = session.service.onReady, onLifeEnded = session.service.onLifeEnded })
	if not RunService:IsRunning() then RunService:Run() end
	check(ReplicatedStorage.Remotes.K0HeroRequest:IsA("RemoteEvent") and ReplicatedStorage.Remotes.K0HeroState:IsA("RemoteEvent"), "public start registers native request/state remotes")

	case("lobby-first-safe-without-hero-or-combat", function()
		local player, state = newSession()
		equal(player.loads, 1, "initial join creates one life")
		nearDestination(player, lobbySpawn)
		local view = session.snapshot(state)
		check(view.sessionOnly and view.canManage and not view.canStart and #view.heroes == 0, "initial server snapshot is an empty session-only lobby")
		equal(player.Character:GetAttribute("K0ClassId"), nil, "lobby does not guess Knight")
		equal(session.service.getCombatContext(player, player.Character), nil, "lobby life is never combat eligible")
		local response = send(player, "StartTutorial")
		equal(response.errorCode, "SelectHeroFirst", "cannot start without a selected hero")
		equal(player.loads, 1, "denied start does not spawn")
	end)
	case("four-heroes-class-immutable-idempotent-copied-snapshots", function()
		local player, state = newSession()
		local first = create(player, "knight", "same_create")
		local repeated = send(player, "CreateHero", "knight", "same_create")
		equal(repeated.errorCode, nil, "exact duplicate replays success")
		equal(#state.heroes, 1, "duplicate create does not create an extra hero")
		equal(state.heroes[1], first, "duplicate preserves original hero object")
		equal(send(player, "CreateHero", "elf", "same_create").errorCode, "RequestConflict", "same request ID cannot change class")
		local ids = { [first.heroId] = true }
		for _, classId in ipairs({ "elf", "dwarf", "mage" }) do
			local hero = create(player, classId)
			check(not ids[hero.heroId], "different heroes have different server IDs")
			ids[hero.heroId] = true
		end
		equal(#state.heroes, 4, "exactly four classes in roster")
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			equal(send(player, "CreateHero", classId).errorCode, "ClassAlreadyCreated", "class cannot be duplicated")
			equal(state.byClass[classId].baseClassId, classId, "original class remains immutable")
		end
		local view = session.snapshot(state)
		view.heroes[1].classId, view.heroes[1].practice.attacked = "mage", true
		view.heroes[2] = nil
		equal(state.heroes[1].baseClassId, "knight", "snapshot cannot mutate hero class")
		equal(state.heroes[1].practice.attacked, false, "snapshot cannot mutate nested practice")
		equal(#state.heroes, 4, "snapshot cannot remove server hero")
	end)
	case("malformed-forged-and-unowned-requests", function()
		local player, state = newSession()
		local own = create(player, "knight")
		local other = newSession()
		local foreign = create(other, "mage")
		equal(send(player, "SelectHero", foreign.heroId).errorCode, "HeroNotOwned", "foreign hero ID is denied")
		equal(send(player, "SelectHero", "fabricated").errorCode, "HeroNotOwned", "fabricated hero ID is denied")
		for _, request in ipairs({
			{ "CreateHero", "priest" }, { "CreateHero", { classId = "mage" } }, { "CreateHero", 0 / 0 },
			{ "SetClass", "mage" }, { "StartTutorial", own.heroId }, { "SelectHero", 10 },
			{ "GetState", nil, "bad id" }, { "GetState", nil, string.rep("x", 49) }, { string.rep("x", 25) },
		}) do
			equal(send(player, request[1], request[2], request[3]).errorCode, "InvalidRequest", "malformed request rejected")
		end
		equal(send(player, "CreateHero", "elf", nil, "forged_extra").errorCode, "InvalidRequest", "unexpected extra argument is denied")
		equal(#state.heroes, 1, "invalid requests create no new heroes")
		equal(state.selectedHeroId, own.heroId, "invalid selection leaves owned identity selected")
		player.Character:SetAttribute("K0ClassId", "mage")
		player.Character:SetAttribute("K0HeroId", foreign.heroId)
		equal(session.service.getActiveHero(player).classId, "knight", "replicated claims cannot overwrite server class")
		equal(session.service.getActiveHero(player).heroId, own.heroId, "replicated claims cannot overwrite server hero ownership")
	end)
	case("lobby-platform-bounds-and-rate-limit", function()
		local player, state = newSession()
		local root = player.Character.HumanoidRootPart
		root.CFrame = CFrame.new(lobbySpawn.Position + Vector3.new(50, 4, 0))
		create(player, "knight", "evicted_create")
		for _, offset in ipairs({ Vector3.new(50.1, 4, 0), Vector3.new(0, 15.1, 0), Vector3.new(0, 4, -50.1) }) do
			root.CFrame = CFrame.new(lobbySpawn.Position + offset)
			equal(send(player, "StartTutorial").errorCode, "ReturnToPlatform", "outside lobby bounds denies tutorial entry")
		end
		equal(player.loads, 1, "out-of-bounds starts create no life")
		root.CFrame = CFrame.new(lobbySpawn.Position + Vector3.new(0, 4, 0))
		state.tokens, state.lastRefill = 10, os.clock()
		for index = 1, 11 do session.request(player, "GetState", "rate_" .. index) end
		equal(player.responses[#player.responses].errorCode, "TooFast", "burst limiter rejects the eleventh immediate request")
		equal(#state.heroes, 1, "throttle never mutates roster")
		for index = 1, 40 do send(player, "GetState", nil, "cache_" .. index) end
		equal(#state.requestOrder, 32, "idempotency cache is bounded")
		equal(send(player, "CreateHero", "knight", "evicted_create").errorCode, "ClassAlreadyCreated", "evicted request cannot bypass one-per-class invariant")
	end)
	case("four-hero-start-return-and-profile-identity", function()
		local player, state = newSession()
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do create(player, classId) end
		local previousEpoch = state.epoch
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			local hero = state.byClass[classId]
			equal(send(player, "SelectHero", hero.heroId).errorCode, nil, "server selects owned hero")
			local count = player.loads
			local id = beginTutorial(player)
			nearDestination(player, tutorialSpawn)
			local context = assert(session.service.getCombatContext(player, player.Character))
			equal(context.heroId, hero.heroId, "combat context uses selected hero")
			equal(context.baseClassId, classId, "combat context uses immutable selected class")
			check(context.epoch > previousEpoch, "new life advances server combat epoch")
			previousEpoch = context.epoch
			equal(player.Character:GetAttribute("K0ClassId"), classId, "new life replicates selected class")
			equal(send(player, "StartTutorial", nil, id).errorCode, nil, "duplicate successful start replays")
			equal(player.loads, count + 1, "duplicate start does not load twice")
			equal(send(player, "StartTutorial").errorCode, "WaitForLobby", "new start while in tutorial is denied")
			local response, returnId = send(player, "ReturnLobby")
			equal(response.errorCode, nil, "return accepted")
			equal(session.service.getCombatContext(player, player.Character), nil, "return immediately revokes combat")
			equal(send(player, "ReturnLobby", nil, returnId).errorCode, nil, "duplicate return replays without another transition")
			ready(player, "Lobby")
			nearDestination(player, lobbySpawn)
			equal(player.loads, count + 2, "one start and one return create exactly two lives")
			equal(session.service.getCombatContext(player, player.Character), nil, "returned lobby is combat-ineligible")
			equal(state.byClass[classId].baseClassId, classId, "hero class survives another hero's session")
		end
		equal(#state.heroes, 4, "switching keeps all four heroes")
		equal(player.maxSimultaneous, 1, "loads stay serialized across four heroes")
	end)
	case("tutorial-death-respawn-and-stale-life-callbacks", function()
		local player, state = newSession()
		local hero = create(player, "dwarf")
		beginTutorial(player)
		local old, generation, transition, epoch, count = player.Character, state.generation, state.transitionId, state.epoch, player.loads
		old:FindFirstChildOfClass("Humanoid").Health = 0
		waitFor(function() return not state.ready end, "native Humanoid death revokes life")
		equal(session.service.getCombatContext(player, old), nil, "dead life has no combat context")
		ready(player, "Tutorial", 7)
		check(player.Character ~= old and state.generation > generation and state.epoch > epoch, "respawn has a new character, generation and epoch")
		equal(player.loads, count + 1, "native death causes one replacement load")
		nearDestination(player, tutorialSpawn)
		local context = assert(session.service.getCombatContext(player, player.Character))
		equal(context.heroId, hero.heroId, "death keeps same selected hero")
		equal(context.baseClassId, "dwarf", "respawn keeps original class")
		session.service.onReady(player, old, generation, transition)
		session.service.onLifeEnded(player, old, generation, transition)
		equal(session.service.getCombatContext(player, player.Character).epoch, context.epoch, "old life callbacks cannot revoke or ready new life")
	end)
	for _, stage in ipairs({ "before", "after" }) do
		case("return-during-load-" .. stage .. "-character-added", function()
			local player, state = newSession()
			create(player, "mage")
			local gate = event()
			if stage == "before" then player.holdBefore = gate else player.holdAfter = gate end
			local count = player.loads
			equal(send(player, "StartTutorial").errorCode, nil, "start enters pending tutorial")
			waitFor(function() return player.loads == count + 1 and player.lastJob and (stage == "before" and player.lastJob.waitingBefore or stage == "after" and player.lastJob.waitingAfter) end, "held load reaches requested boundary")
			local pending = player.lastJob
			local oldRequest = state.transitionId
			equal(session.service.getCombatContext(player, player.Character), nil, "pending life never enables combat")
			equal(send(player, "ReturnLobby").errorCode, nil, "return supersedes unfinished tutorial")
			local desired = state.transitionId
			check(desired > oldRequest, "new transition fences old request")
			gate:Fire()
			ready(player, "Lobby", 5)
			nearDestination(player, lobbySpawn)
			equal(player.loads, count + 2, "old load completes before exactly one lobby replacement")
			equal(player.maxSimultaneous, 1, "superseding a load never overlaps LoadCharacterAsync")
			check(pending.character ~= player.Character and pending.character:GetAttribute("K0SpawnReady") ~= true, "superseded character never becomes ready")
			session.service.onReady(player, pending.character, state.generation - 1, oldRequest)
			equal(state.transitionId, desired, "late ready cannot roll back transition")
			equal(state.phase, "Lobby", "late ready cannot reopen tutorial")
			equal(session.service.getCombatContext(player, player.Character), nil, "late load cannot enable lobby combat")
		end)
	end
	case("unavailable-destination-retry-and-invalid-server-spawn", function()
		local player, state = newSession()
		create(player, "elf")
		tutorialSpawn.Enabled = false
		equal(send(player, "StartTutorial").errorCode, "SpawnUnavailable", "unavailable spawn is explicit")
		equal(state.phase, "SpawnFailed", "failed transition retains a recoverable phase")
		equal(session.service.getCombatContext(player, player.Character), nil, "failed spawn cannot reuse old life combat")
		tutorialSpawn.Enabled = true
		returnLobby(player)
		local original = spawn.states[player].desiredRequest
		for _, request in ipairs({ -1, 0, 0.5, math.huge, 0 / 0 }) do
			equal(spawn.service.requestSpawn(player, tutorialSpawn, request), false, "invalid server transition number rejected")
		end
		equal(spawn.service.requestSpawn(player, tutorialSpawn, original.id), false, "stale transition is rejected")
		local invalidDestination = Instance.new("Part")
		equal(spawn.service.requestSpawn(player, invalidDestination, original.id + 1), false, "non-spawn destination rejected")
		invalidDestination:Destroy()
		equal(spawn.states[player].desiredRequest, original, "rejected requests do not replace desired spawn")
	end)
	case("misplaced-native-rig-rescued-to-lobby", function()
		local player = fakePlayer()
		player.noPlacement = true
		newSession(player)
		nearDestination(player, lobbySpawn)
		equal(player.loads, 1, "rescue moves existing rig rather than loading twice")
		equal(session.service.getCombatContext(player, player.Character), nil, "rescued lobby stays safe")
	end)
	case("practice-is-per-hero-and-does-not-grant-combat", function()
		local player, state = newSession()
		local knight = create(player, "knight")
		local mage = create(player, "mage")
		send(player, "SelectHero", knight.heroId)
		beginTutorial(player)
		player.Character:SetAttribute("K0AttackSeq", 1)
		player.Character:SetAttribute("K0State", "Dodge")
		player.Character:PivotTo(player.Character:GetPivot() + Vector3.new(7, 0, 0))
		waitFor(function() return knight.practice.attacked and knight.practice.dodged and knight.practice.moved end, "native tutorial progress observers")
		returnLobby(player)
		send(player, "SelectHero", mage.heroId)
		check(not mage.practice.attacked and not mage.practice.dodged and not mage.practice.moved, "another hero does not inherit tutorial progress")
		check(knight.practice.attacked and knight.practice.dodged and knight.practice.moved, "return preserves selected hero's session progress")
		equal(session.service.getCombatContext(player, player.Character), nil, "practice records do not enable combat in lobby")
	end)
	case("leave-during-load-and-same-user-new-session", function()
		local player = newSession()
		create(player, "knight")
		local gate = event()
		player.holdBefore = gate
		send(player, "StartTutorial")
		waitFor(function() return player.lastJob and player.lastJob.before == gate and player.lastJob.waitingBefore end, "pending load before leave")
		local oldState, oldSpawn, count, userId = session.states[player], spawn.states[player], player.loads, player.UserId
		unbind(player)
		gate:Fire()
		waitFor(function() return player.simultaneous == 0 end, "inflight identity load returns after leave")
		task.wait(0.15)
		equal(session.states[player], nil, "leave deletes roster session")
		equal(spawn.states[player], nil, "leave deletes spawn state")
		equal(player.loads, count, "late completion schedules no departed-player replacement")
		equal(session.service.getActiveHero(player), nil, "departed identity has no active hero")
		equal(session.service.getCombatContext(player, player.Character), nil, "departed identity has no combat")
		local rejoined, newState = newSession(fakePlayer(userId))
		check(newState ~= oldState and spawn.states[rejoined] ~= oldSpawn, "same UserId new Player identity gets fresh server session")
		equal(#newState.heroes, 0, "session-only roster is not reported as permanent storage")
		local hero = create(rejoined, "mage")
		equal(hero.baseClassId, "mage", "new session does not inherit departed-player class cache")
	end)
end, debug.traceback)
if not ok then table.insert(report.failures, "fixture: " .. tostring(fatal)) end
local cleaned, cleanupError = pcall(function()
	for _, player in ipairs(fakePlayers) do unbind(player) end
	for _, job in ipairs(loadJobs) do
		if not job.finished then
			if job.before then job.before:Fire() end
			if job.after then job.after:Fire() end
		end
	end
	waitFor(function() for _, player in ipairs(fakePlayers) do if player.simultaneous ~= 0 then return false end end; return true end, "cleanup of inflight identity loads", 2)
	for _, connection in ipairs(connections) do connection:Disconnect() end
	for _, item in ipairs(eventObjects) do item:Destroy() end
	for _, module in ipairs(privateModules) do module:Destroy() end
	if fixture then fixture:Destroy() end
end)
if not cleaned then table.insert(report.failures, "cleanup: " .. tostring(cleanupError)) end
report.identityFixtures = #fakePlayers
report.loadCalls = 0
for _, player in ipairs(fakePlayers) do report.loadCalls += player.loads end
report.running, report.pass = RunService:IsRunning(), #report.failures == 0
print("K0_HERO_LOBBY_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "K0 hero lobby native fixture failed; see K0_HERO_LOBBY_NATIVE")
