-- RPG-only roster, items and hero growth share one account fence. Studio uses a session adapter.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Catalog = require(ReplicatedStorage.Shared.ItemCatalog)
local Growth = require(ReplicatedStorage.Shared.HeroProgression)
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
	if accounts[player] ~= state or player.Parent ~= Players then
		state.busy = false
		if accounts[player] == state then accounts[player] = nil end
		store:close(player.UserId)
		return nil, "Unavailable"
	end
	state.busy = false
	state.profile, state.valid, state.errorCode = profile, profile ~= nil, errorCode
	player:SetAttribute("TLTInventoryMode", sessionOnly and "Studio session" or "RPG test save")
	return profile and Rules.copy(profile.heroes), errorCode
end
function Service.close(player)
	local state = accounts[player]
	if not state then return end
 if state.transferPrepared then accounts[player]=nil;return end
	state.closing = true
	-- An in-flight committed mutation must settle before releasing its fence.
	task.spawn(function()
		while state.busy do task.wait(0.1) end
		local deadline=os.clock()+10
        while accounts[player]==state and state.revealJobs and #state.revealJobs>0 and os.clock()<deadline do
            local job=state.revealJobs[1];state.busy=true
            local profile,reason=store:transact(player.UserId,function(current) return Rules.explore(current,job.heroId,job.zone,job.x,job.z) end)
            if profile then state.profile,state.valid,state.errorCode=profile,true,nil;state.revealPending=nil;table.remove(state.revealJobs,1)
            elseif reason~='SaveUnknown' and reason~='AccountBusy' then break end
            state.busy=false;if reason then task.wait(.5) end
        end
        state.busy=false
		while accounts[player]==state and state.rewards and #state.rewards>0 and os.clock()<deadline do
			local reason=Service.progress(player,state.rewards[1],true)
			if not reason then table.remove(state.rewards,1)
			elseif reason=="SaveUnknown" or reason=="Busy" then task.wait(.5) else break end
		end
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
function Service.growth(player, heroId)
	local state=accounts[player]
	local hero=state and state.profile and state.profile.heroes[heroId]
	return hero and Growth.copy(hero.progression)
end
-- One account fence serializes items, point investments and XP. Unknown writes
-- retry the exact command; no new reward sequence is issued during recovery.
function Service.progress(player, command, serverReward)
	local state=accounts[player]
	if not state or state.busy or state.closing and not serverReward then return "Busy" end
	local pending=state.growthPending
	if not state.valid and not (pending and pending.requestId==command.requestId) then return state.errorCode or "Unavailable" end
	if pending then
		if pending.requestId~=command.requestId then return "Busy" end
		local function same(a,b)
			if type(a)~=type(b) then return false end
			if type(a)~="table" then return a==b end
			for k,v in pairs(a) do if not same(v,b[k]) then return false end end
			for k in pairs(b) do if a[k]==nil then return false end end
			return true
		end
		if not same(command,pending) then return "RequestConflict" end
		command=Growth.copy(pending)
	end
	local initial=options.heroSession.getInventoryContext(player)
	local investment=command.action=="AllocateStats" or command.action=="TrainSkill"
 if not serverReward then
  if not initial or initial.heroId~=command.heroId or options.heroSession.isBusy(player) then return "WaitForLobby" end
  if not initial.atHub and not (investment and options.combat.isSafeForEquipment(player)) then return investment and "UnsafeGrowth" or "WaitForLobby" end
 end
	state.busy=true
	state.growthPending=Growth.copy(command)
	local profile,errorCode=store:transact(player.UserId,function(current)
		local context={serverReward=serverReward==true}
		if not serverReward then
			local latest=options.heroSession.getInventoryContext(player)
			local sameLife=latest and initial and latest.heroId==initial.heroId and latest.generation==initial.generation
   context.atHub=sameLife and latest.atHub
   context.canInvest=sameLife and investment and options.combat.isSafeForEquipment(player)
		end
		return Rules.progress(current,command,context,Catalog)
	end)
	if profile then
		state.profile,state.valid,state.errorCode=profile,true,nil
		state.growthPending=nil
		Service.refreshCharacter(player)
		options.heroSession.refresh(player)
	elseif errorCode=="SaveUnknown" or errorCode=="AccountBusy" then
		state.valid,state.errorCode=false,errorCode
	else state.growthPending=nil end
	state.busy=false
	publish(player,command.requestId,errorCode)
	return errorCode
end
function Service.awardXP(player,heroId,amount,defeat,coins)
	local state=accounts[player]
	if not state or not state.valid or state.closing or not state.profile.heroes[heroId] then return end
	state.rewards=state.rewards or {}
	state.rewardSequences=state.rewardSequences or {}
	local saved=state.profile.heroes[heroId].progression
	local sequence=(state.rewardSequences[heroId] or (saved.rewardStream==token and saved.rewardSequence or 0))+1
	state.rewardSequences[heroId]=sequence
	table.insert(state.rewards,{action="AwardXP",heroId=heroId,amount=amount,coins=coins or 0,rewardKind=defeat and "Defeat" or nil,stream=token,sequence=sequence,requestId="xp_"..heroId.."_"..sequence})
	if state.rewardWorker then return end
	state.rewardWorker=true
	task.spawn(function()
		while accounts[player]==state and #state.rewards>0 and not state.closing do
			local command=state.rewards[1]
			local reason=Service.progress(player,command,true)
			if not reason then table.remove(state.rewards,1)
			elseif reason=="Busy" or reason=="SaveUnknown" or state.pending and state.errorCode=="SaveUnknown" then task.wait(1)
			else break end
		end
		state.rewardWorker=false
	end)
end
-- Server-only story command; never accepted by InventoryRequest/ProgressionRequest.
function Service.storyState(player,heroId)
 local state=accounts[player];local hero=state and state.profile and state.profile.heroes[heroId]
 return hero and Rules.copy(hero.deepwood or require(ReplicatedStorage.Shared.DeepwoodProgress).new())
end
function Service.storyEvent(player,heroId,chapterId,goalId,choice,stepId)
 local state=accounts[player]
 if not state or state.busy or state.closing then return 'Busy' end
 local key=heroId..':'..chapterId..':'..goalId..':'..tostring(choice)..':'..tostring(stepId)
 if state.storyPending and state.storyPending~=key then return 'Busy' end
 if not state.valid and state.storyPending~=key then return state.errorCode or 'Unavailable' end
 state.busy=true;state.storyPending=key
 local profile,reason=store:transact(player.UserId,function(current)
  if goalId=='@accept' then return Rules.acceptQuest(current,heroId,chapterId,choice==true) end
  if goalId=='@selene' then return Rules.selectSelene(current,heroId,choice) end
  return Rules.story(current,heroId,chapterId,goalId,choice,Catalog,stepId)
 end)
 if profile then
  state.profile,state.valid,state.errorCode=profile,true,nil;state.storyPending=nil
  Service.refreshCharacter(player);options.heroSession.refresh(player)
 elseif reason=='SaveUnknown' or reason=='AccountBusy' then state.valid,state.errorCode=false,reason
 else state.storyPending=nil end
 state.busy=false;publish(player,nil,reason);return reason
end
-- Monotonic fog discovery. Server positions enqueue cells; unknown writes retry
-- the same job and never replace a failed load with a new journal.
function Service.reveal(player,heroId,zone,x,z)
 local state=accounts[player]
 if not state or state.closing or not state.profile or not state.profile.heroes[heroId] then return end
 local story=state.profile.heroes[heroId].deepwood
 local cells=story and story.explored and story.explored[zone]
 if cells and (cells[tostring((z-1)*12+x)] or cells[(z-1)*12+x]) then return end
 local key=heroId..':'..zone..':'..x..':'..z
 state.revealJobs=state.revealJobs or {};state.revealKeys=state.revealKeys or {}
 if state.revealKeys[key] then return end
 state.revealKeys[key]=true;table.insert(state.revealJobs,{key=key,heroId=heroId,zone=zone,x=x,z=z})
 if state.revealRunning then return end;state.revealRunning=true
 task.spawn(function()
  while accounts[player]==state and #state.revealJobs>0 and not state.closing do
   local job=state.revealJobs[1]
   if state.busy or not state.valid and state.revealPending~=job.key then task.wait(.25)
   else
    state.busy=true;state.revealPending=job.key
    local profile,reason=store:transact(player.UserId,function(current) return Rules.explore(current,job.heroId,job.zone,job.x,job.z) end)
    if profile then
     state.profile,state.valid,state.errorCode=profile,true,nil;state.revealPending=nil
     state.revealKeys[job.key]=nil;table.remove(state.revealJobs,1)
    elseif reason=='SaveUnknown' or reason=='AccountBusy' then state.valid,state.errorCode=false,reason
    else state.revealPending=nil;state.revealKeys[job.key]=nil;table.remove(state.revealJobs,1) end
    state.busy=false
    if profile then publish(player) end
    if reason then task.wait(1) end
   end
  end
  state.revealRunning=false
 end)
end
local function atStorage(player)
	local context = options.heroSession.getInventoryContext(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not context or not context.atHub or not root then return false end
 for _,chest in ipairs(options.chests or {options.chest}) do if (root.Position-chest.Position).Magnitude<=14 then return true end end
 return false
end
function Service.snapshot(player)
	local state = accounts[player]
	local context = options.heroSession.getInventoryContext(player)
	local heroId = context and context.heroId
	local snapshot = {revision = state and state.profile and state.profile.revision or 0, ready = state and state.valid or false,
		sessionOnly = sessionOnly, heroId = heroId, items = {}, heroes = {}, bagUsed = 0, storageUsed = 0, pending = 0,
		bagCapacity = Catalog.bagCapacity, storageCapacity = Catalog.storageCapacity, safe = false, atHub = context and context.atHub or false, atStorage = atStorage(player) == true}
	if not state or not state.profile then return snapshot end
 local money=Rules.copy(state.profile);require(ReplicatedStorage.Shared.EconomyRules).upgrade(money);snapshot.wallet=money.wallet
	snapshot.heroes = Rules.copy(state.profile.heroes)
	snapshot.safe = context and (context.atHub or options.combat.isSafeForEquipment(player)) or false
 snapshot.canInvest=snapshot.ready and snapshot.safe or false
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
	if command.action == "GetState" then
		local errorCode
		if not state.valid then errorCode = state.errorCode or "Unavailable" end
		publish(player, command.requestId, errorCode)
		return
	end
	if state.busy then publish(player, command.requestId, "Busy"); return end
	if not state.valid and not (state.pending and state.pending.requestId == command.requestId) then publish(player, command.requestId, state.errorCode or "Unavailable"); return end
	local heroContext = options.heroSession.getInventoryContext(player)
	if not heroContext or heroContext.heroId ~= command.heroId or options.heroSession.isBusy(player) then publish(player, command.requestId, "Changed"); return end
	if command.action == "Use" and heroContext.atHub then publish(player, command.requestId, "EnterTutorial"); return end
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
	remote("HeroProgressionRequest").OnServerEvent:Connect(function(player,command,...)
		local state=accounts[player]
		if not state or state.closing then return end
		local current=os.clock()
		state.tokens=math.min(12,state.tokens+(current-state.refillAt)*3); state.refillAt=current
		if state.tokens<1 then return end
		state.tokens=state.tokens-1
		local valid=select("#",...)==0 and type(command)=="table"
		if valid then
			local allowed={action=true,requestId=true,heroId=true,revision=true,stats=true,skill=true,slot=true,branch=true,stage=true}
			for key in pairs(command) do if not allowed[key] then valid=false end end
			valid=valid and type(command.requestId)=="string" and #command.requestId>0 and #command.requestId<=64 and command.requestId:match("^[%w_-]+$")
				and type(command.heroId)=="string" and #command.heroId<=64 and Growth.integer(command.revision,0,1e12)
				and (command.action=="AllocateStats" or command.action=="TrainSkill" or command.action=="SetSkillSlot" or command.action=="Advance")
		end
		if not valid then publish(player,nil,"InvalidRequest"); return end
		local reason=Service.progress(player,command,false)
		if reason then publish(player,command.requestId,reason) end
	end)
	for _,prompt in ipairs(options.prompts or {options.prompt}) do prompt.Triggered:Connect(function(player)
  if Service.ready(player) and atStorage(player) then openRemote:FireClient(player);publish(player) end
 end) end
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
-- Flush before releasing the account fence. Failure never starts a teleport.
function Service.prepareTransfer(player)
 local s=accounts[player];if not s or not s.valid or s.closing then return false end
 s.closing=true
 local deadline=os.clock()+15
 while s.busy and os.clock()<deadline do task.wait(.1) end
 if s.busy or s.pending or s.growthPending or s.storyPending or s.shopPending or options.storyPending and options.storyPending(player) then s.closing=false;return false end
 while s.rewards and #s.rewards>0 and os.clock()<deadline do
  local reason=Service.progress(player,s.rewards[1],true)
  if not reason then table.remove(s.rewards,1) else s.closing=false;return false end
 end
 while s.revealJobs and #s.revealJobs>0 and os.clock()<deadline do
  local job=s.revealJobs[1];s.busy=true
  local p,e=store:transact(player.UserId,function(current) return Rules.explore(current,job.heroId,job.zone,job.x,job.z) end);s.busy=false
  if not p then s.closing=false;s.valid=false;s.errorCode=e;return false end
  s.profile=p;table.remove(s.revealJobs,1)
 end
 if s.rewards and #s.rewards>0 or s.revealJobs and #s.revealJobs>0 or not s.valid then s.closing=false;return false end
 s.busy=true;local p,e=store:close(player.UserId);s.busy=false
 if not p then
  -- A release may have committed without acknowledgement. Reacquire only if
  -- no other server owns the account; never continue on the old cached fence.
  local restored,reason=store:open(player.UserId)
  s.closing=false;s.profile=restored or s.profile;s.valid=restored~=nil;s.errorCode=reason or e;publish(player);return false
 end
 s.profile=p;s.valid=false;s.transferPrepared=true;publish(player);return true
end
function Service.resumeTransfer(player)
 local s=accounts[player];if not s then return false end
 if not s.transferPrepared then s.closing=false;return s.valid end
 local p,e=store:open(player.UserId)
 if not p then s.errorCode=e;publish(player);return false end
 s.profile=p;s.valid=true;s.errorCode=nil;s.closing=false;s.transferPrepared=nil;publish(player);return true
end
function Service.shop(player,command)
 local s=accounts[player];if not s or s.busy or s.closing then return 'Busy' end
 if not s.valid and not (s.shopPending and s.shopPending.requestId==command.requestId) then return s.errorCode or 'Unavailable' end
 if s.shopPending and s.shopPending.requestId~=command.requestId then return 'Busy' end
 if s.shopPending then for _,k in ipairs({'action','heroId','offerId','instanceId','itemVersion','revision'}) do if s.shopPending[k]~=command[k] then return 'RequestConflict' end end end
 s.busy=true;s.shopPending=Rules.copy(command)
 local p,e=store:transact(player.UserId,function(current)
  local ctx=options.heroSession.getInventoryContext(player)
  return Rules.shop(current,command,{atLobby=workspace:GetAttribute('TLTServerRole')~='Battle' and ctx and ctx.heroId==command.heroId and ctx.atHub and player:GetAttribute('K0SessionPhase')=='Lobby'},Catalog)
 end)
 if p then s.profile=p;s.valid=true;s.errorCode=nil;s.shopPending=nil
 elseif e=='SaveUnknown' or e=='AccountBusy' then s.valid=false;s.errorCode=e
 else s.shopPending=nil end
 s.busy=false;publish(player,command.requestId,e);return e
end
return Service
