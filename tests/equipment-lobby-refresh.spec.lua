-- Production request handler + lobby projection, with pure reducers and a fenced store fixture.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local function read(path) local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local function body(source,a,b) local i=assert(source:find(a,1,true));return source:sub(i,assert(source:find(b,i+1,true))-1) end
local source=read(arg[1] or 'src/server/Inventory/InventoryService.luau')
local hero={heroId='hero-mage',baseClassId='mage'}
local p=R.addHero(R.new(42),hero.heroId,hero.baseClassId,C)
p.wallet.gold=100000;p.wallet.diamonds=100000
local attrs={};local character={SetAttribute=function(_,key,value) attrs[key]=value end}
local player={UserId=42,Character=character,SetAttribute=function()end}
local session={player=player,character=character,mode='Lobby',phase='Lobby',revision=0}
local account={profile=p,valid=true,tokens=12,refillAt=os.clock(),delivered={}}
local accounts={[player]=account}
local context={heroId=hero.heroId,generation=1,atHub=true}
local checks,refreshes,fail,reply=0,0,nil,nil
local function check(v,m) checks=checks+1;assert(v,m) end
local options={heroSession={getInventoryContext=function() return context end,isBusy=function() return false end},combat={}}
-- A lobby character has no combat state: CombatService.refreshEquipment returns without changes.
options.combat.refreshEquipment=function()end
options.combat.isSafeForEquipment=function()return true end
local service={stats=function() return R.stats(account.profile,hero.heroId,C) end,counts=function()return {0,0},{'',''}end}
local projectionEnv=setmetatable({settings={inventory=service},selectedHero=function()return hero end,connected=function()return true end,publish=function()end},{__index=_G})
local projection=body(read('src/server/Lobby/HeroSessionService.luau'),'local function changed(', 'local function validLife(')
local changed=assert(load(projection..'return changed','projection','t',projectionEnv))()
options.heroSession.refresh=function()refreshes=refreshes+1;changed(session)end
local store={transact=function(_,_,fn) if fail then return nil,fail end;local n,e=fn(account.profile);return n,e end}
local env=setmetatable({Service=service,options=options,accounts=accounts,Rules=R,Catalog=C,store=store,token='fixture',atStorage=function()return false end,publish=function(_,_,e)reply=e end},{__index=_G})
assert(load(body(source,'function Service.refreshCharacter(', 'local function validCommand('),'refresh','t',env))()
local handle=assert(load(body(source,'local function validCommand(', 'function Service.addStorage(')..'return handle','handle','t',env))()
changed(session)
local seq=0
local function request(item,action)
 seq=seq+1;account.tokens=12
 return {requestId='equip-'..seq,action=action,heroId=hero.heroId,instanceId=item.instanceId,itemVersion=item.version,revision=account.profile.revision}
end
for _,id in ipairs({'mage_weapon_fine','mage_tempered_hat','mage_tempered_coat','tempered_gloves','tempered_boots'}) do
 local buy={action='Buy',requestId='buy-'..id,heroId=hero.heroId,revision=account.profile.revision,offerId=id}
 account.profile=assert(R.shop(account.profile,buy,{atLobby=true},C))
 local item=account.profile.items['shop-'..buy.requestId]
 local suffix=({weapon='Weapon',head='Head',body='Body',hands='Hands',feet='Feet'})[C.items[id].slot]
 local key='TLTEquipped'..suffix
 local old=attrs[key];local cmd=request(item,'Equip');local before=refreshes
 fail='SaveFailed';handle(player,cmd)
 check(reply=='SaveFailed' and attrs[key]==old and refreshes==before,'failed save preserves '..id)
 fail=nil;handle(player,cmd)
 check(reply==nil and attrs[key]==id,'confirmed purchase/equip immediately projects '..id)
 check(refreshes==before+1 and R.validate(account.profile,C),'successful equip refreshes with valid ownership')
 account.tokens=12;handle(player,cmd)
 check(reply==nil and attrs[key]==id,'duplicate equip reconciles '..id)
 local stale=request(item,'Unequip');handle(player,stale)
 check(reply=='Changed' and attrs[key]==id,'stale item version preserves '..id)
 local equipped=account.profile.items[item.instanceId]
 handle(player,request(equipped,'Unequip'))
 check(reply==nil and attrs[key]=='','unequip immediately removes '..id)
 handle(player,request(account.profile.items[item.instanceId],'Equip'))
 check(reply==nil and attrs[key]==id,'re-equip immediately restores '..id)
end
print('equipment-lobby-refresh: '..checks..' checks passed')
