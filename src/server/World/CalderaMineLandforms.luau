-- EC-03: a cold, excavated basalt rim around the miners' rescue clearing.
-- Only unused exterior terrain; no heat source or alternate mine entrance.
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local M={version=2}
local V=Vector3.new
function M.plan(center,size)
 local cells={}
 for _,side in ipairs({-1,1})do for i=1,5 do
  for offset=160,320,40 do
  local p=center+V(side*(size[1]/2+offset),0,(i-3)*size[2]/4)
  local radius=96 -- encloses every lobe, 6.37 studs of horizontal clearance
  local valid=not Bounds.region(p.X,p.Z,radius)and not Bounds.connection(p.X,p.Z,radius)
  for _,old in ipairs(cells)do if (p-old.position).Magnitude<140 then valid=false end end
  if valid then cells[#cells+1]={position=p,radius=radius,height=({66,98,54,86,70})[i],side=side,index=i};break end
  end
 end end
 return cells
end
-- Three diminishing working benches keep a readable excavated profile.
-- Cylinder height runs along local X; rotate it upright onto world Y.
function M.benches(cell)
 local h=cell.height
 local rows={}
 local bottom=-12
 for tier,top in ipairs({h*.30,h*.64,h})do
  local radius=({68,51,34})[tier]
  local offset=V(cell.side*(tier-1)*9,0,(tier-1)*-7)
  rows[tier]={cframe=CFrame.new(cell.position+offset+V(0,(bottom+top)/2,0))*CFrame.Angles(0,0,math.pi/2),
   height=top-bottom,radius=radius,top=top,offset=offset}
  bottom=top-4 -- one voxel of overlap avoids cracks between the tiers
 end
 return rows
end
function M.build(parent,center,size)
 local root=Instance.new('Folder');root.Name='ExcavatedMineRim'
 root:SetAttribute('LandformVersion',M.version);root:SetAttribute('StoryZone','EC-03')
 root:SetAttribute('SourceKind','NewNativeTerrain');root.Parent=parent
 local cells=M.plan(center,size)
 for _,cell in ipairs(cells)do
  local p=cell.position;local h=cell.height
  -- Broad quarry shelves replace the bulbous, uninterrupted hill profile.
  -- All three volumes remain within the existing reserved 96-stud envelope.
  for _,bench in ipairs(M.benches(cell))do
   workspace.Terrain:FillCylinder(bench.cframe,bench.height,bench.radius,Enum.Material.Basalt)
  end
  local marker=Instance.new('Folder');marker.Name=(cell.side<0 and 'West'or 'East')..cell.index
  marker:SetAttribute('Center',p);marker:SetAttribute('Height',h);marker:SetAttribute('FootprintRadius',cell.radius);marker.Parent=root
  task.wait()
 end
 root:SetAttribute('RimCount',#cells);root:SetAttribute('TerrainWrites',#cells*3)
 return root
end
return M
