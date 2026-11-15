-- HG-03: weathered stone banks frame Lumi's maintenance approach.
-- Additive native terrain; story access, authoritative floors and TD assets stay independent.
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local M={version=1};local V=Vector3.new
function M.plan(center,size,safe)
 local cells={}
 local function add(p,r,h,kind,index)
  local margin=r+8 -- two voxel widths beyond every terrain write
  if Bounds.region(p.X,p.Z,margin,kind=='Shoulder'and 'HG-03'or nil)or Bounds.connection(p.X,p.Z,margin)then return end
  if kind=='Shoulder'and not safe(p,margin)then return end
  for _,old in ipairs(cells)do if (p-old.position).Magnitude<margin+old.radius+16 then return end end
  cells[#cells+1]={position=p,radius=margin,ballRadius=r,height=h,kind=kind,index=index}
 end
 -- Interrupted banks, never an unbroken wall or an alternate bypass.
 for _,side in ipairs({-1,1})do for i=1,4 do
  local p=center+V(side*(size[1]/2+154),0,(i-2.5)*size[2]/4)
  add(p,({62,70,58,66})[i],({48,66,42,58})[i],'Skyline',(side<0 and 'West'or 'East')..i)
 end end
 -- Small rounded shoulders leave the passage and encounter reservations flat.
 for _,at in ipairs({{-.35,-.32},{.35,-.32},{-.35,.32},{.35,.32},{-.30,0},{.30,0},{0,-.36},{0,.36}})do
  local n=0;for _,cell in ipairs(cells)do if cell.kind=='Shoulder'then n+=1 end end
  if n>=3 then break end
  add(center+V(at[1]*size[1],0,at[2]*size[2]),26,12,'Shoulder',tostring(n+1))
 end
 return cells
end
function M.build(parent,center,size,safe)
 local root=Instance.new('Folder');root.Name='PassageBanks'
 root:SetAttribute('LandformVersion',M.version);root:SetAttribute('StoryZone','HG-03')
 root:SetAttribute('SourceKind','NewNativeTerrain');root.Parent=parent
 local cells=M.plan(center,size,safe)
 for _,cell in ipairs(cells)do
  local p=cell.position;local r=cell.ballRadius;local h=cell.height
  -- Spherical caps meet the deep existing envelope, with exposed slate below weathered rock.
  workspace.Terrain:FillBall(p+V(0,h-r,0),r,Enum.Material.Slate)
  workspace.Terrain:FillBall(p+V(0,h-r+8,0),r-5,Enum.Material.Rock)
  local marker=Instance.new('Folder');marker.Name=cell.kind..cell.index
  marker:SetAttribute('Center',p);marker:SetAttribute('Height',h)
  marker:SetAttribute('FootprintRadius',cell.radius);marker:SetAttribute('BallRadius',r)
  marker:SetAttribute('LandformKind',cell.kind);marker.Parent=root
  task.wait()
 end
 root:SetAttribute('BankCount',#cells);root:SetAttribute('TerrainWrites',#cells*2)
 return root
end
return M
