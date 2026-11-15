-- Finite enemy elemental effects. No effect adds to an attack's raw damage budget.
local R={version=1,minimumMovement=.7,minimumOutgoing=.8,maxLateTick=.18,maxRecords=128,maxTicksPerStep=32}
local rows={
 fire={kind='Burn',attribute='K0EnemyBurnUntil',duration=1.35,fraction=.25,ticks=2,interval=.6},
 venom={kind='Venom',attribute='K0EnemyVenomUntil',duration=1.35,fraction=.3,ticks=2,interval=.6},
 frost={kind='Chill',attribute='K0EnemyChillUntil',duration=1.4,movement=.8},
 web={kind='Web',attribute='K0EnemyWebUntil',duration=1.2,movement=.75},
 shadow={kind='Weakness',attribute='K0EnemyWeaknessUntil',duration=1.5,outgoing=.85},
 -- A short, resource-neutral curse affects every class equally; it never steals MP or heals a boss.
 soul={kind='Soul',attribute='K0EnemySoulUntil',duration=1.4,outgoing=.9},
}
local function copy(source)
 local result={}for key,value in pairs(source)do result[key]=value end return result
end
local function finite(value)return type(value)=='number'and value==value and value>-math.huge and value<math.huge end
function R.get(element)return rows[element]and copy(rows[element])or nil end
function R.attributes()
 local list={}for _,row in pairs(rows)do list[#list+1]=row.attribute end return list
end
function R.split(element,amount)
 if not finite(amount)or amount<0 then return 0,nil end
 local total=math.floor(amount)
 local rule=R.get(element)
 if not rule then return total,nil end
 local reservation={rule=rule,element=element,amounts={}}
 if rule.fraction then
  local deferred=math.floor(total*rule.fraction)
  if deferred<1 then return total,nil end
  for index=1,rule.ticks do
   reservation.amounts[index]=math.floor(deferred*index/rule.ticks)-math.floor(deferred*(index-1)/rule.ticks)
  end
  return total-deferred,reservation
 end
 return total,reservation
end
function R.canApply(receipt)
 return type(receipt)=='table'and finite(receipt.applied)and receipt.applied>0
  and receipt.result=='Hit'and (receipt.absorbed or 0)==0
end
function R.movement(value)return math.max(R.minimumMovement,math.min(1,value or 1))end
function R.outgoing(value)return math.max(R.minimumOutgoing,math.min(1,value or 1))end
return R
