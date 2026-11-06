-- Campaign-wide side quest audit: actual admission/progression/account/replay rules.
local Content=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local A=dofile('src/shared/AdventureRules.luau')
local D=dofile('src/shared/Difficulty.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local Log=dofile('src/shared/DeepwoodQuestLog.luau')
local Bounds=dofile('src/shared/CampaignBounds.luau')
local Access=dofile('src/shared/CampaignAccess.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local n,total,goals,battles,optional=0,0,0,0,0
local function check(v,m)n=n+1;assert(v,m)end
local profile=assert(R.addHero(R.new(928),'hero','knight',C))
profile.heroes.hero.level=80;profile.heroes.hero.progression=G.new(80)
local prefixes={[0]=R.copy(profile)}
for _,c in ipairs(Content.mainChapters)do
 for _,g in ipairs(c.goals)do if not g.optional then
  for _,s in ipairs(g.activity and g.activity.steps or {false})do
   profile=assert(R.story(profile,'hero',c.id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared',C,s and s.id or nil))
  end
 end end
 prefixes[c.number]=R.copy(profile)
end
local rows={}
for _,c in ipairs(Content.chapters)do if c.side then
 total=total+1;local required=D.requiredMain(c);local base=prefixes[required];check(base~=nil,'valid side admission checkpoint')
 check(c.quest and c.quest.giver and c.quest.brief~='' and c.quest.outcome~='','authored quest narrative')
 local report=P.goal(c,c.quest.turnIn);check(report and not report.optional,'mandatory report exists')
 check(c.goals[#c.goals]==report,'report is last objective')
 check(c.reward.xp==0 and c.reward.coins==0,'approved side fixed reward is zero')
 check(D.allowed(base.heroes.hero,c.id,'Easy'),c.id..' can enter at required checkpoint')
 if required>0 then
  local ok,why=D.allowed(prefixes[required-1].heroes.hero,c.id,'Easy');check(not ok and why=='StoryLocked',c.id..' rejects unfinished report gate')
 end
 -- Every mandatory authored destination is walkable and reachable through unlocked zones.
 local seen={[c.zone]=true};local changed=true
 while changed do changed=false;for _,edge in ipairs(Access.edges)do
  local a,b=edge[1],edge[2]
  if Access.allowed(base.heroes.hero.deepwood,a) and Access.allowed(base.heroes.hero.deepwood,b)then
   if seen[a] and not seen[b]then seen[b]=true;changed=true end
   if seen[b] and not seen[a]then seen[a]=true;changed=true end
  end
 end end
 for _,g in ipairs(c.goals)do
  goals=goals+1;if g.optional then optional=optional+1 end
  check(Bounds.supported(g.position[1],g.position[2]+4,g.position[3]),c.id..':'..g.id..' supported destination')
  local zone=Access.region(g.position[1],g.position[3]);check(Access.allowed(base.heroes.hero.deepwood,zone),c.id..':'..g.id..' actual nearest region unlocked')
  check(seen[zone],c.id..':'..g.id..' connected from launch zone')
  for _,dep in ipairs(g.requires)do check(P.goal(c,dep)~=nil,'known prerequisite')end
  if #g.enemies>0 then
   battles=battles+1;local waves=B.encounterWaves(c,g,1);check(#waves>0,'battle has finite spawn plan')
   local bosses=0
   for i,wave in ipairs(waves)do for _,unit in ipairs(wave)do if B.isBoss(unit.kind)then bosses=bosses+1;check(i==#waves and #wave==1,'boss alone in final wave')end end end
   check(bosses<=1,'unique optional boss')
  end
 end
 local p=R.copy(base)
 for _,mode in ipairs({'Easy','Easy','Hard','Insane','Hell'})do
  if mode=='Easy' or D.combat(c)then
   local first=not p.heroes.hero.deepwood.clears[c.id]
   local runId='audit_'..c.id..'_'..mode..'_'..p.revision
   p=assert(A.begin(p,'hero',c.id,mode,runId,p.revision,R,C))
   local permanentMain=p.heroes.hero.deepwood.main
   check(P.accepted(A.projection(p.heroes.hero),c),'admission durably accepts side quest')
   local wrong,why=A.event(p,'hero',c.id,c.goals[1].id,nil,nil,R,C,'foreign')
   check(not wrong and why=='AdventureChanged','foreign run rejected')
   wrong=A.event(p,'hero',c.id,report.id,nil,nil,R,C,runId);check(not wrong,'early report rejected')
   for _,g in ipairs(c.goals)do
    local view=A.projection(p.heroes.hero)
    check(P.available(view,c,g),c.id..':'..g.id..' available in order')
    if not g.optional then local t=Log.tracked(view,c.id);check(t and t.goal.id==g.id,'tracker leads to next mandatory goal')end
    p=assert(A.event(p,'hero',c.id,g.id,nil,nil,R,C,runId))
    local again,_,repeated=A.event(p,'hero',c.id,g.id,nil,nil,R,C,runId)
    check(again and again.revision==p.revision and again.wallet.gold==p.wallet.gold,'duplicate does not grant rewards')
    check(R.validate(p,C),'account valid after event')
    local before=A.projection(p.heroes.hero)
    if g~=report then
     -- New server admission must resume the same mission's saved flags.
     runId=runId..'r';p=assert(A.begin(p,'hero',c.id,mode,runId,p.revision,R,C))
     check(A.projection(p.heroes.hero).flags[c.id..':'..g.id] and P.validate(before),'reconnect preserves completed objective')
    end
   end
   check(p.heroes.hero.expeditions.active.completed and p.heroes.hero.expeditions.clears[c.id][mode],'report confirms difficulty clear')
   check(p.heroes.hero.deepwood.main==permanentMain,'side quest never advances campaign')
   check(p.heroes.hero.deepwood.clears[c.id],'permanent first clear retained')
   check(not Log.tracked(A.projection(p.heroes.hero)),'completed run has no stale objective')
  else local ok,why=D.allowed(p.heroes.hero,c.id,mode);check(not ok and why=='CombatMissionOnly','noncombat side rejects combat difficulty')end
 end
 table.insert(rows,string.format('%s | %s | %d | %d | %s',c.id,c.title,required,#c.goals,D.combat(c)and 'Easy/replay/Hard/Insane/Hell' or 'Easy/replay'))
end end
-- Completing a side expedition after the finale must still say side quest complete.
local c=Content.byId['DW-Q3'];local p=assert(A.begin(prefixes[35],'hero',c.id,'Easy','postgame',prefixes[35].revision,R,C))
for _,g in ipairs(c.goals)do if not g.optional then p=assert(A.event(p,'hero',c.id,g.id,nil,nil,R,C,'postgame'))end end
check(Log.tracker(A.projection(p.heroes.hero)).title=='SIDE QUEST COMPLETE','postgame side completion is not mislabeled as epic completion')
print(string.format('SIDE_QUEST_REVIEW %d checks PASS; %d quests, %d goals, %d combats, %d optional goals',n,total,goals,battles,optional))
for _,row in ipairs(rows)do print(row)end
