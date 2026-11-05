-- CPU regression of real catalog/renderer/controller with Roblox API doubles.
-- This does not claim engine rendering, image loading or device performance.
local count=0
local function check(v,s)count=count+1;assert(v,s)end
math.clamp=math.clamp or function(x,a,b)return math.max(a,math.min(b,x))end
local Config=dofile('src/shared/K0Config.luau')
local modules={K0Config=Config,AdvancedSkills=dofile('src/shared/AdvancedSkills.luau')}
require=function(k)return assert(modules[k],tostring(k))end
script={Parent={AdvancedSkills='AdvancedSkills'}}
modules.SkillPresentation=dofile('src/shared/SkillPresentation.luau')
modules.PixelFXAssets=dofile('src/shared/PixelFXAssets.luau')
script={Parent={K0Config='K0Config',SkillPresentation='SkillPresentation'}}
modules.PixelFXCatalog=dofile('src/shared/PixelFXCatalog.luau')
local Catalog,Assets=modules.PixelFXCatalog,modules.PixelFXAssets
local vector={};local vm={__index=vector}
function vector.new(x,y,z)return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vm)end
vm.__add=function(a,b)return vector.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
vm.__sub=function(a,b)return vector.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vm.__mul=function(a,b)return vector.new(a.X*b,a.Y*b,a.Z*b)end
vm.__index=function(v,k)if k=='Magnitude'then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z)elseif k=='Unit'then local m=v.Magnitude;return vector.new(v.X/m,v.Y/m,v.Z/m)end;return vector[k]end
Vector3=vector;Vector3.zero=vector.new();Vector3.one=vector.new(1,1,1)
Vector2={new=function(x,y)return {X=x,Y=y}end};Vector2.zero=Vector2.new(0,0)
UDim2={fromScale=function(x,y)return {X=x,Y=y}end}
Enum={ResamplerMode={Pixelated='Pixelated'}}
local created={}
local object={}
object.__index=function(self,k)
 if object[k]then return object[k]end
 for _,c in ipairs(created)do if rawget(c,'Parent')==self and rawget(c,'Name')==k then return c end end
end
function object:SetAttribute(k,v)self.attrs[k]=v end
function object:GetAttribute(k)return self.attrs[k]end
function object:IsDescendantOf(p)return self.Parent==p end
function object:Destroy()self.Parent=nil end
function object:FindFirstChild(k)return self[k]end
function object:FindFirstChildOfClass(k)for _,c in ipairs(created)do if c.Parent==self and c.ClassName==k then return c end end end
Instance={new=function(k)local o=setmetatable({ClassName=k,attrs={}},object);table.insert(created,o);return o end}
typeof=function(v)return getmetatable(v)==vm and 'Vector3'or type(v)end
workspace={CurrentCamera={CFrame={Position=Vector3.zero}},GetServerTimeNow=function()return 100 end}
local RS={Shared={K0Config='K0Config',SkillPresentation='SkillPresentation',PixelFXAssets='PixelFXAssets',PixelFXCatalog='PixelFXCatalog'}}
local services={ReplicatedStorage=RS,RunService={IsClient=function()return false end},Players={}}
game={GetService=function(_,k)return assert(services[k],k)end}
task={spawn=function()end}
local function loadModule(path)
 local file=assert(io.open(path));local source=file:read('*a');file:close()
 source=source:gsub('r.age%+=dt','r.age=r.age+dt')
 return assert(load(source,'@'..path))()
