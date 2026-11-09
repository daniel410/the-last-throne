local function load(n)return dofile('src/shared/'..n..'.luau')end
local Content,P,A,E,G,D,View=load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('EconomyRules'),load('HeroProgression'),load('Difficulty'),load('ExpeditionPresentation')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=load('ItemCatalog')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end
 return true
end
local function events(c,journal,run)
 for _,g in ipairs(c.goals)do if P.required(journal(),g)then
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do run(g.id,step.choices and step.choices[1].id,step.id)end
  else run(g.id,g.choice and 'shared')end
 end end
end
local p=assert(R.addHero(R.new(956),'hero','knight',C));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
local snapshots={};local paid=0
for _,mode in ipairs(D.order)do
 local run='full-'..mode
 p=assert(A.begin(p,'hero','DW-01',mode,run,p.revision,R,C))
 for _,c in ipairs(Content.mainChapters)do
  local before=p.wallet.diamonds
  events(c,function()return A.projection(p.heroes.hero)end,function(goal,choice,step)
   p=assert(A.event(p,'hero',c.id,goal,choice,step,R,C,run))
   check(same(assert(A.event(p,'hero',c.id,goal,choice,step,R,C,run)),p),'saved event retry '..mode..' '..c.id)
  end)
  paid=paid+3
  check(p.wallet.diamonds==before+3 and p.wallet.diamonds==paid,'first difficulty clear pays three '..mode..' '..c.id)
  check(mode=='Easy'and p.wallet.claims[c.id]or mode~='Easy'and p.wallet.difficultyClaims[c.id][mode],'mode receipt '..c.id)
  check(R.validate(p,C),'account validates '..mode..' '..c.id)
 end
 snapshots[mode]=R.copy(p)
 check(p.wallet.diamonds==105*(_),'35 main stories pay 105 per mode '..mode)
end
check(p.wallet.diamonds==420,'all four campaign routes pay 420')
-- Another run, same mode, no new Diamonds. Other reward streams stay live.
for _,mode in ipairs(D.order)do
 local run='repeat-'..mode;p=assert(A.begin(p,'hero','DW-01',mode,run,p.revision,R,C))
 local gold=p.wallet.gold
 events(Content.byId['DW-01'],function()return A.projection(p.heroes.hero)end,function(goal,choice,step)
  p=assert(A.event(p,'hero','DW-01',goal,choice,step,R,C,run))
 end)
 check(p.wallet.diamonds==420 and p.wallet.gold>gold,'same-mode replay pays Gold but no Diamonds '..mode)
end
-- New hero actually completes a main story, then Hard with its own progression.
p=assert(R.addHero(p,'mage','mage',C));p.heroes.mage.level=80;p.heroes.mage.progression=G.new(80)
for _,mode in ipairs({'Easy','Hard'})do
 local run='mage-'..mode;p=assert(A.begin(p,'mage','DW-01',mode,run,p.revision,R,C))
 events(Content.byId['DW-01'],function()return A.projection(p.heroes.mage)end,function(goal,choice,step)
  p=assert(A.event(p,'mage','DW-01',goal,choice,step,R,C,run))
 end)
 check(p.wallet.diamonds==420,'another hero cannot duplicate account-mode reward '..mode)
end
-- Historic mode clears restore only their missing mode, never inferred higher clears.
local old=R.copy(snapshots.Hard);old.wallet.diamonds=2;old.wallet.difficultyClaims=nil
check(R.validate(old,C),'legacy no mode ledger accepted')
local migrated=R.upgrade(R.copy(old),C)
check(migrated.wallet.diamonds==107,'historic 35 Hard clears restore 105; spent Easy remains two')
check(same(migrated.heroes,old.heroes)and same(migrated.items,old.items)and migrated.wallet.gold==old.wallet.gold,'migration preserves growth, journal, gear and Gold')
check(not migrated.wallet.difficultyClaims['DW-01'].Insane,'Hard clear does not imply Insane')
check(same(R.upgrade(R.copy(migrated),C),migrated),'migration and revision idempotent')
migrated.wallet.diamonds=0;check(same(R.upgrade(R.copy(migrated),C),migrated),'spent mode rewards never refill')
local duplicate=R.copy(old);duplicate.heroes.other=R.copy(duplicate.heroes.hero)
E.upgrade(duplicate);check(duplicate.wallet.diamonds==107,'two heroes historical Hard shares one account receipt')
local easy=R.copy(snapshots.Easy);easy.wallet.diamonds=0
check(not E.upgrade(easy)and not easy.wallet.difficultyClaims,'Easy-only account has no higher-mode reward')
-- Legacy two-Diamond receipts are not topped up.
easy.wallet.claims['DW-01']=true;check(not E.claimDifficulty(easy,'DW-01','Easy')and easy.wallet.diamonds==0,'historical Easy receipt preserved')
for _,id in ipairs({'DW-Q1','PR-01','DW-08'})do
 for _,mode in ipairs(D.order)do check(not E.claimDifficulty(easy,id,mode),'no side/invalid-mode award '..id)end
