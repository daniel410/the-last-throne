-- EC-03: a cold, excavated basalt rim around the miners' rescue clearing.
-- Only reserved unused terrain; no heat source or alternate mine entrance.
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local Areas=require(game.ReplicatedStorage.Shared.CampaignAreas)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local M={version=2}
local V=Vector3.new
function M.plan(center,size,safe)
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
 -- Broad, buried basalt spurs give the rescue clearing a quarry floor edge.
 -- Full lobe radius plus two terrain voxels; never reserve just the center.
 if safe then
  for _,band in ipairs({{-.36,-.34},{.36,-.34},{-.36,.34},{.36,.34}})do
   local anchor=center+V(band[1]*size[1],0,band[2]*size[2])
   local chosen
   for ring=0,5 do
    for k=0,(ring==0 and 0 or 11)do
     local a=k*math.pi/6
     local p=anchor+V(math.cos(a)*ring*18,0,math.sin(a)*ring*18)
     local radius=64
     local _,zone=Bounds.region(p.X,p.Z,-radius)
     local valid=zone=='EC-03'and safe(p,radius)
      and not Bounds.region(p.X,p.Z,radius,'EC-03')and not Bounds.connection(p.X,p.Z,radius)
     for _,area in ipairs(Content.zones['EC-03'].expansionAreas or {})do
      if Areas.contains(area,p.X,p.Z,radius+8)or Areas.contains(area.connector,p.X,p.Z,radius+8)then valid=false end
     end
     for _,old in ipairs(cells)do if (p-old.position).Magnitude<radius+old.radius+16 then valid=false end end
     if valid then chosen={position=p,radius=radius,height=18,side=band[1]<0 and -1 or 1,index=#cells+1,kind='FloorSpur'};break end
    end
    if chosen then break end
   end
   if chosen then cells[#cells+1]=chosen end
  end
 end
 return cells
end
function M.build(parent,center,size,safe)
 local root=Instance.new('Folder');root.Name='ExcavatedMineRim'
 root:SetAttribute('LandformVersion',M.version);root:SetAttribute('StoryZone','EC-03')
 root:SetAttribute('SourceKind','NewNativeTerrain');root.Parent=parent
 local cells=M.plan(center,size,safe)
 local spurs=0
 for _,cell in ipairs(cells)do
  local p=cell.position;local h=cell.height
  if cell.kind=='FloorSpur'then
   -- Below-grade overlap gives a continuous planted toe, not stacked boulders.
   workspace.Terrain:FillBall(p-V(0,20,0),38,Enum.Material.Basalt)
   workspace.Terrain:FillBall(p+V(cell.side*22,-16,10),28,Enum.Material.Basalt)
   workspace.Terrain:FillBall(p+V(-cell.side*20,-18,-14),24,Enum.Material.Basalt)
   spurs+=1
  else
  -- Unequal overlapping masses replace identical isolated pillar silhouettes.
  workspace.Terrain:FillBall(p+V(0,h-68,0),68,Enum.Material.Basalt)
  workspace.Terrain:FillBall(p+V(cell.side*18,h*.62-58,26),58,Enum.Material.Basalt)
  workspace.Terrain:FillBall(p+V(-cell.side*14,h*.4-48,-30),48,Enum.Material.Basalt)
  end
  local marker=Instance.new('Folder');marker.Name=(cell.kind or 'Rim')..(cell.side<0 and 'West'or 'East')..cell.index
  marker:SetAttribute('LandformKind',cell.kind or 'Rim')
  marker:SetAttribute('Center',p);marker:SetAttribute('Height',h);marker:SetAttribute('FootprintRadius',cell.radius);marker.Parent=root
  task.wait()
 end
 root:SetAttribute('RimCount',#cells-spurs);root:SetAttribute('FloorSpurCount',spurs);root:SetAttribute('TerrainWrites',#cells*3)
 return root
end
return M
