-- HG-03: quiet burial gardens beside Lumi's maintenance passage.
-- Reuse the repository grave kit; keep gameplay terrain and personal state intact.
local K=require(script.Parent.EpicEnvironmentKit)
local A=require(script.Parent.EpicArchitecture)
local M={version=1};local V=Vector3.new
function M.build(parent,center,size,pal,safe,ground)
 local placed={};local groups=0;local graves=0
 for band,offset in ipairs({V(-.32,0,-.30),V(.32,0,-.18),V(-.30,0,.28),V(.30,0,.32)})do
  local anchor=center+V(offset.X*size[1],0,offset.Z*size[2]);local at
  for ring=0,2 do
   for k=0,(ring==0 and 0 or 7)do
    local a=k*math.pi/4;local q=anchor+V(math.cos(a)*ring*28,0,math.sin(a)*ring*28)
    local supported=safe(q,34) and math.abs(q.X-center.X)+34<size[1]/2 and math.abs(q.Z-center.Z)+34<size[2]/2
    for _,p in ipairs(placed)do if (p-q).Magnitude<80 then supported=false end end
    local foot,hit=ground(q);supported=supported and hit~=false
    -- Check every grave footprint and the low wall, not just the cluster pivot.
    for _,d in ipairs({V(-23,0,-19),V(23,0,-19),V(-23,0,19),V(23,0,19),V(0,0,19)})do
     local p,ok=ground(q+d);if ok==false or math.abs(p.Y-foot.Y)>.65 then supported=false end
    end
    if supported then at=foot;break end
   end
   if at then break end
  end
  if at then
   local plot=Instance.new('Model');plot.Name='QuietBurialPlot';plot.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;plot.Parent=parent
   plot:SetAttribute('BurialPlotVersion',M.version);plot:SetAttribute('BurialPlotBand',band);plot:SetAttribute('GroundPosition',at)
   for i,x in ipairs({-14,0,14})do
    local p=ground(at+V(x,0,({0,3,-2})[i]));local grave=A.grave(plot,p,pal,i==2 and band%2==0 and 1 or 2)
    grave:SetAttribute('BurialPlotGrave',true);graves+=1
   end
   -- Unequal low courses break the flat horizon without a tall camera occluder.
   for i,x in ipairs({-14,0,14})do
    local height=({3,5,4})[(i+band-2)%3+1];local p=ground(at+V(x,0,-17))
    local wall=K.part(plot,'BurialGardenWall',V(13,height,3),p+V(0,height/2-.2,0),pal.rock,Enum.Material.Brick)
    wall:SetAttribute('EpicDetailSolid',true)
   end
   groups+=1;placed[#placed+1]=at
  end
 end
 parent:SetAttribute('BurialPlots',groups);parent:SetAttribute('BurialPlotGraves',graves)
 return groups,graves
end
return M
