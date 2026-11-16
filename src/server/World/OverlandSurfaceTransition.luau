-- Render-only thaw on the existing FV palace -> EC freight road.
-- No collision, query, touch, progression or changes to the server floor.
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local K=require(script.Parent.EpicEnvironmentKit)
local M={version=1}
local V=Vector3.new
function M.apply(world)
 local roads=world.folder:FindFirstChild('OverlandRoads')
 local root=roads and roads:FindFirstChild('FV-07_EC-01')
 if not root then return end
 local old=root:FindFirstChild('ThawSurface');if old then old:Destroy()end
 local aa,bb=Bounds.ends({'FV-07','EC-01'})
 local a,b=V(table.unpack(aa)),V(table.unpack(bb))
 local length=(b-a).Magnitude
 local surface=Instance.new('Folder');surface.Name='ThawSurface'
 local snow,basalt=K.palette.FrozenVale.ground,K.palette.EmberCaldera.ground
 -- Narrow staggered tongues avoid a single straight biome seam across the road.
 for lane=1,3 do
  for i=1,24 do
   local t=(i-.5)/24
   local melt=math.clamp((t-.14+(lane==2 and .06 or -.03))/.72,0,1)
   local blend=melt*melt*(3-2*melt)
   local p=Instance.new('Part');p.Name='ThawRoadSurface'
   p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
   p.Size=V(32,.06,length/24)
   p.CFrame=CFrame.lookAt(a:Lerp(b,t),b)*CFrame.new((lane-2)*32,.04,0)
   p.Color=snow:Lerp(basalt,blend)
   p.Material=melt<.23 and Enum.Material.Snow or melt<.72 and Enum.Material.Rock or Enum.Material.Basalt
   p:SetAttribute('ThawFraction',melt);p.Parent=surface
  end
 end
 surface.Parent=root;root:SetAttribute('ThawSurfaceVersion',M.version)
end
return M
