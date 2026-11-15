-- Read-only production-reducer exercise: 35 quests x four interleaved modes.
local function module(name)return dofile('src/shared/'..name..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local C,P,A,D,G,I=module('CampaignContent'),module('DeepwoodProgress'),module('AdventureRules'),module('Difficulty'),module('HeroProgression'),module('ItemCatalog')
local order={'Hard','Insane','Hell','Easy'}
local branch={Hard='shared',Insane='sanctuary',Hell='shared',Easy='sanctuary'}
local totals={checks=0,completed=0,events=0,begins=0,kills=0,duplicateKills=0,stale=0,reconnects=0}
local done={Easy=0,Hard=0,Insane=0,Hell=0}
local sequence=0
local function check(value,message)totals.checks=totals.checks+1;assert(value,message)end
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for key,value in pairs(a)do if not same(value,b[key])then return false end end
 for key in pairs(b)do if a[key]==nil then return false end end
 return true
end
local profile=assert(R.addHero(R.new(1094140),'hero','knight',I))
profile.heroes.hero.level=99;profile.heroes.hero.progression=G.new(99)
local function hero()return profile.heroes.hero end
local function choices(mode,goal,step)
 if step and step.choices then return step.solution or step.choices[({Easy=true,Insane=true})[mode]and #step.choices or 1].id end
 return goal.choice and branch[mode]or nil
end
local function otherModes(mode)
 local result={}
 for _,other in ipairs(order)do if other~=mode then
  result[other]={journal=R.copy(hero().expeditions.modeJournals[other]),claims=R.copy(hero().expeditions.modeRewardClaims[other])}
 end end
 return result
end
local function unchangedOther(snapshot,message)
 for other,old in pairs(snapshot)do
  check(same(old.journal,hero().expeditions.modeJournals[other]),message..': untouched journal '..other)
  check(same(old.claims,hero().expeditions.modeRewardClaims[other]),message..': untouched claims '..other)
 end
end
local function invariants(message)
 local h=hero();local e=h.expeditions
 check(R.validate(profile,I),message..': profile valid')
 for _,mode in ipairs(order)do
  local journal=e.modeJournals[mode]
  check(journal.main==done[mode],message..': exact own main '..mode)
  check(A.selection(h,mode).missionId==C.mainChapters[math.min(35,done[mode]+1)].id,message..': own selection frontier '..mode)
  check(A.selection(h,mode).difficultyId==mode,message..': selection mode '..mode)
  check(journal.choice==(done[mode]>=7 and branch[mode]or ''),message..': own restoration choice '..mode)
  for number,c in ipairs(C.mainChapters)do
   local earned=number<=done[mode]
   check((journal.clears[c.id]==true)==earned,message..': exact story receipt '..mode..':'..c.id)
   check((e.modeRewardClaims[mode][c.id]==true)==earned,message..': exact first reward receipt '..mode..':'..c.id)
   check((e.clears[c.id]and e.clears[c.id][mode]==true or false)==earned,message..': actual mode clear '..mode..':'..c.id)
   local paid=profile.wallet.heroClaims.hero and profile.wallet.heroClaims.hero[c.id]
   check((paid and paid[mode]==true or false)==earned,message..': exact Diamond receipt '..mode..':'..c.id)
  end
  if done[mode]<35 then
   local nextChapter=C.mainChapters[done[mode]+1]
   local previous=D.modes[mode].previous
   local previousPaid=not previous or done[previous]>=nextChapter.number
   local allowed,reason=D.allowed(h,nextChapter.id,mode)
   check(allowed==previousPaid,message..': next gate uses own story plus same quest previous mode '..mode)
   if not allowed then check(reason=='PreviousDifficulty',message..': correct prior-mode gate '..mode)end
   local beyond=C.mainChapters[done[mode]+2]
   if beyond then
    local denied,why=D.allowed(h,beyond.id,mode)
    check(not denied and why=='StoryLocked',message..': other mode cannot unlock own next-next story '..mode)
    local result,admissionWhy=A.begin(profile,'hero',beyond.id,mode,'forbidden_'..mode..'_'..beyond.id:gsub('-','_'),profile.revision,R,I,D.version)
    check(not result and admissionWhy=='StoryLocked',message..': actual admission enforces own story '..mode)
   end
  end
 end
end
local function enter(c,mode)
 local snapshot=otherModes(mode)
 local old=hero().expeditions.active and R.copy(hero().expeditions.active)
 totals.begins=totals.begins+1
 local run='interleave_'..totals.begins..'_'..mode..'_'..c.id:gsub('-','_')
 local nextProfile,why=A.begin(profile,'hero',c.id,mode,run,profile.revision,R,I,D.version)
 assert(nextProfile,tostring(why)..' entering '..mode..':'..c.id)
 profile=nextProfile
 unchangedOther(snapshot,'admission '..mode..':'..c.id)
 local repeated=assert(A.begin(profile,'hero',c.id,mode,run,profile.revision,R,I,D.version))
 check(same(repeated,profile),'same admission request is idempotent '..run)
 check(hero().expeditions.active.difficultyId==mode and hero().expeditions.active.missionId==c.id,'run launch binds own mode and chapter')
 if old then
  local goal=C.byId[old.missionId].goals[1]
  local stale,errorCode=A.event(profile,'hero',old.missionId,goal.id,nil,nil,R,I,old.runId)
  check(not stale and errorCode=='AdventureChanged','stale goal request rejected after every admission')
  local staleKill,killWhy=R.progress(profile,{action='AwardXP',heroId='hero',runId=old.runId,killId='stale',stream='interleave_validation',sequence=sequence+1,amount=1,coins=99},{serverReward=true},I)
  check(not staleKill and killWhy=='AdventureChanged','stale kill request rejected after every admission')
  totals.stale=totals.stale+2
 end
 return run
end
local function apply(c,mode,goal,step,run)
 local snapshot=otherModes(mode)
 local choice=choices(mode,goal,step)
 local nextProfile,why=A.event(profile,'hero',c.id,goal.id,choice,step and step.id or nil,R,I,run)
 assert(nextProfile,tostring(why)..' applying '..mode..':'..c.id..':'..goal.id)
 profile=nextProfile;totals.events=totals.events+1
 unchangedOther(snapshot,'objective '..mode..':'..c.id..':'..goal.id)
 local retried=assert(A.event(profile,'hero',c.id,goal.id,choice,step and step.id or nil,R,I,run))
 check(same(retried,profile),'goal retry cannot duplicate or move any checkpoint')
end
local function kill(c,mode,run,duplicate)
 local snapshot=otherModes(mode);local oldGold=profile.wallet.gold
 sequence=sequence+1
 local command={action='AwardXP',heroId='hero',runId=run,killId=c.id..':partial_guard',stream='interleave_validation',sequence=sequence,amount=17,coins=7}
 local result,why=R.progress(profile,command,{serverReward=true},I)
 assert(result,tostring(why)..' kill '..mode..':'..c.id)
 profile=result
 check(hero().expeditions.active.kills[command.killId],'actual server API stores the kill receipt')
 check(profile.wallet.gold-oldGold==(duplicate and 0 or 7),'kill receipt pays Gold once across mode resumes')
 local sameCommand=assert(R.progress(profile,command,{serverReward=true},I))
 check(same(sameCommand,profile),'same kill response retry is idempotent')
 unchangedOther(snapshot,'kill '..mode..':'..c.id)
 if duplicate then totals.duplicateKills=totals.duplicateKills+1 else totals.kills=totals.kills+1 end
end
local function firstPartial(c,mode,run)
 local goal=c.goals[1];local step=goal.activity and goal.activity.steps and goal.activity.steps[1]
 apply(c,mode,goal,step or false,run)
 check(not hero().expeditions.active.journal.clears[c.id],'first step genuinely leaves the chapter unfinished')
 kill(c,mode,run,false)
 return {journal=R.copy(hero().expeditions.active.journal),kills=R.copy(hero().expeditions.active.kills)}
end
local function finish(c,mode,run)
 local oldGold=profile.wallet.gold
 for _,goal in ipairs(c.goals)do if P.required(A.projection(hero()),goal)then
  for _,step in ipairs(goal.activity and goal.activity.steps or {false})do apply(c,mode,goal,step,run)end
 end end
 done[mode]=done[mode]+1;totals.completed=totals.completed+1
 check(profile.wallet.gold-oldGold==c.reward.coins,'one first quest Gold award on '..mode..':'..c.id)
 check(hero().expeditions.modeJournals[mode].clears[c.id],'completed quest belongs to its actual mode')
 invariants('completed '..mode..':'..c.id)
end
local function reload(epic)
 local database=R.copy(profile)
 local adapter={UpdateAsync=function(_,_,transform)
  local value=transform(R.copy(database));if value then database=R.copy(value)end
  return value and R.copy(database)
 end}
 local first=Store.new(adapter,R,I,function()return 100 end,function()end,'interleave_before_'..epic)
 local opened=assert(first:open(profile.userId))
 local modes=R.copy(opened.heroes.hero.expeditions.modeJournals)
 local claims=R.copy(opened.heroes.hero.expeditions.modeRewardClaims)
 local runs=R.copy(opened.heroes.hero.expeditions.runsByMode)
 local gold,diamonds=opened.wallet.gold,opened.wallet.diamonds
 assert(first:close(profile.userId))
 local second=Store.new(adapter,R,I,function()return 101 end,function()end,'interleave_after_'..epic)
 profile=assert(second:open(profile.userId))
 check(same(modes,hero().expeditions.modeJournals)and same(claims,hero().expeditions.modeRewardClaims),'all difficulty histories survive epic reconnect')
 check(same(runs,hero().expeditions.runsByMode),'all per-mode run checkpoints survive epic reconnect')
 check(profile.wallet.gold==gold and profile.wallet.diamonds==diamonds,'epic reconnect cannot repay shared balances')
 profile=assert(second:close(profile.userId));totals.reconnects=totals.reconnects+1
end
local function run()
 invariants('fresh account')
 for _,c in ipairs(C.mainChapters)do
  local easyPartial
  for _,mode in ipairs({'Hard','Insane','Hell'})do
   local run=enter(c,mode)
   check(next(hero().expeditions.active.kills)==nil,'new chapter admission cannot inherit previous chapter kill IDs')
   local partial=firstPartial(c,mode,run)
   local easyRun=enter(c,'Easy')
   if not easyPartial then easyPartial=firstPartial(c,'Easy',easyRun)else
    check(same(easyPartial.journal,hero().expeditions.active.journal),'Easy partial journal survives every other mode completion')
    check(same(easyPartial.kills,hero().expeditions.active.kills),'Easy partial kills survive every other mode completion')
   end
   local resumed=enter(c,mode)
   check(same(partial.journal,hero().expeditions.active.journal),'mode returns to exactly its own partial journal '..mode..':'..c.id)
   check(same(partial.kills,hero().expeditions.active.kills),'mode returns to exactly its own kill receipts '..mode..':'..c.id)
   kill(c,mode,resumed,true)
   finish(c,mode,resumed)
  end
  local easyRun=enter(c,'Easy')
  check(same(easyPartial.journal,hero().expeditions.active.journal),'Easy returns to its own unfinished journal after all higher modes')
  check(same(easyPartial.kills,hero().expeditions.active.kills),'Easy returns to its own partial kills after all higher modes')
  kill(c,'Easy',easyRun,true)
  finish(c,'Easy',easyRun)
  if c.number%7==0 then reload(c.epic);invariants('epic boundary '..c.epic)end
  print('Completed chapter '..c.number..' '..c.id..' in Hard > Insane > Hell > Easy');io.stdout:flush()
 end
 check(totals.completed==140,'all 140 actual mode quest completions executed')
 check(totals.kills==140 and totals.duplicateKills==140,'every mode quest tests actual and resumed duplicate kill receipt')
 check(profile.wallet.diamonds==(3+5+7+10)*35,'exact first Diamonds for every mode and chapter')
 for _,mode in ipairs(order)do
  check(hero().expeditions.modeJournals[mode].main==35,'all five epics complete independently in '..mode)
  check(hero().expeditions.modeJournals[mode].choice==branch[mode],'mode retains its own restoration choice '..mode)
 end
 print('PASS: 140 interleaved main quests, five epic reconnects, own restoration choices, gates, selections, receipts, stale requests')
 for _,key in ipairs({'checks','completed','events','begins','kills','duplicateKills','stale','reconnects'})do print(key..'='..totals[key])end
end
local versionFile=assert(io.open('VERSION'));local version=versionFile:read('*l');versionFile:close()
local commit=assert(io.popen('git rev-parse HEAD')):read('*l')
print('VERSION='..version);print('COMMIT='..commit);print('SCRIPT=/tmp/throne-mode-interleaved-01094.lua');io.stdout:flush()
local ok,reason=xpcall(run,debug.traceback)
if not ok then print('FAIL after '..totals.completed..' completions and '..totals.checks..' checks: '..reason);os.exit(1)end
