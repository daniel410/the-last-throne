assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated QA only')
do
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local F=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local Store=require(game.ServerScriptService.Server.Inventory.AccountStore)
local n=0
local function check(v,label)n=n+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label..': '..tostring(a)..' ~= '..tostring(b))end
local function fixture()
 local p=assert(R.addHero(R.new(42),'hero','knight',C));p.wallet.gold=1000;p.wallet.diamonds=77
 F.grant(p,R,C,'hero','enhancement_gem',500,'test-gems');F.grant(p,R,C,'hero','magic_stone',500,'test-stones')
 local id;for k,item in pairs(p.items)do if item.definitionId=='knight_weapon_traveler'and (item.location.kind=='bag'or item.location.kind=='equipped')then id=k;break end end
 return p,id
end
local function command(p,id,request)
 local item=p.items[id]
 return {action='Enhance',store='blacksmith',heroId='hero',instanceId=id,itemVersion=item.version,revision=p.revision,requestId=request,rulesVersion=E.version,expectedLevel=item.enhancementLevel or 0}
end
for target=1,9 do
 eq(E.successPercent(target),110-10*target,'success percentage')
 local count=0;for roll=0,9999 do if E.succeeds(target,roll)then count=count+1 end end
 eq(count,E.successPercent(target)*100,'all ten thousand outcomes')
 check(E.succeeds(target,E.successPercent(target)*100-1),'last successful roll')
 check(not E.succeeds(target,E.successPercent(target)*100),'first failed roll or out-of-range')
 local p,id=fixture();p.items[id].enhancementLevel=target-1
 local c=command(p,id,'boundary'..target);local gems=R.quantity(p,'hero','enhancement_gem');local stones=R.quantity(p,'hero','magic_stone')
 local cost=E.cost(C.items[p.items[id].definitionId],target)
 local result=assert(R.shop(p,c,{atLobby=true,enhancementRoll=9999},C))
 local success=target==1
 eq(result.items[id].enhancementLevel,success and target or target-1,'failure preserves level')
 eq(result.items[id].version,p.items[id].version+1,'every attempt changes item version')
 eq(R.quantity(result,'hero','enhancement_gem'),gems-cost.gems,'success and failure consume exact gems')
 eq(R.quantity(result,'hero','magic_stone'),stones-cost.stones,'success and failure consume exact stones')
 eq(result.wallet.gold,950,'success and failure each cost exactly50 Gold');eq(result.operations[c.requestId].enhancementOutcome.gold,50,'receipt records Gold consumed');eq(result.wallet.diamonds,77,'no Diamonds cost')
 eq(result.schemaVersion,2,'old deterministic writers fenced by schema')
 eq(result.operations[c.requestId].enhancementOutcome.success,success,'durable outcome')
 local ledger=result.items[id].enhancementPaidV2
 eq(ledger and ledger.gems or 0,success and cost.gems or 0,'only successful investment refundable')
 for retry=1,100 do
  local replay,err,repeated=R.shop(result,c,{atLobby=false,enhancementRoll=0},C)
  check(replay and not err and repeated,'replay returns saved result even outside lobby')
  eq(replay.revision,result.revision,'replay cannot spend or reroll')
  eq(replay.operations[c.requestId].enhancementOutcome.success,success,'replay preserves original failure')
 end
 local conflicting=R.copy(c);conflicting.expectedLevel=99
 local no,why=R.shop(result,conflicting,{atLobby=true,enhancementRoll=0},C)
 check(not no and why=='RequestConflict','same ID with changed fingerprint refused')
 local stale=R.copy(c);stale.requestId='stale'
 no,why=R.shop(result,stale,{atLobby=true,enhancementRoll=0},C)
 check(not no and why=='Changed','concurrent old revision cannot spend')
end
local p,id=fixture();local original=R.copy(p)
for _,roll in ipairs({-1,10000,.5,0/0})do
 local no,why=R.shop(p,command(p,id,'bad-roll'),{atLobby=true,enhancementRoll=roll},C)
 check(not no and why=='InvalidRequest','invalid server sample refused')
