-- HG-05 retained burial terraces behind the two outer shield devices.
-- Prototype only: not invoked by the production world generator.
local K=require(script.Parent.EpicEnvironmentKit)
local A=require(script.Parent.EpicArchitecture)
local M={version=1}
local V=Vector3.new
function M.build(world,safe)
 local root=Instance.new('Model');root.Name='RoyalBurialTerraces';root.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local pal=K.palette.HauntedGraveyard
 local zone=world.folder.EpicWorldArt.EpicWorldArt_5['HG-05']
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
 overlap.FilterDescendantsInstances={zone};overlap.RespectCanCollide=true
 local retired={}
 for _,x in ipairs({150,270,390})do
  for _,part in ipairs(workspace:GetPartBoundsInBox(CFrame.new(x,197,-17520),V(105,18,81),overlap))do
   if part.Position.Y+part.Size.Y/2>188.5 then
    local m=part.Parent
    if m.Name=='Sarcophagus' or m.Name=='CarvedHeadstone' then retired[m]=true end
   end
  end
 end
 for m in pairs(retired)do m:Destroy()end
 -- Re-seat the existing story architecture as whole assemblies on the new courts.
 for _,entry in ipairs({{'TwinShieldPylons',270},{'KeeperMemorialCluster',150}})do
  local m=zone.RegionalConcept:FindFirstChild(entry[1]);assert(m,'Missing original architecture')
  local cf,sz=m:GetBoundingBox();local target=V(entry[2],206.05+sz.Y/2,-17520)
  m:PivotTo(m:GetPivot()+(target-cf.Position));m.Parent=root
 end
 for _,m in ipairs(zone.RegionalConcept:GetChildren())do if m.Name=='KeeperMemorialCluster'then m:Destroy()end end
 for i,x in ipairs({150,270,390})do
  local p=V(x,188,-17520)
  assert(safe(p,66),'Terrace reservation overlap')
  local m=Instance.new('Model');m.Name='RetainedBurialCourt'..i;m.Parent=root
  for tier=1,3 do
   local size=V(104-(tier-1)*12,6,80-(tier-1)*12)
   local y=(tier-1)*6+3-.25
   local block=K.part(m,'RetainingCourse',size,p+V(0,y,0),pal.rock:Lerp(pal.ground,tier*.08),Enum.Material.Brick)
   block.CanCollide=true;block.CanQuery=true;block:SetAttribute('EpicDetailSolid',true)
   local cap=K.part(m,'WeatheredCoping',V(size.X+.4,.6,size.Z+.4),p+V(0,tier*6-.25,0),pal.trim,Enum.Material.Slate)
   cap.CanCollide=true;cap.CanQuery=true
  end
  for _,dx in ipairs(i==3 and {-25,0,25} or {-28})do A.grave(m,p+V(dx,18.05,0),pal,dx==0 and 1 or 2)end
  m:SetAttribute('AssetOrigin','Derived:EpicArchitecture.grave/EpicEnvironmentKit.palette.HauntedGraveyard')
 end
 root:SetAttribute('StoryZone','HG-05');root:SetAttribute('PrototypeVersion',M.version);root.Parent=world.folder
 return root
end
return M
