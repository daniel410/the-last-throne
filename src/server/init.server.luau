local world = require(script.World.TrainingField).create()
require(script.Cosmetics.KnightAppearance).start()
require(script.Combat.CombatService).start(world.enemies)
require(script.Spawn.SpawnService).start(world.spawn)
