local RS=game:GetService('ReplicatedStorage')
local Items=require(RS.Shared.ItemCatalog)
local Catalog=require(RS.Shared.EconomyCatalog)
local Economy=require(RS.Shared.EconomyRules)
local T=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Artwork=require(script.Parent.ItemArtwork)
local Impact=require(RS.Shared.EquipmentImpact)
local ItemText=require(RS.Shared.InventoryText)
local TextService=game:GetService('TextService')
local Forge=require(script.Parent.EnhancementView)
local Enhance=require(RS.Shared.Enhancement)
local AdventureText=require(RS.Shared.AdventureText)
local V={}
function V.create(parent,send,diamondOnly,store)
 store=store or "all"
 local function allowed(d,offer)return Catalog.allowed(diamondOnly and 'diamonds' or store,d,offer)end
 local function itemCategory(d)
  local id=Catalog.category(d)
  if store=='items' and id~='Potions' and id~='Accessories' then return 'Etc' end
  return id
 end
 local panel=Menu.frame(parent,diamondOnly and 'DiamondShop' or store=='items' and 'ItemShop' or 'Armory',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(950,700);cap.Parent=panel
 require(script.Parent.LobbyPanelLayout).bind(panel)
 local title=T.label(panel,'Title',diamondOnly and 'DIAMOND SHOP' or store=='blacksmith' and 'BLACKSMITH' or store=='items' and 'POTION SHOP' or 'DAWNSPIRE SUPPLIES',UDim2.fromOffset(20,12),UDim2.new(1,-88,0,28),22,T.color.gold)
 local close=T.button(panel,'Close','X',UDim2.new(1,-62,0,12),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local balance=T.label(panel,'Balance','Loading your saved wallet...',UDim2.fromOffset(20,46),UDim2.new(1,-40,0,26),15)
 local buy=T.button(panel,'BuyTab','BUY',UDim2.fromOffset(16,82),UDim2.new(.5,-20,0,44))
 local sell=T.button(panel,'SellTab','SELL',UDim2.new(.5,4,0,82),UDim2.new(.5,-20,0,44))
 if diamondOnly then buy.Visible=false;sell.Visible=false end
 local scroll=Instance.new('ScrollingFrame');scroll.Name='Offers';scroll.Position=UDim2.fromOffset(16,238);scroll.Size=UDim2.new(1,-32,1,-330);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=panel
 local layout=Instance.new('UIGridLayout');layout.CellPadding=UDim2.fromOffset(10,10);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=scroll
 local notice=T.label(panel,'Notice','',UDim2.new(0,20,1,-82),UDim2.new(1,-40,0,64),12)
 local enhance=T.button(panel,'EnhanceTab','ENHANCE',UDim2.new(.75,6,0,37),UDim2.new(.25,-22,0,44));enhance.Visible=store=='blacksmith'
 local guide=require(script.Parent.EnhancementGuide).create(panel)
 local help=T.button(panel,'EnhancementHelp',AdventureText.EnhancementHelp,UDim2.new(1,-242,0,12),UDim2.fromOffset(174,44));help.Visible=store=='blacksmith'
 if store=='blacksmith' then title.Size=UDim2.new(1,-270,0,28) end
 local categories=Instance.new('Frame');categories.Name='Categories';categories.Position=UDim2.fromOffset(16,132);categories.Size=UDim2.new(1,-32,0,96);categories.BackgroundTransparency=1;categories.Parent=panel
 local grid=Instance.new('UIGridLayout');grid.CellSize=UDim2.new(1/3,-6,0,44);grid.CellPadding=UDim2.fromOffset(6,6);grid.SortOrder=if store=='items' or store=='blacksmith' then Enum.SortOrder.LayoutOrder else Enum.SortOrder.Name;grid.Parent=categories
 local function resize()
  local short=panel.AbsoluteSize.Y<420
  help.Position=UDim2.new(1,-242,0,short and 4 or 12)
  enhance.Position=UDim2.new(.75,6,0,short and 38 or 37)
  title.Position=UDim2.fromOffset(20,short and 4 or 12)
  close.Position=UDim2.new(1,-62,0,short and 4 or 12)
  balance.Position=UDim2.fromOffset(20,short and 42 or 46)
  balance.Size=UDim2.new(1,-40,0,short and 20 or 26)
  if store=='blacksmith'and short then
   balance.Size=UDim2.new(.25,-20,0,44);buy.Position,buy.Size=UDim2.new(.25,0,0,38),UDim2.new(.25,-6,0,44);sell.Position,sell.Size=UDim2.new(.5,0,0,38),UDim2.new(.25,-6,0,44)
  elseif (store=='blacksmith' or store=='items') and short then
   balance.Size=UDim2.new(.5,-24,0,short and 20 or 26)
   buy.Position,buy.Size=UDim2.new(.5,0,0,short and 38 or 42),UDim2.new(.25,-10,0,44)
   sell.Position,sell.Size=UDim2.new(.75,0,0,short and 38 or 42),UDim2.new(.25,-16,0,44)
  elseif store=='blacksmith' or store=='items' then
   balance.Position=UDim2.fromOffset(20,37)
   balance.Size=UDim2.new(.25,-24,0,44)
   buy.Position,buy.Size=UDim2.new(.25,0,0,37),UDim2.new(.25,-6,0,44)
   sell.Position,sell.Size=UDim2.new(.5,6,0,37),UDim2.new(.25,-6,0,44)
  else
   buy.Position=UDim2.fromOffset(16,short and 66 or 82)
   sell.Position=UDim2.new(.5,4,0,short and 66 or 82)
  end
  if store=='blacksmith'then
   local tabY=short and 52 or 60
   buy.Position=UDim2.new(.25,0,0,tabY);sell.Position=UDim2.new(.5,6,0,tabY);enhance.Position=UDim2.new(.75,6,0,tabY)
   balance.Position=UDim2.fromOffset(20,tabY)
  end
  local compactStore=store=='blacksmith' or store=='items'
  local y=if store=='blacksmith'then (if short then 102 else 110)elseif compactStore then (if short then 88 else 87) else (if short then (if diamondOnly then 66 else 114) else 132)
  categories.Position=UDim2.fromOffset(16,y)
  if compactStore then categories.Size=UDim2.new(1,-32,0,44) end
  local top=y+(if panel:GetAttribute('EnhancementMode') or panel:GetAttribute('EnhancementGuideMode')then 0 elseif compactStore then 54 else 106)
  scroll.Position=UDim2.fromOffset(16,top)
  -- Reserve space only for an actual confirmation, save status, or error.
  local noticeHeight=0
  if notice.Text~='' then
   noticeHeight=TextService:GetTextSize(notice.Text,notice.TextSize,notice.Font,Vector2.new(math.max(1,panel.AbsoluteSize.X-40),1000)).Y+8
  end
  local bottom=16+noticeHeight
  notice.Visible=noticeHeight>0
  -- Desktop uses two cards across; short mobile windows have their own layout.
  local columns=panel.AbsoluteSize.X>=640 and 2 or 1
  local cardHeight=panel:GetAttribute('EnhancementMode')and 314 or short and 224 or 244
  layout.FillDirectionMaxCells=columns
  layout.CellSize=UDim2.new(1/columns,-(8+10*(columns-1))/columns,0,cardHeight)
  panel:SetAttribute('ShopLayout',short and 'MobileLandscape' or 'Desktop')
  scroll.Size=UDim2.new(1,-32,1,-top-bottom)
  guide.scroll.Position=scroll.Position;guide.scroll.Size=scroll.Size;guide.resize()
  notice.Position=UDim2.new(0,20,1,-bottom+4)
  notice.Size=UDim2.new(1,-40,0,bottom-8)
 end
 panel:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
 notice:GetPropertyChangedSignal('Text'):Connect(resize);resize()
 local state,mode,pending,category={},'Buy',nil,if store=='blacksmith' then 'Weapons' elseif store=='items' then 'Potions' else 'All'
 local transactionPending=false
 local categoryButtons={}
 local render
 local function command(action,fields)
  if pending then return end
  fields.action=action;fields.heroId=state.heroId;fields.revision=state.revision;pending=fields
  notice.Text='CONFIRM: '..fields.review..' Press the same button again to complete the trade.'
 end
 local function row(name,title,description,def,caption,fields,shortfall,currency)
  local card=T.frame(scroll,name,UDim2.new(),UDim2.new(1,-8,0,184))
  card.LayoutOrder=#scroll:GetChildren()
  if def.currencyArt then T.icon(card,'gold',UDim2.fromOffset(10,12),UDim2.fromOffset(62,66))
  else Artwork.create(card,def,UDim2.fromOffset(10,12),UDim2.fromOffset(62,66)) end
  T.label(card,'Name',title,UDim2.fromOffset(82,8),UDim2.new(1,-94,0,64),16,T.color.gold)
  T.label(card,'Details',description,UDim2.fromOffset(14,80),UDim2.new(1,-28,1,-140),12)
  local b=T.button(card,'Trade',caption,UDim2.new(0,14,1,-52),UDim2.new(1,-28,0,44))
  local insufficient=shortfall and shortfall>0
  if insufficient then
   b.Caption.Text=string.format(ItemText.ShopInsufficient,shortfall,currency)
   b:SetAttribute('InsufficientFunds',true);T.enabled(b,false)
  elseif transactionPending then T.enabled(b,false) end
  local armed=false
  b.Activated:Connect(function()
   if insufficient or transactionPending then return end
   if not state.ready or not state.heroId then notice.Text='Select a hero and wait for your account to load.';return end
   if not armed then
    pending=nil;command(mode,fields);armed=true;b.Caption.Text='CONFIRM · '..caption
   elseif pending==fields then
    local c={store=diamondOnly and 'diamonds' or store~='all' and store or nil,action=fields.action,heroId=fields.heroId,revision=fields.revision,offerId=fields.offerId,instanceId=fields.instanceId,itemVersion=fields.itemVersion}
    notice.Text='Saving transaction...';T.enabled(b,false);send(c);pending=nil
   else armed=false;b.Caption.Text=caption end
  end)
 end
 render=function(snapshot,message,saving)
  state=snapshot or state;pending=nil;categories.Visible=mode~='Enhance'and mode~='Guide';panel:SetAttribute('EnhancementMode',mode=='Enhance');panel:SetAttribute('EnhancementGuideMode',mode=='Guide');guide.scroll.Visible=mode=='Guide';scroll.Visible=mode~='Guide'
  for id,b in pairs({Buy=buy,Sell=sell,Enhance=enhance})do b.TDButtonArt.ImageColor3=mode==id and Color3.fromRGB(160,220,255)or Color3.new(1,1,1);b.Caption.Text=(mode==id and '[X] 'or '')..id:upper() end
  resize();if saving~=nil then transactionPending=saving==true end
  for id,b in pairs(categoryButtons)do b.Caption.Text=(category==id and '[X] ' or '')..b:GetAttribute('CategoryLabel') end
  local w=state.wallet;balance.Text=w and string.format('Gold: %d     Diamonds: %d',w.gold,w.diamonds) or 'Wallet unavailable. Rejoin before trading.'
  for _,child in ipairs(scroll:GetChildren()) do if child:IsA('GuiObject') then child:Destroy() end end
  local class=state.heroId and state.heroes and state.heroes[state.heroId] and state.heroes[state.heroId].baseClassId
  if mode=='Guide'then
   guide.resize()
  elseif mode=='Enhance'then
   Forge.render(scroll,state,send,transactionPending,notice)
  elseif mode=='Buy' then
   if diamondOnly and (category=='All' or category=='Gold')then
    for _,offer in ipairs(Catalog.goldOffers)do
     local title=string.format(ItemText.GoldBundle,offer.amount)
     local description=string.format(ItemText.GoldDescription,offer.amount)
     local balance=state.wallet and state.wallet.diamonds
     local shortfall=type(balance)=='number' and math.max(0,offer.price-balance)or nil
     if shortfall and shortfall>0 then description=description..string.format(ItemText.ShopShortfall,offer.price,'Diamonds',shortfall)end
     row(offer.id,title,description,{currencyArt=true},string.format('BUY · %d Diamonds',offer.price),{offerId=offer.id,review=title..' for '..offer.price..' Diamonds'},shortfall,'Diamonds')
    end
   end
   local offers=table.clone(Catalog.offers)
   table.sort(offers,function(a,b) local da,db=Items.items[a.definitionId],Items.items[b.definitionId];if (da.restore~=nil)~=(db.restore~=nil) then return da.restore~=nil end;if da.restore and db.restore then if da.restore~=db.restore then return da.restore=='health' end;return da.potionTier<db.potionTier end;local aa=da.classId==class;local bb=db.classId==class;if aa~=bb then return aa end;return a.id<b.id end)
   for _,offer in ipairs(offers) do
    local d=Items.items[offer.definitionId];if not allowed(d,offer) then continue end;if category~='All' and itemCategory(d)~=category then continue end;local hero=state.heroes and state.heroes[state.heroId]
    local description
    if d.restore then
     local owned=0;for _,item in ipairs(state.items or {}) do if item.definitionId==d.id and item.location.kind=='bag' and item.location.heroId==state.heroId then owned+=item.quantity end end
     description=string.format('Restores up to %d %s · In bag: %d\n%s',d.amount,d.restore=='health' and 'HP' or 'MP',owned,d.restore=='mana' and 'Requires an MP pool. Assign to Z / C from BAG.' or 'Delivered to your bag. Assign to Z / C from BAG.')
    else
     local fit=d.classId and string.format(ItemText.Class,Items.classes[d.classId]) or ItemText.Compatible
     description=string.format('%s · %s · Lv%d · Power +%.2f%s%s\n%s',fit,d.rarity,d.level or 1,d.stats.power or 0,d.stats.armor and ' · Armor +'..d.stats.armor or '',d.stats.health and ' · HP +'..d.stats.health or '',d.classId and hero and d.classId~=class and ItemText.OtherClassPurchase or (hero and hero.level<(d.level or 1) and 'You may buy now; equip after reaching the required level.' or 'Delivered to your bag. Equip from BAG.'))
    end
    if not d.restore then
     local selected={definitionId=d.id,location={kind='bag'}};local impact=Impact.compare(hero,state.items,selected,nil,Items)
     if impact and d.slot~='accessory' then description=description..'\n'..Impact.summary(impact) end
    end
    if store=='blacksmith' and Catalog.diamondGear(d) then description=description..'\n'..ItemText.ForgeDiamondOnly end
    local currency=offer.currency=='gold' and 'Gold' or 'Diamonds'
    local amount=state.wallet and state.wallet[offer.currency]
    local shortfall=type(amount)=='number' and math.max(0,offer.price-amount) or nil
    if shortfall and shortfall>0 then description=description..string.format(ItemText.ShopShortfall,offer.price,currency,shortfall) end
    local caption=string.format('BUY · %d %s',offer.price,currency)
    row(offer.id,d.name,description,d,caption,{offerId=offer.id,review=d.name..' for '..offer.price..' '..offer.currency},shortfall,currency)
   end
   local hasOffers=false
   for _,child in ipairs(scroll:GetChildren()) do if child:IsA('GuiObject') then hasOffers=true;break end end
   if not hasOffers then T.label(scroll,'Empty','No items available in this category.',UDim2.new(),UDim2.new(1,-16,0,60),14) end
  else
   local n=0
   for _,item in ipairs(state.items or {}) do
    local price=Economy.sellPrice(item)
    if price and allowed(Items.items[item.definitionId]) and (category=='All' or itemCategory(Items.items[item.definitionId])==category) and item.location.kind=='bag' and item.location.heroId==state.heroId and not item.locked and (item.enhancementLevel or 0)==0 then
     n+=1;local d=Items.items[item.definitionId]
     local fit=d.restore and ItemText.AllClasses or d.classId and string.format(ItemText.Class,Items.classes[d.classId]) or ItemText.Compatible
     row(item.instanceId,d.name,fit..'\nSell one item permanently. You receive Gold; Diamonds are not refunded.',d,'SELL · '..price..' Gold',{instanceId=item.instanceId,itemVersion=item.version,review=d.name..' for '..price..' Gold'})
    end
   end
   if n==0 then T.label(scroll,'Empty','Nothing to sell in this category. Unequip and unlock purchased gear in BAG. Starter gear cannot be sold.',UDim2.new(),UDim2.new(1,-16,0,100),14) end
  end
  notice.Text=message or ''
 end
 local function selectCategory(id)
  if store=='blacksmith' and id~='Weapons' and id~='Armor' and id~='Accessories' then return end
  if store=='items' then
   if id=='Potions' or id=='Accessories' or id=='Etc' then category=id;render() end
   return
  end
  if diamondOnly and id=='Gold'then category=id;render();return end
  for _,entry in ipairs(Catalog.categories)do if entry.id==id then category=id;render();return end end
 end
 local displayedCategories=if store=='items' then {{id='Potions',label='POTIONS'},{id='Accessories',label='ACCESSORIES'},{id='Etc',label='ETC'}} else Catalog.categories
 for index,entry in ipairs(displayedCategories)do
  if store=='blacksmith' and entry.id~='Weapons' and entry.id~='Armor' and entry.id~='Accessories' then continue end
  local b=T.button(categories,'Category_'..entry.id,entry.label,UDim2.new(),UDim2.new());b.LayoutOrder=index;b.Caption.TextSize=11;b:SetAttribute('CategoryLabel',entry.label);categoryButtons[entry.id]=b;b.Activated:Connect(function()selectCategory(entry.id)end)end
 if diamondOnly then
  local b=T.button(categories,'Category_Gold',ItemText.GoldCategory,UDim2.new(),UDim2.new());b.Caption.TextSize=11;b:SetAttribute('CategoryLabel',ItemText.GoldCategory);categoryButtons.Gold=b;b.Activated:Connect(function()selectCategory('Gold')end)
 end
 help.Activated:Connect(function()mode=mode=='Guide'and 'Enhance'or 'Guide';render()end)
 enhance.Activated:Connect(function()mode='Enhance';render()end)
 buy.Activated:Connect(function() mode='Buy';render() end);sell.Activated:Connect(function() mode='Sell';render() end)
 return {panel=panel,render=render,notice=notice,selectCategory=selectCategory,setMode=function(value) if value=="Buy" or value=="Sell" or (value=="Enhance" or value=="Guide") and store=="blacksmith" then mode=value;render() end end}
end
return V
