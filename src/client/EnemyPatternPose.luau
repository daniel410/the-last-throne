-- Continuous preparation, contact and recovery from the authoritative attack clock.
local Snapshot=require(script.Parent.EnemyPatternDefinition)
local AttackFrame=require(game:GetService('ReplicatedStorage').Shared.EnemyAttackFrame)
local CombatProfiles=require(game:GetService('ReplicatedStorage').Shared.EnemyCombatProfiles)
local Pose={}
local facingCache=setmetatable({},{__mode='k'})
local function smooth(t)
 t=math.clamp(t,0,1);return t*t*(3-2*t)
end
local function definition(model)
 return Snapshot.get(model)
end
local function wrap(angle)return (angle+math.pi)%(math.pi*2)-math.pi end
local function facing(model,d)
 local frame=Snapshot.frame(model)
 local origin=frame.origin or Vector3.zero
 local direction=frame.direction or Vector3.new(0,0,-1)
 local aim=frame.aim or origin+direction*12
 local castOrigin=frame.castOrigin
 local row=facingCache[model]
 if row and row.d==d and row.origin==origin and row.direction==direction and row.aim==aim and row.castOrigin==castOrigin then return row.yaws end
 local base=Vector3.new(direction.X,0,direction.Z)
 base=base.Magnitude>.001 and base.Unit or Vector3.new(0,0,-1)
 local attack={d=d,origin=origin,direction=direction,aim=aim,castOrigin=castOrigin}
 local yaws={}
 for pulse=1,d.pulses do
  local _,_,dir=AttackFrame.resolve(attack,pulse)
  local flat=Vector3.new(dir.X,0,dir.Z)
  flat=flat.Magnitude>.001 and flat.Unit or base
  local yaw=math.atan2(base:Cross(flat).Y,base:Dot(flat))
  yaws[pulse]=pulse==1 and yaw or yaws[pulse-1]+wrap(yaw-yaws[pulse-1])
 end
 facingCache[model]={d=d,origin=origin,direction=direction,aim=aim,castOrigin=castOrigin,yaws=yaws}
 return yaws
end
function Pose.facingYaw(model,current,attack)
 local d=definition(model);if not d then return 0 end
 local yaws=facing(model,d);local age=current-attack.start
 if age<attack.w then return yaws[1]*smooth(age/attack.w)end
 local elapsed=age-attack.w
 local pulse=math.min(d.pulses,math.floor(math.max(0,elapsed)/d.interval)+1)
 local localAge=elapsed-(pulse-1)*d.interval
 local hold=math.min(.12,d.interval*.24)
 if pulse<d.pulses then
  -- Turn throughout the next preparation, rather than snapping at contact.
  local blend=smooth((localAge-hold)/math.max(.1,d.interval-hold))
  return yaws[pulse]+(yaws[pulse+1]-yaws[pulse])*blend
 end
 local settle=math.min(.8,math.max(.3,attack.r*.65))
 return yaws[pulse]+wrap(-yaws[pulse])*smooth((localAge-hold)/settle)
end
function Pose.phase(model,current,attack)
 local d=definition(model);if not d then return nil end
 local age=current-attack.start
 -- Authored clips contact at .62. Preserve that phase on every server pulse.
 if age<attack.w then
  local t=math.clamp(age/attack.w,0,1)
  if t<.8 then return .5*smooth(t/.8)end
  return .5+.12*smooth((t-.8)/.2)
 end
 local elapsed=age-attack.w
 -- Release the arm during the last projectile's flight. The active server
 -- window includes travel time and can outlast the visible throw by seconds.
 if d.shape=='projectile' then
  local sinceLast=elapsed-(d.pulses-1)*d.interval
  local follow=math.min(.14,d.interval*.25)
  if sinceLast>=follow then
   local remaining=attack.a+attack.r-(d.pulses-1)*d.interval-follow
   return .78+.22*smooth((sinceLast-follow)/math.max(.01,math.min(remaining,.28+.50*attack.r)))
  end
 end
 if elapsed<attack.a then
  local strike=math.min(d.pulses-1,math.floor(elapsed/d.interval))
  local localAge=elapsed-strike*d.interval
  local follow=math.min(.14,d.interval*.25)
  if localAge<follow then return .62+.16*smooth(localAge/follow)end
  if strike==d.pulses-1 then return .78 end
  local prepare=d.interval*.72
  local ready=d.motion=='cast' and .60 or .44
  if localAge<prepare then return .78+(ready-.78)*smooth((localAge-follow)/(prepare-follow))end
  return ready+(.62-ready)*smooth((localAge-prepare)/(d.interval-prepare))
 end
 return .78+.22*smooth((elapsed-attack.a)/attack.r)
end
-- Signed local rotations in degrees. Reach is a fraction of the visual height.
-- The preparation and contact work in opposite directions, as do the two arms.
local v=Vector3.new
local function action(wind,hit,arm,guard,reach)
 return {wind=wind,hit=hit,arm=arm,guard=guard,reach=reach}
