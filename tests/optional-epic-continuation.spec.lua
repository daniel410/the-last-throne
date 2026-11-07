local A=dofile('src/shared/AdventureRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local G=dofile('src/shared/HeroProgression.luau')
local D=dofile('src/shared/Difficulty.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local Scope=dofile('src/shared/CampaignMapScope.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local profile=assert(R.addHero(R.new(958),'hero','elf',C));profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
local prefixes={}
for _,c in ipairs(Content.mainChapters)do
 for _,g in ipairs(c.goals)do if not g.optional then for _,s in ipairs(g.activity and g.activity.steps or {false})do
  profile=assert(R.story(profile,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',C,s and s.id or nil))
 end end end
 prefixes[c.number]=R.copy(profile)
end
for epic=1,5 do
 local ids=Scope.ids(epic);local count=0
 for id in pairs(ids)do count=count+1;check(Scope.epicFor(id)==epic,'map excludes other epics')end
 check(count==((epic==1 or epic==3 or epic==4)and 10 or 7),'all seven story and all optional regions are included')
 local first,last=Scope.range(epic);check(last-first+1==7,'story journey still contains exactly seven stories')
end
for _,c in ipairs(Content.chapters)do if c.side then
 check(Scope.ids(c.epic or 1)[c.zone],c.id..' optional destination included in detailed map')
 local completed=(c.epic or 1)*7;local nextStory=Content.mainChapters[completed+1]
 for _,status in ipairs({'unaccepted','accepted','in_progress','ready'})do
  local p=R.copy(prefixes[completed]);local run='optional_'..c.id..'_'..status
  if status~='unaccepted'then
   p=assert(A.begin(p,'hero',c.id,'Easy',run,p.revision,R,C))
   if status=='in_progress' or status=='ready'then
    for _,g in ipairs(c.goals)do
     if g.id==c.quest.turnIn then break end
     if not g.optional then p=assert(A.event(p,'hero',c.id,g.id,nil,nil,R,C,run))end
     if status=='in_progress'then break end
    end
   end
  end
  local before=P.copy(p.heroes.hero.deepwood)
  check(D.allowed(p.heroes.hero,nextStory.id,'Easy'),'uncompleted optional never gates next epic')
  local selection=A.selection(p.heroes.hero)
  check(selection.missionId==nextStory.id and selection.difficultyId=='Easy','lobby Continue selects next epic')
  if status~='unaccepted'then
   local view=A.projection(p.heroes.hero);local side=Log.tracked(view)
   check(side and side.chapter.id==c.id,'current side expedition keeps its own default tracking')
   local target=Log.tracked(view,nextStory.id)
   check(target and target.lobby and target.chapter.id==nextStory.id,'explicit main tracking offers lobby continuation')
   local hud=Log.tracker(view,target)
   check(hud.title=='CONTINUE MAIN STORY' and hud.objective:find(Content.epics[(c.epic or 1)+1].region,1,true),'HUD names next epic instead of reverting to side target')
   check(hud.note:find('optional',1,true)~=nil,'HUD explains optional status')
  end
  p=assert(A.begin(p,'hero',nextStory.id,'Easy','next_'..run,p.revision,R,C))
  check(p.heroes.hero.deepwood.main==completed and not p.heroes.hero.deepwood.clears[c.id],'changing expedition does not auto-complete side or main')
  for key,value in pairs(before.flags)do check(p.heroes.hero.deepwood.flags[key]==value,'side and main saved flags retained')end
  if status~='unaccepted'then
   p=assert(A.begin(p,'hero',c.id,'Easy','return_'..run,p.revision,R,C))
   check(P.accepted(A.projection(p.heroes.hero),c),'returning to side preserves acceptance')
   for _,g in ipairs(c.goals)do if before.flags[c.id..':'..g.id]then check(A.projection(p.heroes.hero).flags[c.id..':'..g.id],'return preserves partial fieldwork')end end
  end
  check(R.validate(p,C),'account valid after leaving and returning')
 end
end end
-- A deliberate side expedition in an unfinished epic remains the default.
local p=assert(A.begin(prefixes[5],'hero','DW-Q3','Easy','mid_epic',prefixes[5].revision,R,C))
check(A.selection(p.heroes.hero).missionId=='DW-Q3','unfinished epic side selection still resumes normally')
local final=assert(A.begin(prefixes[35],'hero','DW-Q3','Easy','postgame_optional',prefixes[35].revision,R,C))
check(A.selection(final.heroes.hero).missionId=='DW-Q3','after all five epics there is no invented next epic')
print('OPTIONAL_EPIC_CONTINUATION '..n..' checks PASS; twelve side quests, all states, five map scopes')