end
script={Parent={PixelFX='PixelFX'}}
modules.PixelFX=loadModule('src/client/PixelFX.luau')
local FX=modules.PixelFX
local Controller=loadModule('src/client/PixelFXController.luau')
local character=Instance.new('Model');character.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.zero;root.CFrame={LookVector=vector.new(0,0,-1)};root.Parent=character
character:SetAttribute('K0State','Attack')
local skills,pulses=0,0
for classId,list in pairs(Config.Skills)do
 character:SetAttribute('K0ClassId',classId)
 for _,d in ipairs(list)do
  skills=skills+1;FX.clear()
  local row=Catalog.get(classId,d.id)
  check(row and Assets[row.key],d.id..' texture exists')
  check(FX.hit(Vector3.zero,classId,d.id),d.id..' contact')
  if d.advanced then
   check(not FX.skill(character,d.id,Vector3.zero,vector.new(0,0,-4),0,nil,1),'no windup impact')
    character:SetAttribute('K0AttackSeq',skills)
    for p=1,d.pulses do FX.clear();check(FX.skill(character,d.id,Vector3.zero,vector.new(0,0,-4),p,nil,skills),d.id..' pulse');pulses=pulses+1 end
  else
   character:SetAttribute('K0AttackStartedAt',100);character:SetAttribute('K0SkillId',d.id);character:SetAttribute('K0AttackSeq',skills)
   for p=1,d.shotCount or 1 do
    FX.clear();local now=100+d.windup+(d.hitDelay or 0)+(p-1)*(d.shotInterval or .3)+.01
    check(Controller.renderCharacter(character,now),d.id..' release')
    check(not Controller.renderCharacter(character,now),'release once')
   end
  end
 end
 FX.clear();character:SetAttribute('K0SkillId',nil);character:SetAttribute('K0Combo',1);character:SetAttribute('K0AttackSeq',skills+1000)
 local d=Config.BasicAttackProfiles[classId].attacks[1]
 check(Controller.renderCharacter(character,100+d.windup+(d.hitDelay or 0)+.01),classId..' basic')
end
check(skills==128,'128 skills covered')
FX.clear()
for _,action in ipairs({'Heal','Protect','Cleanse'})do check(FX.support(character,action),'support '..action)end
FX.clear()
local ok,holder=FX.emit('steel',Vector3.zero,2,1,{manual=true,character=character,seq=character:GetAttribute('K0AttackSeq')})
check(ok,'emit');FX.step(.25)
check(holder.PixelFXSprite.Frame.ImageRectOffset.X==0 and holder.PixelFXSprite.Frame.ImageRectOffset.Y==128,'time chooses correct frame')
character:SetAttribute('K0State','Stunned');FX.step(.01);check(FX.count()==0,'interruption cleans')
for i=1,24 do check(FX.emit('steel',Vector3.zero,2,1,{manual=true}),'slot '..i)end
check(not FX.emit('steel',Vector3.zero,2,1,{manual=true}),'bounded effects')
FX.step(2);check(FX.count()==0,'burst cleanup')
check(not FX.emit('steel',vector.new(0/0,0,0),2,1),'NaN ignored')
check(not FX.emit('steel',Vector3.zero,-1,1),'negative size ignored')
check(not FX.emit('steel',vector.new(81,0,0),2,1),'distance cull')
check(Catalog.beat(Config.Skills.elf[2],50)==0,'no old volley replay')
character:SetAttribute('K0HurtAt',200);character:SetAttribute('K0HurtDamage',1)
check(Controller.renderHurt(character,200.01),'confirmed hurt')
check(not Controller.renderHurt(character,200.02),'hurt once');FX.clear()
character:SetAttribute('K0State','Attack');character:SetAttribute('K0EnemyState','Active');character:SetAttribute('K0AttackSeq',2)
character:SetAttribute('K0EnemyAttackClock','2|100.000000|0.500000|0.100000|0.500000|0')
character:SetAttribute('K0AttackOrigin',root.Position);character:SetAttribute('K0AttackDirection',vector.new(0,0,-1))
check(FX.enemy(character,100.51),'enemy release')
check(not FX.enemy(character,100.52),'enemy release once');FX.clear()
local advanced=Config.Skills.mage[4]
character:SetAttribute('K0AttackSeq',50000)
check(not FX.skill(character,advanced.id,Vector3.zero,vector.new(0,0,-4),1,nil,50000,99),'stale remote pulse ignored')
check(FX.skill(character,advanced.id,Vector3.zero,vector.new(0,0,-4),1,nil,50000,100),'fresh remote pulse')
check(not FX.skill(character,advanced.id,Vector3.zero,vector.new(0,0,-4),1,nil,50000,100),'duplicate remote pulse ignored')
check(not FX.skill(character,advanced.id,Vector3.zero,vector.new(0,0,-4),1,nil,49999,100),'previous attack sequence ignored')
FX.clear()
print('PixelFX CPU: '..count..' checks PASS; 128 skills, 4 basic profiles, '..pulses..' advanced pulses, support, hostile accents, frame playback, cancellation and budgets. No engine rendering.')