end
local styles={
 thrust=action(v(8,22,-8),v(-9,0,5),v(-18,21,10),v(17,-16,-20),.061),
 cleave=action(v(8,34,-14),v(-12,-13,13),v(-31,27,14),v(22,-15,-20),.042),
 sweep=action(v(6,24,9),v(-8,-10,-8),v(-12,29,-9),v(18,-13,18),.034),
 riposte=action(v(-10,-16,13),v(-7,5,-8),v(-18,14,-9),v(32,-14,-20),.045),
 slam=action(v(17,8,-6),v(-19,0,5),v(-36,5,12),v(27,-12,-13),.041),
 rake=action(v(5,-24,13),v(-10,12,-9),v(-14,-25,22),v(15,13,-18),.044),
 grasp=action(v(11,13,-12),v(-14,0,8),v(-20,14,-12),v(-14,-22,18),.053),
 bite=action(v(14,-6,-5),v(-14,0,4),v(-18,0,8),v(-18,0,-8),.077),
 lunge=action(v(17,12,-7),v(-16,0,4),v(-26,9,12),v(22,-10,-9),.08),
 hop=action(v(-14,0,3),v(12,0,-2),v(-14,0,6),v(-14,0,-6),.056),
 swoop=action(v(17,13,17),v(-13,0,-12),v(-22,0,24),v(-22,0,-24),.068),
 bolt=action(v(9,-15,-9),v(-8,0,4),v(-22,18,9),v(31,-16,-22),.026),
 conjure=action(v(-15,16,7),v(10,0,-5),v(28,13,-16),v(36,-17,19),.014),
 spit=action(v(16,-11,5),v(-14,0,-3),v(-12,0,15),v(-12,0,-15),.052),
}
-- Older encounters publish a simple timing clock without a pattern snapshot.
-- Layer preparation onto their original attack clip and retain its exact contact.
local basicStyles={dagger='thrust',mandible='thrust',axe='cleave',greatsword='cleave',swordShield='riposte',
 club='slam',fist='slam',claw='rake',fang='bite',wing='swoop',hand='grasp',gel='hop',
 staff='bolt',crystalStaff='bolt',ember='bolt',soulStaff='conjure',totem='conjure',curse='conjure',web='spit'}
function Pose.basic(kind)
 local p=CombatProfiles.get(kind)
 return p and (styles[basicStyles[p.weapon]] or styles.sweep)
end
local function style(d)
 if d.motion=='cast' or d.shape=='projectile' then
  if d.weapon=='fang' or d.weapon=='web' or d.weapon=='mandible' then return styles.spit end
  if d.shape=='circle' or d.shape=='ring' or d.shape=='trail' or d.element=='soul' or d.element=='shadow' then return styles.conjure end
  return styles.bolt
 end
 if d.motion=='dash' then return styles.lunge end
 if d.motion=='slam' then return styles.slam end
 if d.motion=='hop' and d.motionStyle~='bite' and d.motionStyle~='swoop' then return styles.hop end
 return styles[d.motionStyle] or styles[d.motion] or styles.sweep
end
local function angles(a)
 return CFrame.Angles(math.rad(a.X),math.rad(a.Y),math.rad(a.Z))
end

local function beats(age,attack,d)
 if age<attack.w then
  local t=age/attack.w
  local swing=smooth((t-.67)/.33)
  return smooth(t/.64)*(1-swing),swing
 end
 local elapsed=age-attack.w
 local index=math.min(d.pulses-1,math.floor(elapsed/d.interval))
 local since=elapsed-index*d.interval
 local brake=math.min(d.heavy and .32 or .22,d.interval*.42,attack.a+attack.r-index*d.interval)
 local drive=1-smooth(since/brake)
 if index==d.pulses-1 then return 0,drive end
 local t=since/d.interval
 local swing=smooth((t-.69)/.31)
 return smooth((t-.21)/.48)*(1-swing),drive+swing
end

function Pose.accent(model,current,attack,height,basic)
 local d=definition(model)
 if not d and not basic then return CFrame.identity end
 local g=d and style(d) or basic
 local load,drive
 if d then
  load,drive=beats(current-attack.start,attack,d)
 else
  local t=(current-attack.start)/attack.w
  load=smooth(t/.64)*(1-smooth((t-.67)/.33))
  drive=0
 end
 local reach=math.min(.58,(height or 5)*g.reach)
 local turn=d and CFrame.Angles(0,Pose.facingYaw(model,current,attack),0) or CFrame.identity
 local body=angles(g.wind*load+g.hit*drive)
 return turn*CFrame.new(0,0,reach*(.62*load-drive))*body,g,load,drive
end

function Pose.joint(model,channel,phase,g,load,drive)
 if channel~='weapon' and channel~='off' then return CFrame.identity end
 if not g then
  local d=definition(model)
  if not d then return CFrame.identity end
  g=style(d)
  load=smooth(phase/.50)*(1-smooth((phase-.50)/.12))
  drive=smooth((phase-.50)/.12)*(1-smooth((phase-.62)/.38))
 end
 local arc=channel=='weapon' and g.arm or g.guard
 return angles(arc*(load-.48*drive))
end
return Pose
