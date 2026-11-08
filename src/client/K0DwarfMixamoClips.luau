-- Generated Mixamo dwarf packs; split for Studio source limits.
local skills=require(script.Parent.K0DwarfMixamoSkills)
skills.skills["dwarf.common.overhead"]=require(script.Parent.K0DwarfMixamoOverhead)
return {basic=require(script.Parent.K0DwarfMixamoBasic),skills=skills.skills,variants=skills.variants}
