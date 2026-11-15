assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local W=game.ServerScriptService.Server.World
local world=require(W.CampaignWorld).create()
local M=require(W.FrozenSurfaceUnderlays)
local report={checks=0,hidden=0,physicalParts=0}
local function check(ok,m)report.checks+=1;assert(ok,m)end
local before={}
for _,p in world.folder:GetDescendants()do if p:IsA('BasePart')then
 before[p]={p.CFrame,p.Size,p.CanCollide,p.CanQuery,p.CanTouch,p.Transparency,p.CastShadow};report.physicalParts+=1
 if p:GetAttribute('FVUnderlayTransparency')~=nil then
  report.hidden+=1
  check(p.Transparency==1 and not p.CastShadow and p.CanCollide and p.CanQuery,'hidden render underlay keeps real floor collision')
 end
end end
check(report.hidden==20,'ten Frozen Vale clearings have two covered render underlays')
check(M.apply(world)==20 and M.apply(world)==20,'repeat calls are stable')
for p,v in before do
 check(p.CFrame==v[1]and p.Size==v[2]and p.CanCollide==v[3]and p.CanQuery==v[4]and p.CanTouch==v[5],'all physical geometry unchanged')
 check(p.Transparency==v[6]and p.CastShadow==v[7],'repeat render state stable')
end
local floor
for _,p in world.terrain.RouteFoundation3:GetChildren()do if p:GetAttribute('RouteZone')=='FV-03'then floor=p end end
check(floor~=nil and floor.Transparency==0,'visible canonical floor remains')
local support=world.terrain.FrozenValeFoundation['Support_FV-03']
local snow=world.terrain['FV-03'].SnowGround
local size=floor.Size
floor.Size=size-Vector3.new(2,0,0)
check(M.apply(world)==18 and support.Transparency==0 and snow.Transparency==0,'incomplete cover restores original underlays')
floor.Size=size;M.apply(world)
floor.Transparency=1
check(M.apply(world)==18 and support.Transparency==0 and snow.Transparency==0,'invisible cover cannot retire underlying render surface')
floor.Transparency=0;M.apply(world)
check(support.Transparency==1 and snow.Transparency==1,'cover restoration is reversible')
print('FROZEN_SURFACE_UNDERLAYS '..game.HttpService:JSONEncode(report))
return report
