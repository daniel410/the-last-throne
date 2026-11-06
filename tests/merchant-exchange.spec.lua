-- Exercise the real remote handler and reducer together, not just shop math.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/Enhancement.luau')
local F=dofile('src/shared/EquipmentTransactions.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local clock=0;local remotes={};local reply;local calls=0
local function signal()return {Connect=function(self,fn)self.callback=fn end}end
local fakeGame={GetService=function()return {Remotes=remotes}end,Players={PlayerRemoving=signal()}}
local env=setmetatable({game=fakeGame,script={Parent={FacilityAccess={}}},os={clock=function()clock=clock+1;return clock end},
 require=function()return {allowed=function()return true end}end,
 Instance={new=function()
  local remote={OnServerEvent=signal(),FireClient=function(_,_,data)reply=data end}
  return setmetatable(remote,{__newindex=function(t,k,v)rawset(t,k,v);if k=='Name'then remotes[v]=t end end})
 end}},{__index=_G})
local merchant=assert(loadfile('src/server/Lobby/MerchantService.luau','t',env))()
local profile=assert(R.addHero(R.new(42),'hero','knight',C));profile.wallet.gold=200;profile.wallet.diamonds=99
F.grant(profile,R,C,'hero','enhancement_gem',5,'fixture-gems')
merchant.start({inventory={snapshot=function()return R.copy(profile)end,shop=function(_,cmd)
 calls=calls+1
 local nextProfile,err=R.shop(profile,cmd,{atLobby=true},C)
 if nextProfile then profile=nextProfile end
 return err
end}})
local function send(cmd)reply=nil;remotes.ArmoryRequest.OnServerEvent.callback({},cmd);return reply end
local function command(action,id)return {action=action,requestId=id,store='blacksmith',heroId='hero',revision=profile.revision,exchangeVersion=(action==nil or action=='ExchangeGems')and E.gemPurchaseVersion or E.exchangeVersion}end
local stone=command('ExchangeStone','stone');local result=assert(send(stone))
check(not result.error and result.requestId=='stone','versioned stone exchange reaches real shop')
check(profile.wallet.gold==150 and R.quantity(profile,'hero','enhancement_gem')==0 and R.quantity(profile,'hero','magic_stone')==1,'remote consumes five gems and50 Gold and grants one stone')
result=assert(send(stone));check(not result.error and profile.wallet.gold==150 and R.quantity(profile,'hero','magic_stone')==1,'remote duplicate cannot charge twice')
result=assert(send(command('ExchangeGems','gems')));check(not result.error and profile.wallet.gold==100 and R.quantity(profile,'hero','enhancement_gem')==1,'gem purchase action is allowed at remote boundary')
result=assert(send(command('ConvertOre','ore')));check(not result.error and profile.wallet.gold==50 and R.quantity(profile,'hero','enhancement_gem')==2,'paid ore conversion accepts quote version at remote boundary')
local bad=command('ExchangeStone','bad-field');bad.price=0;local before=calls
result=assert(send(bad));check(result.error=='InvalidRequest'and result.requestId=='bad-field'and calls==before,'invalid field rejects with matching ID so client clears pending')
bad=command('ExchangeStone','bad-version');bad.exchangeVersion='1'
result=assert(send(bad));check(result.error=='InvalidRequest'and result.requestId=='bad-version'and calls==before,'malformed quote rejected before storage')
bad=command('ExchangeStone','stale');bad.exchangeVersion=0
result=assert(send(bad));check(result.error=='ExchangeChanged'and result.requestId=='stale'and profile.wallet.gold==50,'stale quote reaches authoritative price validation without debit')
profile.wallet.gold=49
result=assert(send(command('ExchangeStone','poor')));check(result.error=='NotEnoughGold'and profile.wallet.gold==49 and R.quantity(profile,'hero','enhancement_gem')==2,'remote insufficient Gold preserves gems')
check(profile.wallet.diamonds==99,'remote exchanges never consume Diamonds')
print('Merchant remote exchanges: '..checks..' checks passed')
