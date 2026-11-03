-- Authored environment pass over the existing server-owned campaign footprint.
-- Scenery never extends story access, collision, interaction or reward authority.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Bounds=require(Shared.CampaignBounds)
local Kit=require(script.Parent.EpicEnvironmentKit)
local Env=require(script.Parent.DeepwoodEnvironment)
local Art={version=1}
local V=Vector3.new
local C=Color3.fromRGB
local function vec(p)return V(table.unpack(p))end
local themes={DW='Deepwood',FV='FrozenVale',EC='EmberCaldera',GW='Gloamwood',HG='HauntedGraveyard'}
local landmarks={
 DW={'Pilgrim Watch','Convoy Ruins','Ranger Sanctuary','Lost Cloister','Occupied Watchtower','Elder Roots','Broken Seal'},
 FV={'Glacier Gate','Hearth Refuge','Blue Ice Gorge','Relay Watch','Frozen Procession','Sentinel Citadel','Mirror Palace'},
 EC={'Freight Foundry','Workers Quarter','Braced Mine','Cooling Aqueduct','Engineers Archive','Heatworks','Great Furnace'},
 GW={'Lantern Ruins','Webbed Watch','Root Refuge','Hollowbark Grove','Venomcoil Burrow','Widow Nest','Hidden Cemetery Gate'},
 HG={'Mist Chapel','Keepers Shelter','Garden of Names','Fallen Belfry','Royal Gate','Crownheart Bastion','Last Throne'},
}
local obsolete={Snowbank=true,GlacierSpire=true,PineTrunk=true,SnowPineCrown=true,CalderaRim=true,DistantLavaFissure=true,AncientTrunk=true,Canopy=true,BoundaryPillar=true,Memorial=true,GatePillar=true,GateLintel=true}
local function backdrop(p)
 p:SetAttribute('TLTSceneryDistance',900)
 if p:IsA('Model')then for _,v in ipairs(p:GetDescendants())do if v:IsA('BasePart')then v:SetAttribute('TLTSceneryDistance',900)end end end
 return p
end
local function model(parent,name)
 local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=parent;return m
end
local function flatDistance(a,b)return (V(a.X,0,a.Z)-V(b.X,0,b.Z)).Magnitude end
local function segmentDistance(p,a,b)
 p,a,b=V(p.X,0,p.Z),V(a.X,0,a.Z),V(b.X,0,b.Z)
 local d=b-a;local t=math.clamp((p-a):Dot(d)/math.max(.001,d:Dot(d)),0,1);return (p-a-d*t).Magnitude
