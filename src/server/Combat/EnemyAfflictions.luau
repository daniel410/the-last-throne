-- Server-only, bounded target-bound effects. Every delayed hit reuses the authoritative hit resolver.
local Rules=game and require(game:GetService('ReplicatedStorage').Shared.EnemyAfflictionRules)or dofile('src/shared/EnemyAfflictionRules.luau')
local A={}
local records={}
local byTarget=setmetatable({},{__mode='k'})
local sourceEpochs=setmetatable({},{__mode='k'})
local function copy(source)
 local result={}for key,value in pairs(source or {})do result[key]=value end return result
end
local function publicTime(current)
 return workspace and workspace.GetServerTimeNow and workspace:GetServerTimeNow()or current
end
local function attribute(model,name,value)
 if model and model.SetAttribute then model:SetAttribute(name,value)end
end
local function getAttribute(model,name)
 return model and model.GetAttribute and model:GetAttribute(name)or nil
end
local function clearAttributes(character)
 for _,name in ipairs(Rules.attributes())do attribute(character,name,nil)end
 attribute(character,'K0EnemySlowMultiplier',1)
 attribute(character,'K0EnemyOutgoingMultiplier',1)
end
local function baseValid(record,current)
 local enemy,state=record.enemy,record.state
 if (sourceEpochs[enemy]or 0)~=record.sourceEpoch then return false end
 if enemy.model~=record.sourceModel or not record.sourceModel.Parent
  or enemy.root~=record.sourceRoot or not record.sourceRoot.Parent
  or enemy.humanoid~=record.sourceHumanoid or not record.sourceHumanoid.Parent or record.sourceHumanoid.Health<=0 then return false end
 if getAttribute(record.sourceModel,'DeepwoodEncounter')~=record.encounter then return false end
 if state.character~=record.character or not record.character.Parent
  or state.root~=record.root or not record.root.Parent
  or state.humanoid~=record.humanoid or not record.humanoid.Parent or record.humanoid.Health<=0
  or state.heroId~=record.heroId or state.mode=='Dead' then return false end
 if state.player and state.player.Character~=record.character then return false end
 if getAttribute(record.sourceModel,'StoryPacified')then return false end
 if (getAttribute(record.sourceModel,'StoryPauseUntil')or 0)>publicTime(current)then return false end
 return true
end
local function publish(state,current)
 local active=byTarget[state]or {}
 local movement,outgoing=1,1
 local clock=publicTime(current)
 for _,element in ipairs({'fire','venom','frost','web','shadow','soul'})do
  local rule=Rules.get(element)
  local row=active[rule.kind]
  local valid=row and current<row.expires and baseValid(row,current)
  attribute(state.character,rule.attribute,valid and clock+row.expires-current or nil)
  if valid then movement=math.min(movement,rule.movement or 1);outgoing=math.min(outgoing,rule.outgoing or 1)end
 end
 attribute(state.character,'K0EnemySlowMultiplier',Rules.movement(movement))
 attribute(state.character,'K0EnemyOutgoingMultiplier',Rules.outgoing(outgoing))
end
local function remove(index,current)
 local row=records[index]
 if not row then return end
 table.remove(records,index)
 if row.character~=row.state.character then clearAttributes(row.character)end
 local active=byTarget[row.state]
 if active and active[row.rule.kind]==row then
  active[row.rule.kind]=nil
  if not next(active)then byTarget[row.state]=nil end
  publish(row.state,current)
 end
end
function A.split(attack,amount,state,current)
 if not attack or attack.afflictionTick or not attack.pattern then return amount,nil end
 local rule=Rules.get(attack.pattern.element)
 if not rule then return amount,nil end
 local old=state and byTarget[state]and byTarget[state][rule.kind]
 if old and current and current<old.expires and baseValid(old,current)then return amount,nil end
 return Rules.split(attack.pattern.element,amount)
