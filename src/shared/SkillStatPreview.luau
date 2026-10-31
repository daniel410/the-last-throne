-- Read-only projection of normal server skill outcomes. Never awards or saves.
local Shared=game and game:GetService("ReplicatedStorage").Shared
local Growth=Shared and require(Shared.HeroProgression) or dofile("src/shared/HeroProgression.luau")
local Config=Shared and require(Shared.K0Config) or dofile("src/shared/K0Config.luau")
local Advanced=Shared and require(Shared.AdvancedSkills) or dofile("src/shared/AdvancedSkills.luau")
local Text=Shared and require(Shared.SkillStatText) or dofile("src/shared/SkillStatText.luau")
local Preview={}
function Preview.derived(classId,g,equipment)
	local d=Growth.derived(classId,g)
	equipment=equipment or {}
	d.health=d.health+(equipment.health or 0)
	d.armor=d.armor+(equipment.armor or 0)
	-- Keep precision until the final hit, as CombatService does.
	d.physicalPower=d.physicalPower*(1+(equipment.power or 0)/100)
	d.magicPower=d.magicPower*(1+(equipment.power or 0)/100)
	return d
end
-- Separate saved values from an unconfirmed point draft; never mutate either.
function Preview.breakdown(classId,g,equipment,draftGrowth)
 local hero=Growth.derived(classId,g)
 local current=Preview.derived(classId,g,equipment)
 local after=draftGrowth and Preview.derived(classId,draftGrowth,equipment)
 local rows={}
 for _,key in ipairs({'physicalPower','magicPower','armor','health','mana'}) do
  table.insert(rows,{key=key,hero=hero[key],gear=current[key]-hero[key],total=current[key],draft=after and after[key]})
 end
 return rows
end
function Preview.gearSources(heroId,items,catalog)
 local equipped={}
 for _,item in ipairs(items or {}) do
  local loc=item.location
  if loc and loc.kind=='equipped' and loc.heroId==heroId and catalog.items[item.definitionId] then equipped[loc.slot]=item end
 end
 local result={}
 for _,slot in ipairs(catalog.slots) do
  local item=equipped[slot]
  if item then
   local definition=catalog.items[item.definitionId]
   table.insert(result,{slot=slot,definitionId=item.definitionId,name=definition.name,stats=Growth.copy(definition.stats or {})})
  end
 end
 return result
end
function Preview.scalingText(classId,skill)
	local lines={}
	if skill.damage>0 then
		table.insert(lines,string.format(Text.Scaling,Growth.attackStat(classId,skill.magic)))
	elseif not skill.shield then table.insert(lines,Text.NoDamageScaling) end
	if skill.shield then table.insert(lines,skill.partyShield and Text.PartyBarrierScaling or Text.SelfBarrierScaling) end
	return table.concat(lines,"\n")
end
function Preview.statHint(classId,key,g)
	local t=Text.StatHints
	if key=="VIT" then return t.Vitality end
	if key=="INT" then
		if Growth.derived(classId,g).mana>0 then return t.Magic end
		return classId=="elf" and t.FutureMagic or t.UnusedMagic
	end
	if key==Growth.attackStat(classId,false) and classId~="mage" then return t.Physical end
	return key=="DEX" and t.UnusedDexterity or t.UnusedPhysical
end
function Preview.value(classId,index,g,equipment)
	local base=assert(Config.Skills[classId][index])
	local skill=Growth.skill(classId,index,base,g)
	local d=Preview.derived(classId,g,equipment)
	local power=skill.magic and d.magicPower or d.physicalPower
	local hit=skill.damage>0 and math.max(1,math.floor(power*skill.damage+.5)) or 0
	local hits=skill.pulses or skill.shotCount or 1
	return {skill=skill,damage=hit,hits=hits,totalDamage=hit*hits,barrier=skill.shield and d.health*skill.shield or nil}
end
local function number(value)
	return string.format("%.1f",value):gsub("%.0$", "")
end
local function comparison(label,before,after)
	if after==nil then return string.format(Text.Value,label,number(before)) end
	if math.abs(before-after)<.000001 then return string.format(Text.Unchanged,label,number(before)) end
	local delta=after-before
	return string.format(Text.Changed,label,number(before),number(after),(delta>0 and "+" or "")..number(delta))
end
function Preview.effectText(classId,index,g,equipment,draftGrowth)
	local v=Preview.value(classId,index,g,equipment)
	local after=draftGrowth and Preview.value(classId,index,draftGrowth,equipment)
	local lines={}
	if v.damage>0 then
		table.insert(lines,comparison(Text.Damage,v.damage,after and after.damage))
		if v.hits>1 then table.insert(lines,comparison(string.format(Text.TotalDamage,v.hits),v.totalDamage,after and after.totalDamage)) end
	end
	if v.barrier then
		table.insert(lines,comparison(Text.SelfBarrier,v.barrier,after and after.barrier))
		if v.skill.partyShield then table.insert(lines,string.format(Text.AllyBarrier,v.skill.shield*100)) end
	end
	if v.skill.provokeDuration then table.insert(lines,string.format(Text.Taunt,v.skill.provokeDuration)) end
	if v.skill.guardReduction then table.insert(lines,string.format(Text.Guard,v.skill.guardReduction*100,v.skill.guardDuration)) end
	return table.concat(lines,"\n")
end
function Preview.equipped(g,classId)
	local result={}
	for slot=1,Advanced.slotCount(g) do
		local index=g.skillSlots[slot]
		if index and index>0 and Advanced.unlocked(g,classId,index) and not Advanced.isUltimate(classId,index) then
			table.insert(result,{index=index,slot=slot})
		end
	end
	local ultimate=Advanced.ultimate(g,classId)
	if ultimate then table.insert(result,{index=ultimate,slot=0}) end
	return result
end
return Preview
