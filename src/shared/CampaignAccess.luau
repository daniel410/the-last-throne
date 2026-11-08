local Content=game and require(game:GetService('ReplicatedStorage').Shared.CampaignContent) or dofile('src/shared/CampaignContent.luau')
local Areas=game and require(game:GetService('ReplicatedStorage').Shared.CampaignAreas)or dofile('src/shared/CampaignAreas.luau')
local A={edges=Content.edges}
function A.region(x,z)
 for id,v in pairs(Content.zones)do if Areas.containsZone(v,x,z,0)then return id end end
 local best,distance
 for id,v in pairs(Content.zones) do local d=(x-v.center[1])^2+(z-v.center[3])^2;if not distance or d<distance or d==distance and id<best then best,distance=id,d end end
 return best
end
function A.allowed(journal,id) return journal and Content.zones[id] and Content.accessible(journal,Content.zones[id].requiresMain,Content.zones[id].legacyRequiresMain) end
function A.cell(id,x,z)
 local v=Content.zones[id]
 return math.max(1,math.min(12,math.floor(((x-v.center[1])/v.size[1]+.5)*12)+1)),math.max(1,math.min(12,math.floor(((z-v.center[3])/v.size[2]+.5)*12)+1))
end
return A
