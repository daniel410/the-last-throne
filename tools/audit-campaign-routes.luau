-- Isolated Studio Edit audit. Does not change world geometry, saves or progress.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'local player-free scene required')
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Bounds=require(Shared.CampaignBounds)
local world=assert(workspace:FindFirstChild('DeepwoodCampaign'))
local A={rows={},edges={},artVersion=world.EpicWorldArt:GetAttribute('ArtVersion')}
local V=Vector3.new
local function vec(t)return V(table.unpack(t))end
local function xyz(p)return {p.X,p.Y,p.Z}end
local function inside(p,part)
 local q=part.CFrame:PointToObjectSpace(p);local h=part.Size/2
 return math.abs(q.X)<h.X+1 and math.abs(q.Y)<h.Y+1 and math.abs(q.Z)<h.Z+1
end
local scenery={}
for _,p in ipairs(world:GetDescendants())do
 if p:IsA('BasePart')and not p.CanCollide and p.Transparency<.5 and p.Size.Y>8 and p.Size.Magnitude>20 then
  -- Bounding candidates are deliberately reported separately from proven collisions.
  table.insert(scenery,p)
 end
end
local physical=RaycastParams.new();physical.RespectCanCollide=true
physical.FilterType=Enum.RaycastFilterType.Include;physical.FilterDescendantsInstances={world,workspace.Terrain}
local function auditSegment(a,b,label)
 local row={label=label,a=xyz(a),b=xyz(b),samples=0,floorMisses=0,floorExamples={},visualCandidates={}}
 local d=b-a;local steps=math.max(1,math.ceil(d.Magnitude/8));local seen={}
 local near={}
 for _,p in ipairs(scenery)do
  local flat=V(d.X,0,d.Z);local t=math.clamp(V(p.Position.X-a.X,0,p.Position.Z-a.Z):Dot(flat)/math.max(.001,flat:Dot(flat)),0,1)
  local q=a:Lerp(b,t);local radius=p.Size.Magnitude/2+8
  if (p.Position-q).Magnitude<radius then table.insert(near,p)end
 end
 local normal=V(-d.Z,0,d.X);normal=normal.Magnitude>.001 and normal.Unit or V(1,0,0)
 for i=0,steps do
  local at=a:Lerp(b,i/steps)
  for _,side in ipairs({-4,0,4})do
   local p=at+normal*side;row.samples+=1
   local floor=workspace:Raycast(p+V(0,4,0),V(0,-16,0),physical)
   if not floor or math.abs(floor.Position.Y-p.Y)>2 then
    row.floorMisses+=1
    if #row.floorExamples<3 then table.insert(row.floorExamples,{p=xyz(p),hit=floor and floor.Instance:GetFullName(),height=floor and floor.Position.Y})end
   end
   for _,part in ipairs(near)do if not seen[part]and inside(p+V(0,4,0),part)then
    seen[part]=true;table.insert(row.visualCandidates,{path=part:GetFullName(),at=xyz(p),size=xyz(part.Size),mesh=part:IsA('MeshPart')})
   end end
  end
 end
 if d.Magnitude>.1 then
  local hit=workspace:Blockcast(CFrame.new(a+V(0,4,0)),V(4,5,4),d,physical)
  row.directCollision=hit and hit.Instance:GetFullName()or nil
  local path=game.PathfindingService:CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=8})
  local ok,err=pcall(function()path:ComputeAsync(a+V(0,3,0),b+V(0,3,0))end)
  row.pathStatus=ok and path.Status.Name or 'Error';row.pathError=not ok and tostring(err)or nil
  row.waypoints=ok and #path:GetWaypoints()or 0
  path:Destroy()
 else row.pathStatus='SamePoint'end
 task.wait()
 return row
end
function A.chapter(index)
 local chapter=Content.chapters[index];local out={id=chapter.id,zone=chapter.zone,side=chapter.side==true,segments={},crossZone={},anchors={}}
 local spawn=world:FindFirstChild(chapter.zone..'_SP');local previous=spawn.Position-V(0,.15,0)
 local function add(at,label)
  local _,from=Bounds.region(previous.X,previous.Z);local _,to=Bounds.region(at.X,at.Z)
  if from and to and from==to then table.insert(out.segments,auditSegment(previous,at,label))
  else table.insert(out.crossZone,{label=label,a=xyz(previous),b=xyz(at),from=from,to=to})end
  previous=at
 end
 for _,goal in ipairs(chapter.goals)do
  local p=vec(goal.position);table.insert(out.anchors,{id=goal.id,p=xyz(p)})
  local steps=goal.activity and goal.activity.steps
  if steps and #steps>0 then for _,s in ipairs(steps)do if s.position then add(vec(s.position),goal.id..':'..s.id)end end
  else add(p,goal.id)end
 end
 A.rows[index]=out;return out
end
function A.edge(index)
 local edge=Access.edges[index];local aa,bb=Bounds.ends(edge)
 local out=auditSegment(vec(aa),vec(bb),edge[1]..' -> '..edge[2]);A.edges[index]=out;return out
end
function A.inventory()return {chapters=#Content.chapters,edges=#Access.edges,scenery=#scenery,artVersion=A.artVersion}end
function A.returns()
 local out={}
 for _,chapter in ipairs(A.rows)do for _,r in ipairs(chapter.crossZone)do
  local queue={{id=r.from,chain={}}};local seen={[r.from]=true};local chain
  while #queue>0 do
   local node=table.remove(queue,1)
   if node.id==r.to then chain=node.chain;break end
   for i,edge in ipairs(Access.edges)do
    local target=edge[1]==node.id and edge[2]or edge[2]==node.id and edge[1]
    if target and not seen[target]then
     seen[target]=true;local path=table.clone(node.chain);table.insert(path,{index=i,forward=edge[1]==node.id});table.insert(queue,{id=target,chain=path})
    end
   end
  end
  local row={chapter=chapter.id,label=r.label,chain=chain,approaches={}}
  if chain then
   local previous=vec(r.a)
   for _,link in ipairs(chain)do
    local aa,bb=Bounds.ends(Access.edges[link.index]);local entrance,exit=vec(aa),vec(bb)
    if not link.forward then entrance,exit=exit,entrance end
    table.insert(row.approaches,auditSegment(previous,entrance,r.label..':connector_'..link.index))
    previous=exit
   end
   table.insert(row.approaches,auditSegment(previous,vec(r.b),r.label..':arrival'))
  else row.error='No access-graph route'end
  table.insert(out,row)
 end end
 A.returnRoutes=out;return out
end
return A
