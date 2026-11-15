-- Production account transitions: independent campaigns, checkpoints and payouts.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items,C,P,A,D,M=load('ItemCatalog'),load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('Difficulty'),load('CampaignModeProgress')
local Growth,Presentation=load('HeroProgression'),load('ExpeditionPresentation')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function same(a,b)
 if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end;return true
end
local function fresh(id)
 local p=assert(R.addHero(R.new(id),'hero','knight',Items));p.heroes.hero.level=99;p.heroes.hero.progression=Growth.new(99);return p
end
local function gearCount(profile)
 local count=0
 for _,item in pairs(profile.items)do if item.definitionId=='knight_weapon_fine'then count=count+item.quantity end end
 return count
end
local function begin(p,id,mode,run)return assert(A.begin(p,'hero',id,mode,run,p.revision,R,Items))end
local function apply(p,c,g,step,run)
 local choice=step and step.choices and(step.solution or step.choices[1].id)or g.choice and 'shared' or nil
 local nextProfile,why=A.event(p,'hero',c.id,g.id,choice,step and step.id or nil,R,Items,run)
 assert(nextProfile,tostring(why)..' '..c.id..':'..g.id)
 local retry=assert(A.event(nextProfile,'hero',c.id,g.id,choice,step and step.id or nil,R,Items,run))
 check(same(retry,nextProfile),'same event retry cannot regrant or advance '..c.id..':'..g.id)
 check(R.validate(nextProfile,Items),'saved profile remains valid')
 return nextProfile
end
local function finish(p,c,run)
 for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do p=apply(p,c,g,step,run)end
 end end
 check(A.projection(p.heroes.hero).clears[c.id],'quest actually completes '..c.id)
 return p
