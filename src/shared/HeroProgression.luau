-- Pure hero growth. Starting resources are user decisions; growth coefficients
-- and mastery effects are trial balance. XP mirrors story-reward-budget.json.
local Advanced=game and require(game:GetService("ReplicatedStorage").Shared.AdvancedSkills) or dofile("src/shared/AdvancedSkills.luau")
local Growth={maxLevel=80,xpBase=100,xpPerLevel=25,statKeys={"STR","DEX","INT","VIT"}}
Growth.bases={
	knight={health=250,healthPerLevel=15,mana=0,stats={STR=12,DEX=6,INT=4,VIT=12}},
	dwarf={health=200,healthPerLevel=13,mana=0,stats={STR=11,DEX=7,INT=4,VIT=10}},
	elf={health=150,healthPerLevel=10,mana=0,stats={STR=6,DEX=12,INT=6,VIT=8}},
	mage={health=100,healthPerLevel=8,mana=100,stats={STR=4,DEX=6,INT=14,VIT=6}},
}
Growth.mastery={knight={.05,.04,0},elf={.05,.03,.04},dwarf={.05,.05,.04},mage={.04,.04,.03}}
function Growth.integer(n,lo,hi) return type(n)=="number" and n==n and n%1==0 and n>=lo and n<=hi end
function Growth.copy(t)
	if type(t)~="table" then return t end
	local n={}; for k,v in pairs(t) do n[k]=Growth.copy(v) end; return n
end
function Growth.xpToNext(level) return level<Growth.maxLevel and Growth.xpBase+Growth.xpPerLevel*(level-1) or 0 end
function Growth.new(level)
 local ranks={};for i=1,32 do ranks[i]=0 end
 return {version=3,revision=0,level=level or 1,xp=0,stats={STR=0,DEX=0,INT=0,VIT=0},
  mastery=ranks,skillSlots={1,2,3,0,0},rewardStream="",rewardSequence=0,branch="",stage=0,battleWins=0}
end
function Growth.upgrade(g)
 if type(g)~="table" then return g end
 local result=Growth.copy(g)
 if g.version==1 then
  result.version=2;result.branch="";result.stage=0;result.battleWins=0
  if type(result.mastery)=="table" then for i=4,29 do result.mastery[i]=0 end end
 end
 if result.version==2 then
  if type(result.mastery)=="table" then
   -- Version 2 never owned these indices. Reject ambiguous saved data.
   for i=30,32 do if result.mastery[i]~=nil then return result end end
   for i=30,32 do result.mastery[i]=0 end
  end
  local branch=Advanced.branches[result.branch]
  local classId=branch and branch.classId
  if classId and type(result.skillSlots)=="table" then
   for slot,index in pairs(result.skillSlots) do
    if type(index)=="number" and Advanced.isUltimate(classId,index) and Advanced.unlocked(result,classId,index) then result.skillSlots[slot]=0 end
   end
  end
  result.version=3
 end
 return result
end
function Growth.validate(g,classId)
 if type(g)=="table" and (g.version==1 or g.version==2) then g=Growth.upgrade(g) end
 if type(g)~="table" or g.version~=3 or not Growth.integer(g.revision,0,1e12) or not Growth.integer(g.level,1,80)
  or not Growth.integer(g.xp,0,math.max(0,Growth.xpToNext(g.level)-1)) or type(g.stats)~="table"
  or type(g.mastery)~="table" or type(g.skillSlots)~="table" or type(g.rewardStream)~="string" or #g.rewardStream>64
  or not Growth.integer(g.rewardSequence,0,1e12) or not Growth.integer(g.stage,0,4) or not Growth.integer(g.battleWins,0,1e12) then return false end
 local branch=Advanced.branches[g.branch]
 if g.stage==0 then if g.branch~="" then return false end
 elseif not branch or classId and branch.classId~=classId or g.level<g.stage*20 or g.battleWins<g.stage*3 then return false end
 local resolvedClass=classId or branch and branch.classId or "knight"
 local spent=0;for k in pairs(g.stats) do if k~="STR" and k~="DEX" and k~="INT" and k~="VIT" then return false end end
 for _,k in ipairs(Growth.statKeys) do if not Growth.integer(g.stats[k],0,316) then return false end;spent=spent+g.stats[k] end
 if spent>4*(g.level-1) then return false end
 local sp=0
 for k,v in pairs(g.mastery) do if not Growth.integer(k,1,32) or not Growth.integer(v,0,3) then return false end end
 for i=1,32 do
  if not Growth.integer(g.mastery[i],0,3) or g.mastery[i]>0 and not Advanced.unlocked(g,resolvedClass,i) then return false end
  sp=sp+g.mastery[i]
 end
 if sp>g.level-1 then return false end
 local seen={}
 for k,v in pairs(g.skillSlots) do if not Growth.integer(k,1,5) or not Growth.integer(v,0,32) then return false end end
 for i=1,5 do
  local v=g.skillSlots[i]
  if not Growth.integer(v,0,32) or i>Advanced.slotCount(g) and v~=0 or v>0 and (seen[v] or not Advanced.unlocked(g,resolvedClass,v) or Advanced.isUltimate(resolvedClass,v)) then return false end
  if v>0 then seen[v]=true end
 end
 return true
end
function Growth.points(g)
	local spent=0; for _,k in ipairs(Growth.statKeys) do spent=spent+g.stats[k] end
	local sp=0;for _,rank in ipairs(g.mastery) do sp=sp+rank end
	return 4*(g.level-1)-spent,(g.level-1)-sp
