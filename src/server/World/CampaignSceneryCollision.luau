-- Only permanent, visible scenery owns shared collision. Personal story poses
-- and their disappearing actors/bridges/gates must never become shared walls.
local Collision={version=1}
local solids={}
for name in string.gmatch([[
PineTrunk WeatheredTrunk FacetedOutcrop
ArchFoot ArchPier ArchCapital ArchVoussoir ArchKeystone
TowerFoot TowerShaft TowerButtress TowerCornice HallPlinth HallBack HallSide HallButtress HallRoof
PierCourse ArchImpost ArchStone Crownstone OctagonalWall TowerPlinth FlyingButtress
WingWall ButtressBase ButtressShaft ButtressCap GateRecess GateUpperPier GateParapetBeam
LodgeWall LodgeBack LodgeHeader PorchPost ShelterRoof PorchAwning
FurnaceChimney FurnaceInterior FurnaceInteriorLintel PipeSupport BrokenArchStump GatePier
CryptPlinth CryptRearWall CryptSideWall CryptColumnFoot CryptColumn CryptCapital CryptEntablature CryptDoorRecess
SarcophagusChest TombPlinth TombLid StoneBase Headstone
MineTimber MineLintel MineShadow
IceGalleryWall ArchivePillar TowerFrame RootGallery
]],'%S+')do solids[name]=true end
local meshSolids={trunk_geom=true,body_geom=true,walls_geom=true,door_geom=true,
 ['glacier peaks_geom']=true,['rune stone arch_geom']=true,
 ['basalt columns_geom']=true,['forge arch_geom']=true}
function Collision.isSolid(part,root)
 if not part:IsA('BasePart')or part.Transparency>=.95 then return false end
 local node=part.Parent;local template
 while node and node~=root do
  if node:GetAttribute('ExpansionEvent')or node:GetAttribute('ExpansionStepEvent')or node:GetAttribute('NPCActor')then return false end
  template=template or node:GetAttribute('TDEnvironmentSource')
  node=node.Parent
 end
 -- Material-fused terrain kits contain disconnected islands and waterfalls;
 -- retained Terrain/foundations already supply their traversable surfaces.
 if part:IsA('MeshPart')then
  return template~=nil and template~='TDWaterfallGorge'and template~='TDCanopyCrown'
   and meshSolids[part.Name]==true
 end
 return solids[part.Name]==true
end
function Collision.apply(root)
 local count=0
 for _,part in ipairs(root:GetDescendants())do
  if Collision.isSolid(part,root)then
   part.CanCollide=true;part.CanQuery=true;part.CanTouch=false
   part:SetAttribute('CampaignScenerySolid',true);count+=1
  end
 end
 root:SetAttribute('SceneryCollisionVersion',Collision.version)
 root:SetAttribute('SolidSceneryParts',count)
 return count
end
return Collision
