local function load(n)return dofile('src/shared/'..n..'.luau')end
local D,B,C=load('Difficulty'),load('DeepwoodEncounterBalance'),load('CampaignContent')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
check(D.version==18 and D.compatible(17),'new runs pin rules18; saved rules17 accepted')
for _,mode in ipairs(D.order)do
 local factor=({Easy=1,Hard=1.25,Insane=1.35,Hell=1.5})[mode]
 for key,value in pairs(D.mode(mode,17))do
  if key~='damage'and key~='bossDamage'then check(D.mode(mode)[key]==value,'non-attack mode contract '..key)end
 end
 for kind,profile in pairs(load('EnemyPatterns').profiles)do
  for epic=1,5 do for party=1,4 do for _,level in ipairs({5,12,18,27,37})do
   local h0,d0,l0=D.stats(kind,level,party,profile.boss,mode,17,epic)
   local h1,d1,l1=D.stats(kind,level,party,profile.boss,mode,18,epic)
   check(h1==h0 and l1==l0,'HP and level preserved '..kind)
   check(math.abs(d1-d0*factor)<=1.25,'damage boost with final integer rounding '..kind)
   check(mode=='Easy'and d1==d0 or mode~='Easy'and d1>d0,'Easy stable; advanced damage increases')
  end end end
 end
 for _,c in ipairs(C.chapters)do
  local old,new=D.completion(c,mode,17),D.completion(c,mode,18)
  for key,value in pairs(old)do check(new[key]==value,'quest reward preserved '..c.id..' '..key)end
  for _,g in ipairs(c.goals)do for _,spec in ipairs(g.enemies or {})do
   local x0,g0=B.rewards(spec,mode,17);local x1,g1=B.rewards(spec,mode,18)
   check(x0==x1 and g0==g1,'kill rewards preserved '..c.id)
  end end
 end
end
print('Advanced mode damage: '..checks..' checks passed')
