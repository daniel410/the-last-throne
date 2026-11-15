-- Broken forest margins around the convoy/scout search clearing.
-- Reuses the pinned TD tree through the existing Gloamwood material adapter.
local M={version=1}
local V=Vector3.new
function M.build(root,center,size,safe,ground,plant)
 local used={};local groups={};local count=0
 local function candidate(p,r)
  if not safe(p,r)then return end
  if math.abs(p.X-center.X)+r>=size[1]/2 or math.abs(p.Z-center.Z)+r>=size[2]/2 then return end
  for _,q in used do if (p-q).Magnitude<24 then return end end
  local at,ok=ground(p);if not ok then return end
  for _,d in ipairs({V(6,0,0),V(-6,0,0),V(0,0,6),V(0,0,-6)})do
   local q,valid=ground(p+d);if not valid or math.abs(q.Y-at.Y)>1 then return end
  end
  return at
 end
 for _,side in ipairs({-1,1})do for band,z in ipairs({-.34,.04,.33})do
  local anchor=center+V(side*size[1]*.40,0,z*size[2])
  for i,offset in ipairs({V(0,0,0),V(-side*27,0,29),V(side*16,0,53)})do
   local h=({68,42,54})[i]+(band==2 and 5 or 0)
   local at
   for ring=0,2 do
    for k=0,(ring==0 and 0 or 7)do
     local angle=k*math.pi/4
     at=candidate(anchor+offset+V(math.cos(angle)*ring*24,0,math.sin(angle)*ring*24),h*.32+6)
     if at then break end
    end
    if at then break end
   end
   if at then
    local m=plant(at,h);local yaw=side*(band*1.37+i*.81)
    m:PivotTo(CFrame.new(at)*CFrame.Angles(0,yaw,0)*CFrame.new(-at)*m:GetPivot())
    m:SetAttribute('VergeCluster',side..':'..band);m:SetAttribute('VergeHeight',h)
    m:SetAttribute('VergeSource','PinnedTD:ForestTree');m:SetAttribute('GroundPosition',at)
    used[#used+1]=at;groups[side..':'..band]=true;count+=1
   end
  end
 end end
 local n=0;for _ in pairs(groups)do n+=1 end
 root:SetAttribute('GloamwoodVergeVersion',M.version)
 root:SetAttribute('VergeTrees',count);root:SetAttribute('VergeGroups',n)
 return root
end
return M
