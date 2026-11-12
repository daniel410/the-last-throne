local V=dofile('src/shared/HeroVitals.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function restored(v,h,m,l,eh,em)
 local hp,mp=V.restore(v,h,m,l);check(hp==eh and mp==em,'resource restoration')
end
restored(nil,100,50,1,100,50)
local depleted={health=37.25,mana=0,level=1}
restored(depleted,100,50,1,37.25,0)
restored(depleted,200,100,1,37.25,0)
restored({health=90,mana=45,level=1},60,20,1,60,20)
restored(depleted,100,0,1,37.25,0)
restored(depleted,200,100,2,200,100)
restored({health=0,mana=0,level=1},100,50,1,100,50)
for _,value in ipairs({-1,0/0,math.huge,'100'})do
 check(not V.valid({health=value,mana=0,level=1}),'invalid HP rejected')
 check(not V.valid({health=1,mana=value,level=1}),'invalid MP rejected')
end
local data,unknown,down={},false,false
local adapter={UpdateAsync=function(_,key,fn)
 if down then error('offline')end
 local p=fn(R.copy(data[key]));if p then data[key]=R.copy(p)end
 if unknown then error('ack lost')end
 return R.copy(p)
end}
local function server(token)return Store.new(adapter,R,C,function()return 100 end,function()end,token)end
local battle,lobby=server('battle'),server('lobby')
assert(battle:open(1))
assert(battle:transact(1,function(p)return R.addHero(p,'mage','mage',C)end))
assert(battle:transact(1,function(p)return R.addHero(p,'knight','knight',C)end))
local p=assert(battle:transact(1,function(p)return R.saveVitals(p,'mage',depleted)end))
depleted.health=99
check(p.heroes.mage.vitals.health==37.25,'snapshot copied')
check(p.heroes.knight.vitals==nil,'other hero untouched')
local _,e=battle:transact(1,function(p)return R.saveVitals(p,'foreign',{health=1,mana=1,level=1})end)
check(e=='HeroNotOwned','ownership required')
assert(battle:close(1));p=assert(lobby:open(1))
check(p.heroes.mage.vitals.health==37.25 and p.heroes.mage.vitals.mana==0,'battle to lobby persists')
assert(lobby:close(1));p=assert(battle:open(1))
restored(p.heroes.mage.vitals,100,50,1,37.25,0)
unknown=true
_,e=battle:transact(1,function(p)return R.saveVitals(p,'mage',{health=12,mana=4,level=1})end)
check(e=='SaveUnknown','unknown acknowledgement not success')
unknown=false
p=assert(battle:transact(1,function(p)return R.saveVitals(p,'mage',{health=12,mana=4,level=1})end))
check(p.heroes.mage.vitals.health==12 and p.heroes.mage.vitals.mana==4,'retry preserves absolute resources')
down=true;_,e=battle:open(2);check(e=='SaveUnknown' and data['account:2']==nil,'load failure never creates full-resource profile')
down=false;assert(battle:close(1));assert(lobby:open(1))
_,e=battle:transact(1,function(p)return R.saveVitals(p,'mage',{health=100,mana=50,level=1})end)
check(e=='Unavailable','released server cannot overwrite destination')
check(data['account:1'].heroes.mage.vitals.health==12,'destination resources preserved')
print('Hero vitals: '..n..' checks passed')
