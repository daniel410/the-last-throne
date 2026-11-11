-- Narrative corrections may change prose, never the saved/runtime campaign contract.
local original=dofile
dofile=function(path)
 if path=='src/shared/CampaignStoryText.luau'then return {install=function()end}end
 return original(path)
end
local before=dofile('src/shared/CampaignContent.luau')
dofile=original
local C=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local Guide=dofile('src/shared/CampaignStoryGuide.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local prose={title=true,text=true,brief=true,outcome=true,clue=true,promise=true}
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not prose[k]and not same(v,b[k])then return false end end
 for k in pairs(b)do if not prose[k]and a[k]==nil then return false end end;return true
end
check(same(before.chapters,C.chapters),'all prerequisite, reward, combat, ownership, choice, and activity data stays stable')
check(same(before.zones,C.zones)and same(before.edges,C.edges),'story corrections never move routes or regions')
check(#C.chapters==47 and #C.mainChapters==35,'35 main and 12 optional stories retained')
local briefs,outcomes={},{}
for _,c in ipairs(C.chapters)do
 check(not briefs[c.quest.brief],'each story has a distinct current purpose '..c.id);briefs[c.quest.brief]=true
 check(not outcomes[c.quest.outcome],'each story has a distinct earned result '..c.id);outcomes[c.quest.outcome]=true
 for _,g in ipairs(c.goals)do
  if g.activity and g.activity.steps and #g.activity.steps==1 then check(g.text==g.activity.steps[1].text,'single-step goal and actual dialogue share the same reviewed text '..c.id..':'..g.id)end
  if not c.side and c.number<28 then
   check(not (g.text or ''):find('Veyr',1,true),'villain name is not revealed before the furnace dispatch '..c.id..':'..g.id)
   for _,step in ipairs(g.activity and g.activity.steps or {})do check(not step.text:find('Veyr',1,true),'substep does not leak later knowledge')end
  end
 end
end
check(not C.epics[4].promise:find('Veyr',1,true),'the regional summary does not reveal the villain before the evidence')
local function goal(id,key)for _,g in ipairs(C.byId[id].goals)do if g.id==key then return g end end end
check(goal('DW-07','core_record').text:find('Gloamwood',1,true),'parent objective no longer points directly to Frozen Vale')
check(goal('DW-07','core_record').activity.steps[1].text:find('food-and-medicine',1,true),'stolen Crownheart cargo is distinguished from the local supply convoy')
check(not C.byId['DW-03'].quest.outcome:find('free companion',1,true),'recruitment does not promise unlimited free combat support')
check(goal('DW-03','report').activity.steps[2].text:find('saved support credits',1,true),'later support is explained without changing rights')
check(C.byId['EC-07'].quest.outcome:find('before your arrival',1,true),'heart departure precedes the furnace arrival')
check(goal('HG-02','elowen').text:find('heart is intact',1,true),'the key frame does not destroy the heart to be restored')
check(goal('HG-03','passage').text:find('main gate',1,true),'Lumi service passage does not make the alliance gate redundant')
check(C.byId['HG-06'].quest.outcome:find('Defeat Veyr',1,true),'final approach explains the actual next boss and recovery order')
check(goal('HG-07','exp_2').activity.steps[1].text:find('already free',1,true),'empty-frame work follows rather than repeats heart recovery')
check(C.byId['FV-04'].quest.outcome:find('palace still',1,true),'local repair does not prematurely end the valley alarm')
check(C.byId['GW-07'].quest.outcome:find('Frozen Vale',1,true)and C.byId['EC-07'].quest.outcome:find('Haunted Graveyard',1,true),'outcomes name actual next regions')
local s=assert(P.enableExpansion(P.new()));local steps=0
for _,c in ipairs(C.mainChapters)do
 for _,g in ipairs(c.goals)do if P.required(s,g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   s=assert(P.apply(s,c.id,g.id,step and step.choices and (step.solution or step.choices[1].id)or g.choice and 'shared',step and step.id or nil));steps=steps+1
   check(P.validate(s),'existing checkpoints remain valid through revised narrative')
  end
 end end
 check(s.clears[c.id]and Guide.recap(s,c)==c.quest.outcome,'confirmed recap matches the reviewed earned outcome')
end
check(s.main==35 and s.clears['HG-07'],'all main stories still finish without side quests or supporter state')
print('CAMPAIGN_CONTEXT_REVIEW '..checks..' checks passed; '..steps..' saved transitions, 47 distinct stories, unchanged runtime contracts')
