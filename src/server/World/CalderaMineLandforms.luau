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
function M.build(parent,center,size)
 local root=Instance.new('Folder');root.Name='ExcavatedMineRim'
 root:SetAttribute('LandformVersion',M.version);root:SetAttribute('StoryZone','EC-03')
 root:SetAttribute('SourceKind','NewNativeTerrain');root.Parent=parent
 local cells=M.plan(center,size)
 for _,cell in ipairs(cells)do
  local p=cell.position;local h=cell.height
  -- A broad below-grade talus apron ties the excavated skyline into the floor.
  -- Both balls fit inside the original 96-stud reservation, including 8 studs
  -- of voxel clearance. No new ground is occupied beside the rescue facility.
  workspace.Terrain:FillBall(p-V(0,68,0),88,Enum.Material.Basalt)
  workspace.Terrain:FillBall(p+V(cell.side*12,-49,-24),54,Enum.Material.Basalt)
  -- Unequal overlapping masses replace identical isolated pillar silhouettes.
  workspace.Terrain:FillBall(p+V(0,h-68,0),68,Enum.Material.Basalt)
  workspace.Terrain:FillBall(p+V(cell.side*18,h*.62-58,26),58,Enum.Material.Basalt)
  workspace.Terrain:FillBall(p+V(-cell.side*14,h*.4-48,-30),48,Enum.Material.Basalt)
  local marker=Instance.new('Folder');marker.Name=(cell.side<0 and 'West'or 'East')..cell.index
  marker:SetAttribute('Center',p);marker:SetAttribute('Height',h);marker:SetAttribute('ApronHeight',20);marker:SetAttribute('FootprintRadius',cell.radius);marker.Parent=root
  task.wait()
 end
 root:SetAttribute('RimCount',#cells);root:SetAttribute('TerrainWrites',#cells*5)
 return root
end
return M
