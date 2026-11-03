local E=dofile('src/shared/RewardEconomy.luau');local D=dofile('src/shared/Difficulty.luau');local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/ExpeditionPresentation.luau');local R=dofile('src/server/Inventory/InventoryRules.luau');local C=dofile('src/shared/ItemCatalog.luau');local F=dofile('src/shared/EquipmentTransactions.luau');local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
for _,boundary in ipairs({20,40,60,80})do
 check(E.band(boundary-1).level<boundary and E.band(boundary).level==boundary,'level band boundary')
end
check(E.band(106).level==80,'enemy levels above hero cap cannot inflate reward band without limit')
for _,mode in ipairs(D.order)do
 local previousGems,previousStones=0,0
 for _,level in ipairs({1,20,40,60,80})do local gems,stones=E.materials(level,mode)
  check(gems>=previousGems and stones>=previousStones and gems>0 and stones>0,'all levels retain a free source of both materials')
  previousGems,previousStones=gems,stones
 end
end
local p=assert(R.addHero(R.new(42),'hero','knight',C));p.wallet.gold=10000;p.wallet.diamonds=77
local function quantity(id)return R.quantity(p,'hero',id)end
local initialOre,initialCore=quantity('iron_ore'),quantity('forge_core')
check(quantity('enhancement_gem')==0 and quantity('magic_stone')==0,'old materials never auto-convert on load')
local one=P.missions(p.heroes.hero)[1].modes.Easy
p.heroes.hero.level=80;p.heroes.hero.progression=dofile('src/shared/HeroProgression.luau').new(80)
local high=P.missions(p.heroes.hero)[1].modes.Easy
check(high.gems==one.gems and high.stones==one.stones and high.repeatGold==one.repeatGold,'high-level visitor cannot inflate easy mission rewards')
check(D.completion(Content.byId['DW-01'],'Hell').rewardBand==80,'mode level lifts appropriate material band')
local beforeGems=quantity('enhancement_gem')
local function command(action,id)
 return {action=action,store='blacksmith',heroId='hero',requestId=id,revision=p.revision}
end
local convert=command('ConvertOre','convert');p=assert(R.shop(p,convert,{atLobby=true},C))
check(quantity('iron_ore')==initialOre-1 and quantity('enhancement_gem')==beforeGems+1,'explicit 1:1 conversion consumes only requested old item')
p=assert(R.shop(p,convert,{atLobby=true},C));check(quantity('enhancement_gem')==1,'conversion retry cannot duplicate gems')
F.grant(p,R,C,'hero','enhancement_gem',30,'fixture-gems');F.grant(p,R,C,'hero','magic_stone',5,'fixture-stones')
local gems,stones,gold=quantity('enhancement_gem'),quantity('magic_stone'),p.wallet.gold
local exchange=command('ExchangeStone','exchange');p=assert(R.shop(p,exchange,{atLobby=true},C))
check(quantity('enhancement_gem')==gems-5 and quantity('magic_stone')==stones+1 and p.wallet.gold==gold-50,'new material exchange uses gems and RPG Gold')
check(p.wallet.diamonds==77 and quantity('forge_core')==initialCore,'new economy never consumes Diamonds or old cores')
local item
for _,v in pairs(p.items)do if v.definitionId=='knight_weapon_fine'and v.location.kind=='bag'then item=v;break end end
-- Preserve one historical paid step and add a modern paid step to the same item.
item.enhancementLevel=1;item.enhancementPaid={ore=2,cores=0}
check(R.validate(p,C),'legacy investment ledger still validates')
local ore=quantity('iron_ore');gems=quantity('enhancement_gem')
local enhance=command('Enhance','enhance');enhance.instanceId=item.instanceId;enhance.itemVersion=item.version
p=assert(R.shop(p,enhance,{atLobby=true},C));item=p.items[item.instanceId]
check(quantity('iron_ore')==ore and quantity('enhancement_gem')==gems-4,'new upgrade consumes new gems while preserving old stock')
check(item.enhancementPaid.ore==2 and item.enhancementPaidV2.gems==4,'separate old and modern ledgers retained')
local recover=command('Recover','recover');recover.instanceId=item.instanceId;recover.itemVersion=item.version
ore=quantity('iron_ore');gems=quantity('enhancement_gem');p=assert(R.shop(p,recover,{atLobby=true},C))
check(quantity('iron_ore')==ore+1 and quantity('enhancement_gem')==gems+3,'mixed recovery refunds each original material separately')
p=assert(R.shop(p,recover,{atLobby=true},C));check(quantity('iron_ore')==ore+1 and quantity('enhancement_gem')==gems+3,'mixed recovery is idempotent')
-- Unknown committed write recovers the same conversion without double debit.
local saved;local fail=false;local adapter={UpdateAsync=function(_,_,fn)local nextP=fn(R.copy(saved));if nextP then saved=R.copy(nextP)end;if fail then error('lost reply')end;return R.copy(nextP)end}
local store=Store.new(adapter,R,C,function()return 100 end,function()end,'material-test');assert(store:open(42))
assert(store:transact(42,function(current)local fixture=R.copy(p);fixture.lease=current.lease;fixture.epoch=current.epoch;return fixture end))
local lost=command('ConvertOre','lost');ore=quantity('iron_ore');gems=quantity('enhancement_gem');fail=true
local no,why=store:transact(42,function(current)return R.shop(current,lost,{atLobby=true},C)end)
check(not no and why=='SaveUnknown','conversion response loss stays unknown')
fail=false;p=assert(store:transact(42,function(current)return R.shop(current,lost,{atLobby=true},C)end))
check(quantity('iron_ore')==ore-1 and quantity('enhancement_gem')==gems+1,'unknown conversion recovers exactly once')
local locked
for _,v in pairs(p.items)do if v.definitionId=='enhancement_gem'then v.locked=true;locked=v end end
local rejected=command('ExchangeStone','locked');no,why=R.shop(p,rejected,{atLobby=true},C)
check(not no and why=='EnhancementMaterials','locked gems cannot pay')
check(p.wallet.diamonds==77,'Diamonds remain isolated after all material transactions')
print('Reward materials: '..n..' checks passed')
