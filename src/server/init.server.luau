local world = require(script.World.TrainingField).create()
local lobby = require(script.World.LobbyWorld).create()
local spawnService = require(script.Spawn.SpawnService)
local heroSession = require(script.Lobby.HeroSessionService)
local inventory = require(script.Inventory.InventoryService)
local combat = require(script.Combat.CombatService)
local chest, prompt = require(script.World.StorageChest).create(lobby)
inventory.start({heroSession = heroSession, combat = combat, chest = chest, prompt = prompt})
heroSession.start({
	inventory = inventory,
	lobbySpawn = lobby.spawn,
	tutorialSpawn = world.spawn,
	lobbyBounds = lobby.bounds,
	requestSpawn = spawnService.requestSpawn,
})
require(script.Cosmetics.KnightAppearance).start()
require(script.Cosmetics.HeroPalette).start()
combat.start(world.enemies, heroSession.getCombatContext)
spawnService.start(lobby.spawn, {
	onLifeStarted = heroSession.onLifeStarted,
	onReady = heroSession.onReady,
	onLifeEnded = heroSession.onLifeEnded,
})
