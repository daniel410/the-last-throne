local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau')
local D=dofile('src/shared/Difficulty.luau')
local n,goals,added=0,0,0
local function check(v,m)n=n+1;assert(v,m)end
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.goals)do
 local authored={};for _,s in ipairs(g.enemies)do authored[#authored+1]=s end
 for _,stage in ipairs(g.bossEncounter and g.bossEncounter.waves or {})do for _,s in ipairs(stage.enemies)do authored[#authored+1]=s end end
 local hasBoss,hasGuards=false,false
 for _,s in ipairs(authored)do if B.isBoss(s.kind)then hasBoss=true else hasGuards=true end end
 if hasBoss then goals=goals+1;if not hasGuards then added=added+1 end end
 for party=1,4 do
  local original=B.expand(authored,party,c.epic);local oldOrder={};local oldBoss
  for _,s in ipairs(original)do if B.isBoss(s.kind)then oldBoss=s else oldOrder[#oldOrder+1]=s end end
  if oldBoss then oldOrder[#oldOrder+1]=oldBoss end
  local plan=B.encounterWaves(c,g,party);local indices={};local units={};local bossCount=0
  for index,wave in ipairs(plan)do
   check(#wave<=B.packCapacity(c,g,party),'wave stays within party cap')
   for _,s in ipairs(wave)do
    check(not indices[s.killIndex],'kill receipt index unique');indices[s.killIndex]=s;units[#units+1]=s
    if B.isBoss(s.kind)then
     bossCount=bossCount+1;check(index==#plan and #wave>1,'one boss joins guards only in final wave')
    elseif hasBoss and index==#plan then check(not B.isBoss(s.kind),'final escorts are normal enemies')end
   end
  end
  check(bossCount==(hasBoss and 1 or 0),'boss never duplicated')
  for index,s in ipairs(oldOrder)do
   local preserved=indices[index]
   check(preserved and (c.id=='DW-01' or preserved.kind==s.kind) and preserved.level==s.level,'existing receipt still maps to same enemy kind/level')
   for _,mode in ipairs(D.order)do
    for version=1,D.version do
     local x,y=B.rewards(s,mode,version);local xp,gold=B.rewards(preserved,mode,version)
     check(x==xp and y==gold,'existing receipt reward amount unchanged')
    end
   end
  end
  if hasBoss and not hasGuards then
   check(#units==1+B.population(party),'formerly solo boss gains one finite scaled guard cohort')
   local final=plan[#plan];check(#final==math.min(#units,B.packCapacity(c,g,party)),'final pack fills available capacity')
   local guard=final[2];check(guard.level==math.max(1,oldBoss.level-1),'new guard level follows boss')
   for _,mode in ipairs(D.order)do
    local xp,gold=0,0
    for _,s in ipairs(units)do if not B.isBoss(s.kind)then local x,y=B.rewards(s,mode,D.version);xp=xp+x;gold=gold+y end end
    local x,y=B.rewards({kind=guard.kind,level=guard.level},mode,D.version)
    check(xp==x and gold==y,'new cohort reward budget independent of party density')
   end
  else check(#units==#original,'existing roster and all normal encounters retain total population')end
 end
end end
check(goals==22 and added==14,'all twenty-two bosses covered, fourteen formerly solo')
print(string.format('BOSS_FINAL_ESCORT %d checks PASS; %d boss goals / %d new escort cohorts; 1-4 players and existing receipt rewards preserved',n,goals,added))
