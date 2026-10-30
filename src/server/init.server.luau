local Run=game:GetService('RunService')
local roleValue=game.ServerStorage:FindFirstChild('ServerRole')
local role=roleValue and roleValue.Value or 'Lobby'
workspace:SetAttribute('TLTServerRole',role)
local world=require(script.World.TrainingField).create()
local story=require(script.Story.DeepwoodService)
local spawnService=require(script.Spawn.SpawnService)
local heroSession=require(script.Lobby.HeroSessionService)
local inventory=require(script.Inventory.InventoryService)
local combat=require(script.Combat.CombatService)
local expedition=require(script.Network.ExpeditionService)
local deepwood,lobby,storyStarted
if role=='Battle' or Run:IsStudio() then deepwood=require(script.World.DeepwoodWorld).create() end
if role=='Lobby' then lobby=require(script.World.LobbyWorld).create()
else
 local sp=deepwood.spawns['DW-01'];lobby={spawn=sp,origin=sp.Position,bounds={center=sp.Position,size=Vector3.new(220,40,220)}}
end
local chests,prompts={},{}
if role=='Lobby' then
 local chest,prompt=require(script.World.StorageChest).create(lobby);table.insert(chests,chest);table.insert(prompts,prompt)
end
if deepwood then
 local chest,prompt=require(script.World.StorageChest).create({folder=deepwood.folder,origin=deepwood.positions['DW-03']+Vector3.new(-55,0,-10)})
 chest.Parent.Name='DeepwoodAccountStorage';prompt.ObjectText='Elder Tree Storage';table.insert(chests,chest);table.insert(prompts,prompt)
end
inventory.start({chests=chests,prompts=prompts,heroSession=heroSession,combat=combat,storyPending=story.hasPendingEvents})
local function previewWorld()
 if not deepwood then deepwood=require(script.World.DeepwoodWorld).create() end
 if not storyStarted then story.start({world=deepwood,enemies=world.enemies,inventory=inventory,heroSession=heroSession,combat=combat});storyStarted=true end
end
expedition.start({role=role,heroSession=heroSession,inventory=inventory,previewWorld=previewWorld})
heroSession.start({inventory=inventory,lobbySpawn=lobby.spawn,tutorialSpawn=deepwood and deepwood.spawns['DW-01'] or world.spawn,
 trainingSpawn=world.spawn,tutorialDestination=function(p,id) if deepwood then return story.destination(p,id) end;return world.spawn end,
 lobbyBounds=lobby.bounds,outpostBounds=deepwood and {center=deepwood.positions['DW-03'],size=Vector3.new(220,24,200)} or nil,
 requestSpawn=spawnService.requestSpawn,network=expedition})
require(script.Cosmetics.KnightAppearance).start()
require(script.Cosmetics.HeroPalette).start()
combat.start(world.enemies,heroSession.getCombatContext,inventory.awardXP)
if role=='Battle' or Run:IsStudio() then previewWorld() end
local merchant=role=='Lobby' and require(script.World.WeaponMerchant).create(lobby) or nil
require(script.Lobby.MerchantService).start({inventory=inventory,merchant=merchant})
spawnService.start(lobby.spawn,{
 resolveDestination=function(player,previous)
  local phase=player:GetAttribute('K0SessionPhase');local h=heroSession.getActiveHero(player)
  if h and (phase=='Respawning' or phase=='LoadingTutorial' or phase=='Tutorial') then return h.training and world.spawn or story.destination(player,h.heroId) end
  return previous
 end,onLifeStarted=heroSession.onLifeStarted,onReady=heroSession.onReady,onLifeEnded=heroSession.onLifeEnded,
})
