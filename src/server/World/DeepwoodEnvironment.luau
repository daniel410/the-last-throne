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
return Env
