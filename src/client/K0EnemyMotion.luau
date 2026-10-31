-- Local presentation from Blender MCP curves. The server owns roots and hits.
local RunService=game:GetService('RunService')
local Workspace=game:GetService('Workspace')
local Clips=require(script.Parent.K0EnemyClips)
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
 local data=profile.clips[clip];local f=clamp(phase,0,1)*60;local n=math.min(60,math.floor(f));local a=f-n;local out={}
 for _,ch in ipairs(channels)do
  out[ch]={};local x,y=data[ch][n+1],data[ch][math.min(n+2,61)]
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
  local motor=torso:FindFirstChild(name);local part=visual:FindFirstChild(meshNames[ch])
  if motor and part then s.joints[ch]=motor
   if ch=='rightLeg' or ch=='leftLeg'then
    local points=corners(part,motor.Part1);s.legs[ch]={points=points,bottom=lowest(rest*motor.C0*motor.C1:Inverse(),points)}
   end
  end
 end
 return s
end
function Motion.step(s,dt,current)
 dt=clamp(dt,0,.25)
 local delta=s.root.Position-s.position;local distance=Vector3.new(delta.X,0,delta.Z).Magnitude;s.position=s.root.Position
 local state=s.model:GetAttribute('K0EnemyState');local alive=s.model:FindFirstChildOfClass('Humanoid')
 if state=='Dead' or not alive or alive.Health<=0 then return end
 local stunned=(s.model:GetAttribute('K0EnemyStunUntil') or 0)>current
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
   if start and w and a and r and w>0 and a>0 and r>0 then s.attack={start=start,w=w,a=a,r=r,clip=v[6]=='1' and 'Heavy' or 'Attack'}end
  end
 end
 if stunned or state=='Exposed' then target=Motion.sample(s.kind,'Stunned',(current*.65+s.seed)%1)
 elseif s.attack and (state=='Windup' or state=='Active' or state=='Recovery') then
  local a=s.attack;target=Motion.sample(s.kind,a.clip,Motion.attackPhase(current-a.start,a.w,a.a,a.r))
 end
 -- Attack timing is sampled directly; smoothing it would delay the impact.
 if s.attack and not stunned and (state=='Windup' or state=='Active' or state=='Recovery') then s.pose=target else s.pose=mix(s.pose,target,1-math.exp(-dt*16))end
 local p=s.pose;local b=p.body;local look=s.root.CFrame.LookVector
 local cross=s.look:Cross(look).Y;s.look=look;s.turn=s.turn+(clamp(cross/math.max(dt,.001),-2,2)-s.turn)*(1-math.exp(-dt*9))
 local rootFrame=CFrame.new(b[1]*s.height,b[2]*s.height,b[3]*s.height)*frame(b,4)*CFrame.Angles(0,0,-s.turn*.025*s.move)
 local bodyInRoot=s.joint.C0*rootFrame*s.joint.C1:Inverse()
 if not s.profile.hasLegs then
  -- Robes/one-piece bodies keep their lower bound planted. Slime scales from
  -- its feet, with authored lift above that baseline; no collision resizing.
  local scale=s.kind=='Slime' and Vector3.new(b[7],b[8],b[9]) or nil
  local offset=s.bodyBottom-lowest(bodyInRoot,s.bodyPoints,scale,s.bodyCenter)+(s.kind=='Slime' and b[2]*s.height or 0)
  rootFrame=CFrame.new(0,offset,0)*rootFrame
  bodyInRoot=s.joint.C0*rootFrame*s.joint.C1:Inverse()
  if scale then s.body.Size=s.bodySize*scale end
 end
 s.joint.Transform=rootFrame
 for ch,motor in pairs(s.joints)do
  local transform=frame(p[ch]);local leg=s.legs[ch]
  if leg then
   local cf=bodyInRoot*motor.C0*transform*motor.C1:Inverse()
   local swing=ch=='rightLeg' and math.max(0,math.sin(s.phase*math.pi*2)) or math.max(0,-math.sin(s.phase*math.pi*2))
   local lift=swing*swing*.025*s.height*s.move
   local correction=leg.bottom+lift-lowest(cf,leg.points)
   local localUp=(bodyInRoot*motor.C0).UpVector.Y
   transform=CFrame.new(0,correction/math.max(.5,localUp),0)*transform
  end
  motor.Transform=transform
 end
end
function Motion.start(enemies)
 local rigs,pending={},{}
 local function queue(m)
  if rigs[m] or pending[m] or m.Parent~=enemies then return end;pending[m]=true
  task.defer(function()pending[m]=nil;if m.Parent==enemies and not rigs[m] then local s=Motion.bind(m);if s then rigs[m]=s end end end)
 end
 local added=enemies.ChildAdded:Connect(queue)
 local descendants=enemies.DescendantAdded:Connect(function(o)local m=o;while m.Parent and m.Parent~=enemies do m=m.Parent end;if m.Parent==enemies then queue(m)end end)
 local removed=enemies.ChildRemoved:Connect(function(m)rigs[m]=nil;pending[m]=nil end)
 for _,m in ipairs(enemies:GetChildren())do queue(m)end
 local frameConnection=RunService.PreSimulation:Connect(function(dt)
  local current=Workspace:GetServerTimeNow();local camera=Workspace.CurrentCamera
  for model,s in pairs(rigs)do
   if not model.Parent then rigs[model]=nil
   elseif not camera or (camera.CFrame.Position-s.root.Position).Magnitude<260 then Motion.step(s,dt,current)
   else s.position=s.root.Position end
  end
 end)
 return function()added:Disconnect();descendants:Disconnect();removed:Disconnect();frameConnection:Disconnect();table.clear(rigs);table.clear(pending)end
end
return Motion
