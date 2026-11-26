local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function fixture(studio,universe,player,result,crash,leaveOnWait)
 local market={};local shared={DiamondProducts={}}
 local now=0
 local env=setmetatable({game={GameId=universe,ReplicatedStorage={Shared=shared},GetService=function(_,name)
  if name=='MarketplaceService'then return market end
  if name=='Players'then return {GetPlayerByUserId=function(_,id)if id==12 then return player end end}end
  if name=='RunService'then return {IsStudio=function()return studio end}end
 end},Enum={ProductPurchaseDecision={NotProcessedYet='retry',PurchaseGranted='granted'}},require=function()return {universeId=10773575153,find=function(id)return id==8001 end}end,
 os={clock=function()return now end},task={wait=function(seconds)assert(seconds>0);now=now+seconds;if leaveOnWait then player=nil end end}},{__index=_G})
 local service=assert(loadfile('src/server/Lobby/DiamondProductService.luau','t',env))()
 local calls=0
 service.start({grantDiamondReceipt=function(p,r)
  calls=calls+1;assert(p==player and r.PlayerId==12 and r.PurchaseId=='paid')
  if crash then error('failed')end
  if type(result)=='function'then return result(calls)end
  return result
 end})
 return function(id)local v=market.ProcessReceipt({PlayerId=12,ProductId=id or 8001,PurchaseId='paid'});return v,calls,now end
end
for _,reason in ipairs({'Unavailable','AccountBusy','BalanceLimit','ReceiptConflict'})do
 local call=fixture(false,10773575153,{},reason)
 local decision,calls,now=call()
 check(decision=='retry' and calls==1 and now==0,'defer terminal result '..reason)
end
check(fixture(false,10773575153,{},nil)()=='granted','only saved success acknowledges')
check(fixture(false,10773575153,{},nil,true)()=='retry','exceptions never acknowledge')
for _,call in ipairs({fixture(true,10773575153,{},nil),fixture(false,10770905829,{},nil),fixture(false,10773575153,nil,nil)})do local decision,calls=call();check(decision=='retry'and calls==0,'Studio, TD or absent player cannot grant')end
local decision,calls=fixture(false,10773575153,{},nil)(3728491648)
check(decision=='retry'and calls==0,'unknown and TD products remain unresolved')
local recovered,count=fixture(false,10773575153,{},function(attempt)
 return ({'Busy','Busy','SaveUnknown'})[attempt]
end)()
check(recovered=='granted' and count==4,'same callback waits for account and reconciles an unknown save')
local timeout,attempts,elapsed=fixture(false,10773575153,{},'SaveUnknown')()
check(timeout=='retry' and attempts>1 and attempts<40 and elapsed==130,'persistent storage failure defers with bounded backoff')
local departure,attempts=fixture(false,10773575153,{},'Busy',false,true)()
check(departure=='retry' and attempts==1,'disconnect leaves the receipt for a later server')
print('diamond-product-service: '..checks..' checks passed')
