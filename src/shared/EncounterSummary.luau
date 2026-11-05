-- Display/audit projection over the same finite waves, stats and reward splitter.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local B=load('DeepwoodEncounterBalance')
local S={}
function S.mission(chapter,mode,players,version)
 local result={count=0,health=0,xp=0,gold=0,players=players or 1}
 for _,g in ipairs(chapter.goals)do
  local groups=B.encounterWaves(chapter,g,players)
  for _,group in ipairs(groups)do for index,spec in ipairs(group)do
   local hp,damage,level=B.unitStats(spec,players or 1,mode,version,index)
   local xp,gold=B.rewards(spec,mode,version)
   local key=B.isBoss(spec.kind)and 'boss'or 'normal';local row=result[key]
   if not row then row={levelMin=level,levelMax=level,hpMin=hp,hpMax=hp,damageMin=damage,damageMax=damage};result[key]=row end
   row.levelMin=math.min(row.levelMin,level);row.levelMax=math.max(row.levelMax,level)
   row.hpMin=math.min(row.hpMin,hp);row.hpMax=math.max(row.hpMax,hp)
   row.damageMin=math.min(row.damageMin,damage);row.damageMax=math.max(row.damageMax,damage)
   result.count=result.count+1;result.health=result.health+hp;result.xp=result.xp+xp;result.gold=result.gold+gold
  end end
 end
 return result
end
return S
