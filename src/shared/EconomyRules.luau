local Catalog=game and require(script.Parent.EconomyCatalog) or dofile('src/shared/EconomyCatalog.luau')
local E={}
-- Historical clears predate the new first-clear award; migration preserves earnings.
local legacyStoryDiamonds=2
local function integer(v) return type(v)=='number' and v==v and v%1==0 and v>=0 and v<=1e12 end
function E.valid(w)
 if type(w)~='table' or w.version~=1 or not integer(w.gold) or not integer(w.diamonds) or type(w.claims)~='table' then return false end
 local n=0;for k,v in pairs(w.claims) do if type(k)~='string' or not Catalog.storyDiamondIds[k] or v~=true then return false end;n=n+1 end
 if n>35 then return false end
 if w.difficultyClaims~=nil then
  if type(w.difficultyClaims)~='table'then return false end
  for id,modes in pairs(w.difficultyClaims)do
   if not Catalog.storyDiamondIds[id]or type(modes)~='table'then return false end
   for mode,claimed in pairs(modes)do
    if not Catalog.storyDiamondModes[mode]or claimed~=true then return false end
   end
  end
 end
 if w.heroClaims~=nil then
  if type(w.heroClaims)~='table'then return false end
  for heroId,stories in pairs(w.heroClaims)do
   if type(heroId)~='string'or heroId==''or type(stories)~='table'then return false end
   for id,modes in pairs(stories)do
    if not Catalog.storyDiamondIds[id]or type(modes)~='table'then return false end
    for mode,claimed in pairs(modes)do
     if (mode~='Easy'and not Catalog.storyDiamondModes[mode])or claimed~=true then return false end
    end
   end
  end
 end
 return true
end
-- The shared account wallet stores permanent receipts keyed by hero/story/mode.
local function mark(w,heroId,id,mode)
 w.heroClaims[heroId]=w.heroClaims[heroId]or {}
 local stories=w.heroClaims[heroId];stories[id]=stories[id]or {};stories[id][mode]=true
end
local function claim(p,heroId,id,mode)
 if not p.heroes[heroId]or not Catalog.storyDiamondIds[id]
  or(mode~='Easy'and not Catalog.storyDiamondModes[mode])then return false end
 local stories=p.wallet.heroClaims[heroId]
 if stories and stories[id]and stories[id][mode]then return false end
 local amount=Catalog.storyDiamondsByMode[mode]
 if p.wallet.diamonds+amount>1e12 then return false end
 mark(p.wallet,heroId,id,mode);p.wallet.diamonds=p.wallet.diamonds+amount
 return true
end
local function completed(hero,id,mode)
 if mode=='Easy'and hero.deepwood and hero.deepwood.clears[id]then return true end
 local modes=hero.expeditions and hero.expeditions.clears[id]
 return modes and modes[mode]==true
end
function E.upgrade(p,pendingHeroId,pendingChapter)
 local changed=false
 if not p.wallet then
  p.wallet={version=1,gold=0,diamonds=0,claims={}};changed=true
  for _,h in pairs(p.heroes)do
   local s=h.deepwood
   if s then
    p.wallet.gold=p.wallet.gold+s.coins+(s.killCoins or 0)
    for id in pairs(s.clears)do
     if id:match('^DW%-0[1-7]$')and not p.wallet.claims[id]then
      p.wallet.claims[id]=true;p.wallet.diamonds=p.wallet.diamonds+legacyStoryDiamonds
     end
    end
   end
  end
 end
 local heroIds={};for id in pairs(p.heroes)do table.insert(heroIds,id)end;table.sort(heroIds)
 if not p.wallet.heroClaims then
  p.wallet.heroClaims={};changed=true
  -- Old receipts omitted the hero. Bind each already-paid award to one completed
  -- hero in stable ID order, without minting it again or topping up historic DW2.
  local function inherit(id,mode)
   for _,heroId in ipairs(heroIds)do
    if completed(p.heroes[heroId],id,mode)then mark(p.wallet,heroId,id,mode);break end
   end
  end
  for id in pairs(p.wallet.claims)do inherit(id,'Easy')end
  for id,modes in pairs(p.wallet.difficultyClaims or {})do
   for mode in pairs(modes)do inherit(id,mode)end
  end
 end
 for _,heroId in ipairs(heroIds)do
  local h=p.heroes[heroId]
  for id in pairs(h.deepwood and h.deepwood.clears or {})do
   -- A story journal can now be first completed on Hard. Only infer Easy
   -- for legacy story-only clears or an explicitly completed Easy expedition.
   local modes=h.expeditions and h.expeditions.clears[id]
   if not(heroId==pendingHeroId and id==pendingChapter)and (not modes or modes.Easy)and claim(p,heroId,id,'Easy')then changed=true end
  end
  for id,modes in pairs(h.expeditions and h.expeditions.clears or {})do
   for mode,cleared in pairs(modes)do
    if cleared and claim(p,heroId,id,mode)then changed=true end
   end
  end
 end
 return changed
