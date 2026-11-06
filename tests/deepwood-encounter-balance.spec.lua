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
   expectedCount=expectedCount+spec.count*(boss and 1 or 6)
   xp=xp+(8+2*spec.level)*(boss and 5 or 1)*spec.count
   gold=gold+(3+math.floor(spec.level/2))*(boss and 10 or 1)*spec.count
   original=original+spec.count
  end
  local plan=B.expand(specs);expanded=expanded+#plan
  check(#plan==expectedCount,'normal population doubles the previous three-copy trial; bosses stay unique')
  local actualXP,actualGold=0,0
  for _,spec in ipairs(plan)do
   local x,g=B.rewards(spec);actualXP=actualXP+x;actualGold=actualGold+g
   check(x>=1 and g>=0 and x%1==0 and g%1==0,'integer XP and nonnegative Gold preserve the finite reward budget')
   for party=1,4 do
    local hp,damage=B.stats(spec.kind,spec.level,party)
    local boss=B.isBoss(spec.kind)
    local previousHP=(boss and 1000+spec.level*100 or 100+spec.level*25)*(boss and ({1,1.7,2.3,2.8})[party]or 1)
    local previousDamage=boss and 28+spec.level*2 or 10+spec.level
    check(hp>previousHP and damage>previousDamage,'all existing levels and party sizes become tougher')
   end
  end
  check(actualXP==xp and actualGold==gold,'whole group keeps original XP and Gold budget')
  local waves=B.waves(plan,B.packSize(chapter,goal),specs~=goal.enemies and goal.bossEncounter and 1 or nil)
  local seen,count={},0
  for _,batch in ipairs(waves) do
   check(#batch>=1 and #batch<=B.packSize(chapter,goal),'every finite pack respects its story cap')
   for _,unit in ipairs(batch) do check(not seen[unit],'no duplicated unit across packs');seen[unit]=true;count=count+1 end
  end
  check(count==#plan,'all planned enemies appear exactly once across the finite waves')
 end
end end
check(original==82 and expanded==467,'231 normal enemies become 462; five unique bosses unchanged')
check(#B.expand({{kind='Warlord',level=10,count=1}})==1,'boss never multiplied')
local hp,damage=B.stats('Goblin',5,1);check(hp==371 and damage==34,'early guard tuning')
for party,multiplier in ipairs({1,1.5,2,2.5}) do
 local hp,damage=B.stats('Goblin',5,party)
 check(hp==math.floor(225*1.5*1.1*multiplier+.5) and damage==math.floor(28.125*1.2*(1+.1*(party-1))+.5),'normal enemy scales health and damage with party size')
 local bossHP,bossDamage=B.stats('Warlord',10,party)
 check(bossHP==math.floor(2000*1.35*1.1*({1,1.7,2.3,2.8})[party]+.5) and bossDamage==math.floor(75*1.2*(1+.1*(party-1))+.5),'boss health and damage scale with party size')
end
local early=C.byId['DW-01'];check(B.packSize(early,early.goals[1])==2,'first encounter teaches two at once')
for _,row in ipairs({{'DW-04','courtyard',4},{'DW-04','west_link',5},{'DW-04','east_link',6},{'DW-07','corridor',7},{'DW-07','outer_west',8},{'DW-07','outer_east',9}}) do local c=C.byId[row[1]];local g;for _,x in ipairs(c.goals) do if x.id==row[2] then g=x end end;check(#B.waves(B.expand(g.enemies),B.packSize(c,g))[1]==row[3],'story progressively introduces the requested group size') end
print('Deepwood encounter balance: '..n..' checks passed; authored enemies '..original..' -> '..expanded)
