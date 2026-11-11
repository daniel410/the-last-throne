local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local G=dofile('src/shared/HeroProgression.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local I=dofile('src/shared/EquipmentImpact.luau')
local E=dofile('src/shared/Enhancement.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b,m)check(math.abs(a-b)<1e-8,m)end
check(C.items.copper_ring.rarity=='Common'and C.items.copper_ring.level==1,'grade/level preserved')
check(C.items.copper_ring.stats.dexterity==3 and C.items.copper_ring.stats.power==nil,'ring has exactly DEX instead of attack')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local p=assert(R.addHero(R.new(42),'h',class,C));local ring=R.equipped(p,'h','accessory1');local before=R.copy(p)
 local equipped=R.stats(p,'h',C);local d=P.derived(class,p.heroes.h.progression,equipped);local base=G.derived(class,p.heroes.h.progression)
 near(d.totalStats.DEX,base.totalStats.DEX+3,'total DEX includes ring')
 near(d.attackRate,1.015,'ring raises basic attack rate by1.5 percent of base')
 near(d.moveRate,1.003,'ring raises movement by0.3 percent of base')
 near(d.physicalPower,base.physicalPower+5,'ring no longer supplies attack')
 local sp,kp=G.points(p.heroes.h.progression);check(sp==0 and kp==0 and G.validate(p.heroes.h.progression,class),'gear never spends or creates allocation points')
 check(p.heroes.h.progression.stats.DEX==0 and p.revision==before.revision,'derived calculations never save invested DEX')
 local bag=assert(R.apply(p,{action='Unequip',requestId='off',heroId='h',revision=p.revision,instanceId=ring.instanceId,itemVersion=ring.version},{safe=true},C))
 local unequipped=P.derived(class,bag.heroes.h.progression,R.stats(bag,'h',C))
 near(unequipped.attackRate,1,'bag ring has no speed bonus');near(unequipped.totalStats.DEX,base.totalStats.DEX,'bag ring has no DEX bonus')
 local list={};for _,item in pairs(bag.items)do table.insert(list,item)end
 local rows=assert(I.compare(bag.heroes.h,list,bag.items[ring.instanceId],nil,C))
 check(#rows==8 and rows[6].key=='dexterity','ring preview shows DEX and both speed changes')
 near(rows[1].delta,0,'ring preview adds no direct physical attack');near(rows[6].delta,3,'preview DEX matches actual')
 near(rows[7].delta,.015,'preview attack speed matches actual');near(rows[8].delta,.003,'preview movement matches actual')
 check(I.text(rows):find('Dexterity',1,true)and I.summary(rows):find('DEX +3',1,true),'ring changes are visible in bag/shop text')
 p.wallet.gold=100;assert(F.grant(p,R,C,'h','enhancement_gem',2,'gems'))
 local enhanced=assert(R.shop(p,{action='Enhance',store='blacksmith',requestId='dex-enhance',heroId='h',revision=p.revision,instanceId=ring.instanceId,itemVersion=ring.version,rulesVersion=E.version,expectedLevel=0},{atLobby=true,enhancementRoll=0},C))
 near(R.stats(enhanced,'h',C).dexterity,3.09,'authoritative DEX enhancement uses existing3 percent rate')
 near(enhanced.wallet.gold,50,'DEX enhancement retains50 Gold cost')
 check(R.validate(enhanced,C),'existing enhanced ring remains valid')
 near(E.stats(C.items.copper_ring,{enhancementLevel=9}).dexterity,3.81,'existing +9 follows new DEX definition')
 for _,investment in ipairs({199,200,299,300})do
  local g=G.new(80);g.stats.DEX=investment;local derived=G.derived(class,g,{dexterity=3.81})
  near(derived.attackRate,1+math.min(1,(investment+3.81)*.005),'DEX gear obeys attack speed cap')
  near(derived.moveRate,1+math.min(.3,(investment+3.81)*.001),'DEX gear obeys movement cap')
  check(G.validate(g,class),'gear never violates316-point budget')
 end
end
for tier,value in pairs({traveler=2,tempered=4,veteran=10,sentinel=20})do
 check(C.items[C.equipmentFamilies.piece(tier,'hands')].stats.power==value,'latest fixed glove value '..tier)
 check(C.items[C.equipmentFamilies.piece(tier,'feet')].stats.armor==value,'latest fixed boot value '..tier)
end
print('Copper DEX and secondary gear: '..n..' checks passed')
