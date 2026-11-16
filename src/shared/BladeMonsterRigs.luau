-- Source-space shoulders, and mesh-local edge sockets after Studio's Y-180 import.
local commander = {
	template = "dread_commander", folder = "BladeMonsterModels",
	parts = {"Body", "ArmL"}, weaponArm = "ArmL",
	pivots = {ArmL = {-.146, .658, .081}},
	socket = {tip = {.5, -.5, -.5}, base = {.13902, -.18620, -.21670}},
	groundPoints = {
		{-.40619,-.47756,.34358},{-.34430,-.49359,-.16800},{-.26417,-.49744,-.23264},
		{.27590,-.50000,-.30766},{.30000,-.49872,-.31165},{.38208,-.49487,-.25499},
		{.39772,-.49295,-.22466},{.31498,-.48590,.44414},{.00879,-.47885,.50000},{-.29218,-.48782,.40263},
	},
}

return {
	Veyr = commander,
	DreadCommander = commander,
	DeathKnight = {
		template = "death_knight", folder = "BladeMonsterModels",
		parts = {"Body", "ArmL", "LegL", "LegR"}, weaponArm = "ArmL",
		pivots = {ArmL = {-.215,.718,.071}, LegL = {-.188815,.307850,-.114931}, LegR = {.201129,.314521,.069266}},
		socket = {tip = {-.14410,-.5,-.45377}, base = {-.09686,-.19435,-.34188}},
	},
	EnragedWarlord = {
		template = "warlord-enraged", folder = "BladeMonsterModels",
		parts = {"Body", "ArmL", "ArmR"}, weaponArm = "ArmL",
		pivots = {ArmL = {-.339,.687,.034}, ArmR = {.231,.659,-.125}},
		socket = {tip = {-.22989,-.5,-.37895}, base = {-.10070,-.28713,-.21014}},
		groundPoints = {
			{-.40086,-.49412,.16667},{-.35964,-.49608,.04991},{-.31401,-.49542,-.00942},
			{.33366,-.49804,-.26083},{.47718,-.49281,-.24670},{.50000,-.49542,-.20245},
			{.43229,-.49804,.17420},{-.17344,-.49542,.40113},
		},
	},
}