end
local c=command(p,id,'old-ui');c.rulesVersion=2
local no,why=R.shop(p,c,{atLobby=true,enhancementRoll=0},C);check(not no and why=='EnhancementChanged','old client must refresh')
c=command(p,id,'first');p=assert(R.shop(p,c,{atLobby=true,enhancementRoll=0},C))
for i=1,3 do p=assert(R.shop(p,command(p,id,'fail'..i),{atLobby=true,enhancementRoll=9999},C))end
local gems=R.quantity(p,'hero','enhancement_gem');c=command(p,id,'recover');c.action='Recover'
p=assert(R.shop(p,c,{atLobby=true},C));eq(R.quantity(p,'hero','enhancement_gem'),gems+1,'only floor80% of successful two gems returned')
eq(p.items[id].enhancementLevel,0,'recovery resets level');eq(p.wallet.gold,800,'recovery does not refund four50Gold attempt fees')
check(p.items[id].lastEnhancement.success==false,'recovery preserves last attempt history')
check(p.operations.fail1.enhancementOutcome.success==false,'recovery retains durable failure receipts')
-- Unknown save after commit and callback reexecution must not redraw or double debit.
local saved,lose;local callbacks=0
local adapter={UpdateAsync=function(_,_,fn)
 callbacks=callbacks+1;fn(R.copy(saved)) -- Discarded callback candidate, as in UpdateAsync contention.
 local nextP=fn(R.copy(saved));if nextP then saved=R.copy(nextP)end
 if lose then error('lost reply')end;return R.copy(nextP)
end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'probability-session')
assert(store:open(42));assert(store:transact(42,function(current)local copy=R.copy(p);copy.lease=current.lease;copy.epoch=current.epoch;return copy end))
c=command(p,id,'unknown-first');lose=true
no,why=store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=0},C)end)
check(not no and why=='SaveUnknown','committed unknown reported as unknown')
lose=false;p=assert(store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=9999},C)end))
eq(p.wallet.gold,750,'unknown success charges Gold once');eq(p.items[id].enhancementLevel,1,'committed attempt recovered once');eq(R.quantity(p,'hero','enhancement_gem'),gems-1,'callback retries consume once')
c=command(p,id,'unknown-failure');lose=true
no,why=store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=9999},C)end)
check(not no and why=='SaveUnknown','failed attempt response loss stays unknown')
lose=false;local result=assert(store:transact(42,function(current)return R.shop(current,c,{atLobby=true,enhancementRoll=0},C)end))
eq(result.wallet.gold,p.wallet.gold-50,'unknown failure charges Gold once');eq(result.items[id].enhancementLevel,1,'lost failure cannot become a success')
eq(result.operations[c.requestId].enhancementOutcome.success,false,'original failure retained')
eq(R.quantity(result,'hero','enhancement_gem'),R.quantity(p,'hero','enhancement_gem')-4,'failure consumes once through save retries')
-- A historical +10 is preserved and cannot be enhanced further.
local high=R.copy(C);high.items.test80={id='test80',name='Legacy Sword',category='Equipment',slot='weapon',classId='knight',stats={power=24},level=80,maxStack=1}
p,id=fixture();p.items[id].location.kind='bag';p.items[id].definitionId='test80';p.items[id].enhancementLevel=10;p.items[id].enhancementPaid={ore=110,cores=28}
check(R.validate(p,high),'legacy +10 loads unchanged');check(math.abs(E.stats(high.items.test80,p.items[id]).power-31.2)<1e-9,'legacy +10 keeps original power')
no,why=R.shop(p,command(p,id,'legacy-cap'),{atLobby=true,enhancementRoll=0},high);check(not no and why=='EnhancementMax','legacy +10 cannot advance')
-- Material shortage and old evicted requests cannot spend.
p,id=fixture();for k,item in pairs(p.items)do if item.definitionId=='enhancement_gem'then p.items[k]=nil end end
no,why=R.shop(p,command(p,id,'short'),{atLobby=true,enhancementRoll=0},C);check(not no and why=='EnhancementMaterials','shortage never counts as probability failure')
p,id=fixture();c=command(p,id,'evicted');p=assert(R.shop(p,c,{atLobby=true,enhancementRoll=0},C));p.operations[c.requestId]=nil;p.operationOrder={}
no,why=R.shop(p,c,{atLobby=true,enhancementRoll=0},C);check(not no and why=='Changed','evicted old request remains stale')
check(R.validate(result,C),'final stored profile valid')
print('Enhancement probability: '..n..' checks passed (including 90000 outcome boundaries)')

