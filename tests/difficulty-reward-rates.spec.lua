local function load(n)return dofile('src/shared/'..n..'.luau')end
local D,C,E,Content,View=load('Difficulty'),load('EconomyCatalog'),load('EconomyRules'),load('CampaignContent'),load('ExpeditionPresentation')
local R=dofile('src/server/Inventory/InventoryRules.luau');local Items=load('ItemCatalog')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local gold={Easy=1,Hard=1.5,Insane=2,Hell=3};local xp={Easy=1,Hard=1.5,Insane=2,Hell=3};local diamonds={Easy=3,Hard=5,Insane=7,Hell=10}
local p=assert(R.addHero(R.new(957),'hero','knight',Items))
for _,mode in ipairs(D.order)do
 check(D.mode(mode).gold==gold[mode]and D.mode(mode).xp==xp[mode],'approved Gold/XP '..mode)
 check(C.storyDiamondsByMode[mode]==diamonds[mode],'approved Diamonds '..mode)
 check(E.claimDifficulty(p,'DW-01',mode,'hero'),'unclaimed receipt paid '..mode)
 check(not E.claimDifficulty(p,'DW-01',mode,'hero'),'repeated receipt rejected '..mode)
 local historical=R.copy(p);historical.wallet.diamonds=0
 E.upgrade(historical);check(historical.wallet.diamonds==0,'spent receipt never topped up '..mode)
 for _,c in ipairs(Content.chapters)do
  local before=D.completion(c,mode,14);local after=D.completion(c,mode,15)
  for _,key in ipairs({'xp','gems','stones','ore','cores','cache','rewardLevel','rewardBand'})do check(before[key]==after[key],'non-Gold reward preserved '..c.id..' '..key)end
  for _,boss in ipairs({false,true})do
   local h,d,l=D.stats('Goblin',10,1,boss,mode,14,c.epic)
   local nh,nd,nl=D.stats('Goblin',10,1,boss,mode,15,c.epic)
   check(h==nh and d==nd and l==nl,'combat unchanged '..mode..' '..c.id)
  end
 end
end
check(p.wallet.diamonds==25,'one story all four modes totals 25')
-- Already-paid historic three-Diamond Hard receipt stays consumed.
local old=R.copy(p);old.wallet.diamonds=3
E.upgrade(old);check(old.wallet.diamonds==3,'historical payout not replenished')
for version=1,14 do
 check(D.compatible(version),'old version remains readable '..version)
 local previous=version==1 and {Easy=1,Hard=1.5,Insane=2,Hell=3}or {Easy=1,Hard=2,Insane=3,Hell=5}
 for _,mode in ipairs(D.order)do check(D.mode(mode,version).gold==previous[mode],'pinned old Gold preserved '..version..' '..mode)end
end
local cap=R.copy(p);cap.wallet.heroClaims.hero['DW-02']=nil;cap.wallet.diamonds=1e12-9
check(not E.claimDifficulty(cap,'DW-02','Hell','hero')and not cap.wallet.heroClaims.hero['DW-02'],'ten-Diamond award respects balance ceiling without burning receipt')
cap.wallet.diamonds=1e12-10;check(E.claimDifficulty(cap,'DW-02','Hell','hero')and cap.wallet.diamonds==1e12,'exact ceiling accepts full payout')
for _,mission in ipairs(View.missions(p.heroes.hero))do for _,mode in ipairs(D.order)do check(mission.modes[mode].storyDiamonds==(Content.byId[mission.id].side and 0 or diamonds[mode]),'preview matches award '..mode)end end
print('Difficulty reward rates: '..checks..' checks passed')
