local Enhance=game and require(game:GetService('ReplicatedStorage').Shared.Enhancement)or dofile('src/shared/Enhancement.luau')
-- Read-only current -> equipped-item replacement using the same combat formulas.
local Shared=game and game:GetService('ReplicatedStorage').Shared
local Preview=Shared and require(Shared.SkillStatPreview) or dofile('src/shared/SkillStatPreview.luau')
local Text=Shared and require(Shared.CombatStatText) or dofile('src/shared/CombatStatText.luau')
local Impact={}
local Slots=Shared and require(Shared.EquipmentSlotRules)or dofile('src/shared/EquipmentSlotRules.luau')
function Impact.compare(hero,items,selected,slot,catalog)
 local d=selected and catalog.items[selected.definitionId]
 if not hero or not hero.progression or not d or not d.slot then return nil,'Loading' end
 if d.classId and d.classId~=hero.baseClassId then return nil,'WrongClass' end
 local slotError
 slot,slotError=Slots.resolve(hero.heroId,items,d,catalog,slot or (selected.location and selected.location.kind=='equipped' and selected.location.slot or nil))
 if not slot then return nil,slotError end
 local before={power=0,armor=0,health=0,mana=0,dexterity=0};local current
 for _,item in ipairs(items or {}) do
  if item.location.kind=='equipped' and item.location.heroId==hero.heroId then
   local def=catalog.items[item.definitionId]
   if def then for key in pairs(before) do before[key]=before[key]+(Enhance.stats(def,item)[key] or 0) end end
   if item.location.slot==slot then current=Enhance.stats(def,item) end
  end
 end
 local after={}
 for key,value in pairs(before) do after[key]=value-((current or {})[key] or 0)+(Enhance.stats(d,selected)[key] or 0) end
 local a,b=Preview.derived(hero.baseClassId,hero.progression,before),Preview.derived(hero.baseClassId,hero.progression,after)
 local rows={}
 for _,key in ipairs({'physicalPower','magicPower','armor','health','mana'}) do
  table.insert(rows,{key=key,before=a[key],after=b[key],delta=b[key]-a[key]})
 end
 if (Enhance.stats(d,selected).dexterity or 0)>0 or (current and (current.dexterity or 0)>0)then
  table.insert(rows,{key='dexterity',before=a.totalStats.DEX,after=b.totalStats.DEX,delta=b.totalStats.DEX-a.totalStats.DEX})
  for _,key in ipairs({'attackRate','moveRate'})do table.insert(rows,{key=key,before=a[key],after=b[key],delta=b[key]-a[key]})end
 end
 return rows
end
local function number(v)return string.format('%.4f',v):gsub('0+$',''):gsub('%.$','')end
function Impact.text(rows)
 local lines={Text.EquipmentPreview}
 for _,row in ipairs(rows) do lines[#lines+1]=string.format('%s: %s → %s (%s%s)',Text.Labels[row.key],number(row.before),number(row.after),row.delta>=0 and '+' or '',number(row.delta)) end
 return table.concat(lines,'\n')
end
function Impact.summary(rows)
 local values={};for _,r in ipairs(rows) do values[r.key]=(r.delta>=0 and '+' or '')..number(r.delta) end
 local extra=values.dexterity and ('\nDEX '..values.dexterity..' · Attack speed '..values.attackRate..'x · Move speed '..values.moveRate..'x')or ''
 return string.format('On equip (pts): ATK %s · MATK %s\nDEF %s · Max HP %s · Max MP %s',values.physicalPower,values.magicPower,values.armor,values.health,values.mana)..extra
end
return Impact
