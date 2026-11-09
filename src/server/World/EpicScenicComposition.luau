-- TD's hero / supporting masses / open foreground, adapted to RPG sightlines.
-- Uses pinned script-free TD meshes. Final collision is assigned by CampaignWorld.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Env=require(script.Parent.DeepwoodEnvironment)
local K=require(script.Parent.EpicEnvironmentKit)
local S={version=1}
local V=Vector3.new
local profiles={
 DW={
  {'Trailhead Grove','ForestLandmark',72,-1}, {'Convoy Overlook','CliffRock',44,1},
  {'Elder Sanctuary','ForestLandmark',116,1}, {'Watchtower Ridge','CliffRock',57,-1},
  {'Occupied Keep','CliffRock',64,1}, {'Twisted Rootwood','ForestLandmark',102,-1},
  {'Seal Sanctuary','ForestLandmark',108,1},
 },
 GW={
  {'Lantern Grove','ForestLandmark',79,-1}, {'Silk Watch','ForestLandmark',92,1},
  {'Root Refuge','ForestLandmark',84,-1}, {'Ancient Rootway','ForestLandmark',116,1},
  {'Venomcoil Hollow','CliffRock',65,-1}, {'Widow Ruins','ForestLandmark',107,1},
  {'Web Queen Canopy','ForestLandmark',122,-1},
 },
 FV={
  {'Blizzard Ice Gate','SnowLandmark',88,-1}, {'Sheltered Hearth','SnowLandmark',58,1},
  {'Split Glacier Gorge','SnowLandmark',103,-1}, {'Archive Ice Shelf','SnowLandmark',72,1},
  {'Frozen Procession','SnowLandmark',65,-1}, {'Sentinel Ice Gate','SnowLandmark',98,1},
  {'Mirror Palace Crest','SnowLandmark',114,-1},
 },
 EC={
  {'Ash Spire Gate','VolcanoLandmark',84,1}, {'Foundry Skyline','VolcanoLandmark',69,-1},
  {'Fractured Mine','VolcanoLandmark',77,1}, {'Cooling Rift','VolcanoLandmark',60,-1},
  {'Ancestral Foundry','VolcanoLandmark',91,1}, {'Heatworks Spires','VolcanoLandmark',104,-1},
  {'Great Furnace Crown','VolcanoLandmark',123,1},
 },
 HG={
  {'Lost Chapel','CemeteryLandmark',122,-1}, {'Keepers Chapel','CemeteryLandmark',61,1},
  {'Garden of Names','CemeteryLandmark',70,-1}, {'Fallen Belfry','CemeteryLandmark',83,1},
  {'Royal Gate Chapel','CemeteryLandmark',95,-1}, {'Royal Tomb Spire','CemeteryLandmark',109,1},
  {'Last Throne Ruin','CemeteryLandmark',117,-1},
 },
}
local optional={
 ['DW-S1']={'Supply Camp Grove','ForestLandmark',54,1},
 ['DW-S2']={'Waterfall Quarry','CliffRock',66,-1},
 ['DW-S3']={'Battlefield Ridge','CliffRock',58,1},
 ['FV-S1']={'Supply Cave Crest','SnowLandmark',64,-1},
 ['FV-S2']={'Blue Lake Shelf','SnowLandmark',53,1},
 ['FV-S3']={'Ancient Glacier Watch','SnowLandmark',78,-1},
 ['EC-S1']={'Raider Spires','VolcanoLandmark',57,-1},
 ['EC-S2']={'Shaman Rift','VolcanoLandmark',71,1},
 ['EC-S3']={'Titan Caldera Rim','VolcanoLandmark',91,-1},
}
function S.profile(id)
 return optional[id] or profiles[id:sub(1,2)][assert(tonumber(id:sub(4)))]
end
local function extents(m)
 local cf,size=m:GetBoundingBox();local low,high=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
 for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
  local p=cf:PointToWorldSpace(size*V(x,y,z)/2)
  low=V(math.min(low.X,p.X),math.min(low.Y,p.Y),math.min(low.Z,p.Z));high=V(math.max(high.X,p.X),math.max(high.Y,p.Y),math.max(high.Z,p.Z))
 end end end
 return low,high
