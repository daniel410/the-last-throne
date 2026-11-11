-- Ground structural feet, never the decorative bounding box or a roof ray hit.
local M={}
local V=Vector3.new
local feet={LodgeWall=true,LodgeBack=true,PorchPost=true,ButtressBase=true,TowerPlinth=true,PierCourse=true,
 GateUpperPier=true,GatePier=true,BrokenArchStump=true,FurnaceChimney=true,
 PipeSupport=true,MineTimber=true,CryptPlinth=true,FirePedestal=true,ForgePillar=true}
function M.samples(model)
 local result={}
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')and feet[p.Name]then
  -- PierCourse stacks three courses. Only the lowest course owns the foot.
  local lower=false
  if p.Name=='PierCourse'then for _,q in ipairs(p.Parent:GetChildren())do
   if q:IsA('BasePart')and q.Name==p.Name and q.Position.Y<p.Position.Y-1 and V(q.Position.X-p.Position.X,0,q.Position.Z-p.Position.Z).Magnitude<1 then lower=true;break end
  end end
  if not lower then
   for _,xz in ipairs({{0,0},{-.4,-.4},{-.4,.4},{.4,-.4},{.4,.4}})do
    table.insert(result,p.CFrame:PointToWorldSpace(V(p.Size.X*xz[1],-p.Size.Y/2,p.Size.Z*xz[2])))
   end
  end
 end end
 return result
end
function M.apply(model,params)
 local old=model:FindFirstChild('ArchitectureFoundations')
 if old then old:Destroy()end
 local folder=Instance.new('Folder');folder.Name='ArchitectureFoundations';folder.Parent=model
 local supports={}
 for _,p in ipairs(model:GetDescendants())do
  if p:IsA('BasePart')and feet[p.Name]then table.insert(supports,p)end
 end
 for _,p in ipairs(supports)do
  local bottom=p.Position.Y-p.Size.Y/2
  local lowest=math.huge
  for _,xz in ipairs({{0,0},{-.4,-.4},{-.4,.4},{.4,-.4},{.4,.4}})do
   local at=p.CFrame:PointToWorldSpace(V(p.Size.X*xz[1],-p.Size.Y/2,p.Size.Z*xz[2]))
   local hit=workspace:Raycast(at+V(0,256,0),V(0,-768,0),params)
   if hit then lowest=math.min(lowest,hit.Position.Y)end
  end
  -- Only exposed lowest courses need a footing; upper courses rest on masonry.
  local lower=false
  for _,q in ipairs(supports)do
   if q~=p and q.Position.Y<p.Position.Y-1 and V(q.Position.X-p.Position.X,0,q.Position.Z-p.Position.Z).Magnitude<1 then lower=true;break end
  end
  if not lower and lowest<math.huge and bottom>lowest+.25 then
   local h=bottom-lowest+.4
   local base=Instance.new('Part');base.Name='ArchitectureFooting'
   base.Size=V(p.Size.X,h,p.Size.Z);base.CFrame=CFrame.new(p.Position.X,bottom-h/2+.1,p.Position.Z)*p.CFrame.Rotation
   base.Color=p.Color;base.Material=Enum.Material.Slate
   base.Anchored=true;base.CanCollide=true;base.CanQuery=true;base.CanTouch=false
   base:SetAttribute('EpicDetailSolid',true);base:SetAttribute('TLTDecorative',true)
   base:SetAttribute('TLTSceneryDistance',p:GetAttribute('TLTSceneryDistance')or 900)
   base.Parent=folder
  end
 end
 model:SetAttribute('ArchitectureGrounded',#supports>0)
end
return M
