assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated place only')
do
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local F=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local Store=require(game.ServerScriptService.Server.Inventory.AccountStore)
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
check(#C.deletedEquipment==14,'seven families including Epic')
for _,id in ipairs(C.deletedEquipment)do
 local def=C.items[id]
 local p=assert(R.addHero(R.new(42),'hero',def.classId or 'knight',C))
 p.heroes.hero.level=10;p.heroes.hero.progression=require(game.ReplicatedStorage.Shared.HeroProgression).new(10)
 p.wallet.gold=987;p.wallet.diamonds=76
 local slot=def.slot=='accessory'and 'accessory1'or def.slot
 local locations={{kind='bag',heroId='hero'},{kind='storage'},{kind='pending'},{kind='equipped',heroId='hero',slot=slot}}
 for key,item in pairs(p.items)do if item.location.kind=='equipped'and item.location.slot==slot then p.items[key]=nil end end
 for i,loc in ipairs(locations)do
  local key='legacy-'..i
  p.items[key]={instanceId=key,definitionId=id,definitionVersion=C.version,ownerUserId=42,quantity=1,version=1,
   binding='account',locked=true,location=loc,sourceGrantId='legacy',enhancementLevel=9}
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

end
do
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local P=require(game.ReplicatedStorage.Shared.SkillStatPreview)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b)return math.abs(a-b)<1e-8 end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 for _,level in ipairs({1,5,40,80})do
  local growth=G.new(level)
  local base=P.derived(class,growth,{})
  local d=P.derived(class,growth,{power=6,armor=4,health=20})
  check(near(d.physicalPower-base.physicalPower,6),'flat physical at every level')
  check(near(d.magicPower-base.magicPower,6),'flat magic at every level')
  check(d.armor-base.armor==4 and d.health-base.health==20,'other flat bonuses preserved')
 end
 local profile=assert(R.addHero(R.new(42),'hero',class,C))
 local stats=R.stats(profile,'hero',C)
 local derived=P.derived(class,profile.heroes.hero.progression,stats)
 local base=P.derived(class,profile.heroes.hero.progression,{})
 check(near(derived.physicalPower-base.physicalPower,stats.power),'actual starter aggregation adds points')
end
for _,def in pairs(C.items)do
 if def.slot and not def.deleted and (def.stats.power or 0)>0 then
  check(def.rarity=='Common'or def.rarity=='Uncommon','all usable attack gear uses flat contract')
  check(near(E.stats(def,{enhancementLevel=9}).power,def.stats.power*1.27),'enhancement increases flat base by 27 percent')
 end
end
for _,id in ipairs(C.deletedEquipment)do check(next(E.stats(C.items[id],{enhancementLevel=9}))==nil,'deleted gear adds no combat effects')end
print('Flat equipment power: '..n..' checks passed')

end
local S=game.ReplicatedStorage.Shared
local T=require(S.InventoryText);local A=require(S.AdventureText);local C=require(S.CombatStatText)
assert(string.format(T.ShopGearStats,'Knight','Uncommon',5,4,'','',''):find('Attack +4.0 pts',1,true))
assert(A.Power=='Attack bonus (pts)')
assert(string.format(C.AttackBonus,4):find('+4.0 pts',1,true))
print('Equipment units: 3 checks passed')
