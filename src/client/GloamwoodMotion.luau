-- Blender-authored per-species skin curves; no collision, damage or root movement.
local PatternPose=require(script.Parent.EnemyPatternPose)
local HitReaction=require(script.Parent.K0EnemyHitReaction)
local M={}
local cache={}
local function dataFor(kind)
 if not cache[kind]then
  local module=script.Parent.GloamwoodClips:FindFirstChild(kind)
  if not module then return nil end
  cache[kind]=require(module)
 end
 return cache[kind]
end
function M.sample(kind,clip,phase,scale)
 local data=assert(dataFor(kind),'Missing Gloamwood motion data');local c=assert(data.clips[clip])
 local frame=math.clamp(phase,0,1)*40;local i=math.min(40,math.floor(frame));local alpha=frame-i
 local pose={}
 for _,name in data.bones do
  local track=c.tracks[name];local cf=track and track[i+1]:Lerp(track[math.min(41,i+2)],alpha)or CFrame.identity
  pose[name]=CFrame.new(cf.Position*(scale or 1))*cf.Rotation
 end
 return pose
end
function M.bind(model)
 if not model:GetAttribute('GloamwoodMeshyVersion')then return nil end
 local kind=model:GetAttribute('EnemyKind');local data=dataFor(kind);local visual=model:FindFirstChild('TdMonsterVisual')
 if not data or not visual then return nil end
 local bones={}
 for _,b in visual:GetDescendants()do if b:IsA('Bone')then bones[b.Name]=b end end
 for _,name in data.bones do if not bones[name]then return nil end end
 local scale=model:GetAttribute('TdMonsterScale')or 1
 return {skinned=true,kind=kind,bones=bones,data=data,scale=scale,position=model.HumanoidRootPart.Position,phase=0,pose=M.sample(kind,'Idle',0,scale)}
end
function M.reset(c)
 if not c then return end
 for _,b in c.bones do if b.Parent then b.Transform=CFrame.identity end end
end
function M.stepSkinned(c,s,dt,current,attackPhase)
 local model=s.model;local state=model:GetAttribute('K0EnemyState');local humanoid=model:FindFirstChildOfClass('Humanoid')
 if not humanoid or humanoid.Health<=0 or state=='Dead'then M.reset(c);return end
 local distance=(s.root.Position-c.position).Magnitude;c.position=s.root.Position;s.position=c.position
 local stunned=(model:GetAttribute('K0EnemyStunUntil')or 0)>current or (model:GetAttribute('K0EnemyHitUntil')or 0)>current
 local moving=state=='Chase' and not stunned and distance>.001 and distance<math.max(3,s.height*1.5)
 if moving then c.phase=(c.phase+distance/math.max(.5,s.height*.7))%1 end
 local clip=moving and 'Walk'or 'Idle';local phase=moving and c.phase or (current/c.data.clips.Idle.duration+s.seed)%1
 local clock=model:GetAttribute('K0EnemyAttackClock')
 if clock~=c.clock then
  c.clock=clock;c.attack=nil
  if type(clock)=='string'then
   local v=string.split(clock,'|');local start,w,a,r=tonumber(v[2]),tonumber(v[3]),tonumber(v[4]),tonumber(v[5])
   if start and w and a and r and w>0 and a>0 and r>0 then
    local name=v[6]=='1' and 'Heavy'or 'Attack';if (tonumber(v[1])or 1)%2==0 then name..='Alt'end
    c.attack={start=start,w=w,a=a,r=r,clip=name,heavy=v[6]=='1'}
   end
  end
 end
 local active=not stunned and c.attack and (state=='Windup'or state=='Active'or state=='Recovery')
 if stunned then clip='Stunned';phase=(current/.7+s.seed)%1
 elseif state=='Exposed'then clip='Exposed';phase=(current+s.seed)%1
 elseif active then clip=c.attack.clip;phase=PatternPose.phase(model,current,c.attack)or attackPhase(current-c.attack.start,c.attack.w,c.attack.a,c.attack.r)end
 local key=active and 'attack:'..tostring(clock)or clip
 if key~=c.key then c.key=key;c.from=table.clone(c.pose);c.transition=current end
 local target=M.sample(c.kind,clip,phase,c.scale)
 local alpha=math.clamp((current-(c.transition or current))/.10,0,1)
 for _,name in c.data.bones do
  local cf=active and phase>=.5 and target[name]or c.from and c.from[name]:Lerp(target[name],alpha)or target[name]
  c.pose[name]=cf;c.bones[name].Transform=cf
 end
 -- Imported Root has a baked 180-degree rest rotation; convert reactions once.
 -- Legacy R6 bob/squash is bypassed for skinned monsters.
 local basis=c.bones.Root.CFrame.Rotation
 c.bones.Root.Transform=c.pose.Root*basis:Inverse()*HitReaction.sample(model,current)*basis
 c.clip=clip;c.samplePhase=phase;c.active=active==true;s.attack=c.attack
end
return M
