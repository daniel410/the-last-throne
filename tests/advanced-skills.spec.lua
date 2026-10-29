if game then return {} end
local A=dofile('src/shared/AdvancedSkills.luau')
local G=dofile('src/shared/HeroProgression.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local K=dofile('src/shared/K0Config.luau')
local checks=0
local function check(v,label) checks=checks+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
local count=0
for classId,paths in pairs(A.order)do
 eq(#K.Skills[classId],29,'class catalog')
 for _,path in ipairs(paths)do
  local b=A.branches[path];eq(#b.skills,13,'12 actives + ultimate');local roots={0,0,0};local ids={}
  for _,d in ipairs(b.skills)do
   count=count+1;check(not ids[d.id],'unique branch id');ids[d.id]=true
   check(d.damage>0 and d.range>0 and d.cooldown>0 and d.maxTargets<=8 and d.pulses<=4,'bounded useful damage')
   eq(d.magic,classId=='mage' or path=='magic_archer','physical or magic')
   check(not d.magic or d.manaCost>0,'magic costs MP')
   if not d.ultimate then roots[d.root]=roots[d.root]+1 else eq(d.level,80,'ultimate80') end
  end
  for _,v in ipairs(roots)do eq(v,4,'four descendants per root')end
  local g=G.new(20)
  check(not A.unlocked(g,classId,b.skills[1].index),'level alone no skill')
  check(not G.apply(g,{action='Advance',branch=path,stage=1},classId),'trial required')
  for seq=1,12 do g=assert(G.apply(g,{action='AwardXP',stream='qa',sequence=seq,amount=1,rewardKind='Defeat'},classId))end
  local first=assert(G.apply(g,{action='Advance',branch=path,stage=1},classId))
  check(G.validate(first,classId),'valid advanced profile');eq(A.slotCount(first),4,'slot4 after completion')
  check(A.unlocked(first,classId,b.skills[1].index),'first path skill learned')
  check(not A.unlocked(first,classId,b.skills[2].index),'mid level remains locked')
  check(not G.apply(first,{action='Advance',branch=path,stage=2},classId),'level40 required')
  local other=paths[1]==path and paths[2] or paths[1]
  check(not G.apply(first,{action='Advance',branch=other,stage=2},classId),'no free path change')
  g=G.copy(first);g.level=80;g.xp=0
  for stage=2,4 do
   g=assert(G.apply(g,{action='Advance',branch=path,stage=stage},classId))
   check(A.unlocked(g,classId,b.skills[stage==2 and 5 or stage==3 and 9 or 13].index),'stage grants skill')
  end
  local learned=0;for i=1,29 do if A.unlocked(g,classId,i)then learned=learned+1 end end;eq(learned,16,'selected path16')
  eq(A.slotCount(g),5,'max5 slots')
  local advancedIndex=b.skills[1].index
  g=assert(G.apply(g,{action='SetSkillSlot',slot=5,skill=advancedIndex},classId));eq(g.skillSlots[5],advancedIndex,'path skill equips')
  g=assert(G.apply(g,{action='TrainSkill',skill=advancedIndex},classId));eq(g.mastery[advancedIndex],1,'path mastery persists')
  check(not G.apply(g,{action='SetSkillSlot',slot=1,skill=A.branches[other].skills[1].index},classId),'opposite path rejected')
  check(not G.validate(g,classId=='knight' and 'mage' or 'knight'),'cross-class branch rejected')
  local mana=G.derived(classId,g).mana
  check((classId=='mage' or path=='magic_archer') and mana>0 or mana==0,'MP eligibility')
 end
end
eq(count,104,'96 branch actives +8 ultimates')
local old=G.new();old.version=1;old.branch=nil;old.stage=nil;old.battleWins=nil;for i=4,29 do old.mastery[i]=nil end
local p=assert(R.addHero(R.new(42),'hero','mage',C));p.heroes.hero.progression=old
check(R.validate(p,C),'legacy basic profile accepted')
local upgraded=R.upgrade(p);eq(upgraded.heroes.hero.progression.version,2,'v1 to v2');eq(upgraded.heroes.hero.progression.mastery[29],0,'new slots initialized');eq(upgraded.heroes.hero.level,1,'level preserved')
local g=G.new(80);for seq=1,12 do g=assert(G.apply(g,{action='AwardXP',stream='qa',sequence=seq,amount=1,rewardKind='Defeat'},'mage'))end
for stage=1,4 do g=assert(G.apply(g,{action='Advance',branch='pyro',stage=stage},'mage'))end
for _,d in ipairs(A.branches.pyro.skills)do
 if d.element=='earth' then check(d.stage>=2 and d.level>=40,'no early earth')end
end
print('Advanced skills: '..checks..' checks passed')
