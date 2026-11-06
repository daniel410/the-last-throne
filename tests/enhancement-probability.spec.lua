local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/Enhancement.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0
local function check(v,label)n=n+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
local function fixture()
 local p=assert(R.addHero(R.new(42),'hero','knight',C));p.wallet.gold=1000;p.wallet.diamonds=77
 F.grant(p,R,C,'hero','enhancement_gem',500,'test-gems');F.grant(p,R,C,'hero','magic_stone',500,'test-stones')
 local id;for k,item in pairs(p.items)do if item.definitionId=='knight_weapon_fine'and item.location.kind=='bag'then id=k;break end end
 return p,id
end
local function command(p,id,request)
 local item=p.items[id]
 return {action='Enhance',store='blacksmith',heroId='hero',instanceId=id,itemVersion=item.version,revision=p.revision,requestId=request,rulesVersion=E.version,expectedLevel=item.enhancementLevel or 0}
end
for target=1,9 do
 eq(E.successPercent(target),110-10*target,'success percentage')
 local count=0;for roll=0,9999 do if E.succeeds(target,roll)then count=count+1 end end
 eq(count,E.successPercent(target)*100,'all ten thousand outcomes')
 check(E.succeeds(target,E.successPercent(target)*100-1),'last successful roll')
 check(not E.succeeds(target,E.successPercent(target)*100),'first failed roll or out-of-range')
 local p,id=fixture();p.items[id].enhancementLevel=target-1
 local c=command(p,id,'boundary'..target);local gems=R.quantity(p,'hero','enhancement_gem');local stones=R.quantity(p,'hero','magic_stone')
 local cost=E.cost(C.items[p.items[id].definitionId],target)
 local result=assert(R.shop(p,c,{atLobby=true,enhancementRoll=9999},C))
 local success=target==1
 eq(result.items[id].enhancementLevel,success and target or target-1,'failure preserves level')
 eq(result.items[id].version,p.items[id].version+1,'every attempt changes item version')
 eq(R.quantity(result,'hero','enhancement_gem'),gems-cost.gems,'success and failure consume exact gems')
 eq(R.quantity(result,'hero','magic_stone'),stones-cost.stones,'success and failure consume exact stones')
 eq(result.wallet.gold,975,'success and failure each cost exactly25 Gold');eq(result.operations[c.requestId].enhancementOutcome.gold,25,'receipt records Gold consumed');eq(result.wallet.diamonds,77,'no Diamonds cost')
 eq(result.schemaVersion,2,'old deterministic writers fenced by schema')
 eq(result.operations[c.requestId].enhancementOutcome.success,success,'durable outcome')
 local ledger=result.items[id].enhancementPaidV2
 eq(ledger and ledger.gems or 0,success and cost.gems or 0,'only successful investment refundable')
 for retry=1,100 do
  local replay,err,repeated=R.shop(result,c,{atLobby=false,enhancementRoll=0},C)
  check(replay and not err and repeated,'replay returns saved result even outside lobby')
  eq(replay.revision,result.revision,'replay cannot spend or reroll')
  eq(replay.operations[c.requestId].enhancementOutcome.success,success,'replay preserves original failure')
 end
 local conflicting=R.copy(c);conflicting.expectedLevel=99
 local no,why=R.shop(result,conflicting,{atLobby=true,enhancementRoll=0},C)
 check(not no and why=='RequestConflict','same ID with changed fingerprint refused')
 local stale=R.copy(c);stale.requestId='stale'
 no,why=R.shop(result,stale,{atLobby=true,enhancementRoll=0},C)
 check(not no and why=='Changed','concurrent old revision cannot spend')
end
local p,id=fixture();local original=R.copy(p)
for _,roll in ipairs({-1,10000,.5,0/0})do
 local no,why=R.shop(p,command(p,id,'bad-roll'),{atLobby=true,enhancementRoll=roll},C)
 check(not no and why=='InvalidRequest','invalid server sample refused')
