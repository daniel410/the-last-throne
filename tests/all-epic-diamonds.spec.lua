local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local Progress=dofile('src/shared/DeepwoodProgress.luau')
local A=dofile('src/shared/AdventureRules.luau')
local E=dofile('src/shared/EconomyRules.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local function events(c,run,journal)
 for _,g in ipairs(c.goals)do if (journal and Progress.required(journal(),g))or(not journal and not g.optional)then
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do run(g.id,step.choices and step.choices[1].id,step.id)end
  else run(g.id,g.choice and 'shared')end
 end end
end
local p=assert(R.addHero(R.new(955),'knight','knight',C))
for _,heroId in ipairs({'knight','mage'})do
 if heroId=='mage'then p=assert(R.addHero(p,heroId,'mage',C))end
 for i,c in ipairs(Content.mainChapters)do
  events(c,function(goal,choice,step)
   p=assert(R.story(p,heroId,c.id,goal,choice,C,step))
   check(same(assert(R.story(p,heroId,c.id,goal,choice,C,step)),p),'event retry preserves balance, receipts and revision '..c.id)
  end)
  check(p.wallet.diamonds==(heroId=='knight'and i*3 or 105+i*3),'actual first clear once per hero '..heroId..' '..c.id)
  check(p.wallet.heroClaims[heroId][c.id].Easy and R.validate(p,C),'durable receipt and valid wallet '..c.id)
  check(Log.reward(c):find('3 Diamonds per difficulty, once per hero',1,true),'quest reward describes Diamonds '..c.id)
 end
end
local complete=R.copy(p)
for _,c in ipairs(Content.mainChapters)do
 local run='repeat-'..c.id
 p=assert(A.begin(p,'knight',c.id,'Easy',run,p.revision,R,C))
 events(c,function(goal,choice,step)
  local n,why=A.event(p,'knight',c.id,goal,choice,step,R,C,run);assert(n,c.id..' '..goal..' '..tostring(step)..' '..tostring(why));p=n
  check(same(assert(A.event(p,'knight',c.id,goal,choice,step,R,C,run)),p),'expedition retry '..c.id)
 end,function()return A.projection(p.heroes.knight)end)
 check(p.wallet.diamonds==210,'new repeat expedition cannot mint Diamonds '..c.id)
end
for _,c in ipairs(Content.chapters)do if c.side then
 local before=p.wallet.diamonds;E.story(p,{chapter=c.id,coins=0},'knight')
 check(p.wallet.diamonds==before and not p.wallet.claims[c.id],'side excluded '..c.id)
 check(not Log.reward(c):find('Diamonds',1,true),'side reward does not promise Diamonds '..c.id)
end end
for _,id in ipairs({'DW-00','GW-08','FV-01extra','PR-01','XX-01'})do
 local bad=R.copy(p);bad.wallet.claims[id]=true
 check(not R.validate(bad,C),'reject unknown wallet receipt '..id)
 E.story(p,{chapter=id,coins=0},'knight');check(not p.wallet.claims[id],'unknown reward cannot mint '..id)
end
-- Real pre-change completed profile, with spent Deepwood balance and no new rights.
local old=R.copy(complete);old.wallet.diamonds=2;old.wallet.heroClaims=nil
for i=1,7 do old.wallet.claims['DW-0'..i]=true end
local migrated=R.upgrade(R.copy(old),C)
check(migrated.wallet.diamonds==191,'63 unpaid hero/story clears catch up 189 Diamonds across two heroes')
check(migrated.wallet.gold==old.wallet.gold and same(migrated.heroes,old.heroes)and same(migrated.items,old.items),'catch-up preserves Gold, XP, gear, journal and quest reward receipts')
check(same(R.upgrade(R.copy(migrated),C),migrated),'load migration idempotent including revision')
migrated.wallet.diamonds=1
check(same(R.upgrade(R.copy(migrated),C),migrated),'spent Diamonds never refill')
local noWallet=R.copy(old);noWallet.wallet=nil;E.upgrade(noWallet)
check(noWallet.wallet.diamonds==203,'walletless historic account keeps DW14 and grants all missing hero rewards')
check(E.valid(noWallet.wallet),'all 35 receipts validate')
-- UpdateAsync callback replays and lost response after durable commit.
local saved=R.copy(old);local lose=true
local store=Store.new({UpdateAsync=function(_,_,fn)
 fn(R.copy(saved));local n=fn(R.copy(saved));if n then saved=R.copy(n)end
 if lose then error('response lost after commit')end;return n
end},R,C,function()return 100 end,function()end,'diamond-session')
local result,why=store:open(955)
check(not result and why=='SaveUnknown'and saved.wallet.diamonds==191,'unknown save never doubles catch-up')
lose=false;result=assert(store:open(955))
check(result.wallet.diamonds==191 and R.validate(result,C),'same account recovers durable receipt')
check(store:close(955),'close lease')
check(assert(store:open(955)).wallet.diamonds==191,'reconnect cannot duplicate catch-up')
-- At cap, no receipt is burned; loading after spending recovers the award.
local capped=R.copy(old);capped.wallet.diamonds=1e12
E.upgrade(capped);check(capped.wallet.diamonds==1e12 and not capped.wallet.heroClaims.knight['GW-01'],'balance cap defers receipt')
capped.wallet.diamonds=0;check(E.upgrade(capped)and capped.wallet.diamonds==189,'deferred historic awards recover after spending')
print('All epic Diamonds: '..checks..' checks passed')
