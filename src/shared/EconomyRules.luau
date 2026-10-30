local Catalog=game and require(script.Parent.EconomyCatalog) or dofile('src/shared/EconomyCatalog.luau')
local E={}
local function integer(v) return type(v)=='number' and v==v and v%1==0 and v>=0 and v<=1e12 end
function E.valid(w)
 if type(w)~='table' or w.version~=1 or not integer(w.gold) or not integer(w.diamonds) or type(w.claims)~='table' then return false end
 local n=0;for k,v in pairs(w.claims) do if type(k)~='string' or not k:match('^DW%-0[1-7]$') or v~=true then return false end;n=n+1 end
 return n<=7
end
function E.upgrade(p)
 if p.wallet then return false end
 local w={version=1,gold=0,diamonds=0,claims={}}
 for _,h in pairs(p.heroes) do
  local s=h.deepwood
  if s then
   w.gold=w.gold+s.coins+(s.killCoins or 0)
   for id in pairs(s.clears) do if id:match('^DW%-0[1-7]$') and not w.claims[id] then w.claims[id]=true;w.diamonds=w.diamonds+Catalog.storyDiamonds end end
  end
 end
 p.wallet=w;return true
end
function E.story(p,reward)
 E.upgrade(p);p.wallet.gold=p.wallet.gold+reward.coins
 if reward.chapter and reward.chapter:match('^DW%-0[1-7]$') and not p.wallet.claims[reward.chapter] then
  p.wallet.claims[reward.chapter]=true;p.wallet.diamonds=p.wallet.diamonds+Catalog.storyDiamonds
 end
end
function E.sellPrice(item)
 if type(item.sourceGrantId)=='string' and item.sourceGrantId:sub(1,8)=='starter:' then return nil end
 return Catalog.sell[item.definitionId]
end
function E.apply(p,cmd,context,items,R)
 local fingerprint=table.concat({'shop',cmd.action or '',cmd.heroId or '',cmd.offerId or '',cmd.instanceId or '',tostring(cmd.itemVersion),tostring(cmd.revision)},'|')
 local previous=p.operations[cmd.requestId]
 if previous then if previous.fingerprint~=fingerprint then return nil,'RequestConflict' end;return R.copy(p),nil,true end
 if not context.atLobby then return nil,'ShopLobbyOnly' end
 if cmd.revision~=p.revision then return nil,'Changed' end
 local hero=p.heroes[cmd.heroId];if not hero then return nil,'HeroNotOwned' end
 local n=R.copy(p);E.upgrade(n)
 if cmd.action=='Buy' then
  local offer=Catalog.offer(cmd.offerId);if not offer then return nil,'InvalidRequest' end
  if R.count(n,'bag',cmd.heroId)>=items.bagCapacity then return nil,'BagFull' end
  if n.wallet[offer.currency]<offer.price then return nil,offer.currency=='gold' and 'NotEnoughGold' or 'NotEnoughDiamonds' end
  local id='shop-'..cmd.requestId
  if n.items[id] then return nil,'Changed' end
  n.wallet[offer.currency]=n.wallet[offer.currency]-offer.price
  n.items[id]={instanceId=id,definitionId=offer.definitionId,definitionVersion=items.version,ownerUserId=p.userId,quantity=1,version=1,binding='account',locked=false,
   location={kind='bag',heroId=cmd.heroId},sourceGrantId='shop:'..cmd.requestId}
 elseif cmd.action=='Sell' then
  local item=n.items[cmd.instanceId]
  if not item or item.ownerUserId~=p.userId or item.version~=cmd.itemVersion then return nil,'Changed' end
  if item.location.kind~='bag' or item.location.heroId~=cmd.heroId or item.locked then return nil,'CannotSell' end
  local value=E.sellPrice(item);if not value then return nil,'CannotSell' end
  n.items[cmd.instanceId]=nil;n.wallet.gold=n.wallet.gold+value
 else return nil,'InvalidRequest' end
 n.revision=n.revision+1
 n.operations[cmd.requestId]={fingerprint=fingerprint,revision=n.revision}
 table.insert(n.operationOrder,cmd.requestId)
 if #n.operationOrder>96 then n.operations[table.remove(n.operationOrder,1)]=nil end
 if not R.validate(n,items) then return nil,'Incompatible' end
 return n
end
return E