end
local c=command(p,id,'old-ui');c.rulesVersion=2
local no,why=R.shop(p,c,{atLobby=true,enhancementRoll=0},C);check(not no and why=='EnhancementChanged','old client must refresh')
c=command(p,id,'first');p=assert(R.shop(p,c,{atLobby=true,enhancementRoll=0},C))
for i=1,3 do p=assert(R.shop(p,command(p,id,'fail'..i),{atLobby=true,enhancementRoll=9999},C))end
local gems=R.quantity(p,'hero','enhancement_gem');c=command(p,id,'recover');c.action='Recover'
p=assert(R.shop(p,c,{atLobby=true},C));eq(R.quantity(p,'hero','enhancement_gem'),gems+1,'only floor80% of successful two gems returned')
eq(p.items[id].enhancementLevel,0,'recovery resets level');eq(p.wallet.gold,900,'recovery does not refund four25Gold attempt fees')
check(p.items[id].lastEnhancement.success==false,'recovery preserves last attempt history')
check(p.operations.fail1.enhancementOutcome.success==false,'recovery retains durable failure receipts')
-- Unknown save after commit and callback reexecution must not redraw or double debit.
local saved,lose;local callbacks=0
local adapter={UpdateAsync=function(_,_,fn)
 callbacks=callbacks+1;fn(R.copy(saved)) -- Discarded callback candidate, as in UpdateAsync contention.
 local nextP=fn(R.copy(saved));if nextP then saved=R.copy(nextP)end
 if lose then error('lost reply')end;return R.copy(nextP)
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'probability-session')
assert(store:open(42));assert(store:transact(42,function(current)local copy=R.copy(p);copy.lease=current.lease;copy.epoch=current.epoch;return copy end))
c=command(p,id,'unknown-first');lose=true
no,why=store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=0},C)end)
check(not no and why=='SaveUnknown','committed unknown reported as unknown')
lose=false;p=assert(store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=9999},C)end))
eq(p.wallet.gold,875,'unknown success charges Gold once');eq(p.items[id].enhancementLevel,1,'committed attempt recovered once');eq(R.quantity(p,'hero','enhancement_gem'),gems-1,'callback retries consume once')
c=command(p,id,'unknown-failure');lose=true
no,why=store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=9999},C)end)
check(not no and why=='SaveUnknown','failed attempt response loss stays unknown')
lose=false;local result=assert(store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=0},C)end))
eq(result.wallet.gold,p.wallet.gold-25,'unknown failure charges Gold once');eq(result.items[id].enhancementLevel,1,'lost failure cannot become a success')
eq(result.operations[c.requestId].enhancementOutcome.success,false,'original failure retained')
eq(R.quantity(result,'hero','enhancement_gem'),R.quantity(p,'hero','enhancement_gem')-4,'failure consumes once through save retries')
-- A historical +10 is preserved and cannot be enhanced further.
local high=R.copy(C);high.items.test80={id='test80',name='Legacy Sword',category='Equipment',slot='weapon',classId='knight',stats={power=24},level=80,maxStack=1}
p,id=fixture();p.items[id].definitionId='test80';p.items[id].enhancementLevel=10;p.items[id].enhancementPaid={ore=110,cores=28}
check(R.validate(p,high),'legacy +10 loads unchanged');check(math.abs(E.stats(high.items.test80,p.items[id]).power-31.2)<1e-9,'legacy +10 keeps original power')
no,why=R.shop(p,command(p,id,'legacy-cap'),{atLobby=true,enhancementRoll=0},high);check(not no and why=='EnhancementMax','legacy +10 cannot advance')
-- Material shortage and old evicted requests cannot spend.
p,id=fixture();for k,item in pairs(p.items)do if item.definitionId=='enhancement_gem'then p.items[k]=nil end end
no,why=R.shop(p,command(p,id,'short'),{atLobby=true,enhancementRoll=0},C);check(not no and why=='EnhancementMaterials','shortage never counts as probability failure')
p,id=fixture();c=command(p,id,'evicted');p=assert(R.shop(p,c,{atLobby=true,enhancementRoll=0},C));p.operations[c.requestId]=nil;p.operationOrder={}
no,why=R.shop(p,c,{atLobby=true,enhancementRoll=0},C);check(not no and why=='Changed','evicted old request remains stale')
check(R.validate(result,C),'final stored profile valid')
print('Enhancement probability: '..n..' checks passed (including 90000 outcome boundaries)')