end
check(not E.claimDifficulty(easy,'DW-01','Nightmare'),'invalid difficulty cannot mint')
for _,bad in ipairs({false,{['XX-01']={Hard=true}},{['DW-01']={Easy=true}},{['DW-01']={Hard=false}},{['DW-01']={Nightmare=true}}})do
 local invalid=R.copy(easy);invalid.wallet.difficultyClaims=bad
 check(not R.validate(invalid,C),'invalid mode ledger rejected')
end
local cap=R.copy(old);cap.wallet.diamonds=1e12
check(not E.upgrade(cap)and not cap.wallet.difficultyClaims,'cap does not burn new receipt')
cap.wallet.diamonds=0;check(E.upgrade(cap)and cap.wallet.diamonds==105,'cap recovery after spending')
-- AccountStore commits receipt and balance even when acknowledgement is lost.
local saved=R.copy(old);local lose=true
local adapter={UpdateAsync=function(_,_,fn)
 fn(R.copy(saved));local n=fn(R.copy(saved));if n then saved=R.copy(n)end
 if lose then error('lost response after commit')end;return n
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'difficulty-diamonds')
local result,why=store:open(956)
check(not result and why=='SaveUnknown'and saved.wallet.diamonds==107,'lost response migration pays once')
lose=false;result=assert(store:open(956));check(result.wallet.diamonds==107,'retry recovers committed mode receipt')
check(store:close(956),'close lease');check(assert(store:open(956)).wallet.diamonds==107,'reconnect no duplicate mode award')
-- The last field event and its Diamond receipt commit in the same account write.
local pending=R.copy(snapshots.Easy)
pending=assert(A.begin(pending,'hero','DW-01','Hard','lost-hard',pending.revision,R,C))
local actions={}
for _,g in ipairs(Content.byId['DW-01'].goals)do if P.required(A.projection(pending.heroes.hero),g)then
 if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do
  table.insert(actions,{goal=g.id,choice=step.choices and step.choices[1].id,step=step.id})
 end else table.insert(actions,{goal=g.id,choice=g.choice and 'shared'})end
end end
for i=1,#actions-1 do local e=actions[i]
 pending=assert(A.event(pending,'hero','DW-01',e.goal,e.choice,e.step,R,C,'lost-hard'))
end
check(pending.wallet.diamonds==105,'unfinished Hard mission grants no Diamonds')
local durable=R.copy(pending);local drop=false
local eventStore=Store.new({UpdateAsync=function(_,_,fn)
 fn(R.copy(durable));local n=fn(R.copy(durable));if n then durable=R.copy(n)end
 if drop then error('lost final event response')end;return n
end},R,C,function()return 100 end,function()end,'hard-event')
assert(eventStore:open(956));drop=true
local last=actions[#actions]
local function complete(v)return A.event(v,'hero','DW-01',last.goal,last.choice,last.step,R,C,'lost-hard')end
local no,errorCode=eventStore:transact(956,complete)
check(not no and errorCode=='SaveUnknown'and durable.wallet.diamonds==108,'final Hard event commits exactly three on lost response')
drop=false;local recovered=assert(eventStore:transact(956,complete))
check(recovered.wallet.diamonds==108 and recovered.wallet.difficultyClaims['DW-01'].Hard,'same field event recovers committed Diamonds')
check(eventStore:close(956),'close after recovered Hard event')
check(assert(eventStore:open(956)).wallet.diamonds==108,'reconnect preserves live Hard entitlement')
for _,mission in ipairs(View.missions(p.heroes.hero))do for _,mode in ipairs(D.order)do
 check(mission.modes[mode].storyDiamonds==(Content.byId[mission.id].side and 0 or 3),'mode reward preview '..mission.id..' '..mode)
end end
print('Difficulty Diamonds: '..checks..' checks passed')
