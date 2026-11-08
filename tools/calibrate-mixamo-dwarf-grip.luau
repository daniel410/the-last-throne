-- Authoring only: fit one rigid hand-to-axe rotation to actual R15 FK.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local V=require(Client.K0SwordVisual)
local M=require(Client.K0MeleeMotion)
local clips=require(Client.K0DwarfMixamoClips)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local desc=Instance.new('HumanoidDescription')
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,Enum.HumanoidRigType.R15);desc:Destroy()
c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
local model=Instance.new('Model');model.Parent=c;local w=assert(A.attachInto(model,c,'dwarf'))
local joints={};for _,j in c:GetDescendants() do if (j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
local edge=w.grip.AxeCuttingEdge.Position
local direction=w.grip.AxeCuttingDirection.Position.Unit
local face=w.grip.AxeFaceNormal.Position.Unit
local function rotation(x)return CFrame.Angles(math.rad(x[1]),math.rad(x[2]),math.rad(x[3]))end
local output={};local metrics={}
for _,row in {{'basic',nil,clips.basic},{'overhead','dwarf.common.overhead',clips.skills['dwarf.common.overhead']},{'ground','dwarf.common.ground',clips.skills['dwarf.common.ground']},{'grounded','dwarf.mixamo.grounded',clips.variants['dwarf.mixamo.grounded']},{'backhand','dwarf.mixamo.backhand',clips.variants['dwarf.mixamo.backhand']},{'sweep','dwarf.mixamo.sweep',clips.variants['dwarf.mixamo.sweep']}} do
 local key,id,clip=row[1],row[2],row[3]
 local d=key=='basic'and Config.BasicAttackProfiles.dwarf.attacks[1]or(key=='ground'or key=='grounded')and Config.Skills.dwarf[3]or Config.Skills.dwarf[1]
 local contact=d.windup+(d.hitDelay or 0)
 local samples={}
 for _,delta in {-.005,0,.005} do
  local frames={}
  for _,epsilon in {-.0005,0,.0005} do
   local p=M.sample('dwarf',1,contact+delta+epsilon,nil,nil,id)
   -- Set exactly the same native joints as renderArms, without action history.
   for channel,joint in {right='RightShoulder',left='LeftShoulder',elbow='RightElbow',leftElbow='LeftElbow',wrist='RightWrist',torso='Waist',neck='Neck'} do
    local j=c:FindFirstChild(joint,true);j.Transform=p[channel]
   end
   table.insert(frames,frame(w.joint.Part0)*w.joint.C0*CFrame.Angles(0,math.rad(-110),0))
  end
  table.insert(samples,frames)
 end
 local function cost(x)
  local r=rotation(x);local score=0
  for _,s in samples do
   local before=s[1]*r*w.joint.C1:Inverse();local at=s[2]*r*w.joint.C1:Inverse();local after=s[3]*r*w.joint.C1:Inverse()
   local velocity=(after:PointToWorldSpace(edge)-before:PointToWorldSpace(edge)).Unit
   local dot=at:VectorToWorldSpace(direction):Dot(velocity)
   local flat=at:VectorToWorldSpace(face):Dot(velocity)
   score+=(1-dot)^2*12+flat^2*6+math.max(0,.94-dot)^2*100
   local localEdge=c.HumanoidRootPart.CFrame:PointToObjectSpace(at:PointToWorldSpace(edge))
   score+=math.max(0,localEdge.Z+(key=='basic'and 1.6 or .4))^2*2
  end
  score+=((x[1]+94)^2+x[2]^2+x[3]^2)*.0000001
  return score
 end
 local best,bestCost
 for _,seed in {{-94,0,0},{0,0,0},{-90,90,0},{90,0,90},{-90,-90,0},{0,0,180}} do
  local x=table.clone(seed);local value=cost(x)
  for _,step in {45,20,8,3,1,.3,.1} do
   for iter=1,30 do
    local changed=false
    for axis=1,3 do
     local original=x[axis];local chosen=original
     for _,sign in {-1,1} do
      x[axis]=original+step*sign;local v=cost(x)
      if v<value then value=v;chosen=x[axis];changed=true end
     end
     x[axis]=chosen
    end
    if not changed then break end
   end
  end
  if not bestCost or value<bestCost then best,bestCost=table.clone(x),value end
 end
 output[key]=best;metrics[key]={cost=bestCost}
 task.wait()
end
print('MIXAMO_GRIP_CALIBRATION '..game.HttpService:JSONEncode(output))
print('MIXAMO_GRIP_METRICS '..game.HttpService:JSONEncode(metrics))
c:Destroy()
