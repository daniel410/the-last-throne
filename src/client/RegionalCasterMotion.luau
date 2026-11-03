-- Deterministic imported Bone curves, driven by the existing server attack clock.
local Clips=require(script.Parent.RegionalCasterClips)
local Sockets=require(script.Parent.RegionalCasterSockets)
local Caster={}
local names={'Root','Torso','UpperR','ForearmR','HandR','Staff','UpperL','ForearmL','HandL'}
local function scale(cf,height)return CFrame.new(cf.Position*height)*cf.Rotation end
function Caster.sample(kind,clip,phase,height)
 local data=assert(Clips[kind][clip]);local frames=data.frames
 local t=math.clamp(phase,0,1)*data.duration;local i=1
 while i<#frames-1 and frames[i+1].time<t do i+=1 end
 local a,b=frames[i],frames[i+1];local alpha=math.clamp((t-a.time)/math.max(.000001,b.time-a.time),0,1)
 local pose={};for _,name in names do pose[name]=scale(a.pose[name]:Lerp(b.pose[name],alpha),height or 1)end
 return pose
end
function Caster.bind(model,visual,height)
 if not model:GetAttribute('TdSkinnedCaster')then return nil end
 local kind=model:GetAttribute('EnemyKind');if not Clips[kind]then return nil end
 local bones={};for _,b in visual:GetDescendants()do if b:IsA('Bone')then bones[b.Name]=b end end
 for _,name in names do if not bones[name]then return nil end end
 if not visual:FindFirstChild('Staff') or not visual:FindFirstChild('VisualRoot')then return nil end
 local pose=Caster.sample(kind,'Idle',0,height)
 local socket=Sockets[kind];local origin=visual.VisualRoot.CFrame
 local basis=Vector3.new(-1,1,-1)
 local tip=bones.Staff.WorldCFrame:PointToObjectSpace(origin:PointToWorldSpace(socket.tip*basis*height))
 local base=bones.Staff.WorldCFrame:PointToObjectSpace(origin:PointToWorldSpace(socket.base*basis*height))
 for _,name in names do bones[name].Transform=pose[name]end
 return {bones=bones,kind=kind,height=height,pose=pose,tip=tip,base=base,phase=0,position=model.HumanoidRootPart.Position}
end
function Caster.step(c,s,dt,current,attackPhase)
 local model=s.model;local state=model:GetAttribute('K0EnemyState')
 local stunned=(model:GetAttribute('K0EnemyStunUntil') or 0)>current or (model:GetAttribute('K0EnemyHitUntil') or 0)>current
 local distance=(s.root.Position-c.position).Magnitude;c.position=s.root.Position
 local moving=state=='Chase' and not stunned and distance<math.max(3,c.height*1.5)
 if moving then c.phase=(c.phase+distance/(c.height*s.profile.stride))%1 end
 local clip=moving and 'Walk' or 'Idle';local phase=moving and c.phase or (current/s.profile.breathSeconds+s.seed)%1
 local clock=model:GetAttribute('K0EnemyAttackClock')
 if clock~=c.clock then
  c.clock=clock;c.attack=nil
  if type(clock)=='string'then
   local v=string.split(clock,'|');local start,w,a,r=tonumber(v[2]),tonumber(v[3]),tonumber(v[4]),tonumber(v[5])
   if start and w and a and r and w>0 and a>0 and r>0 then
    local attackClip=v[6]=='1' and 'Heavy' or 'Attack';if (tonumber(v[1]) or 1)%2==0 then attackClip..='Alt'end
    c.attack={start=start,w=w,a=a,r=r,clip=attackClip,heavy=v[6]=='1'}
   end
  end
 end
 local active=not stunned and c.attack and (state=='Windup' or state=='Active' or state=='Recovery')
 if stunned then clip='Stunned';phase=(current*.65+s.seed)%1
 elseif state=='Exposed'then clip='Exposed';phase=(current*.65+s.seed)%1
 elseif active then clip=c.attack.clip;phase=attackPhase(current-c.attack.start,c.attack.w,c.attack.a,c.attack.r)end
 -- On a state change, blend from the actual current pose. This also handles
 -- interruption at arbitrary attack times rather than replaying a fixed windup.
 local key=active and ('attack:'..tostring(clock)) or clip
 if key~=c.key then c.key=key;c.from=table.clone(c.pose);c.transition=current end
 local target=Caster.sample(c.kind,clip,phase,c.height)
 local alpha=math.clamp((current-(c.transition or current))/.1,0,1)
 local contact=active and phase>=.5
 for _,name in names do
  local frame=contact and target[name] or c.from and c.from[name]:Lerp(target[name],alpha)or target[name]
  c.bones[name].Transform=frame;c.pose[name]=frame
 end
 c.clip=clip;c.samplePhase=phase;c.active=active==true
 s.attack=c.attack;s.position=s.root.Position
 return phase,active==true,c.attack and c.attack.heavy,clock,distance>math.max(3,c.height*1.5)
end
function Caster.reset(c)
 if not c then return end
 for _,b in c.bones do if b.Parent then b.Transform=CFrame.identity end end
end
return Caster
