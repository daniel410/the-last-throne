local A=dofile('src/shared/AdventureRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local G=dofile('src/shared/HeroProgression.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local p=assert(R.addHero(R.new(711),'hero','knight',C))
p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
local function apply(profile,c,g,run)
 for _,step in ipairs(g.activity and g.activity.steps or {false})do
  profile=assert(A.event(profile,'hero',c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared' or nil,step and step.id or nil,R,C,run))
 end
 return profile
end
p=assert(A.begin(p,'hero','DW-01','Easy','launch',p.revision,R,C))
for i=1,7 do local c=Content.mainChapters[i]
 for _,g in ipairs(c.goals)do if not g.optional then
  if c.id=='DW-07'and g.id=='restoration'then break end
  p=apply(p,c,g,'launch')
 end end
end
local h=p.heroes.hero
check(h.deepwood.main==6 and h.deepwood.flags['DW-07:separate'],'reproduce all Deepwood combat complete, returning to Eryn')
check(not h.deepwood.clears['DW-07']and not h.deepwood.flags['DW-07:restoration'],'Eryn report is still required for story 7 completion')
check(h.expeditions.active.missionId=='DW-01'and h.expeditions.active.completed,'saved launch mission differs from current objective')
local saved=R.copy(p);local gold=p.wallet.gold;local xp=h.progression.xp
-- Recover an existing account that already acquired the unintended early replay.
local accidental=assert(A.begin(saved,'hero','DW-01','Easy','accidental',saved.revision,R,C))
for _,goal in ipairs(Content.byId['DW-01'].goals)do if not goal.optional then accidental=apply(accidental,Content.byId['DW-01'],goal,'accidental')end end
check(A.projection(accidental.heroes.hero).expeditionMission=='DW-02','reproduce the reported 2/7 replay while permanent history stays at 7/7')
local recovery=A.selection(accidental.heroes.hero)
check(recovery.missionId=='DW-07','existing accidental replay defaults back to permanent story 7')
local restored=assert(A.begin(accidental,'hero',recovery.missionId,recovery.difficultyId,'recover',accidental.revision,R,C))
check(A.projection(restored.heroes.hero).flags['DW-07:separate'],'recover Eryn checkpoint from retained permanent journal')
local choice=A.selection(h)
check(choice.missionId=='DW-07'and choice.difficultyId=='Easy','lobby defaults to saved story 7 instead of replaying story 1')
-- A new lobby departure receives a new admission ID; it must preserve checkpoints.
p=assert(A.begin(saved,'hero',choice.missionId,choice.difficultyId,'return',saved.revision,R,C))
local view=A.projection(p.heroes.hero)
check(view.main==6 and view.expeditionMission=='DW-07'and view.flags['DW-07:king_shaman']and view.flags['DW-07:separate'],'new run preserves final boss and return-to-Eryn checkpoints')
check(p.wallet.gold==gold and p.heroes.hero.progression.xp==xp,'resuming neither charges nor regrants rewards')
local revision=p.revision
p=assert(A.begin(p,'hero','DW-07','Easy','return',p.revision,R,C))
check(p.revision==revision,'repeated destination admission is idempotent')
local restoration=Content.byId['DW-07'].goals[#Content.byId['DW-07'].goals]
check(restoration.id=='restoration','fixture ends at actual Eryn report')
p=apply(p,Content.byId['DW-07'],restoration,'return')
check(p.heroes.hero.deepwood.main==7 and A.selection(p.heroes.hero).missionId=='FV-01','Eryn report completes Deepwood and lobby continues to Frozen Vale')
local paid=p.wallet.gold
p=assert(A.event(p,'hero','DW-07','restoration','shared',nil,R,C,'return'))
check(p.wallet.gold==paid,'retried Eryn report cannot pay twice')
-- Explicit replay is supported; returning during it must also retain substeps.
p=assert(A.begin(p,'hero','DW-01','Easy','replay',p.revision,R,C))
local c=Content.byId['DW-01'];p=apply(p,c,c.goals[1],'replay')
local g=c.goals[2];local step=g.activity.steps[1]
p=assert(A.event(p,'hero',c.id,g.id,nil,step.id,R,C,'replay'))
local permanent=R.copy(p.heroes.hero.deepwood);gold=p.wallet.gold
p=assert(A.begin(p,'hero','DW-01','Easy','resume_replay',p.revision,R,C))
view=A.projection(p.heroes.hero)
check(view.flags['DW-01:trail_guards']and view.activities['DW-01:supplies']==1,'same-difficulty new departure preserves replay combat and investigation substep')
check(p.heroes.hero.deepwood.main==permanent.main and p.wallet.gold==gold,'resuming replay preserves permanent clears and wallet')
local stale,reason=A.event(p,'hero','DW-01',g.id,nil,step.id,R,C,'replay')
check(not stale and reason=='AdventureChanged','old run cannot overwrite resumed checkpoint')
-- Exercise the actual network selection body, including an explicit override.
local f=assert(io.open('src/server/Network/ExpeditionService.luau'));local source=f:read('*a');f:close()
local first=assert(source:find('local function selection(p)',1,true));local last=assert(source:find('local function publish',first,true))
local selection=assert(load('return function(selections,o,RS,require,Content)\n'..source:sub(first,last-1)..'return selection end'))()({}, {inventory={expeditionHero=function()return saved.heroes.hero end}}, {Shared={AdventureRules={}}},function()return A end,Content)
check(selection({}).missionId=='DW-07','actual network lobby selection uses current saved story')
local player={};selection=assert(load('return function(selections,o,RS,require,Content)\n'..source:sub(first,last-1)..'return selection end'))()({[player]={missionId='DW-02',difficultyId='Easy'}},{},{},nil,Content)
check(selection(player).missionId=='DW-02','explicit mission selection still allows deliberate replay')
check(R.validate(p,C),'resumed profile passes complete ownership and journal validation')
-- Returning within the same Studio service must discard its old cached selection.
local firstAction=assert(source:find('function Service.beforeHeroAction',1,true))
local lastAction=assert(source:find('local function handle',firstAction,true))
local factory=assert(load('return function(role,Service,selections,travel,busy) local parties={}\n'..source:sub(firstAction,lastAction-1)..'return Service end'))()
for _,role in ipairs({'Lobby','Battle'})do
 local cache={[player]={missionId='DW-01'}};local returned=0
 local service={returnLobby=function()returned=returned+1;return true end}
 factory(role,service,cache,{},{}).beforeHeroAction(player,'ReturnLobby')
 check(cache[player]==nil,'return removes the previous mission selection in '..role)
 check(returned==(role=='Battle'and 1 or 0),'real Battle return still delegates to verified transfer')
end
for _,chapter in ipairs(Content.mainChapters)do
 for _,goal in ipairs(chapter.goals)do if not goal.optional then p=apply(p,chapter,goal,'resume_replay')end end
end
check(A.selection(p.heroes.hero).missionId=='HG-07','completed campaign defaults to final story, never its launch mission')
print('Story lobby resume: '..n..' checks passed')
