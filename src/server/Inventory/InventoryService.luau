-- RPG-only account items. Studio uses an explicitly labeled session adapter.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Catalog = require(ReplicatedStorage.Shared.ItemCatalog)
local Rules = require(script.Parent.InventoryRules)
local Store = require(script.Parent.AccountStore)
local Service = {}
local accounts, options, store, stateRemote, openRemote
accounts = {}
local token = HttpService:GenerateGUID(false)
local sessionOnly = RunService:IsStudio()
local started = false

local function publish(player, requestId, errorCode)
	if stateRemote and player.Parent == Players then stateRemote:FireClient(player, Service.snapshot(player), requestId, errorCode) end
end
function Service.ready(player)
	local state = accounts[player]
	return state ~= nil and state.valid and not state.busy
end
function Service.available(player)
	local state = accounts[player]
	return state ~= nil and state.valid and not state.closing
end
function Service.busy(player)
	local state = accounts[player]
	return state ~= nil and state.busy == true
end
function Service.open(player)
	local state = {busy = true, valid = false, delivered = {}, tokens = 12, refillAt = os.clock()}
	accounts[player] = state
	local profile, errorCode = store:open(player.UserId)
	if accounts[player] ~= state or player.Parent ~= Players then store:close(player.UserId); return nil, "Unavailable" end
	state.busy = false
	state.profile, state.valid, state.errorCode = profile, profile ~= nil, errorCode
	player:SetAttribute("TLTInventoryMode", sessionOnly and "Studio session" or "RPG test save")
	return profile and Rules.copy(profile.heroes), errorCode
end
function Service.close(player)
	local state = accounts[player]
	if not state then return end
	state.closing = true
	-- An in-flight committed mutation must settle before releasing its fence.
	task.spawn(function()
		while state.busy do task.wait(0.1) end
		if accounts[player] ~= state then return end
		state.busy = true
		store:close(player.UserId)
		accounts[player] = nil
	end)
end
function Service.createHero(player, heroId, classId)
	local state = accounts[player]
	if not Service.ready(player) or state.closing then return "Unavailable" end
	state.busy = true
	local profile, errorCode = store:transact(player.UserId, function(current) return Rules.addHero(current, heroId, classId, Catalog) end)
	state.busy = false
	if not profile then
		if errorCode == "SaveUnknown" or errorCode == "AccountBusy" then state.valid = false end
		state.errorCode = errorCode
		return errorCode
	end
	state.profile = profile
	publish(player)
	return nil
end
function Service.stats(player, heroId)
	local state = accounts[player]
	if not state or not state.valid or not state.profile.heroes[heroId] then return nil end
	return Rules.stats(state.profile, heroId, Catalog)
end
function Service.counts(player, heroId)
	local state = accounts[player]
	local hero = state and state.profile and state.profile.heroes[heroId]
	if not hero then return {0, 0}, {"health_potion", "mana_potion"} end
	local counts = {}
	for index = 1, 2 do counts[index] = Rules.quantity(state.profile, heroId, hero.quickSlots[index]) end
	return counts, Rules.copy(hero.quickSlots)
