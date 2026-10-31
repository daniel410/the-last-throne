local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/DeepwoodContent.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local original,expanded=0,0
for _,chapter in ipairs(C.chapters)do for _,goal in ipairs(chapter.goals)do
 local groups={goal.enemies}
 for _,wave in ipairs(goal.bossEncounter and goal.bossEncounter.waves or {})do table.insert(groups,wave.enemies)end
 for _,specs in ipairs(groups)do
  local expectedCount,xp,gold=0,0,0
  for _,spec in ipairs(specs)do
   local boss=B.isBoss(spec.kind)
   expectedCount=expectedCount+spec.count*(boss and 1 or 3)
   xp=xp+(8+2*spec.level)*(boss and 5 or 1)*spec.count
   gold=gold+(3+math.floor(spec.level/2))*(boss and 10 or 1)*spec.count
   original=original+spec.count
  end
  local plan=B.expand(specs);expanded=expanded+#plan
  check(#plan==expectedCount,'density triples guards and preserves single bosses')
  local actualXP,actualGold=0,0
  for _,spec in ipairs(plan)do
   local x,g=B.rewards(spec);actualXP=actualXP+x;actualGold=actualGold+g
   check(x>=1 and g>=1 and x%1==0 and g%1==0,'integer positive split rewards')
   for party=1,4 do
    local hp,damage=B.stats(spec.kind,spec.level,party)
    local boss=B.isBoss(spec.kind)
    local previousHP=(boss and 1000+spec.level*100 or 100+spec.level*25)*(boss and ({1,1.7,2.3,2.8})[party]or 1)
    local previousDamage=boss and 28+spec.level*2 or 10+spec.level
    check(hp>previousHP and damage>previousDamage,'all existing levels and party sizes become tougher')
   end
  end
  check(actualXP==xp and actualGold==gold,'whole group keeps original XP and Gold budget')
 end
end end
check(#B.expand({{kind='Warlord',level=10,count=1}})==1,'boss never multiplied')
local hp,damage=B.stats('Goblin',5,1);check(hp==338 and damage==23,'early guard tuning')
print('Deepwood encounter balance: '..n..' checks passed; authored enemies '..original..' -> '..expanded)
