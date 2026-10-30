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
  local nextS,err,r,updated,reason
  if g.activity and g.activity.steps then
   check(not P.apply(s,c.id,g.id,choice),'cannot skip spatial activity')
   local steps=g.activity.steps
   if #steps>1 and g.activity.mode~='investigate' then check(not P.apply(s,c.id,g.id,nil,steps[2].id),'ordered activity cannot start with later step') end
   for i,step in ipairs(steps) do
    local answer=step.choices and step.choices[1].id
    if step.choices then check(not P.apply(s,c.id,g.id,'forged',step.id),'invalid answer rejected') end
    nextS,err,r=P.apply(s,c.id,g.id,answer,step.id);check(nextS and not err,'activity substep accepted');check(P.validate(nextS),'saved substep valid')
    updated,reason=Rules.story(profile,'hero',c.id,g.id,answer,Catalog,step.id);check(updated and not reason,'substep atomic account mutation')
    local replay=Rules.story(updated,'hero',c.id,g.id,answer,Catalog,step.id);check(replay.revision==updated.revision,'substep retry cannot duplicate receipt')
    if i<#steps then check(r.xp==0 and r.coins==0 and not nextS.flags[c.id..':'..g.id],'partial activity gives no completion reward') end
    profile=updated;s=nextS;totalXP=totalXP+r.xp;totalCoins=totalCoins+r.coins
   end
  else
   nextS,err,r=P.apply(s,c.id,g.id,choice);check(nextS and not err,'progress accepted');check(P.validate(nextS),'journal valid')
   updated,reason=Rules.story(profile,'hero',c.id,g.id,choice,Catalog);check(updated and not reason,'atomic account mutation')
   totalXP=totalXP+r.xp;totalCoins=totalCoins+r.coins
  end
  local duplicate=Rules.story(updated,'hero',c.id,g.id,choice,Catalog)
  check(duplicate.revision==updated.revision,'duplicate no second account write')
  check(duplicate.heroes.hero.progression.xp==updated.heroes.hero.progression.xp,'duplicate XP receipt')
  profile=updated;s=nextS
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
for _,c in ipairs(C.chapters) do if c.side then s=assert(P.accept(s,c.id));for _,g in ipairs(c.goals) do
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

local Access=dofile('src/shared/DeepwoodAccess.luau')
for id,z in pairs(C.zones) do
 check(Access.region(z.center[1],z.center[3])==id,'region nearest anchor')
 check(not Access.allowed({main=z.requiresMain-1},id),'preceding story required')
 check(Access.allowed({main=z.requiresMain},id),'region opens after required story')
 local x,y=Access.cell(id,z.center[1],z.center[3]);check(x==7 and y==7,'server discovery grid')
end
local fog=P.new();check(not P.reveal(fog,'DW-02',1,1),'locked region cannot be revealed')
fog=assert(P.reveal(fog,'DW-01',6,6));local known=0;for _ in pairs(fog.explored['DW-01']) do known=known+1 end
check(known==9,'reveal local neighborhood without revealing whole region')
local copy,reason,repeated=P.reveal(fog,'DW-01',6,6);check(repeated and copy.coins==0,'fog replay immutable reward')
check(not P.reveal(fog,'DW-01',0,4) and not P.reveal(fog,'DW-01',13,4),'bounded fog cells')
local forged=P.copy(fog);forged.explored['DW-02']={[1]=true};check(not P.validate(forged),'forged locked fog denied')
local legacy=P.copy(s);legacy.activities=nil;legacy.decisions=nil;legacy.explored=nil;legacy.clues=nil;check(P.validate(legacy),'old completed journal does not reset')
local partial=assert(store:transact(93,function(p) return Rules.story(p,'retry','DW-01','supplies',nil,Catalog,'manifest') end))
check(not partial.heroes.retry.deepwood.flags['DW-01:supplies'],'saved first clue does not complete activity')
failAfterCommit=true
local unknown=store:transact(93,function(p) return Rules.story(p,'retry','DW-01','supplies',nil,Catalog,'bindings') end)
check(not unknown,'partial clue unknown result')
failAfterCommit=false
local resumed=assert(store:transact(93,function(p) return Rules.story(p,'retry','DW-01','supplies',nil,Catalog,'bindings') end))
check(resumed.heroes.retry.deepwood.activities['DW-01:supplies']==2,'unknown clue retry resumes exact step')
check(not resumed.heroes.retry.deepwood.flags['DW-01:supplies'],'retry cannot auto complete final clue')
print('Deepwood extended total: '..checks..' checks passed')
