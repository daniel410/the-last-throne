-- Authored in Blender MCP; load sampled tables only when a regional kind is used.
local C={["version"]=1,["samples"]=201,["fps"]=120,["impactPhase"]=0.62,["channels"]={"body","weapon","off","rightLeg","leftLeg"},["sourceSha256"]="981f27006f5108f0aa9dfb56812b0d44b12bb7ee2c003245553d06afde84c566"}
C.models={}
C.kinds={"Zombie","Skeleton","Ghoul","Mummy","Hellhound","SkeletonKnight","DeathKnight","Lich","LichSovereign","DreadCommander","Veyr"}
local sources={
 Zombie=script.Zombie,
 Skeleton=script.Skeleton,
 Ghoul=script.Ghoul,
 Mummy=script.Mummy,
 Hellhound=script.Hellhound,
 SkeletonKnight=script.SkeletonKnight,
 DeathKnight=script.DeathKnight,
 Lich=script.Lich,
 LichSovereign=script.LichSovereign,
 DreadCommander=script.DreadCommander,
 Veyr=script.Veyr,
}
function C.get(kind)
 local source=sources[kind]
 if not source then return nil end
 if not C.models[kind]then C.models[kind]=require(source)end
 return C.models[kind]
end
return C
