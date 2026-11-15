-- Render only the canonical surface when a confirmed regional underlay is fully covered.
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
local profiles={
 FV={foundation='FrozenValeFoundation',ground='SnowGround'},
 EC={foundation='EmberCalderaFoundation',ground='BasaltGround'},
 GW={foundation='LateEpicFoundation',ground='Ground'},
 HG={foundation='LateEpicFoundation',ground='Ground'},
}
function M.apply(world,only)
 if not world.terrain then return 0 end
 local floors={};local counts={}
 for prefix in profiles do if not only or prefix==only then counts[prefix]=0 end end
 for _,p in world.terrain:GetDescendants()do
  if p:IsA('BasePart')and p.Name=='JourneyGround'then
   local id=p:GetAttribute('RouteZone')
   if type(id)=='string'and counts[id:sub(1,2)]~=nil then floors[id]=p end
  end
 end
 local hidden=0
 for _,p in world.terrain:GetDescendants()do
  local id,prefix
  if p:IsA('BasePart')then
   local supportId=p.Name:match('^Support_(%u%u%-.+)$')
   if supportId then
    local key=supportId:sub(1,2);local spec=profiles[key]
    if spec and counts[key]~=nil and p.Parent.Name==spec.foundation then id=supportId;prefix=key end
   else
    local key=p.Parent.Name:sub(1,2);local spec=profiles[key]
    if spec and counts[key]~=nil and p.Name==spec.ground then id=p.Parent.Name;prefix=key end
   end
  end
  if id then
   local alpha=prefix..'UnderlayTransparency';local shadow=prefix..'UnderlayShadow'
   if covered(p,floors[id])then
    if p:GetAttribute(alpha)==nil then p:SetAttribute(alpha,p.Transparency);p:SetAttribute(shadow,p.CastShadow)end
    p.Transparency=1;p.CastShadow=false;hidden+=1;counts[prefix]+=1
   elseif p:GetAttribute(alpha)~=nil then
    p.Transparency=p:GetAttribute(alpha);p.CastShadow=p:GetAttribute(shadow)
    p:SetAttribute(alpha,nil);p:SetAttribute(shadow,nil)
   end
  end
 end
 for prefix,count in counts do world.folder:SetAttribute(prefix..'ConsolidatedUnderlays',count)end
 if not only then world.folder:SetAttribute('CampaignConsolidatedUnderlays',hidden)end
 return hidden
end
return M
