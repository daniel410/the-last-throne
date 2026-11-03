-- Local presentation from Blender MCP curves. The server owns roots and hits.
local RunService=game:GetService('RunService')
local Workspace=game:GetService('Workspace')
local BaseClips=require(script.Parent.K0EnemyClips)
local Clips=table.clone(BaseClips);Clips.models=table.clone(BaseClips.models)
for kind,profile in pairs(require(script.Parent.FrozenValeClips).models)do Clips.models[kind]=profile end
for kind,profile in pairs(require(script.Parent.EmberCalderaClips).models)do Clips.models[kind]=profile end
-- Late-epic prototypes reuse reviewed movement curves until dedicated clips replace them.
local aliases={Webling='Slime',Silkweaver='Slime',Barkstalker='Ogre',Gloambat='Slime',VenomcoilCentipede='Slime',AncientHollowbark='KingOgre',VenomcoilKing='Slime',WidowQueen='Slime',Zombie='Orc',Skeleton='Goblin',Ghoul='Ogre',Mummy='GoblinKing',Hellhound='IceWolf',SkeletonKnight='Orc',DeathKnight='Orc',Lich='KingShaman',LichSovereign='KingShaman',DreadCommander='EnragedWarlord',Veyr='EnragedWarlord'}
for kind,source in pairs(aliases)do Clips.models[kind]=Clips.models[source]end
local GloamMotion=require(script.Parent.GloamwoodMotion)
local HitReaction=require(script.Parent.K0EnemyHitReaction)
local WeaponMotion=require(script.Parent.K0EnemyWeaponMotion)
local CasterMotion=require(script.Parent.RegionalCasterMotion)
local Motion={}
local channels={'body','weapon','off','rightLeg','leftLeg'}
local names={weapon='Left Shoulder',off='Right Shoulder',rightLeg='Right Hip',leftLeg='Left Hip'}
local meshNames={weapon='ArmR',off='ArmL',rightLeg='LegL',leftLeg='LegR'}
local function clamp(x,a,b)return math.max(a,math.min(b,x))end
local function mix(a,b,t)
 local out={} for _,ch in ipairs(channels)do out[ch]={};for i,v in ipairs(a[ch])do out[ch][i]=v+(b[ch][i]-v)*t end end return out
end
function Motion.sample(kind,clip,phase)
 local profile=Clips.models[kind] or Clips.models.Goblin
 local data=profile.clips[clip] or profile.clips.Attack;local count=Clips.samples-1;local f=clamp(phase,0,1)*count;local n=math.min(count,math.floor(f));local a=f-n;local out={}
 for _,ch in ipairs(channels)do
  out[ch]={};local x,y=data[ch][n+1],data[ch][math.min(n+2,Clips.samples)]
  for i,v in ipairs(x)do out[ch][i]=v+(y[i]-v)*a end
 end
 return out
end
function Motion.attackPhase(age,w,a,r)
 local times={0,w*.55,w*.8,w,w+a,w+a+r};local phases={0,.4,.5,.62,.78,1}
 for i=2,#times do if age<=times[i]then return phases[i-1]+(phases[i]-phases[i-1])*clamp((age-times[i-1])/math.max(.001,times[i]-times[i-1]),0,1)end end
 return 1
end
local function frame(v,offset)
 offset=offset or 1;return CFrame.Angles(math.rad(v[offset]),math.rad(v[offset+1]),math.rad(v[offset+2]))
end
local function corners(part,anchor)
 local cf=anchor.CFrame:ToObjectSpace(part.CFrame);local out={}
 for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do table.insert(out,cf:PointToWorldSpace(part.Size*Vector3.new(x,y,z)*.5))end end end
 return out
end
local function lowest(cf,points,scale,center)
 local bottom=math.huge
 for _,v in ipairs(points)do bottom=math.min(bottom,cf:PointToWorldSpace(scale and center+(v-center)*scale or v).Y)end
 return bottom
