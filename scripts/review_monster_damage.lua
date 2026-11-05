-- Deterministic stat review, not a combat/playtest simulation.
-- lua scripts/review_monster_damage.lua /tmp/tlt-monster-damage-review.json
local D=dofile('src/shared/Difficulty.luau')
local B=dofile('src/shared/DeepwoodEncounterBalance.luau')
local C=dofile('src/shared/CampaignContent.luau')
local G=dofile('src/shared/HeroProgression.luau')
local report={rulesVersion=D.version,comparisonVersion=2,rows={},hazards={},modes={},limits='Static unblocked single-hit damage. No gear, healing, dodge, block, enemy overlap, input or device acceptance.'}
local function encode(v)
 if type(v)=='string'then return '"'..v:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n')..'"' end
 if type(v)~='table'then return tostring(v)end
 local parts={};if #v>0 then for _,x in ipairs(v)do parts[#parts+1]=encode(x)end;return '['..table.concat(parts,',')..']'end
 local keys={};for k in pairs(v)do keys[#keys+1]=k end;table.sort(keys)
 for _,k in ipairs(keys)do parts[#parts+1]=encode(k)..':'..encode(v[k])end
 return '{'..table.concat(parts,',')..'}'
end
local seen={}
for _,c in ipairs(C.chapters)do for _,goal in ipairs(c.goals)do
 for _,mode in ipairs(D.order)do for party=1,4 do
  for _,group in ipairs(B.encounterWaves(c,goal,party))do for index,spec in ipairs(group)do
   local hp,after,effective,elite=B.unitStats(spec,party,mode,nil,index)
   local oldHP,before=B.unitStats(spec,party,mode,2,index)
   local key=table.concat({c.epic or 1,spec.kind,spec.level,D.entry(c),mode,party,elite or 'Normal'},':')
   if not seen[key]then seen[key]=true
    local boss=B.isBoss(spec.kind)
    local row={epic=c.epic or 1,kind=spec.kind,boss=boss,elite=elite or 'Normal',sampleMission=c.id,sampleGoal=goal.id,authoredLevel=spec.level,enemyLevel=effective,party=party,mode=mode,before=before,after=after,hp=hp,previousHP=oldHP,heroes={}}
    for _,classId in ipairs({'knight','dwarf','elf','mage'})do
     local heroLevel=math.min(80,math.max(D.entry(c),D.modes[mode].level))
     local g=G.new(heroLevel)
     local zero=G.derived(classId,g)
     g.stats.VIT=heroLevel-1 -- 25% of the legal stat budget.
     local vit=G.derived(classId,g)
     row.heroes[classId]={level=heroLevel,hp=zero.health,hitsBefore=math.ceil(zero.health/before),hitsAfter=math.ceil(zero.health/after),vitPoints=g.stats.VIT,vitHP=vit.health,vitArmor=vit.armor,vitHitsAfter=math.ceil(vit.health/math.max(1,after-vit.armor))}
    end
    report.rows[#report.rows+1]=row
   end
  end end
 end end
end end
for _,mode in ipairs(D.order)do
 local old,new=D.mode(mode,2),D.mode(mode)
 report.modes[#report.modes+1]={mode=mode,oldDamage=old.damage,newDamage=new.damage,oldBossDamage=old.bossDamage,newBossDamage=new.bossDamage,levelShift=new.levelShift,minimumLevel=new.level}
 report.hazards[#report.hazards+1]={mode=mode,before=math.floor(32*old.damage+.5),after=math.floor(32*new.damage+.5),armorApplied=false}
end
local content=encode(report)..'\n'
if arg[1]then local f=assert(io.open(arg[1],'w'));f:write(content);f:close()else io.write(content)end
