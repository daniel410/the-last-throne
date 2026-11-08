local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local profile=assert(R.addHero(R.new(712),'hero','elf',C))
profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
local function clear(c,run)
 for _,g in ipairs(c.goals)do if P.required(run and A.projection(profile.heroes.hero)or profile.heroes.hero.deepwood or P.new(),g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   local choice=step and step.choices and step.choices[1].id or g.choice and 'shared' or nil
   if run then profile=assert(A.event(profile,'hero',c.id,g.id,choice,step and step.id or nil,R,C,run))
   else profile=assert(R.story(profile,'hero',c.id,g.id,choice,C,step and step.id or nil))end
  end
 end end
end
for i=1,7 do clear(Content.mainChapters[i])end
check(A.selection(profile.heroes.hero).missionId=='GW-01','Deepwood complete continues to Gloamwood in lobby')
-- Reproduce a separate Waterfall Quarry departure after clearing Deepwood.
profile=assert(A.begin(profile,'hero','DW-Q3','Easy','quarry',profile.revision,R,C))
local view=A.projection(profile.heroes.hero)
check(P.validate(view) and view.main==7,'real admission preserves first seven completed stories')
check(Log.target(view,Log.main(view))==nil,'old default main tracking has no eligible target here')
local target=Log.tracked(view)
check(target and target.chapter.id=='DW-Q3' and target.goal.id=='quarry_tools','admitted optional quest automatically restores its first target')
check(Log.tracker(view,target).title:find('SIDE QUEST',1,true),'optional run never displays campaign completion')
clear(Content.byId['DW-Q3'],'quarry')
view=A.projection(profile.heroes.hero)
local before=P.copy(view)
check(Log.tracked(view)==nil,'completed optional run does not suggest an inaccessible main waypoint')
local tracker=Log.tracker(view)
check(tracker.title=='SIDE QUEST COMPLETE','completed optional quest has its own heading')
check(tracker.objective:find('Gloamwood',1,true) and tracker.objective:find('ADVENTURES',1,true),'missing target explains next region and actionable lobby selection')
check(view.main==before.main and profile.heroes.hero.deepwood.main==7,'presentation does not advance saved progress')
local invalid=Log.tracker({main=6,expeditionMission='DW-01'})
check(invalid.title=='CONTINUE YOUR JOURNEY' and invalid.objective:find('Deepwood',1,true),'blocked main target is not interpreted as full completion')
profile=assert(A.begin(profile,'hero','GW-01','Easy','frozen',profile.revision,R,C))
view=A.projection(profile.heroes.hero);target=Log.tracked(view)
check(target and target.chapter.id=='GW-01','explicit next-region admission restores main target')
check(Log.tracker(view,target).title:find('MAIN STORY 1 / 7',1,true),'Gloamwood starts at story 1')
for i=8,Content.mainCount do clear(Content.mainChapters[i])end
tracker=Log.tracker(profile.heroes.hero.deepwood)
check(tracker.title=='EPIC 5 COMPLETE','full completion remains exclusive to all 35 saved stories')
print('Journal missing target: '..n..' checks passed')
