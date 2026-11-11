-- Existing owned gear, including retired definitions, works at hero level one.
local C=dofile('src/shared/ItemCatalog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Text=dofile('src/shared/InventoryText.luau')
local n,gearCount=0,0
local function check(v,m)n=n+1;assert(v,m)end
for id,d in pairs(C.items)do if d.slot and not d.deleted then
 gearCount=gearCount+1
 check(not d.description:find('Requires level',1,true),'no level requirement description '..id)
 for class in pairs(C.classes)do
  local p=assert(R.addHero(R.new(42),'h',class,C))
  p.items.owned={instanceId='owned',definitionId=id,definitionVersion=C.version,ownerUserId=42,
   quantity=1,version=1,binding='account',locked=true,location={kind='bag',heroId='h'},sourceGrantId='owned-before-change',enhancementLevel=9}
  check(R.validate(p,C),'owned enhanced gear decodes '..id)
  local cmd={action='Equip',requestId='wear',heroId='h',revision=p.revision,instanceId='owned',itemVersion=1}
  local worn,why=R.apply(p,cmd,{safe=true},C)
  if d.classId and d.classId~=class then
   check(not worn and why=='WrongClass','class restriction retained '..class..' '..id)
  else
   check(worn and R.validate(worn,C),'level one equips '..class..' '..id)
   check(worn.heroes.h.level==1 and worn.items.owned.enhancementLevel==9 and worn.items.owned.locked,'hero and enhancement preserved '..id)
   local retry,err,repeated=R.apply(worn,cmd,{safe=true},C)
   check(retry and not err and repeated and retry.revision==worn.revision,'equip retry cannot duplicate '..id)
   local unsafe,reason=R.apply(p,cmd,{safe=false},C)
   check(not unsafe and reason=='InCombat','combat guard retained '..id)
  end
 end
end end
for _,key in ipairs({'ShopGearStats','ShopStaffStats'})do
 local value=string.format(Text[key],'Equippable by: All classes','Rare',30,' · Defense +30 pts','','Delivered to your bag. Equip from BAG.')
 check(value:find('30.0',1,true) and not value:find('Lv',1,true),'shop format preserves stats without level '..key)
end
print('Equipment level-free: '..n..' checks passed across '..gearCount..' owned gear definitions and four classes')
