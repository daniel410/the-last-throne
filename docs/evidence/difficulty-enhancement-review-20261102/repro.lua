local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local G=dofile('src/shared/HeroProgression.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local function fresh()
 local p=assert(R.addHero(R.new(42),'hero','knight',C));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80);return p
end
local function clear(p,c)
 for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do p=assert(R.story(p,'hero',c.id,g.id,step.choices and step.choices[1].id,C,step.id))end
  else p=assert(R.story(p,'hero',c.id,g.id,g.choice and 'sanctuary',C))end
 end end
 return p
end
local base=fresh()
for i=1,7 do base=clear(base,Content.mainChapters[i])end
for _,id in ipairs({'FV-Q1','EC-Q1'})do
 local p=base
 if id=='EC-Q1'then for i=8,14 do p=clear(p,Content.mainChapters[i])end end
 local allowed,why=D.allowed(p.heroes.hero,id,'Easy')
 assert(allowed,why)
 p=assert(A.begin(p,'hero',id,'Easy','side-'..id,p.revision,R,C))
 local c=Content.byId[id]
 for i=1,#c.goals-1 do p=assert(A.event(p,'hero',id,c.goals[i].id,nil,nil,R,C,'side-'..id))end
 local a=p.heroes.hero.expeditions.active;local last=c.goals[#c.goals]
 local nextP,err=A.event(p,'hero',id,last.id,nil,nil,R,C,a.runId)
 local projection=P.copy(a.journal);projection.expeditionMission=id
 local main=Content.mainChapters[projection.main+1]
 print('SIDE_GATE',id,'admitted',allowed,'main',projection.main,'reportNeeds',last.minMain,'reportError',err,'canAdvanceMain',P.eligible(projection,main))
 assert(not nextP and err=='StoryLocked'and not P.eligible(projection,main))
end
local p=assert(A.begin(fresh(),'hero','DW-01','Easy','explore',1,R,C))
p=assert(R.explore(p,'hero','DW-01',2,2))
local original=p.heroes.hero.deepwood.explored['DW-01'];local displayed=p.heroes.hero.expeditions.active.journal.explored['DW-01']
print('FOG_COPY','canonicalRevealed',original and next(original)~=nil,'activeRevealed',displayed and next(displayed)~=nil or false)
assert(original and next(original)and not displayed)
-- As the production startRunLocked does, begin is committed before createRun/transfer.
local p=assert(A.begin(base,'hero','DW-01','Easy','previous-run',base.revision,R,C))
local goal=Content.byId['DW-01'].goals[1]
p=assert(A.event(p,'hero','DW-01',goal.id,nil,nil,R,C,'previous-run'))
local oldManifest={id='previous-run',missionId='DW-01',difficultyId='Easy',rulesVersion=1}
assert(D.verifyRun(p.heroes.hero,oldManifest))
p=assert(A.begin(p,'hero','DW-02','Easy','failed-departure',p.revision,R,C))
local valid,why=D.verifyRun(p.heroes.hero,oldManifest)
print('FAILED_DEPARTURE','oldRunAdmitted',valid,'reason',why,'previousCheckpointRetained',p.heroes.hero.expeditions.active.runId=='previous-run')
assert(not valid and why=='AdventureChanged')
