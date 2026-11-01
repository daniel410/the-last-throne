local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local p=assert(R.addHero(R.new(7),'hero','knight',C));p.wallet.gold=1000;p.wallet.diamonds=100
local checks=0
local function check(value,message) checks=checks+1;assert(value,message) end
local function buy(store,id,request)
 return R.shop(p,{store=store,action='Buy',requestId=request,heroId='hero',revision=p.revision,offerId=id},{atLobby=true},C)
end
check(buy('blacksmith','knight_weapon_fine','weapon')~=nil,'blacksmith sells weapon')
check(not buy('blacksmith','health_potion','wrong1'),'blacksmith rejects potion')
local armor=buy('blacksmith','knight_shield_fine','shield')
check(armor~=nil,'blacksmith sells armor')
local armorSell={store='items',action='Sell',requestId='wrong-armor-sale',heroId='hero',revision=armor.revision,instanceId='shop-shield',itemVersion=1}
check(not R.shop(armor,armorSell,{atLobby=true},C),'item shop rejects selling armor')
check(buy('items','health_potion','potion')~=nil,'item shop sells potion')
check(not buy('items','knight_shield_fine','wrong2'),'item shop rejects armor')
check(not buy('items','knight_weapon_fine','wrong3'),'item shop rejects weapon')
check(buy('diamonds','knight_weapon_veteran_diamond','diamond')~=nil,'diamond shop sells diamond offer')
check(not buy('diamonds','knight_weapon_fine','wrong4'),'diamond shop rejects gold offer')
local stack
for _,item in pairs(p.items) do if item.definitionId=='health_potion' and item.location.kind=='bag' then stack=item;break end end
assert(stack and stack.quantity>1)
local command={store='items',action='Sell',requestId='sellpotion',heroId='hero',revision=p.revision,instanceId=stack.instanceId,itemVersion=stack.version}
local sold=assert(R.shop(p,command,{atLobby=true},C))
check(sold.items[stack.instanceId].quantity==stack.quantity-1 and sold.items[stack.instanceId].version==stack.version+1,'sale removes one from stack')
check(sold.wallet.gold==p.wallet.gold+4,'sale credits one potion price')
local repeated=assert(R.shop(sold,command,{atLobby=true},C))
check(repeated.wallet.gold==sold.wallet.gold and repeated.items[stack.instanceId].quantity==stack.quantity-1,'retry does not sell twice')
local wrong=R.copy(command);wrong.store='blacksmith';wrong.requestId='wrong-store';check(not R.shop(p,wrong,{atLobby=true},C),'blacksmith rejects selling potion')
local conflict=R.copy(command);conflict.store='blacksmith';check(not R.shop(sold,conflict,{atLobby=true},C),'store included in request fingerprint')
print('Store split: '..checks..' checks passed')
