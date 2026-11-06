-- Read-only defense sensitivity probe; no assets, profiles or game balance writes.
-- Source formulas: HeroProgression, Enhancement, CombatService.applyPlayerHit.
local G=dofile('src/shared/HeroProgression.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/Enhancement.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local function out(...)local v={};for i=1,select('#',...)do v[i]=tostring(select(i,...))end;print(table.concat(v,'\t'))end
local function armor(class,loadout,n)
 local ids={}
 if loadout=='gold' then
  ids={'veteran_hood','traveler_coat','traveler_boots','amber_charm'}
  if class=='knight' then table.insert(ids,'knight_shield_fine')end
 elseif loadout=='owned_retired_epic' then
  ids={'sentinel_helm_epic','sentinel_mail_epic','sentinel_gauntlets_epic','sentinel_boots_epic','guardian_charm_epic','storm_pendant_epic'}
  if class=='knight' then table.insert(ids,'sentinel_shield_epic')end
 end
 local a,h=0,0
 for _,id in ipairs(ids)do local s=E.stats(assert(C.items[id]),{enhancementLevel=n});a=a+(s.armor or 0);h=h+(s.health or 0)end
 return a,h
end
local function hit(raw,a,guard)
 return math.max(1,math.max(1,math.floor(raw*guard+.5))-a)
end
-- Alternatives are sensitivity examples, NOT approved balance or runtime paths.
local function armorFirst(raw,a,guard)return math.max(1,math.floor(math.max(1,raw-a)*guard+.5))end
out('scope','current rules 8; authored single-hit arithmetic; no actual encounters, shields, parries, hit frequency or potion consumption')
out('hero','class','level','VIT spent','loadout','enhancement','HP','equipment Armor','VIT Armor','total Armor','raw29 unblocked','raw29 blocked','raw95 unblocked','raw95 blocked','raw428 unblocked','raw428 blocked')
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 for _,level in ipairs({10,22,40,60,80})do
  for _,vit in ipairs({0,math.floor((level-1)),4*(level-1)})do
   for _,loadout in ipairs({'none','gold','owned_retired_epic'})do
    for _,n in ipairs({0,9})do if loadout~='none' or n==0 then
     local g=G.new(level);g.stats.VIT=vit;g.stats[class=='mage' and 'INT' or 'STR']=4*(level-1)-vit
     assert(G.validate(g,class));local d=G.derived(class,g)
     local ea,eh=armor(class,loadout,n);local a=ea+d.armor
     out('hero',class,level,vit,loadout,n,d.health+eh,ea,d.armor,a,hit(29,a,1),hit(29,a,.2),hit(95,a,1),hit(95,a,.2),hit(428,a,1),hit(428,a,.2))
    end end
   end
  end
 end
end
out('comparison','raw','Armor','current unblocked','current blocked','armor-first blocked','20-percent equipment efficacy then armor-first blocked')
for _,raw in ipairs({18,24,29,33,95,103,428})do
 for _,a in ipairs({10,12.7,37.195887,48.216947})do
  out('comparison',raw,a,hit(raw,a,1),hit(raw,a,.2),armorFirst(raw,a,.2),armorFirst(raw,a*.2,.2))
 end
end
out('epic1_sample','kind','level','raw damage')
for _,unit in ipairs({{'Goblin',9},{'Warlord',10},{'KingShaman',12}})do local _,damage=B.stats(unit[1],unit[2],1,'Easy',8,1);out('epic1_sample',unit[1],unit[2],damage)end
out('stat_isolation','class','stat','points','Armor before','Armor after')
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 for _,stat in ipairs({'STR','DEX','INT','VIT'})do
  local g=G.new(80);local before=G.derived(class,g).armor;g.stats[stat]=316
  assert(G.validate(g,class));local after=G.derived(class,g).armor
  assert(after==(stat=='VIT' and 79 or before))
  out('stat_isolation',class,stat,316,before,after)
 end
end
