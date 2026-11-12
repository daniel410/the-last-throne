-- Persistent traces of local life, never a projection of personal quest completion.
-- A quiet foreground / story cluster / existing TD skyline replaces empty verges.
local K=require(script.Parent.EpicEnvironmentKit)
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local M={version=1}
local V=Vector3.new
local profiles={
 DW={'Supplies','Supplies','Refuge','Watch','Work','Roots','Roots'},
 GW={'Scout','Silk','Refuge','Roots','Silk','Scout','Silk'},
 FV={'Refuge','Refuge','Waystone','Archive','Waystone','Watch','Archive'},
 EC={'Freight','Work','Work','Coolant','Archive','Coolant','Freight'},
 HG={'Memorial','Refuge','Memorial','Bells','Watch','Memorial','Bells'},
}
local optional={['DW-S1']='Supplies',['DW-S2']='Work',['DW-S3']='Watch',['FV-S1']='Supplies',['FV-S2']='Waystone',['FV-S3']='Watch',['EC-S1']='Freight',['EC-S2']='Coolant',['EC-S3']='Work'}
function M.profile(id)return optional[id]or profiles[id:sub(1,2)][tonumber(id:sub(4))]end
local function compose(m,kind,origin,pal,theme,variant)
 local function part(name,size,at,col,mat,yaw,shape)
  local p=K.part(m,name,size,origin*CFrame.new(at)*CFrame.Angles(0,yaw or 0,0),col or pal.wood:Lerp(pal.trim,.38),mat or Enum.Material.Wood,shape)
  p:SetAttribute('TLTSceneryDistance',360)
  -- Low cloth/markings are soft; substantial objects have real collision.
  p:SetAttribute('EpicDetailSolid',size.Y>.6 and mat~=Enum.Material.Fabric)
  return p
 end
 local function box(at)
  part('SupplyChest',V(3.8,2.8,3),at+V(0,1.4,0))
  for _,x in ipairs({-1,1})do part('ChestBand',V(.2,2.95,3.1),at+V(x*1.2,1.5,0),pal.trim,Enum.Material.Metal)end
 end
 local function lamp(at)
  part('WayLampPost',V(.5,5,.5),at+V(0,2.5,0))
  part('WayLampHousing',V(1.7,1.6,1.7),at+V(0,5.4,0),pal.rock,Enum.Material.Metal)
  part('WayLampPane',V(1.75,.75,1.75),at+V(0,5.4,0),pal.accent,Enum.Material.Neon)
  part('WayLampCap',V(2.3,.3,2.3),at+V(0,6.35,0),pal.trim,Enum.Material.Metal)
 end
 local function stone(at,h)
  part('StoryStandingStone',V(2.6,h,1.8),at+V(0,h/2,0),pal.rock,Enum.Material.Slate,.08)
  part('StoneInset',V(1.4,.3,.12),at+V(0,h*.7,1),pal.trim,Enum.Material.Slate)
 end
 if kind=='Supplies'or kind=='Freight'then
  for _,x in ipairs({-1,1})do part('CartRunner',V(.6,.8,9),V(x*3,.4,0),pal.wood,Enum.Material.Wood)end
  for i=1,5 do part('CartBed',V(7,.35,1.4),V(0,1,(i-3)*1.5))end
  box(V(-1.5,1.2,-2));box(V(1.4,1.2,1.5))
  part('CargoCloth',V(4,.16,2.8),V(1.4,4.1,1.5),theme=='Deepwood'and Color3.fromRGB(108,166,203)or pal.trim,Enum.Material.Fabric)
 elseif kind=='Refuge'then
  for i=1,3 do
   part('RestMat',V(3,.15,6),V((i-2)*4.5,.15,0),pal.trim,Enum.Material.Fabric)
   part('RolledBlanket',V(3,.65,1),V((i-2)*4.5,.5,-2),pal.wood,Enum.Material.Fabric)
  end
  box(V(-4.5,0,-6));lamp(V(5,0,-5))
 elseif kind=='Scout'or kind=='Silk'then
  lamp(V(-5,0,-3));lamp(V(4,0,3))
  for i=1,3 do part('ScoutTrailCloth',V(1.4,.2,2),V((i-2)*3,.25,(i-2)*2),pal.trim,Enum.Material.Fabric,.4)end
  if kind=='Silk'then
   -- Old silk on abandoned gear; no captive or quest actor duplicated here.
   box(V(0,0,-3))
   for i=1,4 do part('OldSilkStrand',V(.12,.12,8),V((i-2)*.65,3,-2),pal.trim,Enum.Material.Fabric,i*.45)end
  end
 elseif kind=='Work'then
  for _,x in ipairs({-1,1})do part('TrestleFoot',V(.9,3.4,4),V(x*4,1.7,0))end
  part('WorkBench',V(11,.6,5),V(0,3.7,0))
  for i=1,3 do part('UnworkedStone',V(2,1.1,1.8),V((i-2)*3,4.5,0),pal.rock,Enum.Material.Slate,i*.3,'Wedge')end
  box(V(-4,0,-5))
 elseif kind=='Coolant'then
  for _,x in ipairs({-1,1})do part('ChannelVerge',V(1,1.4,12),V(x*3,.7,0),pal.rock,Enum.Material.Basalt)end
  part('DryServiceChannel',V(5,.2,12),V(0,.15,0),pal.trim,Enum.Material.Metal)
  for i=1,3 do part('ServiceGrate',V(6,.3,.5),V(0,1.5,(i-2)*3),pal.wood,Enum.Material.Metal)end
  box(V(5,0,-3))
 elseif kind=='Roots'then
  for i=1,4 do part('ExposedOldRoot',V(2.3,1+i*.45,10-i),V((i-2.5)*2,1,0),pal.wood,Enum.Material.Wood,i*.35,'Wedge')end
  stone(V(-5,0,-4),5);stone(V(4,0,4),3)
 elseif kind=='Archive'then
  for i=1,3 do
   stone(V((i-2)*4,0,-3),4+i%2*2)
   part('RecordSlab',V(2.4,.35,3),V((i-2)*4,.3,1),pal.trim,Enum.Material.Slate,.1*i)
  end
 elseif kind=='Memorial'then
  for i=1,3 do
   stone(V((i-2)*4,0,-3),3+i%2)
   part('OfferingBowl',V(1.5,.65,1.5),V((i-2)*4,.4,0),pal.trim,Enum.Material.Slate,0,'Ball')
  end
  lamp(V(5,0,4))
 elseif kind=='Bells'then
  for _,x in ipairs({-1,1})do part('BellStand',V(1,7,1),V(x*3,3.5,-2))end
  part('BellCrossbar',V(8,.8,1.3),V(0,7,-2))
  part('OldBell',V(3,3,3),V(0,5,-2),pal.trim,Enum.Material.Metal,0,'Ball')
  part('BellLip',V(4,.5,4),V(0,3.5,-2),pal.trim,Enum.Material.Metal)
 else
  stone(V(-4,0,-3),7);stone(V(4,0,3),4);lamp(V(3,0,-4))
 end
 m:SetAttribute('StoryMotif',kind);m:SetAttribute('CompositionVariant',variant)
