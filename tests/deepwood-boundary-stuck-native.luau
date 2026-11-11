-- Regression for the DW-01 screenshot position and reused generated worlds.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene required')
local W=require(game.ServerScriptService.Server.World.CampaignWorld)
local world=W.create(1)
local V=Vector3.new
local r={checks=0,boundaries=0,zones={}}
local function check(v,m)r.checks+=1;assert(v,m)end
local physical=RaycastParams.new();physical.RespectCanCollide=true
physical.FilterType=Enum.RaycastFilterType.Include;physical.FilterDescendantsInstances={world.folder,workspace.Terrain}
local function crossing()
 return workspace:Blockcast(CFrame.new(-1760,3.7,-695.24),V(4,5,4),V(-42,0,0),physical)
end
for _,p in ipairs(world.folder:GetDescendants())do
 if p:IsA('BasePart')and p.Name=='ForestBoundary'then
  r.boundaries+=1;r.zones[p.Parent.Name]=true
  check(not p.CanCollide and not p.CanQuery and not p.CanTouch,'obsolete boundary retired '..p:GetFullName())
 end
end
check(r.boundaries>0,'legacy boundaries covered')
check(crossing()==nil,'screenshot crossing clear without jump')
local spawnCF=world.spawns['DW-01'].CFrame
-- Reintroduce exactly the reported stale wall and prove the probe detects it.
local wall
for _,p in ipairs(world.folder.GroundedForest['ForestEdge_DW-01']:GetChildren())do
 if p:IsA('BasePart')and p.Name=='ForestBoundary'and math.abs(p.Position.X+1778)<1 and math.abs(p.Position.Z+692.57)<2 then wall=p;break end
end
check(wall~=nil,'reported wall found')
wall.CanCollide=true;wall.CanQuery=true;wall.CanTouch=true
check(crossing()~=nil,'regression detects the original hidden wall')
check(W.create(1,world)==world,'loaded epic reused')
check(crossing()==nil and not wall.CanQuery and not wall.CanTouch,'loaded epic repairs stale collision')
check(world.spawns['DW-01'].CFrame==spawnCF,'checkpoint unchanged')
print('DEEPWOOD_BOUNDARY_STUCK '..game.HttpService:JSONEncode(r))
return r
