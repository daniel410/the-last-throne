local Content=game and require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent) or dofile('src/shared/DeepwoodContent.luau')
local A={edges={{'DW-01','DW-02'},{'DW-02','DW-03'},{'DW-03','DW-04'},{'DW-04','DW-05'},{'DW-05','DW-06'},{'DW-06','DW-07'},{'DW-03','DW-S1'},{'DW-03','DW-S2'},{'DW-05','DW-S3'}}}
function A.region(x,z)
 local best,distance
 for id,v in pairs(Content.zones) do local d=(x-v.center[1])^2+(z-v.center[3])^2;if not distance or d<distance or d==distance and id<best then best,distance=id,d end end
 return best
end
function A.allowed(journal,id) return journal and Content.zones[id] and journal.main>=Content.zones[id].requiresMain end
function A.cell(id,x,z)
 local v=Content.zones[id]
 return math.max(1,math.min(12,math.floor(((x-v.center[1])/v.size[1]+.5)*12)+1)),math.max(1,math.min(12,math.floor(((z-v.center[3])/v.size[2]+.5)*12)+1))
end
return A
