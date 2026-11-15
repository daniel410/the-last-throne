local R=dofile('src/shared/EnemyPackRules.luau')
local P=dofile('src/shared/EnemyPatterns.luau')
local Profiles=dofile('src/shared/EnemyCombatProfiles.luau')
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
-- Per-target pressure has a separate, finite budget for the teaching mode.
check(R.pressureLimit('Easy')==1,'Easy permits one announced attack per target')
for _,mode in ipairs({'Hard','Insane','Hell'})do
 check(R.pressureLimit(mode)==2,'later modes permit a bounded two-attack combination: '..mode)
end
-- A frontal hit never gains a positional bonus intended for the rear/flank.
for sample=-100,100 do
 local dot=sample/100
 local rear=R.weaknessMultiplier('rear',dot)
 local flank=R.weaknessMultiplier('flank',dot)
 check(rear>=1 and rear<=1.25 and flank>=1 and flank<=1.25,'counterplay cannot stack an unbounded multiplier')
 if dot>=0 then check(rear==1,'a frontal or side hit cannot claim a rear punish')end
 if math.abs(dot)>.55 then check(flank==1,'a frontal/rear hit cannot claim a flank punish')end
 check(R.weaknessMultiplier('any',dot)==1.25,'an unrestricted opening is available from every approach')
 check(R.weaknessMultiplier('unknown',dot)==1,'an unknown side does not grant a positional bonus')
end
check(R.weaknessMultiplier('rear',-.35)==1.25,'rear boundary includes its announced threshold')
check(R.weaknessMultiplier('rear',-.349)==1,'rear bonus stops at its boundary')
check(R.weaknessMultiplier('flank',-.55)==1.25 and R.weaknessMultiplier('flank',.55)==1.25,'flank boundaries are symmetric')
check(R.weaknessMultiplier('flank',-.551)==1 and R.weaknessMultiplier('flank',.551)==1,'flank bonus ends on both sides')
-- Every support cast is visible, interruptible, finite, and limited to nearby allies.
local wardCount,rallyCount=0,0
for kind in pairs(P.profiles)do
 local support=R.support(kind)
 if support then
  check(support.windup>=1.5 and support.recovery>=1,'support exposes a reaction and recovery window: '..kind)
  check(support.cooldown>=12 and support.duration>0 and support.duration<=5,'support cannot be maintained indefinitely: '..kind)
  check(support.range>0 and support.range<=18,'support remains attached to a local pack: '..kind)
  check(support.maxTargets>=1 and support.maxTargets<=3 and support.maxTargets%1==0,'support cannot affect unlimited targets: '..kind)
  if support.kind=='Ward'then
   wardCount=wardCount+1
   check(support.maxTargets==1,'a ward protects only one ally')
   check(support.wardFraction>0 and support.wardFraction<=.18,'a ward cannot replace an ally entire health pool')
  elseif support.kind=='Rally'then
   rallyCount=rallyCount+1
   check(support.maxTargets<=3,'a commander cannot rally an unbounded formation')
   check(support.wardFraction==nil,'a rally does not silently grant an additional shield')
  else check(false,'unknown support behavior')end
  support.range=999
  check(R.support(kind).range<=18,'cast-specific mutation cannot corrupt future support contracts')
 end
end
check(wardCount==10 and rallyCount==5,'authored support species are explicitly bounded')
for _,kind in ipairs({'Goblin','Orc','Ogre','IceWolf','IceBear','Slime','CalderaTitan'})do
 check(R.support(kind)==nil,'frontline creatures do not invent unsupported summoning/buff skills: '..kind)
end
check(R.support('Unknown')==nil,'unsupported species cannot obtain a generic support cast')
-- The support system uses the same finite directional vocabulary as real finishers.
for kind,profile in pairs(P.profiles)do
 for _,health in ipairs({1,.6,.2})do
  for _,attack in ipairs(profile.attacks)do
   local d=Profiles.resolve(kind,attack,'Hell',health)
   if d.weaknessDuration then
    check(d.weaknessDuration<=2.8 and d.weaknessDuration<=d.recovery,'punish duration fits its announced recovery')
    local side=d.weaknessSide
    check(side=='any'or side=='rear'or side=='flank','finisher and server agree on weak-side identifiers')
    local dot=side=='rear'and -1 or side=='flank'and 0 or 1
    check(R.weaknessMultiplier(side,dot)==1.25,'every authored finisher has a reachable positional punish')
   end
  end
 end
end
print('enemy-pack-rules: '..checks..' checks PASS; finite pressure/support bounds and side-specific punish windows')
