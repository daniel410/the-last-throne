local world = require(script.World.TrainingField).create()
local deepwood = require(script.World.DeepwoodWorld).create()
local story = require(script.Story.DeepwoodService)
local lobby = require(script.World.LobbyWorld).create()
local spawnService = require(script.Spawn.SpawnService)
local heroSession = require(script.Lobby.HeroSessionService)
local inventory = require(script.Inventory.InventoryService)
local combat = require(script.Combat.CombatService)
local chest, prompt = require(script.World.StorageChest).create(lobby)
local outpostChest,outpostPrompt=require(script.World.StorageChest).create({folder=deepwood.folder,origin=deepwood.positions['DW-03']+Vector3.new(-55,0,-10)})
outpostChest.Parent.Name='DeepwoodAccountStorage';outpostPrompt.ObjectText='Elder Tree Storage'
inventory.start({chests={chest,outpostChest},prompts={prompt,outpostPrompt},heroSession = heroSession, combat = combat, chest = chest, prompt = prompt})
heroSession.start({
	inventory = inventory,
	lobbySpawn = lobby.spawn,
	tutorialSpawn = deepwood.spawns["DW-01"],
 tutorialDestination = story.destination,
	lobbyBounds = lobby.bounds,
 outpostBounds={center=deepwood.positions['DW-03'],size=Vector3.new(220,24,200)},
	requestSpawn = spawnService.requestSpawn,
})
require(script.Cosmetics.KnightAppearance).start()
require(script.Cosmetics.HeroPalette).start()
combat.start(world.enemies, heroSession.getCombatContext, inventory.awardXP)
story.start({world=deepwood,enemies=world.enemies,inventory=inventory,heroSession=heroSession,combat=combat})
spawnService.start(lobby.spawn, {
 resolveDestination=function(player,previous)
  local phase=player:GetAttribute('K0SessionPhase')
  local h=heroSession.getActiveHero(player)
  if h and (phase=='Respawning' or phase=='LoadingTutorial' or phase=='Tutorial') then return story.destination(player,h.heroId) end
  return previous
 end,
	onLifeStarted = heroSession.onLifeStarted,
	onReady = heroSession.onReady,
	onLifeEnded = heroSession.onLifeEnded,
})
