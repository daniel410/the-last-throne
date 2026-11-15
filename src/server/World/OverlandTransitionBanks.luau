-- The thawed pass between the mirror palace and the freight foundry.
-- Native rock shoulders; the existing server road remains the playable floor.
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local M={version=1}
local V=Vector3.new
function M.build(root,edge)
 if edge[1]~='FV-07' or edge[2]~='EC-01' then return end
 local aa,bb=Bounds.ends(edge);local a,b=V(table.unpack(aa)),V(table.unpack(bb))
 local d=b-a;local normal=V(-d.Z,0,d.X).Unit
 local count=0
 for _,spec in ipairs({{.24,78,-56},{.51,84,-60},{.79,72,-50}})do
  for _,side in ipairs({-1,1})do
   local radius=spec[2];local at=a:Lerp(b,spec[1])+normal*side*172
   -- Include voxel interpolation margin; never enter a story wing or its ramp.
   if not Bounds.region(at.X,at.Z,radius+4)then
    local center=at+V(0,spec[3],0)
    -- Buried shoulder joins the rock to the road foundation; no floating islands.
    local foot=at-normal*side*40-V(0,48,0)
    workspace.Terrain:FillBlock(CFrame.lookAt(foot,foot+d),V(112,72,radius*2),Enum.Material.Rock)
    workspace.Terrain:FillBall(center,radius,Enum.Material.Rock)
    count+=1
   end
  end
  task.wait()
 end
 root:SetAttribute('TransitionBanksVersion',M.version)
 root:SetAttribute('TransitionBanksCount',count)
end
return M
