-- Per-pulse mesh-facing continuity, without rotating authoritative roots.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts:FindFirstChild('Client')
local Shared=game.ReplicatedStorage.Shared
local P=deps and deps.EnemyPatterns or require(Shared.EnemyPatterns)
local Profiles=deps and deps.EnemyCombatProfiles or require(Shared.EnemyCombatProfiles)
local Frame=deps and deps.EnemyAttackFrame or require(Shared.EnemyAttackFrame)
local Snapshot=deps and deps.EnemyPatternDefinition or require(Client.EnemyPatternDefinition)
local Pose=deps and deps.EnemyPatternPose or require(Client.EnemyPatternPose)
local checks,casts,sampled=0,0,0
local function check(v,m)checks+=1;assert(v,m)end
local function wrap(angle)return (angle+math.pi)%(math.pi*2)-math.pi end
local model=Instance.new('Model');model.Name='EnemyDirectionQA';model.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CanCollide=false;root.Parent=model
local human=Instance.new('Humanoid');human.Parent=model
local origin=Vector3.new(0,4,0);local base=Vector3.new(.6,0,-.8)
root.CFrame=CFrame.lookAt(origin,origin+base)
local originalCF,originalHP=root.CFrame,human.Health
local seen={}
for kind,profile in pairs(P.profiles)do
 model:SetAttribute('EnemyKind',kind)
 for _,health in ipairs({1,.55,.2})do for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  for _,raw in ipairs(profile.attacks)do
   casts+=1
   local d=Profiles.resolve(kind,raw,mode,health)
   local a={d=d,origin=origin,direction=base,aim=origin+base*12+Vector3.yAxis*2,castOrigin=origin+Vector3.new(2,1,-.5)}
   model:SetAttribute('K0AttackSeq',casts);model:SetAttribute('K0PatternId',d.id)
   model:SetAttribute('K0PatternDefinition',game.HttpService:JSONEncode(d))
   Snapshot.message({kind='begin',model=model,id=d.id,sequence=casts,definition=d,origin=a.origin,direction=a.direction,aim=a.aim,castOrigin=a.castOrigin})
   local attack={start=0,w=d.windup,a=d.active,r=d.recovery}
   local signature={d.motion,d.motionStyle,d.windup,d.interval,d.recovery,d.pulses}
   for pulse=1,d.pulses do
    local at=d.windup+(pulse-1)*d.interval
    local _,_,direction=Frame.resolve(a,pulse)
    local flat=Vector3.new(direction.X,0,direction.Z).Unit
    local expected=math.atan2(base:Cross(flat).Y,base:Dot(flat))
    table.insert(signature,math.floor(expected*10000+.5))
    local actual=Pose.facingYaw(model,at,attack)
    check(math.abs(wrap(actual-expected))<.00001,'visual faces the actual committed pulse '..d.id)
    check(math.abs(Pose.phase(model,at,attack)-.62)<.00001,'direction and clip contact share the same pulse clock')
    local before=Pose.facingYaw(model,at-.00001,attack)
    local after=Pose.facingYaw(model,at+.00001,attack)
    check(math.abs(wrap(after-before))<.001,'no direction snap at repeated contact '..d.id)
    if d.motion=='cast'then
     local look=root.CFrame:VectorToWorldSpace(Pose.accent(model,at,attack).LookVector)
     look=Vector3.new(look.X,0,look.Z).Unit
     check(look:Dot(flat)>.99999,'the complete caster/staff hierarchy follows final socket-to-aim yaw')
    end
   end
   local key=table.concat(signature,'|')
   if not seen[key]then
    seen[key]=true;sampled+=1
    for _,hz in ipairs({30,60,144})do
     local previous=Pose.facingYaw(model,0,attack)
     for frame=1,math.ceil((d.windup+d.active+d.recovery)*hz)do
      local angle=Pose.facingYaw(model,frame/hz,attack)
      check(angle==angle and math.abs(wrap(angle-previous))<.36,'continuous preparation and recovery at '..hz..' Hz '..d.id)
      previous=angle
     end
    end
   end
   check(math.abs(wrap(Pose.facingYaw(model,100,attack)))<.00001,'visual facing returns to neutral')
  end
 end end
 task.wait()
end
check(root.CFrame==originalCF and human.Health==originalHP,'all facing changes preserve authoritative root and health')
model:Destroy()
print('ENEMY_DIRECTION_MOTION_NATIVE '..game.HttpService:JSONEncode({checks=checks,casts=casts,uniqueCurves=sampled,frameRates={30,60,144}}))
