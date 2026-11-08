local Content=dofile('src/shared/CampaignContent.luau')
local Rewards=dofile('src/shared/QuestCompletionRewards.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local D=dofile('src/shared/Difficulty.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local View=dofile('src/shared/ExpeditionPresentation.luau')
local Completion=dofile('src/shared/StoryCompletion.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function equal(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not equal(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local function events(c,run)
 for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do run(g,step.choices and step.choices[1].id,step.id)end
  else run(g,g.choice and 'shared')end
 end end
end
local function quantity(p,id)
 local n=0;for _,item in pairs(p.items)do if item.definitionId==id then n=n+item.quantity end end;return n
end
local profile=assert(R.addHero(R.new(902),'hero','knight',C))
local expectedGold,expectedXP=0,0
local prefixes={}
for _,c in ipairs(Content.mainChapters)do
 check(c.reward.xp>0 and c.reward.coins>0,'every main quest pays '..c.id)
 events(c,function(g,choice,step)
  profile=assert(R.story(profile,'hero',c.id,g.id,choice,C,step))
  local again=assert(R.story(profile,'hero',c.id,g.id,choice,C,step))
  check(equal(again,profile),'retry does not pay twice '..c.id)
 end)
 expectedGold=expectedGold+c.reward.coins;expectedXP=expectedXP+c.reward.xp
 check(profile.wallet.gold==expectedGold,'actual wallet matches first reward '..c.id)
 check(G.totalXP(profile.heroes.hero.progression)==expectedXP,'actual growth matches first reward '..c.id)
 check(R.validate(profile,C),'account valid after first clear '..c.id)
 prefixes[c.number]=R.copy(profile)
end
local mainOnly=R.copy(profile)
for _,c in ipairs(Content.chapters)do if c.side then
 check(c.reward.xp>0 and c.reward.coins>0 and ((c.reward.ore or 0)+(c.reward.gems or 0))>0,'side pays XP, Gold and items '..c.id)
 local run='first-'..c.id
 profile=assert(A.begin(profile,'hero',c.id,'Easy',run,profile.revision,R,C,12))
 local gold,xp=profile.wallet.gold,G.totalXP(profile.heroes.hero.progression)
 local ore,gems=quantity(profile,'iron_ore'),quantity(profile,'enhancement_gem')
 local report=P.goal(c,c.quest.turnIn)
 check(not A.event(profile,'hero',c.id,report.id,nil,nil,R,C,run),'early report cannot award '..c.id)
 events(c,function(g,choice,step)
  profile=assert(A.event(profile,'hero',c.id,g.id,choice,step,R,C,run))
  if g~=report then check(profile.wallet.gold==gold,'unfinished quest does not pay '..c.id)end
  check(equal(assert(A.event(profile,'hero',c.id,g.id,choice,step,R,C,run)),profile),'run retry cannot duplicate '..c.id)
 end)
 check(profile.wallet.gold-gold==c.reward.coins,'first side Gold paid '..c.id)
 check(G.totalXP(profile.heroes.hero.progression)-xp==c.reward.xp,'first side XP paid '..c.id)
 local mode=D.completion(c,'Easy')
 check(quantity(profile,'iron_ore')-ore==(c.reward.ore or 0),'fixed Ore paid '..c.id)
 check(quantity(profile,'enhancement_gem')-gems==(c.reward.gems or 0)+mode.gems,'fixed gems and mode gems both paid '..c.id)
 check(profile.heroes.hero.completionRewardClaims[c.id]==1,'durable reward receipt '..c.id)
 check(Log.reward(c):find(tostring(c.reward.coins)..' Gold',1,true),'journal reward preview '..c.id)
 -- Replaying does not reissue the first-clear materials, but pays repeat XP/Gold.
 local repeatRun='repeat-'..c.id
 profile=assert(A.begin(profile,'hero',c.id,'Easy',repeatRun,profile.revision,R,C,12))
 gold=profile.wallet.gold;xp=G.totalXP(profile.heroes.hero.progression);ore=quantity(profile,'iron_ore');gems=quantity(profile,'enhancement_gem')
 events(c,function(g,choice,step)profile=assert(A.event(profile,'hero',c.id,g.id,choice,step,R,C,repeatRun))end)
 check(mode.gold>0 and mode.xp>0,'nonzero repeat award '..c.id)
 check(profile.wallet.gold-gold==mode.gold and G.totalXP(profile.heroes.hero.progression)-xp==mode.xp,'actual repeat pays advertised XP/Gold '..c.id)
 check(quantity(profile,'iron_ore')==ore and quantity(profile,'enhancement_gem')-gems==mode.gems,'repeat never reissues first materials '..c.id)
 check(R.validate(profile,C),'replay account valid '..c.id)
end end
-- Every new award preserves rules 1-11, including completed legacy runs.
for id in pairs(Rewards.awards)do
 for _,mode in ipairs(D.order)do for version=1,11 do
  local reward=D.completion(Content.byId[id],mode,version)
  check(reward.xp==0 and reward.gold==0,'pinned pre-award repeat contract '..id)
 end end
end
check(D.version==13 and D.compatible(12) and D.compatible(11),'expanded runs retain rules 12 completion rewards')
-- Reconstruct an actual pre-award account: unchanged journal, with awards absent.
local legacy=R.copy(profile);local h=legacy.heroes.hero
local addedGold,addedXP=0,0
for id,row in pairs(Rewards.awards)do addedGold=addedGold+row.coins;addedXP=addedXP+row.xp end
legacy.wallet.gold=1000;legacy.wallet.diamonds=7;h.completionRewardClaims=nil;h.level=20;h.progression=G.new(20)
check(R.validate(legacy,C),'old no-receipt profile validates before migration')
local migrated=R.upgrade(R.copy(legacy),C)
check(migrated.wallet.gold==1000+addedGold and migrated.wallet.diamonds==7,'catch-up pays only missing Gold, preserves Diamonds')
check(G.totalXP(migrated.heroes.hero.progression)-G.totalXP(h.progression)==addedXP,'catch-up grants missing XP')
check(equal(migrated.heroes.hero.deepwood,h.deepwood),'journal flags/checksum and clears preserved')
check(equal(R.upgrade(R.copy(migrated),C),migrated),'second migration cannot pay or change revision')
check(R.validate(migrated,C),'migrated account valid')
local two=assert(R.addHero(legacy,'mage','mage',C));two.heroes.mage.deepwood=R.copy(h.deepwood)
local twoBefore=two.wallet.gold;two=R.upgrade(two,C)
check(two.wallet.gold==twoBefore+2*addedGold,'two heroes each own their quest completion rewards')
check(two.heroes.mage.completionRewardClaims['DW-Q1']==1 and two.heroes.hero.completionRewardClaims['DW-Q1']==1,'receipts are per hero')
check(R.validate(two,C)and equal(R.upgrade(R.copy(two),C),two),'two-hero migration is valid and idempotent')
-- Spending and selling awarded items never recreates the entitlement.
migrated.wallet.gold=1
for id,item in pairs(migrated.items)do if item.sourceGrantId:find('quest-award-v1-',1,true)then migrated.items[id]=nil end end
check(equal(R.upgrade(R.copy(migrated),C),migrated),'spent awards do not refill')
local invalid=R.copy(mainOnly);invalid.heroes.hero.completionRewardClaims={['DW-Q1']=1}
check(not R.validate(invalid,C),'reward receipt without a clear fails closed')
invalid=R.copy(migrated);invalid.heroes.hero.completionRewardClaims['DW-Q1']=2
check(not R.validate(invalid,C),'unknown reward receipt version fails closed')
-- Full bags route fixed items to unclaimed rather than dropping them.
local full=R.copy(legacy)
for id,item in pairs(full.items)do if item.definitionId=='iron_ore'or item.definitionId=='enhancement_gem'then full.items[id]=nil end end
for _,item in pairs(full.items)do if item.location.kind=='bag'then item.location={kind='pending'}end end
for i=1,C.bagCapacity do local id='full'..i;full.items[id]={instanceId=id,definitionId='health_potion',definitionVersion=C.version,ownerUserId=full.userId,quantity=99,version=1,binding='account',locked=true,location={kind='bag',heroId='hero'},sourceGrantId=id}end
check(R.validate(full,C),'full bag fixture valid')
full=R.upgrade(full,C)
local pending=0;for _,item in pairs(full.items)do if item.sourceGrantId:find('quest-award-v1-',1,true)then check(item.location.kind=='pending','full bag award is unclaimed');pending=pending+1 end end
check(pending>0 and R.validate(full,C),'full bag loses no award')
-- AccountStore UpdateAsync replay and lost response keep catch-up atomic.
local saved=R.copy(legacy);local lose=true
local adapter={UpdateAsync=function(_,_,fn)
 fn(R.copy(saved));local nextProfile=fn(R.copy(saved));if nextProfile then saved=R.copy(nextProfile)end
 if lose then error('response lost after commit')end;return nextProfile
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'award-session')
local no,why=store:open(902);check(not no and why=='SaveUnknown','lost response stays unknown')
check(saved.wallet.gold==1000+addedGold,'committed catch-up paid once through three retries')
lose=false;local loaded=assert(store:open(902));check(loaded.wallet.gold==saved.wallet.gold,'retry returns durable award')
local durable=R.copy(loaded);check(store:close(902),'close lease')
loaded=assert(store:open(902));check(loaded.wallet.gold==durable.wallet.gold and equal(loaded.items,durable.items),'reconnect preserves spent rights and items')
local broken=Store.new({UpdateAsync=function()error('read failed')end},R,C,function()return 100 end,function()end,'broken')
no,why=broken:open(902);check(not no and why=='SaveUnknown'and broken.profiles[902]==nil,'failed load never fabricates a reward account')
local busy=R.copy(legacy);busy.lease={token='other',epoch=busy.epoch,expiresAt=200}
local blocked=Store.new({UpdateAsync=function(_,_,fn)return fn(R.copy(busy))end},R,C,function()return 100 end,function()end,'blocked')
no,why=blocked:open(902);check(not no and why=='AccountBusy'and busy.wallet.gold==1000,'another live lease blocks catch-up')
-- Lv80 keeps Gold/material awards and cannot accumulate capped XP.
local capped=R.copy(legacy);capped.heroes.hero.level=80;capped.heroes.hero.progression=G.new(80)
capped=R.upgrade(capped,C);check(capped.heroes.hero.progression.xp==0 and capped.wallet.gold==1000+addedGold,'Lv80 caps only XP')
local overflow=R.copy(legacy);overflow.wallet.gold=1e12
local deferred=R.upgrade(overflow,C);check(deferred.wallet.gold==1e12 and deferred.heroes.hero.completionRewardClaims==nil,'wallet cap defers missing awards without a false receipt')
deferred.wallet.gold=0;check(R.upgrade(deferred,C).wallet.gold==addedGold,'deferred catch-up recovers after wallet room exists')
for _,mission in ipairs(View.missions(mainOnly.heroes.hero))do if mission.id=='DW-Q1'then
 check(mission.modes.Easy.firstXP==60 and mission.modes.Easy.firstGold==100 and mission.modes.Easy.firstOre==2,'lobby mission preview matches first payout')
end end
local c=Content.byId['DW-Q1']
local card=Completion.project({heroId='hero',journal=profile.heroes.hero.deepwood,completion={id=c.id,xp=60,coins=100,ore=2}})
check(card.reward:find('100 Gold',1,true)and card.saved:find('2 Iron Ore',1,true),'completion card reports actual materials and Gold')
print('Quest completion rewards: '..checks..' checks passed; 47 quests pay, 19 new awards; legacy catch-up and storage recovery PASS')
