-- Exercise the actual per-mission account transaction path, including replay journals.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local A=dofile('src/shared/AdventureRules.luau')
local G=dofile('src/shared/HeroProgression.luau')
local D=dofile('src/shared/Difficulty.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local journal=P.new()
for i=1,7 do local c=Content.mainChapters[i];for _,g in ipairs(c.goals)do if not g.optional then
 if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
 else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary'))end
end end end
local p=assert(R.addHero(R.new(911),'hero','knight',C));p.heroes.hero.level=27;p.heroes.hero.progression=G.new(27);p.heroes.hero.deepwood=journal
local function run(id,mode,runId)
 p=assert(A.begin(p,'hero',id,mode,runId,p.revision,R,C))
 local wrong,reason=A.event(p,'hero',id,Content.byId[id].goals[1].id,nil,nil,R,C,'foreign')
 check(not wrong and reason=='AdventureChanged','foreign mission event rejected')
 for _,g in ipairs(Content.byId[id].goals)do
  local steps=g.activity and g.activity.steps or {false}
  for _,step in ipairs(steps)do
   local sid=step and step.id or nil
   p=assert(A.event(p,'hero',id,g.id,step and step.choices and step.choices[1].id,sid,R,C,runId))
   local revision,gold=p.revision,p.wallet.gold
   local copy,err,repeated=A.event(p,'hero',id,g.id,step and step.choices and step.choices[1].id,sid,R,C,runId)
   check(copy and not err and copy.wallet.gold==gold and copy.revision==revision,'account event retry cannot duplicate rewards/material receipts')
   check(R.validate(copy,C),'account valid after each event')
  end
 end
 check(p.heroes.hero.expeditions.active.completed,'mission completes')
end
for number=8,35 do
 local c=Content.mainChapters[number];run(c.id,'Easy','first_'..number)
 check(p.heroes.hero.deepwood.main==number,'first clear advances permanent campaign')
 check(p.heroes.hero.expeditions.clears[c.id].Easy,'difficulty clear saved separately')
end
check(p.wallet.gold==14280,'FV/EC/HG first-clear fixed Gold preserved and GW provisional fixed Gold zero')
run('GW-01','Easy','replay_gw')
check(p.heroes.hero.deepwood.main==35 and p.heroes.hero.deepwood.clears['HG-07'],'earlier replay preserves permanent ending')
local expected=D.completion(Content.byId['HG-07'],'Easy');local before=p.wallet.gold
run('HG-07','Easy','replay_hg')
check(p.wallet.gold-before==expected.gold,'final story replay uses existing repeat reward contract')
check(p.heroes.hero.deepwood.main==35 and p.heroes.hero.deepwood.flags['HG-07:portal'],'replay keeps permanent portal closure')
print('LATE_EPICS_ADVENTURES '..n..' checks passed')
