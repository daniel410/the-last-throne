-- Pinned TD presentation cloned without scripts; server geometry owns collision.
-- Source bytes/permissions: assets/shared/td-deepwood-environment/manifest.json
local Storage=game:GetService('ServerStorage')
local Env={}
local function place(template,parent,name,position,height)
 assert(template and template:IsA('Model'),'Pinned TD environment model missing: '..name)
 local copy=template:Clone();copy.Name=name
 for _,p in ipairs(copy:GetDescendants()) do
  if p:IsA('BasePart') then assert(p:IsA('MeshPart') and p.MeshId~='','Expected original TD MeshPart');p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p:SetAttribute('TLTDecorative',true)
  elseif p:IsA('LuaSourceContainer') then error('Executable content in pinned TD environment') end
 end
 local _,size=copy:GetBoundingBox();copy:ScaleTo(copy:GetScale()*height/size.Y)
 local bounds,newSize=copy:GetBoundingBox();copy:PivotTo(CFrame.new(position+Vector3.new(0,newSize.Y/2,0))*bounds:ToObjectSpace(copy:GetPivot()))
 copy.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 copy:SetAttribute('TDEnvironmentSource',name);copy.Parent=parent;return copy
end
function Env.tree(parent,position,height,landmark)
 local models=Storage:FindFirstChild('TDMapModels');assert(models,'Missing pinned TDMapModels')
 return place(models:FindFirstChild(landmark and 'ForestLandmark' or 'ForestTree'),parent,landmark and 'TDElderTree' or 'TDForestTree',position,height)
end
function Env.cliff(parent,position,height)
 local models=Storage:FindFirstChild('TDMapModels');return place(models and models:FindFirstChild('CliffRock'),parent,'TDLimestoneCliff',position,height)
end
function Env.portal(parent,position)
 local kit=Storage:FindFirstChild('TDForestKit');assert(kit,'Missing pinned TDForestKit')
 local source=Instance.new('Model');source.Name='PortalSubset'
 for _,p in ipairs(kit:GetDescendants()) do if p:IsA('MeshPart') then
  local value=p:FindFirstChild('ForestKitZone');local zone=p:GetAttribute('ForestKitZone') or value and value.Value
  if zone=='PortalGate' or zone=='PortalEnergy' then p:Clone().Parent=source end
 end end
 assert(#source:GetChildren()>0,'TD Forest kit portal pieces missing')
 local result=place(source,parent,'TDArrivalPortal',position,22);source:Destroy();return result
end
-- Existing pinned TD map templates; no external asset insertion.
function Env.asset(parent,name,position,height)
 local allowed={CliffRock=true,SnowCliff=true,VolcanoCliff=true,CemeteryCliff=true,SnowTree=true,ForestTree=true,ForestLandmark=true,SnowLandmark=true,VolcanoLandmark=true,CemeteryLandmark=true}
 assert(allowed[name],'Unsupported pinned scenery template')
 local models=Storage:FindFirstChild('TDMapModels')
 return place(models and models:FindFirstChild(name),parent,name,position,height)
end
-- Native TD kit submeshes, sized by their horizontal footprint rather than thin height.
function Env.kit(parent,zone,position,width)
 local allowed={BankVegetation=true,ContinuousTerrain=true,DeepCliff=true,SanctuaryTerrace=true,WaterfallGorge=true}
 assert(allowed[zone],'Unsupported TD kit region')
 local source=Instance.new('Model');source.Name=zone
 for _,p in ipairs(Storage.TDForestKit:GetDescendants())do if p:IsA('MeshPart')then
  local value=p:FindFirstChild('ForestKitZone')
  if (p:GetAttribute('ForestKitZone') or value and value.Value)==zone then p:Clone().Parent=source end
 end end
 assert(#source:GetChildren()>0,'Missing pinned kit geometry')
 local _,size=source:GetBoundingBox()
 local result=place(source,parent,'TD'..zone,position,size.Y*width/math.max(size.X,size.Z));source:Destroy();return result
end
function Env.crown(parent,position,width,color)
 local template=Instance.new('Model');template.Name='CanopySubset'
 for _,p in ipairs(Storage.TDMapModels.ForestTree:GetDescendants())do
  if p:IsA('MeshPart')and p.Name=='foliage_geom'then p:Clone().Parent=template end
 end
 local _,size=template:GetBoundingBox()
 local copy=place(template,parent,'TDCanopyCrown',position,size.Y*width/size.X);template:Destroy()
 for _,p in ipairs(copy:GetDescendants())do if p:IsA('MeshPart')then p:SetAttribute('TDOriginalTexture',p.TextureID);p.TextureID='';p.Color=color;p.Material=Enum.Material.Grass end end
 return copy
end
-- Axis-aligned kit exports are fused by material, so a presentation-only fit can
-- match a rectangular encounter footprint with an organic TD terrain perimeter.
function Env.fit(copy,center,size)
 local cf,bounds=copy:GetBoundingBox();local scale=Vector3.new(size.X/bounds.X,size.Y/bounds.Y,size.Z/bounds.Z)
 for _,p in ipairs(copy:GetDescendants())do if p:IsA('BasePart')then
  local delta=p.Position-cf.Position
  p.Size=p.Size*scale;p.CFrame=CFrame.new(center+delta*scale)*p.CFrame.Rotation
 end end
 return copy
end
return Env
