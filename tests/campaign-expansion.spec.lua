-- Current expansion, historical runs and account invariants, not simulated play time.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,P,A,D,G,Log=load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('Difficulty'),load('HeroProgression'),load('DeepwoodQuestLog')
local R=dofile('src/server/Inventory/InventoryRules.luau');local Items=load('ItemCatalog');local Store=dofile('src/server/Inventory/AccountStore.luau')
local CP,Bounds,Areas,Guide=load('CheckpointTravel'),load('CampaignBounds'),load('CampaignAreas'),load('LobbySideQuests')
local Party=dofile('src/server/Story/PartyStory.luau');local Recovery=load('CampaignExpansionCheckpoints')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function eq(a,b)if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end;for k,v in pairs(a)do if not eq(v,b[k])then return false end end;for k in pairs(b)do if a[k]==nil then return false end end;return true end
local function profile(user,class)
 local p=assert(R.addHero(R.new(user or 192),'hero',class or 'knight',Items));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80);return p
end
local function steps(g,fn)
 for _,s in ipairs(g.activity and g.activity.steps or {false})do fn(s and s.choices and s.choices[1].id or g.choice and 'shared',s and s.id or nil)end
end
local main=profile();local prefixes={[0]=R.copy(main)}
for _,c in ipairs(C.mainChapters)do for _,g in ipairs(c.coreGoals)do if not g.optional then steps(g,function(choice,id)main=assert(R.story(main,'hero',c.id,g.id,choice,Items,id))end)end end;prefixes[c.number]=R.copy(main)end
check(main.wallet.gold==19170,'existing first main Gold unchanged')
local eventCount,stepCount,oldBattles=0,0,0
for _,c in ipairs(C.chapters)do
 local legacy=P.new();local z=C.zones[c.zone];local seen={}
 for _,g in ipairs(c.goals)do check(not seen[g.id],'unique goal '..c.id..g.id);seen[g.id]=true end
 for _,g in ipairs(c.coreGoals)do
  local actual=P.goal(c,g.id);check(eq(actual.enemies,g.enemies),'enemy budget unchanged '..c.id..g.id)
  check(eq(actual.position,g.position),'original anchor unchanged '..c.id..g.id)
  if #g.enemies>0 then oldBattles=oldBattles+1 end
 end
 for _,g in ipairs(c.expansionGoals)do
  eventCount=eventCount+1;check(g.optional and g.expansion and #g.enemies==0,'legacy exclusion and zero extra kill rewards')
  check(not P.available(legacy,c,g),'legacy journal never requires new incident')
  for _,s in ipairs(g.activity.steps)do
   stepCount=stepCount+1;check(Areas.containsZone(z,s.position[1],s.position[3]),'new step on authoritative footprint')
   check(Bounds.supported(s.position[1],s.position[2]+3,s.position[3]),'new step has supported authority floor')
   check(s.title~=''and s.text~='','authored action and feedback')
  end
 end
end
check(eventCount==82 and stepCount==246,'all 35 main and 12 side expansions authored')
-- Every old save frontier imports past events without deleting progress or paying again.
for frontier=0,35 do
 local base=prefixes[frontier].heroes.hero.deepwood or P.new();local expanded=assert(P.enableExpansion(base))
 check(P.validate(expanded),'valid import at frontier '..frontier)
 check(expanded.main==base.main and expanded.coins==base.coins,'preserve old clears/ledger '..frontier)
 for k,v in pairs(base.flags)do check(expanded.flags[k]==v,'preserve original flag')end
 for _,c in ipairs(C.mainChapters)do if base.clears[c.id]then
  for _,g in ipairs(c.expansionGoals)do check(expanded.flags[c.id..':'..g.id]and expanded.expansionWaivers[c.id..':'..g.id],'completed chapter waived without replay')end
 end end
end
-- One admitted current run traverses all five regions with saved substeps.
local p=profile();p=assert(A.begin(p,'hero','DW-01','Easy','expanded-main',p.revision,R,Items))
check(A.projection(p.heroes.hero).expansionVersion==1,'new run enables expansion')
local partial
for _,c in ipairs(C.mainChapters)do
 for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)then
  local view=A.projection(p.heroes.hero)
  if g.expansion then
   local base=P.goal(c,g.before);local first=base.activity and base.activity.steps and base.activity.steps[1]
   local skipped=A.event(p,'hero',c.id,base.id,base.choice and 'shared',first and first.id,R,Items,'expanded-main')
   check(not skipped,'core objective cannot skip incident '..c.id..g.id)
   check(not CP.allowed(view,'exit:'..c.id..':'..g.id),'shortcut locked until incident completion')
  end
  steps(g,function(choice,id)
   local before=R.copy(p);p=assert(A.event(p,'hero',c.id,g.id,choice,id,R,Items,'expanded-main'))
   check(R.validate(p,Items),'valid account after confirmed step')
   check(eq(assert(A.event(p,'hero',c.id,g.id,choice,id,R,Items,'expanded-main')),p),'duplicate step pays/advances once')
   if g.expansion then
    check(p.wallet.gold==before.wallet.gold,'incidents do not mint Gold')
    check(eq(p.items,before.items),'incidents do not mint materials')
    local journal=A.projection(p.heroes.hero);check(Recovery.respawn(journal,c)~=nil,'confirmed incident has safe resume')
    partial=partial or R.copy(p)
   end
  end)
  if g.expansion then
   local journal=A.projection(p.heroes.hero);local checkpoint=CP.allowed(journal,c.id..':'..g.id)
   check(checkpoint and checkpoint.position,'saved incident unlocks local checkpoint')
   check(CP.allowed(journal,'exit:'..c.id..':'..g.id),'saved incident unlocks main-route return')
  end
 end end
 check(p.heroes.hero.deepwood.clears[c.id],'expanded story completes '..c.id)
