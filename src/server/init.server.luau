local world = require(script.World.TrainingField).create()
local lobby = require(script.World.LobbyWorld).create()
local spawnService = require(script.Spawn.SpawnService)
local heroSession = require(script.Lobby.HeroSessionService)
heroSession.start({
	lobbySpawn = lobby.spawn,
	tutorialSpawn = world.spawn,
	lobbyBounds = lobby.bounds,
	requestSpawn = spawnService.requestSpawn,
})
require(script.Cosmetics.KnightAppearance).start()
require(script.Cosmetics.HeroPalette).start()
require(script.Combat.CombatService).start(world.enemies, heroSession.getCombatContext)
spawnService.start(lobby.spawn, {
	onLifeStarted = heroSession.onLifeStarted,
	onReady = heroSession.onReady,
	onLifeEnded = heroSession.onLifeEnded,
})
