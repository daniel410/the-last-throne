-- Same-run first-clear progression, including persisted completed launch missions.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local M=dofile('src/shared/StoryCompletion.luau')
local D=dofile('src/shared/Difficulty.luau')
local Pass=dofile('src/shared/SupportPassRules.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local p=assert(R.addHero(R.new(912),'hero','knight',C))
local afterStoryOne,afterStoryFive
local function event(c,g,step,run)
 local choice=step and step.choices and step.choices[1].id or g.choice and 'sanctuary' or nil
 return A.event(p,'hero',c.id,g.id,choice,step and step.id or nil,R,C,run)
end
for i,c in ipairs(Content.mainChapters)do
 -- The whole campaign continues in one admitted run.
 local run='campaign'
 if i==1 then
  p.heroes.hero.level=80;p.heroes.hero.progression=dofile('src/shared/HeroProgression.luau').new(80)
  p=assert(A.begin(p,'hero',c.id,'Easy',run,p.revision,R,C))
 end
 local h=p.heroes.hero;local s=A.projection(h)
 local gemsBefore=R.quantity(p,'hero','enhancement_gem')
 if i==4 or i==5 then
  if i==4 then p.supportPasses={version=1,credits=2,active={}}end
  local v=Pass.view(p,'hero')
  check(v.story==i and not v.active and not v.completed,'continued story needs its own explicit support invitation')
  p=assert(R.supportPass(p,{action='Activate',requestId='invite_'..i,heroId='hero',story=i,scope=v.scope},{inAdventure=true,hasCampAccess=true,maxStories=35},C))
  check(Pass.view(p,'hero').active and Pass.view(p,'hero').credits==5-i,'continued story invitation consumes exactly one credit')
 end
 check(s.expeditionMission==c.id,'next story opens without returning to lobby: '..c.id)
 check(Log.target(s,c)~=nil,'next objective is trackable: '..c.id)
 if i==3 then
  check(h.expeditions.active.missionId=='DW-01'and h.expeditions.active.completed,'completed launch mission can continue to DW-03')
  check(P.available(s,c,c.goals[1]),'Selene report is immediately available')
  local revision=p.revision
  p=assert(A.begin(p,'hero','DW-01','Easy',run,p.revision,R,C))
  check(p.revision==revision and A.projection(p.heroes.hero).expeditionMission=='DW-03','rejoin admission preserves story 3')
 end
 local locked,why=A.event(p,'hero',c.id,c.goals[1].id,nil,nil,R,C,'foreign')
 check(not locked and why=='AdventureChanged','foreign run rejected')
 local future=Content.mainChapters[i+1]
 if future then
  locked,why=A.event(p,'hero',future.id,future.goals[1].id,nil,nil,R,C,run)
  check(not locked and why=='AdventureChanged','cannot skip current story')
 end
 for _,g in ipairs(c.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   p=assert(event(c,g,step,run))
   local revision,gold,gems=p.revision,p.wallet.gold,R.quantity(p,'hero','enhancement_gem')
   local copy=assert(event(c,g,step,run))
   check(copy.revision==revision and copy.wallet.gold==gold and R.quantity(copy,'hero','enhancement_gem')==gems,'lost save response cannot regrant rewards')
   check(R.validate(copy,C),'continued profile remains loadable')
  end
 end end
 h=p.heroes.hero
 if i==4 or i==5 then check(not Pass.view(p,'hero').active and Pass.view(p,'hero').credits==5-i,'story completion ends support without automatic renewal')end
 local reward=D.completion(c,'Easy',h.expeditions.active.balanceVersion)
 check(R.quantity(p,'hero','enhancement_gem')==gemsBefore+reward.gems,'each continued story grants its own materials exactly once')
 check(h.deepwood.main==i and h.expeditions.clears[c.id].Easy,'story and difficulty clears saved: '..c.id)
 local view=A.projection(h)
 local value={heroId='hero',journal=view,expedition=h.expeditions.active,completion={id=c.id}}
 local summary=M.project(value)
 check(Log.followNext(value,{heroId='hero',journal=s}),'main completion automatically restores main tracking without a button')
 value.completion=nil
 check(Log.followNext(value,{heroId='hero',journal=s}),'saved snapshot arriving before completion also restores main tracking')
 check(not Log.followNext(value,value),'ordinary refresh does not override player tracking')
 check(not Log.followNext(value,{heroId='other',journal=s}),'another hero cannot cause a false main handoff')
 if future then
  check(summary.nextId==future.id and summary.objective~=''and summary.action==M.text.follow,'completion card tracks the playable next story, including epic boundaries')
 else check(A.continuation(h.expeditions.active)==nil,'only the final main story ends automatic progression')end
 if i==1 then afterStoryOne=R.copy(p)end
 if i==5 then afterStoryFive=R.copy(p)end
end
local clearedCampaign=R.copy(p)
-- Every difficulty can replay all 35 main stories in a single admission.
for _,mode in ipairs({'Hard','Insane','Hell'})do
 p=assert(A.begin(clearedCampaign,'hero','DW-01',mode,'mode_'..mode,clearedCampaign.revision,R,C))
 local gold=p.wallet.gold;local expected=0
 for _,chapter in ipairs(Content.mainChapters)do
  local view=A.projection(p.heroes.hero)
  check(view.expeditionMission==chapter.id and not view.expeditionFirstClear,'higher difficulty opens each next story as a replay')
  for _,g in ipairs(chapter.goals)do if not g.optional then
   for _,step in ipairs(g.activity and g.activity.steps or {false})do p=assert(event(chapter,g,step,'mode_'..mode))end
  end end
  expected=expected+D.completion(chapter,mode,p.heroes.hero.expeditions.active.balanceVersion).gold
  check(p.heroes.hero.deepwood.main==35,'replay preserves canonical campaign completion')
 end
 check(p.wallet.gold==gold+expected,'all higher-difficulty replay story rewards paid exactly once')
 check(A.continuation(p.heroes.hero.expeditions.active)==nil,'higher difficulty finishes only after story 35')
 clearedCampaign=R.copy(p)
end
-- Replays continue while preserving permanent first-clear ownership.
p=assert(A.begin(p,'hero','DW-02','Easy','replay',p.revision,R,C))
local c=Content.byId['DW-02']
for _,g in ipairs(c.goals)do if not g.optional then
 for _,step in ipairs(g.activity and g.activity.steps or {false})do p=assert(event(c,g,step,'replay'))end
end end
check(A.continuation(p.heroes.hero.expeditions.active).id=='DW-03','Easy replay automatically continues')
local reportStep=Content.byId['DW-03'].goals[1].activity.steps[1]
p=assert(A.event(p,'hero','DW-03','report',reportStep.choices[1].id,reportStep.id,R,C,'replay'))
check((p.heroes.hero.expeditions.active.journal.activities['DW-03:report']or 0)==1,'replay can save the next story')
check(p.heroes.hero.deepwood.main==35,'replay preserves permanent completion')
-- Reproduce entry directly into DW-02, as well as old completed-run saves:
-- projection opens DW-03 without migration writes or replaying the final reward.
p=assert(A.begin(afterStoryOne,'hero','DW-02','Easy','rescue',afterStoryOne.revision,R,C))
for _,g in ipairs(c.goals)do if not g.optional then
 for _,step in ipairs(g.activity and g.activity.steps or {false})do p=assert(event(c,g,step,'rescue'))end
end end
local saved=R.copy(p);local gold=p.wallet.gold
check(A.projection(saved.heroes.hero).expeditionMission=='DW-03','old completed DW-02 save immediately opens DW-03')
local hard=R.copy(saved.heroes.hero.expeditions.active);hard.difficultyId='Hard'
check(A.continuation(hard).id=='DW-03','upper difficulties also continue through narrative stories')
p=assert(A.begin(saved,'hero','DW-02','Easy','rescue',saved.revision,R,C))
check(p.wallet.gold==gold,'rejoin never regrants rescue reward')
local report=Content.byId['DW-03'].goals[1]
local first=report.activity.steps[1]
p=assert(event(Content.byId['DW-03'],report,first,'rescue'))
check((p.heroes.hero.deepwood.activities['DW-03:report']or 0)==1,'Selene dialogue can actually save after DW-02')
-- Direct DW-06 entry, completion card and the actual DW-07 first event.
p=assert(A.begin(afterStoryFive,'hero','DW-06','Easy','altar',afterStoryFive.revision,R,C))
c=Content.byId['DW-06']
local before=A.projection(p.heroes.hero)
local unconfirmed={heroId='hero',journal=before,completion={id=c.id}}
check(not Log.followNext(unconfirmed,{heroId='hero',journal=before}),'unconfirmed completion cannot clear a tracking choice')
for _,g in ipairs(c.goals)do if not g.optional then
 for _,step in ipairs(g.activity and g.activity.steps or {false})do p=assert(event(c,g,step,'altar'))end
end end
local h=p.heroes.hero
local value={heroId='hero',journal=A.projection(h),expedition=h.expeditions.active,completion={id=c.id}}
local summary=M.project(value)
check(summary.nextId=='DW-07'and summary.guidance==M.text.route and summary.action==M.text.follow,'DW-06 card continues to story 7 without lobby guidance')
check(Log.followNext(value,{heroId='hero',journal=before}),'DW-06 completion restores navigation automatically')
local target=Log.target(value.journal,Log.main(value.journal))
check(target and target.chapter.id=='DW-07'and target.goal.id=='corridor','navigation has the first story 7 combat target')
gold=p.wallet.gold
p=assert(A.begin(p,'hero','DW-06','Easy','altar',p.revision,R,C))
check(p.wallet.gold==gold and A.projection(p.heroes.hero).expeditionMission=='DW-07','rejoin retains story 7 and never repeats story 6 rewards')
p=assert(event(target.chapter,target.goal,nil,'altar'))
check(p.heroes.hero.deepwood.flags['DW-07:corridor'],'story 7 first encounter completion can save in the same run')
-- Replaying an earlier story must switch back to first-clear rewards at the frontier.
p=assert(A.begin(afterStoryFive,'hero','DW-05','Easy','mixed',afterStoryFive.revision,R,C))
for _,id in ipairs({'DW-05','DW-06'})do
 local chapter=Content.byId[id]
 local view=A.projection(p.heroes.hero)
 check(view.expeditionFirstClear==(id=='DW-06'),'first/repeat reward status follows the current chapter, not the launch mission')
 local gold=p.wallet.gold
 for _,g in ipairs(chapter.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do p=assert(event(chapter,g,step,'mixed'))end
 end end
 local expected=id=='DW-06'and chapter.reward.coins or D.completion(chapter,'Easy',2).gold
 check(p.wallet.gold==gold+expected,'mixed replay/frontier uses correct story reward')
end
check(p.heroes.hero.deepwood.main==6 and A.continuation(p.heroes.hero.expeditions.active).id=='DW-07','replay launch cannot prevent first-time story 6 to 7 progression')
print('Story continuation: '..n..' checks passed')
