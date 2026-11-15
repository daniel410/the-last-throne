-- GW-01 search clearing: broken stone shoulders around the divided trail.
-- Native terrain only. No personal progress, new routes, or imported assets.
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local M={version=1}
local V=Vector3.new
function M.plan(center,size,safe)
 local cells={}
 for _,side in ipairs({-1,1})do
  for i=1,5 do
   local t=(i-3)/4
   -- Probe an open V silhouette; neighboring routes may reject either bank.
   local height=({72,104,38,86,58})[i]+(side==1 and (i%2==0 and 18 or -12)or 0)
   local width=112+(i%2)*16
   local depth=144
   local p=center+V(side*(size[1]/2+136+(i%2)*12),0,t*size[2])
   -- The complete rotated footprint plus two voxel widths must miss *all*
   -- clearings, expanded incident wings and overland/optional connections.
   local radius=math.sqrt(width*width+depth*depth)/2+8
   if not Bounds.region(p.X,p.Z,radius)and not Bounds.connection(p.X,p.Z,radius)then
    cells[#cells+1]={position=p,width=width,depth=depth,height=height,side=side,index=i,radius=radius,kind='Skyline'}
   end
  end
 end
 -- Short forest spurs give the unused clearing shoulders real relief. Full
 -- swept radii reserve combat leashes, NPCs, activity steps and return lanes.
 for i,at in ipairs({{3,-2},{-3,4},{-1,4},{1,4},{3,4},{0,2},{2,2}})do
  local p=center+V(at[1]*size[1]/8,0,at[2]*size[2]/10)
  local w,d=38,42;local radius=math.sqrt(w*w+d*d)/2+8
  local valid=safe(p,radius)and not Bounds.region(p.X,p.Z,radius,'GW-01')and not Bounds.connection(p.X,p.Z,radius)
  for _,old in ipairs(cells)do if (p-old.position).Magnitude<radius+old.radius+8 then valid=false end end
  if valid then
   cells[#cells+1]={position=p,width=w,depth=d,height=16+i%3*6,side=at[1]<0 and -1 or 1,index=i,radius=radius,kind='Shoulder'}
  end
 end
 return cells
end
function M.build(parent,center,size,safe)
 local old=parent:FindFirstChild('SearchRidges');if old then old:Destroy()end
 local root=Instance.new('Folder');root.Name='SearchRidges'
 root:SetAttribute('LandformVersion',M.version);root:SetAttribute('StoryZone','GW-01')
 root:SetAttribute('SourceKind','NewNativeTerrain');root.Parent=parent
 local cells=M.plan(center,size,safe)
 for _,cell in ipairs(cells)do
  local p=cell.position;local h=cell.height;local w=cell.width;local d=cell.depth
  local baseDepth=cell.kind=='Shoulder'and 16 or 48
  local cf=CFrame.new(p+V(0,(h-baseDepth)/2,0))*CFrame.Angles(0,cell.side*math.pi/2,0)
  -- Every layer meets the existing terrain envelope below the clearing.
  -- No subtraction: the deep persistent foundation and floor stay intact.
  workspace.Terrain:FillBlock(CFrame.new(p-V(0,30,0)),V(d,36,w),Enum.Material.Slate)
  workspace.Terrain:FillWedge(cf,V(w,h+baseDepth,d),Enum.Material.Rock)
  workspace.Terrain:FillWedge(cf*CFrame.new(0,6,4),V(w-16,h+baseDepth-8,d-16),Enum.Material.Grass)
  local marker=Instance.new('Folder');marker.Name=cell.kind..(cell.side<0 and 'West' or 'East')..cell.index
  marker:SetAttribute('Center',p);marker:SetAttribute('Height',h)
  marker:SetAttribute('FootprintRadius',cell.radius);marker.Parent=root
  marker:SetAttribute('LandformKind',cell.kind)
  task.wait()
 end
 root:SetAttribute('RidgeCount',#cells);root:SetAttribute('TerrainWrites',#cells*3)
 return root
end
return M
