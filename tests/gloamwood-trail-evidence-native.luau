assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
for _,s in game:GetDescendants()do if s:IsA('BaseScript')then s.Enabled=false end end
local bp=workspace:FindFirstChild('Baseplate');if bp then bp:Destroy()end
local W=game.ServerScriptService.Server.World
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local world=require(W.CampaignWorld).create(2)
local parent=world.folder.EpicWorldArt.EpicWorldArt_2['GW-01']
local root=assert(parent:FindFirstChild('ScoutsTrailEvidence'))
local report={checks=0,marks=0,ruts=0,footprints=0}
local function check(value,message)report.checks+=1;assert(value,message)end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={workspace.Terrain,world.terrain};params.RespectCanCollide=true
local function ground(p)
 local h=workspace:Raycast(p+Vector3.new(0,180,0),Vector3.new(0,-480,0),params)
 return h and h.Position or p,h~=nil
end
local function validate(r)
 check(r:GetAttribute('MarkCount')==34,'all local story marks must render')
 for _,p in r:GetChildren()do
  check(p:IsA('BasePart')and p.Anchored,'anchored primitive')
  check(p.Shape==Enum.PartType.Ball,'rounded impression silhouette')
  check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'no physics/query/touch changes')
  local floor,ok=ground(p.Position)
  check(ok and math.abs(p.Position.Y-floor.Y-.025)<.002,'visible on final wing floor')
  check(math.abs(p.Size.Y-.025)<.00001 and not p.CastShadow,'flat non-occluding mark')
 end
end
validate(root)
for _,p in root:GetChildren()do
 report.marks+=1
 if p.Name=='LoadedWheelRut'then report.ruts+=1;check(p.CFrame.LookVector:Dot(Vector3.new(0,0,-1))>.999,'convoy north')else report.footprints+=1 end
end
local snapshot={}
for _,p in world.folder:GetDescendants()do if p:IsA('BasePart')and not p:IsDescendantOf(root)then snapshot[p]={p.CFrame,p.Size,p.CanCollide,p.CanQuery,p.CanTouch}end end
local before=game.HttpService:JSONEncode(C.byId['GW-01'])
root=require(W.GloamwoodTrailEvidence).build(parent,C.byId['GW-01'],ground);validate(root)
check(game.HttpService:JSONEncode(C.byId['GW-01'])==before,'chapter state unchanged')
for p,v in snapshot do check(p.CFrame==v[1]and p.Size==v[2]and p.CanCollide==v[3]and p.CanQuery==v[4]and p.CanTouch==v[5],'existing geometry unchanged')end
local fixture=Instance.new('Folder')
local none=require(W.GloamwoodTrailEvidence).build(fixture,C.byId['GW-01'],function(p)return p,false end)
check(#none:GetChildren()==0,'void rejected')
local slope=require(W.GloamwoodTrailEvidence).build(fixture,C.byId['GW-01'],function(p)return Vector3.new(p.X,p.X*.5,p.Z),true end)
check(#slope:GetChildren()==0,'slope rejected')
fixture:Destroy()
_G.TraceRoot=root;_G.TraceWorld=world;_G.TraceReport=report
return game.HttpService:JSONEncode(report)