end
local function atStorage(player)
	local context = options.heroSession.getInventoryContext(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return context and context.atHub and root and (root.Position - options.chest.Position).Magnitude <= 14
end
function Service.snapshot(player)
	local state = accounts[player]
	local context = options.heroSession.getInventoryContext(player)
	local heroId = context and context.heroId
	local snapshot = {revision = state and state.profile and state.profile.revision or 0, ready = state and state.valid or false,
		sessionOnly = sessionOnly, heroId = heroId, items = {}, heroes = {}, bagUsed = 0, storageUsed = 0, pending = 0,
		bagCapacity = Catalog.bagCapacity, storageCapacity = Catalog.storageCapacity, safe = false, atHub = context and context.atHub or false, atStorage = atStorage(player) == true}
	if not state or not state.profile then return snapshot end
	snapshot.heroes = Rules.copy(state.profile.heroes)
	snapshot.safe = context and (context.atHub or options.combat.isSafeForEquipment(player)) or false
	for _, item in pairs(state.profile.items) do
		local loc = item.location
		if loc.kind == "storage" or loc.kind == "pending" or loc.heroId == heroId then table.insert(snapshot.items, Rules.copy(item)) end
		if loc.kind == "pending" then snapshot.pending = snapshot.pending + 1 end
	end
	table.sort(snapshot.items, function(a,b) return a.instanceId < b.instanceId end)
	snapshot.storageUsed = Rules.count(state.profile, "storage")
	if heroId then snapshot.bagUsed = Rules.count(state.profile, "bag", heroId); snapshot.stats = Rules.stats(state.profile, heroId, Catalog) end
	return snapshot
end
function Service.refreshCharacter(player)
	local context = options.heroSession.getInventoryContext(player)
	if not context then return end
	local stats = Service.stats(player, context.heroId)
	if not stats then return end
	options.combat.refreshEquipment(player, stats)
	local character = player.Character
	if character then
		local counts, slots = Service.counts(player, context.heroId)
		for index = 1, 2 do
			character:SetAttribute("K0ItemCount" .. index, counts[index])
			character:SetAttribute("K0ItemDefinition" .. index, slots[index])
		end
	end
end
local function validCommand(command)
	if type(command) ~= "table" then return false end
	local allowed = {requestId=true, action=true, heroId=true, instanceId=true, itemVersion=true, revision=true, slot=true, quantity=true, destination=true}
	for key in pairs(command) do if not allowed[key] then return false end end
	if type(command.requestId) ~= "string" or #command.requestId < 1 or #command.requestId > 64 or not command.requestId:match("^[%w_-]+$") then return false end
	if command.action == "GetState" then return true end
	if type(command.action) ~= "string" or #command.action > 16 or type(command.heroId) ~= "string" or #command.heroId > 64
		or type(command.instanceId) ~= "string" or #command.instanceId > 100 then return false end
	if not Rules.integer(command.revision, 0, 1e12) or not Rules.integer(command.itemVersion, 1, 1e12) then return false end
	if command.slot ~= nil and type(command.slot) ~= "string" and type(command.slot) ~= "number" then return false end
	if type(command.slot) == "string" and #command.slot > 16 then return false end
	if command.quantity ~= nil and not Rules.integer(command.quantity, 1, 999) then return false end
	if command.destination ~= nil and command.destination ~= "bag" and command.destination ~= "storage" then return false end
	return true
end
local function handle(player, command, ...)
	local state = accounts[player]
	if not state or state.closing then return end
	local time = os.clock()
	state.tokens = math.min(12, state.tokens + (time - state.refillAt) * 3); state.refillAt = time
	if state.tokens < 1 then return end
	state.tokens = state.tokens - 1
	if select("#", ...) ~= 0 or not validCommand(command) then publish(player, nil, "InvalidRequest"); return end
	if command.action == "GetState" then publish(player, command.requestId, state.valid and nil or state.errorCode or "Unavailable"); return end
	if state.busy then publish(player, command.requestId, "Busy"); return end
	if not state.valid and not (state.pending and state.pending.requestId == command.requestId) then publish(player, command.requestId, state.errorCode or "Unavailable"); return end
	local heroContext = options.heroSession.getInventoryContext(player)
	if not heroContext or heroContext.heroId ~= command.heroId or options.heroSession.isBusy(player) then publish(player, command.requestId, "Changed"); return end
	local context = {safe = heroContext.atHub or options.combat.isSafeForEquipment(player), atHub = heroContext.atHub, atStorage = atStorage(player) == true,
		lifeToken = token .. ":" .. tostring(heroContext.generation)}
	local item = state.profile.items[command.instanceId]
	local definition = item and Catalog.items[item.definitionId]
	local life, human
	if command.action == "Use" and definition and definition.restore then
		local allowed, errorCode, character = options.combat.canUseInventoryItem(player, definition)
		context.canUse, context.useError, context.restore = allowed, errorCode, definition.restore
		life = character
		human = life and life:FindFirstChildOfClass("Humanoid")
	end
	if state.pending and state.pending.requestId == command.requestId and state.pendingLife then
		life = state.pendingLife
		human = life:FindFirstChildOfClass("Humanoid")
	end
	state.busy = true
	state.pending = Rules.copy(command)
	state.pendingLife = life
	local profile, errorCode = store:transact(player.UserId, function(current)
		-- A confirmed earlier result is reconciled even if this life has ended.
		-- Its saved life token prevents an old use from healing a new life.
		if current.operations[command.requestId] then return Rules.apply(current, command, context, Catalog) end
		-- Recheck server life and hub access after any datastore yield/retry.
		local latest = options.heroSession.getInventoryContext(player)
		if not latest or latest.heroId ~= command.heroId or latest.generation ~= heroContext.generation then return nil, "Changed" end
		if command.action == "Use" then
			if player.Character ~= life or not human or human.Health <= 0 then return nil, "Unavailable" end
			local usable, reason = options.combat.canUseInventoryItem(player, definition)
			context.canUse, context.useError = usable, reason
		end
		if command.action ~= "Use" and command.action ~= "Lock" then context.safe = latest.atHub or options.combat.isSafeForEquipment(player) end
		context.atStorage = atStorage(player) == true
		context.atHub = latest.atHub
		return Rules.apply(current, command, context, Catalog)
	end)
	if profile then
		state.profile, state.valid, state.errorCode = profile, true, nil
		local operation = profile.operations[command.requestId]
		if command.action == "Use" and definition and operation and operation.lifeToken == context.lifeToken and not state.delivered[command.requestId] then
			state.delivered[command.requestId] = true
			options.combat.applyInventoryItem(player, definition, life)
		end
		state.pending, state.pendingLife = nil, nil
		Service.refreshCharacter(player)
	elseif errorCode == "SaveUnknown" or errorCode == "AccountBusy" then
		state.valid, state.errorCode = false, errorCode
	else state.pending, state.pendingLife = nil, nil end
	state.busy = false
	publish(player, command.requestId, errorCode)
end
function Service.start(settings)
	assert(not started, "Inventory already started")
	started, options = true, settings
	local adapter
	if sessionOnly then
		local data = {}
		adapter = {UpdateAsync = function(_, key, callback)
			local result = callback(Rules.copy(data[key]))
			if result then data[key] = Rules.copy(result) end
			return result and Rules.copy(result)
		end}
	else
		assert(game.GameId == 10773575153, "RPG account storage is restricted to The Last Throne test Experience")
		adapter = game:GetService("DataStoreService"):GetDataStore("TLT_RPG_Accounts_v1_Test")
	end
	store = Store.new(adapter, Rules, Catalog, os.time, task.wait, token)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then remotes = Instance.new("Folder"); remotes.Name = "Remotes"; remotes.Parent = ReplicatedStorage end
	local function remote(name)
		local value = Instance.new("RemoteEvent"); value.Name = name; value.Parent = remotes; return value
	end
	stateRemote = remote("InventoryState")
	openRemote = remote("InventoryOpenStorage")
	remote("InventoryRequest").OnServerEvent:Connect(handle)
	options.prompt.Triggered:Connect(function(player)
		if Service.ready(player) and atStorage(player) then openRemote:FireClient(player); publish(player) end
	end)
	task.spawn(function()
		while true do
			task.wait(30)
			for player, state in pairs(accounts) do
				if state.valid and not state.busy and not state.closing then
					state.busy = true
					task.spawn(function()
						local profile, errorCode = store:renew(player.UserId)
						if profile then state.profile = profile else state.valid, state.errorCode = false, errorCode end
						state.busy = false
						if errorCode then publish(player, nil, errorCode) end
					end)
				end
			end
		end
	end)
	game:BindToClose(function()
		for player in pairs(accounts) do Service.close(player) end
		local deadline = os.clock() + 20
		while next(accounts) and os.clock() < deadline do task.wait(0.1) end
	end)
end
return Service
