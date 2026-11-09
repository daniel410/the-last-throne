local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
check(#C.deletedEquipment==18,'four Training weapons plus seven Rare/Epic families')
for _,id in ipairs(C.deletedEquipment)do
 local def=C.items[id]
 local p=assert(R.addHero(R.new(42),'hero',def.classId or 'knight',C))
 p.heroes.hero.level=10;p.heroes.hero.progression=dofile('src/shared/HeroProgression.luau').new(10)
 p.wallet.gold=987;p.wallet.diamonds=76
 local slot=def.slot=='accessory'and 'accessory1'or def.slot
 local locations={{kind='bag',heroId='hero'},{kind='storage'},{kind='pending'},{kind='equipped',heroId='hero',slot=slot}}
 for key,item in pairs(p.items)do if item.location.kind=='equipped'and item.location.slot==slot then p.items[key]=nil end end
 for i,loc in ipairs(locations)do
  local key='legacy-'..i
  p.items[key]={instanceId=key,definitionId=id,definitionVersion=C.version,ownerUserId=42,quantity=1,version=1,
   binding='account',locked=true,location=loc,sourceGrantId='legacy',enhancementLevel=next(def.stats) and 9 or nil}
 end
 check(R.validate(p,C),'legacy enhanced copies validate before cleanup '..id)
 local expected=R.copy(p)
 for key,item in pairs(expected.items)do if item.definitionId==id then expected.items[key]=nil end end
 expected.revision=expected.revision+1
 local cleaned=R.upgrade(R.copy(p),C)
 check(equal(cleaned,expected),'only requested equipment removed in every location '..id)
 check(R.validate(cleaned,C),'cleaned profile validates '..id)
 check(equal(R.upgrade(R.copy(cleaned),C),cleaned),'idempotent cleanup '..id)
 check(not F.grant(cleaned,R,C,'hero',id,1,'new-grant'),'deleted item cannot be granted '..id)
 local saved=R.copy(p);local lose=true
 local adapter={UpdateAsync=function(_,_,fn)
  fn(R.copy(saved));local value=fn(R.copy(saved));if value then saved=R.copy(value)end
  if lose then error('reply lost after commit')end;return value
 end}
 local store=Store.new(adapter,R,C,function()return 100 end,function()end,'deletion-session')
 local value,why=store:open(42)
 check(not value and why=='SaveUnknown','lost response never opens empty account '..id)
 check(equal(saved.items,expected.items)and saved.wallet.gold==987 and saved.wallet.diamonds==76,'committed cleanup preserves other property '..id)
 lose=false;value=assert(store:open(42))
 check(equal(value.items,expected.items)and value.revision==expected.revision,'retry does not resurrect items '..id)
 assert(store:close(42));value=assert(store:open(42))
 check(equal(value.items,expected.items),'reconnect persists deletion '..id)
end
for _,id in ipairs({'sentinel_shield','sentinel_helm','sentinel_mail','sentinel_boots','guardian_charm','knight_weapon_veteran','copper_ring','traveler_gloves'})do
 check(not C.items[id].deleted,'unrequested equipment preserved '..id)
end
print('Deleted equipment: '..n..' checks passed')
