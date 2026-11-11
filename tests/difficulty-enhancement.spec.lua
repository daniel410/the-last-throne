-- User-visible progression and ownership invariants; no client-trusted rewards.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local E=dofile('src/shared/Enhancement.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local Growth=dofile('src/shared/HeroProgression.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local function shop(p,c,context,catalog)
 if c.action=='Enhance'then c.rulesVersion=c.rulesVersion or E.version;c.expectedLevel=c.expectedLevel or (p.items[c.instanceId].enhancementLevel or 0);context.enhancementRoll=0 end
 return R.shop(p,c,context,catalog)
end
local n=0
local function check(v,label)n=n+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
local function new()return assert(R.addHero(R.new(42),'hero','knight',C))end
local function find(p,id)local fallback;for _,item in pairs(p.items)do if item.definitionId==id then if item.location.kind=='bag'then return item end;fallback=item end end;return fallback end
local function complete(p,run)
 local c=Content.byId['DW-01']
 for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do p=assert(A.event(p,'hero',c.id,g.id,step.choices and step.choices[1].id,step.id,R,C,run))end
  else p=assert(A.event(p,'hero',c.id,g.id,g.choice and 'sanctuary',nil,R,C,run))end
 end end
 check(R.validate(p,C),'completed run profile valid');return p
end
local p=new();local hero=p.heroes.hero
check(D.allowed(hero,'DW-01','Easy'),'Easy begins at level one')
dofile('tests/difficulty-level-free.spec.lua')
p=new();p=assert(A.begin(p,'hero','DW-01','Easy','easy1',p.revision,R,C))
p=complete(p,'easy1');eq(p.heroes.hero.deepwood.main,1,'original story advances once')
local originalGold=p.wallet.gold;local originalDiamonds=p.wallet.diamonds
local g=p.heroes.hero.progression;p.heroes.hero.level=80;p.heroes.hero.progression=Growth.new(80)
for _,mode in ipairs({'Hard','Insane'})do
 p=assert(A.begin(p,'hero','DW-01',mode,mode,p.revision,R,C));p=complete(p,mode)
end
local beforeHell=p.wallet.gold;local coreBefore=R.quantity(p,'hero','magic_stone')
for run=1,3 do
 local id='hell'..run;p=assert(A.begin(p,'hero','DW-01','Hell',id,p.revision,R,C))
 local wrong,reason=A.event(p,'hero','DW-01','trail_guards',nil,nil,R,C,'forged')
 check(not wrong and reason=='AdventureChanged','foreign run cannot complete objectives')
 p=complete(p,id)
 local gold=p.wallet.gold;local cores=R.quantity(p,'hero','magic_stone')
 p=assert(A.event(p,'hero','DW-01',Content.byId['DW-01'].goals[#Content.byId['DW-01'].goals].id,nil,nil,R,C,id))
 eq(p.wallet.gold,gold,'same run cannot recredit Gold');eq(R.quantity(p,'hero','magic_stone'),cores,'same run cannot recredit cores')
 eq(p.heroes.hero.progression.xp,0,'level80 never accumulates XP')
end
eq(p.wallet.gold-beforeHell,3*D.completion(Content.byId['DW-01'],'Hell').gold,'three fresh Hell clears each credit current repeat Gold')
eq(R.quantity(p,'hero','magic_stone')-coreBefore,30,'three Hell clears credit three material rewards')
eq(p.wallet.diamonds,originalDiamonds,'replays never regrant story Diamonds')
eq(p.heroes.hero.deepwood.main,1,'replays preserve canonical story')
eq(p.heroes.hero.deepwood.coins,150,'replays preserve original story budget')
check(find(p,'equipment_cache_1'),'Hell earns repeat equipment caches')
local gold=p.wallet.gold
local c={action='OpenCache',store='blacksmith',requestId='cache-choice',heroId='hero',revision=p.revision,instanceId=find(p,'equipment_cache_1').instanceId,itemVersion=find(p,'equipment_cache_1').version,offerId='knight_weapon_fine'}
p=assert(shop(p,c,{atLobby=true},C));p=assert(shop(p,c,{atLobby=false},C));eq(p.wallet.gold,gold,'cache retry neither charges nor duplicates')
-- Forge exact costs, idempotency, immutable definitions and recovery.
p.wallet.gold=10000
local item=find(p,'knight_weapon_fine');local id=item.instanceId
for level=1,3 do
 item=p.items[id];local cmd={action='Enhance',store='blacksmith',requestId='enhance'..level,heroId='hero',revision=p.revision,instanceId=id,itemVersion=item.version}
 local oldGold=p.wallet.gold;p=assert(shop(p,cmd,{atLobby=true},C));eq(p.wallet.gold,oldGold-50,'enhancement costs50 Gold per attempt')
 local q=R.quantity(p,'hero','enhancement_gem');p=assert(shop(p,cmd,{atLobby=true},C));eq(R.quantity(p,'hero','enhancement_gem'),q,'retry consumes no extra ore')
end
eq(C.items.knight_weapon_fine.stats.power,3,'item definition never overwritten')
check(math.abs(E.stats(C.items.knight_weapon_fine,p.items[id]).power-3.27)<.00001,'three upgrades add9% to equipment only')
local old=p.wallet.gold;local cmd={action='Enhance',store='blacksmith',requestId='cap',heroId='hero',revision=p.revision,instanceId=id,itemVersion=p.items[id].version}
local capped=R.copy(p);capped.items[id].enhancementLevel=9;cmd.expectedLevel=9
local no,why=shop(capped,cmd,{atLobby=true},C);check(not no and why=='EnhancementMax','all equipment stops at+9');eq(p.wallet.gold,old,'rejected upgrade costs nothing')
local ore=R.quantity(p,'hero','enhancement_gem');cmd.action='Recover';cmd.requestId='recover';p=assert(shop(p,cmd,{atLobby=true},C));eq(p.items[id].enhancementLevel,0,'recovery preserves equipment at+0');eq(R.quantity(p,'hero','enhancement_gem'),ore+9,'recover floor80% of actually paid12ore')
p=assert(shop(p,cmd,{atLobby=true},C));eq(R.quantity(p,'hero','enhancement_gem'),ore+9,'recovery retry creates no extra materials')
cmd.requestId='recover-again';cmd.revision=p.revision;cmd.itemVersion=p.items[id].version;local no,why=shop(p,cmd,{atLobby=true},C);check(not no and why=='NoRecovery','zero ledger cannot refund twice')
check(R.validate(p,C),'forge and replay maintain ownership invariants')
-- Unknown save after the write committed retries the same operation and recovers once.
local data;local fail=false;local adapter={UpdateAsync=function(_,key,fn)local nextP=fn(R.copy(data));if nextP then data=R.copy(nextP)end;if fail then error('reply lost')end;return R.copy(nextP)end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'test-session')
assert(store:open(42));assert(store:transact(42,function(current)local fixture=R.copy(p);fixture.lease=current.lease;fixture.epoch=current.epoch;return fixture end))
item=p.items[id];cmd={action='Enhance',store='blacksmith',requestId='lost-forge',heroId='hero',revision=p.revision,instanceId=id,itemVersion=item.version}
fail=true;local result,reason=store:transact(42,function(current)return shop(current,cmd,{atLobby=true},C)end)
check(not result and reason=='SaveUnknown','lost save response is unknown, not rolled back')
fail=false;result=assert(store:transact(42,function(current)return shop(current,cmd,{atLobby=true},C)end))
eq(result.items[id].enhancementLevel,1,'unknown save recovers exactly one enhancement')
eq(result.wallet.gold,p.wallet.gold-50,'unknown save debits50 Gold exactly once')
-- A fresh run permits new rewards; an enemy in the same run is credited once.
local nextRun='kill-ledger';result=assert(A.begin(result,'hero','DW-01','Hell',nextRun,result.revision,R,C))
local kill={action='AwardXP',heroId='hero',amount=50,coins=5,rewardKind='Defeat',stream='kill-test',sequence=1,requestId='kill1',runId=nextRun,killId='trail_guards_1'}
local money=result.wallet.gold;result=assert(R.progress(result,kill,{serverReward=true},C));eq(result.wallet.gold,money+5,'server kill credits once')
kill.sequence=2;kill.requestId='kill2';result=assert(R.progress(result,kill,{serverReward=true},C));eq(result.wallet.gold,money+5,'respawned same run enemy cannot be farmed twice')
kill.sequence=3;kill.requestId='kill3';kill.killId='trail_guards_2';result=assert(R.progress(result,kill,{serverReward=true},C));eq(result.wallet.gold,money+10,'a duplicate kill does not block subsequent reward stream')
local replay=assert(A.begin(result,'hero','DW-01','Hell',nextRun,result.revision-1,R,C));eq(replay.revision,result.revision,'unknown run creation recovers before stale revision rejection')
local no,why=A.begin(result,'hero','DW-01','Hell','old-request',0,R,C);check(not no and why=='Changed','evicted old departure cannot overwrite newer run')
local manifest={id=nextRun,missionId='DW-01',difficultyId='Hell',rulesVersion=D.version}
check(D.verifyRun(result.heroes.hero,manifest),'destination revalidates persisted manifest and eligibility')
manifest.difficultyId='Easy';check(not D.verifyRun(result.heroes.hero,manifest),'manifest cannot downgrade the persisted mode')
manifest.difficultyId='Hell';manifest.rulesVersion=99;check(not D.verifyRun(result.heroes.hero,manifest),'mixed rule version cannot enter battle')
-- All supported definitions now cap at +9.
local high=R.copy(C);high.items.test_80={id='test_80',name='Test Sword',category='Equipment',slot='weapon',classId='knight',stats={power=24},level=80,maxStack=1}
local full=new();full.heroes.hero.level=80;full.heroes.hero.progression=Growth.new(80);full.wallet.gold=100000
local hitem=find(full,'knight_weapon_fine');hitem.definitionId='test_80'
full.items.gems={instanceId='gems',definitionId='enhancement_gem',definitionVersion=1,ownerUserId=42,quantity=110,version=1,binding='account',locked=false,location={kind='bag',heroId='hero'}}
full.items.cores={instanceId='cores',definitionId='magic_stone',definitionVersion=1,ownerUserId=42,quantity=28,version=1,binding='account',locked=false,location={kind='bag',heroId='hero'}}
for step=1,9 do
 local item=full.items[hitem.instanceId];full=assert(shop(full,{action='Enhance',store='blacksmith',heroId='hero',requestId='high'..step,revision=full.revision,instanceId=item.instanceId,itemVersion=item.version},{atLobby=true},high))
end
eq(full.wallet.gold,99550,'nine successful enhancements cost450 Gold at any level');eq(R.quantity(full,'hero','enhancement_gem'),20,'+9 consumes90 gems');eq(R.quantity(full,'hero','magic_stone'),7,'+9 consumes21 stones')
check(math.abs(E.stats(high.items.test_80,full.items[hitem.instanceId]).power-30.48)<1e-9,'+9 adds27% once to base stats')
-- Partial material shortage and foreign locations never mutate the source account.
local q=new();q.wallet.gold=1000;local gear=find(q,'knight_weapon_fine');gear.enhancementLevel=0
local bad={action='Enhance',store='blacksmith',heroId='hero',requestId='short',revision=q.revision,instanceId=gear.instanceId,itemVersion=gear.version}
q.items.gems={instanceId='gems',definitionId='enhancement_gem',definitionVersion=1,ownerUserId=42,quantity=10,version=1,binding='account',locked=false,location={kind='bag',heroId='hero'}}
find(q,'enhancement_gem').locked=true;local no,why=shop(q,bad,{atLobby=true},C);check(not no and why=='EnhancementMaterials','locked ore cannot pay');eq(q.wallet.gold,1000,'shortage leaves Gold unchanged')
find(q,'enhancement_gem').locked=false;gear.location={kind='storage'};local no,why=shop(q,bad,{atLobby=true},C);check(not no and why=='BagOnly','storage target cannot enhance directly')
local no,why=shop(q,bad,{atLobby=false},C);check(not no and why=='ShopLobbyOnly','remote forge outside lobby rejected')
-- Explicit party selections clear everyone's readiness and are leader-only.
local Match=dofile('src/server/Network/ExpeditionStore.luau');local cfg=dofile('src/shared/ExpeditionConfig.luau');local db={}
local match=Match.new({GetAsync=function(_,k)return R.copy(db[k])end,UpdateAsync=function(_,k,fn)local v=fn(R.copy(db[k]));if v then db[k]=R.copy(v)end;return v end},function()return 100 end,cfg)
local one={userId=1,token='one',heroId='one',main=0,level=80,arrived=true};local two={userId=2,token='two',heroId='two',main=1,level=80,arrived=true}
assert(match.create('party',one,2,'job',1));assert(match.join('party',two));assert(match.configure('party',1,'DW-01','Easy'))
assert(match.touch('party',one,true));assert(match.touch('party',two,true))
check(not match.configure('party',2,'DW-01','Hell'),'nonleader cannot select difficulty')
assert(match.configure('party',1,'DW-01','Hell'));check(not match.freeze('party',1,'run'),'difficulty changes invalidate all readiness')
assert(match.touch('party',one,true));assert(match.touch('party',two,true));check(match.freeze('party',1,'run'),'qualified selected-mission party can depart despite different canonical checkpoints')
for _,mode in ipairs(D.order)do
 local hp,damage,level=D.stats('Goblin',5,4,false,mode)
 check(hp>0 and damage>0 and level>=D.modes[mode].level,'mode stats have fixed difficulty level and party scale')
end
-- Entry limits must not introduce mandatory grinding on the existing Lv1 route.
local balance=dofile('src/shared/DeepwoodEncounterBalance.luau');local routeLevel,routeXP=1,0
for _,chapter in ipairs(Content.mainChapters)do
 check(D.entry(chapter)<=routeLevel,'normal mandatory route reaches '..chapter.id..' without forced repeats')
 local amount=chapter.reward.xp
 for _,goal in ipairs(chapter.goals)do
  for _,spec in ipairs(balance.expand(goal.enemies or {}))do amount=amount+balance.rewards(spec)end
  for _,wave in ipairs(goal.bossEncounter and goal.bossEncounter.waves or {})do for _,spec in ipairs(balance.expand(wave.enemies))do amount=amount+balance.rewards(spec)end end
 end
 routeXP=routeXP+amount
 while routeLevel<80 and routeXP>=Growth.xpToNext(routeLevel)do routeXP=routeXP-Growth.xpToNext(routeLevel);routeLevel=routeLevel+1 end
end
-- Side entry must include the mandatory report's prerequisite, not only discovery.
local function storyClear(profile,c)
 for _,goal in ipairs(c.goals)do if not goal.optional then
  if goal.activity and goal.activity.steps then
   for _,step in ipairs(goal.activity.steps)do profile=assert(R.story(profile,'hero',c.id,goal.id,step.choices and step.choices[1].id,C,step.id))end
  else profile=assert(R.story(profile,'hero',c.id,goal.id,goal.choice and 'sanctuary',C))end
 end end
 return profile
end
local route=new();route.heroes.hero.level=80;route.heroes.hero.progression=Growth.new(80)
for number=1,22 do
 route=storyClear(route,Content.mainChapters[number])
 for id,required in pairs({['FV-Q1']=15,['EC-Q1']=22})do
  if number==required-1 then
   local ok,why=D.allowed(route.heroes.hero,id,'Easy')
   check(not ok and why=='StoryLocked',id..' rejects unfinishable report boundary')
   local nextProfile,why=A.begin(route,'hero',id,'Easy','blocked-'..id,route.revision,R,C)
   check(not nextProfile and why=='StoryLocked',id..' server begin also rejects boundary')
  elseif number==required then
   check(D.allowed(route.heroes.hero,id,'Easy'),id..' opens when report is reachable')
   local side=assert(A.begin(route,'hero',id,'Easy','side-'..id,route.revision,R,C))
   for _,goal in ipairs(Content.byId[id].goals)do if not goal.optional then
    side=assert(A.event(side,'hero',id,goal.id,nil,nil,R,C,'side-'..id))
   end end
   check(side.heroes.hero.expeditions.active.completed,id..' can finish inside isolated run')
   eq(side.heroes.hero.deepwood.main,required,id..' preserves main progress')
  end
 end
end
-- The actual journal projection used by DeepwoodState includes hero-wide discovery.
local fog=assert(A.begin(new(),'hero','DW-01','Easy','fog-first',1,R,C))
fog=assert(R.explore(fog,'hero','DW-01',2,2))
local view=A.projection(fog.heroes.hero)
check(view.explored['DW-01']and next(view.explored['DW-01']),'saved first-run exploration is visible')
check(not fog.heroes.hero.expeditions.active.journal.explored['DW-01'],'projection does not duplicate canonical storage')
view.explored['DW-01']['1']=nil
check(fog.heroes.hero.deepwood.explored['DW-01']['1'],'client projection cannot mutate saved fog')
local fogReplay=assert(A.begin(route,'hero','DW-01','Easy','fog-replay',route.revision,R,C))
fogReplay=assert(R.explore(fogReplay,'hero','DW-01',4,4))
fogReplay=assert(R.explore(fogReplay,'hero','FV-01',4,4))
local view=A.projection(fogReplay.heroes.hero)
check(view.explored['DW-01']and next(view.explored['DW-01']),'replay discovery is visible')
check(not view.explored['FV-01'],'replay projection keeps future zones hidden')
check(R.validate(fogReplay,C),'fog projection preserves saved replay journal invariants')
print('Difficulty/enhancement: '..n..' checks passed')
