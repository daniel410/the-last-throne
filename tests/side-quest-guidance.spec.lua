local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local f=assert(io.open('src/client/DeepwoodJournal.luau'));local source=f:read('*a');f:close()
local first=assert(source:find('function Journal.guidance',1,true));local last=assert(source:find('function Journal.start',first,true))
local env=setmetatable({Journal={},Content=Content,Progress=P,Log=Log,Text=dofile('src/shared/K0Text.luau'),Vector3={new=function(...)return {...}end}},{__index=_G})
assert(load(source:sub(first,last-1),'production journal guidance','t',env))()
local n=0;local function check(v,m)n=n+1;assert(v,m)end
for _,c in ipairs(Content.chapters)do if c.side then
 local s=P.new();s.main=c.minMain
 if c.quest.offerPosition then
  local target=Log.tracked(s,c.id);check(target and target.offer,'unaccepted request tracks offer')
  local guidance=env.Journal.guidance({journal=s},target)
  local position=c.quest.offerPosition
  check(guidance.position[1]==position[1] and guidance.position[3]==position[3],'waypoint leads to authored acceptance position')
  if c.quest.discoveryOnly then
   check(guidance.objective==c.goals[1].title,'field discovery instructs clue interaction')
   check(guidance.note:find('field clue',1,true),'field discovery explains acceptance')
  else check(guidance.objective=='Speak with '..c.quest.giver,'NPC offer names actual giver')end
 end
 s.accepted[c.id]=true;local target=Log.tracked(s,c.id)
 check(target and target.goal.id==c.goals[1].id and not target.offer,'accepted request leads to field objective')
 local guidance=env.Journal.guidance({journal=s},target);check(guidance and guidance.objective==c.goals[1].title,'accepted objective has actionable guidance')
 check(not env.Journal.guidance({journal=s,training=true},target),'training does not show adventure guidance')
end end
print('SIDE_QUEST_GUIDANCE '..n..' checks PASS')
