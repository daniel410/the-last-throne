-- Narrative changes must preserve progression contracts and existing saved answers.
local sourceDofile=dofile
dofile=function(path)
 if path=='src/shared/CampaignStoryBeats.luau'then return {install=function()end}end
 return sourceDofile(path)
end
local baseline=dofile('src/shared/CampaignContent.luau')
dofile=sourceDofile
local C=dofile('src/shared/CampaignContent.luau')
local B=dofile('src/shared/CampaignStoryBeats.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local S=dofile('src/shared/CampaignSceneState.luau')
local Circuit=dofile('src/shared/CampaignCircuit.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end;return true
end
local changed=0
for _,c in ipairs(C.chapters)do
 local old=baseline.byId[c.id]
 check(c.number==old.number and c.zone==old.zone,'chapter order and zone stay stable')
 check(equal(c.reward,old.reward),'original quest rewards unchanged')
 check(#c.goals==#old.goals,'no extra required goals')
 for i,g in ipairs(c.goals)do
  local o=old.goals[i]
  check(g.id==o.id and equal(g.requires,o.requires)and equal(g.expansionRequires,o.expansionRequires),'saved goal IDs and prerequisites unchanged')
  check(equal(g.position,o.position)and equal(g.enemies,o.enemies),'original placements and enemy budgets preserved')
  check(g.optional==o.optional and g.expansion==o.expansion,'optional and historical behavior stable')
  for n,step in ipairs(g.activity and g.activity.steps or {})do
   local before=o.activity.steps[n]
   check(step.id==before.id and equal(step.position,before.position),'saved substeps and checkpoints unchanged')
   check(equal(step.choices,before.choices),'persistent answer IDs and server solution unchanged by story beats')
  end
  if g.text~=o.text then changed=changed+1 end
 end
end
check(changed>=20,'character and evidence outcomes integrated across the campaign')
local n=0;for _ in pairs(B.beats)do n=n+1 end;check(n>=20,'authored incident coverage')
local c=C.byId['EC-05'];local g=c.expansionGoals[2]
local first=Circuit.display(g.activity.steps[1]);local second=Circuit.display(g.activity.steps[2])
check(first[1].id=='inlet'and second[2].id=='return','physical/display order varies without changing stored solution IDs')
check(g.activity.steps[2].choices[1].id=='return','presentation order never mutates canonical data')
local inherited={flags={},clears={['GW-06']=true}}
check(S.requires(inherited,'GW-06:rear_guard'),'old completed heroes retain earned scout payoff')
check(not S.requires({flags={},clears={}},'GW-06:rear_guard'),'unrescued scouts cannot appear as an earned payoff')
check(not S.requires({flags={['GW-06:rear_guard']=true},clears={}},'GW-06:rear_guard|EC-07:courier'),'multiple requirements need all earned rights')
check(S.requires(nil,nil),'ungated scenery does not invent a progress requirement')
-- A real saved circuit continues after a previously completed choice; no replay requirement.
local s=P.new()
local function applyGoal(state,chapter,goal)
 for _,step in ipairs(goal.activity and goal.activity.steps or {false})do state=assert(P.apply(state,chapter.id,goal.id,step and step.choices and step.choices[1].id or goal.choice and 'shared',step and step.id or nil))end
 return state
end
for i=1,c.number-1 do for _,goal in ipairs(C.mainChapters[i].coreGoals)do if not goal.optional then s=applyGoal(s,C.mainChapters[i],goal)end end end
s=assert(P.enableExpansion(s))
for _,goal in ipairs(c.goals)do if goal==g then break end;if P.required(s,goal)then s=applyGoal(s,c,goal)end end
s=assert(P.apply(s,c.id,g.id,'inlet','step1'))
local persisted=P.copy(s);check(P.validate(persisted),'preexisting partial circuit journal remains valid')
s=assert(P.apply(persisted,c.id,g.id,'return','step2'));s=assert(P.apply(s,c.id,g.id,'protect','step3'))
check(s.flags['EC-05:exp_2']and P.validate(s),'existing answer IDs resume to completion')
print('STORY_FUN '..checks..' checks passed; progression/answers unchanged, earned callbacks and partial-save resume')
