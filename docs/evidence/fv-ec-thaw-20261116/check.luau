local W=assert(_G.PassWorld)
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
local V=Vector3.new
local a0,b0=B.ends(C.overlandLinks[3]);local a,b=V(table.unpack(a0)),V(table.unpack(b0));local d=(b-a).Unit;local normal=V(-d.Z,0,d.X)
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={W.folder,workspace.Terrain}
local R={samples=0,missing=0,raised=0,blocked=0,banks=W.folder.OverlandRoads['FV-07_EC-01']:GetAttribute('TransitionBanksCount')}
for i=0,math.ceil((b-a).Magnitude/4)do for offset=-44,44,4 do
 local at=a:Lerp(b,i/math.ceil((b-a).Magnitude/4))+normal*offset
 local floor=workspace:Raycast(at+V(0,8,0),V(0,-20,0),ray)
 R.samples+=1
 if not floor then R.missing+=1 elseif math.abs(floor.Position.Y-at.Y)>.6 then R.raised+=1 end
 local hit=workspace:Blockcast(CFrame.new(at+V(0,3.5,0)),V(3,5,3),d*4,ray)
 if hit then R.blocked+=1 end
end end
assert(R.banks==4 and R.missing==0 and R.raised==0 and R.blocked==0,game.HttpService:JSONEncode(R))
_G.PassWidth=R
return R
