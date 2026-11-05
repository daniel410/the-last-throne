local E=game and require(script.Parent.Enhancement)or dofile('src/shared/Enhancement.luau')
local F={}
-- Caller supplies deterministic IDs and commits this mutation in its account write.
function F.grant(p,R,C,heroId,definitionId,amount,id,pendingOnly,bagOnly)
 local def=C.items[definitionId];if not def or amount<=0 then return true end
 if def.retired then return false end
 local ids={};for key in pairs(p.items)do table.insert(ids,key)end;table.sort(ids)
 for _,key in ipairs(ids)do local item=p.items[key]
  if not item.locked and item.binding=='account' and item.definitionId==definitionId and item.quantity<def.maxStack
   and (not bagOnly and item.location.kind=='pending' or not pendingOnly and item.location.kind=='bag'and item.location.heroId==heroId)then
   local n=math.min(amount,def.maxStack-item.quantity);item.quantity=item.quantity+n;item.version=item.version+1;amount=amount-n
   if amount==0 then return true end
  end
 end
 local seq=0
 while amount>0 do
  if bagOnly and R.count(p,'bag',heroId)>=C.bagCapacity then return false end
  seq=seq+1;local instanceId=id..'-'..seq
  if p.items[instanceId]then error('Deterministic grant ID collision')end
  local q=math.min(amount,def.maxStack)
  p.items[instanceId]={instanceId=instanceId,definitionId=definitionId,definitionVersion=C.version,ownerUserId=p.userId,quantity=q,version=1,binding='account',locked=false,
   location=not pendingOnly and R.count(p,'bag',heroId)<C.bagCapacity and {kind='bag',heroId=heroId}or {kind='pending'},sourceGrantId=id}
  amount=amount-q
 end
 return true
end
function F.consume(p,heroId,id,quantity)
 local ids={};local total=0
 for key,item in pairs(p.items)do if item.definitionId==id and not item.locked and item.location.kind=='bag'and item.location.heroId==heroId then total=total+item.quantity;table.insert(ids,key)end end
 if total<quantity then return false end
 table.sort(ids)
 for _,key in ipairs(ids)do
  if quantity<=0 then break end
  local item=p.items[key];local used=math.min(item.quantity,quantity);item.quantity=item.quantity-used;item.version=item.version+1;quantity=quantity-used
  if item.quantity==0 then p.items[key]=nil end
 end
 return true
