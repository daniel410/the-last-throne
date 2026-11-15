local function load(n)return dofile('src/shared/'..n..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C,P,A,D,M,S,G,Items,Q=load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('Difficulty'),load('CampaignModeProgress'),load('LobbySideQuests'),load('HeroProgression'),load('ItemCatalog'),load('QuestCompletionRewards')
local checks,completed=0,0
local function check(v,m)checks=checks+1;assert(v,m)end
local function same(a,b)
 if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end;return true
end
local function profile()
 local p=assert(R.addHero(R.new(991115),'hero','knight',Items));local h=p.heroes.hero
 h.level=40;h.progression=G.new(40);A.upgradeHero(h)
 p.wallet.heroClaims.hero={}
 for _,mode in ipairs(D.order)do
  local journal=assert(P.enableExpansion(P.new()))
  for _,c in ipairs(C.mainChapters)do
   for _,g in ipairs(c.goals)do if P.required(journal,g)then
    for _,step in ipairs(g.activity and g.activity.steps or {false})do
     journal=assert(P.apply(journal,c.id,g.id,step and step.choices and(step.solution or step.choices[1].id)or g.choice and 'shared'or nil,step and step.id or nil))
    end
   end end
   check(journal.clears[c.id],'normal P.apply prerequisite '..mode..':'..c.id)
   h.expeditions.clears[c.id]=h.expeditions.clears[c.id]or {};h.expeditions.clears[c.id][mode]=true
   h.expeditions.modeRewardClaims[mode][c.id]=true
   p.wallet.heroClaims.hero[c.id]=p.wallet.heroClaims.hero[c.id]or {};p.wallet.heroClaims.hero[c.id][mode]=true
  end
  h.expeditions.modeJournals[mode]=journal
  h.deepwood=M.merge(h.deepwood,journal)
 end
 p=assert(R.upgrade(p,Items))
 check(R.validate(p,Items),'independent normal prerequisite journals form a valid normalized fixture')
 return p
end
local function row(p,id)
 for _,v in ipairs(S.project({ready=true,heroId='hero',heroes=p.heroes}).rows)do if v.id==id then return v end end
end
local function begin(p,id,mode,run)
 local n,why=A.begin(p,'hero',id,mode,run,p.revision,R,Items,D.version)
 assert(n,tostring(why)..' begin '..id..':'..mode..':'..run);return n
end
local function quantity(p,id)
 local n=0;for _,item in pairs(p.items)do if item.definitionId==id then n=n+item.quantity end end;return n
end
local function otherUnchanged(p,before,mode,label)
 for _,other in ipairs(D.order)do if other~=mode then
  check(same(p.heroes.hero.expeditions.modeJournals[other],before.modeJournals[other]),label..' leaves '..other..' journal unchanged')
  check(same(p.heroes.hero.expeditions.modeRewardClaims[other],before.modeRewardClaims[other]),label..' leaves '..other..' receipts unchanged')
 end end
end
local function event(p,c,g,step,run,mode,path)
 local choice=step and step.choices and(step.solution or step.choices[1].id)or g.choice and 'shared'or nil
 local n,why
 if path=='run'then n,why=A.event(p,'hero',c.id,g.id,choice,step and step.id or nil,R,Items,run)
 else n,why=R.story(p,'hero',c.id,g.id,choice,Items,step and step.id or nil,mode,D.version)end
 assert(n,tostring(why)..' event '..path..':'..mode..':'..c.id..':'..g.id)
 check(R.validate(n,Items),'valid field mutation '..path..':'..mode..':'..c.id..':'..g.id)
 local duplicate
 if path=='run'then duplicate=assert(A.event(n,'hero',c.id,g.id,choice,step and step.id or nil,R,Items,run))
 else duplicate=assert(R.story(n,'hero',c.id,g.id,choice,Items,step and step.id or nil,mode,D.version))end
 check(same(duplicate,n),'field retry idempotent '..path..':'..mode..':'..c.id..':'..g.id)
 return n
end
local sides={};for _,c in ipairs(C.chapters)do if c.side then sides[#sides+1]=c end end
check(#sides==12,'all twelve authored side quests')
local base=profile()
for _,path in ipairs({'run','campaign'})do
 local p=R.copy(base)
 for _,c in ipairs(sides)do
  for _,mode in ipairs(D.order)do
   local label=path..':'..mode..':'..c.id
   local before=R.copy(p.heroes.hero.expeditions)
   local j=M.journal(p.heroes.hero,mode)
   check(not P.accepted(j,c)and not j.clears[c.id]and not M.claimed(p.heroes.hero,c.id,mode),'fresh side state '..label)
   local run='side_'..path..'_'..mode..'_'..c.id
   if path=='run'then p=begin(p,c.id,mode,run)
   else
    p=begin(p,'DW-01',mode,run..'_main')
    local n,why=R.acceptQuest(p,'hero',c.id,c.quest.discoveryOnly==true)
    assert(n,tostring(why)..' accept '..label);p=n
   end
   j=path=='run'and p.heroes.hero.expeditions.active.journal or M.journal(p.heroes.hero,mode)
   check(P.accepted(j,c)and not j.clears[c.id],'accepted only selected mode '..label)
   otherUnchanged(p,before,mode,'accept '..label)
   local events={}
   for _,g in ipairs(c.goals)do if P.required(j,g)and g.id~=c.quest.turnIn then
    for _,step in ipairs(g.activity and g.activity.steps or {false})do events[#events+1]={g=g,step=step}end
   end end
   check(#events>0,'field objectives exist '..label)
   local first=events[1];p=event(p,c,first.g,first.step,run,mode,path)
   local partial=R.copy(path=='run'and p.heroes.hero.expeditions.active.journal or M.journal(p.heroes.hero,mode))
   check(not partial.clears[c.id],'partial is unfinished '..label)
   check(row(p,c.id).phase=='progress','partial lobby projects selected mode '..label)
   local detour=mode=='Easy'and 'Hard'or 'Easy'
   p=begin(p,'DW-01',detour,run..'_detour')
   if path=='run'then
    check(A.selection(p.heroes.hero,mode).missionId==c.id,'mode selector retains side checkpoint '..label)
    p=begin(p,c.id,mode,run..'_resume');run=run..'_resume'
    check(same(p.heroes.hero.expeditions.active.journal,partial),'run checkpoint survives mode roundtrip '..label)
   else
    p=begin(p,'DW-01',mode,run..'_resume_main')
    check(same(M.journal(p.heroes.hero,mode),partial),'campaign side survives mode roundtrip '..label)
   end
   otherUnchanged(p,before,mode,'partial roundtrip '..label)
   for i=2,#events do local e=events[i];p=event(p,c,e.g,e.step,run,mode,path)end
   local ready=row(p,c.id)
   check(ready and ready.canReport and ready.phase=='report'and ready.difficultyId==mode,'selected mode ready to report '..label)
   check(ready.runId==(path=='run'and run or 'campaign'),'correct report path '..label)
   local cmd={action='Report',heroId='hero',questId=c.id,runId=ready.runId,requestId='report_'..path..'_'..mode..'_'..c.id}
   check(S.command(cmd),'bounded report command '..label)
   local gold,xp,ore,gems=p.wallet.gold,G.totalXP(p.heroes.hero.progression),quantity(p,'iron_ore'),quantity(p,'enhancement_gem')
   local n,why=S.apply(p,cmd,R,Items);assert(n,tostring(why)..' report '..label);p=n
   check(R.validate(p,Items),'valid reported account '..label)
   check(M.journal(p.heroes.hero,mode).clears[c.id]and M.claimed(p.heroes.hero,c.id,mode),'clear and mode first receipt together '..label)
   check(p.wallet.gold-gold==c.reward.coins,'first Gold exact '..label)
   check(G.totalXP(p.heroes.hero.progression)-xp==c.reward.xp,'first XP exact '..label)
   local completion=path=='run'and D.combat(c)and D.completion(c,mode,D.version)or {ore=0,gems=0}
   check(quantity(p,'iron_ore')-ore==(Q.awards[c.id].ore or 0)+completion.ore,'first ore exact '..label)
   check(quantity(p,'enhancement_gem')-gems==(Q.awards[c.id].gems or 0)+completion.gems,'first gems exact '..label)
   check(S.settled({ready=true,heroId='hero',heroes=p.heroes},cmd),'report settled '..label)
   check(same(assert(S.apply(p,cmd,R,Items)),p),'report retry no duplicate '..label)
   check(not row(p,c.id),'completed side hidden in own mode '..label)
   otherUnchanged(p,before,mode,'completion '..label)
   local loaded=assert(R.upgrade(R.copy(p),Items))
   if not same(loaded,p)then
    local function differences(a,b,k)
     if type(a)~=type(b)or type(a)~='table'then if a~=b then print('DIFF '..k..' '..tostring(a)..' -> '..tostring(b))end;return end
     for key,value in pairs(a)do differences(value,b[key],k..'.'..tostring(key))end
     for key,value in pairs(b)do if a[key]==nil then differences(nil,value,k..'.'..tostring(key))end end
    end
    differences(p,loaded,'profile')
   end
   check(same(loaded,p),'reconnect normalization no repayout or journal changes '..label)
   completed=completed+1
   print('SIDE_MODE_CASE_PASS '..label);io.stdout:flush()
  end
 end
end
print('SIDE_MODE_ALL_PASS checks='..checks..' completed='..completed..' sides='..#sides..' modes='..#D.order..' paths=2')
