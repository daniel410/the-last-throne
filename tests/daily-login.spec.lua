local D=dofile('src/shared/DailyLogin.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function eq(a,b,m)check(a==b,m..': '..tostring(a)..' ~= '..tostring(b))end
local p=R.new(51);local start=200*86400+100;local total=0
for i,amount in ipairs({20,20,20,50,50,50,100})do
 local when=start+(i-1)*86400;local id='day'..i
 local day,ready=D.compute(p.dailyLogin,when);eq(day,i,'cycle day');check(ready,'next UTC day claimable')
 local previous=p.wallet.gold;p=assert(R.claimDaily(p,when,id));total=total+amount
 eq(p.wallet.gold,previous+amount,'correct Gold');eq(p.dailyLogin.amount,amount,'persist receipt amount');eq(p.dailyLogin.day,i,'persist day')
 check(R.validate(p,C),'new record validates')
 local duplicate,err,replay=R.claimDaily(p,when+5,id);check(duplicate and not err and replay and duplicate.wallet.gold==p.wallet.gold,'same request recovers without double credit')
 local other,e=R.claimDaily(p,when+10,'other'..i);check(not other and e=='AlreadyClaimed','different same-day request rejected')
end
eq(total,310,'seven day total')
local nextday=assert(R.claimDaily(p,start+7*86400,'cycle2'));eq(nextday.dailyLogin.day,1,'day seven wraps to one');eq(nextday.wallet.gold,total+20,'new cycle reward')
local first=assert(R.claimDaily(R.new(1),start,'first'))
local boundary=assert(R.claimDaily(first,start+48*3600,'boundary'));eq(boundary.dailyLogin.day,2,'48h inclusive')
local late=assert(R.claimDaily(first,start+48*3600+1,'late'));eq(late.dailyLogin.day,1,'over 48h resets')
local beforeMidnight=100*86400+86399;local after=assert(R.claimDaily(R.new(2),beforeMidnight,'midnight1'))
after=assert(R.claimDaily(after,beforeMidnight+1,'midnight2'));eq(after.dailyLogin.day,2,'UTC midnight permits next day')
local future,allow=D.compute(after.dailyLogin,beforeMidnight);check(not allow and future==2,'future record cannot grant again')
local malformed=R.copy(after);malformed.dailyLogin.day=8;check(not R.validate(malformed,C),'malformed persisted record fails closed')
check(not R.claimDaily(first,start,'!invalid'),'malformed request rejected')
local legacy=R.copy(first);legacy.wallet=nil;local migrated=assert(R.claimDaily(legacy,start+86400,'legacy'));eq(migrated.wallet.gold,20,'legacy wallet migrated before award')
local db,fail={},false;local clock=start
local adapter={UpdateAsync=function(_,key,callback)local result=callback(db[key]and R.copy(db[key]));if result then db[key]=R.copy(result)end;if fail then error('ack lost')end;return result end}
local store=Store.new(adapter,R,C,function()return clock end,function()end,'server-a')
assert(store:open(51));fail=true
local lost,reason=store:transact(51,function(v)return R.claimDaily(v,clock,'pending')end)
check(not lost and reason=='SaveUnknown','uncertain acknowledgement is not called success')
eq(db['account:51'].wallet.gold,20,'backend may have committed once')
fail=false;local recovered,err,repeated=store:transact(51,function(v)return R.claimDaily(v,clock,'pending')end)
check(recovered and not err and repeated,'same request recovers saved transaction')
eq(recovered.wallet.gold,20,'retry does not duplicate Gold')
local other=Store.new(adapter,R,C,function()return clock end,function()end,'server-b')
local claimed,blocked=other:open(51);check(not claimed and blocked=='AccountBusy','other server cannot bypass live account lease')
assert(store:close(51));local rejoined=assert(other:open(51));eq(rejoined.wallet.gold,20,'rejoin retains reward')
local _,same=R.claimDaily(rejoined,clock+20,'after-rejoin');eq(same,'AlreadyClaimed','reconnect cannot grant another reward')
print('Daily login: '..checks..' checks passed')
