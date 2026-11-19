assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local modules=game.ServerScriptService.Server.World
local timings={}
local methods={
 DeepwoodWorld={'create'},DeepwoodGroundedWorld={'create'},DeepwoodPlaces={'create'},
 StoryGateTemplates={'prepare'},CampaignExpansionWorld={'create','openEntrances'},
 CampaignCombatRouteWorld={'create','finish'},DeepwoodActivityWorld={'create'},
 EpicWorldArt={'create','connectOverland'},CampaignSceneryPlacement={'apply','openGalleries'},
 CampaignSceneryCollision={'apply'},DeepwoodConceptArt={'finish'},RegionalConceptArt={'finish'},
 CampaignSurfaceFinish={'apply'},CampaignQuestSetpieces={'create'},CampaignRouteClearance={'apply','retireBlockouts'},
}
for moduleName,list in pairs(methods)do
 local module=require(modules[moduleName])
 for _,name in ipairs(list)do
  local original=module[name]
  if original then
   module[name]=function(...)
    local start=os.clock()
    local result=table.pack(original(...))
    local key=moduleName..'.'..name
    local sample=timings[key] or {seconds=0,calls=0}
    sample.seconds+=os.clock()-start;sample.calls+=1;timings[key]=sample
    return table.unpack(result,1,result.n)
   end
  end
 end
end
local preparation=require(modules.CampaignPreparation)
local world=preparation.new('ColdProfile')
local heartbeat=game:GetService('RunService').Heartbeat
local peak,frames,long=0,0,0
local conn=heartbeat:Connect(function(dt)
 frames+=1;peak=math.max(peak,dt);if dt>.1 then long+=1 end
end)
local t=os.clock()
preparation.prepare(1,world)
local time=os.clock()-t
task.wait();conn:Disconnect()
print('COLD_PROFILE '..game.HttpService:JSONEncode({total=time,frames=frames,peak=peak,long=long,breakdown=timings,instances=#world.folder:GetDescendants()}))
local entries={}
local relocated=0
for _,part in ipairs(world.folder:GetDescendants())do
 if part:IsA('BasePart')then
  if part:GetAttribute('RouteClearanceOriginalPosition')then relocated+=1 end
  table.insert(entries,part:GetFullName()..'|'..tostring(part.CFrame)..'|'..tostring(part.Size)..'|'..tostring(part.CanCollide)..'|'..tostring(part.CanQuery)..'|'..tostring(part.CanTouch))
 end
end
table.sort(entries)
local hash=5381
for _,entry in ipairs(entries)do
 for i=1,#entry do hash=(hash*33+string.byte(entry,i))%4294967296 end
end
print('COLD_FINGERPRINT '..game.HttpService:JSONEncode({hash=hash,parts=#entries,relocated=relocated}))
local content=require(game.ReplicatedStorage.Shared.CampaignContent)
local zones={}
for id,zone in pairs(content.zones)do if zone.epic==1 or id:sub(1,2)=='DW'then table.insert(zones,id)end end
table.sort(zones)
local terrainHash,cells=5381,0
for _,id in ipairs(zones)do
 local zone=content.zones[id]
 local center=Vector3.new(table.unpack(zone.center))
 for _,x in ipairs({-.4,0,.4})do for _,z in ipairs({-.4,0,.4})do
  local p=center+Vector3.new(x*zone.size[1],0,z*zone.size[2])
  local r=Region3.new(p-Vector3.new(12,16,12),p+Vector3.new(12,24,12)):ExpandToGrid(4)
  local materials,occupancies=workspace.Terrain:ReadVoxels(r,4)
  for i,column in ipairs(materials)do for j,row in ipairs(column)do for k,material in ipairs(row)do
   terrainHash=(terrainHash*33+material.Value*1024+math.floor(occupancies[i][j][k]*1023+.5))%4294967296
   cells+=1
  end end end
 end end
end
print('TERRAIN_FINGERPRINT '..game.HttpService:JSONEncode({hash=terrainHash,cells=cells}))
