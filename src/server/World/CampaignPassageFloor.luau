-- Solid triangular prisms meet the actual mouth planes across the full width.
-- Their upper faces are exactly the triangles used by CampaignBounds.
local Passage=require(game.ReplicatedStorage.Shared.CampaignPassage)
local Floor={}
local V=Vector3.new
local function triangle(parent,a,b,c,color,material,edge)
 -- Physics uses float coordinates; overlap coplanar seams by a few hundredths
 -- of a stud instead of leaving a ray/foot-sized numerical crack.
 local center=(a+b+c)/3
 a=center+(a-center)*1.001;b=center+(b-center)*1.001;c=center+(c-center)*1.001
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then a,c=c,a
 elseif ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local normal=ac:Cross(ab)
 if normal.Magnitude<.00001 or bc.Magnitude<.00001 then return end
 local right,back=normal.Unit,bc.Unit
 local up=back:Cross(right).Unit
 local height=math.abs(ab:Dot(up))
 local surfaceNormal=right.Y>=0 and right or -right
 for _,spec in ipairs({
  {size=V(2,height,math.abs(ab:Dot(back))),cf=CFrame.fromMatrix((a+b)*.5,right,up,back)},
  {size=V(2,height,math.abs(ac:Dot(back))),cf=CFrame.fromMatrix((a+c)*.5,-right,up,-back)},
 })do
  if spec.size.Y>.001 and spec.size.Z>.001 then
   local p=Instance.new('WedgePart');p.Name='JourneyPass';p.Size=spec.size
   p.CFrame=spec.cf-surfaceNormal;p.Anchored=true;p.CanTouch=false
   p.CanCollide=true;p.CanQuery=true;p.Color=color;p.Material=material
   p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
   p:SetAttribute('FromZone',edge[1]);p:SetAttribute('ToZone',edge[2]);p.Parent=parent
  end
 end
end
function Floor.create(parent,first,last,color,material,edge)
 for _,t in ipairs(Passage.create(first,last).triangles)do
  triangle(parent,V(table.unpack(t[1])),V(table.unpack(t[2])),V(table.unpack(t[3])),color,material,edge)
 end
end
return Floor
