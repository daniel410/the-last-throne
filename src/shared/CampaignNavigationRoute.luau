-- Client guidance follows the same regional corridors accepted by the server.
-- This is presentation only; it never grants access or moves a character.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local C,A,B,Incident=load('CampaignContent'),load('CampaignAreas'),load('CampaignBounds'),load('CampaignIncidentRoute')
local N={}
local function distance(a,b)return math.sqrt((a[1]-b[1])^2+(a[3]-b[3])^2)end
local neighbors={}
for _,edge in ipairs(C.edges)do
 -- Crossing an epic boundary is a server transfer, never an overland shortcut.
 if C.zones[edge[1]].epic==C.zones[edge[2]].epic then
  local first,last=B.ends(edge)
  for _,row in ipairs({{edge[1],edge[2],first,last},{edge[2],edge[1],last,first}})do
   neighbors[row[1]]=neighbors[row[1]]or {}
   table.insert(neighbors[row[1]],{to=row[2],entry=row[3],exit=row[4],cost=distance(C.zones[row[1]].center,C.zones[row[2]].center)})
  end
 end
end
local function chain(from,to)
 local costs,previous,visited={[from]=0},{},{}
 while true do
  local current
  for id,cost in pairs(costs)do if not visited[id]and(not current or cost<costs[current]or cost==costs[current]and id<current)then current=id end end
  if not current then return end
  if current==to then
   local result={}
   while current~=from do local step=previous[current];table.insert(result,1,step.link);current=step.from end
   return result,costs[to]
  end
  visited[current]=true
  for _,link in ipairs(neighbors[current]or {})do
   local cost=costs[current]+link.cost
   if not costs[link.to]or cost<costs[link.to]then costs[link.to]=cost;previous[link.to]={from=current,link=link}end
  end
 end
end
local function region(p)
 -- An area/connector belongs to its owning zone even outside the main rectangle.
 local _,id=B.region(p[1],p[3],.05);return id
end
function N.route(origin,target)
 local from,to=region(origin),region(target)
 if not to then return {origin}end
 local links,prefix
 if from then
  if from==to then return Incident.route(origin,target)end
  links=chain(from,to)
 else
  if not B.surface(origin[1],origin[3])then return {origin}end
  -- While walking between regions, choose the onward end by remaining route
  -- cost. Nearest-zone selection can reverse the arrows halfway down a pass.
  local best
  for _,edge in ipairs(C.edges)do
   local z1,z2=C.zones[edge[1]],C.zones[edge[2]]
   if z1.epic==z2.epic and z1.epic==C.zones[to].epic then
    local first,last=B.ends(edge)
    local dx,dz=last[1]-first[1],last[3]-first[3];local length2=dx*dx+dz*dz
    local t=length2>0 and ((origin[1]-first[1])*dx+(origin[3]-first[3])*dz)/length2 or -1
    t=math.max(0,math.min(1,t))
    local projection={first[1]+dx*t,first[2]+(last[2]-first[2])*t,first[3]+dz*t}
    if distance(origin,projection)<=B.trailHalfWidth then
     for _,candidate in ipairs({{edge[1],first},{edge[2],last}})do
      local path,cost=chain(candidate[1],to)
      if path then
       -- Center-distance costs are shared by both directions. Include the
       -- end-to-center leg so a destination in the neighboring zone wins.
       cost=cost+distance(origin,candidate[2])+distance(candidate[2],C.zones[candidate[1]].center)
       if not best or cost<best then best=cost;from=candidate[1];links=path;prefix={origin,projection,candidate[2]}end
      end
     end
    end
   end
  end
 end
 if not links then return {origin}end
 local result={origin}
 local function add(p)
  local last=result[#result]
  if distance(last,p)>.01 then result[#result+1]=p end
 end
 if prefix then for i=2,#prefix do add(prefix[i])end end
 local function localLeg(targetPoint)
  local points=Incident.route(result[#result],targetPoint)
  for i=2,#points do add(points[i])end
 end
 for _,link in ipairs(links)do localLeg(link.entry);add(link.exit)end
 localLeg(target)
 return result
end
return N
