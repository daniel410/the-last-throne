local C=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local G=dofile('src/shared/CampaignStoryGuide.luau')
local State=dofile('src/shared/CampaignSceneState.luau')
local Completion=dofile('src/shared/StoryCompletion.luau')
local Impact=dofile('src/shared/EquipmentImpact.luau')
local Metrics=dofile('src/shared/StoryPlaytestMetrics.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end;return true
end
check(#G.discoveries(P.new())==0,'new heroes cannot read undiscovered people or future plot')
local partial=P.new();partial.flags['GW-02:exp_1']=true
local entries=G.discoveries(partial,'people')
check(#entries==1 and entries[1].id=='finn'and #entries[1].lines==1,'partial discoveries do not reveal later growth or final allies')
entries[1].lines[1]='changed locally'
check(G.discoveries(partial,'people')[1].lines[1]~='changed locally','UI cannot mutate canonical discovery prose')
partial.expansionWaivers={['GW-02:exp_1']=true}
check(#G.discoveries(partial,'people')==0,'migration waivers are not recorded as witnessed incidents')
local old=P.new();old.clears['GW-06']=true
local historical=G.discoveries(old,'people')
check(#historical==1 and #historical[1].lines==1 and not historical[1].lines[1]:find('Sovereign',1,true),'old rescues do not claim newly added boss victories')
local selene=P.new();selene.seleneUnlocked=true
local original=P.copy(selene)
local people=G.discoveries(selene,'people')
check(#people==1 and people[1].id=='selene'and #people[1].lines==2,'unlocked Selene has optional motivation dialogue without support purchase')
check(equal(original,selene),'reading dialogue does not consume trial, credit, currency, or progress')
check(not G.inCombat({encounters={one={remaining=0,pillars=0}}}),'completed encounter does not suppress safe dialogue')
check(G.inCombat({encounters={one={remaining=1}}}),'active enemies suppress informational overlay')
check(G.inCombat({encounters={one={pillars=1}}}),'active encounter devices preserve visibility')
check(not G.inCombat({encounters={one={active=false,remaining=3}}}),'leaving an encounter restores safe dialogue even while enemies remain')
check(not State.requires(P.new(),'FV-07'),'region result cannot be shown for an unfinished final incident')
check(State.requires({clears={['FV-07']=true}},'FV-07'),'actual saved region clear unlocks result scene')
local s=assert(P.enableExpansion(P.new()))
local transitions=0
for _,c in ipairs(C.mainChapters)do
 check(not G.completedRegion(s,c),'no success summary before confirmed clear')
 for _,goal in ipairs(c.goals)do if P.required(s,goal)then
  for _,step in ipairs(goal.activity and goal.activity.steps or {false})do
   local before=P.copy(s)
   G.context(s,c);G.recap(s,c);G.discoveries(s);G.lesson(goal)
   check(equal(before,s),'presentation does not alter live partial journal')
   local answer=step and step.choices and (step.solution or step.choices[1].id)or goal.choice and 'shared'
   s=assert(P.apply(s,c.id,goal.id,answer,step and step.id or nil))
   transitions=transitions+1
   check(P.validate(s),'saved journal remains valid at every new/old goal and substep')
  end
 end end
 local saved=P.copy(s)
 local summary=Completion.project({heroId='h',journal=s,completion={id=c.id}})
 check(summary~=nil,'every main story still produces a completion summary')
 check((summary.nextReason~=nil)==(c.number%7==0),'only region endings receive cross-region story handoffs')
 if c.number%7==0 then
  check(G.completedRegion(s,c)~=nil,'confirmed final story projects saved region outcome')
  check(summary.nextReason:find(G.regions[c.epic].next,1,true),'next reason follows the approved epic sequence')
 end
 check(equal(saved,s),'recaps and completion never award or mutate a saved clear')
end
check(s.main==35 and #G.discoveries(s,'people')>=5,'all five epics retain solo sequential completion and earned people')
check(#G.discoveries(P.new())==0,'switching to another hero cannot inherit discoveries')
check(G.recap(s,C.byId['GW-06'])==C.byId['GW-06'].quest.outcome,'replay context uses its actual expedition rather than the latest epic')
local lesson=G.lesson(C.byId['GW-06'].goals[#C.byId['GW-06'].goals])
check(#lesson>0 and #lesson<=4,'combat learning is bounded and derived from actual encounter patterns')
check(Impact.meaning({{key='health',delta=30}}):find('not restored',1,true),'equipment meaning never promises free healing')
check(Impact.meaning({{key='armor',delta=-3}}):find('less',1,true),'downgrade is described as a loss')
check(Impact.meaning({{key='mana',delta=0}}):find('No change',1,true),'no MP is invented for an unchanged comparison')
local m=Metrics.new()
m.sample(1,{distance=10,goal='g',progress=0})
m.sample(1,{distance=10,goal='g',progress=0})
m.sample(1,{distance=1,goal='g',progress=1,combat=true,reading=true})
m.sample(1,{distance=0,goal='g',progress=1,reading=true})
m.sample(1,{distance=5000,goal='g',progress=1,dead=true})
m.sample(1,{distance=0,goal='g',progress=1,dead=true})
local stats=m.snapshot()
check(stats.seconds.combat==1 and stats.seconds.reading==1,'combat/reading observation categories never double count')
check(stats.deaths==1 and stats.distance==21,'death frames and teleport corrections are excluded from distance')
check(stats.confirmedChanges==1 and stats.unchangedTravel==10,'confirmed activity and unchanged-route proxies are distinct')
stats.seconds.combat=999;check(m.snapshot().seconds.combat==1,'QA snapshots cannot mutate local measurement')
m.sample(0/0,{});m.sample(4,{});check(m.snapshot().samples==6,'invalid or paused samples do not inflate playtime')
print('STORY_RPG_GUIDE '..checks..' checks passed; '..transitions..' saved transitions, discoveries/waivers/solo/handoffs/combat/metrics')
