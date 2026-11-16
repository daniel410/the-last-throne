-- Actual wallet and resume contracts, with frozen pre-change campaign totals.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,D,B,S,G=load('CampaignContent'),load('Difficulty'),load('DeepwoodEncounterBalance'),load('EncounterSummary'),load('GoldRewardTuning')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local A,P,I,H,V,Log=load('AdventureRules'),load('DeepwoodProgress'),load('ItemCatalog'),load('HeroProgression'),load('ExpeditionPresentation'),load('DeepwoodQuestLog')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function fresh(id)
 local p=assert(R.addHero(R.new(id),'hero','knight',I));p.heroes.hero.level=99;p.heroes.hero.progression=H.new(99)
 p.wallet.gold=725;p.wallet.diamonds=11;return p
end
local function begin(p,id,mode,run,version)return assert(A.begin(p,'hero',id,mode,run,p.revision,R,I,version))end
local function finish(p,c,run)
 for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   local choice=step and step.choices and (step.solution or step.choices[1].id)or g.choice and 'shared'or nil
   local nextProfile,why=A.event(p,'hero',c.id,g.id,choice,step and step.id or nil,R,I,run)
   assert(nextProfile,tostring(why)..' '..c.id..':'..g.id);p=nextProfile
  end
 end end
 return p
end
check(D.version==19 and G.rulesVersion==19,'new runs use rules19')
local expected={Easy={17685,6729},Hard={20245,10813},Insane={24323,17193},Hell={33543,31808}}
for _,mode in ipairs(D.order)do for players=1,4 do
 local first,repeatGold=0,0
 for _,c in ipairs(C.chapters)do
  local old,now=D.completion(c,mode,18),D.completion(c,mode,19)
  check(now.gold==math.floor(old.gold/2),'repeat cuts the old final amount only '..c.id)
  for key,value in pairs(old)do if key~='gold'then check(now[key]==value,'non-Gold completion unchanged '..key)end end
  local before,after=S.mission(c,mode,players,18),S.mission(c,mode,players,19)
  check(before.xp==after.xp and before.health==after.health and before.count==after.count,'combat/XP unchanged '..c.id)
  check(after.gold<=before.gold,'new kill budget never grows '..c.id)
  if not c.side then first=first+G.first(c.reward.coins)+after.gold;repeatGold=repeatGold+now.gold+after.gold end
 end
 check(first==expected[mode][1]and repeatGold==expected[mode][2],'frozen proposed campaign totals '..mode..' '..players)
end end
-- Low-value copies may pay zero; rounding must not mint one Gold per copy.
for players=1,4 do
 local gold=0;local copies=B.population(players)
 for index=1,copies do local _,amount=B.rewards({kind='Goblin',level=1,rewardCopies=copies,rewardIndex=index},'Easy',19);gold=gold+amount end
 check(gold==2,'whole budget conserved across party copies')
end
local first=C.byId['DW-01']
for _,version in ipairs({18,19})do
 local p=fresh(1900+version);p=begin(p,first.id,'Easy','first_'..version,version)
 p=finish(p,first,'first_'..version)
 local amount=version==18 and 150 or 105
 check(p.wallet.gold==725+amount,'actual first wallet delta '..version)
 check(p.heroes.hero.deepwood.coins==150,'immutable journal checksum survives reduced wallet payout')
 check(p.wallet.diamonds==14,'Diamonds unchanged')
 local loaded=R.upgrade(R.copy(p),I)
 check(R.validate(loaded,I)and loaded.wallet.gold==p.wallet.gold,'load never reprices an earned receipt')
 local last=first.goals[#first.goals];local step=last.activity and last.activity.steps and last.activity.steps[1]
 local retry=assert(A.event(p,'hero',first.id,last.id,nil,step and step.id or nil,R,I,'first_'..version))
 check(retry.wallet.gold==p.wallet.gold,'completion retry cannot pay twice')
end
-- An unfinished old campaign remains old after reconnect and mode switches.
local p=fresh(1940);p=begin(p,first.id,'Easy','old_partial',18)
local goal=first.goals[1]
p=assert(A.event(p,'hero',first.id,goal.id,nil,nil,R,I,'old_partial'))
p=R.upgrade(R.copy(p),I);p=begin(p,first.id,'Hard','new_hard')
check(p.heroes.hero.expeditions.active.balanceVersion==19,'new mode adopts new policy')
p=begin(p,first.id,'Easy','old_resumed')
check(p.heroes.hero.expeditions.active.balanceVersion==18,'unfinished old run keeps its pinned policy')
check(A.projection(p.heroes.hero).expeditionBalanceVersion==18,'field exposes the pinned budget')
check(V.missions(p.heroes.hero)[1].modes.Easy.firstGold==150,'entry preview matches resumed old award')
check(Log.reward(first,18):find('150 Gold',1,true)and Log.reward(first):find('105 Gold',1,true),'journal old/new first award matches policy')
p=finish(p,first,'old_resumed');check(p.wallet.gold==875,'resumed old run pays original amount')
p=begin(p,first.id,'Easy','new_repeat')
check(p.heroes.hero.expeditions.active.balanceVersion==19,'new replay adopts new policy after completion')
local gold=p.wallet.gold;p=finish(p,first,'new_repeat')
check(p.wallet.gold-gold==18,'new replay pays reduced repeat only')
-- Added awards (including side quests) and historical journal checksums.
for _,version in ipairs({18,19})do
 local q=fresh(1950+version)
 q=begin(q,'DW-01','Easy','deepwood_'..version,version)
 for n=1,7 do q=finish(q,C.mainChapters[n],'deepwood_'..version)end
 q=begin(q,'DW-Q1','Easy','side_'..version,version)
 local before=q.wallet.gold;q=finish(q,C.byId['DW-Q1'],'side_'..version)
 check(q.wallet.gold-before==(version==18 and 100 or 70),'added side award follows pinned budget')
 check(q.heroes.hero.completionRewardClaims['DW-Q1']==1,'original added receipt version is preserved')
 check(R.upgrade(R.copy(q),I).wallet.gold==q.wallet.gold,'added receipt prevents historic catch-up from topping up reduced award')
 -- A legacy unpaid entitlement is recovered at its earned, pre-19 amount.
 local legacy=R.copy(q);legacy.heroes.hero.completionRewardClaims['DW-Q1']=nil
 legacy.heroes.hero.expeditions.modeRewardClaims.Easy['DW-Q1']=nil
 local recovered=R.upgrade(legacy,I)
 check(recovered.wallet.gold-q.wallet.gold==100,'legacy missing receipt is recovered without repricing')
 check(R.upgrade(R.copy(recovered),I).wallet.gold==recovered.wallet.gold,'historic catch-up remains idempotent')
end
print('Gold reward tuning: '..checks..' checks passed')
