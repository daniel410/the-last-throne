local C=dofile('src/shared/CampaignContent.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local Access=dofile('src/shared/CampaignAccess.luau')
local Bounds=dofile('src/shared/CampaignBounds.luau')
local Balance=dofile('src/shared/DeepwoodEncounterBalance.luau')
local Config=dofile('src/shared/FrozenValeCombat.luau')
local checks=0
local function check(x,m)checks=checks+1;assert(x,m)end
local s=P.new();check(P.validate(s),'new order journal accepted')
local frozenXP,frozenGold,kinds=0,0,{}
for number=1,21 do
 local c=C.mainChapters[number];check(c and c.number==number,'contiguous main story')
 for _,g in ipairs(c.goals)do
  check(P.available(s,c,g),'ordered goal available '..c.id..':'..g.id)
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do
    local choice=step.choices and step.choices[1].id
    local n,e=P.apply(s,c.id,g.id,choice,step.id);check(n and not e,'saved activity step');s=n
   end
  else
   local n,e=P.apply(s,c.id,g.id,g.choice and 'sanctuary' or nil);check(n and not e,'saved interaction/battle');s=n
  end
  check(P.validate(s),'journal valid after each event')
  local again,e,reward=P.apply(s,c.id,g.id);check(again and not e and reward.repeated and reward.xp==0 and reward.coins==0,'retry cannot duplicate reward')
  if c.epic==3 then
   for _,enemy in ipairs(g.enemies)do kinds[enemy.kind]=true;check(Config.profiles[enemy.kind]~=nil,'server combat profile')end
   local batches=Balance.encounterWaves(c,g);for _,batch in ipairs(batches)do check(#batch<=Balance.packSize(c,g),'bounded finite wave')end
  end
 end
 check(s.main==number and s.clears[c.id],'chapter advances only after all goals')
 if c.epic==3 then frozenXP=frozenXP+c.reward.xp;frozenGold=frozenGold+c.reward.coins end
 if number==7 then
  local old=P.copy(s);check(P.validate(old) and old.coins==2290,'old Deepwood complete save retained')
  local locked=P.copy(s);locked.main=8;check(not P.validate(locked),'no forged clear/main')
 end
end
check(frozenXP==2158 and frozenGold==3360,'canonical FV story XP/Gold preserved')
check(s.coins==5650 and P.validate(s),'combined exact earned Gold cap')
for _,c in ipairs(C.chapters)do if c.epic==3 and c.side then
 local n,e=P.accept(s,c.id,true);check(n and not e,'optional discovery accepted');s=n
 for _,g in ipairs(c.goals)do
  for _,enemy in ipairs(g.enemies)do kinds[enemy.kind]=true end
  if not s.flags[c.id..':'..g.id] then s=assert(P.apply(s,c.id,g.id))end
 end
 check(s.clears[c.id] and P.validate(s),'optional report complete and saved')
end end
local count=0;for k in pairs(kinds)do count=count+1;check(Config.profiles[k]~=nil,'all ten combat profiles')end
check(count==10,'ten TD species used in actual objectives')
local old=P.new();check(not Access.allowed(old,'FV-01'),'new hero cannot skip Deepwood')
old.main=14;check(Access.allowed(old,'FV-01') and not Access.allowed(old,'FV-02'),'first FV gate unlocks after Gloamwood')
for id,z in pairs(C.zones)do if id:sub(1,3)=='FV-' then
 check(Access.region(z.center[1],z.center[3])==id,'atlas/region center agrees')
 check(Bounds.supported(z.center[1],z.center[2]+3,z.center[3]),'authoritative winter ground')
end end
print('FROZEN_VALE_STATIC '..checks..' checks passed')
