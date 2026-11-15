local Products=dofile('src/shared/DiamondProducts.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function signal()return {Connect=function(self,fn)self.callback=fn;return {Disconnect=function()end}end}end
local function fixture(info,studio)
 local visible,finished=signal(),signal()
 local panel={Visible=true,Destroying=signal(),GetPropertyChangedSignal=function()return visible end}
 local scroll={};local prompts=0
 local function node(parent,name)local n={};parent[name]=n;return n end
 local theme={color={gold=1},frame=function(p,n)return node(p,n)end,icon=function(p)return node(p,'Icon')end,label=function(p,n,t)local v=node(p,n);v.Text=t;return v end,button=function(p,n,t)local v=node(p,n);v.Caption={Text=t};v.Activated=signal();return v end,enabled=function(b,v)b.Active=v end}
 local market={PromptProductPurchaseFinished=finished,GetProductInfoAsync=function(_,id)if info==false then error('unavailable')end;return info end,PromptProductPurchase=function()prompts=prompts+1 end}
 local shared={DiamondProducts={}};local parent={TDInventoryTheme={}}
 local env=setmetatable({game={GameId=Products.universeId,ReplicatedStorage={Shared=shared},GetService=function(_,n)
  if n=='Players'then return {LocalPlayer={UserId=12}}end
  if n=='MarketplaceService'then return market end
  if n=='RunService'then return {IsStudio=function()return studio end}end
 end},script={Parent=parent},require=function(m)if m==shared.DiamondProducts then return Products end;return theme end,
 Enum={InfoType={Product=1}},task={spawn=function(fn)fn()end},UDim2={new=function()end,fromOffset=function()end},Vector2={zero='zero'}},{__index=_G})
 local module=assert(loadfile('src/client/DiamondProductCards.luau','t',env))()
 local view=module.create(panel,scroll,{},function()end)
 visible.callback();view.render({diamonds=0},false)
 return scroll,finished,function()return prompts end
end
local scroll,finished,prompts=fixture({IsForSale=true,PriceInRobux=17,IconImageAssetId=123456},false)
for _,pack in ipairs(Products.packs)do
 local card=scroll['Robux_'..pack.id]
 check(card.BuyRobux.Active and card.BuyRobux.Caption.Text=='BUY · 17 ROBUX','platform price replaces reference price')
 check(card.Icon.Image=='rbxassetid://123456'and card.Icon.ImageRectSize=='zero','product icon replaces atlas crop')
end
scroll.Robux_diamonds_100.BuyRobux.Activated.callback()
check(prompts()==1,'explicit click opens one prompt')
scroll.Robux_diamonds_500.BuyRobux.Activated.callback()
check(prompts()==1,'second click blocked while prompt open')
finished.callback(12,3731586526,false)
scroll.Robux_diamonds_500.BuyRobux.Activated.callback()
check(prompts()==2,'cancelled prompt releases guard')
for _,info in ipairs({false,{IsForSale=false,PriceInRobux=49},{IsForSale=true}})do
 local cards=fixture(info,false)
 check(not cards.Robux_diamonds_100.BuyRobux.Active,'failed, off-sale or missing price disables purchase')
end
local cards=fixture({IsForSale=true,PriceInRobux=49},true)
check(not cards.Robux_diamonds_100.BuyRobux.Active and cards.Robux_diamonds_100.BuyRobux.Caption.Text=='LOCAL TEST','Studio never opens paid prompt')
print('diamond-product-cards: '..checks..' checks passed')
