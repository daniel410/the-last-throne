assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local shared=game.ReplicatedStorage.Shared
local motion=require(client.K0EnemyMotion)
local pose=require(client.EnemyPatternPose)
local snapshot=require(client.EnemyPatternDefinition)
local patterns=require(shared.EnemyPatterns)
local profiles=require(shared.EnemyCombatProfiles)
local field=require(game.ServerScriptService.Server.World.TrainingField)
local folder=Instance.new("Folder",workspace)
local report={checks=0,attacks=0,kinds=0,bosses=0,travelRecoveries=0,skinned=0,pulses=0,styles={}}
local function check(v,msg) report.checks+=1;assert(v,msg) end
local origins={}
for kind,profile in patterns.profiles do
 local model=field.makeEnemy(folder,kind,0,0,1,1)
 local root=model.HumanoidRootPart
 root.Anchored=true
 local original=root.CFrame
 local hp=model.Humanoid.Health
 local s=assert(motion.bind(model),kind)
 report.kinds+=1
 if profile.boss then report.bosses+=1 end
 for i,base in profile.attacks do
  local d=profiles.resolve(kind,base,"Hell",.3)
  local a={start=50,w=d.windup,a=d.active,r=d.recovery}
  report.attacks+=1
  model:SetAttribute("K0PatternId",d.id)
  model:SetAttribute("K0AttackSeq",i)
  snapshot.message({kind="begin",id=d.id,sequence=i,model=model,definition=d,origin=root.Position,direction=-Vector3.zAxis,aim=root.Position-Vector3.zAxis*12})
  local setting=string.format("%d|50|%.7f|%.7f|%.7f|%d",i,a.w,a.a,a.r,d.blockable==false and 1 or 0)
  model:SetAttribute("K0EnemyAttackClock",setting)
  model:SetAttribute("K0EnemyState","Windup")
  motion.step(s,1/60,50)
  motion.step(s,1/60,50+a.w*.64)
  local body,g,load,drive=pose.accent(model,50+a.w*.64,a,s.height)
  check(load>.98 and drive<.001 and body.Position.Magnitude>.006*math.min(s.height,5),"Readable gathering "..d.id)
  local arm=pose.joint(model,"weapon",.4,g,load,drive)
  local off=pose.joint(model,"off",.4,g,load,drive)
  local _,delta=arm:ToObjectSpace(off):ToAxisAngle()
  check(delta>.1,"Paired limbs have different preparations "..d.id)
  local key=tostring(g.wind).."/"..tostring(g.arm)
  if not origins[key] then origins[key]=true;table.insert(report.styles,d.id) end
  model:SetAttribute("K0EnemyState","Active")
  for pulse=1,d.pulses do
   local at=50+a.w+(pulse-1)*d.interval
   local _,_,l,h=pose.accent(model,at,a,s.height)
   check(l<.0001 and h>.9999 and math.abs(pose.phase(model,at,a)-.62)<.00001,"Committed pulse "..d.id)
   local before=pose.accent(model,at-.00001,a,s.height)
   local after=pose.accent(model,at+.00001,a,s.height)
   local difference=before:ToObjectSpace(after)
   local _,angle=difference:ToAxisAngle()
   check(difference.Position.Magnitude<.0005 and math.abs(angle)<.001,"Continuous strike "..d.id)
   motion.step(s,1/60,at)
   report.pulses+=1
  end
  local sinceLast=a.a-(d.pulses-1)*d.interval
  if d.shape=="projectile" and sinceLast>1 then
   local phase=pose.phase(model,50+a.w+a.a-.01,a)
   check(phase>.90,"Arm recovers during long projectile flight "..d.id)
   report.travelRecoveries+=1
  end
  local _,_,ending,hit=pose.accent(model,50+a.w+a.a+a.r,a,s.height)
  check(ending==0 and hit==0 and root.CFrame==original and model.Humanoid.Health==hp,"Clean recovery "..d.id)
 end
 model:SetAttribute("K0EnemyAttackClock",nil)
 model:SetAttribute("K0EnemyState","Chase")
 local skin=s.caster or s.gloam
 if skin then
  report.skinned+=1
  for n=1,18 do
   if n%3==1 then root.CFrame+=Vector3.new(0,0,-.15) end
   motion.step(s,1/60,60+n/60)
   check(skin.clip=="Walk","Short replication gap must keep walking "..kind)
  end
  motion.step(s,.2,61)
  check(skin.clip=="Idle","A stopped skin settles "..kind)
  local phase=skin.phase
  root.CFrame+=Vector3.new(0,0,-100)
  motion.step(s,1/60,61.1)
  check(skin.clip=="Idle" and phase==skin.phase,"Teleport cannot create a stride "..kind)
 end
 model:SetAttribute("K0EnemyState","Idle")
 motion.unbind(s);model:Destroy();task.wait()
end
folder:Destroy()
check(#report.styles>=12 and report.travelRecoveries>0 and report.skinned>0,"Representation coverage")
table.sort(report.styles)
report.pass=true
print("MONSTER_ACTION_PHRASING "..game.HttpService:JSONEncode(report))
