-- Isolated prototype; run after terraces/access/asymmetry/memorial-focus.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local root=assert(_G.Terraces)
assert(not root:FindFirstChild('RoyalRetainingButtresses'),'Already applied')
local model=Instance.new('Model');model.Name='RoyalRetainingButtresses'
local rows={}
for i=1,3 do
 local court=assert(root:FindFirstChild('RetainedBurialCourt'..i))
 local top
 for _,p in ipairs(court:GetChildren())do
  if p.Name=='WeatheredCoping' and (not top or p.Position.Y>top.Position.Y)then top=p end
 end
 assert(top)
 for _,side in ipairs({-1,1})do
  local height=top.Position.Y-188
  local inner=top.Position.X+side*(top.Size.X/2-3)
  local p=Instance.new('WedgePart');p.Name='RetainingButtress'
  p.Size=Vector3.new(10,height,26);p.Anchored=true
  p.Material=Enum.Material.Slate;p.Color=top.Color
  -- Wedge rises toward local +Z; rotate toward the court center.
  p.CFrame=CFrame.new(inner+side*13,188+height/2,top.Position.Z)*CFrame.Angles(0,-side*math.pi/2,0)
  p.CanCollide=true;p.CanQuery=true;p:SetAttribute('EpicDetailSolid',true)
  p:SetAttribute('AssetOrigin','Derived:RoyalBurialTerraces/WeatheredCoping')
  p.Parent=model
  rows[#rows+1]={court=i,side=side,position=tostring(p.Position),size=tostring(p.Size)}
  assert(math.abs((p.Position.Y-p.Size.Y/2)-188)<.001)
 end
end
model.Parent=root
root:SetAttribute('PrototypeVersion',4)
assert(#model:GetChildren()==6)
return rows