end
check(p.heroes.hero.deepwood.main==35 and p.wallet.gold==main.wallet.gold,'expanded ending and main budget match legacy')
local legacyRun=profile();legacyRun=assert(A.begin(legacyRun,'hero','DW-01','Easy','expanded-main',legacyRun.revision,R,Items,12))
for _,oldChapter in ipairs(C.mainChapters)do for _,oldGoal in ipairs(oldChapter.coreGoals)do if not oldGoal.optional then steps(oldGoal,function(choice,id)legacyRun=assert(A.event(legacyRun,'hero',oldChapter.id,oldGoal.id,choice,id,R,Items,'expanded-main'))end)end end end
check(eq(p.items,legacyRun.items),'expanded main preserves the same run item rights')
check(not CP.allowed(A.projection(p.heroes.hero),'exit:DW-01:forged'),'forged shortcut rejected')
-- All twelve side quests retain the same field/Tessa report and original reward rights.
for _,c in ipairs(C.chapters)do if c.side then
 local before=R.copy(p);local run='side-'..c.id
 p=assert(A.begin(p,'hero',c.id,'Easy',run,p.revision,R,Items))
 for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)and g.id~=c.quest.turnIn then
  if g.expansion then check(not Guide.apply(p,{action='Report',heroId='hero',questId=c.id,runId=run},R,Items),'Tessa cannot skip expanded field work')end
  steps(g,function(choice,id)p=assert(A.event(p,'hero',c.id,g.id,choice,id,R,Items,run))end)
 end end
 local expected=assert(A.event(p,'hero',c.id,c.quest.turnIn,nil,nil,R,Items,run))
 p=assert(Guide.apply(p,{action='Report',heroId='hero',questId=c.id,runId=run},R,Items))
 check(eq(p,expected),'expanded Tessa/field result identical '..c.id)
 check(p.wallet.gold-before.wallet.gold==c.reward.coins,'side fixed award unchanged '..c.id)
 check(R.validate(p,Items),'side account valid '..c.id)
end end
-- Old rules remain runnable with the original objectives only.
for version=1,12 do
 local legacy=profile(200+version)
 legacy=assert(A.begin(legacy,'hero','DW-01','Easy','legacy-'..version,legacy.revision,R,Items,version))
 check(A.projection(legacy.heroes.hero).expansionVersion==nil,'old pinned run has no new mandatory content')
 for _,g in ipairs(C.byId['DW-01'].coreGoals)do if not g.optional then steps(g,function(choice,id)legacy=assert(A.event(legacy,'hero','DW-01',g.id,choice,id,R,Items,'legacy-'..version))end)end end
 check(legacy.heroes.hero.deepwood.clears['DW-01'],'old rules complete without expansion '..version)
