-- HG-05: split weathered ridges frame the outer shield lines, without
-- depicting the personally destroyed devices or adding a bypass.
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local M={version=1}
local V=Vector3.new
function M.plan(c,size)
 local cells={}
 for _,side in ipairs({-1,1})do
  for i=1,5 do
   local r=({66,78,62,84,68})[i]
   local p=c+V(side*(size[1]/2+r+24),0,(i-3)*size[2]/4)
   local margin=r+8
   if not B.region(p.X,p.Z,margin)and not B.connection(p.X,p.Z,margin)then
    cells[#cells+1]={position=p,radius=r,height=({64,108,46,92,72})[i],side=side,index=i}
   end
  end
 end
 return cells
end
function M.build(parent,c,size)
 local root=Instance.new('Folder');root.Name='DefenseRidges';root.Parent=parent
 for _,cell in ipairs(M.plan(c,size))do
  local p,r,h=cell.position,cell.radius,cell.height
  workspace.Terrain:FillBall(p+V(0,h-r-12,0),r,Enum.Material.Slate)
  workspace.Terrain:FillBall(p+V(0,h-r,0),r-10,Enum.Material.Rock)
  local m=Instance.new('Folder');m.Name=(cell.side<0 and 'West'or 'East')..cell.index;m:SetAttribute('Center',p);m:SetAttribute('Radius',r);m:SetAttribute('Height',h);m.Parent=root
  task.wait()
 end
 return root
end
return M
