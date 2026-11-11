-- Blender-authored regional kits and quiet, grounded material breakup.
-- The original TD silhouettes remain the focal points; these supply the middle scale.
local K=require(script.Parent.EpicEnvironmentKit)
local Templates=require(script.Parent.EpicDetailTemplates)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local D={version=1}
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
 m:PivotTo(m:GetPivot())
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
 local function supported(p,r)
  local q,valid=ground(p)
  if not valid or math.abs(q.Y-c.Y)>22 then return nil end
  for _,d in ipairs({V(r,0,0),V(-r,0,0),V(0,0,r),V(0,0,-r)})do
   local s,ok=ground(q+d)
   if not ok or math.abs(s.Y-q.Y)>1.8 then return nil end
  end
  return q
 end
 local placed=0
 -- Unequal groups form a broken verge, rather than a repeated fence of props.
 for side=-1,1,2 do
  for i=1,9 do
   local q=c+V(side*(size[1]*.5-rng:NextNumber(28,76)),0,(i/10-.5)*size[2])
   local large=i==3 or i==7
   local radius=large and 24 or 7
   if clear(q,radius)then
    local p=supported(q,radius)
    if p then
     kit(group,large and heroes[theme]or theme..'Groundcover',p,large and rng:NextNumber(1,1.35)or rng:NextNumber(1.3,2),rng:NextNumber(-math.pi,math.pi))
     placed+=1
    end
   end
  end
 end
 -- Thin ellipsoids add broad patches with irregular overlapping edges. They
 -- never own collision, cover objectives, emit light, or lift a character.
 local mat=theme=='FrozenVale'and Enum.Material.Glacier or theme=='EmberCaldera'and Enum.Material.CrackedLava or theme=='HauntedGraveyard'and Enum.Material.Ground or Enum.Material.Ground
 for i=1,54 do
  local p=c+V(rng:NextNumber(-size[1]*.47,size[1]*.47),0,rng:NextNumber(-size[2]*.46,size[2]*.46))
  local radius=rng:NextNumber(4,11)
  if clear(p,radius)then
   local q=supported(p,radius)
   if q then
    local col=pal.ground:Lerp(pal.rock,theme=='FrozenVale'and .20 or .32)
    local part=K.part(group,'NaturalGroundPatch',V(radius*2,.09,radius*1.3),CFrame.new(q+V(0,.015,0))*CFrame.Angles(0,i*2.4,0),col,mat,'Ball')
    part.CastShadow=false;part:SetAttribute('TLTSceneryDistance',300)
   end
  end
 end
 site:SetAttribute('BiomeDetailVersion',D.version);site:SetAttribute('BiomeDetailClusters',placed)
 return group
end
return D