end
function Growth.derived(classId,g)
	local base=assert(Growth.bases[classId]); local total={}
	local manaBase=(classId=="elf" and g.branch=="magic_archer" and g.stage>=1) and 80 or base.mana
	local manaLevels=classId=="elf" and math.max(0,g.level-20)*3 or (g.level-1)*4
	for _,k in ipairs(Growth.statKeys) do total[k]=base.stats[k]+g.stats[k] end
	local physical=g.stats[classId=="elf" and "DEX" or "STR"]*2+(g.level-1)*3
	return {health=base.health+base.healthPerLevel*(g.level-1)+g.stats.VIT*10,
		mana=manaBase>0 and manaBase+manaLevels+g.stats.INT*3 or 0,
		physicalPower=100+physical,magicPower=100+(g.level-1)*3+g.stats.INT*2,
		armor=math.floor(g.stats.VIT/4),totalStats=total}
end
function Growth.skill(classId,index,base,g)
	local skill=Growth.copy(base); local rank=g.mastery[index] or 0
	skill.damage=skill.damage*(1+(Growth.mastery[classId][index] or .04)*rank)
	if index==1 and (classId=="knight" or classId=="dwarf") then skill.posture=skill.posture+(classId=="knight" and 3 or 2)*rank end
	if index==3 and classId=="knight" then skill.provokeDuration=skill.provokeDuration+.2*rank end
	if index==3 and classId=="mage" then skill.slowDuration=skill.slowDuration+.2*rank end
	if skill.shield and skill.form=="self" then skill.shield=skill.shield*(1+.04*rank) end
	skill.masteryRank=rank
	return skill
end
function Growth.apply(g,command,classId)
	g=Growth.upgrade(g)
	if not Growth.validate(g,classId) then return nil,"Incompatible" end
	local nextG=Growth.copy(g)
	if command.action=="AwardXP" then
		if type(command.stream)~="string" or #command.stream<1 or #command.stream>64 or not Growth.integer(command.sequence,1,1e12)
			or not Growth.integer(command.amount,1,1000000) then return nil,"InvalidRequest" end
		local old=g.rewardStream==command.stream and g.rewardSequence or 0
		if command.sequence<=old then return nextG,nil,true end
		if command.sequence~=old+1 then return nil,"Changed" end
		nextG.rewardStream,nextG.rewardSequence=command.stream,command.sequence
		if command.rewardKind=="Defeat" then nextG.battleWins=nextG.battleWins+1 end
		nextG.xp=nextG.xp+command.amount
		while nextG.level<80 and nextG.xp>=Growth.xpToNext(nextG.level) do
			nextG.xp=nextG.xp-Growth.xpToNext(nextG.level); nextG.level=nextG.level+1
		end
		if nextG.level==80 then nextG.xp=0 end
	elseif command.action=="AllocateStats" then
		if type(command.stats)~="table" then return nil,"InvalidRequest" end
		local cost=0; for k,v in pairs(command.stats) do
			if nextG.stats[k]==nil or not Growth.integer(v,0,316) then return nil,"InvalidRequest" end
			cost=cost+v; nextG.stats[k]=nextG.stats[k]+v
		end
		local points=Growth.points(g); if cost<=0 or cost>points then return nil,"NotEnoughStatPoints" end
	elseif command.action=="TrainSkill" then
		if not Growth.integer(command.skill,1,32) then return nil,"InvalidRequest" end
		if not Advanced.unlocked(g,classId or (Advanced.branches[g.branch] or {}).classId or "knight",command.skill) then return nil,"SkillLocked" end
		local _,points=Growth.points(g)
		if points<1 then return nil,"NotEnoughSkillPoints" end
		if nextG.mastery[command.skill]>=3 then return nil,"SkillMaxRank" end
		nextG.mastery[command.skill]=nextG.mastery[command.skill]+1
	elseif command.action=="SetSkillSlot" then
		if not Growth.integer(command.slot,1,Advanced.slotCount(g)) or not Growth.integer(command.skill,0,32) then return nil,"InvalidRequest" end
		if command.skill>0 and Advanced.isUltimate(classId or (Advanced.branches[g.branch] or {}).classId or "knight",command.skill) then return nil,"UltimateSeparate" end
		if command.skill>0 and not Advanced.unlocked(g,classId or (Advanced.branches[g.branch] or {}).classId or "knight",command.skill) then return nil,"SkillLocked" end
		if command.skill>0 then for i,v in ipairs(nextG.skillSlots) do if i~=command.slot and v==command.skill then nextG.skillSlots[i]=nextG.skillSlots[command.slot] end end end
		nextG.skillSlots[command.slot]=command.skill
	elseif command.action=="Advance" then
		local branch=Advanced.branches[command.branch]
		local stage=g.stage+1
		if not branch or branch.classId~=classId or command.stage~=stage or stage>4 or g.stage>0 and command.branch~=g.branch then return nil,"InvalidAdvancement" end
		if g.level<stage*20 then return nil,"LevelRequired" end
		if g.battleWins<stage*3 then return nil,"TrialRequired" end
		nextG.branch=command.branch;nextG.stage=stage
	else return nil,"InvalidRequest" end
	nextG.revision=nextG.revision+1
	if not Growth.validate(nextG,classId) then return nil,"InvalidRequest" end
	return nextG
end
return Growth
