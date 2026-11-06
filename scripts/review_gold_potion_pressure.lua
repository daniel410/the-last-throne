-- Read-only authored balance probe. Not a combat/clear-time simulation.
-- Run from the repository root: lua scripts/review_gold_potion_pressure.lua
local G=dofile('src/shared/HeroProgression.luau')
local I=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/Enhancement.luau')
local C=dofile('src/shared/CampaignContent.luau')
local D=dofile('src/shared/Difficulty.luau')
local S=dofile('src/shared/EncounterSummary.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Shop=dofile('src/shared/EconomyCatalog.luau')
local function out(...)local v={};for k=1,select('#',...)do v[k]=tostring(select(k,...))end;print(table.concat(v,'\t'))end
out('scope','static authored values; solo Easy; no measured hit rate, potion use or wallet data')
out('rules','3 = published 0.75.5 default; 8 = current new-run default; old runs stay pinned')
out('hero','class','level','VIT spent','loadout','HP','armor','HP regen/s','unblocked damage at raw 25','blocked damage at raw 25')
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 for _,level in ipairs({1,22,80})do
  local vit=level==1 and 0 or level==22 and 20 or 80
  for _,loadout in ipairs({'starter_equipped','free_kit_equipped','gold_max','owned_retired_epic_plus9'})do
   if level>=10 or loadout~='owned_retired_epic_plus9' then
    local g=G.new(level);g.stats.VIT=vit
    g.stats[class=='mage' and 'INT' or 'STR']=4*(level-1)-vit
    assert(G.validate(g,class))
    local ids={}
    if loadout=='free_kit_equipped' or loadout=='gold_max' then
     ids={'traveler_coat','traveler_boots','amber_charm',level>=5 and 'veteran_hood' or 'traveler_hood'}
     if class=='knight' and loadout=='gold_max' then table.insert(ids,'knight_shield_fine')end
    elseif loadout=='owned_retired_epic_plus9' then
     ids={'sentinel_helm_epic','sentinel_mail_epic','sentinel_gauntlets_epic','sentinel_boots_epic','guardian_charm_epic','storm_pendant_epic'}
     if class=='knight' then table.insert(ids,'sentinel_shield_epic')end
    end
    local d=G.derived(class,g);local hp,armor=d.health,d.armor
    for _,id in ipairs(ids)do
     local stats=E.stats(assert(I.items[id]),{enhancementLevel=loadout=='owned_retired_epic_plus9' and 9 or 0})
     hp=hp+(stats.health or 0);armor=armor+(stats.armor or 0)
    end
    out('hero',class,level,vit,loadout,hp,armor,hp*.001,math.max(1,25-armor),math.max(1,math.floor(25*.2+.5)-armor))
   end
  end
 end
end
out('starter','class','HP bottles including pending','nominal HP including pending','HP potion replacement Gold')
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 local p=assert(R.addHero(R.new(1),'probe',class,I));local count,hp,gold=0,0,0
 for _,item in pairs(p.items)do
  local def=I.items[item.definitionId]
  if def.restore=='health' then count=count+item.quantity;hp=hp+item.quantity*def.amount;gold=gold+item.quantity*Shop.offer(def.id).price end
 end
 out('starter',class,count,hp,gold)
end
out('mission','id','epic','rule','normal damage min','normal damage max','boss damage min','boss damage max','kill Gold','first fixed Gold','repeat fixed Gold','count')
local totals={}
for _,c in ipairs(C.chapters)do
 if not c.side then
  local epic=c.epic or 1
  local s=S.mission(c,'Easy',1,8);local old=S.mission(c,'Easy',1,3)
  for _,v in ipairs({{3,old},{8,s}})do
   local r=v[2];out('mission',c.id,epic,v[1],r.normal and r.normal.damageMin or 0,r.normal and r.normal.damageMax or 0,r.boss and r.boss.damageMin or 0,r.boss and r.boss.damageMax or 0,r.gold,c.reward.coins,D.completion(c,'Easy',8).gold,r.count)
  end
  local t=totals[epic]or {fixed=0,kill=0,repeatGold=0};totals[epic]=t
  t.fixed=t.fixed+c.reward.coins;t.kill=t.kill+s.gold;t.repeatGold=t.repeatGold+D.completion(c,'Easy',8).gold
 end
end
out('epic','index','first fixed Gold','finite kill Gold','first total Gold','repeat total Gold','XL HP potions at 200 Gold')
for epic,t in ipairs(totals)do out('epic',epic,t.fixed,t.kill,t.fixed+t.kill,t.repeatGold+t.kill,(t.fixed+t.kill)/200)end
out('sample','kind','authored level','epic','rule','raw damage','HP')
for _,row in ipairs({{'Goblin',9,1},{'Warlord',10,1},{'Veyr',40,5}})do
 for _,version in ipairs({3,8})do local hp,damage=B.stats(row[1],row[2],1,'Easy',version,row[3]);out('sample',row[1],row[2],row[3],version,damage,hp)end
end
out('enhancement','all current steps Gold',E.cost(I.items.traveler_coat,9).gold)
