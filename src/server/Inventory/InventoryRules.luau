local Story=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress) or dofile('src/shared/DeepwoodProgress.luau')
local Economy=game and require(game:GetService('ReplicatedStorage').Shared.EconomyRules) or dofile('src/shared/EconomyRules.luau')
-- Pure single-account transitions; no services, clocks, random IDs or side effects.
local Growth = game and require(game:GetService("ReplicatedStorage").Shared.HeroProgression) or dofile("src/shared/HeroProgression.luau")
local Rules = {}
function Rules.copy(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, entry in pairs(value) do result[key] = Rules.copy(entry) end
	return result
end
function Rules.integer(value, minimum, maximum)
	return type(value) == "number" and value == value and value % 1 == 0 and value >= minimum and value <= maximum
end
function Rules.new(userId)
	return {schemaVersion = 1, userId = userId, revision = 0, epoch = 0, heroes = {}, items = {}, operations = {}, operationOrder = {},wallet={version=1,gold=0,diamonds=0,claims={}}}
end
function Rules.count(profile, kind, heroId)
	local count = 0
	for _, item in pairs(profile.items) do
		if item.location.kind == kind and (kind ~= "bag" or item.location.heroId == heroId) then count = count + 1 end
	end
	return count
end
function Rules.equipped(profile, heroId, slot)
	for _, item in pairs(profile.items) do
		if item.location.kind == "equipped" and item.location.heroId == heroId and item.location.slot == slot then return item end
	end
end
function Rules.quantity(profile, heroId, definitionId)
	local count = 0
	for _, item in pairs(profile.items) do
		if item.location.kind == "bag" and item.location.heroId == heroId and item.definitionId == definitionId then count = count + item.quantity end
	end
	return count
end
function Rules.stats(profile, heroId, catalog)
	local result = {power = 0, armor = 0, health = 0, weapon = false, offhand = false}
	for _, item in pairs(profile.items) do
		if item.location.kind == "equipped" and item.location.heroId == heroId then
			for key, value in pairs(catalog.items[item.definitionId].stats or {}) do result[key] = result[key] + value end
			if item.location.slot == "weapon" or item.location.slot == "offhand" then result[item.location.slot] = item.definitionId end
		end
	end
	return result
end
local function sameLocation(a, b)
	return a.kind == b.kind and a.heroId == b.heroId
end
local function insertItem(profile, id, definitionId, quantity, location, catalog, source)
	local definition = catalog.items[definitionId]
	profile.items[id] = {instanceId = id, definitionId = definitionId, definitionVersion = catalog.version,
		ownerUserId = profile.userId, quantity = quantity, version = 1, binding = "account", locked = false,
		location = location, sourceGrantId = source or id}
	return definition
end
function Rules.addHero(profile, heroId, classId, catalog)
	if not catalog.classes[classId] then return nil, "InvalidRequest" end
	for _, hero in pairs(profile.heroes) do if hero.baseClassId == classId then return nil, "ClassAlreadyCreated" end end
	local nextProfile = Rules.copy(profile)
	nextProfile.heroes[heroId] = {heroId = heroId, baseClassId = classId, level = 1, progression = Growth.new(), quickSlots = {"health_potion", "mana_potion"}}
	local n = 0
	local function add(definitionId, quantity, location)
		n = n + 1
		insertItem(nextProfile, heroId .. "-starter-" .. n, definitionId, quantity, location or {kind = "bag", heroId = heroId}, catalog, "starter:" .. heroId)
	end
	add(classId .. "_weapon", 1, {kind = "equipped", heroId = heroId, slot = "weapon"})
	if classId == "knight" then add("knight_shield", 1, {kind = "equipped", heroId = heroId, slot = "offhand"}) end
	add(classId .. "_weapon_fine", 1)
	for _, id in ipairs(catalog.kit) do add(id, 1) end
	add("health_potion", 3); add("mana_potion", 3)
	for _, resource in ipairs({"health", "mana"}) do
		add(resource .. "_potion_medium", 2); add(resource .. "_potion_large", 1); add(resource .. "_potion_xl", 1)
	end
	add("iron_ore", 24); add("soft_hide", 8)
	add("health_potion", 5, {kind = "pending"})
	nextProfile.revision = nextProfile.revision + 1
	return nextProfile
end
function Rules.validate(profile, catalog)
 if profile and profile.wallet~=nil and not Economy.valid(profile.wallet) then return false end
	if type(profile) ~= "table" or profile.schemaVersion ~= 1 or not Rules.integer(profile.revision, 0, 1e12)
		or type(profile.heroes) ~= "table" or type(profile.items) ~= "table" or type(profile.operations) ~= "table"
		or type(profile.operationOrder) ~= "table" or not Rules.integer(profile.epoch, 0, 1e12) then return false end
	local classes, slots, heroCount = {}, {}, 0
	if #profile.operationOrder > 96 then return false end
	for id, operation in pairs(profile.operations) do
		if type(id) ~= "string" or #id > 64 or type(operation) ~= "table" or type(operation.fingerprint) ~= "string"
			or not Rules.integer(operation.revision, 0, profile.revision) or operation.lifeToken ~= nil and type(operation.lifeToken) ~= "string" then return false end
	end
	if profile.lease and (type(profile.lease) ~= "table" or type(profile.lease.token) ~= "string"
		or not Rules.integer(profile.lease.expiresAt, 0, 1e12) or profile.lease.epoch ~= profile.epoch) then return false end
	for id, hero in pairs(profile.heroes) do
		if type(hero) ~= "table" or id ~= hero.heroId or type(id) ~= "string" or not catalog.classes[hero.baseClassId]
			or classes[hero.baseClassId] or not Rules.integer(hero.level, 1, 80) or type(hero.quickSlots) ~= "table" then return false end
		if hero.deepwood~=nil and not Story.validate(hero.deepwood) then return false end
		if hero.progression ~= nil and (not Growth.validate(hero.progression,hero.baseClassId) or hero.level ~= hero.progression.level) then return false end
		for index = 1, 2 do
			local definition = catalog.items[hero.quickSlots[index]]
			if not definition or not definition.restore then return false end
		end
		classes[hero.baseClassId] = true; heroCount = heroCount + 1
	end
	if heroCount > 4 then return false end
	for id, item in pairs(profile.items) do
		if type(item) ~= "table" then return false end
		local def, loc = catalog.items[item.definitionId], item.location
		if not def or item.instanceId ~= id or type(id) ~= "string" or item.ownerUserId ~= profile.userId
			or item.definitionVersion ~= catalog.version or not Rules.integer(item.version, 1, 1e12)
			or not Rules.integer(item.quantity, 1, def.maxStack) or type(loc) ~= "table" or type(item.locked) ~= "boolean"
			or (item.binding ~= "account" and item.binding ~= "character") then return false end
		if item.binding == "character" and not profile.heroes[item.boundHeroId] then return false end
		if loc.kind == "bag" or loc.kind == "equipped" then
			if not profile.heroes[loc.heroId] or item.binding == "character" and loc.heroId ~= item.boundHeroId then return false end
		elseif loc.kind ~= "storage" and loc.kind ~= "pending" then return false end
		if loc.kind == "equipped" then
			local hero = profile.heroes[loc.heroId]
			local validSlot = false
			for _, slot in ipairs(catalog.slots) do if slot == loc.slot then validSlot = true end end
			if not validSlot or not def.slot or def.slot ~= loc.slot and not (def.slot == "accessory" and (loc.slot == "accessory1" or loc.slot == "accessory2"))
				or def.classId and def.classId ~= hero.baseClassId or (def.level or 1) > hero.level then return false end
			local key = loc.heroId .. ":" .. loc.slot
			if slots[key] then return false end
			slots[key] = true
		end
	end
	for heroId in pairs(profile.heroes) do
		if Rules.count(profile, "bag", heroId) > catalog.bagCapacity then return false end
		local groups = {}
		for _, item in pairs(profile.items) do
			local group = catalog.items[item.definitionId].uniqueGroup
			if group and item.location.kind == "equipped" and item.location.heroId == heroId then
				if groups[group] then return false end; groups[group] = true
			end
		end
	end
	return Rules.count(profile, "storage") <= catalog.storageCapacity
end
function Rules.fingerprint(command)
	local values = {}
	for _, key in ipairs({"action", "heroId", "instanceId", "itemVersion", "revision", "slot", "quantity", "destination"}) do
		local value = command[key]
		values[#values + 1] = key .. "=" .. type(value) .. ":" .. tostring(value)
	end
	return table.concat(values, "|")
end
function Rules.apply(profile, command, context, catalog)
	local fingerprint = Rules.fingerprint(command)
	local previous = profile.operations[command.requestId]
	if previous then
		if previous.fingerprint ~= fingerprint then return nil, "RequestConflict" end
		return Rules.copy(profile), nil, true
	end
	local hero = profile.heroes[command.heroId]
	if not hero then return nil, "HeroNotOwned" end
	if command.revision ~= profile.revision then return nil, "Changed" end
	local item = profile.items[command.instanceId]
	if not item or item.version ~= command.itemVersion then return nil, "Changed" end
	local def, loc = catalog.items[item.definitionId], item.location
	if not def or loc.kind ~= "storage" and loc.kind ~= "pending" and loc.heroId ~= hero.heroId then return nil, "NotOwned" end
	if item.binding == "character" and item.boundHeroId ~= hero.heroId then return nil, "BoundHero" end
	local action = command.action
	if action ~= "Lock" and action ~= "Use" and not context.safe then return nil, "InCombat" end
	if (action == "Deposit" or action == "Withdraw") and not context.atStorage then return nil, "StorageOnly" end
	if action == "Claim" and not context.atHub then return nil, "StorageOnly" end
	if action == "Lock" and loc.kind ~= "bag" and loc.kind ~= "equipped" then return nil, "BagOnly" end
	local nextProfile = Rules.copy(profile)
	local target = nextProfile.items[item.instanceId]
	if action == "Equip" then
		if loc.kind ~= "bag" or not def.slot then return nil, "BagOnly" end
		if def.classId and def.classId ~= hero.baseClassId then return nil, "WrongClass" end
		if hero.level < (def.level or 1) then return nil, "LevelRequired" end
		local slot = def.slot == "accessory" and command.slot or def.slot
		if def.slot == "accessory" and slot ~= "accessory1" and slot ~= "accessory2" then return nil, "ChooseAccessory" end
		local equipped = Rules.equipped(nextProfile, hero.heroId, slot)
		if def.uniqueGroup then
			for _, other in pairs(nextProfile.items) do
				if other.location.kind == "equipped" and other.location.heroId == hero.heroId and other ~= equipped
					and catalog.items[other.definitionId].uniqueGroup == def.uniqueGroup then return nil, "UniqueGroup" end
			end
		end
		if equipped then equipped.location = {kind = "bag", heroId = hero.heroId}; equipped.version = equipped.version + 1 end
		target.location = {kind = "equipped", heroId = hero.heroId, slot = slot}
	elseif action == "Unequip" then
		if loc.kind ~= "equipped" then return nil, "Changed" end
		if Rules.count(nextProfile, "bag", hero.heroId) >= catalog.bagCapacity then return nil, "BagFull" end
		target.location = {kind = "bag", heroId = hero.heroId}
	elseif action == "Lock" then
		target.locked = not target.locked
	elseif action == "Discard" then
		if loc.kind ~= "bag" then return nil, "BagOnly" end
		if item.locked then return nil, "ItemLocked" end
		if not Rules.integer(command.quantity, 1, item.quantity) then return nil, "InvalidQuantity" end
		target.quantity = target.quantity - command.quantity
		if target.quantity == 0 then nextProfile.items[target.instanceId] = nil end
	elseif action == "Assign" then
		if loc.kind ~= "bag" or not def.restore or not Rules.integer(command.slot, 1, 2) then return nil, "InvalidRequest" end
		nextProfile.heroes[hero.heroId].quickSlots[command.slot] = def.id
	elseif action == "Use" then
		if loc.kind ~= "bag" or not def.restore then return nil, "BagOnly" end
		if not context.canUse or context.restore ~= def.restore then return nil, context.useError or "Unavailable" end
		target.quantity = target.quantity - 1
		if target.quantity == 0 then nextProfile.items[target.instanceId] = nil end
	elseif action == "Deposit" or action == "Withdraw" or action == "Claim" then
		local expected = action == "Deposit" and "bag" or action == "Withdraw" and "storage" or "pending"
		if loc.kind ~= expected then return nil, "Changed" end
		local destination = action == "Deposit" and "storage" or action == "Withdraw" and "bag" or command.destination
		if destination ~= "bag" and destination ~= "storage" then return nil, "InvalidRequest" end
		if not Rules.integer(command.quantity, 1, item.quantity) then return nil, "InvalidQuantity" end
		local newLoc = destination == "bag" and {kind = "bag", heroId = hero.heroId} or {kind = "storage"}
		local remaining, mergeTargets = command.quantity, {}
		for _, other in pairs(nextProfile.items) do
			if sameLocation(other.location, newLoc) and other.definitionId == item.definitionId and other.binding == item.binding
				and other.boundHeroId == item.boundHeroId and other.locked == item.locked and other.quantity < def.maxStack then table.insert(mergeTargets, other) end
		end
		table.sort(mergeTargets, function(a, b) return a.instanceId < b.instanceId end)
		for _, other in ipairs(mergeTargets) do
			local amount = math.min(remaining, def.maxStack - other.quantity)
			other.quantity = other.quantity + amount; other.version = other.version + 1; remaining = remaining - amount
			if remaining == 0 then break end
		end
		if remaining > 0 then
			local capacity = destination == "bag" and catalog.bagCapacity or catalog.storageCapacity
			if Rules.count(nextProfile, destination, hero.heroId) >= capacity then return nil, destination == "bag" and "BagFull" or "StorageFull" end
			if command.quantity == item.quantity then
				target.location, target.quantity = newLoc, remaining
			else
				local splitId = command.requestId .. "-split"
				if nextProfile.items[splitId] then return nil, "RequestConflict" end
				local child = Rules.copy(item)
				child.instanceId, child.location, child.quantity, child.version = splitId, newLoc, remaining, 1
				child.parentInstanceId = item.instanceId
				nextProfile.items[splitId] = child
				target.quantity = target.quantity - command.quantity
			end
		else
			target.quantity = target.quantity - command.quantity
			if target.quantity == 0 then nextProfile.items[target.instanceId] = nil end
		end
	else return nil, "InvalidRequest" end
	if nextProfile.items[target.instanceId] then target.version = target.version + 1 end
	nextProfile.revision = nextProfile.revision + 1
	nextProfile.operations[command.requestId] = {fingerprint = fingerprint, revision = nextProfile.revision, lifeToken = context.lifeToken}
	table.insert(nextProfile.operationOrder, command.requestId)
	-- Evicted requests still carry an older mandatory revision/item version and
	-- cannot be applied again. Monetary/receipt grants must use a separate ledger.
	if #nextProfile.operationOrder > 96 then nextProfile.operations[table.remove(nextProfile.operationOrder, 1)] = nil end
	if not Rules.validate(nextProfile, catalog) then return nil, "Incompatible" end
	return nextProfile
end
-- Legacy account migration preserves roster, classes, items and all ownership.
function Rules.upgrade(profile)
	local changed=Economy.upgrade(profile)
	for _,hero in pairs(profile.heroes) do
		if hero.progression==nil then hero.progression=Growth.new(hero.level); changed=true
		elseif (hero.progression.version==1 or hero.progression.version==2) then hero.progression=Growth.upgrade(hero.progression); changed=true end
	end
	if changed then profile.revision=profile.revision+1 end
	return profile
end
function Rules.progress(profile,command,context,catalog)
	if command.stats~=nil and type(command.stats)~="table" then return nil,"InvalidRequest" end
	local hero=profile.heroes[command.heroId]
	if not hero then return nil,"HeroNotOwned" end
	local g=hero.progression or Growth.new(hero.level)
	local fingerprint=table.concat({"growth",command.action,command.heroId,tostring(command.skill or ""),tostring(command.slot or ""),tostring(command.branch or ""),tostring(command.stage or ""),
		tostring(command.stats and command.stats.STR or 0),tostring(command.stats and command.stats.DEX or 0),
		tostring(command.stats and command.stats.INT or 0),tostring(command.stats and command.stats.VIT or 0)},"|")
	if command.action~="AwardXP" then
		local previous=profile.operations[command.requestId]
		if previous then if previous.fingerprint~=fingerprint then return nil,"RequestConflict" end; return Rules.copy(profile),nil,true end
		if command.revision~=profile.revision then return nil,"Changed" end
		local investment=command.action=="AllocateStats" or command.action=="TrainSkill"
  if not context.atHub and not (investment and context.canInvest) then return nil,investment and "UnsafeGrowth" or "WaitForLobby" end
	elseif context.serverReward~=true then return nil,"InvalidRequest" end
	local nextG,reason,repeated=Growth.apply(g,command,hero.baseClassId)
	if not nextG then return nil,reason end
	local nextProfile=Rules.copy(profile)
	if repeated then return nextProfile,nil,true end
 Economy.upgrade(nextProfile)
	nextProfile.heroes[command.heroId].progression=nextG
	nextProfile.heroes[command.heroId].level=nextG.level
 if command.action=='AwardXP' and command.coins~=nil then
  if not Rules.integer(command.coins,0,1000000) then return nil,'InvalidRequest' end
  local h=nextProfile.heroes[command.heroId];h.deepwood=h.deepwood or Story.new();h.deepwood.killCoins=(h.deepwood.killCoins or 0)+command.coins
  nextProfile.wallet.gold=nextProfile.wallet.gold+command.coins
 end
	nextProfile.revision=nextProfile.revision+1
	if command.action~="AwardXP" then
		nextProfile.operations[command.requestId]={fingerprint=fingerprint,revision=nextProfile.revision}
		table.insert(nextProfile.operationOrder,command.requestId)
		if #nextProfile.operationOrder>96 then nextProfile.operations[table.remove(nextProfile.operationOrder,1)]=nil end
	end
	if not Rules.validate(nextProfile,catalog) then return nil,"Incompatible" end
	return nextProfile
end
-- Journal, first-clear receipt, Coins and quest XP commit in one account write.
function Rules.story(profile,heroId,chapterId,goalId,choice,catalog,stepId)
 local hero=profile.heroes[heroId];if not hero then return nil,'HeroNotOwned' end
 local journal,reason,reward=Story.apply(hero.deepwood or Story.new(),chapterId,goalId,choice,stepId)
 if not journal then return nil,reason end
 if reward.repeated then return Rules.copy(profile),nil,true end
 local n=Rules.copy(profile);local h=n.heroes[heroId];h.deepwood=journal
 -- Migrate historic earnings before assigning the new journal, then credit only this event.
 local migrated=Rules.copy(profile);Economy.upgrade(migrated);n.wallet=migrated.wallet;Economy.story(n,reward)
 local g=h.progression or Growth.new(h.level)
 g.xp=g.xp+reward.xp
 while g.level<80 and g.xp>=Growth.xpToNext(g.level) do g.xp=g.xp-Growth.xpToNext(g.level);g.level=g.level+1 end
 if g.level==80 then g.xp=0 end
 g.revision=g.revision+1
 h.progression=g;h.level=g.level;n.revision=n.revision+1
 local function grant(id,quantity,suffix)
  local instanceId=heroId..'-'..chapterId..'-'..suffix
  if not n.items[instanceId] then insertItem(n,instanceId,id,quantity,{kind='pending'},catalog,'story:'..heroId..':'..chapterId..':'..suffix) end
 end
 if reward.chapter=='DW-01' or reward.chapter=='DW-05' then grant(h.baseClassId..'_weapon_fine',1,'equipment')
 elseif reward.chapter=='DW-02' then grant('traveler_coat',1,'equipment')
 elseif reward.chapter=='DW-04' or reward.chapter=='DW-06' then grant('iron_ore',5,'materials') end
 if chapterId=='DW-05' and goalId=='warlord' then grant('warlord_seal',1,'bossseal') end
 if chapterId=='DW-07' and goalId=='king_shaman' then grant('king_shaman_seal',1,'bossseal') end
 if not Rules.validate(n,catalog) then return nil,'Incompatible' end
 return n
end
function Rules.acceptQuest(profile,heroId,chapterId,discovery)
 local hero=profile.heroes[heroId];if not hero then return nil,'HeroNotOwned' end
 local journal,reason,repeated=Story.accept(hero.deepwood or Story.new(),chapterId,discovery)
 if not journal then return nil,reason end
 if repeated then return Rules.copy(profile),nil,true end
 local n=Rules.copy(profile);n.heroes[heroId].deepwood=journal;n.revision=n.revision+1
 return n
end
function Rules.explore(profile,heroId,zone,x,z)
 local hero=profile.heroes[heroId];if not hero then return nil,'HeroNotOwned' end
 local s,reason,repeated=Story.reveal(hero.deepwood or Story.new(),zone,x,z)
 if not s then return nil,reason end
 if repeated then return Rules.copy(profile),nil,true end
 local n=Rules.copy(profile);n.heroes[heroId].deepwood=s;n.revision=n.revision+1
 return n
end
-- Preference shares the account fence with the rescue journal; no XP/Gold or new receipt.
function Rules.selectSelene(profile,heroId,following)
 local hero=profile.heroes[heroId];if not hero then return nil,'HeroNotOwned' end
 local journal,reason,repeated=Story.selectSelene(hero.deepwood or Story.new(),following)
 if not journal then return nil,reason end
 if repeated then return Rules.copy(profile),nil,true end
 local n=Rules.copy(profile);n.heroes[heroId].deepwood=journal;n.revision=n.revision+1;return n
end
function Rules.shop(profile,command,context,catalog) return Economy.apply(profile,command,context,catalog,Rules) end
return Rules
