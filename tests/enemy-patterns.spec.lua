local P=dofile('src/shared/EnemyPatterns.luau')
local G=dofile('src/shared/EnemyAttackGeometry.luau')
local C=dofile('src/shared/CampaignContent.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local D=dofile('src/shared/Difficulty.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local seen,ids={},{ };local count,bosses=0,0
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.goals)do
 for _,wave in ipairs(B.encounterWaves(c,g,1))do for _,unit in ipairs(wave)do seen[unit.kind]=unit end end
end end
for kind,unit in pairs(seen)do
 local profile=P.get(kind);check(profile~=nil,'missing actual enemy '..kind);count=count+1
 check(profile.boss==B.isBoss(kind),'boss classification preserved')
 if profile.boss then bosses=bosses+1 end
 check(#profile.attacks==(profile.boss and 4 or 2),'authored count')
 for _,a in ipairs(profile.attacks)do
  check(not ids[a.id],'unique attack ID');ids[a.id]=true
  check(a.windup>=1 and a.recovery>=.8 and a.active>0,'reaction/opening budget')
  check(a.pulses>=1 and a.pulses<=3 and a.fan<=3,'finite damage and visual budget')
  check(a.range<=32 and a.maxRange<=32,'bounded range')
 end
 local history={};local t=0;local last
 for i=1,20 do
  local chosen=P.choose(kind,4,history,t)
  check(chosen~=nil,'reachable action for solo')
  check(chosen.id~=last,'nonrepeated actions')
  P.commit(history,chosen,t);last=chosen.id;t=t+10
 end
 for _,mode in ipairs(D.order)do for _,party in ipairs({1,4})do
  local h,d,l,e=B.unitStats(unit,party,mode,8,1);local hp,damage,level,elite=B.unitStats(unit,party,mode,9,1)
  check(h==hp and d==damage and l==level and e==elite,'rule9 preserves rule8 stats')
  local x,y=B.rewards(unit,mode,8);local xp,gold=B.rewards(unit,mode,9)
  check(x==xp and y==gold,'rule9 preserves rewards')
 end end
end
check(count==49 and bosses==22,'actual roster coverage')
for v=1,8 do check(not P.enabled(v)and D.compatible(v),'old runs remain supported and old patterns')end
check(P.enabled(9)and not P.enabled(nil),'new-run gate')
check(G.contains('cone',0,5,0,6,2,4,2,90),'cone front')
check(not G.contains('cone',5,0,0,6,2,4,2,90),'cone side')
check(not G.contains('cone',0,-1,0,6,2,4,2,90),'cone behind')
check(G.contains('line',1,5,0,10,2,4,2,90),'line path')
check(not G.contains('line',3,5,0,10,2,4,2,90),'line safe side')
check(G.contains('circle',2,2,0,10,2,4,2,90),'circle inside')
check(not G.contains('circle',2,2,9,10,2,4,2,90),'different floor safe')
check(not G.contains('ring',0,0,0,10,2,4,2,90),'ring safe center')
check(G.contains('ring',3,0,0,10,2,4,2,90),'ring band')
check(not G.contains('ring',5,0,0,10,2,4,2,90),'ring safe exterior')
local distance,t=G.segmentDistance(0,0,-5,0,0,0,0,0,-10)
check(distance==0 and t==.5,'swept projectile cannot tunnel')
check(G.segmentDistance(3,0,-5,0,0,0,0,0,-10)==3,'side dodge')
print('enemy-patterns: '..n..' checks PASS;49 kinds/22 bosses, geometry, version8/9 stats/rewards')
