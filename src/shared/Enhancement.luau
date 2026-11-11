-- Pure enhancement math shared by the authoritative reducer and UI.
local E={version=6,rate=.03,keys={power=true,armor=true,health=true,mana=true,dexterity=true,intelligence=true},exchangeVersion=1,gemPurchaseVersion=2,oreConversionGold=50,
 exchanges={gems={gold=50,amount=1},stones={gold=50,gems=5,amount=1}}}
function E.cap(def)return 9 end
function E.successPercent(target)return 110-10*target end
function E.succeeds(target,roll)
 return type(roll)=='number'and roll%1==0 and roll>=0 and roll<10000 and roll<E.successPercent(target)*100
end
function E.supported(def)
 if not def or not def.slot then return false end
 for key in pairs(E.keys)do if (def.stats or {})[key] and def.stats[key]>0 then return true end end
 return false
end
function E.stats(def,item)
 local result={};if def.deleted then return result end
 local n=item and item.enhancementLevel or 0
 for key,value in pairs(def.stats or {})do result[key]=value*(E.keys[key]and value>0 and (1+E.rate*n)or 1)end
 return result
end
function E.cost(def,level)
 return {gold=50,ore=2*level,cores=math.max(0,level-3),gems=2*level,stones=math.max(0,level-3)}
end
function E.valid(item,def)
 local n=item.enhancementLevel
 if n==nil then return item.enhancementPaid==nil and item.enhancementPaidV2==nil end
 if not E.supported(def)or type(n)~='number'or n%1~=0 or n<0 or n>math.max(E.cap(def),(def.level or 1)>=60 and 10 or 0)then return false end
 local total={gems=0,stones=0}
 for step=1,n do local cost=E.cost(def,step);total.gems=total.gems+cost.gems;total.stones=total.stones+cost.stones end
 local old=item.enhancementPaid;local paid=item.enhancementPaidV2
 for _,ledger in ipairs({{value=old,keys={'ore','cores'}},{value=paid,keys={'gems','stones'}}})do
  if ledger.value~=nil then
   if type(ledger.value)~='table'then return false end
   for index,key in ipairs(ledger.keys)do
    local value=ledger.value[key];local cap=index==1 and total.gems or total.stones
    if type(value)~='number'or value%1~=0 or value<0 or value>cap then return false end
   end
  end
 end
 if ((old and old.ore or 0)+(paid and paid.gems or 0))>total.gems or ((old and old.cores or 0)+(paid and paid.stones or 0))>total.stones then return false end
 return true
end
function E.name(def,item)return def.name..((item and (item.enhancementLevel or 0)>0)and ' +'..item.enhancementLevel or '')end
return E