end
do
-- Current 43 equipment definitions through the actual inventory/forge reducer.
local function module(path)
 if not game then return dofile(path)end
 local name=path:match('([^/]+)%.luau$')
 return require((path:sub(1,11)=='src/shared/'and game.ReplicatedStorage.Shared or game.ServerScriptService.Server.Inventory)[name])
end
local R=module('src/server/Inventory/InventoryRules.luau')
local C=module('src/shared/ItemCatalog.luau')
local E=module('src/shared/Enhancement.luau')
local F=module('src/shared/EquipmentTransactions.luau')
local Text=module('src/shared/AdventureText.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function near(a,b)return math.abs(a-b)<1e-8 end
local chances={100,90,80,70,60,50,40,30,20}
local ids={};for _,id in ipairs(C.tierEquipment)do ids[#ids+1]=id end
for _,id in ipairs({'copper_ring','amber_charm','amber_mana_charm'})do ids[#ids+1]=id end
check(#ids==43,'all 40 family gear and 3 accessories covered')
for _,id in ipairs(ids)do
 local def=C.items[id]
 local profile=assert(R.addHero(R.new(42),'hero',def.classId or 'knight',C))
 profile.wallet.gold=1000;profile.wallet.diamonds=77
 assert(F.grant(profile,R,C,'hero',id,1,'acceptance-item'))
 assert(F.grant(profile,R,C,'hero','enhancement_gem',500,'acceptance-gems'))
 assert(F.grant(profile,R,C,'hero','magic_stone',500,'acceptance-stones'))
 for target=1,9 do
  check(E.successPercent(target)==chances[target],'independent expected chance '..target)
  for _,success in ipairs(target==1 and {true}or {true,false})do
   local p=R.copy(profile);local item=p.items['acceptance-item-1'];item.enhancementLevel=target-1
   local before=E.stats(def,item)
   local command={action='Enhance',store='blacksmith',heroId='hero',requestId='attempt',instanceId=item.instanceId,itemVersion=item.version,revision=p.revision,rulesVersion=E.version,expectedLevel=target-1}
   local roll=success and chances[target]*100-1 or chances[target]*100
   local result=assert(R.shop(p,command,{atLobby=true,enhancementRoll=roll},C))
   local after=result.items[item.instanceId];local outcome=result.operations.attempt.enhancementOutcome
   check(R.validate(result,C),'result profile remains valid '..id)
   check(outcome.success==success and outcome.roll==roll and outcome.targetLevel==target,'server receipt uses boundary roll')
   check(after.enhancementLevel==(success and target or target-1),'failure keeps level; success raises once')
   check(result.wallet.gold==950 and result.wallet.diamonds==77,'exact 50 Gold, zero Diamonds')
   check(R.quantity(result,'hero','enhancement_gem')==R.quantity(p,'hero','enhancement_gem')-2*target,'exact gem cost')
   check(R.quantity(result,'hero','magic_stone')==R.quantity(p,'hero','magic_stone')-math.max(0,target-3),'exact stone cost')
   check(after.instanceId==item.instanceId and after.definitionId==id and after.location.kind==item.location.kind,'ownership and location survive both outcomes')
   check(p.wallet.gold==1000 and item.enhancementLevel==target-1,'input profile never partially spent')
   for key,value in pairs(def.stats)do
    local actual=E.stats(def,after)[key]
    check(near(actual,value*(1+.03*(success and target or target-1))),'enhanced actual stat '..id..' '..key)
    if not success then check(near(actual,before[key]),'failure cannot reduce or raise stats')end
   end
   local replay,err,repeated=R.shop(result,command,{atLobby=true,enhancementRoll=success and 9999 or 0},C)
   check(replay and not err and repeated and replay.wallet.gold==950 and replay.items[item.instanceId].enhancementLevel==after.enhancementLevel,'opposite-roll replay cannot change result or charge again')
  end
 end
end
check(Text.EnhancementHelpIntro:find('Max MP',1,true)and Text.EnhancementHelpIntro:find('DEX',1,true),'guide covers all enhanced resources and stats')
check(Text.EnhancementHelpIntro:find('Special effects do not change.',1,true),'guide distinguishes special effects')
print('Current equipment enhancement: '..n..' checks passed (43 definitions; all 9 targets; success/failure boundaries)')

end

do
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local Catalog=require(game.ReplicatedStorage.Shared.ItemCatalog)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local F=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local Service={refreshCharacter=function()end}
local player={UserId=42,GetAttribute=function()return 'Lobby'end}
local workspace={GetAttribute=function()return 'Lobby'end}
local options={heroSession={getInventoryContext=function()return {heroId='hero',atHub=true}end,refresh=function()end}}
local draws=0;local nextRoll=9999
local Random={new=function()return {NextInteger=function(_,low,high)check(low==0 and high==9999,'server draw uses inclusive 0..9999');draws=draws+1;return nextRoll end}end}
local function publish()end
local saved=assert(R.addHero(R.new(42),'hero','knight',Catalog));saved.wallet.gold=1000
assert(F.grant(saved,R,Catalog,'hero','enhancement_gem',500,'gems'))
assert(F.grant(saved,R,Catalog,'hero','magic_stone',500,'stones'))
local item=assert(R.equipped(saved,'hero','weapon'));local id=item.instanceId;item.enhancementLevel=1
local state={profile=R.copy(saved),valid=true};local accounts={[player]=state}
local lose=true;local callbacks=0
local store={transact=function(_,_,fn)
 callbacks=callbacks+2
 local a,err=fn(R.copy(saved));if not a then return nil,err end
 local b=assert(fn(R.copy(saved)))
 check(a.wallet.gold==b.wallet.gold and a.items[id].enhancementLevel==b.items[id].enhancementLevel,'repeated save callbacks use identical outcome')
 saved=b
 if lose then return nil,'SaveUnknown'end
 return R.copy(saved)
end}
function Service.shop(player,command)
 local s=accounts[player];if not s or s.busy or s.closing then return 'Busy' end
 if not s.valid and not (s.shopPending and s.shopPending.requestId==command.requestId) then return s.errorCode or 'Unavailable' end
 if s.shopPending and s.shopPending.requestId~=command.requestId then return 'Busy' end
 if s.shopPending then for _,k in ipairs({'store','action','heroId','offerId','instanceId','itemVersion','revision','rulesVersion','expectedLevel','exchangeVersion'}) do if s.shopPending[k]~=command[k] then return 'RequestConflict' end end end
 s.busy=true
 if not s.shopPending then
  s.shopPending=Rules.copy(command)
  s.shopPending.enhancementRoll=Random.new():NextInteger(0,9999)
 end
 local enhancementRoll=s.shopPending.enhancementRoll
 local p,e=store:transact(player.UserId,function(current)
  local ctx=options.heroSession.getInventoryContext(player)
  return Rules.shop(current,command,{enhancementRoll=enhancementRoll,atLobby=workspace:GetAttribute('TLTServerRole')~='Battle' and ctx and ctx.heroId==command.heroId and ctx.atHub and player:GetAttribute('K0SessionPhase')=='Lobby'},Catalog)
 end)
 if p then s.profile=p;s.valid=true;s.errorCode=nil;s.shopPending=nil;Service.refreshCharacter(player);options.heroSession.refresh(player)
 elseif e=='SaveUnknown' or e=='AccountBusy' then s.valid=false;s.errorCode=e
 else s.shopPending=nil end
 s.busy=false;publish(player,command.requestId,e);return e,p and p.operations[command.requestId] and p.operations[command.requestId].enhancementOutcome
end

local command={action='Enhance',store='blacksmith',requestId='service-failure',heroId='hero',instanceId=id,itemVersion=item.version,revision=saved.revision,rulesVersion=E.version,expectedLevel=1,enhancementRoll=0}
local err=Service.shop(player,command)
check(err=='SaveUnknown'and draws==1 and callbacks==2,'save response loss preserves one server draw')
check(saved.wallet.gold==950 and saved.items[id].enhancementLevel==1,'failed enhancement charged once and level kept')
check(state.shopPending and state.shopPending.enhancementRoll==9999,'pending keeps original roll, ignores command roll')
local other=R.copy(command);other.requestId='other'
local otherError=Service.shop(player,other)
check(otherError=='SaveUnknown','unconfirmed account cannot accept a new attempt')
local conflict=R.copy(command);conflict.expectedLevel=2
check(Service.shop(player,conflict)=='RequestConflict','pending request cannot change target level')
lose=false;nextRoll=0
local outcome;err,outcome=Service.shop(player,command)
check(err==nil and outcome.success==false and outcome.roll==9999,'retry cannot turn saved failure into success')
check(draws==1 and saved.wallet.gold==950 and saved.items[id].enhancementLevel==1,'retry neither redraws nor spends')
check(state.valid and not state.shopPending,'acknowledged retry clears pending')
err,outcome=Service.shop(player,command)
check(err==nil and outcome.success==false and saved.wallet.gold==950,'acknowledged duplicate returns original receipt')
local second={action='Enhance',store='blacksmith',requestId='service-success',heroId='hero',instanceId=id,itemVersion=saved.items[id].version,revision=saved.revision,rulesVersion=E.version,expectedLevel=1}
err,outcome=Service.shop(player,second)
check(err==nil and outcome.success and saved.items[id].enhancementLevel==2 and saved.wallet.gold==900,'fresh request gets a fresh server draw')
check(R.validate(saved,Catalog),'mock service account remains valid')
print('InventoryService.shop extracted-body QA: '..n..' checks passed; no real account or DataStore')
end


do
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local rng=Random.new(20261110)
local chances={100,90,80,70,60,50,40,30,20}
local trials=100000
for target,percent in ipairs(chances)do
 local successes=0
 for _=1,trials do if E.succeeds(target,rng:NextInteger(0,9999))then successes=successes+1 end end
 local p=percent/100;local sigma=math.sqrt(trials*p*(1-p))
 assert(math.abs(successes-trials*p)<=math.max(1,6*sigma),'random sample outside 6-sigma band')
 print(string.format('RNG +%d: %d/%d = %.3f%% (configured %d%%)',target,successes,trials,successes/trials*100,percent))
end
print('Roblox Random sample: 900000 draws PASS; fixed QA seed 20261110')
end
do
local RS=game.ReplicatedStorage
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(RS.Shared.ItemCatalog)
local F=require(RS.Shared.EquipmentTransactions)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
local panel=Instance.new('Frame');panel.Size=UDim2.fromOffset(800,700);panel.Parent=gui
local guide=require(client.EnhancementGuide).create(panel)
guide.scroll.Size=UDim2.fromOffset(760,650);guide.scroll.Visible=true;task.wait(.1);guide.resize()
check(guide.scroll.Introduction.Body.Text:find('Max MP',1,true)and guide.scroll.Introduction.Body.Text:find('DEX',1,true),'guide includes MP and DEX')
local scroll=Instance.new('ScrollingFrame');scroll.Size=UDim2.fromOffset(800,700);scroll.Parent=gui
local notice=Instance.new('TextLabel');notice.Parent=gui
local p=assert(R.addHero(R.new(42),'hero','mage',C));p.wallet.gold=10000
assert(F.grant(p,R,C,'hero','enhancement_gem',500,'gems'));assert(F.grant(p,R,C,'hero','magic_stone',500,'stones'))
local item=assert(R.equipped(p,'hero','weapon'))
local forge=require(client.EnhancementView)
for target,percent in ipairs({100,90,80,70,60,50,40,30,20})do
 item.enhancementLevel=target-1
 local items={};for _,v in pairs(p.items)do items[#items+1]=v end
 for _,child in ipairs(scroll:GetChildren())do child:Destroy()end
 forge.render(scroll,{ready=true,heroId='hero',heroes=p.heroes,items=items,wallet=p.wallet,revision=p.revision},function()end,false,notice)
 local card=scroll:FindFirstChild(item.instanceId)
 check(card.Description.Text:find(string.format('Success: %d%% / Failure: %d%%',percent,100-percent),1,true),'forge chance matches server '..target)
 check(guide.scroll['Stage'..target].Body.Text:find(string.format('%d%% success / %d%% failure',percent,100-percent),1,true),'guide chance matches server '..target)
end
gui:Destroy()
print('Forge/guide actual UI chance QA: '..n..' checks passed')
end
