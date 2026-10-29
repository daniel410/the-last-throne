-- Pure production reducers and account-store adapter with adversarial failures.
if game ~= nil then return {} end
local R = dofile("src/server/Inventory/InventoryRules.luau")
local Store = dofile("src/server/Inventory/AccountStore.luau")
local C = dofile("src/shared/ItemCatalog.luau")
local checks, sequence = 0, 0
local function check(value, label) checks=checks+1; assert(value,label) end
local function equal(a,b,label) check(a==b,label..": "..tostring(a).." ~= "..tostring(b)) end
local function valid(p) check(R.validate(p,C),"inventory invariant") end
local function profile()
	local p=R.addHero(R.new(42),"hero-knight","knight",C)
	valid(p)
	return p
end
local function find(p,id,kind)
	for _,item in pairs(p.items) do if item.definitionId==id and (not kind or item.location.kind==kind) then return item end end
	error("Missing fixture "..id.." "..tostring(kind))
end
local function request(p,item,action,extra)
	sequence=sequence+1
	local command={requestId="request-"..sequence,action=action,heroId="hero-knight",instanceId=item.instanceId,itemVersion=item.version,revision=p.revision}
	for key,value in pairs(extra or {}) do command[key]=value end
	return command
end
local safe={safe=true,atStorage=true,atHub=true,canUse=true,restore="health",lifeToken="life-1"}
local function apply(p,item,action,extra,context)
	local command=request(p,item,action,extra)
	local nextP,errorCode,repeated=R.apply(p,command,context or safe,C)
	if nextP then valid(nextP) end
	return nextP,errorCode,command,repeated
