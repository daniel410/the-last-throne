local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function fixture(studio,universe,player,result,crash)
 local market={};local shared={DiamondProducts={}}
 local env=setmetatable({game={GameId=universe,ReplicatedStorage={Shared=shared},GetService=function(_,name)
  if name=='MarketplaceService'then return market end
  if name=='Players'then return {GetPlayerByUserId=function(_,id)if id==12 then return player end end}end
  if name=='RunService'then return {IsStudio=function()return studio end}end
 end},Enum={ProductPurchaseDecision={NotProcessedYet='retry',PurchaseGranted='granted'}},require=function()return {universeId=10773575153,find=function(id)return id==8001 end}end},{__index=_G})
 local service=assert(loadfile('src/server/Lobby/DiamondProductService.luau','t',env))()
 local calls=0
 service.start({grantDiamondReceipt=function(p,r)calls=calls+1;assert(p==player and r.PlayerId==12);if crash then error('failed')end;return result end})
 return function(id)local v=market.ProcessReceipt({PlayerId=12,ProductId=id or 8001,PurchaseId='paid'});return v,calls end
end
for _,reason in ipairs({'Busy','Unavailable','SaveUnknown','AccountBusy','BalanceLimit','ReceiptConflict'})do
 local call=fixture(false,10773575153,{},reason)
 check(call()=='retry','never acknowledge '..reason)
end
check(fixture(false,10773575153,{},nil)()=='granted','only saved success acknowledges')
check(fixture(false,10773575153,{},nil,true)()=='retry','exceptions never acknowledge')
for _,call in ipairs({fixture(true,10773575153,{},nil),fixture(false,10770905829,{},nil),fixture(false,10773575153,nil,nil)})do local decision,calls=call();check(decision=='retry'and calls==0,'Studio, TD or absent player cannot grant')end
local decision,calls=fixture(false,10773575153,{},nil)(3728491648)
check(decision=='retry'and calls==0,'unknown and TD products remain unresolved')
print('diamond-product-service: '..checks..' checks passed')
