assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
local bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local V=Vector3.new
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={world.folder,workspace.Terrain}
local r={samples=0,holes={},lips={},steps={}}
for _,edge in C.edges do
 local aa,bb=B.ends(edge);local a,b=V(table.unpack(aa)),V(table.unpack(bb));local d=b-a;local flat=V(d.X,0,d.Z);local side=V(-flat.Z,0,flat.X).Unit;local unit=flat.Unit
 for _,offset in {-40,-24,-4,0,4,24,40}do
  local last
  local n=math.ceil(flat.Magnitude/2)
  for i=-12,n+12 do
   local at=a+flat*(i/n)+side*offset;local y=B.surface(at.X,at.Z)
   if y then
    local h=workspace:Raycast(V(at.X,y+24,at.Z),V(0,-64,0),ray);r.samples+=1
    if not h or h.Position.Y<y-1 then if #r.holes<30 then table.insert(r.holes,{edge=edge,offset=offset,at=tostring(at),expected=y,hit=h and h.Position.Y})end end
    if h and last and math.abs(h.Position.Y-last.y)>1.1 then if #r.steps<70 then table.insert(r.steps,{edge=edge,offset=offset,at=tostring(at),rise=h.Position.Y-last.y,part=h.Instance:GetFullName()})end end
    last=h and {y=h.Position.Y}or nil
   end
  end
 end
 task.wait()
end
print('STORY_SURFACE_BASELINE '..game.HttpService:JSONEncode(r))
return r
