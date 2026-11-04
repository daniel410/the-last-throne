-- Composition pass: organic terrain envelopes, enclosed vistas, coherent architecture.
-- Story anchors, combat leash space, and authoritative collision remain independent.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Bounds=require(Shared.CampaignBounds)
local K=require(script.Parent.EpicEnvironmentKit)
local Env=require(script.Parent.DeepwoodEnvironment)
local Architecture=require(script.Parent.EpicArchitecture)
local Art={version=3}
local V=Vector3.new
local C=Color3.fromRGB
local names={DW='Deepwood',FV='FrozenVale',EC='EmberCaldera',GW='Gloamwood',HG='HauntedGraveyard'}
local landmarkNames={DW={'Pilgrim Cloister','Convoy Watch','Elder Sanctuary','Lost Abbey','Occupied Keep','Root Cathedral','Seal Sanctuary'},FV={'Glacier Citadel','Hearth Refuge','Blue Ice Gorge','Relay Aqueduct','Frozen Procession','Sentinel Keep','Mirror Palace'},EC={'Freight Foundry','Workers Quarter','Braced Mine','Cooling Aqueduct','Engineers Archive','Heatworks','Great Furnace'},GW={'Lantern Monastery','Webbed Watch','Root Refuge','Hollowbark Grove','Venomcoil Burrow','Widow Cathedral','Hidden Cemetery Gate'},HG={'Mist Cathedral','Keepers Shelter','Garden of Names','Fallen Belfry','Royal Gate','Crownheart Bastion','Last Throne'}}
local obsolete={Snowbank=true,GlacierSpire=true,PineTrunk=true,SnowPineCrown=true,CalderaRim=true,DistantLavaFissure=true,AncientTrunk=true,Canopy=true,BoundaryPillar=true,Memorial=true,GatePillar=true,GateLintel=true,ForestBoundary=true,OptionalMarsh=true,Waterfall=true,WatchtowerPillar=true,WatchtowerCrown=true}
local function vec(p)return V(table.unpack(p))end
local function model(parent,name)
 local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=parent;return m
end
local function range(root,limit)
 for _,p in ipairs(root:GetDescendants())do if p:IsA('BasePart')then p:SetAttribute('TLTSceneryDistance',limit)end end
end
local function distance(p,a,b)
 local dx,dz=b.X-a.X,b.Z-a.Z
 local t=math.clamp(((p.X-a.X)*dx+(p.Z-a.Z)*dz)/math.max(.001,dx*dx+dz*dz),0,1)
 return math.sqrt((p.X-a.X-t*dx)^2+(p.Z-a.Z-t*dz)^2)
