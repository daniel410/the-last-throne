-- Isolated prototype: preserve the audited approach and top height.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local root=assert(_G.Terraces)
local layouts={
 {x=150,widths={104,86,68},depths={94,80,68},shifts={0,4,6}},
 {x=270,widths={104,92,80},depths={80,68,56},shifts={0,0,0}},
 {x=390,widths={90,74,58},depths={70,60,48},shifts={0,-4,-6}},
}
local rows={}
for i,v in ipairs(layouts)do
 local court=assert(root:FindFirstChild('RetainedBurialCourt'..i))
 for _,p in ipairs(court:GetChildren())do
  if p:IsA('BasePart')and(p.Name=='RetainingCourse'or p.Name=='WeatheredCoping')then
   local tier=math.clamp(math.floor((p.Position.Y-188)/6)+1,1,3)
   local cap=p.Name=='WeatheredCoping'
   -- Keep each tier's south edge unchanged; extend/retract only the rear.
   local front=-17520+(80-(tier-1)*12)/2
   p.Size=Vector3.new(v.widths[tier]+(cap and .4 or 0),p.Size.Y,v.depths[tier]+(cap and .4 or 0))
   p.Position=Vector3.new(v.x+v.shifts[tier],p.Position.Y,front-v.depths[tier]/2)
   rows[#rows+1]={name=p:GetFullName(),size=tostring(p.Size),position=tostring(p.Position)}
  end
 end
 -- Keep the small eastern grave row inside its reduced upper court.
 if i==3 then
  for _,m in ipairs(court:GetChildren())do if m:IsA('Model')then
   local delta=m:GetPivot().Position.X-v.x
   m:PivotTo(m:GetPivot()+Vector3.new(-6-delta*.35,0,-4))
  end end
 end
end
root:SetAttribute('PrototypeVersion',2)
return rows
