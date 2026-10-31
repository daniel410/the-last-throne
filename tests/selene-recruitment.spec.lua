local P=dofile('src/shared/DeepwoodProgress.luau')
local C=dofile('src/shared/DeepwoodContent.luau')
local Rules=dofile('src/server/Inventory/InventoryRules.luau')
local Catalog=dofile('src/shared/ItemCatalog.luau')
local Budget=dofile('src/shared/SeleneSupport.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0;local function check(v,m) checks=checks+1;assert(v,m) end
local profile=Rules.addHero(Rules.new(93),'hero','mage',Catalog)
check(not Rules.selectSelene(profile,'hero',true),'cannot recruit before rescue')
check(not Rules.selectSelene(profile,'stranger',true),'cannot select unowned hero')
local function apply(c,g,step,choice)
 profile=assert(Rules.story(profile,'hero',c.id,g.id,choice,Catalog,step))
end
for _,c in ipairs(C.chapters) do if not c.side then
 for _,g in ipairs(c.goals) do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {}) do
   apply(c,g,step.id,step.choices and step.choices[1].id)
   if c.id=='DW-03' and g.id=='report' and step.id=='account' then check(not P.seleneUnlocked(profile.heroes.hero.deepwood),'partial report never unlocks companion') end
  end
  if not (g.activity and g.activity.steps) then apply(c,g,nil,g.choice and 'shared' or nil) end
  if c.id=='DW-03' and g.id=='report' then
   local s=profile.heroes.hero.deepwood
   check(P.seleneUnlocked(s) and s.main==2,'safe-camp report unlocks before story3 completion')
   check(not s.seleneFollowing,'recruitment never forces selection')
   local before=Rules.copy(profile)
   profile=assert(Rules.selectSelene(profile,'hero',true));check(profile.revision==before.revision+1 and P.validate(profile.heroes.hero.deepwood),'selected preference is valid')
   check(profile.wallet.gold==before.wallet.gold and profile.heroes.hero.progression.xp==before.heroes.hero.progression.xp,'no new Gold or XP')
   local same=assert(Rules.selectSelene(profile,'hero',true));check(same.revision==profile.revision,'repeat invite is idempotent')
   profile=assert(Rules.selectSelene(profile,'hero',false));check(not profile.heroes.hero.deepwood.seleneFollowing and P.seleneUnlocked(profile.heroes.hero.deepwood),'rest never revokes unlock')
   check(not Rules.selectSelene(profile,'hero','true'),'invalid preference rejected')
   local legacy=P.copy(profile.heroes.hero.deepwood);legacy.seleneFollowing=nil;check(P.seleneUnlocked(legacy) and P.validate(legacy),'old rescued profiles derive same unlock without reset')
  end
 end end
end end
check(profile.heroes.hero.deepwood.main==7 and profile.heroes.hero.deepwood.coins==2290,'whole revised epic completes without Selene at exact rewards')
check(C.byId['DW-07'].quest.outcome:find('Frozen Vale',1,true),'ending points north')
local bad=P.new();bad.seleneFollowing=true;check(not P.validate(bad),'forged unlocked preference rejected')
local db={};local fail=false
local store=Store.new({UpdateAsync=function(_,key,f)
 local v=f(db[key] and Rules.copy(db[key]));if v then db[key]=Rules.copy(v) end
 if fail then error('response lost') end;return v
end},Rules,Catalog,function() return 1000 end,function() end,'selene-test')
assert(store:open(93));assert(store:transact(93,function(current) local n=Rules.copy(profile);n.lease=current.lease;n.epoch=current.epoch;return n end))
fail=true;local value,reason=store:transact(93,function(v) return Rules.selectSelene(v,'hero',true) end)
check(not value and reason=='SaveUnknown','unknown write never confirms selection')
fail=false;value=assert(store:transact(93,function(v) return Rules.selectSelene(v,'hero',true) end))
check(value.heroes.hero.deepwood.seleneFollowing and value.wallet.gold==profile.wallet.gold,'same request recovers acknowledged preference without payment')
local revision=value.revision;value=assert(store:transact(93,function(v) return Rules.selectSelene(v,'hero',true) end));check(value.revision==revision,'retry cannot duplicate commit')
check(Budget.limit(1)==2 and Budget.limit(2)==2 and Budget.limit(3)==1 and Budget.limit(4)==1,'party budgets exact')
check(Budget.action(0,100,true,true)==nil,'cannot revive dead player')
check(Budget.action(30,100,true,true)=='Cleanse','cleanse priority')
check(Budget.action(30,100,false,true)=='Heal','limited healing next')
check(Budget.action(100,100,false,true)=='Protect','protection only with danger')
check(Budget.action(100,100,false,false)==nil,'idle supporter never adds unused effects')
print('Selene recruitment: '..checks..' checks passed')
