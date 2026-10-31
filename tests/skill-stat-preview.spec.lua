-- User-visible estimates, allocation isolation and current hybrid tradeoffs.
if game then return {} end
local G=dofile('src/shared/HeroProgression.luau')
local K=dofile('src/shared/K0Config.luau')
local A=dofile('src/shared/AdvancedSkills.luau')
local P=dofile('src/shared/SkillStatPreview.luau')
local n=0
local function check(v,label)n=n+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
local mage=G.new(1)
eq(P.value('mage',1,mage).damage,140,'Mana Bolt now rewards spending 15 MP with 140 damage')
eq(P.value('mage',2,mage).damage,119,'Water Ball gains damage without losing its lower mana cost')
eq(P.value('mage',3,mage).damage,98,'Gravity retains area utility with stronger damage')
eq(K.Skills.mage[2].manaCost,12,'Water Ball retains its mana cost')
eq(P.value('mage',32,mage).damage,0,'Arcane Ward stays a non-damaging barrier')
eq(A.common.mage[1].damage,1,'shared catalog load never compounds the spell bonus')
local g=G.new(10)
eq(P.value('knight',1,g).damage,102,'ordinary Shield Bash estimate')
local draft=G.copy(g);draft.stats.STR=4
eq(P.value('knight',1,draft).damage,108,'STR draft changes actual skill estimate')
eq(g.stats.STR,0,'preview leaves saved allocation intact')
draft.mastery[1]=1
eq(P.value('knight',1,draft).damage,113,'mastery included in estimate')
eq(K.Skills.knight[1].damage,.8,'preview never edits the skill catalog')
eq(P.value('knight',1,g,{power=7}).damage,109,'equipment precision is kept until final hit')
eq(P.value('knight',1,G.new(2),{power=5}).damage,87,'rounding power first would incorrectly predict 86')
check(P.effectText('knight',1,g,nil,draft):find('102 %-> 113 %(%+11%)'),'visible before/after delta')
check(P.effectText('knight',1,g,nil,g):find('unchanged',1,true),'unrelated allocation is explicit')
eq(#P.equipped(G.new(1),'knight'),3,'three starter slots')
eq(#P.equipped(G.new(80),'knight'),3,'empty slots and locked ultimate not shown')
local provoke=P.value('knight',3,g)
eq(provoke.damage,0,'utility skill never advertises fake damage')
check(P.effectText('knight',3,g):find('4.0s',1,true),'taunt duration shown')
local rapid=P.value('elf',2,g)
eq(rapid.hits,3,'rapid fire hit count')
eq(rapid.totalDamage,rapid.damage*3,'total sums individually rounded server hits')
local ward=G.new(20)
local baseWard=P.value('mage',32,ward,{health=30})
local vit=G.copy(ward);vit.stats.VIT=4
check(P.value('mage',32,vit,{health=30}).barrier>baseWard.barrier,'VIT increases own barrier')
local int=G.copy(ward);int.stats.INT=4
eq(P.value('mage',32,int,{health=30}).barrier,baseWard.barrier,'INT does not falsely scale barrier')
vit.mastery[32]=1
check(P.value('mage',32,vit,{health=30}).barrier>P.value('mage',32,ward,{health=70}).barrier,'self barrier mastery included')
check(P.scalingText('mage',K.Skills.mage[32]):find('Max HP',1,true),'barrier source is HP')
for classId,paths in pairs(A.order) do
 for _,path in ipairs(paths) do
  local hero=G.new(80);hero.branch=path;hero.stage=4
  local ultimate=assert(A.ultimate(hero,classId))
  local rows=P.equipped(hero,classId)
  eq(rows[#rows].slot,0,'unlocked ultimate has dedicated preview')
  eq(rows[#rows].index,ultimate,'correct branch ultimate')
  for index,base in ipairs(K.Skills[classId]) do
   local value=P.value(classId,index,hero,{power=13,health=37})
   local more=G.copy(hero);more.stats[G.attackStat(classId,base.magic)]=4
   if base.damage>0 then
    check(P.value(classId,index,more,{power=13,health=37}).damage>value.damage,'correct damage stat raises per-hit damage')
    check(P.scalingText(classId,base):find(G.attackStat(classId,base.magic),1,true),'tooltip agrees with active damage stat')
   end
   eq(P.value(classId,index,more).skill.cooldown,base.cooldown,'stat allocation leaves cooldown intact')
   if base.partyShield then
    check(P.scalingText(classId,base):find("recipient's",1,true),'party shield labels recipient HP')
    check(P.effectText(classId,index,hero):find("each ally's",1,true),'caster HP not advertised for every ally')
   end
  end
 end
end
for _,level in ipairs({20,40,80}) do
 local budget=4*(level-1)
 for _,case in ipairs({{'elf','magic_archer','DEX','INT'},{'dwarf','gunner','STR','DEX'}}) do
  local classId,path,first,second=table.unpack(case)
  local branchSkill=A.branches[path].skills[1].index
  for _,ratio in ipairs({1,.5,0}) do
   local hero=G.new(level);hero.branch=path;hero.stage=level/20;hero.battleWins=12
   hero.stats[first]=math.floor(budget*ratio);hero.stats[second]=budget-hero.stats[first]
   check(G.validate(hero,classId),'same-budget comparison uses a legal profile')
   local remaining=G.points(hero);eq(remaining,0,'comparison spends identical total points')
   local physical=P.value(classId,1,hero,{power=10,health=30}).damage
   local branch=P.value(classId,branchSkill,hero,{power=10,health=30}).damage
   print(string.format('HYBRID %s Lv%d %s=%d %s=%d starter=%d branch=%d',path,level,first,hero.stats[first],second,hero.stats[second],physical,branch))
  end
 end
end
for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
 local saved=G.new(10);saved.stats.VIT=4;saved.stats[G.attackStat(classId,false)]=saved.stats[G.attackStat(classId,false)]+4
 local draft=G.copy(saved);draft.stats.STR=draft.stats.STR+4;draft.stats.INT=draft.stats.INT+4;draft.stats.VIT=draft.stats.VIT+4
 local gear={power=18,armor=6,health=40}
 local current=P.derived(classId,saved,gear);local after=P.derived(classId,draft,gear)
 for _,row in ipairs(P.breakdown(classId,saved,gear,draft)) do
  check(math.abs(row.total-(row.hero+row.gear))<.000001,'total decomposes into hero and equipped gear')
  eq(row.total,current[row.key],'current total follows server formula')
  eq(row.draft,after[row.key],'draft target follows same formula')
  if row.key=='physicalPower' or row.key=='magicPower' then check(math.abs(row.gear-row.hero*.18)<.000001,'power is percentage bonus, not flat points') end
  if row.key=='armor' then eq(row.gear,6,'armor is a flat gear bonus') end
  if row.key=='health' then eq(row.gear,40,'HP is a flat gear bonus') end
  if row.key=='mana' then eq(row.gear,0,'equipment never advertises unsupported MP bonus') end
 end
 eq(saved.stats.VIT,4,'breakdown does not allocate saved points')
 eq(gear.power,18,'breakdown does not mutate gear')
end
local C=dofile('src/shared/ItemCatalog.luau')
local items={
 {definitionId='knight_weapon_fine',location={kind='equipped',heroId='mine',slot='weapon'}},
 {definitionId='traveler_hood',location={kind='equipped',heroId='mine',slot='head'}},
 {definitionId='traveler_coat',location={kind='bag',heroId='mine'}},
 {definitionId='copper_ring',location={kind='equipped',heroId='other',slot='accessory1'}},
 {definitionId='amber_charm',location={kind='storage'}},
}
local sources=P.gearSources('mine',items,C)
eq(#sources,2,'only active hero equipped sources count')
eq(sources[1].definitionId,'knight_weapon_fine','sources follow stable slot order')
eq(sources[1].stats.power,10,'weapon source retains percent units')
eq(sources[2].stats.armor,2,'defense source retains flat units')
sources[1].stats.power=999;eq(C.items.knight_weapon_fine.stats.power,10,'source details cannot change item catalog')
print('Skill stat preview: '..n..' checks passed')
