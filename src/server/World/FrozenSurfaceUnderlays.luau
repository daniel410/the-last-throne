-- Keep deep collision foundations, but do not render a slate top through snow.
local M={version=1}
local function covered(p,floor)
 if not floor or not floor.CanCollide or floor.Transparency~=0 then return false end
 if p.CFrame.UpVector.Y<.99999 or floor.CFrame.UpVector.Y<.99999 then return false end
 if (p.CFrame.RightVector-floor.CFrame.RightVector).Magnitude>.001 then return false end
 local top=p.Position.Y+p.Size.Y/2
 if math.abs(top-floor.Position.Y-floor.Size.Y/2)>.001 then return false end
 return math.abs(p.Position.X-floor.Position.X)+p.Size.X/2<=floor.Size.X/2+.001
  and math.abs(p.Position.Z-floor.Position.Z)+p.Size.Z/2<=floor.Size.Z/2+.001
end
function M.apply(world)
 if not world.terrain then return 0 end
 local floors={}
 for _,p in world.terrain:GetDescendants()do
  if p:IsA('BasePart')and p.Name=='JourneyGround'then
   local id=p:GetAttribute('RouteZone');if type(id)=='string'and id:sub(1,3)=='FV-'then floors[id]=p end
  end
 end
 local hidden=0
 for _,p in world.terrain:GetDescendants()do
  local id
  if p:IsA('BasePart')then
   if p.Parent.Name=='FrozenValeFoundation'and p.Name:sub(1,11)=='Support_FV-'then id=p.Name:sub(9)
   elseif p.Name=='SnowGround'and p.Parent.Name:sub(1,3)=='FV-'then id=p.Parent.Name end
  end
  if id then
   if covered(p,floors[id])then
    if p:GetAttribute('FVUnderlayTransparency')==nil then
     p:SetAttribute('FVUnderlayTransparency',p.Transparency);p:SetAttribute('FVUnderlayShadow',p.CastShadow)
    end
    p.Transparency=1;p.CastShadow=false;hidden+=1
   elseif p:GetAttribute('FVUnderlayTransparency')~=nil then
    p.Transparency=p:GetAttribute('FVUnderlayTransparency');p.CastShadow=p:GetAttribute('FVUnderlayShadow')
    p:SetAttribute('FVUnderlayTransparency',nil);p:SetAttribute('FVUnderlayShadow',nil)
   end
  end
 end
 world.folder:SetAttribute('FVConsolidatedUnderlays',hidden)
 return hidden
end
return M
