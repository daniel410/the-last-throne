local C=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local D=dofile('src/shared/Difficulty.luau')
local Access=dofile('src/shared/CampaignAccess.luau')
local Bounds=dofile('src/shared/CampaignBounds.luau')
local Balance=dofile('src/shared/DeepwoodEncounterBalance.luau')
local Combat=dofile('src/shared/LateEpicCombat.luau')
local Completion=dofile('src/shared/StoryCompletion.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local s=P.new();local hgXP,hgGold=0,0;local kinds={}
check(C.mainCount==35 and #C.epics==5,'five complete epics')
for number=1,C.mainCount do
 local c=assert(C.mainChapters[number]);check(c.number==number,'contiguous main sequence')
 if number>=22 then
  local locked=P.copy(s);check(not P.apply(locked,c.id,c.goals[#c.goals].id,nil,'confirmed'),'cannot skip a late story objective')
  check(Access.allowed(s,c.zone),'region unlocks from exact previous clear')
  check(D.allowed({level=27,deepwood=s},c.id,'Easy'),'provisional late route has no new unbudgeted level gate')
  if number>22 then check(not Access.allowed(P.new(),c.zone),'new hero cannot enter late region')end
 end
 for _,g in ipairs(c.goals)do
  check(P.available(s,c,g),'next goal available '..c.id..':'..g.id)
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do
    s=assert(P.apply(s,c.id,g.id,step.choices and step.choices[1].id,step.id))
    local again,err,reward=P.apply(s,c.id,g.id,step.choices and step.choices[1].id,step.id)
    check(again and not err and reward.repeated and reward.xp==0 and reward.coins==0,'substep retry cannot duplicate rewards')
    check(P.validate(P.copy(s)),'saved substep survives serialization copy')
   end
  else s=assert(P.apply(s,c.id,g.id,g.choice and 'sanctuary'))end
  check(P.validate(s),'journal valid after event')
  local again,err,reward=P.apply(s,c.id,g.id)
  check(again and not err and reward.repeated and reward.xp==0 and reward.coins==0,'goal retry cannot duplicate rewards')
  if number>=22 then
   check(Bounds.supported(g.position[1],g.position[2]+3,g.position[3]),'goal on authoritative terrain')
   for _,e in ipairs(g.enemies)do kinds[e.kind]=true;check(Combat.profiles[e.kind]~=nil,'actual enemy has server attack profile')end
   for _,wave in ipairs(Balance.encounterWaves(c,g))do check(#wave<=Balance.packSize(c,g),'finite bounded encounter pack')end
  end
 end
 check(s.main==number and s.clears[c.id],'clear advances exactly one story')
 if c.epic==4 then check(c.reward.xp==0 and c.reward.coins==0,'GW fixed reward budget remains unassigned')end
 if c.epic==5 then hgXP=hgXP+c.reward.xp;hgGold=hgGold+c.reward.coins end
 if number==7 or number==14 or number==21 or number==28 then
  local save=P.copy(s);check(P.validate(save),'existing/transition save retained')
  check(C.mainChapters[save.main+1]~=nil,'next epic available after saved handoff')
 end
end
check(hgXP==6091 and hgGold==6280,'approved HG fixed rewards unchanged')
check(s.coins==16570 and P.validate(s),'exact campaign fixed Gold')
local final=Completion.project({heroId='hero',journal=s,completion={id='HG-07',xp=1252,coins=1600}})
check(final and not final.nextId and final.guidance:find('Dawnspire',1,true),'ending sends player home without a sixth epic')
local count=0;for _ in pairs(kinds)do count=count+1 end;check(count==19,'eight GW and eleven HG kinds sharing ten TD templates')
check(s.flags['HG-07:crownheart'] and s.flags['HG-07:portal'],'heart recovered before portal closure')
local forged=P.copy(s);forged.flags['HG-07:crownheart']=nil;check(not P.validate(forged),'cannot claim portal closure without the heart')
print('LATE_EPICS_STATIC '..n..' checks passed')
