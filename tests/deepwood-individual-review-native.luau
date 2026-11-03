-- Behavioral regressions found during per-species native/Blender review.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.K0EnemyClips);local Field=require(Server.World.TrainingField)
local report={kind='DEEPWOOD_INDIVIDUAL_REVIEW_NATIVE',checks=0,failures={},species={}}
local function check(value,message)report.checks+=1;assert(value,message)end
local folder=Instance.new('Folder');folder.Name='IndividualMotionAcceptance';folder.Parent=workspace
local function sole(s,ch)
 local leg=s.legs[ch];local motor=s.joints[ch];local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
 local cf=body*motor.C0*motor.Transform*motor.C1:Inverse();local bottom=math.huge
 for _,v in ipairs(leg.points)do bottom=math.min(bottom,cf:PointToWorldSpace(v).Y)end
 return bottom
end
local ok,err=xpcall(function()
 for kind,profile in pairs(Clips.models)do
  local m=Field.makeEnemy(folder,kind,10000,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m));local root=m.HumanoidRootPart;local original=root.CFrame;local hp=m.Humanoid.Health
  local row={maxStoppedFootLift=0};report.species[kind]=row
  -- Enter attacks/stuns with either leg mid-swing; the previous gait must not leak into the pose.
  for _,phase in ipairs({.15,.35,.65,.85})do
   for _,state in ipairs({'Windup','Active','Recovery','Stunned','Exposed'})do
    s.phase=phase;s.move=1;m:SetAttribute('K0EnemyState',state)
    m:SetAttribute('K0EnemyAttackClock','1|1000|1|0.2|0.8|0');m:SetAttribute('K0EnemyStunUntil',state=='Stunned'and 2000 or nil)
    Motion.step(s,1/60,1001)
    for ch,leg in pairs(s.legs)do
     local gap=sole(s,ch)-leg.bottom;row.maxStoppedFootLift=math.max(row.maxStoppedFootLift,math.abs(gap))
     check(math.abs(gap)<.002,kind..' '..state..' plants both feet regardless of old gait phase')
    end
   end
  end
  m:SetAttribute('K0EnemyStunUntil',nil)
  for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
   local poses={}
   for _,hz in ipairs({30,60,144})do
    local q=assert(Motion.bind(m));m:SetAttribute('K0EnemyState','Windup')
    m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|3000|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0'))
    Motion.step(q,1/hz,3001);table.insert(poses,q.pose)
    local hit=Motion.sample(kind,clip,.62)
    for _,ch in ipairs(Clips.channels)do for i,v in ipairs(hit[ch])do check(math.abs(q.pose[ch][i]-v)<.001,kind..' exact contact at '..hz..'Hz')end end
    check(root.CFrame==original and m.Humanoid.Health==hp,'pose cannot change server root/health')
    Motion.unbind(q)
   end
  end
  if profile.hasLegs then
   local p=Motion.sample(kind,'Walk',.2);local guard=Motion.sample(kind,'Idle',0).weapon[1]
   local opposite=kind=='Warlord'and p.leftLeg[1]or p.rightLeg[1]
   check((p.weapon[1]-guard)*opposite>0,kind..' anatomical arm counter-swings opposite its own leg')
   check(p.rightLeg[1]*p.leftLeg[1]<0,kind..' legs alternate rather than march together')
   m:SetAttribute('K0EnemyState','Chase');m:SetAttribute('K0EnemyAttackClock',nil)
   s.phase=0;s.move=1;s.position=root.Position
   local leg=s.legs.rightLeg;local point=Vector3.zero;local minY=math.huge
   for _,v in ipairs(leg.points)do point+=v;minY=math.min(minY,v.Y)end
   point=point/#leg.points;point=Vector3.new(point.X,minY,point.Z)
   local low,high=math.huge,-math.huge;local cycle=profile.stride*s.height/6;local motor=s.joints.rightLeg
   for frame=1,120 do
    local t=frame/120;root.CFrame=original*CFrame.new(0,0,-profile.stride*s.height*t)
    Motion.step(s,cycle/120,4000+cycle*t)
    if t>=.125 and t<=.5 then
     local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
     local solePoint=(root.CFrame*body*motor.C0*motor.Transform*motor.C1:Inverse()):PointToWorldSpace(point)
     low=math.min(low,solePoint.Z);high=math.max(high,solePoint.Z)
    end
   end
   row.stanceSlipHeightFraction=(high-low)/s.height
   check(row.stanceSlipHeightFraction<.03,kind..' planted foot drift stays below 3% of body height at 6 studs/s')
   root.CFrame=original

  end
  Motion.unbind(s);m:Destroy()
 end
 local frozen=require(Client.FrozenValeClips);check(not frozen.models.IceWolf.reviewedGait,'other epic authored gait contracts unchanged')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();Run:Stop();report.pass=#report.failures==0
print('DEEPWOOD_INDIVIDUAL_REVIEW_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'individual review acceptance failed')
