-- Actual journal/account paths: partial old saves, continuation, replay and rewards.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,P,A,B,G,Items=load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('EncounterPopulation'),load('HeroProgression'),load('ItemCatalog')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function equal(a,b)if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end;for k,v in pairs(a)do if not equal(v,b[k])then return false end end;for k in pairs(b)do if a[k]==nil then return false end end;return true end
local raw=assert(io.open('src/shared/CampaignContent.luau')):read('*a'):gsub("load%('CampaignCombatPacing'%).install%(C%)",'')
local old=assert(_G.load(raw))()
local added,totals=0,{}
for _,c in ipairs(C.chapters)do
 check(equal(c.coreGoals,old.byId[c.id].coreGoals),'original goals and fixed rewards retained '..c.id)
 check(equal(c.reward,old.byId[c.id].reward),'fixed completion reward retained')
 totals[c.epic]=totals[c.epic]or 0
 for _,g in ipairs(c.goals)do
  for _,pack in ipairs(B.encounterWaves(c,g,1))do if not c.side then totals[c.epic]=totals[c.epic]+#pack end end
  if g.pacing then
   added=added+1;check(g.optional and not g.expansion,'separate saved opt-in contract')
   check(#g.enemies==1 and not B.isBoss(g.enemies[1].kind),'no duplicate bosses')
   for party=1,4 do
    local count=0;for _,pack in ipairs(B.encounterWaves(c,g,party))do count=count+#pack end
    check(count==18+6*(party-1),'finite scaled patrol population')
   end
  end
 end
end
check(added==13,'all thirteen reviewed combat gaps covered')
check(totals[1]==284 and totals[2]==262 and totals[3]==200 and totals[4]==224 and totals[5]==268,'new main-route populations, untouched Deepwood and Frozen Vale')
local function transition(s,c,g,step)
 local out,why=P.apply(s,c.id,g.id,step and step.choices and (step.solution or step.choices[1].id)or g.choice and 'sanctuary',step and step.id or nil)
 assert(out,c.id..':'..g.id..':'..tostring(step and step.id or nil)..' '..tostring(why));return out
end
local oldJournal=P.new();oldJournal.expansionVersion=1
local partial
for _,c in ipairs(old.mainChapters)do for _,g in ipairs(c.goals)do
 if P.required(oldJournal,g)then
  local steps=g.activity and g.activity.steps or {false}
  for _,step in ipairs(steps)do
   local before=P.copy(oldJournal)
   local migrated=assert(P.enableCombatPacing(oldJournal))
   check(P.validate(migrated),'every old partial save migrates')
   check(equal(oldJournal,before),'migration does not mutate caller')
   for key in pairs(oldJournal.flags)do check(migrated.flags[key],'every old confirmed goal retained')end
   check(equal(migrated.activities,oldJournal.activities)and equal(migrated.clues,oldJournal.clues),'partial clues and activity steps retained')
   check(migrated.coins==oldJournal.coins and migrated.main==oldJournal.main,'migration never pays or resets progression')
   check(equal(P.enableCombatPacing(migrated),migrated),'migration idempotent')
   for _,chapter in ipairs(C.chapters)do for _,patrol in ipairs(chapter.pacingGoals or {})do
    check((migrated.flags[chapter.id..':'..patrol.id]==true)==(oldJournal.flags[chapter.id..':'..patrol.before]==true or ((oldJournal.activities or {})[chapter.id..':'..patrol.before]or 0)>0),'waive exactly confirmed downstream gates')
   end end
   if c.id=='GW-01'and g.id=='exp_1'and not partial then partial=P.copy(oldJournal)end
   oldJournal=transition(oldJournal,c,g,step)
  end
 end
end end
check(P.validate(oldJournal)and oldJournal.main==35,'old expanded route remains playable without new requirements')
local migrated=assert(P.enableCombatPacing(partial));local c=C.byId['GW-01'];local patrol=P.goal(c,'lantern_patrol');local gate=P.goal(c,patrol.before)
for _,id in ipairs({'exp_1','marks'})do while not migrated.flags['GW-01:'..id]do local g=P.goal(c,id);migrated=transition(migrated,c,g,P.nextStep(migrated,c,g))end end
check(P.available(migrated,c,patrol),'pending patrol becomes next available after old partial activity')
check(not P.available(migrated,c,gate),'cannot bypass patrol through lantern')
local blocked,why=P.apply(migrated,c.id,gate.id,nil,'confirmed');check(not blocked and why=='StoryLocked','server journal rejects downstream interaction')
migrated=transition(migrated,c,patrol)
check(P.available(migrated,c,gate),'patrol defeat opens downstream objective')
local bad=P.copy(migrated);bad.flags['GW-01:lantern_patrol']=nil;bad.flags['GW-01:exp_2']=true;bad.activities['GW-01:exp_2']=3
check(not P.validate(bad),'malformed downstream save rejected')
local profile=assert(R.addHero(R.new(181),'hero','knight',Items));profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80);profile.heroes.hero.deepwood=partial
profile=assert(A.begin(profile,'hero','GW-01','Easy','legacy-active',profile.revision,R,Items,14))
-- Simulate a previously admitted v14 run whose journal predates the new content.
profile.heroes.hero.deepwood=P.copy(partial);profile.heroes.hero.expeditions.active.journal=P.copy(partial)
check(R.validate(profile,Items),'existing admitted run stays loadable')
local view=A.projection(profile.heroes.hero)
check(view.combatPacingVersion==1,'Continue projects new content for existing v14 run')
local gold=profile.wallet.gold
for _,goal in ipairs(c.goals)do
 local state=A.projection(profile.heroes.hero)
 if P.required(state,goal)and not state.flags[c.id..':'..goal.id]then
  for _,step in ipairs(goal.activity and goal.activity.steps or {false})do
   if not step or not P.collected(state,c,goal,(function()for i,s in ipairs(goal.activity.steps)do if s==step then return i end end end)())then
    profile=assert(A.event(profile,'hero',c.id,goal.id,step and step.choices and step.choices[1].id,step and step.id or nil,R,Items,'legacy-active'))
   end
  end
 end
end
check(profile.heroes.hero.deepwood.clears['GW-01'],'existing Continue completes with new patrol')
check(profile.wallet.gold-gold==c.reward.coins,'completion Gold unchanged')
local retry,err=A.event(profile,'hero',c.id,patrol.id,nil,nil,R,Items,'legacy-active')
check(retry and not err and retry.wallet.gold==profile.wallet.gold and retry.revision==profile.revision,'patrol completion retry does not pay twice')
profile.heroes.hero.deepwood=assert(P.enableCombatPacing(oldJournal))
profile=assert(A.begin(profile,'hero','GW-01','Easy','replay-patrol',profile.revision,R,Items))
view=A.projection(profile.heroes.hero)
check(not view.flags['GW-01:lantern_patrol']and not (view.pacingWaivers or {})['GW-01:lantern_patrol'],'replay requires its own new patrol, no stale waiver')
check(profile.heroes.hero.deepwood.main==35,'replay leaves permanent ending intact')
print('CAMPAIGN_COMBAT_PACING '..n..' checks passed')
