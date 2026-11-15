-- Generated Mixamo dwarf packs; split for Studio source limits.
local skills=require(script.Parent.K0DwarfMixamoSkills)
skills.skills["dwarf.common.overhead"]=require(script.Parent.K0DwarfMixamoOverhead)
local basic=require(script.Parent.K0DwarfMixamoBasic)
-- Reuse owned, retargeted axe strokes. Do not mutate skill clip timing/curves;
-- K0MeleeMotion maps each basic's server contact to its authored contact.
local function basicStroke(id,turn,r6Turn)
 local clip=table.clone(skills.variants[id])
 clip.basicTurn=turn;clip.basicR6Turn=r6Turn
 clip.disableR6FollowAcross=true
 return clip
end
return {basic=basic,basics={basic,basicStroke("dwarf.mixamo.backhand",35,-15),basicStroke("dwarf.mixamo.sweep",60,15)},
 skills=skills.skills,variants=skills.variants}
