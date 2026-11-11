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
