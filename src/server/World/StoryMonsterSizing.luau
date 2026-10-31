-- Visual heights are TD template TargetHeight times the multiplier below.
-- Keep combat rigs modest for the regional monsters; the Training Field's
-- Orc and Ogre use their exact rig and visual scales as the reference.
local sizes = {
 Orc = {1.65, 1.5},
 Ogre = {2.475, 2.475 / 1.45},
 KingOgre = {1.8, 1.3},
 IceWolf = {1, 1.25}, IceBear = {1, 1.25},
 IceElf = {1, 1.25}, IceTroll = {1, 1.5}, IceGolem = {1, 1.5},
 IceTrollKing = {1, 1.4}, KingIceBear = {1, 1.4},
 KingIceGolem = {1, 1.55}, QueenIceElf = {1, 1.3},
 AncientGlacierKing = {1, 1.3},
 Imp = {1, 1.25}, LavaSlime = {1, 1.25}, Golem = {1, 1.45},
 MagmaWorm = {1, 1.3}, VolcanoShaman = {1, 1.3},
 MagmaImp = {1, 1.3}, MagmaGolem = {1, 1.5},
 InfernoOverlord = {1, 1.4}, CalderaTitan = {1, 1.3},
 KingVolcanoShaman = {1, 1.3},
}

local Sizing = {}
function Sizing.forStory(kind, boss)
 local size = sizes[kind]
 if size then return size[1], size[2] end
 return 1, boss and 1.3 or 1
end
return Sizing