end
function Motion.bind(model)
 local root=model:FindFirstChild('HumanoidRootPart');local torso=model:FindFirstChild('Torso');local visual=model:FindFirstChild('TdMonsterVisual')
 local joint=root and root:FindFirstChild('RootJoint');local body=visual and visual:FindFirstChild('Body')
 if not root or not torso or not joint or not body then return nil end
 local kind=model:GetAttribute('EnemyKind');local profile=Clips.models[kind];if not profile then return nil end
 local seed=model:GetAttribute('K0EnemyMotionSeed') or (math.abs(root.Position.X*.13+root.Position.Z*.17)%1)
 local s={model=model,root=root,torso=torso,joint=joint,kind=kind,profile=profile,height=model:GetAttribute('TdMonsterTargetHeight') or 5,
  phase=seed%1,seed=seed,position=root.Position,look=root.CFrame.LookVector,move=0,turn=0,joints={},legs={},body=body,bodySize=body.Size,
  bodyPoints=corners(body,torso),bodyCenter=torso.CFrame:PointToObjectSpace(body.Position),pose=Motion.sample(kind,'Idle',seed%1)}
 local rest=joint.C0*joint.C1:Inverse();s.bodyBottom=lowest(rest,s.bodyPoints)
 for ch,name in pairs(names)do
  local weaponArm=model:GetAttribute('TdWeaponArm') or 'ArmR'
  local swapped=weaponArm=='ArmL' and not profile.quadruped
  if swapped and ch=='weapon' then name='Right Shoulder' elseif swapped and ch=='off' then name='Left Shoulder' end
  local meshName=swapped and (ch=='weapon' and 'ArmL' or ch=='off' and 'ArmR') or meshNames[ch]
  local motor=torso:FindFirstChild(name);local part=visual:FindFirstChild(profile.quadruped and ({weapon='LegFR',off='LegFL',rightLeg='LegBL',leftLeg='LegBR'})[ch] or meshName)
  if motor and part then s.joints[ch]=motor
   if profile.quadruped or ch=='rightLeg' or ch=='leftLeg'then
    local points=corners(part,motor.Part1);s.legs[ch]={points=points,bottom=lowest(rest*motor.C0*motor.C1:Inverse(),points)}
   end
  end
 end
 s.gloam=GloamMotion.bind(model)
 s.caster=CasterMotion.bind(model,visual,s.height)
 if model:GetAttribute('TdSkinnedCaster') and not s.caster then return nil end
 s.weaponFX=WeaponMotion.bind(model,s.caster)
 return s
end
function Motion.step(s,dt,current)
 dt=clamp(dt,0,.25)
 if s.caster then
  local humanoid=s.model:FindFirstChildOfClass('Humanoid')
  if not humanoid or humanoid.Health<=0 or s.model:GetAttribute('K0EnemyState')=='Dead'then WeaponMotion.hide(s.weaponFX);return end
  local phase,active,heavy,clock,jumped=CasterMotion.step(s.caster,s,dt,current,Motion.attackPhase)
  s.caster.bones.Root.Transform=s.caster.pose.Root*HitReaction.sample(s.model,current)
  WeaponMotion.step(s.weaponFX,phase,active,heavy,clock,current,s.viewDistance or 0,jumped)
  return
 end
 local delta=s.root.Position-s.position;local distance=Vector3.new(delta.X,0,delta.Z).Magnitude;s.position=s.root.Position
 local state=s.model:GetAttribute('K0EnemyState');local alive=s.model:FindFirstChildOfClass('Humanoid')
 if state=='Dead' or not alive or alive.Health<=0 then WeaponMotion.hide(s.weaponFX);return end
 local stunned=(s.model:GetAttribute('K0EnemyStunUntil') or 0)>current
  or (s.model:GetAttribute('K0EnemyHitUntil') or 0)>current
 local moving=not stunned and state=='Chase' and distance<math.max(3,s.height*1.5)
 local speed=dt>0 and distance/dt or 0
 if moving then s.phase=(s.phase+distance/(s.height*s.profile.stride))%1 end
 local targetMove=moving and clamp(speed/2,0,1) or 0;s.move=s.move+(targetMove-s.move)*(1-math.exp(-dt*14))
 local target=Motion.sample(s.kind,'Idle',(current/s.profile.breathSeconds+s.seed)%1)
 if s.move>.001 then target=mix(target,Motion.sample(s.kind,'Walk',s.phase),s.move)end
 local clock=s.model:GetAttribute('K0EnemyAttackClock')
 if clock~=s.clock then
  s.clock=clock;s.attack=nil
  if type(clock)=='string' then
   local v=string.split(clock,'|');local start,w,a,r=tonumber(v[2]),tonumber(v[3]),tonumber(v[4]),tonumber(v[5])
   if start and w and a and r and w>0 and a>0 and r>0 then
    local clip=v[6]=='1' and 'Heavy' or 'Attack'
    if (tonumber(v[1]) or 1)%2==0 then clip..='Alt'end
    s.attack={start=start,w=w,a=a,r=r,clip=clip,heavy=v[6]=='1'}
   end
  end
 end
 local attackActive=not stunned and state~='Exposed' and s.attack and (state=='Windup' or state=='Active' or state=='Recovery')
 local attackPhase=0
 if stunned or state=='Exposed' then target=Motion.sample(s.kind,'Stunned',(current*.65+s.seed)%1)
 elseif s.attack and (state=='Windup' or state=='Active' or state=='Recovery') then
  local a=s.attack;attackPhase=Motion.attackPhase(current-a.start,a.w,a.a,a.r);target=Motion.sample(s.kind,a.clip,attackPhase)
 end
 GloamMotion.step(s.gloam,s.model,current,moving,attackActive and attackPhase or nil)
 -- Attack timing is sampled directly; smoothing it would delay the impact.
 -- Reviewed gaits are already continuous distance samples. A second pose lerp
 -- shifts the feet behind their stance phase at running speed and causes skating.
 if attackActive or (s.profile.reviewedGait and moving and speed>.2) then s.pose=target
 else s.pose=mix(s.pose,target,1-math.exp(-dt*16))end
 local p=s.pose;local b=p.body;local look=s.root.CFrame.LookVector
 local cross=s.look:Cross(look).Y;s.look=look;s.turn=s.turn+(clamp(cross/math.max(dt,.001),-2,2)-s.turn)*(1-math.exp(-dt*9))
 local rootFrame=CFrame.new(b[1]*s.height,b[2]*s.height,b[3]*s.height)*frame(b,4)*CFrame.Angles(0,0,-s.turn*.025*s.move)
 rootFrame=rootFrame*HitReaction.sample(s.model,current)
 local bodyInRoot=s.joint.C0*rootFrame*s.joint.C1:Inverse()
 if not s.profile.hasLegs then
  -- Robes/one-piece bodies keep their lower bound planted. Slime scales from
  -- its feet, with authored lift above that baseline; no collision resizing.
  local scale=(s.kind=='Slime' or s.profile.squash) and Vector3.new(b[7],b[8],b[9]) or nil
  local offset=s.bodyBottom-lowest(bodyInRoot,s.bodyPoints,scale,s.bodyCenter)+((s.kind=='Slime' or s.profile.squash or s.profile.lift) and b[2]*s.height or 0)
  rootFrame=CFrame.new(0,offset,0)*rootFrame
  bodyInRoot=s.joint.C0*rootFrame*s.joint.C1:Inverse()
  if scale then s.body.Size=s.bodySize*scale end
 end
 s.joint.Transform=rootFrame
 for ch,motor in pairs(s.joints)do
  local angles=p[ch]
  if ch=='weapon' and s.model:GetAttribute('TdWeaponSwingReversed') then angles={-angles[1],angles[2],-angles[3]} end
  local transform=frame(angles);local leg=s.legs[ch]
  if leg then
   local cf=bodyInRoot*motor.C0*transform*motor.C1:Inverse()
   local swing=(ch=='rightLeg' or s.profile.quadruped and ch=='weapon') and math.max(0,math.sin(s.phase*math.pi*2)) or math.max(0,-math.sin(s.phase*math.pi*2))
   local lift=swing*swing*.025*s.height*s.move
   if s.profile.reviewedGait then
    -- Stance occupies 60% of each leg's cycle; only the returning foot lifts.
    -- A previous chase phase must never lift a foot during attacks or stuns.
    local opposite=ch=='leftLeg' or (s.profile.quadruped and ch=='off')
    local phase=(s.phase+(opposite and .5 or 0))%1
    local returning=phase>.6 and math.sin((phase-.6)/.4*math.pi) or 0
    lift=(moving and not attackActive and not stunned and state~='Exposed') and returning*returning*.025*s.height*s.move or 0
   end
   local correction=leg.bottom+lift-lowest(cf,leg.points)
   local localUp=(bodyInRoot*motor.C0).UpVector.Y
   transform=CFrame.new(0,correction/math.max(.5,localUp),0)*transform
  end
  motor.Transform=transform
 end
 WeaponMotion.step(s.weaponFX,attackPhase,attackActive,s.attack and s.attack.heavy,clock,current,s.viewDistance or 0,distance>math.max(3,s.height*1.5))
