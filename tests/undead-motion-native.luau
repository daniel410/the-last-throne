-- Real refreshed meshes: complete sampled cycles, support surfaces and interruption.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
local Surface=assert(_G.TLTUndeadSurfacePoints,'inject pinned surface vertices with prepare-undead-motion-test.py')
local Run=game:GetService('RunService');Run:Run();task.wait(.5)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion)
local Clips=require(Client.HauntedGraveyardClips)
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local folder=Instance.new('Folder');folder.Parent=workspace
local report={kind='UNDEAD_INDIVIDUAL_MOTION_NATIVE',checks=0,species={},failures={}}
local function check(v,message)report.checks+=1;assert(v,message)end
local function age(p)
 local times={0,.55,.8,1,1.2,2};local points={0,.4,.5,.62,.78,1}
 for i=2,#points do if p<=points[i]then return times[i-1]+(times[i]-times[i-1])*(p-points[i-1])/(points[i]-points[i-1])end end
 return 2
end
local ok,err=xpcall(function()
 for _,kind in ipairs({'Zombie','Ghoul'})do
  local m=Field.makeEnemy(folder,kind,10000,10000,1,1)
  local root=m.HumanoidRootPart;root.Anchored=true
  local original=root.CFrame;local hp=m.Humanoid.Health
  local s=assert(Motion.bind(m));local profile=Clips.get(kind)
  local row={minimumSurfaceHeight=math.huge,clips=0,interruptionChecks=0}
  report.species[kind]=row
  check(not profile.rigidArms,'independent arms are no longer frozen')
  local floor=math.huge;local parts={}
  for _,part in ipairs(m.TdMonsterVisual:GetChildren())do if part:IsA('BasePart')then
   local rest=root.CFrame:ToObjectSpace(part.CFrame)
   floor=math.min(floor,rest.Y-part.Size.Y/2)
   local anchor=part.TdVisualWeld.Part0
   local points={};for _,p in ipairs(Surface[kind][part.Name])do table.insert(points,Vector3.new(p[1],p[2],p[3])*part.Size)end
   parts[part.Name]={part=part,anchor=anchor,localCF=anchor.CFrame:ToObjectSpace(part.CFrame),points=points}
  end end
  for _,clip in ipairs({'Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned'})do
   row.clips+=1
   for n=0,200 do
    local phase=n/200
    s.pose=Motion.sample(kind,clip,phase);s.move=clip=='Walk'and 1 or 0;s.phase=phase
    m:SetAttribute('K0EnemyState',clip=='Walk'and'Chase'or clip=='Idle'and'Idle'or clip=='Stunned'and'Stunned'or'Windup')
    m:SetAttribute('K0EnemyStunUntil',clip=='Stunned'and 2000 or nil)
    m:SetAttribute('K0EnemyAttackClock',(clip=='Idle'or clip=='Walk'or clip=='Stunned')and nil or ((clip:find('Alt')and'2'or'1')..'|100|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0')))
    Motion.step(s,0,100+age(phase))
    local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
    for name,part in pairs(parts)do
     local cf=body
     for _,motor in ipairs(m.Torso:GetChildren())do if motor:IsA('Motor6D')and motor.Part1==part.anchor then cf=body*motor.C0*motor.Transform*motor.C1:Inverse()end end
     cf=cf*part.localCF
     local bottom=math.huge
     for _,p in ipairs(part.points)do bottom=math.min(bottom,cf:PointToWorldSpace(p).Y-floor)end
     row.minimumSurfaceHeight=math.min(row.minimumSurfaceHeight,bottom)
     check(bottom>=-.002,kind..' '..clip..' '..phase..' '..name..' actual surface below floor: '..bottom)
    end
    for _,ch in ipairs({'weapon','off'})do
     local v=s.pose[ch]
     check(Vector3.new(math.rad(v[1]),math.rad(v[2]),math.rad(v[3])).Magnitude<=profile.armLimitRadians+.00001,'complete arm rotation respects refreshed shoulder seam budget')
    end
    check(root.CFrame==original and m.Humanoid.Health==hp,'animation does not move authoritative root or alter health')
   end
  end
  for _,clip in ipairs({'Attack','Heavy'})do
   local a,b=Motion.sample(kind,clip,.5),Motion.sample(kind,clip,.62)
   check(a.weapon[1]~=b.weapon[1]and a.off[1]~=b.off[1],'both independent arms contribute to contact')
   check(b.body[3]<a.body[3]-.03,'contact reaches forward from preparation')
   m:SetAttribute('K0EnemyState','Stunned');m:SetAttribute('K0EnemyStunUntil',9999)
   for frame=1,90 do Motion.step(s,1/60,200+frame/60)end
   local expected=Motion.sample(kind,'Stunned',((201.5)*.65+s.seed)%1)
   check(math.abs(s.pose.weapon[1]-expected.weapon[1])<.5,'stun clears the old attacking arm pose')
   m:SetAttribute('K0EnemyState','Idle');m:SetAttribute('K0EnemyStunUntil',nil);m:SetAttribute('K0EnemyAttackClock',nil)
   for frame=1,90 do Motion.step(s,1/60,300+frame/60)end
   check(s.attack==nil,'stopped attack clock leaves no latched attack')
   row.interruptionChecks+=1
  end
  row.directionCases=0
  m:SetAttribute('K0EnemyState','Chase')
  for _,hz in ipairs({30,60,144})do
   for _,speed in ipairs({6,14})do
    for direction=0,7 do
     local travel=Vector3.new(math.sin(direction*math.pi/4),0,-math.cos(direction*math.pi/4))
     for frame=1,24 do
      root.CFrame=original;s.position=root.Position
      root.CFrame=original+travel*(speed/hz)
      local committed=root.CFrame
      Motion.step(s,1/hz,500+frame/hz)
      check(root.CFrame==committed,'forward/backward/side animation cannot steer server movement')
      for _,motor in pairs(s.joints)do
       for _,v in ipairs({motor.Transform:GetComponents()})do check(v==v and math.abs(v)<10000,'finite directional joint pose')end
      end
     end
     row.directionCases+=1
    end
   end
  end
  Motion.unbind(s);m:Destroy();task.wait()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();Run:Stop();report.pass=ok
print('UNDEAD_INDIVIDUAL_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
