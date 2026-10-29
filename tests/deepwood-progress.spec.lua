local P=dofile('src/shared/DeepwoodProgress.luau')
local C=dofile('src/shared/DeepwoodContent.luau')
local Rules=dofile('src/server/Inventory/InventoryRules.luau')
local Catalog=dofile('src/shared/ItemCatalog.luau')
local checks=0
local function check(v,m) checks=checks+1;assert(v,m) end
local s=P.new();check(P.validate(s),'new journal')
check(not P.apply(s,'DW-07','king_shaman'),'cannot skip main chain')
check(not P.apply(s,'DW-Q2','food_clue'),'side gate')
local profile=Rules.addHero(Rules.new(93),'hero','mage',Catalog)
local totalXP,totalCoins=0,0
for _,c in ipairs(C.chapters) do if not c.side then
 for _,g in ipairs(c.goals) do if not g.optional then
  check(P.available(s,c,g),c.id..g.id..' eligible')
  local choice=g.choice and 'shared' or nil
  local nextS,err,r=P.apply(s,c.id,g.id,choice);check(nextS and not err,'progress accepted');check(P.validate(nextS),'journal valid')
  local updated,reason=Rules.story(profile,'hero',c.id,g.id,choice,Catalog);check(updated and not reason,'atomic account mutation')
  local duplicate=Rules.story(updated,'hero',c.id,g.id,choice,Catalog)
  check(duplicate.revision==updated.revision,'duplicate no second account write')
  check(duplicate.heroes.hero.progression.xp==updated.heroes.hero.progression.xp,'duplicate XP receipt')
  profile=updated;s=nextS;totalXP=totalXP+r.xp;totalCoins=totalCoins+r.coins
 end end
end end
check(s.main==7 and s.choice=='shared','epic ending')
check(totalXP==1173 and totalCoins==2290,'approved quest XP and Coins exact')
check(profile.heroes.hero.deepwood.coins==2290,'same-write balance')
check(profile.items['hero-DW-05-bossseal'].definitionId=='warlord_seal','warlord seal once')
check(profile.items['hero-DW-07-bossseal'].quantity==1,'king seal once')
check(profile.items['hero-DW-01-equipment'].location.kind=='pending','bag full safe grant')
check(not profile.heroes.hero.deepwood.flags['DW-07:rescue_captives'],'rescue optional')
local after=P.apply(s,'DW-07','restoration','sanctuary');check(after.choice=='shared','ending immutable on duplicate')
for _,c in ipairs(C.chapters) do if c.side then for _,g in ipairs(c.goals) do
 if not g.optional then s=assert(P.apply(s,c.id,g.id));check(P.validate(s),'side preserves bounded journal') end
end end end
check(s.coins==2290 and s.main==7,'side rewards not invented')
local broken=P.copy(s);broken.main=8;check(not P.validate(broken),'reject invalid main')
broken=P.copy(s);broken.flags['DW-01:forged']=true;check(not P.validate(broken),'reject unknown objective')
broken=P.copy(s);broken.coins=2291;check(not P.validate(broken),'reject forged Coins')
local saved=Rules.copy(profile);saved.heroes.hero.deepwood=nil
check(Rules.validate(saved,Catalog),'old profile remains compatible')
-- Two non-linear devices may be completed in either order.
local branch=P.new();branch.main=3
for i=1,3 do local c=C.chapters[i];branch.clears[c.id]=true;branch.coins=branch.coins+c.reward.coins;for _,g in ipairs(c.goals) do branch.flags[c.id..':'..g.id]=true end end
branch=assert(P.apply(branch,'DW-04','courtyard'));branch=assert(P.apply(branch,'DW-04','east_link'))
check(not P.available(branch,C.byId['DW-04'],P.goal(C.byId['DW-04'],'spirit')),'one device cannot free spirit')
branch=assert(P.apply(branch,'DW-04','west_link'));check(P.available(branch,C.byId['DW-04'],P.goal(C.byId['DW-04'],'spirit')),'both devices free spirit')
print('Deepwood progression: '..checks..' checks passed')
-- A committed-but-unacknowledged story write retries the same permanent flag.
local Store=dofile('src/server/Inventory/AccountStore.luau')
local db,failAfterCommit={},false
local store=Store.new({UpdateAsync=function(_,key,transform)
 local n=transform(db[key] and Rules.copy(db[key]));if n then db[key]=Rules.copy(n) end
 if failAfterCommit then error('transport failed after commit') end
 return n
end},Rules,Catalog,function() return 1000 end,function() end,'story-test')
assert(store:open(93));assert(store:transact(93,function(p) return Rules.addHero(p,'retry','knight',Catalog) end))
failAfterCommit=true
local unknown,reason=store:transact(93,function(p) return Rules.story(p,'retry','DW-01','trail_guards',nil,Catalog) end)
check(not unknown and reason=='SaveUnknown','unknown response preserved')
failAfterCommit=false
local recovered=assert(store:transact(93,function(p) return Rules.story(p,'retry','DW-01','trail_guards',nil,Catalog) end))
check(recovered.heroes.retry.deepwood.flags['DW-01:trail_guards'],'same flag recovered')
local revision=recovered.revision
recovered=assert(store:transact(93,function(p) return Rules.story(p,'retry','DW-01','trail_guards',nil,Catalog) end))
check(recovered.revision==revision,'unknown retry cannot mint duplicate receipt')
local before=recovered.heroes.retry.deepwood.killCoins
local command={action='AwardXP',heroId='retry',stream='native-trial',sequence=1,amount=18,coins=5,rewardKind='Defeat'}
local reward=assert(Rules.progress(recovered,command,{serverReward=true},Catalog))
check(reward.heroes.retry.deepwood.killCoins==(before or 0)+5,'combat Coins atomically awarded')
local repeated=assert(Rules.progress(reward,command,{serverReward=true},Catalog))
check(repeated.heroes.retry.deepwood.killCoins==reward.heroes.retry.deepwood.killCoins,'combat Coins duplicate sequence denied')
print('Deepwood total: '..checks..' checks passed')
