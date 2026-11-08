if game then return {} end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local E=dofile('src/shared/EconomyCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local A=dofile('src/shared/AdvancedSkills.luau')
local S=dofile('src/server/Inventory/AccountStore.luau')
local n=0
local function check(v,label)n=n+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
local function fixture(classId)
 local p=assert(R.addHero(R.new(42),'hero',classId,C));p.wallet.diamonds=500
 local h=p.heroes.hero;h.level=80;h.progression=G.new(80);h.progression.branch=A.order[classId][1];h.progression.stage=4
 h.progression.stats={STR=100,DEX=60,INT=56,VIT=100};h.progression.mastery[1]=8;h.progression.mastery[30]=4
 check(R.validate(p,C),'fixture valid');return p
end
local function buy(p,kind,id)
 return {action='Buy',heroId='hero',offerId=kind..'_reset_ticket_diamond',requestId=id,revision=p.revision,store='diamonds'}
end
local function use(p,item,id)
 return {action='ResetPoints',heroId='hero',instanceId=item.instanceId,itemVersion=item.version,revision=p.revision,requestId=id}
end
for _,classId in ipairs({'knight','elf','dwarf','mage'})do
 for _,kind in ipairs({'stat','skill'})do
  local p=fixture(classId);local cmd=buy(p,kind,'purchase')
  eq(E.offer(cmd.offerId).price,50,'approved price')
  local poor=R.copy(p);poor.wallet.diamonds=49
  local denied,reason=R.shop(poor,cmd,{atLobby=true},C);eq(denied,nil,'cannot buy without balance');eq(reason,'NotEnoughDiamonds','balance reason');eq(poor.wallet.diamonds,49,'denial unchanged')
  denied=R.shop(p,cmd,{atLobby=false},C);eq(denied,nil,'cannot buy outside lobby')
  local wrong=R.copy(cmd);wrong.store='items';check(not R.shop(p,wrong,{atLobby=true},C),'cannot buy with Gold store')
  p=assert(R.shop(p,cmd,{atLobby=true},C));eq(p.wallet.diamonds,450,'debit50');local item=p.items['shop-purchase'];eq(item.quantity,1,'grant1');eq(p.heroes.hero.progression.stats.VIT,100,'purchase does not reset')
  local replay,_,repeatBuy=R.shop(p,cmd,{atLobby=false},C);check(repeatBuy,'purchase retry reconciles');eq(replay.wallet.diamonds,450,'purchase retry no debit')
  local second=buy(p,kind,'second');p=assert(R.shop(p,second,{atLobby=true},C));eq(p.items[item.instanceId].quantity,2,'stack ticket')
  local before=R.copy(p);item=p.items[item.instanceId];local reset=use(p,item,'reset')
  local field=assert(R.apply(p,reset,{safe=true,atHub=false},C));eq(field.items[item.instanceId].quantity,1,'safe field consumes one ticket')
  local combat=assert(R.apply(p,reset,{safe=false,atHub=false},C));eq(combat.items[item.instanceId].quantity,1,'combat consumes one ticket');check(R.validate(combat,C),'combat reset validates');local cs,cp=G.points(combat.heroes.hero.progression);eq(kind=='stat' and cs or cp,kind=='stat' and 316 or 79,'combat refund exact')
  local stored=R.copy(p);stored.items[item.instanceId].location={kind='storage'}
  check(not R.apply(stored,reset,{safe=true,atHub=true},C),'must withdraw ticket')
  local forged=R.copy(reset);forged.heroId='not-owned';check(not R.apply(p,forged,{safe=true,atHub=true},C),'other hero denied')
  forged=R.copy(reset);forged.itemVersion=999;check(not R.apply(p,forged,{safe=true,atHub=true},C),'stale item denied')
  p=assert(R.apply(p,reset,{safe=false,atHub=false},C));eq(p.items[item.instanceId].quantity,1,'consume1');eq(p.wallet.diamonds,400,'use has no extra debit')
  local g=p.heroes.hero.progression;local st,sp=G.points(g)
  eq(st,kind=='stat' and 316 or 0,'stat refund exact');eq(sp,kind=='skill' and 79 or 67,'skill refund exact')
  eq(g.branch,before.heroes.hero.progression.branch,'branch kept');eq(g.stage,4,'advancement kept');eq(g.level,80,'level kept');eq(g.skillSlots[1],1,'slot kept')
  eq(g.revision,before.heroes.hero.progression.revision+1,'growth revision once')
  replay,_,repeatBuy=R.apply(p,reset,{safe=false,atHub=false},C);check(repeatBuy,'use receipt recovers after context lost');eq(replay.items[item.instanceId].quantity,1,'retry no consume')
  local noInvestment=use(p,p.items[item.instanceId],'zero')
  denied,reason=R.apply(p,noInvestment,{safe=false,atHub=false},C);eq(denied,nil,'zero investment no consume');eq(reason,'NothingToReset','zero reason')
  eq(p.items[item.instanceId].quantity,1,'zero keeps ticket');check(R.validate(p,C),'reset account valid')
  local stale=R.copy(reset);stale.requestId='stale';check(not R.apply(p,stale,{safe=true,atHub=true},C),'concurrent old revision denied')
 end
end
-- Full-bag purchase must not debit; a partial stack still has room.
local full=fixture('knight')
for i=1,60-R.count(full,'bag','hero')do local item=R.copy(full.items['hero-starter-3']);item.instanceId='fill'..i;item.location={kind='bag',heroId='hero'};full.items[item.instanceId]=item end
local denied,reason=R.shop(full,buy(full,'stat','full'),{atLobby=true},C);eq(denied,nil,'full bag rejected');eq(reason,'BagFull','full reason');eq(full.wallet.diamonds,500,'full no debit')
-- Real AccountStore path: response lost after commit, replay, close and reopen.
for _,kind in ipairs({'stat','skill'})do
 local db,fail={},false
 local adapter={UpdateAsync=function(_,key,fn)local v=fn(db[key] and R.copy(db[key]));if v then db[key]=R.copy(v)end;if fail then error('lost response after commit')end;return v end}
 local store=S.new(adapter,R,C,function()return 100 end,function()end,'source')
 assert(store:open(42));local p=assert(store:transact(42,function(cur)local seed=fixture('mage');cur.heroes=seed.heroes;cur.items=seed.items;cur.wallet=seed.wallet;return cur end))
 local cmd=buy(p,kind,'save-buy');fail=true
 local missing,why=store:transact(42,function(cur)return R.shop(cur,cmd,{atLobby=true},C)end);eq(missing,nil,'unknown buy fail closed');eq(why,'SaveUnknown','unknown buy reason')
 fail=false;p=assert(store:transact(42,function(cur)return R.shop(cur,cmd,{atLobby=true},C)end));eq(p.wallet.diamonds,450,'unknown buy single debit')
 local reset=use(p,p.items['shop-save-buy'],'save-use');fail=true
 missing,why=store:transact(42,function(cur)return R.apply(cur,reset,{safe=false,atHub=false},C)end);eq(missing,nil,'unknown use fail closed');eq(why,'SaveUnknown','unknown use reason')
 fail=false;p=assert(store:transact(42,function(cur)return R.apply(cur,reset,{safe=false,atHub=false},C)end));eq(p.items['shop-save-buy'],nil,'last ticket consumed once')
 local st,sp=G.points(p.heroes.hero.progression);eq(kind=='stat' and st or sp,kind=='stat' and 316 or 79,'refund survives response loss')
 assert(store:close(42));local nextStore=S.new(adapter,R,C,function()return 100 end,function()end,'destination')
 p=assert(nextStore:open(42));check(R.validate(p,C),'reopened durable account valid');eq(p.wallet.diamonds,450,'reopen no debit');eq(p.items['shop-save-buy'],nil,'reopen no ticket resurrection')
 p=assert(nextStore:transact(42,function(cur)return R.apply(cur,reset,{safe=false,atHub=false},C)end));check(R.validate(p,C),'same receipt recovers on new server')
end
print('Reset tickets: '..n..' checks passed')