end
local function reserves(world,id)
 local anchors,lanes={world.spawns[id].Position},{}
 local chapter=Content.byId[id]
 local center=vec(Content.zones[id].center)
 if chapter then
  local previous=world.spawns[id].Position
  for _,g in ipairs(chapter.goals)do
   local p=vec(g.position);table.insert(anchors,{p=p,r=#g.enemies>0 and 74 or 20});table.insert(lanes,{previous,p});previous=p
   for _,s in ipairs(g.activity and g.activity.steps or {})do if s.position then table.insert(anchors,{p=vec(s.position),r=22})end end
  end
 end
 -- Reserve broad arrival/departure corridors, including side quests.
 for _,edge in ipairs(Access.edges)do if edge[1]==id or edge[2]==id then
  local other=vec(Content.zones[edge[1]==id and edge[2] or edge[1]].center);table.insert(lanes,{center,other})
 end end
 return function(p,r)
  if flatDistance(p,world.spawns[id].Position)<r+32 then return false end
  for _,a in ipairs(anchors)do if type(a)=='table' and flatDistance(p,a.p)<r+a.r then return false end end
  for _,lane in ipairs(lanes)do if segmentDistance(p,lane[1],lane[2])<r+24 then return false end end
  return true
 end
end
local function pine(parent,p,h,pal)Kit.pine(parent,p,h,pal,true)end
local function forestTree(parent,p,h,pal,theme)
 if theme=='Deepwood' then
  local tree=Env.tree(parent,p,h,false);tree:PivotTo(tree:GetPivot()*CFrame.Angles(0,(p.X+p.Z)%.9,0))
 elseif theme=='Gloamwood' then
  local tree=Env.asset(parent,'ForestTree',p,h)
  for _,part in ipairs(tree:GetDescendants())do if part:IsA('MeshPart')then part.Color=C(105,140,125);if part.Name=='foliage_geom'then part:SetAttribute('TDOriginalTexture',part.TextureID);part.TextureID='';part.Material=Enum.Material.Grass;part.Color=pal.leaf end end end
 else Kit.tree(parent,p,h,pal,true)end
end
local function sculptGround(c,size,pal,theme)
 local terrain=workspace.Terrain
 local mat=theme=='FrozenVale' and Enum.Material.Snow or theme=='EmberCaldera' and Enum.Material.Basalt or theme=='HauntedGraveyard' and Enum.Material.Rock or Enum.Material.Grass
 -- Thin valley floor plus overlapping natural skirts. These sit below or outside
 -- the authoritative floor; access/safe-return bounds remain the existing ones.
 terrain:FillBlock(CFrame.new(c-V(0,72,0)),V(size[1]+440,12,size[2]+440),mat)
 for _,side in ipairs({-1,1})do
  for i=0,6 do
   local p=c+V(side*(size[1]/2+38),-44,-size[2]/2+i*size[2]/6)
   if not Bounds.connection(p.X,p.Z,64)then terrain:FillBall(p,57,mat)end
   if i%2==0 then terrain:FillBall(c+V(side*(size[1]/2+230),-100,-size[2]/2+i*size[2]/6),100,mat)end
  end
 end
end
local function geology(parent,c,size,pal,rng,theme)
 local m=model(parent,'LayeredValley');m:SetAttribute('Theme',theme)
 -- Continuous visual bed under the clearing and its connections. Non-walkable.
 local base=Kit.part(m,'ValleyBed',V(size[1]+680,120,size[2]+680),c-V(0,100,0),pal.rock,Enum.Material.Slate,'Ball');backdrop(base)
 for _,side in ipairs({-1,1})do
  for i=1,5 do
   local p=c+V(side*(size[1]/2+60+rng:NextNumber(0,80)),-48,-size[2]/2+(i-.5)*size[2]/5)
   local rock=Kit.rock(m,p,V(rng:NextNumber(100,160),rng:NextNumber(65,100),110),pal.rock,i*side);backdrop(rock)
   local shelf=Kit.rock(m,p+V(-side*20,27,0),V(80,28,85),pal.ground,i+4);backdrop(shelf)
  end
  -- Background ridges rise beyond the playable bounds, instead of identical balls on the floor.
  for i=1,4 do
   local p=c+V(side*(size[1]/2+230+i%2*48),-15,-size[2]/2+i*size[2]/4)
   local h=rng:NextNumber(90,150)
   backdrop(Kit.rock(m,p,V(150,h,190),pal.rock,side*i+2))
   if theme=='FrozenVale' then backdrop(Kit.rock(m,p+V(0,h*.27,0),V(136,h*.5,170),pal.ground,side*i+2))end
  end
 end
end
local function trail(parent,a,b,width,pal,theme)
 local d=b-a;if d.Magnitude<.1 then return end
 local mat=theme=='FrozenVale' and Enum.Material.Snow or theme=='EmberCaldera' and Enum.Material.CrackedLava or theme=='HauntedGraveyard' and Enum.Material.Cobblestone or Enum.Material.Ground
 local col=theme=='Deepwood' and C(162,145,101) or theme=='Gloamwood' and C(91,105,92) or theme=='HauntedGraveyard' and C(118,124,133) or pal.trim
 local p=Kit.part(parent,'WornRoute',V(width,.07,d.Magnitude+1),CFrame.lookAt((a+b)/2+V(0,.045,0),b+V(0,.045,0)),col,mat);p.CastShadow=false
end
local function paving(parent,c,pal,theme,chapter)
 local m=model(parent,'RouteAndGroundCover')
 -- A sequence of broad, uneven stepping slabs, not a glowing road or new collision.
 local step=theme=='EmberCaldera' and 23 or 18
 for i=1,15 do
  local z=145-i*step;local x=math.sin(i*.39)*22
  local mat=theme=='FrozenVale' and Enum.Material.Glacier or Enum.Material.Slate
  local p=Kit.part(m,'OldPaving',V(11+i%3*3,.1,10+i%2*4),CFrame.new(c+V(x,.08,z))*CFrame.Angles(0,math.sin(i)*.22,0),pal.trim,mat);p.Color=p.Color:Lerp(pal.ground,.55);p.CastShadow=false
 end
 if chapter then
  local from=c+V(-140,0,110)
  for _,g in ipairs(chapter.goals)do local to=vec(g.position);trail(m,from,to,theme=='Deepwood' and 13 or 17,pal,theme);from=to end
 end
end
local function grave(parent,p,pal,i)
 local yaw=CFrame.new(p)*CFrame.Angles(0,math.sin(i)*.12,math.sin(i*3)*.065)
 Kit.part(parent,'GraveBorder',V(7,.4,12),yaw*CFrame.new(0,.2,3),pal.rock)
 Kit.part(parent,'GraveEarth',V(5,.12,9),yaw*CFrame.new(0,.46,3),pal.ground,Enum.Material.Ground)
 Kit.part(parent,'HeadstoneBase',V(7,1.4,3),yaw*CFrame.new(0,.7,-2),pal.trim)
 Kit.part(parent,'Headstone',V(5,7,2),yaw*CFrame.new(0,4,-2),pal.trim)
 Kit.part(parent,'HeadstoneCap',V(5.5,2,2.5),yaw*CFrame.new(0,8,-2),pal.rock,Enum.Material.Slate,'Wedge')
 Kit.part(parent,'NameInset',V(3,1.7,.15),yaw*CFrame.new(0,4.8,-.92),pal.rock)
end
local function scatter(parent,c,size,pal,rng,theme,safe)
 local m=model(parent,'BorderVegetation')
 for i=1,(theme=='Gloamwood' and 62 or theme=='FrozenVale' and 24 or 42)do
  local side=i%2==0 and -1 or 1
  local p=c+V(side*rng:NextNumber(size[1]*.30,size[1]*.59),0,rng:NextNumber(-size[2]*.53,size[2]*.53))
  if safe(p,14)then
   local h=theme=='Gloamwood' and rng:NextNumber(48,74) or rng:NextNumber(30,49)
   if theme=='Deepwood' or theme=='Gloamwood' or theme=='HauntedGraveyard'then forestTree(m,p,h,pal,theme)
   elseif theme=='FrozenVale'then pine(m,p,h,pal)
   else
    Kit.rock(m,p+V(0,7,0),V(12,h,16),pal.rock,i)
    if i%3==0 then Kit.part(m,'BasaltSeam',V(.4,h*.6,1),p+V(4,h*.35,8.2),pal.accent,Enum.Material.Neon)end
   end
  end
 end
 local ground=model(parent,'GroundDetails')
 for i=1,64 do
  local p=c+V(rng:NextNumber(-size[1]*.46,size[1]*.46),0,rng:NextNumber(-size[2]*.46,size[2]*.46))
  if safe(p,5)then
   if theme=='HauntedGraveyard' and i%2==0 then grave(ground,p,pal,i)
   elseif i%3==0 then Kit.rock(ground,p+V(0,1.1,0),V(6+i%4,4,5+i%3),pal.trim,i)
   elseif theme=='Deepwood' or theme=='Gloamwood'then
    for j=1,3 do Kit.part(ground,'FernFrond',V(1,2.5,7),CFrame.new(p+V(0,1,0))*CFrame.Angles(.15,j*2,.25),pal.leaf,Enum.Material.Grass,'Wedge')end
   else Kit.part(ground,'WeatheredGroundPatch',V(14,.08,11),CFrame.new(p+V(0,.04,0))*CFrame.Angles(0,i,0),pal.trim:Lerp(pal.ground,.7),theme=='FrozenVale' and Enum.Material.Snow or Enum.Material.Slate)end
  end
 end
 if theme=='HauntedGraveyard'then
  for _,side in ipairs({-1,1})do for i=1,7 do
   local p=c+V(side*(size[1]/2-43),0,-135+i*31)
   if safe(p,8)then grave(ground,p,pal,i)end
  end end
 end
 for _,s in ipairs({-1,1})do Kit.lantern(ground,c+V(s*112,0,145),pal)end
end
local function waterfall(parent,p,pal)
 local m=model(parent,'SpringCascade')
 Kit.rock(m,p+V(0,27,-8),V(65,80,43),pal.rock,2)
 for i=1,3 do
  local water=Kit.part(m,'FallingWater',V(9,57,1.5),CFrame.new(p+V(i*7-14,19,15))*CFrame.Angles(0,0,.06),C(134,201,211),Enum.Material.Glass);water.Transparency=.28;water.CastShadow=false
 end
 local pool=Kit.part(m,'SpringPool',V(67,.25,45),p-V(0,9,0),C(92,161,168),Enum.Material.Glass,'Ball');pool.Transparency=.2
end
local function landmark(parent,c,size,pal,theme,index)
 local m=model(parent,'Landmark')
 if theme~='Deepwood'then Kit.arch(m,c+V(0,0,145),theme=='Gloamwood' and 85 or 95,36,pal)end
 -- Scenic flanks: outside combat/goal footprint, never a route gate.
 local p=c+V(math.max(135,size[1]/2-38),0,-size[2]/2+46)
 local original=theme=='FrozenVale' and 'SnowLandmark' or theme=='EmberCaldera' and 'VolcanoLandmark' or theme=='HauntedGraveyard' and 'CemeteryLandmark'
 if original then Env.asset(m,original,p+V(10,0,-54),index==7 and 82 or 62)end
 if theme=='Deepwood'then
  if index==3 or index==6 then
   local tree=Env.tree(m,p,index==6 and 82 or 64,true)
   tree:SetAttribute('LandmarkRole','ElderTree')
   for i=1,5 do local a=i*1.25;Kit.beam(m,'ElderRoot',p+V(0,8,0),p+V(math.cos(a)*40,0,math.sin(a)*40),5,pal.wood,Enum.Material.Wood)end
  elseif index==1 or index==5 then Kit.tower(m,p,58,pal,'battlement')
  else Kit.hall(m,p,pal,'ruin')end
  waterfall(parent,c+V(-size[1]/2-45,0,-90),pal)
 elseif theme=='FrozenVale'then
  if index==2 then Kit.hall(m,p,pal,'refuge');Kit.lantern(m,p+V(0,0,35),pal)
  else
   Kit.tower(m,p,65+index*3,pal,'battlement');Kit.arch(m,p+V(-65,0,0),60,46,pal)
   for i=1,4 do local q=p+V(-30-i*21,0,-15);Kit.rock(m,q+V(0,17,0),V(11,48+i*5,12),pal.trim,i)end
  end
 elseif theme=='EmberCaldera'then
  Kit.hall(m,p,pal,'forge')
  for _,s in ipairs({-1,1})do
   local q=p+V(s*36,0,-18)
   Kit.part(m,'FurnaceStack',V(14,75+index*3,16),q+V(0,37.5+index*1.5,0),pal.rock,Enum.Material.Brick)
   Kit.part(m,'StackCrown',V(19,5,21),q+V(0,75+index*3,0),pal.trim)
   Kit.part(m,'FurnaceMouth',V(10,14,.4),q+V(0,12,8.3),pal.accent,Enum.Material.Neon)
   local a=q+V(0,30,0);local b=c+V(size[1]/2+10,30,100);Kit.beam(m,'OverheadConduit',a,b,5,pal.trim,Enum.Material.Metal)
  end
  local lava=Kit.part(m,'LowerLavaChannel',V(38,.4,size[2]+240),c+V(-size[1]/2-95,-25,0),pal.accent,Enum.Material.Neon);backdrop(lava)
  for i=1,7 do Kit.rock(m,c+V(-size[1]/2-95,-6,-size[2]/2+i*62),V(30,45,33),pal.rock,i)end
 elseif theme=='Gloamwood'then
  if index==3 then Kit.hall(m,p,pal,'refuge')
  elseif index==7 then Kit.arch(m,p,52,55,pal);Kit.tower(m,p+V(43,0,0),72,pal,'spire')
  else
   Kit.tree(m,p,83,pal,false);forestTree(m,p+V(25,0,-15),76,pal,theme)
   Kit.tree(m,p+V(-70,0,-30),64,pal,false)
   Kit.web(m,p+V(0,65,0),p+V(-70,54,-30),p+V(-47,15,5),pal)
   if index==6 then Kit.hall(m,p+V(-35,0,-20),pal,'ruin')end
  end
  for _,s in ipairs({-1,1})do
   local q=c+V(s*(size[1]/2+20),0,-120)
   Kit.tree(m,q,65,pal,false);Kit.web(m,q+V(0,47,0),q+V(s*48,29,43),q+V(s*22,4,58),pal)
  end
 elseif theme=='HauntedGraveyard'then
  if index==1 or index==2 then Kit.hall(m,p,pal,index==1 and 'chapel' or 'shelter')
  elseif index==4 then Kit.tower(m,p,94,pal,'spire');Kit.arch(m,p+V(-55,0,0),45,32,pal)
  elseif index>=5 then
   Kit.tower(m,p+V(-40,0,-16),75,pal,'spire');Kit.tower(m,p+V(40,0,-16),95,pal,'spire');Kit.hall(m,p,pal,'chapel')
  else Kit.hall(m,p,pal,'crypt')end
  -- Offset burial rows; the center remains open for target silhouettes.
  for i=1,8 do grave(m,c+V(-size[1]/2+24+(i%2)*22,0,-size[2]/2+30+math.floor((i-1)/2)*40),pal,i)end
 end
 for _,piece in ipairs(m:GetDescendants())do if piece:IsA('BasePart')then backdrop(piece)end end
end
local function connection(world,parent,edge,index)
 local first,last=Content.zones[edge[1]],Content.zones[edge[2]]
 local theme=themes[edge[2]:sub(1,2)];local pal=Kit.palette[theme]
 local aa,bb=Bounds.ends(edge);local a,b=vec(aa),vec(bb);local length=(b-a).Magnitude
 if length<5 then return end
 local forward=V(b.X-a.X,0,b.Z-a.Z).Unit;local normal=V(-forward.Z,0,forward.X)
 local m=model(parent,'Pass_'..edge[1]..'_'..edge[2]);m:SetAttribute('Theme',theme)
 local segments=math.ceil(length/100)
 for i=0,segments do
  local t=i/segments;local p=a:Lerp(b,t)
  -- A visual valley floor follows the existing gentle ramp; no walkable bypass.
  local bed=Kit.part(m,'PassValley',V(280,78,length/segments+80),CFrame.lookAt(p-V(0,47,0),p-V(0,47,0)+forward),pal.rock,Enum.Material.Slate);backdrop(bed)
  for _,side in ipairs({-1,1})do
   local q=p+normal*side*(91+i%3*8)
   if not Bounds.region(q.X,q.Z,18)then
    backdrop(Kit.rock(m,q-V(0,16,0),V(70,61+i%3*9,80),pal.rock,i+index))
    if theme=='FrozenVale' then pine(m,q+V(0,9,0),33,pal)
    elseif theme~='EmberCaldera'then forestTree(m,q+V(0,6,0),35,pal,theme)end
    if i%2==0 then Kit.lantern(m,p+normal*side*38,pal)end
   end
  end
  if i%4==0 then task.wait()end
 end
 -- Dress bridges as broad stone causeways while retaining the exact original ramp collision.
 for _,side in ipairs({-1,1})do
  local curb=Kit.beam(m,'CausewayCoping',a+normal*side*44+V(0,.3,0),b+normal*side*44+V(0,.3,0),1.2,pal.trim);curb.CastShadow=false
 end
end
local function carveRoutes()
 -- Higher neighbouring skirts must never bury a lower clearing. Mask out only
 -- smooth scenic Terrain above the exact Part-owned campaign footprint.
 local terrain=workspace.Terrain
 for _,zone in pairs(Content.zones)do
  local c=vec(zone.center)
  terrain:FillBlock(CFrame.new(c+V(0,198,0)),V(zone.size[1]+4,400,zone.size[2]+4),Enum.Material.Air)
  task.wait()
 end
 for _,edge in ipairs(Access.edges)do
  local aa,bb=Bounds.ends(edge);local a,b=vec(aa),vec(bb)
  local flat=V(b.X-a.X,0,b.Z-a.Z);local n=math.max(1,math.ceil(flat.Magnitude/30))
  for i=0,n do
   local p=a:Lerp(b,i/n)
   terrain:FillBlock(CFrame.lookAt(p+V(0,198,0),p+V(0,198,0)+flat),V(100,400,flat.Magnitude/n+16),Enum.Material.Air)
   if i%12==0 then task.wait()end
  end
 end
end
function Art.create(world)
 if world.folder:FindFirstChild('EpicWorldArt')then return world end
 local root=Instance.new('Folder');root.Name='EpicWorldArt';root:SetAttribute('ArtVersion',Art.version);root.Parent=world.folder
 local ids={};for id in pairs(Content.zones)do table.insert(ids,id)end;table.sort(ids)
 for order,id in ipairs(ids)do
  local zone=Content.zones[id];local prefix=id:sub(1,2);local theme=themes[prefix];local pal=Kit.palette[theme]
  local c=vec(zone.center);local index=tonumber(id:sub(4)) or 2;local region=world.terrain:FindFirstChild(id)
  -- Retain existing colliders/anchors, hide only their superseded primitive presentation.
  if region then for _,p in ipairs(region:GetDescendants())do if p:IsA('BasePart') and obsolete[p.Name]then p.Transparency=1;p.CastShadow=false end end end
  local site=Instance.new('Folder');site.Name=id;site:SetAttribute('Theme',theme);site:SetAttribute('Landmark',landmarks[prefix][index]);site.Parent=root
  local rng=Random.new(6100+order*137)
  sculptGround(c,zone.size,pal,theme)
  geology(site,c,zone.size,pal,rng,theme)
  paving(site,c,pal,theme,Content.byId[id])
  scatter(site,c,zone.size,pal,rng,theme,reserves(world,id))
  landmark(site,c,zone.size,pal,theme,index)
  task.wait()
 end
 for index,edge in ipairs(Access.edges)do connection(world,root,edge,index);task.wait()end
 carveRoutes()
 world.folder:SetAttribute('EpicWorldArtVersion',Art.version)
 return world
end
return Art
