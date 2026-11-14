-- Level-free higher difficulties retain server-owned story and clear eligibility.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local n=0
local function check(v,label)n=n+1;assert(v,label)end
local function eq(a,b,label)check(a==b,label)end
local function new()return assert(R.addHero(R.new(42),'hero','knight',C))end
local hero=new().heroes.hero
for _,mode in ipairs({'Hard','Insane','Hell'})do
 local ok,reason=D.allowed(hero,'DW-01',mode)
 check(mode=='Hard' and ok or mode~='Hard' and not ok and reason=='PreviousDifficulty','only Insane/Hell require previous clear '..mode)
end
-- Level-free admission applies to every combat mission and pinned balance version.
for _,c in ipairs(Content.chapters)do if D.combat(c)then
 for _,mode in ipairs({'Hard','Insane','Hell'})do
  local candidate=new();local h=candidate.heroes.hero
  h.deepwood=P.new();h.deepwood.main=D.requiredMain(c)
  h.expeditions={version=1,clears={[c.id]={Easy=true,Hard=true,Insane=true}},cacheProgress={}}
  eq(D.requiredLevel(c,mode),0,'no mission-level floor '..c.id..' '..mode)
  check(D.allowed(h,c.id,mode),'level one qualifies after story and prior clear '..c.id..' '..mode)
  h.expeditions.clears[c.id]={}
  local ok,reason=D.allowed(h,c.id,mode)
  check(mode=='Hard' and ok or mode~='Hard' and not ok and reason=='PreviousDifficulty','Hard unlocked, upper gates preserved '..c.id..' '..mode)
  if D.requiredMain(c)>0 then
   h.deepwood.main=0
   ok,reason=D.allowed(h,c.id,mode)
   check(not ok and reason=='StoryLocked','story still required '..c.id..' '..mode)
  end
 end
end end
for _,mode in ipairs({'Hard','Insane','Hell'})do
 local candidate=new();local h=candidate.heroes.hero
 h.expeditions={version=1,clears={['DW-01']=mode=='Hard' and {} or {Hard=true,Insane=true}},cacheProgress={}}
 for version=1,D.version do
  local admitted=assert(A.begin(candidate,'hero','DW-01',mode,'level_free',candidate.revision,R,C,version))
  check(D.verifyRun(admitted.heroes.hero,{id='level_free',missionId='DW-01',difficultyId=mode,rulesVersion=version}),'level one enters and rejoins pinned version '..version..' '..mode)
  eq(admitted.heroes.hero.level,1,'admission preserves level')
 end
end
for _,c in ipairs(Content.chapters)do
 eq(D.requiredLevel(c,'Easy',15),D.entry(c,15),'saved Easy mission gate preserved '..c.id)
 eq(D.requiredLevel(c,'Easy'),dofile('src/shared/CampaignGrowthBudget.luau').entryLevel(c),'Easy gate follows new growth '..c.id)
 if not D.combat(c)then
  for _,mode in ipairs({'Hard','Insane','Hell'})do
   local ok,why=D.allowed(hero,c.id,mode)
   check(not ok and why=='CombatMissionOnly','noncombat restriction preserved '..c.id..' '..mode)
  end
 end
end
local ok,why=D.allowed(hero,'DW-01','Nightmare')
check(not ok and why=='InvalidMission','unsupported mode rejected')
print('Difficulty level-free admission: '..n..' checks passed')
