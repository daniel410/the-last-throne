local C=dofile('src/shared/DeepwoodContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local expected={['DW-05:warlord']={4,7},['DW-07:king_shaman']={4,10},['DW-Q2:goblin_king']={6,9},['DW-Q3:king_ogre']={5,8},['DW-Q4:enraged_warlord']={6,12}}
local checks=0;local function check(v,m) checks=checks+1;assert(v,m) end
local encounters=0
for _,c in ipairs(C.chapters) do for _,g in ipairs(c.goals) do
 local key=c.id..':'..g.id;local counts=expected[key]
 if counts then
  encounters=encounters+1;local initial=0;for _,s in ipairs(g.enemies) do initial=initial+s.count end
  check(initial==counts[1],key..' guarded from the start')
  local total=initial;local last=1
  for _,wave in ipairs(g.bossEncounter.waves) do
   check(wave.health>0 and wave.health<last,'descending finite health gates');last=wave.health
   for _,spec in ipairs(wave.enemies) do
    check(spec.count>0 and spec.count%1==0 and spec.level<=g.enemies[1].level,'bounded lower-level support');total=total+spec.count
   end
  end
  check(total==counts[2] and total<=12,key..' finite full population')
  check(g.activity.waves==1,'boss appears with guards; not a separate cleanup wave')
  check(c.reward.xp==(c.id=='DW-05' and 247 or c.id=='DW-07' and 134 or 0),'fixed quest XP unchanged')
 else check(not g.bossEncounter,'ordinary field encounter unchanged') end
end end
check(encounters==5,'all five authored bosses covered')
local s=P.new();check(P.validate(s),'unchanged save format')
print('Deepwood bosses: '..checks..' checks passed')
