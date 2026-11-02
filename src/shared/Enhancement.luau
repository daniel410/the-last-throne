-- Pure enhancement math shared by the authoritative reducer and UI.
local E={version=1,rate=.03,keys={power=true,armor=true,health=true}}
function E.cap(def)
 local level=def.level or 1
 return level>=60 and 10 or level>=40 and 9 or level>=20 and 7 or level>=10 and 5 or 3
end
function E.supported(def)
 if not def or not def.slot then return false end
 for key in pairs(E.keys)do if (def.stats or {})[key] and def.stats[key]>0 then return true end end
 return false
end
function E.stats(def,item)
 local result={};local n=item and item.enhancementLevel or 0
 for key,value in pairs(def.stats or {})do result[key]=value*(E.keys[key]and value>0 and (1+E.rate*n)or 1)end
 return result
end
function E.cost(def,level)
 return {gold=20*level*level*math.max(1,math.ceil((def.level or 1)/10)),ore=2*level,cores=math.max(0,level-3)}
end
function E.valid(item,def)
 local n=item.enhancementLevel
 if n==nil then return item.enhancementPaid==nil end
 if not E.supported(def)or type(n)~='number'or n%1~=0 or n<0 or n>E.cap(def)then return false end
 local paid=item.enhancementPaid
 if paid~=nil then
  if type(paid)~='table'then return false end
  local total={ore=0,cores=0}
  for step=1,n do local c=E.cost(def,step);total.ore=total.ore+c.ore;total.cores=total.cores+c.cores end
  for _,key in ipairs({'ore','cores'})do
   if type(paid[key])~='number'or paid[key]%1~=0 or paid[key]<0 or paid[key]>total[key]then return false end
  end
 end
 return true
end
function E.name(def,item)return def.name..((item and (item.enhancementLevel or 0)>0)and ' +'..item.enhancementLevel or '')end
return E
