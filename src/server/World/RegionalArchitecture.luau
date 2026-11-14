-- Blender-authored primitives retain their exact local rotations and proportions.
local Templates=require(script.Parent.RegionalArchitectureTemplates)
local K=require(script.Parent.EpicEnvironmentKit)
local Architecture={version=3}
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
