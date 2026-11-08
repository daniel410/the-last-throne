-- Actual renderer/FK: every dwarf action must end at the original idle hand,
-- wrist and axe, including the first Idle update and faster basic attacks.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Melee=require(Client.K0MeleeMotion)
local Advanced=require(Client.AdvancedSkillMotion)
local V=require(Client.K0SwordVisual)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local report={kind='DWARF_RECOVERY_NATIVE',checks=0,actions=0,failures={},maxEndDegrees=0,maxEndStuds=0}
local function check(v,label)report.checks+=1;assert(v,label)end
local function angular(a,b)local _,v=(a:Inverse()*b):ToAxisAngle();return math.abs(v)end
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 local c
 local ok,err=xpcall(function()
  local desc=Instance.new('HumanoidDescription');c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
  c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0));c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1)
  local model=Instance.new('Model');model.Parent=c;local weapon=assert(A.attachInto(model,c,'dwarf'))
  local joints={};for _,j in c:GetDescendants()do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
  local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
  local hand=weapon.joint.Part0;local idleHand=frame(hand);local idleGrip=frame(weapon.grip);local root=c.HumanoidRootPart;local origin=root.CFrame
  local definitions={Config.BasicAttackProfiles.dwarf.attacks[1]};for _,d in Config.Skills.dwarf do table.insert(definitions,d)end
  for _,d in definitions do for _,fps in {30,144}do for _,rate in {1,2}do
   report.actions+=1
   c:SetAttribute('K0State','Dodge');Melee.forCharacter(c,99);Advanced.forCharacter(c,99)
   c:SetAttribute('K0State','Attack');c:SetAttribute('K0SkillId',d.id);c:SetAttribute('K0AttackStartedAt',100);c:SetAttribute('K0BasicAttackRate',rate)
   local total=d.windup+d.active+d.recovery;local speed=d.id and 1 or rate
   local function render(age)
    local now=100+age/speed
    V.renderArms(c,1/fps,now);V.render(model,c:GetAttribute('K0State')=='Idle'and'None'or'Recovery',1,1/fps,'Melee',now)
    return frame(hand),frame(weapon.grip)
   end
   -- Evaluate through late recovery; the source socket and hand settle together.
   for i=0,32 do render(total-d.recovery+d.recovery*i/32)end
   local finishHand,finishGrip=render(total)
   local function sameIdle(h,g,label)
    local degrees=math.deg(math.max(angular(h,idleHand),angular(g,idleGrip)))
    local studs=math.max((h.Position-idleHand.Position).Magnitude,(g.Position-idleGrip.Position).Magnitude)
    report.maxEndDegrees=math.max(report.maxEndDegrees,degrees);report.maxEndStuds=math.max(report.maxEndStuds,studs)
    check(degrees<.02 and studs<.001,label..' '..(d.id or 'basic')..' '..rig.Name..' degrees='..degrees..' studs='..studs)
    check(root.CFrame==origin,'Recovery never changes authoritative root')
   end
   sameIdle(finishHand,finishGrip,'Final frame has relaxed palm and original axe orientation')
   local beforeHand,beforeGrip=render(total-.00001)
   check(angular(beforeHand,finishHand)<.002 and angular(beforeGrip,finishGrip)<.002,'Recovery reaches idle without last-frame snap')
   c:SetAttribute('K0State','Idle')
   -- The real server removes SkillId and StartedAt when clearAction runs.
   c:SetAttribute('K0SkillId',nil);c:SetAttribute('K0AttackStartedAt',nil)
   for _,offset in {.00001,.05,.2,.43,.7}do local h,g=render(total+offset);sameIdle(h,g,'Idle never reintroduces the old guard or socket yaw')end
  end end end
 end,debug.traceback)
 if not ok then table.insert(report.failures,rig.Name..': '..tostring(err))end
 if c then c:Destroy()end
end
report.pass=#report.failures==0;print('DWARF_RECOVERY_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Dwarf recovery pose regression failed')
