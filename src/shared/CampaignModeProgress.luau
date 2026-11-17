-- Independent story journals and first-clear receipts; no account payouts here.
local function load(n)return game and require(script.Parent[n])or dofile('src/shared/'..n..'.luau')end
local P,C=load('DeepwoodProgress'),load('CampaignContent')
local M={order={'Easy','Hard','Insane','Hell'}}
local fields={'flags','activities','decisions','accepted','clues','expansionWaivers','pacingWaivers'}
local function copyChapter(target,source,c)
 for _,field in ipairs(fields)do
  target[field]=target[field]or {}
  for key,value in pairs(source[field]or {})do
   if key==c.id or key:sub(1,#c.id+1)==c.id..':'then target[field][key]=P.copy(value)end
  end
 end
 if c.id=='DW-07'then target.choice=source.choice end
end
local function frontier(s)
 s.main=0;while s.main<C.mainCount and s.clears[C.mainChapters[s.main+1].id]do s.main=s.main+1 end
end
local function hasChapter(s,c)
 for _,field in ipairs(fields)do for key in pairs(s[field]or {})do
  if key==c.id or key:sub(1,#c.id+1)==c.id..':'then return true end
 end end
 return false
end
local function receipt(hero,id,mode)
 local e=hero.expeditions
 local modes=e and e.clears and e.clears[id]
 return modes and modes[mode]==true or not modes and mode=='Easy'and hero.deepwood and hero.deepwood.clears[id]==true or false
end
local function completeFromReceipt(s,c,source)
 if source.clears[c.id]then
  if not c.side then s.main=c.number end
  copyChapter(s,source,c);s.clears[c.id]=true;s.coins=s.coins+(c.journalCoins or c.reward.coins)
  return s
 end
 if c.side then s.accepted[c.id]=true end
 for _,g in ipairs(c.goals)do if P.required(s,g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   local choice=step and step.choices and(step.solution or step.choices[1].id)or g.choice and 'sanctuary'or nil
   s=assert(P.apply(s,c.id,g.id,choice,step and step.id or nil))
  end
 end end
 return s
end
function M.claimed(hero,id,mode)
 local e=hero and hero.expeditions
 if e and e.modeRewardClaims then return e.modeRewardClaims[mode]and e.modeRewardClaims[mode][id]==true or false end
 return hero and receipt(hero,id,mode)or false
end
function M.journal(hero,mode)
 local e=hero and hero.expeditions
 if e and e.modeJournals then return P.copy(e.modeJournals[mode]or P.new())end
 local base=assert(P.upgrade(hero and hero.deepwood or P.new()))
 if base.expansionVersion==1 then base=assert(P.enableExpansion(base))end
 local s=P.new();if base.expansionVersion==1 then s=assert(P.enableExpansion(s))end
 while s.main<C.mainCount and hero and receipt(hero,C.mainChapters[s.main+1].id,mode)do
  s=completeFromReceipt(s,C.mainChapters[s.main+1],base)
 end
 -- Preserve access/receipts from the pre-Gloamwood order only when this mode
 -- actually completed that historic prefix. Never copy another mode's access.
 if base.legacyMain then
  local legacy=0
  for i=1,base.legacyMain do if receipt(hero,C.legacyMainChapters[i].id,mode)then legacy=i else break end end
  if legacy>0 then
   s.legacyMain=legacy
   for _,c in ipairs(C.mainChapters)do if c.number>s.main and c.legacyNumber<=legacy and receipt(hero,c.id,mode)then s=completeFromReceipt(s,c,base)end end
   -- Recalculate the contiguous frontier after importing historical clears.
   frontier(s)
  end
 end
 for _,c in ipairs(C.chapters)do
  if c.side and hero and receipt(hero,c.id,mode)and C.accessible(s,c.minMain,c.legacyMinMain)then
   s=completeFromReceipt(s,c,base)
  end
 end
 -- The active chapter belongs to its server-bound mode. Other unscoped legacy
 -- partial records belong to Easy, even when a different mode is being replayed.
 local a=e and e.active
 local activeJournal=a and assert(P.upgrade(a.journal))
 if activeJournal and activeJournal.expansionVersion==1 then activeJournal=assert(P.enableExpansion(activeJournal))end
 local current=a and C.byId[a.missionId]
 if current and a.completed and not current.side then
  local nextChapter=C.mainChapters[(a.returnToCampaign and a.campaignMain or activeJournal.main)+1]
  current=nextChapter and hasChapter(activeJournal,nextChapter)and nextChapter or nil
 end
 local function sourceFor(c)
  if current and current.id==c.id then return a.difficultyId==mode and activeJournal or nil end
  return mode=='Easy'and base or nil
 end
 local source=mode=='Easy'and base or a and a.difficultyId==mode and activeJournal
 local legacyResume=source and source.legacyResume and C.byId[source.legacyResume]
 if legacyResume and s.legacyMain and legacyResume.legacyNumber==s.legacyMain+1 then
  s.legacyResume=legacyResume.id
  local partial=sourceFor(legacyResume);if partial and not partial.clears[legacyResume.id]then
   if partial.expansionVersion==1 and s.expansionVersion~=1 then s=assert(P.enableExpansion(s))end
   copyChapter(s,partial,legacyResume)
  end
 end
 local nextChapter=C.mainChapters[s.main+1]
 for _,c in ipairs(C.chapters)do
  local partial=sourceFor(c)
  if partial and not s.clears[c.id]and not partial.clears[c.id]
   and(c==nextChapter or c.side and C.accessible(s,c.minMain,c.legacyMinMain))then
   if partial.expansionVersion==1 and s.expansionVersion~=1 then s=assert(P.enableExpansion(s))end
   copyChapter(s,partial,c)
  end
 end
 if not P.validate(s)then error('Invalid legacy mode journal: '..mode)end
 return s
end
function M.ensure(hero,paidClaims)
 local e=hero.expeditions
 if e and e.modeJournals then return false end
 if paidClaims and next(paidClaims)then
  e=e or {version=1,clears={},cacheProgress={}};hero.expeditions=e
  for id,modes in pairs(paidClaims)do
   e.clears[id]=e.clears[id]or {}
   for mode,paid in pairs(modes)do if paid then e.clears[id][mode]=true end end
  end
 end
 local journals,claims={},{}
 for _,mode in ipairs(M.order)do
  journals[mode]=M.journal(hero,mode);claims[mode]={}
  for _,c in ipairs(C.chapters)do if receipt(hero,c.id,mode)then claims[mode][c.id]=true end end
 end
 e=e or {version=1,clears={},cacheProgress={}};hero.expeditions=e
 e.modeJournals=journals;e.modeRewardClaims=claims;e.runsByMode={}
 -- Preserve the original active checkpoint as evidence; new admissions use the
 -- selected mode's actual frontier rather than a synthetic cross-mode prefix.
 if e.active then e.runsByMode[e.active.difficultyId]=P.copy(e.active)end
 return true
end
function M.merge(base,update,chapterId)
 local s=assert(P.upgrade(base or P.new()));local u=assert(P.upgrade(update))
 assert(chapterId==nil or C.byId[chapterId],'Unknown campaign chapter')
 local function includes(key)return not chapterId or key==chapterId or key:sub(1,#chapterId+1)==chapterId..':'end
 if s.expansionVersion==1 or u.expansionVersion==1 then
  s=assert(P.enableExpansion(s));u=assert(P.enableExpansion(u))
 end
 for _,field in ipairs({'flags','clears','accepted','expansionWaivers','pacingWaivers'})do
  s[field]=s[field]or {};for key,value in pairs(u[field]or {})do if includes(key)then s[field][key]=value end end
 end
 s.activities=s.activities or {};s.decisions=s.decisions or {};s.clues=s.clues or {}
 for key,value in pairs(u.activities or {})do if includes(key)then s.activities[key]=math.max(s.activities[key]or 0,value)end end
 for key,value in pairs(u.decisions or {})do if includes(key)then s.decisions[key]=s.decisions[key]or value end end
 for key,values in pairs(u.clues or {})do
  if includes(key)then
  s.clues[key]=s.clues[key]or {};for id,value in pairs(values)do s.clues[key][id]=value end
  local count=0;for _ in pairs(s.clues[key])do count=count+1 end;s.activities[key]=count
  end
 end
 if s.choice==''and(not chapterId or chapterId=='DW-07')then s.choice=u.choice end
 frontier(s)
 s.coins=0;for id in pairs(s.clears)do local c=C.byId[id];s.coins=s.coins+(c.journalCoins or c.reward.coins)end
 assert(P.validate(s),'Invalid merged campaign journal')
 return s
end
function M.save(hero,active,chapterId)
 local e=hero.expeditions;local mode=active.difficultyId
 -- A replay journal contains a synthetic prefix for navigation. Admission and
 -- mode switches save its checkpoint only; events can merge their own chapter.
 if not active.replay or chapterId then e.modeJournals[mode]=M.merge(e.modeJournals[mode],active.journal,active.replay and chapterId or nil)end
 if not active.partyAssist then
  e.runsByMode[mode]=P.copy(active)
  return
 end
 -- A helper can reach their original chapter and defeat enemies before the next
 -- objective save. Carry those receipts home even if they leave at that point.
 local parked=e.runsByMode[mode]
 if not parked then return end
 local chapter=C.byId[parked.missionId]
 if parked.completed and chapter and not chapter.side then chapter=C.mainChapters[parked.journal.main+1] end
 if not chapter or chapter.id==active.missionId then return end
 local prefix=chapter.id..':'
 for key in pairs(active.kills) do
  if key:sub(1,#prefix)==prefix then
   local originalKey=parked.missionId==chapter.id and key:sub(#prefix+1) or key
   parked.kills[originalKey]=true
  end
 end
end
return M
