assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local M=require(W.CampaignSurfaceUnderlays)
local report={checks=0,hidden=0,physicalParts=0}
local function check(ok,m)report.checks+=1;assert(ok,m)end
local before={}
for _,p in world.folder:GetDescendants()do if p:IsA('BasePart')then
 before[p]={p.CFrame,p.Size,p.CanCollide,p.CanQuery,p.CanTouch,p.Transparency,p.CastShadow};report.physicalParts+=1
 if (p:GetAttribute('FVUnderlayTransparency')~=nil or p:GetAttribute('GWUnderlayTransparency')~=nil or p:GetAttribute('ECUnderlayTransparency')~=nil or p:GetAttribute('HGUnderlayTransparency')~=nil) then
  report.hidden+=1
  check(p.Transparency==1 and not p.CastShadow and p.CanCollide and p.CanQuery,'hidden render underlay keeps real floor collision')
 end
end end
check(report.hidden==68,'confirmed regional underlays only')
for prefix,n in {FV=20,GW=14,EC=20,HG=14}do check(world.folder:GetAttribute(prefix..'ConsolidatedUnderlays')==n,'per-region count '..prefix)end
check(M.apply(world)==68 and M.apply(world)==68,'repeat calls are stable')
for p,v in before do
 check(p.CFrame==v[1]and p.Size==v[2]and p.CanCollide==v[3]and p.CanQuery==v[4]and p.CanTouch==v[5],'all physical geometry unchanged')
 check(p.Transparency==v[6]and p.CastShadow==v[7],'repeat render state stable')
end
for _,id in {'GW-01','EC-05','HG-03'}do
 local floor
 for _,p in world.terrain:GetDescendants()do if p:IsA('BasePart')and p.Name=='JourneyGround'and p:GetAttribute('RouteZone')==id then floor=p end end
 check(floor~=nil and floor.Transparency==0,'visible canonical floor '..id)
 local tagged={};local key=id:sub(1,2)..'UnderlayTransparency'
 for _,p in world.terrain:GetDescendants()do if p:IsA('BasePart')and p:GetAttribute(key)~=nil and math.abs(p.Position.X-floor.Position.X)<1 and math.abs(p.Position.Z-floor.Position.Z)<1 then tagged[#tagged+1]=p end end
 check(#tagged==2,'two matching underlays '..id)
 local size,cf=floor.Size,floor.CFrame
 floor.Size=size-Vector3.new(2,0,0)
 check(M.apply(world)==66,'partial cover rejected '..id)
 for _,p in tagged do check(p.Transparency==0,'original alpha restored '..id)end
 floor.Size=size;M.apply(world)
 floor.Transparency=1
 check(M.apply(world)==66,'invisible cover rejected '..id)
 floor.Transparency=0;M.apply(world)
 floor.CFrame=cf*CFrame.Angles(0,.1,0)
 check(M.apply(world)==66,'rotated cover rejected '..id)
 floor.CFrame=cf;check(M.apply(world)==68,'cover restored '..id)
end
print('REGIONAL_SURFACE_UNDERLAYS '..game.HttpService:JSONEncode(report))
return report