end
function S.build(site,id,c,size,pal,theme,safe,ground)
 local profile=S.profile(id);local index=tonumber(id:sub(4))or tonumber(id:sub(5))+7
 site:SetAttribute('Composition',profile[1]);site:SetAttribute('CompositionVersion',S.version)
 local root=Instance.new('Folder');root.Name='TDScenicComposition';root.Parent=site
 local placed={}
 local function put(template,p,height,yaw,role)
  local surface,valid=ground(p)
  if not valid or role=='Hero'and surface.Y<c.Y-45 then return nil end
  p=surface
  -- TD cliff templates are tapered islands. Sink the body to make a bank, never a floating pot.
  local bank=template=='CliffRock'or template:find('Cliff')~=nil
  local base=p-(bank and V(0,height*(role=='Hero'and .68 or .90),0)or V(0,0,0))
  local m=Env.asset(root,template,base,height)
  local cf=m:GetBoundingBox();m:PivotTo(CFrame.new(base+V(0,height/2,0))*CFrame.Angles(0,yaw or 0,0)*cf:ToObjectSpace(m:GetPivot()))
  local low,high=extents(m);local center=(low+high)/2;local radius=V(high.X-low.X,0,high.Z-low.Z).Magnitude/2
  -- Check the whole rotated footprint against story corridors and all neighboring zones.
  if not safe(center,radius+6)then m:Destroy();return nil end
  for other,z in pairs(Content.zones)do if other~=id and low.Y<z.center[2]+20 and high.Y>z.center[2] then
   if low.X<z.center[1]+z.size[1]/2+12 and high.X>z.center[1]-z.size[1]/2-12 and low.Z<z.center[3]+z.size[2]/2+12 and high.Z>z.center[3]-z.size[2]/2-12 then m:Destroy();return nil end
  end end
  for _,p in ipairs(placed)do if V(center.X-p.center.X,0,center.Z-p.center.Z).Magnitude<radius+p.radius+8 then m:Destroy();return nil end end
  m.Name='TD'..role..'_'..template;m:SetAttribute('CompositionRole',role);m:SetAttribute('CompositionSource',template)
  m:SetAttribute('GroundPosition',p)
  for _,part in ipairs(m:GetDescendants())do if part:IsA('BasePart')then
   part:SetAttribute('TLTSceneryDistance',role=='Hero'and 850 or 600)
   local darkTree=theme=='Gloamwood'and (template=='ForestLandmark'or template=='ForestTree')
   if bank and (theme=='EmberCaldera'or theme=='HauntedGraveyard')or darkTree then
    part:SetAttribute('TDOriginalTexture',part.TextureID);part.TextureID=''
    for _,surface in ipairs(part:GetChildren())do if surface:IsA('SurfaceAppearance')then surface:Destroy()end end
    part.Color=darkTree and ((part.Name:find('roots')or part.Name:find('trunk'))and pal.wood or pal.leaf)or pal.rock
    part.Material=darkTree and Enum.Material.Wood or theme=='EmberCaldera'and Enum.Material.Basalt or Enum.Material.Slate
   end
  end end
  table.insert(placed,{model=m,center=center,radius=radius,ground=p});return m
 end
 -- The tall silhouette is offset; neither a wall of equal trees nor four copied corners.
 local side=profile[4];local hero
 for _,candidate in ipairs({V(side*(size[1]/2-28),0,-size[2]*.30),V(-side*(size[1]/2-28),0,-size[2]*.30),V(side*(size[1]/2+58),0,-size[2]*.23),V(-side*(size[1]/2+62),0,-size[2]*.27),V(side*size[1]*.32,0,-size[2]/2-66),V(-side*size[1]*.30,0,-size[2]/2-72)})do
  hero=put(profile[2],c+candidate,profile[3],math.rad(side*18+index*11),'Hero')
  if hero then break end
 end
 -- New wings reserve some former landmark positions. Try the grounded corner
 -- shoulders as well, preserving the same footprint/sightline safety checks.
 if not hero then
  for _,x in ipairs({-1,1})do for _,z in ipairs({-1,1})do
   if not hero then hero=put(profile[2],c+V(x*(size[1]/2+32),0,z*(size[2]/2+24)),profile[3],math.rad(side*18+index*11),'Hero')end
  end end
 end
 local cliff=theme=='FrozenVale'and 'SnowCliff'or theme=='EmberCaldera'and 'VolcanoCliff'or theme=='HauntedGraveyard'and 'CemeteryCliff'or 'CliffRock'
 for i=1,2 do
  local at=c+V(-side*(size[1]/2+18+(i-1)*24),0,size[2]*(.25-(i-1)*.5))
  put(cliff,at,profile[3]*(i==1 and .32 or .48),index*.39+i,'Support')
 end
 -- Silk belongs between real trunks, above the verge, never across the RPG route.
 if theme=='Gloamwood'and hero then
  local cf,h=hero:GetBoundingBox();local p=cf.Position-V(0,h.Y/2,0)
  K.web(root,p+V(-h.X*.24,h.Y*.57,0),p+V(h.X*.23,h.Y*.73,0),p+V(0,h.Y*.20,h.Z*.1),pal)
 end
 -- Low, grouped midground gives scale without filling the combat floor with clutter.
 local treeTemplate=theme=='FrozenVale'and 'SnowTree'or (theme=='Deepwood'or theme=='Gloamwood')and 'ForestTree'
 if treeTemplate then
  for group=1,2 do for i=1,3 do
   local q=c+V(side*(size[1]/2-20+(i%2)*20),0,size[2]*(group==1 and .26 or -.31)+(i-2)*24)
   if safe(q,18)then put(treeTemplate,q,(theme=='FrozenVale'and 23 or 28)+i*4+(index%3)*3,index+i,'Grove')end
  end end
 end
 site:SetAttribute('TDCompositionModels',#placed)
 return root
end
return S
