-- Exercise the real inventory projection, bootstrap resolver and story destination.
local A=dofile('src/shared/AdventureRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local G=dofile('src/shared/HeroProgression.luau')
local function body(path,first,last)
 local f=assert(io.open(path));local s=f:read('*a');f:close()
 local start=assert(s:find(first,1,true));return s:sub(start,assert(s:find(last,start,true))-1)
end
local makeState=assert(load('return function(accounts,Rules,ReplicatedStorage,require) local Service={}\n'..body('src/server/Inventory/InventoryService.luau','function Service.storyState','-- All support Gold')..'return Service.storyState end'))()
local makeDestination=assert(load('return function(options,state,Content) local Service={}\n'..body('src/server/Story/DeepwoodService.luau','function Service.destination','local function enqueue')..'return Service.destination end'))()
local resolver=body('src/server/init.server.luau',' resolveDestination=function(player,previous)',' end,onLifeStarted')..' end'
local makeResolver=assert(load('return function(heroSession,world,story) local '..resolver..' return resolveDestination end'))()
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local phase='Tutorial';local player={GetAttribute=function()return phase end}
local profile=assert(R.addHero(R.new(713),'hero','knight',C))
profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
profile=assert(A.begin(profile,'hero','DW-01','Easy','journey',profile.revision,R,C))
local function apply(c,g)
 for _,step in ipairs(g.activity and g.activity.steps or {false})do
  profile=assert(A.event(profile,'hero',c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared' or nil,step and step.id or nil,R,C,'journey'))
 end
end
for i=1,3 do for _,g in ipairs(Content.mainChapters[i].goals)do if not g.optional then apply(Content.mainChapters[i],g)end end end
apply(Content.byId['DW-04'],Content.byId['DW-04'].goals[1])
check(profile.heroes.hero.expeditions.active.missionId=='DW-01','fixture entered through story 1')
check(A.projection(profile.heroes.hero).expeditionMission=='DW-04','fixture advanced to story 4')
local account={profile=profile};local accounts={[player]=account}
local shared={AdventureRules={}}
local storyState=makeState(accounts,R,{Shared=shared},function(module)check(module==shared.AdventureRules,'real projection dependency');return A end)
local spawns={};for id in pairs(Content.zones)do spawns[id]={id=id}end
local inventory={storyState=storyState,expedition=function()return account.profile.heroes.hero.expeditions.active end}
local destination=makeDestination({inventory=inventory,world={spawns=spawns}},storyState,Content)
local active={heroId='hero',training=false}
local resolve=makeResolver({getActiveHero=function()return active end},{spawn={id='training'}},{destination=destination})
local original=R.copy(profile)
for _,value in ipairs({'Tutorial','Respawning','LoadingTutorial'})do
 phase=value
 check(storyState(player,'hero').expeditionMission=='DW-04',value..' retains current story projection')
 check(resolve(player,spawns['DW-01'])==spawns['DW-04'],value..' resolves current story instead of stale launch checkpoint')
 check(storyState(player,'hero').flags['DW-04:courtyard'],'completed story4 objective survives death/loading')
end
check(profile.revision==original.revision and profile.wallet.gold==original.wallet.gold,'destination resolution grants no reward or journal mutation')
-- Replay progress may differ from permanent clears; respawn must use the replay.
profile=assert(A.begin(profile,'hero','DW-01','Easy','replay',profile.revision,R,C));account.profile=profile
phase='Respawning'
check(storyState(player,'hero').main==0 and profile.heroes.hero.deepwood.main==3,'death preserves replay journal independently of permanent progress')
check(resolve(player,spawns['DW-04'])==spawns['DW-01'],'deliberate replay respawns in replay story')
phase='Lobby'
check(storyState(player,'hero').main==3 and storyState(player,'hero').expeditionMission==nil,'lobby retains permanent history')
check(resolve(player,spawns['DW-03'])==spawns['DW-03'],'lobby route remains unchanged')
phase='Respawning';active.training=true
check(resolve(player,spawns['DW-01']).id=='training','training death retains training spawn')
print('Story respawn: '..n..' checks passed')
