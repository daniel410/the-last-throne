local RS=game:GetService('ReplicatedStorage')
local Items=require(RS.Shared.ItemCatalog)
local Catalog=require(RS.Shared.EconomyCatalog)
local Economy=require(RS.Shared.EconomyRules)
local T=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Artwork=require(script.Parent.ItemArtwork)
local V={}
function V.create(parent,send)
 local panel=Menu.frame(parent,'Armory',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(950,700);cap.Parent=panel
 T.label(panel,'Title','DAWNSPIRE ARMORY',UDim2.fromOffset(20,12),UDim2.new(1,-88,0,28),22,T.color.gold)
 local close=T.button(panel,'Close','X',UDim2.new(1,-62,0,12),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local balance=T.label(panel,'Balance','Loading your saved wallet...',UDim2.fromOffset(20,46),UDim2.new(1,-40,0,26),15)
 local buy=T.button(panel,'BuyTab','BUY',UDim2.fromOffset(16,82),UDim2.new(.5,-20,0,44))
 local sell=T.button(panel,'SellTab','SELL',UDim2.new(.5,4,0,82),UDim2.new(.5,-20,0,44))
 local scroll=Instance.new('ScrollingFrame');scroll.Name='Offers';scroll.Position=UDim2.fromOffset(16,136);scroll.Size=UDim2.new(1,-32,1,-228);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,10);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=scroll
 local notice=T.label(panel,'Notice','Choose a weapon to review its price.',UDim2.new(0,20,1,-82),UDim2.new(1,-40,0,64),12)
 local state,mode,pending={},'Buy',nil
 local render
 local function command(action,fields)
  if pending then return end
  fields.action=action;fields.heroId=state.heroId;fields.revision=state.revision;pending=fields
  notice.Text='CONFIRM: '..fields.review..' Press the same button again to complete the trade.'
 end
 local function row(name,title,description,def,caption,fields)
  local card=T.frame(scroll,name,UDim2.new(),UDim2.new(1,-8,0,144))
  Artwork.create(card,def,UDim2.fromOffset(10,12),UDim2.fromOffset(62,66))
  T.label(card,'Name',title,UDim2.fromOffset(82,8),UDim2.new(1,-94,0,28),16,T.color.gold)
  T.label(card,'Details',description,UDim2.fromOffset(82,38),UDim2.new(1,-94,0,52),12)
  local b=T.button(card,'Trade',caption,UDim2.new(0,14,1,-52),UDim2.new(1,-28,0,44))
  local armed=false
  b.Activated:Connect(function()
   if not state.ready or not state.heroId then notice.Text='Select a hero and wait for your account to load.';return end
   if not armed then
    pending=nil;command(mode,fields);armed=true;b.Caption.Text='CONFIRM · '..caption
   elseif pending==fields then
    local c={action=fields.action,heroId=fields.heroId,revision=fields.revision,offerId=fields.offerId,instanceId=fields.instanceId,itemVersion=fields.itemVersion}
    notice.Text='Saving transaction...';T.enabled(b,false);send(c);pending=nil
   else armed=false;b.Caption.Text=caption end
  end)
 end
 render=function(snapshot,message)
  state=snapshot or state;pending=nil
  local w=state.wallet;balance.Text=w and string.format('Gold: %d     Diamonds: %d',w.gold,w.diamonds) or 'Wallet unavailable. Rejoin before trading.'
  for _,child in ipairs(scroll:GetChildren()) do if child:IsA('GuiObject') then child:Destroy() end end
  local class=state.heroId and state.heroes and state.heroes[state.heroId] and state.heroes[state.heroId].baseClassId
  if mode=='Buy' then
   local offers=table.clone(Catalog.offers)
   table.sort(offers,function(a,b) local aa=Items.items[a.definitionId].classId==class;local bb=Items.items[b.definitionId].classId==class;if aa~=bb then return aa end;return a.id<b.id end)
   for _,offer in ipairs(offers) do
    local d=Items.items[offer.definitionId];local hero=state.heroes and state.heroes[state.heroId]
    local fit=d.classId==class and 'Your class' or Items.classes[d.classId]
    local description=string.format('%s · Lv%d · Power +%d%s\n%s',fit,d.level or 1,d.stats.power or 0,d.stats.armor and ' · Armor +'..d.stats.armor or '',hero and hero.level<(d.level or 1) and 'You may buy now; equip after reaching the required level.' or 'Delivered to your bag. Equip from BAG.')
    local caption=string.format('BUY · %d %s',offer.price,offer.currency=='gold' and 'Gold' or 'Diamonds')
    row(offer.id,d.name,description,d,caption,{offerId=offer.id,review=d.name..' for '..offer.price..' '..offer.currency})
   end
  else
   local n=0
   for _,item in ipairs(state.items or {}) do
    local price=Economy.sellPrice(item)
    if price and item.location.kind=='bag' and item.location.heroId==state.heroId and not item.locked then
     n+=1;local d=Items.items[item.definitionId]
     row(item.instanceId,d.name,'Sell one weapon permanently. You receive Gold; Diamonds are not refunded.',d,'SELL · '..price..' Gold',{instanceId=item.instanceId,itemVersion=item.version,review=d.name..' for '..price..' Gold'})
    end
   end
   if n==0 then T.label(scroll,'Empty','No eligible weapons. Unequip and unlock a weapon in BAG. Starter equipment cannot be sold.',UDim2.new(),UDim2.new(1,-16,0,100),14) end
  end
  notice.Text=message or 'Prices are shown before confirmation. Each first main-story clear awards 2 Diamonds per account.'
 end
 buy.Activated:Connect(function() mode='Buy';render() end);sell.Activated:Connect(function() mode='Sell';render() end)
 return {panel=panel,render=render,notice=notice}
end
return V
