-- Exact reference sequence, all combo joins and stopped chains on native rigs.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0MeleeMotion)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local report={checks=0,joins=0,maxJoinDegrees=0,pass=false}
local function check(v,label)report.checks+=1;assert(v,label)end
local before=Instance.new('ModuleScript');before.Name='KnightPreviousMotionQA';before.Source=previousKnightMotionSource;before.Parent=Client
local Baseline=require(before)
-- This is a motion change: independent frozen server budgets must stay exact.
for i,expected in {{.588,1.05,12,5.5},{.644,1.26,14,5.5},{.868,1.68,24,6}}do
 local d=Config.BasicAttackProfiles.knight.attacks[i]
 check(math.abs(d.windup+d.active+d.recovery-expected[1])<1e-8,'Existing attack period retained')
 check(math.abs(d.damage-expected[2])<1e-8 and d.posture==expected[3]and d.range==expected[4],'Existing damage/posture/range retained')
end
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 local desc=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy();c.Parent=workspace
 c:SetAttribute('K0ClassId','knight')
 for _,rate in {1,2}do for _,fps in {30,144}do
  c:SetAttribute('K0State','Dodge');Motion.forCharacter(c,99)
  c:SetAttribute('K0BasicAttackRate',rate)
  local start=100
  for combo=1,3 do
   c:SetAttribute('K0State','Attack');c:SetAttribute('K0Combo',combo);c:SetAttribute('K0AttackStartedAt',start)
   local d=Config.BasicAttackProfiles.knight.attacks[combo];local total=(d.windup+d.active+d.recovery)/rate
   for f=0,math.ceil(total*fps)do
    local p=Motion.forCharacter(c,start+math.min(total,f/fps))
    for _,v in p.angles do check(v.X==v.X and v.Y==v.Y and v.Z==v.Z,'Every sampled joint remains finite')end
   end
   local ending=start+total
   local outgoing=Motion.forCharacter(c,ending)
   local a=Motion.forCharacter(c,ending-.0001)
   c:SetAttribute('K0Combo',combo%3+1);c:SetAttribute('K0AttackStartedAt',ending)
   local incoming=Motion.forCharacter(c,ending)
   local b=Motion.forCharacter(c,ending+.0001)
   for ch,v in outgoing.angles do
    local delta=(v-incoming.angles[ch]).Magnitude;report.maxJoinDegrees=math.max(report.maxJoinDegrees,delta)
    check(delta<.001,'Every1-2/2-3/3-1join preserves pose')
    check(((v-a.angles[ch])/.0001-(b.angles[ch]-incoming.angles[ch])/.0001).Magnitude<50,'Every join preserves angular velocity')
   end
   report.joins+=1
   -- Stop after any accepted strike, including the server clearing its clock.
   c:SetAttribute('K0State','Dodge');Motion.forCharacter(c,99)
   c:SetAttribute('K0State','Attack');c:SetAttribute('K0Combo',combo);c:SetAttribute('K0AttackStartedAt',start)
   local finish=Motion.forCharacter(c,ending)
   c:SetAttribute('K0State','Idle');c:SetAttribute('K0AttackStartedAt',nil)
   local idle=Motion.forCharacter(c,ending+.000001)
   for ch,v in finish.angles do check((v-idle.angles[ch]).Magnitude<.001,'Stopping does not snap to guard')end
   check(Motion.forCharacter(c,ending+.43/rate)==nil,'Stopped chain releases the procedural layer')
   c:SetAttribute('K0State','Dodge');Motion.forCharacter(c,99)
   start=ending
  end
 end end
 -- Shared knight skills and specialist variants must remain byte-equivalent in pose.
 local skills={};for _,d in Config.Skills.knight do table.insert(skills,{id=d.id,index=1,definition=d})end
 for id,v in require(Client.K0KnightMixamoVariants)do table.insert(skills,{id=id,index=v.combo,definition=Config.Attacks[v.combo]})end
 for _,skill in skills do
  local d=skill.definition;local total=d.windup+d.active+d.recovery
  for sample=0,24 do
   local age=total*sample/24
   local actual=Motion.sample('knight',skill.index,age,nil,nil,skill.id,rig)
   local expected=Baseline.sample('knight',skill.index,age,nil,nil,skill.id,rig)
   check((actual~=nil)==(expected~=nil),'Skill choreography availability unchanged')
   if actual then for ch,v in actual.angles do check((v-expected.angles[ch]).Magnitude<1e-8,'Skill choreography unchanged '..skill.id)end end
  end
 end
 c:SetAttribute('K0State','Dead');check(Motion.forCharacter(c,100)==nil,'Death clears the action')
 c:Destroy()
end
before:Destroy();report.pass=true
print('KNIGHT_REFERENCE_COMBO_NATIVE '..game.HttpService:JSONEncode(report))