end
-- Six distinct definitions retain the original saved Small potion IDs.
equal(#C.potions,8,"eight potion variants")
for _,id in ipairs(C.potions) do
	local def=C.items[id]
	equal(def.amount,(def.restore=="health" and {100,300,500,1000} or {50,100,200,500})[def.potionTier],"user-approved restore amount")
	local sample=profile()
	equal(def.iconKey,id,"variant owns a distinct icon identity")
	equal(def.maxStack,99,"potions share the 99-stack contract")
	equal(R.quantity(sample,"hero-knight",id),def.potionTier==1 and 3 or def.potionTier==2 and 2 or 1,"training stock per tier")
	local assigned=assert(apply(sample,find(sample,id,"bag"),"Assign",{slot=1}))
	equal(assigned.heroes['hero-knight'].quickSlots[1],id,"all six potions assign by exact definition")
	local count=R.quantity(assigned,"hero-knight",id)
	local context={safe=true,atHub=true,canUse=true,restore=def.restore,lifeToken="potion-life"}
	local consumed,_,command=apply(assigned,find(assigned,id,"bag"),"Use",nil,context)
	assert(consumed)
	equal(R.quantity(consumed,"hero-knight",id),count-1,"one potion of selected size is consumed")
	local replay=assert(R.apply(consumed,command,context,C))
	equal(R.quantity(replay,"hero-knight",id),count-1,"replay cannot consume another variant or quantity")
end
equal(C.items.health_potion.amount,100,"Small HP follows user restore amount")
equal(C.items.mana_potion.amount,50,"Small MP follows user restore amount")
local p=profile()
equal(#C.slots,8,"exactly eight equipment slots")
equal(R.quantity(p,"hero-knight","health_potion"),3,"starter potions in bag")
equal(R.count(p,"pending"),1,"starter training grant is pending")
for _,class in ipairs({"elf","dwarf","mage"}) do p=assert(R.addHero(p,"hero-"..class,class,C)); valid(p) end
for id,hero in pairs(p.heroes) do
	equal(C.items[R.equipped(p,id,"weapon").definitionId].classId,hero.baseClassId,"class-specific starter weapon")
end
local duplicate,errorCode=R.addHero(p,"forged-hero","knight",C)
equal(duplicate,nil,"cannot recreate class"); equal(errorCode,"ClassAlreadyCreated","class immutable")

p=profile()
for _,id in ipairs({"traveler_hood","traveler_coat","traveler_gloves","traveler_boots","copper_ring","amber_charm"}) do
	p=assert(apply(p,find(p,id,"bag"),"Equip",C.items[id].slot=="accessory" and {slot=id=="copper_ring" and "accessory1" or "accessory2"} or nil))
end
for _,slot in ipairs(C.slots) do check(R.equipped(p,"hero-knight",slot)~=nil,"equipped "..slot) end
local stats=R.stats(p,"hero-knight",C)
equal(stats.power,8,"aggregate server power"); equal(stats.armor,6,"aggregate armor"); equal(stats.health,100,"aggregate HP")
local current=find(p,"knight_weapon_fine","bag")
local beforeCount=R.count(p,"bag","hero-knight")
local first,err,command=apply(p,current,"Equip")
equal(err,nil,"equip succeeds"); equal(R.count(first,"bag","hero-knight"),beforeCount,"swap conserves bag slots")
equal(R.equipped(first,"hero-knight","weapon").definitionId,"knight_weapon_fine","server selects fixed slot")
local replay,replayError,repeated=R.apply(first,command,safe,C)
equal(replayError,nil,"same request replay succeeds"); check(repeated,"replay recognized"); equal(replay.revision,first.revision,"replay no mutation")
local altered=R.copy(command); altered.action="Deposit"
local denied,reason=R.apply(first,altered,safe,C)
equal(denied,nil,"changed request denied"); equal(reason,"RequestConflict","changed ID collision")
denied,reason=apply(first,find(first,"traveler_hood","equipped"),"Unequip",nil,{safe=false})
equal(denied,nil,"combat cannot change equipment"); equal(reason,"InCombat","combat reason")
denied,reason=apply(first,find(first,"veteran_hood","bag"),"Equip")
equal(reason,"LevelRequired","level checked on server")

p=profile()
local ring=find(p,"copper_ring","bag")
denied,reason=apply(p,ring,"Equip")
equal(reason,"ChooseAccessory","no automatic accessory target")
p=assert(apply(p,ring,"Equip",{slot="accessory1"}))
local another=R.copy(find(p,"copper_ring","equipped")); another.instanceId="second-ring"; another.location={kind="bag",heroId="hero-knight"}; p.items[another.instanceId]=another; valid(p)
denied,reason=apply(p,another,"Equip",{slot="accessory2"})
equal(reason,"UniqueGroup","unique accessories enforced")
p=assert(apply(p,another,"Equip",{slot="accessory1"})); valid(p)

p=profile()
while R.count(p,"bag","hero-knight")<C.bagCapacity do
	local item=R.copy(find(p,"traveler_gloves","bag")); item.instanceId="filler-"..R.count(p,"bag","hero-knight"); p.items[item.instanceId]=item
end
valid(p)
p=assert(apply(p,find(p,"knight_weapon_fine","bag"),"Equip"))
equal(R.count(p,"bag","hero-knight"),60,"full bag swap works")
denied,reason=apply(p,find(p,"knight_weapon_fine","equipped"),"Unequip")
equal(reason,"BagFull","full bag unequip denied"); check(R.equipped(p,"hero-knight","weapon")~=nil,"failed unequip preserves equipment")
local pendingGear=find(p,"health_potion","pending")
pendingGear.definitionId,pendingGear.quantity="traveler_gloves",1
valid(p)
denied,reason=apply(p,pendingGear,"Claim",{quantity=1,destination="bag"})
equal(reason,"BagFull","claim needs full quantity space or merge capacity")
-- A pending potion CAN merge into an existing partial stack despite full bag.
pendingGear.definitionId,pendingGear.quantity="health_potion",5
local result=assert(apply(p,find(p,"health_potion","pending"),"Claim",{quantity=1,destination="bag"}))
equal(R.quantity(result,"hero-knight","health_potion"),4,"full bag partial stack claim merges")

p=profile()
local ore=find(p,"iron_ore","bag")
local oldId=ore.instanceId
local nextP=assert(apply(p,ore,"Deposit",{quantity=7}))
equal(nextP.items[oldId].quantity,17,"partial transfer keeps remainder")
local stored=find(nextP,"iron_ore","storage")
equal(stored.quantity,7,"partial transfer exact destination quantity")
equal(stored.parentInstanceId,oldId,"split provenance retained")
equal(stored.sourceGrantId,ore.sourceGrantId,"split grant retained")
nextP=assert(apply(nextP,find(nextP,"iron_ore","bag"),"Deposit",{quantity=17}))
equal(R.count(nextP,"storage"),1,"identical stacks merge")
equal(find(nextP,"iron_ore","storage").quantity,24,"quantity conserved after merge")
equal(R.quantity(nextP,"hero-knight","iron_ore"),0,"source removed only once")
for _,quantity in ipairs({0,-1,1.5,25,math.huge,0/0}) do
	denied,reason=apply(nextP,find(nextP,"iron_ore","storage"),"Withdraw",{quantity=quantity})
	equal(denied,nil,"invalid quantity denied"); equal(reason,"InvalidQuantity","quantity reason")
end
denied,reason=apply(nextP,find(nextP,"iron_ore","storage"),"Withdraw",{quantity=1},{safe=true,atStorage=false})
equal(reason,"StorageOnly","remote storage access denied")

-- Both 999 material and 99 potion stack boundaries preserve total quantity.
p=profile()
ore=find(p,"iron_ore","bag")
local full=R.copy(ore); full.instanceId="stored-ore"; full.location={kind="storage"}; full.quantity=995; p.items[full.instanceId]=full
p=assert(apply(p,ore,"Deposit",{quantity=10}))
equal(p.items['stored-ore'].quantity,999,"material stack caps at 999")
equal(find(p,"iron_ore","bag").quantity,14,"exact source remainder after capped merge")
local total=0
for _,item in pairs(p.items) do if item.definitionId=="iron_ore" then total=total+item.quantity end end
equal(total,1019,"material quantity conserved across split and capped merge")
p=profile()
while R.count(p,"storage")<C.storageCapacity do
	local item=R.copy(find(p,"traveler_gloves","bag")); item.instanceId="stored-filler-"..R.count(p,"storage"); item.location={kind="storage"}; p.items[item.instanceId]=item
end
valid(p)
local original=find(p,"iron_ore","bag")
denied,reason=apply(p,original,"Deposit",{quantity=1})
equal(reason,"StorageFull","full destination rejects whole transfer")
equal(p.items[original.instanceId].quantity,24,"failed transfer preserves full original stack")
local hpStack=R.copy(find(p,"health_potion","bag")); hpStack.instanceId="stored-partial-hp"; hpStack.location={kind="storage"}; hpStack.quantity=97
p.items['stored-filler-0']=nil; p.items[hpStack.instanceId]=hpStack
denied,reason=apply(p,find(p,"health_potion","bag"),"Deposit",{quantity=3})
equal(reason,"StorageFull","cannot silently transfer only mergeable amount")
equal(p.items[hpStack.instanceId].quantity,97,"partial destination merge rolls back on full transfer failure")
p=assert(apply(p,find(p,"health_potion","bag"),"Deposit",{quantity=2}))
equal(p.items[hpStack.instanceId].quantity,99,"potion merge into full container caps at 99")

p=assert(R.addHero(profile(),"hero-mage","mage",C))
local sword=find(p,"knight_weapon_fine","bag")
p=assert(apply(p,sword,"Deposit",{quantity=1}))
local commandMage=request(p,find(p,"knight_weapon_fine","storage"),"Withdraw",{quantity=1,heroId="hero-mage"})
p=assert(R.apply(p,commandMage,safe,C)); valid(p)
local mageSword=p.items[sword.instanceId]
denied,reason=apply(p,mageSword,"Equip",{heroId="hero-mage"})
equal(reason,"WrongClass","other class can store and own but not equip")
mageSword.binding,mageSword.boundHeroId="character","hero-mage"
p=assert(apply(p,mageSword,"Deposit",{quantity=1,heroId="hero-mage"}))
denied,reason=apply(p,p.items[sword.instanceId],"Withdraw",{quantity=1})
equal(reason,"BoundHero","character binding preserved through storage")

p=profile()
local hp=find(p,"health_potion","bag")
local locked=assert(apply(p,hp,"Lock"))
check(locked.items[hp.instanceId].locked,"lock toggled")
locked=assert(apply(locked,locked.items[hp.instanceId],"Deposit",{quantity=3}))
check(find(locked,"health_potion","storage").locked,"lock does not block transfers")
denied,reason=apply(p,hp,"Use",nil,{safe=false,canUse=false,restore="health",useError="HealthFull"})
equal(reason,"HealthFull","full HP no consume"); equal(R.quantity(p,"hero-knight","health_potion"),3,"full HP preserves quantity")
local used,_,useCommand=apply(p,hp,"Use",nil,safe)
equal(R.quantity(used,"hero-knight","health_potion"),2,"consume exactly one")
local usedAgain=assert(R.apply(used,useCommand,safe,C))
equal(R.quantity(usedAgain,"hero-knight","health_potion"),2,"duplicate consume no extra cost")
local stale=request(p,hp,"Use")
denied,reason=R.apply(used,stale,safe,C)
equal(reason,"Changed","concurrent old revision rejected")

p=profile()
local mana=find(p,"mana_potion","bag")
p=assert(apply(p,mana,"Assign",{slot=1}))
equal(p.heroes['hero-knight'].quickSlots[1],"mana_potion","quick slot accepts an owned potion")
equal(R.quantity(p,"hero-knight","mana_potion"),3,"assignment consumes nothing")
denied,reason=apply(p,find(p,"mana_potion","bag"),"Assign",{slot=3})
equal(reason,"InvalidRequest","only two item slots")
denied,reason=apply(p,find(p,"iron_ore","bag"),"Assign",{slot=2})
equal(reason,"InvalidRequest","materials cannot become potion slots")
local lastPotion=find(p,"health_potion","bag")
lastPotion.quantity=1
p=assert(apply(p,lastPotion,"Use"))
equal(R.quantity(p,"hero-knight","health_potion"),0,"last potion consumes the stack")
equal(p.heroes['hero-knight'].quickSlots[2],"mana_potion","consuming another potion preserves assignment")

-- Discard removes only the requested owned, unlocked bag quantity and is replay-safe.
p=profile()
local ore=find(p,"iron_ore","bag")
local partial,discardError,discardCommand=apply(p,ore,"Discard",{quantity=7})
equal(discardError,nil,"partial discard succeeds")
equal(partial.items[ore.instanceId].quantity,17,"discard preserves remainder")
equal(p.items[ore.instanceId].quantity,24,"discard does not mutate input")
equal(R.stats(partial,"hero-knight",C).weapon,"knight_weapon","discard preserves equipped weapon")
local repeatDiscard=assert(R.apply(partial,discardCommand,safe,C))
equal(repeatDiscard.items[ore.instanceId].quantity,17,"replay does not discard twice")
local conflict=R.copy(discardCommand);conflict.quantity=8
local _,discardReason=R.apply(partial,conflict,safe,C)
equal(discardReason,"RequestConflict","reused request cannot change discarded count")
local staleDiscard=request(p,ore,"Discard",{quantity=1})
_,discardReason=R.apply(partial,staleDiscard,safe,C);equal(discardReason,"Changed","old revision cannot discard")
for _,quantity in ipairs({0,-1,1.5,25,math.huge,0/0}) do
 local denied,reason=apply(p,ore,"Discard",{quantity=quantity});equal(denied,nil,"invalid discard quantity rejected");equal(reason,"InvalidQuantity","discard quantity reason")
end
local lockedProfile=assert(apply(p,ore,"Lock"))
_,discardReason=apply(lockedProfile,lockedProfile.items[ore.instanceId],"Discard",{quantity=1});equal(discardReason,"ItemLocked","locked item cannot be discarded")
local unlockedProfile=assert(apply(lockedProfile,lockedProfile.items[ore.instanceId],"Lock"))
local deleted=assert(apply(unlockedProfile,unlockedProfile.items[ore.instanceId],"Discard",{quantity=24}))
equal(deleted.items[ore.instanceId],nil,"full stack removed")
_,discardReason=apply(p,find(p,"knight_weapon","equipped"),"Discard",{quantity=1});equal(discardReason,"BagOnly","equipped item must be removed first")
local equippedLocked=assert(apply(p,find(p,"knight_weapon","equipped"),"Lock"));check(find(equippedLocked,"knight_weapon","equipped").locked,"equipped item can be locked")
local unequipped=assert(apply(equippedLocked,find(equippedLocked,"knight_weapon","equipped"),"Unequip"));check(find(unequipped,"knight_weapon","bag").locked,"unequipping preserves lock")
_,discardReason=apply(p,find(p,"health_potion","pending"),"Discard",{quantity=1});equal(discardReason,"BagOnly","unclaimed reward cannot be discarded")
local stored=assert(apply(p,ore,"Deposit",{quantity=24}))
_,discardReason=apply(stored,find(stored,"iron_ore","storage"),"Discard",{quantity=1});equal(discardReason,"BagOnly","storage cannot be discarded directly")
_,discardReason=apply(p,ore,"Discard",{quantity=1},{safe=false});equal(discardReason,"InCombat","combat cannot discard")
local other=assert(R.addHero(p,"hero-mage","mage",C))
_,discardReason=apply(other,find(other,"mage_weapon_fine","bag"),"Discard",{quantity=1});equal(discardReason,"NotOwned","other hero bag cannot be discarded")
local hpDiscard=assert(apply(p,find(p,"health_potion","bag"),"Discard",{quantity=3}))
equal(R.quantity(hpDiscard,"hero-knight","health_potion"),0,"discard updates quick-slot count")
equal(hpDiscard.heroes['hero-knight'].quickSlots[1],"health_potion","empty quick slot preserves selection")

-- A fake UpdateAsync adapter exercises callback retries and unknown write results.
local data,failBefore,failAfter,callbacks={},false,0,0
local adapter={UpdateAsync=function(_,key,fn)
	if failBefore then error("injected read failure") end
	callbacks=callbacks+1
	local original=R.copy(data[key])
	local proposed=fn(R.copy(original))
	local repeatedProposal=fn(R.copy(original)) -- Roblox may re-run the pure callback.
	if proposed then check(repeatedProposal.revision==proposed.revision,"callback retry stable revision") end
	if proposed then data[key]=R.copy(proposed) end
	if failAfter>0 then failAfter=failAfter-1; error("injected lost acknowledgement") end
	return proposed and R.copy(proposed)
end}
local time=1000
local function newStore(token) return Store.new(adapter,R,C,function() return time end,function() end,token) end
local a,b=newStore("server-a"),newStore("server-b")
local account=assert(a:open(42))
equal(account.epoch,1,"first session epoch")
denied,reason=b:open(42); equal(reason,"AccountBusy","other live server fenced")
account=assert(a:transact(42,function(current) return R.addHero(current,"hero-knight","knight",C) end))
local weapon=find(account,"knight_weapon_fine","bag")
local cmd=request(account,weapon,"Equip")
failAfter=1
account=assert(a:transact(42,function(current) return R.apply(current,cmd,safe,C) end))
equal(account.revision,2,"unknown response retry commits once")
equal(R.equipped(account,"hero-knight","weapon").definitionId,"knight_weapon_fine","unknown write recovered")
time=time+121
local taken=assert(b:open(42)); equal(taken.epoch,2,"expired lease gets new fence")
denied,reason=a:transact(42,function(current) return current end)
equal(reason,"AccountBusy","old server cannot overwrite new session")
assert(b:close(42)); check(not data['account:42'].lease,"release clears only current lease")
local rejoined=assert(a:open(42)); valid(rejoined)
equal(R.equipped(rejoined,"hero-knight","weapon").definitionId,"knight_weapon_fine","items survive reopen")
failBefore=true
local empty=newStore("server-c")
denied,reason=empty:open(88)
equal(reason,"SaveUnknown","read failure distinct from missing")
equal(data['account:88'],nil,"read failure never writes empty account")
failBefore=false
data['account:99']={schemaVersion=2,userId=99}
denied,reason=empty:open(99); equal(reason,"Incompatible","future schema preserved"); equal(data['account:99'].schemaVersion,2,"future data not replaced")
assert(a:close(42))
print("Inventory: "..checks.." ownership, capacity, stacking, idempotency, binding and recovery checks passed")
