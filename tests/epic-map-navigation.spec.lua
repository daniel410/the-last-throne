local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,B,A,R=load('CampaignContent'),load('CampaignBounds'),load('CampaignAccess'),load('CampaignNavigationRoute')
local checks,targets,steps=0,0,0
local function check(v,m)checks=checks+1;assert(v,m)end
local function distance(a,b)return math.sqrt((a[1]-b[1])^2+(a[3]-b[3])^2)end
local function follow(current,target,main,label)
 local n=0
 while distance(current,target)>8 and n<2500 do
  local points=R.route(current,target);check(#points>1,'route missing '..label)
  local p=points[2];local d=distance(current,p);check(d>.01,'vertical/duplicate waypoint '..label)
  local t=math.min(1,4/d);local x,z=current[1]+(p[1]-current[1])*t,current[3]+(p[3]-current[3])*t
  local y=B.surface(x,z);check(y~=nil,'outside authority '..label)
  check(A.allowed({main=main},A.region(x,z)),'locked region before target eligibility '..label)
  current={math.floor(x*10000+.5)/10000,y+3,math.floor(z*10000+.5)/10000};n=n+1;steps=steps+1
 end
 check(n<2500,'waypoint oscillation '..label)
 return current
end
for _,c in ipairs(C.chapters)do if c.epic>=2 then
 local current=C.zones[c.zone].center;local main=c.minMain
 for _,g in ipairs(c.goals)do
  main=math.max(main,g.minMain or 0)
  local points=c.combatRoutes and c.combatRoutes[g.id]and c.combatRoutes[g.id].points
  local positions={}
  if points and #points>0 then positions=points
  elseif g.activity and g.activity.steps and #g.activity.steps>0 then for _,s in ipairs(g.activity.steps)do positions[#positions+1]=s.position end
  else positions={g.position}end
  for _,p in ipairs(positions)do targets=targets+1;current=follow(current,p,main,c.id..':'..g.id)end
 end
end end
-- Coordinates captured from the actual stalled return routes in 0.102.9.
for _,case in ipairs({{'FV-Q1',{-788.0109252929688,57,-4442.29541015625},15},{'EC-Q1',{-950,103,-8332},22}})do
 for _,g in ipairs(C.byId[case[1]].goals)do if g.id=='report'then follow(case[2],g.position,case[3],case[1]..':regression')end end
end
follow({879.9625854492188,199.19241333007812,-16954.892578125},C.zones['HG-02'].center,35,'HG boundary steering regression')
print('EPIC_MAP_NAVIGATION '..checks..' checks PASS; '..targets..' active targets; '..steps..' moving samples')
