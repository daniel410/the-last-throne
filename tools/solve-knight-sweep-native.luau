-- Authoring only: solve a broad horizontal finisher on native R6/R15 sockets.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local V=require(Client.K0SwordVisual)
local M=require(Client.K0MeleeMotion)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local result={}
local function rot(x,y,z)return CFrame.Angles(math.rad(x or 0),math.rad(y or 0),math.rad(z or 0))end
for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do
 local desc=Instance.new('HumanoidDescription');local c=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rig);desc:Destroy()
 c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0));c:SetAttribute('K0ClassId','knight');c:SetAttribute('K0State','Attack');c:SetAttribute('K0Combo',3);c:SetAttribute('K0AttackStartedAt',100)
 local model=Instance.new('Model');model.Parent=c;local w=A.attachInto(model,c,'knight');A.attachShieldInto(model,c)
 V.renderArms(c,1/60,100.868);V.render(model,'Recovery',3,1/60,'Melee',100.868)
 local joints={};for _,j in c:GetDescendants()do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
 local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
 local shoulder=c:FindFirstChild(rig==Enum.HumanoidRigType.R6 and 'Right Shoulder'or'RightShoulder',true)
 local elbow=c:FindFirstChild('RightElbow',true);local wrist=c:FindFirstChild('RightWrist',true)
 local root=c.HumanoidRootPart;local base=frame(shoulder.Part0)*shoulder.C0
 local tip=w.tip.Position
 local function fk(x)
  local basis=shoulder.C0.Rotation
  local cf=base*basis:Inverse()*rot(x[1],x[2],x[3])*basis*shoulder.C1:Inverse()
  if elbow then cf=cf*elbow.C0*rot(x[4])*elbow.C1:Inverse()*wrist.C0*rot(x[5],x[6],x[7])*wrist.C1:Inverse()end
  return cf*w.joint.C0*rot(x[8],x[9],x[10])*w.joint.C1:Inverse()
 end
 local lo={15,-110,-110,0,-35,-35,-35,-150,-45,-45};local hi={175,110,110,110,35,35,35,-40,45,45}
 if not elbow then for i=4,7 do lo[i]=0;hi[i]=0 end end
 local rows={};local prior
 for _,angle in {65,45,25,0,-25,-45,-65}do
  local theta=math.rad(angle)
  local directionTarget=Vector3.new(math.sin(theta),0,-math.cos(theta))
  local target=root.CFrame:PointToWorldSpace(Vector3.new(.4,.8,0)+directionTarget*4.4)
  local function cost(x)
   local cf=fk(x);local point=cf:PointToWorldSpace(tip)
   local direction=cf:VectorToWorldSpace(tip.Unit)
   local penalty=0;for i=5,10 do penalty+=x[i]^2*(i==8 and .000001 or .00001)end
   if prior then for i=1,10 do penalty+=(x[i]-prior[i])^2*.00008 end end
   return (point-target).Magnitude^2*8+(direction-directionTarget).Magnitude^2*12+penalty
  end
  local best,score
  for _,seed in {prior or {90,0,-5,30,0,0,0,-92,0,0},{80,0,-10,0,0,0,0,-90,0,0},{100,10,-10,60,0,0,0,-90,0,0}}do
   local x=table.clone(seed);for i=1,10 do x[i]=math.clamp(x[i],lo[i],hi[i])end
   local value=cost(x)
   for _,step in {20,10,5,2,1,.5,.2,.1,.03}do for iter=1,60 do
    local changed=false
    for i=1,10 do local original=x[i];local pick=original
     for _,sign in {-1,1}do x[i]=math.clamp(original+step*sign,lo[i],hi[i]);local nextValue=cost(x);if nextValue<value then value=nextValue;pick=x[i];changed=true end end
     x[i]=pick
    end
    if not changed then break end
   end end
   if not score or value<score then best,score=table.clone(x),value end
  end
  prior=best;local cf=fk(best);local p=root.CFrame:PointToObjectSpace(cf:PointToWorldSpace(tip));local dir=cf:VectorToWorldSpace(tip.Unit)
  table.insert(rows,{angle=angle,parameters=best,tip={p.X,p.Y,p.Z},direction={dir.X,dir.Y,dir.Z},score=score})
 end
 result[rig.Name]=rows;c:Destroy()
end
print('KNIGHT_SWEEP_POSES '..game.HttpService:JSONEncode(result))