end
local p=fresh(501);local first=C.byId['DW-01'];local savedEasy
p=begin(p,'DW-01','Easy','easy_partial');p=apply(p,first,first.goals[1],false,'easy_partial')
savedEasy=R.copy(p.heroes.hero.expeditions.modeJournals.Easy)
p=begin(p,'DW-01','Hard','hard_partial')
check(not A.projection(p.heroes.hero).flags['DW-01:trail_guards'],'Hard cannot inherit Easy first kill objective')
check(not D.allowed(p.heroes.hero,'DW-02','Hard'),'Easy progress cannot unlock Hard story 2')
check(same(savedEasy,p.heroes.hero.expeditions.modeJournals.Easy),'switch leaves Easy journal intact')
p=apply(p,first,first.goals[1],false,'hard_partial')
local oldHard=R.copy(p.heroes.hero.expeditions.active.journal)
p.heroes.hero.expeditions.active.kills.trail_guards_1=true
p=begin(p,'DW-01','Easy','easy_return')
check(A.projection(p.heroes.hero).flags['DW-01:trail_guards'],'Easy checkpoint restored after mode switch')
p=begin(p,'DW-01','Hard','hard_return')
check(same(oldHard,A.projection(p.heroes.hero)and p.heroes.hero.expeditions.active.journal),'Hard checkpoint restored after switching back')
check(p.heroes.hero.expeditions.active.kills.trail_guards_1,'confirmed kill receipts survive mode resume')
local rejected,why=A.event(p,'hero','DW-01',first.goals[1].id,nil,nil,R,Items,'hard_partial')
check(not rejected and why=='AdventureChanged','old mode/run request cannot mutate current progress')
local validCopy=R.copy(p);validCopy.heroes.hero.expeditions.modeJournals.Hard.main=35
check(not R.validate(validCopy,Items),'invalid mode journal is rejected rather than loaded as empty')
validCopy=R.copy(p);validCopy.heroes.hero.expeditions.modeRewardClaims.Hard['HG-07']=true
check(not R.validate(validCopy,Items),'unearned mode claim rejected')
-- Hard first must not mark Easy cleared, including migration/reload.
p=finish(p,first,'hard_return')
check(p.heroes.hero.expeditions.modeJournals.Easy.main==0,'Hard clear leaves Easy unfinished')
local paid=p.wallet.gold;p=R.upgrade(R.copy(p),Items)
check(p.wallet.gold==paid,'loading a separated profile grants no duplicate completion award')
local preview=Presentation.missions(p.heroes.hero,1)
check(not preview[1].modes.Hard.firstClear and preview[1].modes.Easy.firstClear,'mode-specific first reward preview')
check(A.selection(p.heroes.hero,'Hard').missionId=='DW-02'and A.selection(p.heroes.hero,'Easy').missionId=='DW-01','each mode has its own lobby frontier')
-- Full five-epic campaigns; every mode earns each first quest reward once.
p=fresh(502)
local campaigns={}
for _,mode in ipairs(D.order)do
 local run='campaign_'..mode;p=begin(p,'DW-01',mode,run)
 check(A.projection(p.heroes.hero).main==0,'new difficulty starts at the first quest '..mode)
 local beforeGold=p.wallet.gold;local expectedGold=0
 for _,c in ipairs(C.mainChapters)do
  local before=R.copy(p.heroes.hero.expeditions.modeJournals)
  check(A.projection(p.heroes.hero).expeditionFirstClear,'first quest payout belongs to mode '..mode..':'..c.id)
  p=finish(p,c,run);expectedGold=expectedGold+c.reward.coins
  check(p.heroes.hero.expeditions.modeJournals[mode].main==c.number,'mode campaign frontier advances')
  check(p.heroes.hero.expeditions.modeRewardClaims[mode][c.id],'mode reward receipt committed')
  for _,other in ipairs(D.order)do if other~=mode then
   check(same(before[other],p.heroes.hero.expeditions.modeJournals[other]),'other mode journal unchanged '..other)
  end end
  if c.number%7==0 then check(p.heroes.hero.expeditions.modeJournals[mode].clears[c.id],'epic completion stays in selected mode')end
 end
 check(p.wallet.gold-beforeGold==expectedGold,'all first Gold rewards granted on '..mode)
 check(gearCount(p)==4*(#campaigns+1),'first equipment grants have independent mode IDs')
 campaigns[#campaigns+1]=mode
 local side=C.byId['DW-Q1'];local prior=R.copy(p.heroes.hero.expeditions.modeJournals)
 p=begin(p,side.id,mode,'side_'..mode)
 check(not A.projection(p.heroes.hero).clears[side.id],'side quest starts independently on '..mode)
 p=finish(p,side,'side_'..mode)
 check(p.heroes.hero.expeditions.modeRewardClaims[mode][side.id],'mode-specific added quest award receipt')
 for _,other in ipairs(D.order)do if other~=mode then check(same(prior[other],p.heroes.hero.expeditions.modeJournals[other]),'side quest cannot mark another difficulty complete')end end
 local loaded=R.upgrade(R.copy(p),Items)
 check(loaded.wallet.gold==p.wallet.gold and same(loaded.items,p.items),'reload never catches up already-paid mode awards')
 print('Completed mode campaign: '..mode);io.stdout:flush()
end
-- Replay gives only the configured repeat payout, not first quest equipment.
local gold,gear=p.wallet.gold,gearCount(p)
p=begin(p,'DW-01','Hard','hard_replay')
check(A.selection(p.heroes.hero,'Hard').missionId=='DW-01','explicit replay keeps its own checkpoint on mode selection')
p=finish(p,first,'hard_replay')
check(A.selection(p.heroes.hero,'Hard').missionId=='DW-02','explicit replay continues its own next quest')
check(p.wallet.gold-gold==D.completion(first,'Hard',D.version).gold,'Hard replay receives repeat Gold only')
check(gearCount(p)==gear,'Hard replay cannot duplicate first equipment')
-- Noncombat chapters can be resumed within every difficulty.
for _,mode in ipairs(D.order)do check(D.allowed(p.heroes.hero,'DW-03',mode),'noncombat story resume on '..mode)end
-- Legacy mixed records: actual receipts seed modes; a shared completed prefix
-- must never manufacture Hard/Insane/Hell completion or repay old rewards.
local legacy=R.copy(p);local e=legacy.heroes.hero.expeditions
e.modeJournals=nil;e.modeRewardClaims=nil;e.runsByMode=nil;e.active=nil
e.clears={['DW-01']={Easy=true,Hard=true}}
legacy.wallet.heroClaims={hero={}}
for _,c in ipairs(C.mainChapters)do legacy.wallet.heroClaims.hero[c.id]={Easy=true}end
legacy.wallet.heroClaims.hero['DW-01'].Hard=true
legacy.heroes.hero.deepwood=R.copy(p.heroes.hero.expeditions.modeJournals.Easy)
local preserved=R.copy(legacy.heroes.hero.deepwood);gold=legacy.wallet.gold
local migrated=R.upgrade(legacy,Items)
check(migrated.heroes.hero.expeditions.modeJournals.Hard.main==1,'only confirmed legacy Hard chapter imported')
check(migrated.heroes.hero.expeditions.modeJournals.Insane.main==0,'no synthetic Insane completion')
check(migrated.wallet.gold==gold and same(migrated.heroes.hero.deepwood,preserved),'migration preserves original history and balances')
check(M.claimed(migrated.heroes.hero,'DW-01','Hard'),'historic paid receipt preserved')
check(not M.claimed(migrated.heroes.hero,'DW-02','Hard'),'Easy-only clear does not claim Hard reward')
check(R.validate(migrated,Items),'migrated profile can reconnect')
local historic=R.copy(p);local hh=historic.heroes.hero;local old=P.copy(hh.expeditions.modeJournals.Easy)
old.version=1;old.main=21;old.legacyMain=nil;old.legacyResume=nil;old.explored={};old.accepted={}
local function historicChapter(id)return id:match('^DW%-0')or id:match('^FV%-0')or id:match('^EC%-0')end
for _,field in ipairs({'flags','clears','activities','clues','decisions','expansionWaivers','pacingWaivers'})do
 for key in pairs(old[field]or {})do if not historicChapter(key)then old[field][key]=nil end end
end
old.coins=0;for id in pairs(old.clears)do local c=C.byId[id];old.coins=old.coins+(c.journalCoins or c.reward.coins)end
check(P.validate(old),'pre-Gloamwood journal fixture is valid')
hh.deepwood=old;hh.expeditions={version=1,clears={},cacheProgress={}}
historic.wallet.heroClaims={hero={}}
for id in pairs(old.clears)do hh.expeditions.clears[id]={Easy=true};historic.wallet.heroClaims.hero[id]={Easy=true}end
for id in pairs(hh.completionRewardClaims or {})do if not old.clears[id]then hh.completionRewardClaims[id]=nil end end
historic=R.upgrade(historic,Items);hh=historic.heroes.hero
check(R.validate(historic,Items),'historic account remains loadable after mode migration')
check(hh.expeditions.modeJournals.Easy.clears['FV-07']and hh.expeditions.modeJournals.Easy.legacyMain==21,'actual historic Easy clear/access preserved across inserted epic')
check(hh.expeditions.modeJournals.Hard.main==0 and not D.allowed(hh,'FV-01','Hard'),'historic Easy access never unlocks new Hard progress')
-- Real uncapped XP and Diamonds, independently earned on Hard and then Easy.
local xpProfile=fresh(503);xpProfile.heroes.hero.level=10;xpProfile.heroes.hero.progression=Growth.new(10)
local total=Growth.totalXP(xpProfile.heroes.hero.progression)
for _,mode in ipairs({'Hard','Easy'})do
 xpProfile=begin(xpProfile,'DW-01',mode,'xp_'..mode);xpProfile=finish(xpProfile,first,'xp_'..mode)
 total=total+load('CampaignXPRewards')[mode]['DW-01'].quest
 check(Growth.totalXP(xpProfile.heroes.hero.progression)==total,'actual quest XP credited on '..mode)
end
check(xpProfile.wallet.gold==first.reward.coins*2 and gearCount(xpProfile)==2,'first Gold and equipment paid separately on both modes')
check(xpProfile.wallet.diamonds==8,'Hard 5 plus Easy 3 Diamonds remain separate and exact')
-- Lost final-save response: retries see the committed mode receipt, not a fresh
-- profile, and an overlapping server cannot acquire the account lease.
local Store=dofile('src/server/Inventory/AccountStore.luau')
local pending=fresh(504);pending=begin(pending,'DW-01','Hard','uncertain')
local lastGoal=first.goals[#first.goals]
for _,g in ipairs(first.goals)do if g~=lastGoal and P.required(A.projection(pending.heroes.hero),g)then
 for _,step in ipairs(g.activity and g.activity.steps or {false})do pending=apply(pending,first,g,step,'uncertain')end
end end
check(not pending.heroes.hero.expeditions.modeRewardClaims.Hard['DW-01'],'fixture stops before the reward transaction')
local database=R.copy(pending);local lost=0
local adapter={UpdateAsync=function(_,_,callback)
 local nextProfile=callback(R.copy(database));if nextProfile then database=R.copy(nextProfile)end
 if lost>0 then lost=lost-1;error('simulated lost response')end
 return nextProfile and R.copy(database)
end}
local store=Store.new(adapter,R,Items,function()return 100 end,function()end,'mode_owner')
assert(store:open(504));lost=3
local finalStep=lastGoal.activity and lastGoal.activity.steps and lastGoal.activity.steps[1]
local function claim(current)return A.event(current,'hero','DW-01',lastGoal.id,nil,finalStep and finalStep.id,R,Items,'uncertain')end
local result,reason=store:transact(504,claim)
check(not result and reason=='SaveUnknown','uncertain save is not treated as an empty account')
local committed=R.copy(database);result=assert(store:transact(504,claim))
check(result.wallet.gold==committed.wallet.gold and same(result.items,committed.items),'uncertain completion retries grant no duplicate reward')
check(result.heroes.hero.expeditions.modeRewardClaims.Hard['DW-01'],'mode receipt and reward committed together')
local rival=Store.new(adapter,R,Items,function()return 100 end,function()end,'other_server')
result,reason=rival:open(504)
check(not result and reason=='AccountBusy','concurrent server cannot replace mode progress')
database.heroes.hero.expeditions.modeJournals.Hard.main=35
result,reason=rival:open(504)
check(not result and reason=='Incompatible'and database.heroes.hero.expeditions.modeJournals.Hard.main==35,'failed mode load is never replaced with a new profile')
print('Campaign mode progress: '..checks..' checks passed')
