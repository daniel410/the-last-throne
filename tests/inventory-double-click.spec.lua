-- Exercise the production input handler across card rebuilds and blocked actions.
local source=assert(io.open('src/client/InventoryGui.luau')):read('*a')
local handler=assert(source:match('(local function activateItem%(item,input%).-)\n\tlocal function detailLabel'))
local checks=0
local function check(value,label) checks=checks+1;assert(value,label) end
local factory=assert(load([[
return function()
 local now,selectedId,lastItemClick=0,nil,nil
 local snapshot={heroId='hero',revision=1}
 local sourceTab,storageMode,gearMode='bag',false,false
 local actionForSelection,primary=nil,{Active=true}
 local selected,commands,rebuilds=nil,{},0
 local os={clock=function()return now end}
 local Enum={UserInputType={MouseButton1='mouse'}}
 local function choose(item)
  selected=item;selectedId=item.instanceId;rebuilds=rebuilds+1
  actionForSelection=item.action or (item.location.kind=='bag' and 'Equip' or 'Unequip')
 end
 local function command(action) commands[#commands+1]=action end
 ]]..handler..[[
 return function(item,time,input,change)
  now=time
  if change then
   if change.revision then snapshot.revision=change.revision end
   if change.heroId then snapshot.heroId=change.heroId end
   if change.sourceTab then sourceTab=change.sourceTab end
   if change.storageMode~=nil then storageMode=change.storageMode end
   if change.gearMode~=nil then gearMode=change.gearMode end
   if change.active~=nil then primary.Active=change.active end
   if change.close then lastItemClick=nil end
  end
  activateItem(item,input and {UserInputType=input} or nil)
  return #commands,selected,rebuilds
 end
end
]]))()
local a={instanceId='a',location={kind='bag'}}
local b={instanceId='b',location={kind='bag'}}
for _,gearMode in ipairs({false,true}) do
 local click=factory()
 local count,selected,rebuilds=click(a,1,'mouse',{gearMode=gearMode})
 check(count==0 and selected==a and rebuilds==1,'single click selects and rebuilds')
 count,selected,rebuilds=click(a,1.2,'mouse')
 check(count==1 and rebuilds==2,'same item equips after card rebuild in Bag/Gear')
 check(click(a,1.3,'mouse')==1,'triple click does not repeat equip')
end
local click=factory();click(a,1,'mouse')
check(click(a,1.36,'mouse')==0,'slow clicks only select')
click=factory();click(a,1,'mouse')
check(click(b,1.1,'mouse')==0,'different items do not equip')
for _,change in ipairs({{revision=2},{heroId='other'},{sourceTab='storage'},{storageMode=true},{gearMode=true},{active=false},{close=true}}) do
 click=factory();click(a,1,'mouse')
 check(click(a,1.1,'mouse',change)==0,'changed context or disabled action cannot equip')
end
for _,input in ipairs({'touch','gamepad',false}) do
 click=factory();click(a,1,input);check(click(a,1.1,input)==0,'nonmouse input remains selection only')
end
for _,item in ipairs({
 {instanceId='worn',location={kind='equipped'}},
 {instanceId='stored',location={kind='storage'},action='Withdraw'},
 {instanceId='pending',location={kind='pending'},action='Claim'},
 {instanceId='potion',location={kind='bag'},action='Use'},
 {instanceId='ticket',location={kind='bag'},action='ResetPoints'},
 {instanceId='deposit',location={kind='bag'},action='Deposit'},
}) do
 click=factory();click(item,1,'mouse')
 check(click(item,1.1,'mouse')==0,'double click never triggers another action')
end
check(source:find('card.Activated:Connect(function(input) activateItem(item,input) end)',1,true),'bag cards use production handler')
check(source:find('cell.Activated:Connect(function(input) activateItem(item,input) end)',1,true),'gear slots use production handler')
print('inventory-double-click: '..checks..' checks PASS')
