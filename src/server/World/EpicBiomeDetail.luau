-- Blender-authored regional kits and quiet, grounded material breakup.
-- The original TD silhouettes remain the focal points; these supply the middle scale.
local K=require(script.Parent.EpicEnvironmentKit)
local Env=require(script.Parent.DeepwoodEnvironment)
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local Templates=require(script.Parent.EpicDetailTemplates)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local D={version=3}
local V=Vector3.new
local heroes={Deepwood='DeepwoodRelic',Gloamwood='GloamwoodRoots',FrozenVale='FrozenValeShards',EmberCaldera='EmberCalderaColumns',HauntedGraveyard='HauntedMemorial'}
local function kit(parent,key,position,scale,yaw)
 local m=Instance.new('Model');m.Name=key;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('BlenderEnvironmentSource',key)
 local origin=CFrame.new(position)*CFrame.Angles(0,yaw,0)
 for _,r in ipairs(Templates[key])do
  local size=V(table.unpack(r[5]))*scale
  local cf=origin*CFrame.new(V(table.unpack(r[4]))*scale)*CFrame.Angles(0,r[7],r[8])
  local shape=r[2]
  -- Roblox cylinders point along X; Blender source cylinders point up.
  if shape=='Cylinder'then size=V(size.Y,size.X,size.Z);cf*=CFrame.Angles(0,0,math.pi/2)end
  local p=K.part(m,r[1],size,cf,Color3.fromRGB(table.unpack(r[6])),Enum.Material[r[3]],shape)
  if shape=='Cylinder'then p.Shape=Enum.PartType.Cylinder end
  local soft=r[1]:find('Fern')or r[1]:find('Silk')or r[1]:find('Mushroom')or r[3]=='Neon'
  p:SetAttribute('EpicDetailSolid',not soft and size.Magnitude>4 and math.max(size.X,size.Y,size.Z)>2)
  p:SetAttribute('TLTSceneryDistance',key:find('Groundcover')and 230 or 650)
 end
 m.Parent=parent
 return m
end
function D.build(site,id,c,size,pal,theme,safe,ground)
 local group=Instance.new('Folder');group.Name='BiomeDetails';group.Parent=site
 local seed=0;for i=1,#id do seed=seed*31+id:byte(i)end
 local rng=Random.new(seed)
 local function clear(p,r)
  if not safe(p,r)then return false end
  for _,z in pairs(Content.zones)do
   for _,a in ipairs(z.expansionAreas or {})do
    if Areas.contains(a,p.X,p.Z,r+8)or Areas.contains(a.connector,p.X,p.Z,r+8)then return false end
   end
  end
  return true
 end
 local function supported(p,r,large)
  local q,valid=ground(p)
  if not valid or math.abs(q.Y-c.Y)>22 then return nil end
  local low=q.Y
  for _,d in ipairs({V(r,0,0),V(-r,0,0),V(0,0,r),V(0,0,-r)})do
   local s,ok=ground(q+d)
   if not ok or math.abs(s.Y-q.Y)>(large and 8 or 1.8) then return nil end
   low=math.min(low,s.Y)
  end
  return large and V(q.X,low,q.Z)or q
 end
 local placed,largeCount=0,0
 -- Unequal groups form a broken verge, rather than a repeated fence of props.
 for side=-1,1,2 do
  for i=1,13 do
   local q=c+V(side*(size[1]*.5-rng:NextNumber(28,76)),0,(i/14-.5)*size[2])
   local large=largeCount<2 and i%2==1
   local radius=large and 24 or 7
   if clear(q,radius)then
    local p=supported(q,radius,large)
    if p then
     kit(group,large and heroes[theme]or theme..'Groundcover',p,large and rng:NextNumber(1,1.35)or rng:NextNumber(1.3,2),rng:NextNumber(-math.pi,math.pi))
     placed+=1
     if large then largeCount+=1 end
    end
   end
  end
 end
 -- Thin ellipsoids add broad patches with irregular overlapping edges. They
 -- never own collision, cover objectives, emit light, or lift a character.
 local mat=theme=='FrozenVale'and Enum.Material.Glacier or theme=='EmberCaldera'and Enum.Material.Basalt or theme=='HauntedGraveyard'and Enum.Material.Ground or Enum.Material.Ground
 for i=1,110 do
  local p=c+V(rng:NextNumber(-size[1]*.47,size[1]*.47),0,rng:NextNumber(-size[2]*.46,size[2]*.46))
  local radius=rng:NextNumber(7,17)
  do
   local q=supported(p,radius)
   if q then
    local col=pal.ground:Lerp(pal.rock,theme=='FrozenVale'and .20 or .32)
    local part=K.part(group,'NaturalGroundPatch',V(radius*2,.09,radius*1.3),CFrame.new(q+V(0,.015,0))*CFrame.Angles(0,i*2.4,0),col,mat,'Ball')
    part.CastShadow=false;part:SetAttribute('TLTSceneryDistance',300)
   end
  end
 end
 -- Oversized pinned TD forms close the skyline beyond every playable area.
 -- Check their full footprint before adding the terrain pedestal; never fill
 -- a neighboring encounter, incident wing, or connecting road with backdrop.
 local source=theme=='FrozenVale'and 'SnowLandmark'or theme=='EmberCaldera'and 'VolcanoLandmark'or theme=='HauntedGraveyard'and 'CemeteryLandmark'or 'ForestLandmark'
 local backdrops=0
 for side=-1,1,2 do
  local at=c+V(side*(size[1]/2+470),-30,-size[2]*.28)
  local height=theme=='Gloamwood'and 205 or theme=='Deepwood'and 180 or 220
  local m=Env.asset(group,source,at,height)
  local cf,ext=m:GetBoundingBox();local radius=V(ext.X,0,ext.Z).Magnitude/2+24
  local occupied=Bounds.region(at.X,at.Z,radius)or Bounds.connection(at.X,at.Z,radius)
  if not occupied then
   for _,z in pairs(Content.zones)do for _,a in ipairs(z.expansionAreas or {})do
    if Areas.contains(a,at.X,at.Z,radius+24)or Areas.contains(a.connector,at.X,at.Z,radius+24)then occupied=true end
   end end
  end
  if occupied or radius>190 then m:Destroy()
  else
   m.Name='RegionalBackdrop';m:SetAttribute('BlenderEnvironmentSource','TDBackdrop_'..source)
   m:SetAttribute('RegionalBackdrop',true)
   for _,part in ipairs(m:GetDescendants())do if part:IsA('BasePart')then
    part:SetAttribute('TLTSceneryDistance',900)
    if theme=='Gloamwood'then
     part.TextureID='';for _,appearance in ipairs(part:GetChildren())do if appearance:IsA('SurfaceAppearance')then appearance:Destroy()end end
     part.Color=part.Name:find('trunk')and pal.wood or pal.leaf
    end
   end end
   local mat=theme=='FrozenVale'and Enum.Material.Snow or theme=='EmberCaldera'and Enum.Material.Basalt or theme=='HauntedGraveyard'and Enum.Material.Rock or Enum.Material.Grass
   workspace.Terrain:FillBall(at-V(0,radius*.7,0),radius,mat)
   backdrops+=1
  end
 end
 site:SetAttribute('RegionalBackdrops',backdrops)
 site:SetAttribute('BiomeHeroDetails',largeCount);site:SetAttribute('BiomeDetailVersion',D.version);site:SetAttribute('BiomeDetailClusters',placed)
 return group
end
return D
