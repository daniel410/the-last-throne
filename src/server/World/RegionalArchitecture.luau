-- Blender-authored primitives retain their exact local rotations and proportions.
local Templates=require(script.Parent.RegionalArchitectureTemplates)
local K=require(script.Parent.EpicEnvironmentKit)
local Architecture={version=5}
function Architecture.build(kind)
 local rows=assert(Templates[kind],'Unknown regional architecture '..kind)
 local m=Instance.new('Model');m.Name=kind;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('RegionalConceptRole','Signature')
 m:SetAttribute('BlenderSource','regional-architecture-blender-v1')
 m:SetAttribute('BlenderTemplateVersion',Architecture.version)
 for _,r in ipairs(rows)do
  local p=K.part(m,r[1],Vector3.new(table.unpack(r[4])),CFrame.new(table.unpack(r[6])),Color3.fromRGB(table.unpack(r[5])),Enum.Material[r[3]],r[2])
  if r[2]=='Cylinder'then p.Shape=Enum.PartType.Cylinder end
  -- Runtime derivative keeps the pinned Blender layout and source intact.
  if r[1]:match('^Silk')then
   local width=r[1]=='SilkAnchor'and .48 or r[1]=='SilkRadial'and .32 or .26
   p.Size=Vector3.new(width,width,p.Size.Z);p.Color=Color3.fromRGB(210,222,237)
  elseif r[3]=='Slate'then
   p.Color=p.Color:Lerp(Color3.fromRGB(176,188,201),.12)
  end
  p:SetAttribute('EpicDetailSolid',r[7]);p:SetAttribute('TLTSceneryDistance',700)
 end
 m:SetAttribute('BlenderPrimitiveCount',#rows)
 local details=0
 if kind=='SilkWatchApproach'or kind=='WebRescueCourt'or kind=='LanternRootRefuge'or kind=='HollowbarkRootBastion'or kind=='SilkenBankAnchors'or kind=='ScoutExtractionWall'or kind=='WidowWatchfortGate'then
  -- Connect the high web to the architecture; suspended geometry must have
  -- visible anchors rather than reading as a floating wireframe triangle.
  for _,side in ipairs({-1,1})do
   local high=Vector3.new(side*15.5,kind=='WidowWatchfortGate'and 28 or 23,-3)
   local low=Vector3.new(side*11,8,2)
   for i=0,2 do
    local top=high+Vector3.new(-side*i*2,0,0)
    local foot=low+Vector3.new(side*i*.35,0,i*2)
    local strand=K.beam(m,'AttachedSilverSilk',top,foot,.48,Color3.fromRGB(216,228,240),Enum.Material.Fabric)
    strand:SetAttribute('EpicDetailSolid',false);strand:SetAttribute('TLTSceneryDistance',700);details+=1
   end
   for i=1,3 do
    local t=i/4;local a=high:Lerp(low,t);local b=(high+Vector3.new(-side*4,0,0)):Lerp(low+Vector3.new(side*.7,0,4),t)
    local band=K.beam(m,'AnchoredSilkBand',a,b,.36,Color3.fromRGB(201,217,234),Enum.Material.Fabric)
    band:SetAttribute('EpicDetailSolid',false);band:SetAttribute('TLTSceneryDistance',700);details+=1
   end
  end
 end
 if kind=='BracedMineHead'then
  -- EC-03: load-bearing uprights ground the existing rescue lintel and braces.
  -- Static fittings remain inside the authored footprint; no new blocker.
  local function fitting(name,size,pos,color,material)
   local p=K.part(m,name,size,CFrame.new(pos),color,material)
   p:SetAttribute('EpicDetailSolid',false);p:SetAttribute('TLTSceneryDistance',700)
   p:SetAttribute('MineSupportDetail',true);details+=1
  end
  for _,side in ipairs({-1,1})do
   fitting('MineStoneFoot',Vector3.new(3.8,.6,3.8),Vector3.new(side*10,.3,-2),Color3.fromRGB(83,79,77),Enum.Material.Basalt)
   fitting('MineUpright',Vector3.new(2,16,2),Vector3.new(side*10,8.6,-2),Color3.fromRGB(104,72,46),Enum.Material.Wood)
   for _,height in ipairs({2,14.8})do
    fitting('MineIronCollar',Vector3.new(2.16,.55,2.16),Vector3.new(side*10,height,-2),Color3.fromRGB(62,65,68),Enum.Material.Metal)
   end
  end
  -- Five sleepers connect the two original haul rails to the worked ground.
  for i=0,4 do
   fitting('MineRailSleeper',Vector3.new(14,.16,.65),Vector3.new(0,.08,4+i*2),Color3.fromRGB(82+(i%2)*6,61,44),Enum.Material.Wood)
  end
 end
 if kind=='HearthLonghouse'then
  -- FV-02: a sheltered hearth connects the existing flue to the refuge floor.
  -- All additions stay inside the original lodge footprint and stay decorative.
  local function hearth(name,size,pos,color,material)
   local p=K.part(m,name,size,CFrame.new(pos),color,material)
   p:SetAttribute('EpicDetailSolid',false);p:SetAttribute('TLTSceneryDistance',700)
   p:SetAttribute('RefugeHearthDetail',true);details+=1
   return p
  end
  -- FV-02: a dry timber interior distinguishes refuge from the snow outside.
  -- Thin visual boards overlay the existing authoritative floor; no new step.
  for i=1,8 do
   local board=K.part(m,'RefugeFloorboard',Vector3.new(2.995,.08,18),CFrame.new(-13.5+i*3,.04,.5),Color3.fromRGB(91+(i%3)*4,72+(i%3)*3,54+(i%3)*2),Enum.Material.Wood)
   board:SetAttribute('EpicDetailSolid',false);board:SetAttribute('TLTSceneryDistance',700)
   board:SetAttribute('RefugeFloorDetail',true);details+=1
  end
  local stone=Color3.fromRGB(133,161,182)
  local coping=Color3.fromRGB(207,226,235)
  hearth('HearthSlab',Vector3.new(8,.6,6),Vector3.new(-8,.3,-3),coping,Enum.Material.Slate)
  hearth('HearthSootBack',Vector3.new(5,6,.4),Vector3.new(-8,3.6,-4.8),Color3.fromRGB(38,42,48),Enum.Material.Slate)
  for _,side in ipairs({-1,1})do
   hearth('HearthJamb',Vector3.new(1.5,6,4),Vector3.new(-8+side*3,3.6,-3),stone,Enum.Material.Slate)
  end
  hearth('HearthMantel',Vector3.new(8,1.2,5),Vector3.new(-8,7.2,-3),coping,Enum.Material.Slate)
  hearth('HearthThroat',Vector3.new(4,4.4,4),Vector3.new(-8,9.7,-3),stone,Enum.Material.Slate)
  hearth('BankedEmbers',Vector3.new(4,.15,2),Vector3.new(-8,.68,-3),Color3.fromRGB(225,116,47),Enum.Material.Neon)
  for i=1,3 do
   local log=hearth('HearthSplitLog',Vector3.new(3.7,.65,.65),Vector3.new(-8,.95,-4+i*.65),Color3.fromRGB(76,55,44),Enum.Material.Wood)
   log.CFrame*=CFrame.Angles(0,(i-2)*.12,0)
  end
  -- A small static glow gives warmth without lights, particles or update loops.
  hearth('HearthWarmCore',Vector3.new(2.4,.8,.45),Vector3.new(-8,1.5,-3),Color3.fromRGB(245,173,77),Enum.Material.Neon)
 end
 if kind=='GreatFurnaceCrown'then
  -- A tall flue and contained furnace heat give the final works a skyline
  -- without widening its reserved ground footprint or adding any light/loop.
  local function detail(name,size,cf,color,material,shape)
   local p=K.part(m,name,size,cf,color,material,shape)
   p:SetAttribute('EpicDetailSolid',material~=Enum.Material.Neon);p:SetAttribute('TLTSceneryDistance',700);details+=1
  end
  detail('FurnaceFlue',Vector3.new(10,26,10),CFrame.new(0,35,-5),Color3.fromRGB(83,80,83),Enum.Material.Metal)
  detail('FlueCoping',Vector3.new(12,2,12),CFrame.new(0,48,-5),Color3.fromRGB(158,144,119),Enum.Material.Metal)
  detail('ContainedFurnaceHeat',Vector3.new(8,2,.1),CFrame.new(0,24,5),Color3.fromRGB(235,140,64),Enum.Material.Neon)
  for _,p in ipairs(m:GetChildren())do if p.Name=='FurnaceCrown'then p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(145,110,73)end end
 elseif kind=='MirrorPavilion'then
  for _,p in ipairs(m:GetChildren())do if p.Name=='FacetedMirrorRoofPanel'then p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(122,181,216);p.Reflectance=.12 end end
 end
 m:SetAttribute('RuntimeDetailParts',details)
 m.WorldPivot=CFrame.identity
 return m
end
return Architecture