end
function Motion.unbind(s)
 CasterMotion.reset(s.caster)
 WeaponMotion.destroy(s.weaponFX);s.weaponFX=nil
 if s.body.Parent then s.body.Size=s.bodySize end
 if s.joint.Parent then s.joint.Transform=CFrame.identity end
 for _,motor in pairs(s.joints)do if motor.Parent then motor.Transform=CFrame.identity end end
end
function Motion.start(enemies)
 local rigs,pending={},{}
 local function queue(m)
  if rigs[m] or pending[m] or m.Parent~=enemies then return end;pending[m]=true
  task.defer(function()pending[m]=nil;if m.Parent==enemies and not rigs[m] then local s=Motion.bind(m);if s then rigs[m]=s end end end)
 end
 local added=enemies.ChildAdded:Connect(queue)
 local descendants=enemies.DescendantAdded:Connect(function(o)local m=o;while m.Parent and m.Parent~=enemies do m=m.Parent end;if m.Parent==enemies then queue(m)end end)
 local removed=enemies.ChildRemoved:Connect(function(m)if rigs[m]then Motion.unbind(rigs[m])end;rigs[m]=nil;pending[m]=nil end)
 for _,m in ipairs(enemies:GetChildren())do queue(m)end
 local frameConnection=RunService.PreSimulation:Connect(function(dt)
  local current=Workspace:GetServerTimeNow();local camera=Workspace.CurrentCamera
  for model,s in pairs(rigs)do
   if not model.Parent then Motion.unbind(s);rigs[model]=nil
   else
    s.viewDistance=camera and (camera.CFrame.Position-s.root.Position).Magnitude or 0
    if s.viewDistance<260 then Motion.step(s,dt,current)
    else s.position=s.root.Position;WeaponMotion.hide(s.weaponFX)end
   end
  end
 end)
 return function()added:Disconnect();descendants:Disconnect();removed:Disconnect();frameConnection:Disconnect();for _,s in pairs(rigs)do Motion.unbind(s)end;table.clear(rigs);table.clear(pending)end
end
return Motion
