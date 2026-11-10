local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,P,B,E=load('CampaignContent'),load('DeepwoodProgress'),load('DeepwoodEncounterBalance'),load('EnemyPatterns')
local S=dofile('src/server/World/StoryMonsterSizing.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local c=C.byId['GW-06'];local goal=P.goal(c,'rear_guard')
check(c.number==13 and c.epic==2,'GW-06 remains the sixth Gloamwood story')
check(goal.enemies[1].kind=='Silkweaver' and goal.enemies[1].count==2,'existing guard kinds and count preserved')
check(goal.enemies[2].kind=='HollowbarkSovereign' and goal.enemies[2].level==16,'new boss is projected to Gloamwood Lv16')
check(B.isBoss('HollowbarkSovereign') and E.get('HollowbarkSovereign').boss,'server boss classification')
local rig,visual=S.forStory('HollowbarkSovereign',true);check(rig==1 and visual==1,'canonical 14stud visual not scaled again')
for party=1,4 do
 local oldGoal={id=goal.id,enemies={goal.enemies[1]}}
 local old={};for _,wave in ipairs(B.encounterWaves(c,oldGoal,party))do for _,u in ipairs(wave)do old[u.killIndex]=u end end
 local bosses=0;local waves=B.encounterWaves(c,goal,party)
 for wi,wave in ipairs(waves)do
  check(#wave<=B.packCapacity(c,goal,party),'bounded encounter capacity')
  for _,u in ipairs(wave)do
   if u.kind=='HollowbarkSovereign'then
    bosses=bosses+1;check(wi==#waves and not old[u.killIndex],'boss only in final wave with a new receipt ID')
   else
    local before=assert(old[u.killIndex]);check(before.kind==u.kind,'existing guard kill receipt index preserved')
    for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
     local xp,gold=B.rewards(u,mode,13);local ox,og=B.rewards(before,mode,13)
     check(xp==ox and gold==og,'existing per-guard reward preserved')
    end
    old[u.killIndex]=nil
   end
  end
 end
 check(bosses==1 and next(old)==nil,'one boss for every party size; no old guard omitted')
end
-- Old completed rear_guard flags remain valid and are never reopened.
local s=P.new()
for _,chapter in ipairs(C.mainChapters)do
 for _,g in ipairs(chapter.goals)do if not g.optional then
  check(P.available(s,chapter,g),'campaign remains sequentially reachable')
  if g.activity and g.activity.steps then
   for _,step in ipairs(g.activity.steps)do s=assert(P.apply(s,chapter.id,g.id,step.choices and step.choices[1].id,step.id))end
  else s=assert(P.apply(s,chapter.id,g.id,g.choice and 'sanctuary'))end
 end end
 check(P.validate(s),'existing journal schema accepts clear')
 if chapter.id=='GW-06'then
  check(s.flags['GW-06:rear_guard'] and s.clears['GW-06'],'stable goal and chapter clear recorded')
  check(not P.available(s,c,goal),'historical completed goal not reopened')
  local again,err,reward=P.apply(s,c.id,goal.id)
  check(again and not err and reward.repeated and reward.xp==0 and reward.coins==0,'old completed objective retry gives no reward')
 end
end
check(s.main==35 and s.coins==16570,'35 chapters and fixed journal Gold preserved')
check(P.goal(C.byId['GW-04'],'ent').enemies[1].kind=='AncientHollowbark','old ent retained')
check(P.goal(C.byId['GW-05'],'king').enemies[1].kind=='VenomcoilKing','king retained')
check(P.goal(C.byId['GW-07'],'queen').enemies[1].kind=='WidowQueen','queen finale retained')
-- Evaluate the real motion modules with only the CFrame value constructor stubbed.
local savedRequire,savedScript,savedFrame=require,script,CFrame
CFrame={new=function(...)return {...}end};script={Parent={AncientHollowbark='ent'}}
require=function(id)assert(id=='ent');return dofile('src/client/GloamwoodClips/AncientHollowbark.luau')end
local motion=dofile('src/client/GloamwoodClips/HollowbarkSovereign.luau')
local bones={};for _,name in ipairs(motion.bones)do bones[name]=true end
check(#motion.bones==10,'ten dedicated TD bones')
for _,name in ipairs({'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned','Exposed','Return','Interrupted'})do
 local clip=assert(motion.clips[name]);check(clip.duration>0,'positive clip duration')
 for bone,track in pairs(clip.tracks)do
  check(bones[bone] and #track==41,'every animated track addresses a real bone with 41 samples')
  for _,frame in ipairs(track)do for _,v in ipairs(frame)do check(type(v)=='number' and v==v and math.abs(v)<math.huge,'finite pose components')end end
 end
end
require,script,CFrame=savedRequire,savedScript,savedFrame
print('HOLLOWBARK_SOVEREIGN '..checks..' checks passed')
