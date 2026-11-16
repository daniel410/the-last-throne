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
 -- One continuous rock material avoids checkerboard texture seams at walking height.
 do
  for i=1,24 do
   local t=(i-.5)/24
   local melt=math.clamp((t-.08)/.84,0,1)
   local blend=melt*melt*(3-2*melt)
   local p=Instance.new('Part');p.Name='ThawRoadSurface'
   p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
   p.Size=V(96,.06,length/24)
   p.CFrame=CFrame.lookAt(a:Lerp(b,t),b)*CFrame.new(0,.04,0)
   p.Color=snow:Lerp(basalt,blend)
   p.Material=Enum.Material.Rock
   p:SetAttribute('ThawFraction',melt);p.Parent=surface
  end
 end
 surface.Parent=root;root:SetAttribute('ThawSurfaceVersion',M.version)
end
return M
