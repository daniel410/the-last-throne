local D=dofile('src/shared/Difficulty.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local Summary=dofile('src/shared/EncounterSummary.luau')
local E=dofile('src/shared/EconomyRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
check(D.version==17 and D.compatible(16) and D.compatible(15) and D.compatible(14)and D.compatible(13)and D.compatible(12)and D.compatible(11)and D.compatible(10),'expanded runs retain all previous economy rules')
for _,c in ipairs(Content.chapters)do for _,mode in ipairs(D.order)do
 local old,new=D.completion(c,mode,10),D.completion(c,mode,11)
 check(new.gold==math.floor(old.gold*4/5),'20 percent reduction rounded down: '..c.id..' '..mode)
 for key,value in pairs(old)do if key~='gold'then check(new[key]==value,'non-Gold completion reward preserved: '..key)end end
 local oldKills,newKills=Summary.mission(c,mode,1,10),Summary.mission(c,mode,1,11)
 check(oldKills.gold==newKills.gold and oldKills.xp==newKills.xp and oldKills.health==newKills.health,'kill rewards and combat unchanged')
end end
check(D.completion(Content.byId['DW-05'],'Easy',10).gold==135,'existing DW-05 completion stays 135')
check(D.completion(Content.byId['DW-05'],'Easy').gold==108,'new DW-05 completion becomes 108')
check(Summary.mission(Content.byId['DW-05'],'Easy',1,11).gold==164,'DW-05 kill Gold stays 164; total 272')
local p=assert(R.addHero(R.new(71),'hero','knight',Items))
for i=1,7 do E.story(p,{chapter='DW-0'..i,coins=0},'hero')end
check(p.wallet.diamonds==21,'seven unclaimed first clears award 21 account Diamonds')
for i=1,7 do E.story(p,{chapter='DW-0'..i,coins=0},'hero')end
check(p.wallet.diamonds==21,'same hero repeats cannot claim Diamonds twice')
E.story(p,{chapter='GW-01',coins=0},'hero');check(p.wallet.diamonds==24,'other regions now award three Diamonds')
p.wallet.diamonds=1;E.upgrade(p)
E.story(p,{chapter='DW-01',coins=0},'hero');check(p.wallet.diamonds==1,'existing spent balance and claimed reward cannot refill')
local old=assert(R.addHero(R.new(72),'hero','knight',Items));old.wallet=nil
old.heroes.hero.deepwood={coins=150,killCoins=4,clears={['DW-01']=true}}
E.upgrade(old);check(old.wallet.gold==154 and old.wallet.diamonds==2,'legacy wallet migration preserves historical two-Diamond award')
E.story(old,{chapter='DW-01',coins=0},'hero');check(old.wallet.diamonds==2,'legacy first clear cannot receive a top-up')
E.story(old,{chapter='DW-02',coins=0},'hero');check(old.wallet.diamonds==5,'legacy account receives three only for a new first clear')
check(R.validate(p,Items)and E.valid(old.wallet),'old and new wallet contracts still validate')
print('Gold/Diamond tuning: '..checks..' checks passed')
