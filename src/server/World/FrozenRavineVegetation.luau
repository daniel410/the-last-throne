-- Recompose the pinned TD snow trees into broken, unequal windbreak groups.
-- No new mesh, texture, personal progress, or gameplay geometry source.
local Env=require(script.Parent.DeepwoodEnvironment)
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local M={version=1};local V=Vector3.new
function M.build(root,center,size,safe,ground)
 local west,east
 for _,g in ipairs(C.byId['FV-03'].goals)do
  if g.id=='west_beacon'then west=V(table.unpack(g.position))end
  if g.id=='east_beacon'then east=V(table.unpack(g.position))end
 end
 local function openSignal(p,r)
  local d=V(east.X-west.X,0,east.Z-west.Z);local offset=V(p.X-west.X,0,p.Z-west.Z)
  local t=math.clamp(offset:Dot(d)/d:Dot(d),0,1)
  return (offset-d*t).Magnitude>r+8
 end
 local count=0;local groups={};local used={}
 local function candidate(p,radius)
  if not safe(p,radius)or not openSignal(p,radius)then return end
  if math.abs(p.X-center.X)+radius>=size[1]/2 or math.abs(p.Z-center.Z)+radius>=size[2]/2 then return end
  for _,q in used do if (p-q).Magnitude<22 then return end end
  for _,a in ipairs(C.zones['FV-03'].expansionAreas or {})do
   if Areas.contains(a,p.X,p.Z,radius+8)or Areas.contains(a.connector,p.X,p.Z,radius+8)then return end
  end
  local at,supported=ground(p);if not supported then return end
  for _,d in ipairs({V(5,0,0),V(-5,0,0),V(0,0,5),V(0,0,-5)})do
   local q,ok=ground(p+d);if not ok or math.abs(q.Y-at.Y)>1 then return end
  end
  return at
 end
 for _,side in ipairs({-1,1})do for band,z in ipairs({-.36,.02,.35})do
  local anchor=center+V(side*size[1]*.41,0,z*size[2])
  for i,offset in ipairs({V(0,0,0),V(-side*18,0,24),V(side*12,0,43)})do
   local height=({46,27,35})[i]+(band==3 and 4 or 0);local radius=height*.25+4
   local at
   -- Uneven glacier shoulders can reject a whole regular row. Search a bounded
   -- neighborhood for real flat feet instead of weakening combat reservations.
   for ring=0,2 do
    for k=0,(ring==0 and 0 or 7)do
     local angle=k*math.pi/4;local p=anchor+offset+V(math.cos(angle)*ring*24,0,math.sin(angle)*ring*24)
     at=candidate(p,radius);if at then break end
    end
    if at then break end
   end
   if at then
    local m=Env.asset(root,'SnowTree',at,height)
    local yaw=(band*1.31+i*.79)*side
    m:PivotTo(CFrame.new(at)*CFrame.Angles(0,yaw,0)*CFrame.new(-at)*m:GetPivot())
    m:SetAttribute('VergeCluster',side..':'..band);m:SetAttribute('VergeHeight',height)
    m:SetAttribute('VergeSource','PinnedTD:SnowTree');m:SetAttribute('GroundPosition',at)
    count+=1;groups[side..':'..band]=true;used[#used+1]=at
   end
  end
 end end
 local n=0;for _ in pairs(groups)do n+=1 end
 root:SetAttribute('RavineVergeVersion',M.version);root:SetAttribute('VergeTrees',count);root:SetAttribute('VergeGroups',n)
 return root
end
return M
