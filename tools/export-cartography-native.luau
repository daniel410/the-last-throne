-- Disposable offline scene only. Query flags are changed for the bake, never at runtime.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated cartography bake only')
local world=require(game.ServerScriptService.Server.World.CampaignWorld).create()
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local visible={workspace.Terrain}
local function category(p)
 local name=p.Name:lower();local path=p:GetFullName():lower()
 if name:find('route') or name:find('path') or name:find('track') or name:find('landing') or name:find('ramp') then return 2 end
 if name:find('lava') or name:find('furnacecore') then return 7 end
 if name:find('water') or name:find('coolantchannel') or p.Material==Enum.Material.Water then return 6 end
 if name:find('canopy') or name:find('bough') or name:find('tree') or name:find('leaf') or name:find('foliage') or path:find('foresttree') or path:find('forestlandmark') then return 4 end
 if name:find('ground') or name:find('support_') or name:find('bedrock') or name:find('embankment') then return 1 end
 if path:find('architecture') or name:find('roof') or name:find('wall') or name:find('pillar') or name:find('lintel') or name:find('tower') or name:find('throne') then return 5 end
 if name:find('rock') or name:find('cliff') or name:find('spire') then return 3 end
 if path:find('authoredvista') and p.Size.Y>3 then return 5 end
 if p.Size.Y>4 and p.Size.X*p.Size.Z>45 then return 8 end
 return 1
end
for _,p in ipairs(world.folder:GetDescendants())do
 if p:IsA('BasePart')and p.Transparency<.5 and not p:FindFirstAncestor('NPCActors') and not p:FindFirstAncestor('Objectives') and not p:IsA('SpawnLocation')then
  p.CanQuery=true;table.insert(visible,p)
 end
end
local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=visible
local result={resolution=40,zones={}}
local ids={};for id in pairs(Content.zones)do table.insert(ids,id)end;table.sort(ids)
for _,id in ipairs(ids)do
 local z=Content.zones[id];local pixels={};local n=result.resolution
 for y=1,n do for x=1,n do
  local at=Vector3.new(z.center[1]+((x-.5)/n-.5)*z.size[1],z.center[2]+500,z.center[3]+((y-.5)/n-.5)*z.size[2])
  local hit=workspace:Raycast(at,Vector3.new(0,-750,0),ray)
  pixels[(y-1)*n+x]=hit and (hit.Instance==workspace.Terrain and (hit.Material==Enum.Material.Water and 6 or hit.Position.Y>z.center[2]+14 and 3 or 1) or category(hit.Instance)) or 0
 end end
 local roads={}
 for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p.Transparency<.5 and (p.Name=='WornCurvedRoute' or p.Name=='ReturnLoop')then
  if math.abs(p.Position.X-z.center[1])<=z.size[1]/2 and math.abs(p.Position.Z-z.center[3])<=z.size[2]/2 then
   local a=p.CFrame:PointToWorldSpace(Vector3.new(0,0,-p.Size.Z/2));local b=p.CFrame:PointToWorldSpace(Vector3.new(0,0,p.Size.Z/2))
   table.insert(roads,{a.X,a.Z,b.X,b.Z,p.Size.X})
  end
 end end
 local landmark
 local art=world.folder:FindFirstChild('EpicWorldArt')
 if art then for _,site in ipairs(art:GetDescendants())do if site.Name==id and site:GetAttribute('Landmark')then landmark=site:GetAttribute('Landmark');break end end end
 local spawn=world.spawns[id].Position
 result.zones[id]={pixels=pixels,roads=roads,landmark=landmark,spawn={spawn.X,spawn.Z}}
 print('CARTOGRAPHY_DATA_ZONE '..id..' '..game.HttpService:JSONEncode(result.zones[id]))
 task.wait()
end
print('CARTOGRAPHY_COMPLETE '..result.resolution..' '..#ids)