end
function F.apply(profile,c,context,C,R)
 if type(c.requestId)~='string'or #c.requestId==0 or #c.requestId>64 or not c.requestId:match('^[%w_-]+$')then return nil,'InvalidRequest'end
 local fingerprint=table.concat({'forge',c.action or '',c.heroId or '',c.instanceId or '',c.offerId or '',tostring(c.itemVersion),tostring(c.revision),c.store or ''},'|')
 if c.rulesVersion~=nil or c.expectedLevel~=nil then fingerprint=fingerprint..'|'..tostring(c.rulesVersion)..'|'..tostring(c.expectedLevel)end
 local previous=profile.operations[c.requestId]
 if previous then if previous.fingerprint~=fingerprint then return nil,'RequestConflict'end;return R.copy(profile),nil,true end
 if not context.atLobby or c.store~='blacksmith'then return nil,'ShopLobbyOnly'end
 if c.revision~=profile.revision then return nil,'Changed'end
 local hero=profile.heroes[c.heroId];if not hero then return nil,'HeroNotOwned'end
 local outcome
 local p=R.copy(profile);local item=p.items[c.instanceId];local def=item and C.items[item.definitionId]
 if c.action=='ExchangeCore'then
  if p.wallet.gold<50 then return nil,'NotEnoughGold'end
  if not F.consume(p,c.heroId,'iron_ore',5)then return nil,'EnhancementMaterials'end
  p.wallet.gold=p.wallet.gold-50;F.grant(p,R,C,c.heroId,'forge_core',1,'forge-'..c.requestId)
 elseif c.action=='ExchangeStone'then
  if p.wallet.gold<50 then return nil,'NotEnoughGold'end
  if not F.consume(p,c.heroId,'enhancement_gem',5)then return nil,'EnhancementMaterials'end
  p.wallet.gold=p.wallet.gold-50;F.grant(p,R,C,c.heroId,'magic_stone',1,'stone-'..c.requestId)
 elseif c.action=='ConvertOre'or c.action=='ConvertCore'then
  local source=c.action=='ConvertOre'and 'iron_ore'or 'forge_core'
  local target=c.action=='ConvertOre'and 'enhancement_gem'or 'magic_stone'
  if not F.consume(p,c.heroId,source,1)then return nil,'EnhancementMaterials'end
  F.grant(p,R,C,c.heroId,target,1,'convert-'..c.requestId)
 elseif c.action=='Enhance'or c.action=='Recover'or c.action=='OpenCache'then
  if not item or item.version~=c.itemVersion or item.ownerUserId~=p.userId then return nil,'Changed'end
  if item.locked then return nil,'ItemLocked'end
  if item.location.heroId~=c.heroId or (item.location.kind~='bag'and item.location.kind~='equipped')then return nil,'BagOnly'end
  if c.action=='OpenCache'then
   local chosen=C.items[c.offerId]
   if chosen and chosen.retired then return nil,'RetiredEquipment'end
   if not def.cacheTier or not chosen or not chosen.slot or chosen.cacheEligible==false or (chosen.level or 1)~=def.cacheTier or chosen.classId and chosen.classId~=hero.baseClassId or not E.supported(chosen)then return nil,'CacheChoice'end
   item.quantity=item.quantity-1;item.version=item.version+1;if item.quantity==0 then p.items[c.instanceId]=nil end
   F.grant(p,R,C,c.heroId,chosen.id,1,'cache-'..c.requestId)
  else
   if not E.supported(def)then return nil,'EnhancementUnsupported'end
   local level=item.enhancementLevel or 0
   if c.action=='Enhance'then
    if level>=E.cap(def)then return nil,'EnhancementMax'end
    if c.rulesVersion~=E.version or c.expectedLevel~=level then return nil,'EnhancementChanged'end
    local roll=context.enhancementRoll
    if type(roll)~='number'or roll%1~=0 or roll<0 or roll>=10000 then return nil,'InvalidRequest'end
    local cost=E.cost(def,level+1)
    if p.wallet.gold<cost.gold then return nil,'NotEnoughGold'end
    if not F.consume(p,c.heroId,'enhancement_gem',cost.gems)or not F.consume(p,c.heroId,'magic_stone',cost.stones)then return nil,'EnhancementMaterials'end
    local success=E.succeeds(level+1,roll)
    p.schemaVersion=2 -- Old deterministic writers must reject this account.
    p.wallet.gold=p.wallet.gold-cost.gold;item.enhancementLevel=level
    if success then
     item.enhancementLevel=level+1
     local paid=item.enhancementPaidV2 or {gems=0,stones=0};item.enhancementPaidV2={gems=paid.gems+cost.gems,stones=paid.stones+cost.stones}
    end
    outcome={success=success,level=item.enhancementLevel,targetLevel=level+1,rulesVersion=E.version,roll=roll,gems=cost.gems,stones=cost.stones,instanceId=c.instanceId}
    item.lastEnhancement={requestId=c.requestId,success=success,level=item.enhancementLevel,rulesVersion=E.version}
   else
    local paid=item.enhancementPaid or {ore=0,cores=0};local modern=item.enhancementPaidV2 or {gems=0,stones=0}
    local returns={iron_ore=math.floor(paid.ore*.8),forge_core=math.floor(paid.cores*.8),enhancement_gem=math.floor(modern.gems*.8),magic_stone=math.floor(modern.stones*.8)}
    local sum=0;for _,amount in pairs(returns)do sum=sum+amount end
    if sum==0 then return nil,'NoRecovery'end
    item.enhancementLevel=0;item.enhancementPaid={ore=0,cores=0};item.enhancementPaidV2={gems=0,stones=0}
    for _,id in ipairs({'iron_ore','forge_core','enhancement_gem','magic_stone'})do
     if not F.grant(p,R,C,c.heroId,id,returns[id],'recover-'..c.requestId..'-'..id,false,true)then return nil,'BagFull'end
    end
    -- Recovery must fit in the bag; no destructive partial result on refusal.
    for key,v in pairs(p.items)do if not profile.items[key]and v.location.kind=='pending'then return nil,'BagFull'end end
   end
   item.version=item.version+1
  end
 else return nil,'InvalidRequest'end
 p.revision=p.revision+1;p.operations[c.requestId]={fingerprint=fingerprint,revision=p.revision,enhancementOutcome=outcome}
 table.insert(p.operationOrder,c.requestId);if #p.operationOrder>96 then p.operations[table.remove(p.operationOrder,1)]=nil end
 if not R.validate(p,C)then return nil,'Incompatible'end
 return p
end
return F