end
function E.claimDifficulty(p,id,mode,heroId)
 if not p.heroes[heroId]then return false end
 if not p.wallet or not p.wallet.heroClaims then E.upgrade(p)end
 return claim(p,heroId,id,mode)
end
function E.story(p,reward,heroId,difficultyId)
 E.upgrade(p,heroId,difficultyId and difficultyId~='Easy' and reward.chapter or nil);p.wallet.gold=p.wallet.gold+reward.coins
 E.claimDifficulty(p,reward.chapter,difficultyId or 'Easy',heroId)
end
function E.sellPrice(item)
 if type(item.sourceGrantId)=='string' and item.sourceGrantId:sub(1,8)=='starter:' and not item.definitionId:match('^%a+_potion') then return nil end
 return Catalog.sell[item.definitionId]
end
function E.apply(p,cmd,context,items,R)
 local fingerprint=table.concat({'shop',cmd.action or '',cmd.heroId or '',cmd.offerId or '',cmd.instanceId or '',tostring(cmd.itemVersion),tostring(cmd.revision)},'|')
 if cmd.store~=nil then fingerprint=fingerprint..'|'..tostring(cmd.store) end
 local previous=p.operations[cmd.requestId]
 if previous then if previous.fingerprint~=fingerprint then return nil,'RequestConflict' end;return R.copy(p),nil,true end
 if not context.atLobby then return nil,'ShopLobbyOnly' end
 if cmd.store~=nil and cmd.store~='blacksmith' and cmd.store~='items' and cmd.store~='diamonds' then return nil,'InvalidRequest' end
 local function allowed(def,offer)return Catalog.allowed(cmd.store,def,offer)end
 if cmd.revision~=p.revision then return nil,'Changed' end
 local hero=p.heroes[cmd.heroId];if not hero then return nil,'HeroNotOwned' end
 local n=R.copy(p);E.upgrade(n)
 if cmd.action=='Buy' then
  local exchange=Catalog.goldOffer(cmd.offerId)
  if exchange then
   if cmd.store~='diamonds' then return nil,'InvalidRequest' end
   if n.wallet.diamonds<exchange.price then return nil,'NotEnoughDiamonds' end
   if n.wallet.gold+exchange.amount>1e12 then return nil,'BalanceLimit' end
   n.wallet.diamonds=n.wallet.diamonds-exchange.price;n.wallet.gold=n.wallet.gold+exchange.amount
  else
  local offer=Catalog.offer(cmd.offerId);if not offer then return nil,'InvalidRequest' end
  local definition=items.items[offer.definitionId];if not definition or not allowed(definition,offer) then return nil,'InvalidRequest' end
  local stack
  if definition.restore or definition.reset then
   for _,item in pairs(n.items) do
    if item.definitionId==offer.definitionId and item.location.kind=='bag' and item.location.heroId==cmd.heroId
     and not item.locked and item.quantity<definition.maxStack and (not stack or item.instanceId<stack.instanceId) then stack=item end
   end
  end
  if not stack and R.count(n,'bag',cmd.heroId)>=items.bagCapacity then return nil,'BagFull' end
  if n.wallet[offer.currency]<offer.price then return nil,offer.currency=='gold' and 'NotEnoughGold' or 'NotEnoughDiamonds' end
  local id='shop-'..cmd.requestId
  if n.items[id] then return nil,'Changed' end
  n.wallet[offer.currency]=n.wallet[offer.currency]-offer.price
  if stack then stack.quantity=stack.quantity+1;stack.version=stack.version+1
  else n.items[id]={instanceId=id,definitionId=offer.definitionId,definitionVersion=items.version,ownerUserId=p.userId,quantity=1,version=1,binding='account',locked=false,
   location={kind='bag',heroId=cmd.heroId},sourceGrantId='shop:'..cmd.requestId} end
  end
 elseif cmd.action=='Sell' then
  local item=n.items[cmd.instanceId]
  if not item or item.ownerUserId~=p.userId or item.version~=cmd.itemVersion then return nil,'Changed' end
  if item.location.kind~='bag' or item.location.heroId~=cmd.heroId or item.locked then return nil,'CannotSell' end
  local definition=items.items[item.definitionId]
  local value=E.sellPrice(item);if not definition or not allowed(definition,nil) or not value then return nil,'CannotSell' end
  if item.quantity>1 then item.quantity=item.quantity-1;item.version=item.version+1 else n.items[cmd.instanceId]=nil end
  n.wallet.gold=n.wallet.gold+value
 else return nil,'InvalidRequest' end
 n.revision=n.revision+1
 n.operations[cmd.requestId]={fingerprint=fingerprint,revision=n.revision}
 table.insert(n.operationOrder,cmd.requestId)
 if #n.operationOrder>96 then n.operations[table.remove(n.operationOrder,1)]=nil end
 if not R.validate(n,items) then return nil,'Incompatible' end
 return n
end
return E
