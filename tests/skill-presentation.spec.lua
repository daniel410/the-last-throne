-- CPU execution of actual presentation/geometry/motion modules; not engine QA.
local checks=0
local function check(v,label) checks=checks+1;assert(v,label) end
local function near(a,b,label) check(math.abs(a-b)<1e-6,label) end
math.clamp=math.clamp or function(x,a,b)return math.max(a,math.min(b,x))end
unpack=table.unpack
local V={};local mt={}
mt.__index=function(v,k)
 if k=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if k=='Unit' then return v/v.Magnitude end
 return V[k]
end
function V.new(x,y,z)return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},mt)end
mt.__add=function(a,b)return V.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
mt.__sub=function(a,b)return V.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
mt.__mul=function(a,b)if type(a)=='number'then a,b=b,a end;return V.new(a.X*b,a.Y*b,a.Z*b)end
mt.__div=function(a,b)return a*(1/b)end
function V:Lerp(b,t)return self+(b-self)*t end
function V:Dot(b)return self.X*b.X+self.Y*b.Y+self.Z*b.Z end
function V:Cross(b)return V.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X)end
Vector3=V;V.zero=V.new();V.one=V.new(1,1,1);V.xAxis=V.new(1,0,0);V.yAxis=V.new(0,1,0)
CFrame={Angles=function(x,y,z)return {X=x,Y=y,Z=z}end}
local Config=dofile('src/shared/K0Config.luau')
local Advanced=dofile('src/shared/AdvancedSkills.luau')
local Clips=dofile('src/client/K0MeleeClips.luau')
local MageClips=dofile('src/client/K0MageClips.luau')
local oldRequire=require
local modules={AdvancedSkills=Advanced,K0Config=Config,K0MeleeClips=Clips,K0MageClips=MageClips}
require=function(name)return assert(modules[name],tostring(name))end
script={Parent={AdvancedSkills='AdvancedSkills',K0MeleeClips='K0MeleeClips',K0MageClips='K0MageClips'}}
game={ReplicatedStorage={Shared={K0Config='K0Config',SkillPresentation='SkillPresentation'}}}
local P=dofile('src/shared/SkillPresentation.luau');modules.SkillPresentation=P
local Motion=dofile('src/client/AdvancedSkillMotion.luau')
local Mage=dofile('src/client/K0MageMotion.luau')
local G=dofile('src/client/SkillEffectGeometry.luau')
local count,advanced=0,0
local matrix=assert(io.open('docs/evidence/hero-skills-20261104/skill-review.tsv','w'))
matrix:write('class\tskill_id\tname\tform\tmotion\teffect\tpulses\tgeometry_review\tmotion_review\tvisual_acceptance\n')
for _,classId in ipairs({'knight','dwarf','elf','mage'}) do
 for _,d in ipairs(Config.Skills[classId]) do
  count=count+1;local p=assert(P.get(d),d.id)
  check(type(p.motion)=='string' and type(p.effect)=='string',d.id..' explicit contract')
  matrix:write(table.concat({classId,d.id,d.name,d.form or d.effect,p.motion,p.effect,d.pulses or d.shotCount or 1,d.advanced and 'revised' or 'retained',d.advanced and ((classId=='knight' or classId=='dwarf') and 'procedural' or classId=='mage' and 'authored+pulse' or 'authored+confirmed-pulse') or 'retained','NOT_RUN'},'\t')..'\n')
  if d.advanced then
   advanced=advanced+1
   near(P.radius(d),d.form=='ground' and d.radius or d.range,d.id..' radius')
   near(P.sector(d),d.form=='area' and 360 or d.angle,d.id..' sector')
   for pulse=1,d.pulses do
    local age=d.windup+(d.hitDelay or 0)+(pulse-1)*d.interval+1e-7
    local actual,since=P.beat(d,age)
    near(actual,pulse,d.id..' pulse');near(since,1e-7,d.id..' contact')
   end
   if classId=='knight' or classId=='dwarf' then
    local total=d.windup+d.active+d.recovery
    for _,hz in ipairs({30,60,144})do
     for frame=0,math.ceil(total*hz)do
      local age=frame/hz;local pose=assert(Motion.sample(classId,d,age))
      for channel,angle in pairs(pose.angles) do
       check(angle.X==angle.X and angle.Y==angle.Y and angle.Z==angle.Z,d.id..' finite '..channel)
       check(math.abs(angle.X)<=180 and math.abs(angle.Y)<=360 and math.abs(angle.Z)<=180,d.id..' bounded '..channel)
      end
      check(not pose.cutting or (p.effect=='slash' and age>=d.windup-.06 and age<d.windup+d.active),d.id..' trail timing')
     end
    end
    for _,age in ipairs({0,total,total+1})do
     local pose=Motion.sample(classId,d,age)
     for channel,base in pairs(Clips.rest[classId])do
      for i,axis in ipairs({'X','Y','Z'})do near(pose.angles[channel][axis],base[i],d.id..' neutral boundary')end
     end
    end
   elseif classId=='mage' then
    local profile=Mage.profile(d)
    for pulse=1,d.pulses do
     local age=d.windup+(pulse-1)*d.interval
     local pose=assert(Mage.sample(d,profile,age))
     near(pose.time,.65,d.id..' release is retimed per pulse')
    end
   end
  end
 end
end
matrix:close()
check(count==128,'all four classes / 32 skills each')
check(advanced==116,'104 branch + 12 common advanced skills')
-- Geometry is tested against authoritative radial and angular bounds.
for _,direction in ipairs({V.new(0,0,-1),V.new(1,0,0),V.new(0,5,0),V.zero})do
 for _,angle in ipairs({12,65,80,110,360})do
  local origin=V.new(3,2,7);local radius=18
  local points=G.sector(origin,direction,radius,angle,16)
  check(#points==17,'bounded sector segments')
  local forward=V.new(direction.X,0,direction.Z);forward=forward.Magnitude>.001 and forward.Unit or V.new(0,0,-1)
  for _,point in ipairs(points)do
   near((point-origin).Magnitude,radius,'sector stays at real radius')
   check((point-origin).Unit:Dot(forward)>=math.cos(math.rad(angle/2))-1e-6,'sector stays in real cone')
   near(point.Y,origin.Y,'sector lies on ground plane')
  end
 end
end
for _,last in ipairs({V.new(0,0,30),V.new(0,20,0),V.zero})do
 local points=G.lightning(V.zero,last,6)
 near((points[1]-V.zero).Magnitude,0,'chain start');near((points[#points]-last).Magnitude,0,'chain end')
 for _,point in ipairs(points)do check(point.X==point.X and point.Y==point.Y,'vertical / zero chain finite')end
end
require=oldRequire;game=nil
print('Skill presentation CPU: '..checks..' checks PASS; 128 skill contracts, 116 revised advanced skills. No engine/visual acceptance.')
