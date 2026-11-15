local RS=game:GetService('ReplicatedStorage')
local Rules=require(RS.Shared.EnemyPackRules)
local Profiles=require(RS.Shared.EnemyCombatProfiles)
local P={}
local function flat(v)return Vector3.new(v.X,0,v.Z)end
local function attr(enemy,name,value)enemy.model:SetAttribute(name,value)end
local function stamp(current,untilTime)return workspace:GetServerTimeNow()+untilTime-current end
local function samePack(a,b)return a.model:GetAttribute('DeepwoodEncounter')==b.model:GetAttribute('DeepwoodEncounter')end
local function available(source,target,range,current,ctx)
 return source~=target and not source.returning and not target.returning and ctx.alive(source)and ctx.alive(target)and samePack(source,target)
  and not source.model:GetAttribute('StoryPacified')and not target.model:GetAttribute('StoryPacified')
  and (source.model:GetAttribute('StoryPauseUntil')or 0)<=workspace:GetServerTimeNow()
  and (target.model:GetAttribute('StoryPauseUntil')or 0)<=workspace:GetServerTimeNow()
  and not(source.stunUntil and current<source.stunUntil)
  and math.abs(target.root.Position.Y-source.root.Position.Y)<=8
  and flat(target.root.Position-source.root.Position).Magnitude<=range
  and ctx.visible(source,target)
end
function P.canAttack(enemy,target,current,others)
 local active=0
 for _,other in pairs(others)do
  local a=other.attack
  if other~=enemy and samePack(enemy,other)and other.target==target and a and a.pattern
   and current<a.started+a.definition.windup+a.definition.active then active+=1 end
 end
 return active<Rules.pressureLimit(enemy.model:GetAttribute('StoryDifficulty')or 'Easy')
end
function P.expose(enemy,current,duration,side,direction,emit)
 enemy.mechanicWeakness={expires=current+duration,side=side or 'any',direction=direction or enemy.root.CFrame.LookVector}
 attr(enemy,'K0ExposedUntil',stamp(current,current+duration));attr(enemy,'K0ExposedSide',side or 'any')
 emit({kind='weakness',model=enemy.model,untilTime=stamp(current,current+duration),side=side or 'any',at=workspace:GetServerTimeNow()})
end
function P.weaknessMultiplier(enemy,origin,current)
 local w=enemy.mechanicWeakness
 if not w or current>=w.expires then return 1 end
 local delta=flat(origin-enemy.root.Position)
 return Rules.weaknessMultiplier(w.side,delta.Magnitude>.01 and delta.Unit:Dot(w.direction)or 1)
end
function P.clearBuff(enemy,kind)
 if kind=='Ward'then enemy.packWard=nil;attr(enemy,'K0WardUntil',nil);attr(enemy,'K0WardAmount',nil)
 else enemy.packRally=nil;attr(enemy,'K0RallyUntil',nil)end
end
function P.breakLinks(source,others)
 for _,other in pairs(others)do
  if other.packWard and other.packWard.source==source then P.clearBuff(other,'Ward')end
  if other.packRally and other.packRally.source==source then P.clearBuff(other,'Rally')end
 end
end
function P.cancel(enemy,current,ctx,reason)
 local c=enemy.supportCast
 if c then
  enemy.supportCast=nil;attr(enemy,'K0SupportKind',nil);attr(enemy,'K0SupportUntil',nil);attr(enemy,'K0EnemyAttackClock',nil)
  ctx.emit({kind='supportEnd',model=enemy.model,sequence=c.sequence,result=reason or 'Cancelled',at=workspace:GetServerTimeNow()})
 end
 P.breakLinks(enemy,ctx.enemies)
end
function P.interrupt(enemy,current,ctx,impactAt)
 local c=enemy.supportCast
 impactAt=impactAt or current
 if not c or c.released or impactAt<c.started or impactAt>c.started+c.definition.windup then return false end
 P.cancel(enemy,current,ctx,'Interrupted')
 P.expose(enemy,current,2,'any',enemy.root.CFrame.LookVector,ctx.emit)
 enemy.reconsiderAt=current+2
 return true
