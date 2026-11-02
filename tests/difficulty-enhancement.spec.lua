-- User-visible progression and ownership invariants; no client-trusted rewards.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local E=dofile('src/shared/Enhancement.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local Growth=dofile('src/shared/HeroProgression.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
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
for mode,level in pairs({Hard=20,Insane=40,Hell=80})do
 hero.level=level-1;hero.progression=Growth.new(level-1)
 local ok,reason=D.allowed(hero,'DW-01',mode);check(not ok and reason=='DifficultyLevel','below '..mode..' boundary blocked')
 hero.level=level;hero.progression=Growth.new(level)
 local ok,reason=D.allowed(hero,'DW-01',mode);check(not ok and reason=='PreviousDifficulty','level alone cannot bypass previous clear')
end
p=new();p=assert(A.begin(p,'hero','DW-01','Easy','easy1',p.revision,R,C))
p=complete(p,'easy1');eq(p.heroes.hero.deepwood.main,1,'original story advances once')
local originalGold=p.wallet.gold;local originalDiamonds=p.wallet.diamonds
local g=p.heroes.hero.progression;p.heroes.hero.level=80;p.heroes.hero.progression=Growth.new(80)
for _,mode in ipairs({'Hard','Insane'})do
 p=assert(A.begin(p,'hero','DW-01',mode,mode,p.revision,R,C));p=complete(p,mode)
end
local beforeHell=p.wallet.gold;local coreBefore=R.quantity(p,'hero','forge_core')
for run=1,3 do
 local id='hell'..run;p=assert(A.begin(p,'hero','DW-01','Hell',id,p.revision,R,C))
 local wrong,reason=A.event(p,'hero','DW-01','trail_guards',nil,nil,R,C,'forged')
 check(not wrong and reason=='AdventureChanged','foreign run cannot complete objectives')
 p=complete(p,id)
 local gold=p.wallet.gold;local cores=R.quantity(p,'hero','forge_core')
 p=assert(A.event(p,'hero','DW-01',Content.byId['DW-01'].goals[#Content.byId['DW-01'].goals].id,nil,nil,R,C,id))
 eq(p.wallet.gold,gold,'same run cannot recredit Gold');eq(R.quantity(p,'hero','forge_core'),cores,'same run cannot recredit cores')
 eq(p.heroes.hero.progression.xp,0,'level80 never accumulates XP')
end
eq(p.wallet.gold-beforeHell,3*135,'three fresh Hell clears each credit repeat Gold')
eq(R.quantity(p,'hero','forge_core')-coreBefore,9,'three Hell clears credit three material rewards')
eq(p.wallet.diamonds,originalDiamonds,'replays never regrant story Diamonds')
eq(p.heroes.hero.deepwood.main,1,'replays preserve canonical story')
eq(p.heroes.hero.deepwood.coins,150,'replays preserve original story budget')
check(find(p,'equipment_cache_1'),'Hell earns repeat equipment caches')
local gold=p.wallet.gold
local c={action='OpenCache',store='blacksmith',requestId='cache-choice',heroId='hero',revision=p.revision,instanceId=find(p,'equipment_cache_1').instanceId,itemVersion=find(p,'equipment_cache_1').version,offerId='knight_weapon_fine'}
p=assert(R.shop(p,c,{atLobby=true},C));p=assert(R.shop(p,c,{atLobby=false},C));eq(p.wallet.gold,gold,'cache retry neither charges nor duplicates')
-- Forge exact costs, idempotency, immutable definitions and recovery.
p.wallet.gold=10000
local item=find(p,'knight_weapon_fine');local id=item.instanceId
for level=1,3 do
 item=p.items[id];local cmd={action='Enhance',store='blacksmith',requestId='enhance'..level,heroId='hero',revision=p.revision,instanceId=id,itemVersion=item.version}
 local oldGold=p.wallet.gold;p=assert(R.shop(p,cmd,{atLobby=true},C));eq(p.wallet.gold,oldGold-20*level*level,'exact enhancement Gold cost')
 local q=R.quantity(p,'hero','iron_ore');p=assert(R.shop(p,cmd,{atLobby=true},C));eq(R.quantity(p,'hero','iron_ore'),q,'retry consumes no extra ore')
end
eq(C.items.knight_weapon_fine.stats.power,10,'item definition never overwritten')
check(math.abs(E.stats(C.items.knight_weapon_fine,p.items[id]).power-10.9)<.00001,'three upgrades add9% to equipment only')
local old=p.wallet.gold;local cmd={action='Enhance',store='blacksmith',requestId='cap',heroId='hero',revision=p.revision,instanceId=id,itemVersion=p.items[id].version}
local no,why=R.shop(p,cmd,{atLobby=true},C);check(not no and why=='EnhancementMax','level1 equipment cannot exceed+3');eq(p.wallet.gold,old,'failed upgrade costs nothing')
local ore=R.quantity(p,'hero','iron_ore');cmd.action='Recover';cmd.requestId='recover';p=assert(R.shop(p,cmd,{atLobby=true},C));eq(p.items[id].enhancementLevel,0,'recovery preserves equipment at+0');eq(R.quantity(p,'hero','iron_ore'),ore+9,'recover floor80% of actually paid12ore')
p=assert(R.shop(p,cmd,{atLobby=true},C));eq(R.quantity(p,'hero','iron_ore'),ore+9,'recovery retry creates no extra materials')
cmd.requestId='recover-again';cmd.revision=p.revision;cmd.itemVersion=p.items[id].version;local no,why=R.shop(p,cmd,{atLobby=true},C);check(not no and why=='NoRecovery','zero ledger cannot refund twice')
check(R.validate(p,C),'forge and replay maintain ownership invariants')
-- Unknown save after the write committed retries the same operation and recovers once.
local data;local fail=false;local adapter={UpdateAsync=function(_,key,fn)local nextP=fn(R.copy(data));if nextP then data=R.copy(nextP)end;if fail then error('reply lost')end;return R.copy(nextP)end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'test-session')
assert(store:open(42));assert(store:transact(42,function(current)local fixture=R.copy(p);fixture.lease=current.lease;fixture.epoch=current.epoch;return fixture end))
item=p.items[id];cmd={action='Enhance',store='blacksmith',requestId='lost-forge',heroId='hero',revision=p.revision,instanceId=id,itemVersion=item.version}
fail=true;local result,reason=store:transact(42,function(current)return R.shop(current,cmd,{atLobby=true},C)end)
check(not result and reason=='SaveUnknown','lost save response is unknown, not rolled back')
fail=false;result=assert(store:transact(42,function(current)return R.shop(current,cmd,{atLobby=true},C)end))
eq(result.items[id].enhancementLevel,1,'unknown save recovers exactly one enhancement')
eq(result.wallet.gold,p.wallet.gold-20,'unknown save debits Gold once')
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
-- +10 works for authored high-level definitions; current stock remains capped.
local high=R.copy(C);high.items.test_80={id='test_80',name='Test Sword',category='Equipment',slot='weapon',classId='knight',stats={power=24},level=80,maxStack=1}
local full=new();full.heroes.hero.level=80;full.heroes.hero.progression=Growth.new(80);full.wallet.gold=100000
local hitem=find(full,'knight_weapon_fine');hitem.definitionId='test_80'
find(full,'iron_ore').quantity=110
full.items.cores={instanceId='cores',definitionId='forge_core',definitionVersion=1,ownerUserId=42,quantity=28,version=1,binding='account',locked=false,location={kind='bag',heroId='hero'}}
for step=1,10 do
 local item=full.items[hitem.instanceId];full=assert(R.shop(full,{action='Enhance',store='blacksmith',heroId='hero',requestId='high'..step,revision=full.revision,instanceId=item.instanceId,itemVersion=item.version},{atLobby=true},high))
end
eq(full.wallet.gold,38400,'Lv80 +10 costs61600 Gold exactly');eq(R.quantity(full,'hero','iron_ore'),0,'+10 consumes110 ore');eq(R.quantity(full,'hero','forge_core'),0,'+10 consumes28 cores')
check(math.abs(E.stats(high.items.test_80,full.items[hitem.instanceId]).power-31.2)<1e-9,'+10 adds30% once to base stats')
-- Partial material shortage and foreign locations never mutate the source account.
local q=new();q.wallet.gold=1000;local gear=find(q,'knight_weapon_fine');gear.enhancementLevel=0
local bad={action='Enhance',store='blacksmith',heroId='hero',requestId='short',revision=q.revision,instanceId=gear.instanceId,itemVersion=gear.version}
find(q,'iron_ore').locked=true;local no,why=R.shop(q,bad,{atLobby=true},C);check(not no and why=='EnhancementMaterials','locked ore cannot pay');eq(q.wallet.gold,1000,'shortage leaves Gold unchanged')
find(q,'iron_ore').locked=false;gear.location={kind='storage'};local no,why=R.shop(q,bad,{atLobby=true},C);check(not no and why=='BagOnly','storage target cannot enhance directly')
local no,why=R.shop(q,bad,{atLobby=false},C);check(not no and why=='ShopLobbyOnly','remote forge outside lobby rejected')
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
print('Difficulty/enhancement: '..n..' checks passed')
