local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local Artwork=require(script.Parent.ItemArtwork)
local E=require(RS.Shared.Enhancement)
local C=require(RS.Shared.ItemCatalog)
local Text=require(RS.Shared.AdventureText)
local V={}
function V.render(scroll,s,send,saving,notice)
 local hero=s.heroId and s.heroes and s.heroes[s.heroId]
 local function amount(id)
  local q=0;for _,item in ipairs(s.items or {})do if item.definitionId==id and not item.locked and item.location.kind=='bag'and item.location.heroId==s.heroId then q=q+item.quantity end end
  return q
 end
 local ore,cores=amount('enhancement_gem'),amount('magic_stone')
 local function card(id,def,title,description,actions)
  local box=T.frame(scroll,id,UDim2.new(),UDim2.new(1,-8,0,304));box.LayoutOrder=#scroll:GetChildren()
  local gear=def.slot~=nil
  local artSize=gear and 128 or 54
  Artwork.create(box,def,UDim2.fromOffset(10,10),UDim2.fromOffset(artSize,artSize))
  local nameX=gear and 154 or 74
  T.label(box,'Name',title,UDim2.fromOffset(nameX,8),UDim2.new(1,-nameX-12,0,gear and 128 or 56),15,T.color.gold)
  T.label(box,'Description',description,UDim2.fromOffset(12,gear and 146 or 70),UDim2.new(1,-24,1,gear and -258 or -182),12)
  for index,a in ipairs(actions)do
   local b=T.button(box,'Action'..index,a.title,UDim2.new(0,12,1,-108+(index-1)*50),UDim2.new(1,-24,0,44),a.action=='Enhance')
   T.enabled(b,not saving and s.ready and hero~=nil and a.enabled~=false)
   local armedRevision
   b.Activated:Connect(function()
    if saving or not s.ready or not hero or a.enabled==false then return end
    if armedRevision~=s.revision then armedRevision=s.revision;b.Caption.Text=Text.Confirm..a.title;notice.Text=a.review or description;return end
    local cmd={store='blacksmith',action=a.action,heroId=s.heroId,revision=s.revision,instanceId=a.instanceId,itemVersion=a.itemVersion,offerId=a.offerId,rulesVersion=a.rulesVersion,expectedLevel=a.expectedLevel,exchangeVersion=a.exchangeVersion}
    T.enabled(b,false);send(cmd)
   end)
  end
 end
 local gemsOffer,stoneOffer=E.exchanges.gems,E.exchanges.stones
 card('StoneExchange',C.items.magic_stone,Text.ForgeMaterials,string.format(Text.ExchangeInfo,ore,cores,gemsOffer.gold,gemsOffer.amount,stoneOffer.gems,stoneOffer.gold,stoneOffer.amount),{
  {title=string.format(Text.ExchangeGemsButton,gemsOffer.gold,gemsOffer.amount),action='ExchangeGems',exchangeVersion=E.gemPurchaseVersion,enabled=s.wallet and s.wallet.gold>=gemsOffer.gold},
  {title=string.format(Text.ExchangeStoneButton,stoneOffer.gold),action='ExchangeStone',exchangeVersion=E.exchangeVersion,enabled=ore>=stoneOffer.gems and s.wallet and s.wallet.gold>=stoneOffer.gold}})
 if amount('iron_ore')>0 then
  local title,review=string.format(Text.ConvertOre,E.oreConversionGold),string.format(Text.ConvertOreReview,E.oreConversionGold)
  card('LegacyOre',C.items.iron_ore,title,review,{{title=title,review=review,action='ConvertOre',exchangeVersion=E.exchangeVersion,enabled=s.wallet and s.wallet.gold>=E.oreConversionGold}})
 end
 if amount('forge_core')>0 then card('LegacyCore',C.items.forge_core,Text.ConvertCore,Text.ConvertReview,{{title=Text.ConvertCore,review=Text.ConvertReview,action='ConvertCore'}})end
 for _,item in ipairs(s.items or {})do
  local def=C.items[item.definitionId]
  if item.location.heroId==s.heroId and not item.locked and (item.location.kind=='bag'or item.location.kind=='equipped')then
   if E.supported(def)then
    local n=item.enhancementLevel or 0;local cost=E.cost(def,n+1);local before=E.stats(def,item)
    local after=E.stats(def,{enhancementLevel=math.max(n,math.min(E.cap(def),n+1))})
    local lines={n>=E.cap(def)and Text.MaxEnhancement or string.format(Text.Success,E.successPercent(n+1),100-E.successPercent(n+1))}
    for _,key in ipairs({'power','armor','health','mana','dexterity'})do if (before[key]or 0)>0 then table.insert(lines,key=='power' and string.format(Text.PowerChange,before[key],after[key]) or string.format(Text.StatChange,key=='armor'and Text.Armor or key=='mana'and 'Max MP' or key=='dexterity'and 'Dexterity' or Text.Health,before[key],after[key]))end end
    table.insert(lines,string.format(Text.EnhanceCost,E.cap(def),cost.gold,cost.gems,cost.stones))
    table.insert(lines,string.format(Text.MaterialBag,ore,cores))
    local paid=item.enhancementPaid or {ore=0,cores=0};local modern=item.enhancementPaidV2 or {gems=0,stones=0};local ro,rc=math.floor(paid.ore*.8),math.floor(paid.cores*.8);local rg,rs=math.floor(modern.gems*.8),math.floor(modern.stones*.8)
    local enough=s.wallet and s.wallet.gold>=cost.gold and ore>=cost.gems and cores>=cost.stones
    card(item.instanceId,def,E.name(def,item),table.concat(lines,'\n'),{
     {rulesVersion=E.version,expectedLevel=n,title=n>=E.cap(def)and Text.MaxEnhancement or enough and Text.Enhance or Text.MoreMaterials,action='Enhance',instanceId=item.instanceId,itemVersion=item.version,enabled=n<E.cap(def)and enough},
     {title=Text.Recover,action='Recover',instanceId=item.instanceId,itemVersion=item.version,enabled=ro+rc+rg+rs>0,review=string.format(Text.RecoveryReview,E.name(def,item),rg,rs,ro,rc)}})
   elseif def.cacheTier then
    local choices={};for _,choice in pairs(C.items)do if choice.slot and not choice.retired and choice.cacheEligible~=false and (choice.level or 1)==(def.cacheTier==5 and 10 or def.cacheTier) and E.supported(choice)and (not choice.classId or choice.classId==hero.baseClassId)then table.insert(choices,choice)end end
    table.sort(choices,function(a,b)return a.id<b.id end)
    if #choices==0 then card(item.instanceId..'-unavailable',def,def.name,Text.CacheUnavailable,{}) end
    for _,choice in ipairs(choices)do
     card(item.instanceId..choice.id,choice,choice.name,string.format(Text.CacheInfo,def.name),{{title=Text.ChooseEquipment,action='OpenCache',instanceId=item.instanceId,itemVersion=item.version,offerId=choice.id}})
    end
   end
  end
 end
end
return V
