-- Execute the real renderer against bounded API doubles. No engine rendering.
local checks=0
local function check(v,label)checks=checks+1;assert(v,label)end
math.clamp=math.clamp or function(x,a,b)return math.max(a,math.min(b,x))end
unpack=table.unpack
local V={};local mt={}
mt.__index=function(v,k)if k=='Magnitude'then return math.sqrt(v.X^2+v.Y^2+v.Z^2)elseif k=='Unit'then return v/v.Magnitude end;return V[k]end
function V.new(x,y,z)return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},mt)end
mt.__add=function(a,b)return V.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
mt.__sub=function(a,b)return V.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
mt.__unm=function(a)return V.new(-a.X,-a.Y,-a.Z)end
mt.__mul=function(a,b)if type(a)=='number'then a,b=b,a end;return V.new(a.X*b,a.Y*b,a.Z*b)end
mt.__div=function(a,b)return a*(1/b)end
function V:Dot(b)return self.X*b.X+self.Y*b.Y+self.Z*b.Z end
function V:Cross(b)return V.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X)end
Vector3=V;V.zero=V.new();V.one=V.new(1,1,1);V.xAxis=V.new(1,0,0);V.yAxis=V.new(0,1,0)
local cf={};cf.__index=cf;cf.__mul=function(a,b)return CFrame.new(a.Position+b.Position)end
function cf:PointToWorldSpace(p)return self.Position+p end
function cf:VectorToWorldSpace(p)return p end
CFrame={new=function(a,b,c)return setmetatable({Position=type(a)=='table'and a or V.new(a,b,c),LookVector=V.new(0,0,-1)},cf)end}
CFrame.lookAt=function(a,b)return CFrame.new(a)end;CFrame.Angles=function()return CFrame.new()end
Color3={fromRGB=function(r,g,b)return {r,g,b}end}
local enumMt={__index=function(t,k)local v=setmetatable({},getmetatable(t));rawset(t,k,v);return v end}
Enum=setmetatable({},enumMt)
TweenInfo={new=function()return {}end};RaycastParams={new=function()return {}end}
local pending,created={},{}
task={delay=function(_,f)pending[#pending+1]=f end}
local function flush()local q=pending;pending={};for _,f in ipairs(q)do f()end end
local function signal()return {Connect=function(self,f)self.callback=f;return {Disconnect=function()end}end}end
local obj={};obj.__index=obj
function obj:IsA(class)return self.ClassName==class or class=='BasePart'and self.ClassName=='Part'end
function obj:Destroy()self.Parent=nil end
function obj:FindFirstChild(name,recursive)for _,x in ipairs(created)do if x.Parent==self then if x.Name==name then return x end;if recursive then local f=x:FindFirstChild(name,true);if f then return f end end end end end
function obj:GetChildren()local out={};for _,x in ipairs(created)do if x.Parent==self then out[#out+1]=x end end;return out end
function obj:GetAttribute(k)return self.attributes and self.attributes[k]end
function obj:GetAttributeChangedSignal(k)self.signals=self.signals or {};self.signals[k]=self.signals[k]or signal();return self.signals[k]end
Instance={new=function(class)local p=setmetatable({ClassName=class,AncestryChanged=signal(),LocalTransparencyModifier=0},obj);created[#created+1]=p;return p end}
workspace={FindFirstChild=function()end,GetServerTimeNow=function()return 100 end,Raycast=function(self,from,delta,params)return {Position=V.new(from.X,0,from.Z)}end}
local Config=dofile('src/shared/K0Config.luau');local Advanced=dofile('src/shared/AdvancedSkills.luau')
local pixelPulses=0
local modules={AdvancedSkills=Advanced,K0Config=Config,PixelFX={skill=function(_,_,_,_,pulse)assert(pulse>0);pixelPulses=pixelPulses+1 end}}
require=function(name)return assert(modules[name],tostring(name))end
script={Parent={AdvancedSkills='AdvancedSkills',SkillEffectGeometry='Geometry',K0BowMotion='Bow',WindLanceVisual='Wind',PixelFX='PixelFX',HeroVFX='HeroVFX',BombVisual='Bomb',K0CombatAudio='Audio'}}
local P=dofile('src/shared/SkillPresentation.luau');modules.SkillPresentation=P;modules.Geometry=dofile('src/client/SkillEffectGeometry.luau')
table.freeze=table.freeze or function(value)return value end
local previousScript=script
script={Parent={K0Config='K0Config',SkillPresentation='SkillPresentation'}}
modules.PixelFXCatalog=dofile('src/shared/PixelFXCatalog.luau')
script={Parent={PixelFXCatalog='PixelFXCatalog'}}
modules.CombatVFXPalette=dofile('src/shared/CombatVFXPalette.luau')
script=previousScript
modules.Bomb=dofile('src/client/BombVisual.luau')
modules.Audio={play=function()end}
modules.HeroVFX={skill=function()end,isOtherHero=function()return false end,windup=function()end,groundLead=function()end,endWindup=function()end,endIncoming=function()end}
modules.Bow={confirmPulse=function()end};modules.Wind={play=function()end}
local rs={Shared={K0Config='K0Config',SkillPresentation='SkillPresentation',CombatVFXPalette='CombatVFXPalette'}}
local event=signal();rs.WaitForChild=function()return {WaitForChild=function()return {OnClientEvent=event}end}end
local services={ReplicatedStorage=rs,Players={},TweenService={Create=function(self,p,info,props)return {Play=function()for k,v in pairs(props)do p[k]=v end end}end},Debris={AddItem=function(self,p)task.delay(0,function()p:Destroy()end)end}}
game={GetService=function(self,k)return services[k]end}
typeof=function(v)return getmetatable(v)==mt and 'Vector3'or type(v)end
local f=assert(io.open('src/client/AdvancedSkillVisual.luau'));local source=f:read('*a');f:close()
source=source:gsub('active%+=1','active=active+1')
local Visual=assert(load(source,'@AdvancedSkillVisual.luau'))()
local seen={}
local function inspect()
 local parts=0
 for _,p in ipairs(created)do
  if p.ClassName=='Part'and p.Parent then
   parts=parts+1;seen[p.Name]=true
   check(p.CanCollide==false and p.CanTouch==false and p.CanQuery==false,p.Name..' cannot affect combat physics')
   check(p.Size.X>0 and p.Size.Y>0 and p.Size.Z>0,p.Name..' positive size')
   check(p.CFrame.Position.X==p.CFrame.Position.X,p.Name..' finite position')
  end
 end
 check(parts<=128,'global cosmetic part budget')
end
local count=0
for _,list in pairs(Config.Skills)do for _,d in ipairs(list)do if d.advanced then
 count=count+1
 for pulse=0,d.pulses do
  Visual.play(nil,d.id,V.new(0,3,0),V.new(0,3,-d.range),pulse,{V.new(0,3,-4)},1,100,100)
  inspect();flush();created={}
 end
end end end
check(count==116,'execute all advanced skills and all pulses')
local expectedPulses=0
for _,list in pairs(Config.Skills)do for _,d in ipairs(list)do
 local usesSocketTrace=d.id=='elf.marksman.crossfire' or d.id=='dwarf.gunner.quickfire' or d.id=='elf.magic_archer.echo_arrows'
  or d.id=='dwarf.iron_axe.returning_echo'
 local usesAuthoredRelease=P.get(d).fanLanes or d.id=='knight.steel_knight.rallying_slash' or d.id=='mage.pyro.steam_burst'
  or d.id=='knight.steel_knight.twin_cyclone' or d.id=='mage.pyro.cinder_ring'
  or d.id=='knight.steel_knight.steel_sweep' or d.id=='dwarf.iron_axe.crag_cleave'
  or d.id=='elf.magic_archer.vine_burst' or d.id=='mage.pyro.lava_eruption'
 if d.advanced and not modules.Bomb.get(d.id) and d.form~='chain' and not usesSocketTrace and not usesAuthoredRelease then
  expectedPulses=expectedPulses+d.pulses
 end
end end
check(pixelPulses==expectedPulses,'confirmed pulses supplement skills that use PixelFX')
for _,name in ipairs({'SkillTelegraph','ImpactBoundary','ArrowShaft','LightningFork','ChainFallback','IceCrystal','EarthRupture','RifleTracer','ShotPellet','ThrownAxeBlade','BladeCrescent','PersonalWard','ShieldContact','LavaFissure'})do check(seen[name],name..' has exercised renderer')end
check(not seen.RootingVine and not seen.SteamJet and not seen.MortarDescent,'specialized roots, vapor and shells have one renderer owner')
-- Gunner cancellation removes the left-hand prop and preserves the held axe.
local d=Advanced.branches.gunner.skills[1]
local character=Instance.new('Model');character.Parent=workspace;character.attributes={K0State='Attack',K0AttackSeq=5,K0SkillId=d.id}
local hand=Instance.new('Part');hand.Name='LeftHand';hand.Parent=character;hand.CFrame=CFrame.new()
local appearance=Instance.new('Model');appearance.Parent=character
local grip=Instance.new('Part');grip.Name='WeaponGrip';grip.Parent=appearance
local axe=Instance.new('Part');axe.Name='Weapon';axe.Parent=appearance;axe.LocalTransparencyModifier=.2
Visual.play(character,d.id,V.new(0,3,0),V.new(0,3,-10),0,nil,5)
check(axe.LocalTransparencyModifier==.2,'gunner keeps the axe visible')
local prop=assert(character:FindFirstChild('BranchSkillProp'))
local weld=assert(prop:FindFirstChild('Barrel'):GetChildren()[1])
check(weld.Part0==hand,'gunner prop attached to the left hand')
character.attributes.K0State='Dodge';character.signals.K0State.callback()
check(axe.LocalTransparencyModifier==.2,'cancel restores original transparency')
check(character:FindFirstChild('BranchSkillProp')==nil,'cancel destroys prop')
flush()
local connected=0;event.Connect=function(self,f)connected=connected+1 end
Visual.start();Visual.start();check(connected==1,'idempotent remote subscription')
print('Skill effects CPU: '..checks..' checks PASS; all 116 advanced casts/pulses, geometry, cosmetic budget, cancellation. No engine QA.')
