-- Run on the Server in an isolated local 0.68.x Lobby Play session.
local Http=game:GetService('HttpService')
local player=game.Players:GetPlayers()[1]
assert(player,'local Play player required')
local report={checks=0,elapsed={},epics={}}
local function check(ok,message)report.checks+=1;assert(ok,message)end
local Server=game.ServerScriptService.Server
check(workspace:GetAttribute('TLTServerRole')=='Lobby','lobby role')
check(not workspace:FindFirstChild('DeepwoodCampaign'),'no campaign during lobby startup')
check(not workspace:FindFirstChild('DeepwoodK0'),'no training/combat field during lobby startup')
check(workspace:GetAttribute('TLTCombatReady')~=true,'combat not started in lobby')
check(not game.ReplicatedStorage.Remotes:FindFirstChild('K0Action'),'no combat remote in lobby')
check(not game.ReplicatedStorage.Remotes:FindFirstChild('DeepwoodRequest'),'no story remote in lobby')
local hero=require(Server.Lobby.HeroSessionService)
local inventory=require(Server.Inventory.InventoryService)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
-- Native construction in a local test; admission/ownership is exercised by the
-- UI entry test, not bypassed or claimed by these direct world API checks.
local World=require(Server.World.CampaignWorld)
local world
local story=require(Server.Story.DeepwoodService)
local enemies=Instance.new("Folder");enemies.Name="StartupQaEnemies";enemies.Parent=workspace
for _,epic in ipairs({4,5,2,3,1})do
 local before={};for id in pairs(world and world.positions or {})do before[id]=true end
 local t=os.clock();world=World.create(epic,world);report.elapsed[tostring(epic)]=os.clock()-t
 if epic==4 then
  story.start({world=world,enemies=enemies,inventory=inventory,heroSession=hero,combat={setStoryDefeatHandler=function()end}})
 else story.refreshWorld()end
 check(world.folder:FindFirstChild('EpicWorldArt')~=nil,'existing art inspection root preserved')
 local added=0
 for id in pairs(world.spawns)do
  if not before[id]then check((Content.zones[id].epic or 1)==epic,'only selected epic generated: '..id);added+=1 end
 end
 check(added>=7,'all main zones exist')
 for id,spawn in pairs(world.spawns)do
  check(spawn:IsA('SpawnLocation') and spawn:IsDescendantOf(workspace) and spawn.Enabled,'SpawnService accepts checkpoint '..id)
 end
 for _,chapter in ipairs(Content.chapters)do if (chapter.epic or 1)==epic then
  for _,goal in ipairs(chapter.goals)do check(world.nodes[chapter.id..':'..goal.id]~=nil,'objective exists '..chapter.id..':'..goal.id)end
 end end
 local same=World.create(epic,world);check(same==world,'repeated entry reuses same world')
 local total=#world.folder:GetDescendants();World.create(epic,world);check(#world.folder:GetDescendants()==total,'no duplicate geometry')
 report.epics[tostring(epic)]={newZones=added,instances=total}
end
report.kind='BATTLE_STARTUP_NATIVE'
return Http:JSONEncode(report)
