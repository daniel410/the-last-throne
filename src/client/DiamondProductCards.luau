local Players=game:GetService('Players')
local Market=game:GetService('MarketplaceService')
local Products=require(game.ReplicatedStorage.Shared.DiamondProducts)
local T=require(script.Parent.TDInventoryTheme)
local C={}
function C.create(panel,scroll,notice,refresh)
 local player=Players.LocalPlayer
 local prices,loading={},false
 local opening
 local studio=game:GetService('RunService'):IsStudio()
 local function changed()if panel.Visible then refresh()end end
 local function load()
  if loading then return end
  loading=true;prices={}
  task.spawn(function()
   for _,pack in ipairs(Products.packs)do
    if pack.productId>0 then
     local ok,info=pcall(function()return Market:GetProductInfoAsync(pack.productId,Enum.InfoType.Product)end)
     if ok and type(info)=='table'and info.IsForSale==true and type(info.PriceInRobux)=='number'and info.PriceInRobux>0 then prices[pack.id]=info.PriceInRobux end
    end
   end
   loading=false;changed()
  end)
 end
 local visible=panel:GetPropertyChangedSignal('Visible'):Connect(function()if panel.Visible then load()end end)
 local finished=Market.PromptProductPurchaseFinished:Connect(function(userId,productId,purchased)
  if userId~=player.UserId or opening~=productId then return end
  opening=nil;changed()
  notice.Text=purchased and 'Purchase submitted. Diamonds appear after your receipt is saved.'or 'Purchase cancelled.'
 end)
 panel.Destroying:Connect(function()visible:Disconnect();finished:Disconnect()end)
 local function render(wallet,saving)
  for index,pack in ipairs(Products.packs)do
   local card=T.frame(scroll,'Robux_'..pack.id,UDim2.new(),UDim2.new(1,-8,0,184));card.LayoutOrder=-10+index
   T.icon(card,'diamonds',UDim2.fromOffset(12,12),UDim2.fromOffset(62,66))
   T.label(card,'Name',pack.name,UDim2.fromOffset(82,8),UDim2.new(1,-94,0,64),16,T.color.gold)
   T.label(card,'Details','Adds '..pack.diamonds..' Diamonds to your saved RPG wallet.\nFor The Last Throne only.',UDim2.fromOffset(14,80),UDim2.new(1,-28,1,-140),12)
   local price=prices[pack.id]
   local enabled=not studio and game.GameId==Products.universeId and pack.productId>0 and price~=nil and wallet~=nil and not saving and not opening
   local caption=studio and 'LOCAL TEST' or opening==pack.productId and 'OPENING...' or price and ('BUY · '..price..' ROBUX')or loading and 'LOADING PRICE...'or 'NOT AVAILABLE'
   local button=T.button(card,'BuyRobux',caption,UDim2.new(0,14,1,-52),UDim2.new(1,-28,0,44));T.enabled(button,enabled)
   button.Activated:Connect(function()
    if not enabled or opening then return end
    opening=pack.productId;changed()
    local ok=pcall(function()Market:PromptProductPurchase(player,pack.productId)end)
    if not ok then opening=nil;changed();notice.Text='Purchase unavailable. Close and reopen the shop to try again.'end
   end)
  end
 end
 return {render=render}
end
return C