end
function A.afterHit(enemy,state,attack,current,reservation,receipt)
 if not attack or attack.afflictionTick or not attack.pattern or not Rules.canApply(receipt)then return false end
 local rule=reservation and reservation.rule
 if not rule then return false end
 local old=byTarget[state]and byTarget[state][rule.kind]
 -- Same-kind effects do not stack, refresh, or replace another source's remaining budget.
 if old and current<old.expires and baseValid(old,current)then return false end
 for index=#records,1,-1 do
  local row=records[index]
  if current>=row.expires or not baseValid(row,current)then remove(index,current)end
 end
 if #records>=Rules.maxRecords then return false end
 local row={enemy=enemy,state=state,sourceModel=enemy.model,sourceRoot=enemy.root,sourceHumanoid=enemy.humanoid,encounter=getAttribute(enemy.model,'DeepwoodEncounter'),
  sourceEpoch=sourceEpochs[enemy]or 0,character=state.character,root=state.root,humanoid=state.humanoid,heroId=state.heroId,
  rule=copy(rule),element=reservation.element,amounts=copy(reservation.amounts),at=current,expires=current+rule.duration,
  nextTick=1,pattern=copy(attack.pattern),definition=copy(attack.definition),origin=attack.origin,direction=attack.direction,
  sequence=attack.sequence or enemy.attackSeq,pulse=attack.pulse or 1}
 if not baseValid(row,current)then return false end
 records[#records+1]=row
 local active=byTarget[state]or {};byTarget[state]=active;active[rule.kind]=row
 publish(state,current)
 return true
end
local function multiplier(state,current,key,clamp)
 local value=1
 for _,row in pairs(byTarget[state]or {})do
  if current<row.expires and baseValid(row,current)then value=math.min(value,row.rule[key]or 1)end
 end
 return clamp(value)
end
function A.movementMultiplier(state,current)return multiplier(state,current,'movement',Rules.movement)end
function A.outgoingMultiplier(state,current)return multiplier(state,current,'outgoing',Rules.outgoing)end
function A.step(current,ctx)
 local calls=0
 for index=#records,1,-1 do
  local row=records[index]
  if row then
  if not baseValid(row,current)or (ctx.valid and not ctx.valid(row.enemy,row.state,row))then
   remove(index,current)
  else
   local amounts=row.amounts
   while row.nextTick<=#amounts do
    local tick=row.nextTick
    local due=row.at+tick*row.rule.interval
    if current<due then break end
    row.nextTick=tick+1
    if amounts[tick]>0 and current-due<=Rules.maxLateTick and calls<Rules.maxTicksPerStep then
     calls=calls+1
     local definition=copy(row.definition);definition.damage=amounts[tick];definition.blockable=true
     local sample={definition=definition,pattern=row.pattern,origin=row.origin,direction=row.direction,hits={},
      impact=row.state.root.Position,sequence=row.sequence,pulse=1000+row.pulse*10+tick,extraRecovery=0,
      geometryChecked=true,afflictionTick=true}
     ctx.hit(row.enemy,row.state,sample,current)
     -- A callback may synchronously kill/remove a target or cancel the source.
     if records[index]~=row then break end
     if not baseValid(row,current)or (ctx.valid and not ctx.valid(row.enemy,row.state,row))then remove(index,current);break end
    end
   end
   if records[index]==row and (current>=row.expires or #amounts>0 and row.nextTick>#amounts)then remove(index,current)end
  end
  end
 end
 return calls
end
function A.clearTarget(state,current)
 current=current or 0
 for index=#records,1,-1 do if records[index].state==state then remove(index,current)end end
 byTarget[state]=nil;publish(state,current)
end
function A.cancelSource(enemy,current)
 current=current or 0;sourceEpochs[enemy]=(sourceEpochs[enemy]or 0)+1
 for index=#records,1,-1 do if records[index].enemy==enemy then remove(index,current)end end
end
function A.clearAll(current)
 current=current or 0
 for index=#records,1,-1 do remove(index,current)end
end
function A.count()return #records end
return A
