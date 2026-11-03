-- Real TD meshes and Motor6Ds, only in an isolated local place with no real players.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.HauntedGraveyardClips)
local Rigs=require(game.ReplicatedStorage.Shared.HauntedGraveyardRigs)
local Field=require(Server.World.TrainingField);local Combat=require(game.ReplicatedStorage.Shared.LateEpicCombat)
local folder=Instance.new('Folder');folder.Name='HauntedMotionAcceptance';folder.Parent=workspace
local report={kind='HAUNTED_MONSTER_MOTION_NATIVE',checks=0,species={},failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function bodyCF(s)return s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()end
local function bottom(cf,points)local y=math.huge;for _,p in ipairs(points)do y=math.min(y,cf:PointToWorldSpace(p).Y)end;return y end
local function sole(s,ch)return bottom(bodyCF(s)*s.joints[ch].C0*s.joints[ch].Transform*s.joints[ch].C1:Inverse(),s.legs[ch].points)end
local ok,err=xpcall(function()
 check(next(Clips.models)==nil,'HG sampled tables stay unloaded until their first regional model')
 for _,kind in ipairs(Clips.kinds)do
  local profile=Clips.get(kind)
  local m=Field.makeEnemy(folder,kind,10000,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m),kind..' motion binding');local root=m.HumanoidRootPart;local original=root.CFrame;local hp=m.Humanoid.Health
  local row={source=Rigs[kind].template,maxStoppedFootLift=0};report.species[kind]=row
  check(m:GetAttribute('TdMonsterTemplate')==Rigs[kind].template,'original TD template retained')
  check(s.profile==profile,'dedicated HG profile replaces unrelated species alias')
  check(s.profile.hasLegs==(m.TdMonsterVisual:FindFirstChild('LegL')~=nil or m.TdMonsterVisual:FindFirstChild('LegBL')~=nil),'profile matches actual independent legs')
  check(s.profile.quadruped==(kind=='Hellhound'),'only Hellhound uses diagonal quadruped gait')
  for clip,channels in pairs(profile.clips)do for ch,samples in pairs(channels)do
   check(#samples==201,'201 evaluated F-curve samples')
   for _,v in ipairs(samples)do for _,x in ipairs(v)do check(x==x and math.abs(x)<10000,'finite bounded pose')end end
   if clip=='Idle'or clip=='Walk'or clip=='Stunned'then for i,v in ipairs(samples[1])do check(math.abs(v-samples[201][i])<.00001,'seamless loop')end end
  end end
  if profile.groundPoints then check(#s.bodyPoints>=3 and #s.bodyPoints<=64,'bounded real lower-surface support samples')end
  if profile.rigidArms then for _,clip in pairs(profile.clips)do for _,ch in ipairs({'weapon','off'})do for _,values in ipairs(clip[ch])do for _,x in ipairs(values)do check(x==0,'fused garments/weapons keep one anchor')end end end end end
  for _,phase in ipairs({.15,.35,.65,.85})do
   for _,state in ipairs({'Windup','Active','Recovery','Stunned','Exposed'})do
    s.phase=phase;s.move=1;m:SetAttribute('K0EnemyState',state);m:SetAttribute('K0EnemyAttackClock','1|1000|1|0.2|0.8|0');m:SetAttribute('K0EnemyStunUntil',state=='Stunned'and 2000 or nil)
    Motion.step(s,1/60,1001)
    for ch,leg in pairs(s.legs)do local gap=sole(s,ch)-leg.bottom;row.maxStoppedFootLift=math.max(row.maxStoppedFootLift,math.abs(gap));check(math.abs(gap)<.002,'old walk phase cannot lift a planted attack/stunned foot')end
   end
  end
  m:SetAttribute('K0EnemyStunUntil',nil)
  for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
   local attack=Combat.profiles[kind].attacks[clip:find('Heavy')and 2 or 1]or Combat.profiles[kind].attacks[1]
   for _,hz in ipairs({30,60,144})do
    local q=assert(Motion.bind(m));m:SetAttribute('K0EnemyState','Windup')
    m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|3000|'..attack.windup..'|'..attack.active..'|'..attack.recovery..'|'..(clip:find('Heavy')and'1'or'0'))
    Motion.step(q,1/hz,3000+attack.windup)
    local hit=Motion.sample(kind,clip,.62)
    for _,ch in ipairs(Clips.channels)do for i,v in ipairs(hit[ch])do check(math.abs(q.pose[ch][i]-v)<.001,'native contact aligns to unchanged server windup at '..hz..'Hz')end end
    check(root.CFrame==original and m.Humanoid.Health==hp,'presentation cannot move authoritative root or change health')
    if not profile.hasLegs then check(math.abs(bottom(bodyCF(q),q.bodyPoints)-q.bodyBottom)<.002,'fused lower surface remains grounded at contact')end
    if q.weaponFX then check(q.weaponFX.trail.Enabled,'weapon/focus accent appears only at server-aligned contact');m:SetAttribute('K0EnemyState','Idle');m:SetAttribute('K0EnemyAttackClock',nil);Motion.step(q,1/hz,3010);check(not q.weaponFX.trail.Enabled,'no idle weapon trail')end
    Motion.unbind(q)
   end
  end
  if kind=='Skeleton'or kind=='SkeletonKnight'then
   check(m:GetAttribute('TdWeaponArm')=='ArmL'and s.joints.weapon.Name=='Right Shoulder','sword arm, not shield, owns the attack')
   row.bladeForwardTravel={}
   for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
    m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|6000|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0'))
    local function tip(now)Motion.step(s,1/60,now);local motor=s.joints.weapon;return (bodyCF(s)*motor.C0*motor.Transform*motor.C1:Inverse()*s.weaponFX.socketInArm).Position end
    local ready,contact=tip(6000.8),tip(6001);row.bladeForwardTravel[clip]=ready.Z-contact.Z
    check(ready.Z-contact.Z>.05,'actual blade tip moves toward enemy at contact')
   end
  end
  if profile.hasLegs then
   local p=Motion.sample(kind,'Walk',.2);check(p.rightLeg[1]*p.leftLeg[1]<0,'opposite legs alternate')
   if profile.quadruped then check(math.abs(p.weapon[1]-p.rightLeg[1])<.001 and math.abs(p.off[1]-p.leftLeg[1])<.001,'diagonal limbs share phase')end
   m:SetAttribute('K0EnemyState','Chase');m:SetAttribute('K0EnemyAttackClock',nil);s.phase=0;s.move=1;s.position=root.Position
   local leg=s.legs.rightLeg;local point=Vector3.zero;local minY=math.huge
   for _,v in ipairs(leg.points)do point+=v;minY=math.min(minY,v.Y)end;point=point/#leg.points;point=Vector3.new(point.X,minY,point.Z)
   local low,high=math.huge,-math.huge;local cycle=profile.stride*s.height/6;local motor=s.joints.rightLeg
   for frame=1,120 do local t=frame/120;root.CFrame=original*CFrame.new(0,0,-profile.stride*s.height*t);Motion.step(s,cycle/120,4000+cycle*t)
    if t>=.125 and t<=.5 then local v=(root.CFrame*bodyCF(s)*motor.C0*motor.Transform*motor.C1:Inverse()):PointToWorldSpace(point);low=math.min(low,v.Z);high=math.max(high,v.Z)end
   end
   row.stanceSlipHeightFraction=(high-low)/s.height;check(row.stanceSlipHeightFraction<.03,'stance-foot drift below 3% of height at 6 studs/s');root.CFrame=original
  elseif profile.rigidArms then
   local a,b=Motion.sample(kind,'Attack',.4).body,Motion.sample(kind,'Attack',.62).body
   check(math.abs(a[3]-b[3])>.02 and math.abs(a[4]-b[4])>3,'fused monster still has a readable preparation/contact difference')
  end
  if kind=='Lich'or kind=='LichSovereign'then check(s.weaponFX and #s.weaponFX.shards==3,'staff focus is attached to actual TD staff part')end
  Motion.unbind(s);m:Destroy();task.wait()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();Run:Stop();report.pass=ok
print('HAUNTED_MONSTER_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