end
-- Current replay of an old completion requires the new incidents, not a new first award.
local replay=assert(A.begin(main,'hero','FV-04','Easy','replay-expanded',main.revision,R,Items))
for _,g in ipairs(C.byId['FV-04'].goals)do if P.required(A.projection(replay.heroes.hero),g)then steps(g,function(choice,id)replay=assert(A.event(replay,'hero','FV-04',g.id,choice,id,R,Items,'replay-expanded'))end)end end
check(replay.wallet.gold-main.wallet.gold==D.completion(C.byId['FV-04'],'Easy',13).gold,'expanded replay uses existing repeat budget')
-- Migrated old-order completion can return from an expanded replay into the GW gap.
local old=P.new();old.version=1
for i=1,21 do local chapter=C.legacyMainChapters[i];for _,goal in ipairs(chapter.coreGoals)do if not goal.optional then steps(goal,function(choice,id)old=assert(P.apply(old,chapter.id,goal.id,choice,id))end)end end end
local backward=profile(991);backward.heroes.hero.deepwood=assert(P.upgrade(old))
backward=assert(A.begin(backward,'hero','FV-07','Easy','expanded-backward',backward.revision,R,Items))
for _,goal in ipairs(C.byId['FV-07'].goals)do if P.required(A.projection(backward.heroes.hero),goal)then steps(goal,function(choice,id)backward=assert(A.event(backward,'hero','FV-07',goal.id,choice,id,R,Items,'expanded-backward'))end)end end
local resumed=A.projection(backward.heroes.hero)
check(resumed.expeditionMission=='GW-01'and resumed.expansionVersion==1,'current replay returns to expanded GW gap')
for _,goal in ipairs(C.byId['GW-01'].goals)do if P.required(A.projection(backward.heroes.hero),goal)then steps(goal,function(choice,id)backward=assert(A.event(backward,'hero','GW-01',goal.id,choice,id,R,Items,'expanded-backward'))end)end end
check(backward.heroes.hero.deepwood.clears['GW-01']and backward.heroes.hero.deepwood.clears['FV-07'],'backward expanded first-clear preserves old completion')
check(eq(assert(A.event(backward,'hero','GW-01','lantern',nil,'confirmed',R,Items,'expanded-backward')),backward),'backward retry remains idempotent')
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local candidate=profile(992,class)
 for i=1,14 do local chapter=C.mainChapters[i];for _,goal in ipairs(chapter.coreGoals)do if not goal.optional then steps(goal,function(choice,id)candidate=assert(R.story(candidate,'hero',chapter.id,goal.id,choice,Items,id))end)end end end
 local run='class-'..class;candidate=assert(A.begin(candidate,'hero','FV-01','Easy',run,candidate.revision,R,Items))
 for _,goal in ipairs(C.byId['FV-01'].goals)do if P.required(A.projection(candidate.heroes.hero),goal)then steps(goal,function(choice,id)candidate=assert(A.event(candidate,'hero','FV-01',goal.id,choice,id,R,Items,run))end)end end
 check(candidate.heroes.hero.deepwood.clears['FV-01']and R.validate(candidate,Items),'all classes can use expanded incidents without support '..class)
end
-- A saved substep with a lost UpdateAsync response recovers the same run event.
local saved=R.copy(partial);saved.lease=nil;local lose=false
local adapter={UpdateAsync=function(_,_,fn)local a,b=fn(R.copy(saved)),fn(R.copy(saved));check(eq(a,b),'callback replay pure');saved=b or saved;if lose then error('lost reply')end;return R.copy(saved)end}
local store=Store.new(adapter,R,Items,function()return 500 end,function()end,'expansion-test');check(store:open(saved.userId)~=nil,'recovery store opened')
local c=C.byId['DW-01'];local g=c.expansionGoals[1];local cmd=function(current)return A.event(current,'hero',c.id,g.id,nil,'step2',R,Items,'expanded-main')end
lose=true;local failed,why=store:transact(saved.userId,cmd);check(not failed and why=='SaveUnknown','unknown reply is not treated as a new profile')
local committed=R.copy(saved);lose=false;local recovered=assert(store:transact(saved.userId,cmd))
check(eq(recovered.heroes.hero.deepwood,committed.heroes.hero.deepwood),'confirmed substep survives reconnect')
check(recovered.wallet.gold==committed.wallet.gold and eq(recovered.items,committed.items),'recovery creates no extra reward')
-- Party progress shares only server-confirmed events in the same admitted run.
local people={{id=1},{id=2},{id=3},{id=4},{id=5}};local profiles={}
for i in ipairs(people)do profiles[i]=assert(A.begin(prefixes[3],'hero','DW-04','Easy',i==5 and 'other-party'or 'expanded-party',prefixes[3].revision,R,Items))end
local party=Party.create({players=function()return people end,active=function(person)return {heroId='hero'}end,
 state=function(person)return A.projection(profiles[person.id].heroes.hero)end,run=function(person)return profiles[person.id].heroes.hero.expeditions.active end,
 available=P.available,canAccept=P.canAccept,collected=P.collected,enqueue=function(person,heroId,c,g,choice,id)profiles[person.id]=assert(A.event(profiles[person.id],heroId,c.id,g.id,choice,id,R,Items,'expanded-party'))end})
local chapter=C.byId['DW-04']
for _,g in ipairs(chapter.goals)do if P.required(A.projection(profiles[1].heroes.hero),g)then steps(g,function(choice,id)party.enqueue(people[1],'hero',chapter,g,choice,id)end)end end
for i=1,4 do check(profiles[i].heroes.hero.deepwood.clears['DW-04'],'four-player incident progression '..i)end
check(not profiles[5].heroes.hero.deepwood.clears['DW-04'],'other run receives no party events')
print('CAMPAIGN_EXPANSION '..checks..' checks passed; 35 main / 12 side / 82 incidents / 246 new steps')
