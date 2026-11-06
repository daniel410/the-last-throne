-- Edit/Server, isolated unpublished fixture. Verifies real checkpoint instances
-- against the SpawnService safety contract and real destination geometry.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated fixture only')
assert(not workspace:FindFirstChild('DeepwoodCampaign'),'Fresh fixture required')
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local report={checks=0,epics={},kind='REGIONAL_SPAWN_NATIVE'}
local function check(value,message)report.checks+=1;assert(value,message)end
for _,epic in ipairs({3,2,4,5,1})do
 local world=World.create(epic)
 local count=0
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Include
 params.FilterDescendantsInstances={world.terrain}
 params.RespectCanCollide=true
 for id,spawn in pairs(world.spawns)do
  count+=1
  check(spawn:IsA('SpawnLocation') and spawn:IsDescendantOf(workspace) and spawn.Enabled,'SpawnService checkpoint eligibility: '..id)
  local hit=workspace:Raycast(spawn.Position+Vector3.new(0,4,0),Vector3.new(0,-16,0),params)
  check(hit~=nil,'collidable destination floor: '..id)
 end
 check(count>=7,'all main checkpoints: '..epic)
 report.epics[tostring(epic)]=count
 world.folder:Destroy()
end
return game.HttpService:JSONEncode(report)
