local T=dofile('src/shared/CheckpointTravel.luau')
local S=dofile('src/server/Story/CheckpointTravelService.luau')
local A=dofile('src/shared/AdventureRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local G=dofile('src/shared/HeroProgression.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local p=assert(R.addHero(R.new(720),'hero','knight',C));p.heroes.hero.level=80;p.heroes.hero.progression=G.new(80)
p=assert(A.begin(p,'hero','DW-01','Easy','travel',p.revision,R,C,12))
check(next(T.list(A.projection(p.heroes.hero)))==nil,'no travel before any saved completion')
local readySave
for _,c in ipairs(Content.mainChapters)do
 for _,g in ipairs(c.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   p=assert(A.event(p,'hero',c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared' or nil,step and step.id or nil,R,C,'travel'))
   local s=A.projection(p.heroes.hero)
   if c.id=='DW-07'and not s.flags['DW-07:separate']then check(not T.report(s),'boss kill or partial supplies cannot unlock return early')end
   if c.id=='DW-07'and g.id=='separate'and s.flags['DW-07:separate']then readySave=R.copy(p)end
   for id,target in pairs(T.list(s))do
    check(T.allowed(s,id)~=nil,'every shown destination is authorized')
    if target.id~='DW-07:restoration'then
     check(s.clears[target.chapterId],'checkpoint requires the entire saved story')
     check((Content.byId[target.chapterId].epic or 1)==(Content.mainChapters[math.min(35,s.main+1)].epic or 1),'travel stays in the current loaded epic')
    end
   end
  end
 end end
end
local s=A.projection(readySave.heroes.hero);local target=T.preferred(s,'DW-07')
check(target.id=='DW-07:restoration'and target.zone=='DW-03','altar map offers Eryn report shortcut')
check(T.preferred(s,'DW-03').id==target.id,'camp selection lands at Eryn, not a distant spawn')
local report=Content.byId['DW-07'].goals[#Content.byId['DW-07'].goals]
check(target.position[1]==report.position[1]and target.position[2]==report.position[2]and target.position[3]==report.position[3],'report uses authoritative NPC objective coordinates')
local old={revision=readySave.revision,gold=readySave.wallet.gold,main=s.main}
local valid,ready,pending,fighting,loaded,heroId=true,true,false,false,true,'hero'
local moves=0
local travel=S.create({rules=T,context=function()return valid and {heroId='hero'}end,
 active=function()return {heroId=heroId}end,ready=function()return ready end,pending=function()return pending end,inEncounter=function()return fighting end,
 state=function()return s end,destination=function(t)return loaded and {id=t.id,position=t.position}end,
 relocate=function(_,pivot)check(pivot.id==target.id,'server chooses destination from saved rules');moves=moves+1;return true end})
for i=1,4 do check(travel(i,target.id),'each eligible party member can choose travel independently')end
check(moves==4 and readySave.revision==old.revision and readySave.wallet.gold==old.gold and s.main==old.main,'travel neither advances objectives nor awards or resets progression')
for _,id in ipairs({'DW-07','HG-07','unknown','DW-07:king_shaman'})do check(not travel(1,id),'locked or arbitrary target rejected')end
check(not travel(1,{position={1,2,3}}),'client coordinates are not accepted')
valid=false;check(not travel(1,target.id),'downed/no combat context rejected');valid=true
ready=false;check(not travel(1,target.id),'lobby/travel/account lock rejected');ready=true
pending=true;check(not travel(1,target.id),'unconfirmed progress must finish saving');pending=false
fighting=true;check(not travel(1,target.id),'unfinished encounter cannot be skipped');fighting=false
loaded=false;check(not travel(1,target.id),'missing destination cannot move into an unloaded world');loaded=true
heroId='other';check(not travel(1,target.id),'hero switch cannot use stale entitlement');heroId='hero'
s=A.projection(p.heroes.hero);check(not T.allowed(s,target.id),'finished report/epic removes the old report shortcut')
check(R.validate(readySave,C),'travel source checkpoint remains a valid durable profile')
print('Checkpoint travel: '..checks..' checks passed')
