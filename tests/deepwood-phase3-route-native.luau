-- Run after CampaignWorld generation in an isolated local Studio scene.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
local World=game.ServerScriptService.Server.World
local content=require(game.ReplicatedStorage.Shared.DeepwoodContent)
local kit=require(World.EpicEnvironmentKit)
local world=workspace.DeepwoodCampaign
local report={checks=0,pass=false,segments=0,samples=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='Phase3RouteQA';fixture.Parent=workspace
local ok,err=xpcall(function()
 -- Exact neighbor-zone outcrop that covered DW-01's final clue in the screenshot.
 local bad=kit.rock(fixture,Vector3.new(-1225,28.2,-1068.6666),Vector3.new(90,136,95),Color3.fromRGB(94,112,91),3)
 check(bad==nil,'neighboring cliff must not cover a playable clearing')
 local distant=kit.rock(fixture,Vector3.new(-8000,30,-8000),Vector3.new(90,100,95),Color3.fromRGB(94,112,91),3)
 check(distant~=nil,'distant scenic cliffs remain available');distant:Destroy()
 local params=RaycastParams.new();params.RespectCanCollide=true;params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world,workspace.Terrain}
 local cliffs={}
 for _,p in ipairs(world.EpicWorldArt:GetDescendants())do
  if p:IsA('MeshPart')and p.Parent.Name=='CliffRock' and p.Transparency<1 then table.insert(cliffs,p)end
 end
 local function segment(a,b)
  report.segments+=1
  local n=math.max(1,math.ceil((b-a).Magnitude/4))
  for i=0,n do
   local at=a:Lerp(b,i/n);report.samples+=1
   for _,side in ipairs({-6,0,6})do
    local d=b-a;local normal=Vector3.new(-d.Z,0,d.X);normal=normal.Magnitude>0 and normal.Unit or Vector3.xAxis
    local p=at+normal*side
    local floor=workspace:Raycast(p+Vector3.new(0,40,0),Vector3.new(0,-48,0),params)
    check(floor and math.abs(floor.Position.Y-p.Y)<.3,'continuous level walking floor '..tostring(p))
    for _,mesh in ipairs(cliffs)do
     local q=mesh.CFrame:PointToObjectSpace(p+Vector3.new(0,4,0));local half=mesh.Size/2
     check(math.abs(q.X)>half.X+2 or math.abs(q.Y)>half.Y+2 or math.abs(q.Z)>half.Z+2,'visible cliff cannot enclose the clue route '..mesh:GetFullName())
    end
   end
  end
  local direction=b-a
  if direction.Magnitude>.1 then
   local obstacle=workspace:Blockcast(CFrame.new(a+Vector3.new(0,4,0)),Vector3.new(4,5,4),direction,params)
   check(obstacle==nil,'body-width collision clearance '..tostring(obstacle and obstacle.Instance:GetFullName()))
  end
 end
 local tracks
 for _,g in ipairs(content.byId['DW-01'].goals)do if g.id=='tracks'then tracks=g end end
 local previous=Vector3.new(table.unpack(tracks.position))
 for _,s in ipairs(tracks.activity.steps)do local at=Vector3.new(table.unpack(s.position));segment(previous,at);previous=at end
 segment(previous,Vector3.new(table.unpack(content.byId['DW-01'].goals[5].position)))
 report.pass=true
end,debug.traceback)
fixture:Destroy();if not ok then report.error=err end
print('DEEPWOOD_PHASE3_ROUTE '..game.HttpService:JSONEncode(report));assert(ok,err);return report
