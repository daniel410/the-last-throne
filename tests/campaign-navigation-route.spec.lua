local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,B,R,Old=load('CampaignContent'),load('CampaignBounds'),load('CampaignNavigationRoute'),load('CampaignIncidentRoute')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function distance(a,b)return math.sqrt((a[1]-b[1])^2+(a[3]-b[3])^2)end
local function supported(points,label)
 check(#points>1,label..' has a walking route')
 for i=2,#points do local a,b=points[i-1],points[i];local n=math.max(1,math.ceil(distance(a,b)/4))
  for k=0,n do local t=k/n;local x,z=a[1]+(b[1]-a[1])*t,a[3]+(b[3]-a[3])*t
   check(B.surface(x,z)~=nil,label..' leaves server footprint at '..x..','..z)
  end
 end
end
local final=C.byId['DW-07'];local start,finish
for _,g in ipairs(final.goals)do if g.id=='separate'then start=g.activity.steps[#g.activity.steps].position elseif g.id=='restoration'then finish=g.position end end
local rejected=0
for _,a in ipairs({start})do local direct=Old.route(a,finish)
 for i=2,#direct do for k=0,200 do local t=k/200;local p,q=direct[i-1],direct[i]
  if not B.surface(p[1]+(q[1]-p[1])*t,p[3]+(q[3]-p[3])*t)then rejected=rejected+1 end
 end end
end
check(rejected>0,'old Eryn arrow crosses forbidden ground')
local points=R.route(start,finish);check(#points>=10,'report follows DW07 -> DW06 -> DW05 -> DW04 -> DW03')
supported(points,'Eryn return')
-- Recalculate after every walking step, as the live client does. The guide
-- must not reverse course on a connector or lead back to a passed entrance.
local current={start[1],start[2]+3,start[3]};local traveled=0;local iterations=0
while distance(current,finish)>2 and iterations<2000 do
 iterations=iterations+1;local route=R.route(current,finish);check(#route>1,'continuous return guidance')
 local nextPoint=route[2];local d=distance(current,nextPoint)
 if d<.02 then current={nextPoint[1],nextPoint[2]+3,nextPoint[3]}else
  local t=math.min(1,6/d);local x,z=current[1]+(nextPoint[1]-current[1])*t,current[3]+(nextPoint[3]-current[3])*t
  local y=B.surface(x,z);check(y~=nil,'moving arrows remain server-supported')
  current={math.floor(x*10000+.5)/10000,y+3,math.floor(z*10000+.5)/10000};traveled=traveled+math.min(6,d)
 end
end
check(iterations<2000 and distance(current,finish)<=2,'following the live route reaches Eryn without a loop')
supported(R.route({761.8499145507812,33.119964599609375,-2236.34228515625},finish),'physical connector exit cap')
local returns=0
for _,c in ipairs(C.chapters)do
 local previous=C.zones[c.zone].center
 for _,g in ipairs(c.goals)do
  for _,step in ipairs(g.activity and g.activity.steps or {{position=g.position}})do if step.position then
   local _,from=B.region(previous[1],previous[3]);local _,to=B.region(step.position[1],step.position[3])
   if from and to and from~=to and C.zones[from].epic==C.zones[to].epic then
    supported(R.route(previous,step.position),c.id..':'..g.id);returns=returns+1
   end
   previous=step.position
  end end
 end
end
for _,edge in ipairs(C.overlandLinks)do
 supported(R.route(C.zones[edge[1]].center,C.zones[edge[2]].center),'overland forward '..edge[1])
 supported(R.route(C.zones[edge[2]].center,C.zones[edge[1]].center),'overland return '..edge[2])
end
local localTarget={start[1]+8,start[2],start[3]+3}
check(#R.route(start,localTarget)==2,'same-region objective keeps direct guidance')
print('CAMPAIGN_NAVIGATION_ROUTE '..checks..' checks PASS; old rejected '..rejected..'; returns '..returns..'; live steps '..iterations..'; walking distance '..math.floor(traveled))