end
local function reservation(world,id)
 local anchors={{p=world.spawns[id].Position,r=32}};local lanes={}
 local center=vec(Content.zones[id].center);local previous=world.spawns[id].Position
 -- Include every chapter using a shared optional area, not just the main ID.
 for _,chapter in ipairs(Content.chapters)do if chapter.zone==id then
  for _,g in ipairs(chapter.goals)do
   local p=vec(g.position);table.insert(anchors,{p=p,r=#g.enemies>0 and 74 or 20});table.insert(lanes,{previous,p});previous=p
   local stepPrevious=p
   for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then
    local at=vec(step.position);table.insert(anchors,{p=at,r=24});table.insert(lanes,{stepPrevious,at});stepPrevious=at
   end end
   table.insert(lanes,{stepPrevious,p})
  end
 end end
 for _,edge in ipairs(Access.edges)do if edge[1]==id or edge[2]==id then table.insert(lanes,{center,vec(Content.zones[edge[1]==id and edge[2] or edge[1]].center)})end end
 local actors=world.folder:FindFirstChild('NPCActors')
 if actors then for _,actor in ipairs(actors:GetChildren())do
  local root=actor:IsA('Model')and actor.PrimaryPart
  if root and math.abs(root.Position.Y-center.Y)<24 and math.abs(root.Position.X-center.X)<Content.zones[id].size[1]/2+20 and math.abs(root.Position.Z-center.Z)<Content.zones[id].size[2]/2+20 then
   table.insert(anchors,{p=root.Position,r=24})
  end
 end end
 return function(p,r)
  for _,a in ipairs(anchors)do if distance(p,a.p,a.p)<a.r+r then return false end end
  for _,line in ipairs(lanes)do if distance(p,line[1],line[2])<24+r then return false end end
  return true
 end
end
local function groundMaterial(theme)
 return theme=='FrozenVale' and Enum.Material.Snow or theme=='EmberCaldera' and Enum.Material.Basalt or theme=='HauntedGraveyard' and Enum.Material.Rock or Enum.Material.Grass
end
local function paletteKit(m,pal,theme)
 for _,p in ipairs(m:GetDescendants())do if p:IsA('MeshPart')then
  if p.Name:find('Meadow')or p.Name:find('Moss')then p.Material=groundMaterial(theme);p.Color=pal.ground
  elseif p.Name:find('Sandstone')then p.Color=pal.rock;p.Material=theme=='FrozenVale'and Enum.Material.Glacier or Enum.Material.Slate
  elseif theme=='Gloamwood'then p.Color=p.Color:Lerp(pal.leaf,.6)end
 end end
end
local function terrainSite(parent,c,size,pal,theme,safe)
 local m=model(parent,'OrganicTerrain');local terrain=workspace.Terrain;local mat=groundMaterial(theme)
 -- Raised shoulders occupy unused exploration space; encounter leashes and
 -- objective corridors remain flat. This replaces the old all-flat tile rule.
 local shoulders=0
 for x=-2,2 do for z=-2,2 do
  local p=c+V(x*size[1]/5,0,z*size[2]/5)
  if safe(p,48)then terrain:FillBall(p-V(0,32,0),48,mat);shoulders+=1 end
 end end
 m:SetAttribute('RaisedShoulders',shoulders)
 -- Ground now meets the clearing, replacing the exposed rectangular slab sides.
 terrain:FillBlock(CFrame.new(c-V(0,32,0)),V(size[1]+160,64,size[2]+160),mat)
 for _,s in ipairs({-1,1})do for i=0,5 do
  local p=c+V(s*(size[1]/2+74),-35,-size[2]/2+i*size[2]/5)
  terrain:FillBall(p,74,mat)
 end end
 local cliff=Env.kit(m,'DeepCliff',c,100)
 Env.fit(cliff,c-V(0,37,0),V(size[1]+112,74,size[2]+104));paletteKit(cliff,pal,theme)
 -- Merged TD geometry supplies irregular ledges and soil contours, not flat wedges.
 local top=Env.kit(m,'ContinuousTerrain',c,100)
 Env.fit(top,c-V(0,1.6,0),V(size[1]+(theme=='EmberCaldera'and 88 or 148),3.2,size[2]+138));paletteKit(top,pal,theme)
 for _,s in ipairs({-1,1})do for i=0,3 do
  local p=c+V(s*(size[1]/2+125+(i%2)*42),-5,-size[2]/2+i*size[2]/3)
  local h=80+(i%3)*28
  K.rock(m,p+V(0,h*.2,0),V(90,h,95),pal.rock,i+s)
  terrain:FillBall(p-V(0,60,0),80,mat)
  if theme=='FrozenVale'then K.rock(m,p+V(8,h*.4,0),V(70,h*.65,80),pal.ground,i+s)end
 end end
 for _,s in ipairs({-1,1})do for i=1,3 do
  local p=c+V(s*(size[1]/2+310),20,-size[2]/2+(i-.5)*size[2]/3)
  if not Bounds.region(p.X,p.Z,170)then
   local h=190+i%2*65;K.rock(m,p+V(0,h*.15,0),V(220,h,230),theme=='FrozenVale'and pal.ground or pal.rock,i+s)
  end
 end end
 range(m,900)
end
local terrainRay=RaycastParams.new();terrainRay.FilterType=Enum.RaycastFilterType.Include;terrainRay.FilterDescendantsInstances={workspace.Terrain}
local function ground(p)
 local hit=workspace:Raycast(p+V(0,180,0),V(0,-360,0),terrainRay)
 return hit and hit.Position.Y>p.Y-3 and hit.Position.Y<p.Y+70 and V(p.X,hit.Position.Y,p.Z)or p
end
local function tree(parent,p,h,pal,theme,hero)
 p=ground(p)
 if theme=='HauntedGraveyard'then K.tree(parent,p,h,pal,true);return end
 if theme=='FrozenVale'then K.pine(parent,p,h,pal,true);return end
local copy=Env.asset(parent,hero and 'ForestLandmark'or 'ForestTree',p,h)
 if hero then for i=1,3 do
  local angle=i*2.1;Env.crown(parent,p+V(math.cos(angle)*h*.19,h*(.62+i*.025),math.sin(angle)*h*.19),h*.60,pal.leaf)
 end end
 for _,piece in ipairs(copy:GetDescendants())do if piece:IsA('MeshPart')then
  if piece.Name:find('foliage')or piece.Name:find('canopy')or piece.Name:find('leav')or piece.Name:find('crown')then
   if theme=='Gloamwood'then piece:SetAttribute('TDOriginalTexture',piece.TextureID);piece.TextureID='';piece.Material=Enum.Material.Grass;piece.Color=pal.leaf
   else piece.Color=C(124,162,98)end
  end
 end end
end
local function vegetation(parent,c,size,pal,theme,safe,rng)
 local m=model(parent,'LayeredVegetation')
 -- Three staggered depth bands form a forest/canyon wall, rather than a ring of ornaments.
 local count=theme=='FrozenVale' and 12 or theme=='HauntedGraveyard' and 8 or theme=='EmberCaldera' and 10 or 24
 for _,side in ipairs({-1,1})do
  for band=0,2 do
   for i=1,count do
    local p=c+V(side*(size[1]/2-38+band*31+rng:NextNumber(-12,12)),0,-size[2]/2+(i-.5)*size[2]/count+rng:NextNumber(-12,12))
    if safe(p,12)then
     local h=theme=='Gloamwood' and rng:NextNumber(62,96)or rng:NextNumber(39,65)
     if theme=='EmberCaldera'then K.rock(m,p+V(0,8,0),V(14,h,18),pal.rock,i+band)
     else tree(m,p,h,pal,theme,false)end
    end
   end
   task.wait()
  end
 end
 -- Low, merged flower/fern/moss patches from the original TD Blender kit.
 if theme=='Deepwood'or theme=='Gloamwood'then
  local patches=model(parent,'Understory')
  for i=1,20 do
   local p=c+V(rng:NextNumber(-size[1]*.45,size[1]*.45),.05,rng:NextNumber(-size[2]*.45,size[2]*.45))
   if safe(p,13)then
    local patch=Env.kit(patches,'BankVegetation',p,58+rng:NextNumber(0,20))
    if theme=='Gloamwood'then paletteKit(patch,pal,theme)end
   end
  end
  range(patches,170)
 end
 if theme=='Gloamwood'then
  for _,side in ipairs({-1,1})do for i=1,2 do
   local q=c+V(side*(size[1]/2-35),0,100-i*100)
   if safe(q,18)then
    q=ground(q);tree(m,q,76,pal,theme,false)
    K.web(m,q+V(0,58,0),q+V(side*34,37,14),q+V(side*19,8,-13),pal)
   end
  end end
 end
 range(m,650)
end
local function route(parent,a,b,width,pal,theme)
 local d=b-a;if d.Magnitude<.1 then return end
 local forward=V(d.X,0,d.Z).Unit;local normal=V(-forward.Z,0,forward.X);local prev=a
 local n=math.max(2,math.ceil(d.Magnitude/16))
 for i=1,n do
  local t=i/n;local q=a:Lerp(b,t)+normal*math.sin(t*math.pi)*math.sin(i*.32)*6
  local p=K.part(parent,'WornCurvedRoute',V(width,.06,(q-prev).Magnitude+1),CFrame.lookAt((prev+q)/2+V(0,.04,0),q+V(0,.04,0)),pal.ground:Lerp(pal.trim,theme=='Deepwood'and .60 or (theme=='Gloamwood'or theme=='HauntedGraveyard')and .65 or .38),theme=='Deepwood'and Enum.Material.Sandstone or theme=='FrozenVale'and Enum.Material.Glacier or Enum.Material.Cobblestone)
  p.CastShadow=false;prev=q
 end
end
local function floorDetails(parent,c,size,pal,theme,safe,rng,chapter)
 local m=model(parent,'GroundAndPaths')
 local north=c+V(0,0,-size[2]/2+12);local middle=c+V(22,0,0);local south=c+V(-20,0,size[2]/2-16)
 route(m,south,middle,24,pal,theme);route(m,middle,north,24,pal,theme)
 if chapter then for _,g in ipairs(chapter.goals)do
  local p=vec(g.position);local onRoad=c+V(p.Z>c.Z and -10 or 14,0,p.Z-c.Z)
  route(m,onRoad,p,10,pal,theme)
  if #g.enemies>0 and theme~='Deepwood'and theme~='Gloamwood'then
   -- Worn court stonework has no emission or gameplay markings.
   for x=-2,2 do for z=-2,2 do
    local cf=CFrame.new(p+V(x*13,.025,z*12))*CFrame.Angles(0,math.sin(x*2+z)*.035,0)
    local col=pal.ground:Lerp(pal.trim,.12+((x+z)%3)*.025)
    local tile=K.part(m,'CourtFlagstone',V(12.6,.04,11.6),cf,col,theme=='FrozenVale'and Enum.Material.Glacier or Enum.Material.Cobblestone);tile.CastShadow=false
   end end
  end
 end end
 -- Scale-aware paving around interaction positions; quiet center for attack warnings.
 for i=1,38 do
  local p=c+V(rng:NextNumber(-size[1]*.45,size[1]*.45),.08,rng:NextNumber(-size[2]*.45,size[2]*.45))
  if safe(p,6)then
   if theme=='HauntedGraveyard'then Architecture.grave(m,p,pal,i%4==0 and 1 or 2)
   elseif theme=='EmberCaldera'then
    K.part(m,'BasaltRubble',V(7,2,5),CFrame.new(p)*CFrame.Angles(.1,i,.1),pal.rock,Enum.Material.Basalt,'Wedge')
   else K.part(m,'WeatheredStone',V(5,1.2,4),CFrame.new(p)*CFrame.Angles(0,i,.04),pal.trim,Enum.Material.Slate,'Wedge')end
  end
 end
 if theme=='HauntedGraveyard'then
  for _,s in ipairs({-1,1})do for i=1,9 do
   local p=c+V(s*(size[1]/2-42),0,-size[2]/2+30+i*size[2]/11)
   if safe(p,9)then Architecture.grave(m,p,pal,i%3==0 and 1 or 2)end
  end end
 end
 range(m,450)
end
local function vista(parent,c,size,pal,theme,index)
 local m=model(parent,'AuthoredVista')
 if index==1 or index==7 then Architecture.entry(m,c,size,pal)end
 if theme=='EmberCaldera'then
  if index==2 then Architecture.camp(m,c,size,pal,false)
  elseif index==3 then Architecture.mine(m,c,size,pal)
  elseif index==4 then Architecture.aqueduct(m,c,size,pal,theme)
  else Architecture.foundry(m,c,size,pal,index)end
 elseif theme=='FrozenVale'then
  if index==2 then Architecture.camp(m,c,size,pal,true)
  elseif index==3 or index==4 then Architecture.aqueduct(m,c,size,pal,theme)
  else Architecture.citadel(m,c,size,pal,theme,index)end
 elseif theme=='HauntedGraveyard'then
  if index==2 then Architecture.camp(m,c,size,pal,false)
  elseif index==4 then Architecture.belfry(m,c,size,pal)
  else Architecture.citadel(m,c,size,pal,theme,index)end
  for _,side in ipairs({-1,1})do for i=1,2 do
   local q=c+V(side*(size[1]/2-25),0,95-i*95)
   -- Raised burial terraces belong outside encounter leashes; retained ground has a deep plinth.
   Architecture.mausoleum(m,q,pal)
  end end
 elseif theme=='Gloamwood'then
  if index==3 then Architecture.camp(m,c,size,pal,false)
  elseif index==5 then Architecture.mine(m,c,size,pal)
  else Architecture.ruin(m,c,size,pal,index)end
 else
  if index==3 then Architecture.camp(m,c,size,pal,false)
  elseif index==5 then Architecture.citadel(m,c,size,pal,theme,index)
  else Architecture.cloister(m,c,size,pal,index)end
  local hero=c+V(size[1]/2+15,0,-size[2]/2+45)
  tree(m,hero,(index==3 or index==6)and 125 or 98,pal,theme,true)
 end
 -- Real original TD waterfall meshes, no transparent rectangular water panel.
 if theme=='Deepwood'then
  local gorge=Env.kit(m,'WaterfallGorge',c,100)
  Env.fit(gorge,c+V(-size[1]/2-46,-25,-42),V(105,65,155));paletteKit(gorge,pal,theme)
 elseif theme=='EmberCaldera'then
  for _,s in ipairs({-1,1})do
   local lava=K.part(m,'LavaBelowCliff',V(26,.6,size[2]+40),c+V(s*(size[1]/2+68),-12,0),pal.accent,Enum.Material.Neon);lava.CastShadow=false
   for i=1,3 do
    local q=c+V(s*(size[1]/2+67),-43,-size[2]/2+i*size[2]/4)
    K.part(m,'LavaFall',V(5,62,3),q,pal.accent,Enum.Material.Neon)
   end
  end
 end
 for _,s in ipairs({-1,1})do Architecture.flame(m,c+V(s*108,0,124),pal,true)end
 range(m,900)
end
local function pass(parent,edge,index)
 local aa,bb=Bounds.ends(edge);local a,b=vec(aa),vec(bb);local d=b-a
 if d.Magnitude<2 then return end
 local theme=names[edge[2]:sub(1,2)];local pal=K.palette[theme];local normal=V(-d.Z,0,d.X).Unit
 local m=model(parent,'ScenicPass_'..edge[1]..'_'..edge[2]);local count=math.ceil(d.Magnitude/58)
 for i=0,count do
  local t=i/count;local p=a:Lerp(b,t)
  for _,s in ipairs({-1,1})do
   local q=p+normal*s*(74+i%3*9)
   if not Bounds.region(q.X,q.Z,16)then
    if theme~='EmberCaldera'then tree(m,q,theme=='Gloamwood'and 67 or 43,pal,theme,false)
    else K.rock(m,q+V(0,8,0),V(22,47,25),pal.rock,i)end
    if i%3==0 then K.lantern(m,p+normal*s*34,pal)end
   end
  end
  if i%7==0 then task.wait()end
 end
 -- A continuous curving trail remains entirely within the 96-stud safe connector.
 route(m,a,b,23,pal,theme);range(m,700)
end
local function carve(world,Content,Access)
 local terrain=workspace.Terrain
 local original=RaycastParams.new();original.FilterType=Enum.RaycastFilterType.Include;original.RespectCanCollide=true
 original.FilterDescendantsInstances={world.terrain,world.folder:FindFirstChild('GroundedForest')or world.terrain}
 local function clear(p,r)
  -- Return-to-another-zone objectives can span different heights. Follow actual
  -- server-owned floor instead of carving an interpolated line above a lower path.
  local hit=workspace:Raycast(p+V(0,8,0),V(0,-180,0),original)
  local authority=Bounds.surface(p.X,p.Z)
  local y=math.min(p.Y,authority or p.Y,hit and hit.Position.Y or p.Y)
  p=V(p.X,y,p.Z)
  -- Two voxel-edge widths keep interpolated terrain from lifting a planted foot.
  terrain:FillCylinder(CFrame.new(p+V(0,192,0)),400,r+6,Enum.Material.Air)
 end
 for id in pairs(Content.zones)do clear(world.spawns[id].Position-V(0,.1,0),40)end
 for _,chapter in ipairs(Content.chapters)do
  local prev=world.spawns[chapter.zone].Position
  for _,g in ipairs(chapter.goals)do
   local p=vec(g.position);clear(p,#g.enemies>0 and 80 or 24)
   local d=p-prev;local n=math.max(1,math.ceil(d.Magnitude/25))
   for i=0,n do clear(prev:Lerp(p,i/n),25)end
   local stepPrevious=p
   for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then
    local at=vec(step.position);local count=math.max(1,math.ceil((at-stepPrevious).Magnitude/20))
    for i=0,count do clear(stepPrevious:Lerp(at,i/count),27)end
    stepPrevious=at
   end end
   local count=math.max(1,math.ceil((p-stepPrevious).Magnitude/20))
   for i=0,count do clear(stepPrevious:Lerp(p,i/count),27)end
   prev=p
  end
  task.wait()
 end
 -- Existing optional terraces/ramps are part of the playable world too.
 local places=world.terrain:FindFirstChild('DeepwoodPlaces')
 if places then for _,part in ipairs(places:GetDescendants())do
  if part:IsA('BasePart')and part.CanCollide and (part.Name=='WalkableTerrace'or part.Name=='WalkableRamp'or part.Name=='TerraceLanding')then
   local low,high=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
   for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
    local p=part.CFrame:PointToWorldSpace(part.Size*V(x,y,z)/2)
    low=V(math.min(low.X,p.X),math.min(low.Y,p.Y),math.min(low.Z,p.Z));high=V(math.max(high.X,p.X),math.max(high.Y,p.Y),math.max(high.Z,p.Z))
   end end end
   local nx,nz=math.max(1,math.ceil((high.X-low.X)/18)),math.max(1,math.ceil((high.Z-low.Z)/18))
   for ix=0,nx do for iz=0,nz do clear(V(low.X+(high.X-low.X)*ix/nx,low.Y,low.Z+(high.Z-low.Z)*iz/nz),17)end end
  end
 end end
 local actors=world.folder:FindFirstChild('NPCActors')
 if actors then for _,actor in ipairs(actors:GetChildren())do
  local root=actor:IsA('Model')and actor.PrimaryPart
  if root then local y=Bounds.surface(root.Position.X,root.Position.Z);if y then clear(V(root.Position.X,y,root.Position.Z),26)end end
 end end
 for _,edge in ipairs(Access.edges)do
  local aa,bb=Bounds.ends(edge);local a,b=vec(aa),vec(bb);local flat=V(b.X-a.X,0,b.Z-a.Z);local n=math.max(1,math.ceil(flat.Magnitude/30))
  if flat.Magnitude>1 then
   clear(a,52);clear(b,52)
   for i=0,n do
   local p=a:Lerp(b,i/n)
   terrain:FillBlock(CFrame.lookAt(p+V(0,192,0),p+V(0,192,0)+flat),V(100,400,flat.Magnitude/n+16),Enum.Material.Air)
   if i%12==0 then task.wait()end
  end end
 end
end
local function connectGround(edge)
 local aa,bb=Bounds.ends(edge);local a,b=vec(aa),vec(bb);local d=b-a
 if d.Magnitude<2 then return end
 local theme=names[edge[2]:sub(1,2)];local n=math.ceil(d.Magnitude/58)
 for i=0,n do
  local p=a:Lerp(b,i/n)
  workspace.Terrain:FillBlock(CFrame.lookAt(p-V(0,25,0),p-V(0,25,0)+d),V(158,50,d.Magnitude/n+25),groundMaterial(theme))
  if i%10==0 then task.wait()end
 end
end
local function cutScenicWater(plans)
 -- Channels are beyond the playable floor: lava cannot read as the route.
 for _,p in ipairs(plans)do
  local c,size=p.c,p.z.size
  if p.theme=='EmberCaldera'then
   for _,side in ipairs({-1,1})do for i=0,math.ceil(size[2]/48)do
    local q=c+V(side*(size[1]/2+69),120,-size[2]/2+i*48)
    if not Bounds.region(q.X,q.Z,20)and not Bounds.connection(q.X,q.Z,10)then
     workspace.Terrain:FillBlock(CFrame.new(q),V(34,400,53),Enum.Material.Air)
    end
   end end
  elseif p.theme=='Deepwood'then
   local q=c+V(-size[1]/2-54,132,-42)
   workspace.Terrain:FillBlock(CFrame.new(q),V(106,400,162),Enum.Material.Air)
  end
  task.wait()
 end
end
function Art.create(world,scope)
 local Content=scope and scope.content or Content
 local Access=scope and scope.access or Access
 local artName=scope and ("EpicWorldArt_"..scope.epic) or "EpicWorldArt"
 local parent=world.folder
 if scope then
  parent=world.folder:FindFirstChild('EpicWorldArt')or Instance.new('Folder')
  parent.Name='EpicWorldArt';parent:SetAttribute('ArtVersion',Art.version);parent.Parent=world.folder
 end
 local previous=parent:FindFirstChild(artName)
 if previous and previous:GetAttribute('ArtVersion')==Art.version and previous:GetAttribute('BuildComplete')then return world end
 if previous then previous:Destroy()end
 local root=Instance.new('Folder');root.Name=artName;root:SetAttribute('ArtVersion',Art.version);root.Parent=parent
 local ids={};for id in pairs(Content.zones)do table.insert(ids,id)end;table.sort(ids)
 local plans={}
 -- Finish every overlapping height field before grounding a single tree/building.
 for order,id in ipairs(ids)do
  local z=Content.zones[id];local c=vec(z.center);local theme=names[id:sub(1,2)];local pal=K.palette[theme];local index=tonumber(id:sub(4))or 2
  local site=Instance.new('Folder');site.Name=id;site:SetAttribute('Theme',theme);site:SetAttribute('Landmark',landmarkNames[id:sub(1,2)][index]);site.Parent=root
  local rng=Random.new(22000+order*139);local safe=reservation(world,id)
  terrainSite(site,c,z.size,pal,theme,safe)
  table.insert(plans,{id=id,z=z,c=c,theme=theme,pal=pal,index=index,site=site,rng=rng,safe=safe})
  task.wait()
 end
 for _,edge in ipairs(Access.edges)do connectGround(edge);task.wait()end
 cutScenicWater(plans)
 carve(world,Content,Access)
 for _,p in ipairs(plans)do
  vegetation(p.site,p.c,p.z.size,p.pal,p.theme,p.safe,p.rng)
  floorDetails(p.site,p.c,p.z.size,p.pal,p.theme,p.safe,p.rng,Content.byId[p.id])
  vista(p.site,p.c,p.z.size,p.pal,p.theme,p.index)
  task.wait()
 end
 for i,edge in ipairs(Access.edges)do pass(root,edge,i);task.wait()end
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and not p:IsDescendantOf(root)then
  if obsolete[p.Name]then p.Transparency=1;p.CastShadow=false end
 end end
 for _,id in ipairs(ids)do
  local region=world.terrain:FindFirstChild(id);local pal=K.palette[names[id:sub(1,2)]]
  if region then for _,p in ipairs(region:GetDescendants())do
   if p:IsA('MeshPart')and p.Name=='foliage_geom'and id:sub(1,2)=='DW'then p.Color=C(124,162,98)end
   if p:IsA('BasePart')and (p.Name=='ForestGround'or p.Name=='SnowGround'or p.Name=='Ground'or p.Name=='BasaltGround')then p.Color=pal.ground;p.Material=groundMaterial(names[id:sub(1,2)])end
  end end
 end
 root:SetAttribute('BuildComplete',true);world.folder:SetAttribute('EpicWorldArtVersion',Art.version);return world
end
return Art
