-- Definition-owned optional effects. Never read rolled values from item instances.
local Shared=game and game:GetService('ReplicatedStorage').Shared
local Text=Shared and require(Shared.EquipmentEffectText)or dofile('src/shared/EquipmentEffectText.luau')
local Config=Shared and require(Shared.K0Config)or dofile('src/shared/K0Config.luau')
local E={version=1,maxDamageBonus=1,maxReduction=.5,maxPerItem=4}
local allowed={damage=true,physical_damage=true,magic_damage=true,basic_damage=true,skill_damage=true,damage_reduction=true}
local skillNames={}
for _,skills in pairs(Config.Skills)do for _,skill in ipairs(skills)do skillNames[skill.id]=skill.name end end
local function valid(effect)
 if type(effect)~='table' or not allowed[effect.id]or type(effect.value)~='number'
  or effect.value~=effect.value or effect.value<=0 or effect.value>1 then return false end
 for key in pairs(effect)do if key~='id'and key~='value'and key~='skillId'then return false end end
 return effect.skillId==nil or effect.id=='skill_damage'and skillNames[effect.skillId]~=nil
end
function E.validateDefinition(def)
 if def.specialEffects==nil then return true end
 if not def.slot or type(def.specialEffects)~='table'then return false end
 local count=0;local seen={}
 for index,effect in pairs(def.specialEffects)do
  if type(index)~='number'or index%1~=0 or index<1 or index>E.maxPerItem or not valid(effect)then return false end
  local key=effect.id..':'..(effect.skillId or '')
  if seen[key]then return false end;seen[key]=true;count=count+1
 end
 return count==#def.specialEffects
end
function E.fromDefinition(def)
 local effects={}
 if not def or def.deleted or not E.validateDefinition(def)then return effects end
 for _,effect in ipairs(def.specialEffects or {})do
  effects[#effects+1]={id=effect.id,value=effect.value,skillId=effect.skillId}
 end
 return effects
end
-- Shared by the authoritative inventory reducer and read-only replacement preview.
function E.collect(items,heroId,catalog,excludeSlot,selected)
 local effects={}
 local function append(def)for _,effect in ipairs(E.fromDefinition(def))do effects[#effects+1]=effect end end
 for _,item in pairs(items or {})do
  local loc=item.location
  if loc and loc.kind=='equipped'and loc.heroId==heroId and loc.slot~=excludeSlot then append(catalog.items[item.definitionId])end
 end
 if selected then append(selected)end
 return effects
end
function E.damageMultiplier(effects,magic,isSkill,skillId)
 local bonus=0
 for _,effect in ipairs(effects or {})do if valid(effect)then
  local id=effect.id
  if id=='damage'or id=='physical_damage'and not magic or id=='magic_damage'and magic
   or id=='basic_damage'and not isSkill
   or id=='skill_damage'and isSkill and (not effect.skillId or effect.skillId==skillId)then bonus=bonus+effect.value end
 end end
 return 1+math.min(E.maxDamageBonus,bonus)
end
function E.incomingMultiplier(effects)
 local reduction=0
 for _,effect in ipairs(effects or {})do if valid(effect)and effect.id=='damage_reduction'then reduction=reduction+effect.value end end
 return 1-math.min(E.maxReduction,reduction)
end
local function number(v)return string.format('%.2f',v):gsub('0+$',''):gsub('%.$','')end
function E.label(effect)
 return effect.skillId and (skillNames[effect.skillId]..' damage')or Text.Labels[effect.id]
end
function E.text(def)
 local lines={};for _,effect in ipairs(E.fromDefinition(def))do lines[#lines+1]=string.format(Text.Bonus,E.label(effect),number(effect.value*100))end
 return #lines>0 and Text.Title..'\n'..table.concat(lines,'\n')or ''
end
function E.comparison(before,after)
 local values={};local keys={}
 for side,effects in ipairs({before,after})do for _,effect in ipairs(effects or {})do if valid(effect)then
  local key=effect.id..':'..(effect.skillId or '')
  if not values[key]then values[key]={effect=effect,0,0};keys[#keys+1]=key end
  values[key][side]=values[key][side]+effect.value
 end end end
 table.sort(keys);local lines={}
 for _,key in ipairs(keys)do local v=values[key];local cap=v.effect.id=='damage_reduction'and E.maxReduction or E.maxDamageBonus
  local a,b=math.min(cap,v[1])*100,math.min(cap,v[2])*100
  lines[#lines+1]=string.format(Text.Comparison,E.label(v.effect),number(a),number(b),(b-a>=0 and '+'or '')..number(b-a))
 end
 return table.concat(lines,'\n')
end
return E