end
function P.trySupport(enemy,current,ctx)
 local d=Rules.support(enemy.kind)
 local count=enemy.patternHistory and enemy.patternHistory.count or 0
 if not d or not enemy.patternProfile or enemy.attack or enemy.supportCast
  or count-(enemy.lastSupportCount or 0)<2 or current<(enemy.supportReady or 0)
  or enemy.model:GetAttribute('StoryShield')or enemy.model:GetAttribute('StoryPacified')then return false end
 local candidates={}
 for _,other in pairs(ctx.enemies)do
  if other~=enemy and samePack(enemy,other)and other.supportCast then return false end
  local profile=Profiles.get(other.kind)
  if profile and not profile.boss and available(enemy,other,d.range,current,ctx)
   and (d.kind~='Ward'or not other.packWard)
   and (d.kind~='Rally'or not other.packRally)then
   local frontline=profile.role=='bruiser'or profile.role=='guardian'or profile.role=='skirmisher'
   table.insert(candidates,{enemy=other,score=(frontline and 10 or 0)+(1-other.humanoid.Health/other.humanoid.MaxHealth)*3})
  end
 end
 table.sort(candidates,function(a,b)if a.score==b.score then return a.enemy.id<b.enemy.id end return a.score>b.score end)
 if #candidates==0 then return false end
 local targets={}for i=1,math.min(d.maxTargets,#candidates)do targets[i]=candidates[i].enemy end
 enemy.attackSeq+=1
 local c={definition=d,started=current,targets=targets,sequence=enemy.attackSeq,released=false}
 enemy.supportCast=c;enemy.supportReady=current+d.windup+d.recovery+d.cooldown;enemy.lastSupportCount=count
 attr(enemy,'K0AttackSeq',c.sequence);attr(enemy,'K0PatternId',nil);attr(enemy,'K0PatternDefinition',nil)
 attr(enemy,'K0SupportKind',d.kind);attr(enemy,'K0SupportUntil',stamp(current,current+d.windup))
 attr(enemy,'K0SupportSeq',c.sequence);attr(enemy,'K0SupportTargetId',targets[1].id)
 attr(enemy,'K0EnemyAttackClock',string.format('%d|%.6f|%.6f|%.6f|%.6f|0',c.sequence,workspace:GetServerTimeNow(),d.windup,.05,d.recovery))
 ctx.emit({kind='support',model=enemy.model,sequence=c.sequence,support=d.kind,target=targets[1].model,
  untilTime=stamp(current,current+d.windup),at=workspace:GetServerTimeNow()})
 return true
end
function P.stepSupport(enemy,current,ctx)
 local c=enemy.supportCast;if not c then return nil end
 local d=c.definition;local age=current-c.started
 if age<d.windup then return 'Windup' end
 if not c.released then
  c.released=true
  if age-d.windup<=.22 then
   for _,target in ipairs(c.targets)do
    if available(enemy,target,d.range,current,ctx)then
     if d.kind=='Ward'then
      local amount=math.max(1,math.floor(math.min(target.humanoid.MaxHealth*d.wardFraction,enemy.config.attacks[1].damage*2)))
      target.packWard={source=enemy,amount=amount,expires=current+d.duration,range=d.range}
      attr(target,'K0WardUntil',stamp(current,current+d.duration));attr(target,'K0WardAmount',amount)
     else
      target.packRally={source=enemy,expires=current+d.duration,range=d.range}
      attr(target,'K0RallyUntil',stamp(current,current+d.duration))
     end
    end
   end
  end
  attr(enemy,'K0SupportUntil',nil);attr(enemy,'K0SupportKind',nil)
  ctx.emit({kind='supportEnd',model=enemy.model,sequence=c.sequence,result='Released',at=workspace:GetServerTimeNow()})
 end
 if age>=d.windup+.05+d.recovery then
  enemy.supportCast=nil;attr(enemy,'K0EnemyAttackClock',nil);return 'Done'
 end
 return 'Recovery'
end
function P.step(enemy,current,ctx)
 for _,kind in ipairs({'Ward','Rally'})do
  local b=enemy[kind=='Ward'and 'packWard'or 'packRally']
  if b and (current>=b.expires or not available(b.source,enemy,b.range,current,ctx))then P.clearBuff(enemy,kind)end
 end
 if enemy.mechanicWeakness and current>=enemy.mechanicWeakness.expires then
  enemy.mechanicWeakness=nil;attr(enemy,'K0ExposedUntil',nil);attr(enemy,'K0ExposedSide',nil)
 end
end
function P.absorb(enemy,damage,current,ctx)
 P.step(enemy,current,ctx)
 local ward=enemy.packWard
 if not ward then return damage end
 local amount=math.min(damage,ward.amount);ward.amount-=amount;damage-=amount
 attr(enemy,'K0WardAmount',ward.amount)
 if ward.amount<=0 then P.clearBuff(enemy,'Ward')end
 return damage
end
return P
