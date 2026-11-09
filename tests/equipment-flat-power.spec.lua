local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local E=dofile('src/shared/Enhancement.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local G=dofile('src/shared/HeroProgression.luau')
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