end
function M.build(site,id,c,size,pal,theme,safe,ground,world)
 local old=site:FindFirstChild('StoryComposition');if old then old:Destroy()end
 local root=Instance.new('Folder');root.Name='StoryComposition';root.Parent=site
 local kind=assert(M.profile(id),id);local candidates={}
 -- Start from actual story destinations, then try quieter in-zone shoulders.
 for _,chapter in ipairs(C.chapters)do if chapter.zone==id then
  for _,g in ipairs(chapter.goals)do table.insert(candidates,V(table.unpack(g.position)))end
 end end
 table.insert(candidates,c)
 for _,x in ipairs({-.3,.3})do for _,z in ipairs({-.3,.3})do table.insert(candidates,c+V(size[1]*x,0,size[2]*z))end end
 local used={};local radius=12
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude
 overlap.FilterDescendantsInstances={root};overlap.RespectCanCollide=true
 local roads={}
 for _,p in ipairs(world.folder:GetDescendants())do
  if p:IsA('BasePart')and (p.Name=='WornCurvedRoute'or p.Name=='JourneyWalkingTrail'or p.Name=='ReturnLoop'or p.Name=='RegionalReturnTrail')and p.Transparency<.5 then roads[#roads+1]=p end
 end
 local roadOverlap=OverlapParams.new();roadOverlap.FilterType=Enum.RaycastFilterType.Include
 roadOverlap.FilterDescendantsInstances=roads;roadOverlap.RespectCanCollide=false
 for _,anchor in ipairs(candidates)do
  for ring=1,3 do for i=0,7 do
   if #used>=2 then break end
   local angle=i*math.pi/4+ring*.17;local q=anchor+V(math.cos(angle)*(48+ring*22),0,math.sin(angle)*(48+ring*22))
   local valid=math.abs(q.X-c.X)<size[1]/2-radius and math.abs(q.Z-c.Z)<size[2]/2-radius and safe(q,radius)
   for _,z in pairs(C.zones)do for _,a in ipairs(z.expansionAreas or {})do
    if Areas.contains(a,q.X,q.Z,radius+8)or Areas.contains(a.connector,q.X,q.Z,radius+8)then valid=false end
   end end
   for _,p in ipairs(used)do if (q-p).Magnitude<65 then valid=false end end
   if valid then
    local p,ok=ground(q);valid=ok and math.abs(p.Y-c.Y)<12
    for _,d in ipairs({V(10,0,0),V(-10,0,0),V(0,0,10),V(0,0,-10)})do
     local s,supported=ground(q+d);if not supported or math.abs(s.Y-p.Y)>.45 then valid=false end
    end
    if valid and #workspace:GetPartBoundsInBox(CFrame.new(p+V(0,5,0)),V(25,8,25),overlap)==0
     and #workspace:GetPartBoundsInBox(CFrame.new(p+V(0,2,0)),V(25,6,25),roadOverlap)==0 then
     local m=Instance.new('Model');m.Name=kind..'_'..(#used+1);m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
     m:SetAttribute('StoryZone',id);m:SetAttribute('GroundPosition',p);m:SetAttribute('ReservedRadius',radius)
     compose(m,kind,CFrame.new(p)*CFrame.Angles(0,angle+math.pi/2,0),pal,theme,#used+1)
     m.Parent=root;table.insert(used,p)
    end
   end
  end end
  if #used>=2 then break end
 end
 site:SetAttribute('StoryCompositionVersion',M.version);site:SetAttribute('StoryCompositionClusters',#used)
 return root
end
return M
