local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local V=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local M=require(game.StarterPlayer.StarterPlayerScripts.Client.K0MeleeMotion)
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(Instance.new('HumanoidDescription'),Enum.HumanoidRigType.R15)
c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
local model=Instance.new('Model');model.Parent=c;local w=assert(A.attachInto(model,c,'dwarf'))
local root=c.HumanoidRootPart;local joints={};for _,j in c:GetDescendants() do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
local edge=w.grip.AxeCuttingEdge.Position;local dir=w.grip.AxeCuttingDirection.Position;local face=w.grip.AxeFaceNormal.Position
local shoulder=c:FindFirstChild('RightShoulder',true);local elbow=c:FindFirstChild('RightElbow',true);local wrist=c:FindFirstChild('RightWrist',true)
local function rot(v)return CFrame.Angles(math.rad(v[1]),math.rad(v[2]),math.rad(v[3]))end
c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1);c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackStartedAt',100)
local function vec(v)return {v.X,v.Y,v.Z}end
local result={}
local prior
for _,t in {.11,.18,.21,.215,.22,.225,.23,.29,.42} do
 V.renderArms(c,1/60,100+t);V.render(model,'Active',1,1/60,'Melee',100+t)
 local target=frame(w.grip);local targetPoint=target:PointToWorldSpace(edge);local targetDir=target:VectorToWorldSpace(dir);local targetFace=target:VectorToWorldSpace(face)
 local base=frame(shoulder.Part0)*shoulder.C0
 local function fk(x)return base*rot({x[1],x[2],x[3]})*shoulder.C1:Inverse()*elbow.C0*rot({x[4],0,0})*elbow.C1:Inverse()*wrist.C0*rot({x[5],x[6],x[7]})*wrist.C1:Inverse()*w.joint.C0*CFrame.Angles(0,math.rad(-110),0)*CFrame.Angles(math.rad(-94),0,0) end
 local lo={0,-85,-95,0,-30,-30,-30};local hi={170,85,95,110,30,30,30}
 local function cost(x)
  local cf=fk(x);local dp=(cf:PointToWorldSpace(edge)-targetPoint).Magnitude
  local dd=(cf:VectorToWorldSpace(dir)-targetDir).Magnitude;local df=(cf:VectorToWorldSpace(face)-targetFace).Magnitude
  local penalty=0;for i=5,7 do penalty+=x[i]^2*.00003 end
  return dp*dp*3+dd*dd*2+df*df*2+penalty
 end
 local best,bestCost
 local old=M.sample('dwarf',1,t).angles
 for _,seed in {{old.right.X,old.right.Y,old.right.Z,old.elbow.X,0,0,0},{130,-15,-40,30,0,0,0},{80,30,30,60,0,0,0},prior or {90,0,0,60,0,0,0}} do
  local x=table.clone(seed);for i=1,7 do x[i]=math.clamp(x[i],lo[i],hi[i])end
  local score=cost(x)
  for _,step in {25,12,6,3,1.5,.7,.3,.1} do for iter=1,40 do
   local changed=false
   for i=1,7 do local orig=x[i];local pick=orig
    for _,sign in {-1,1} do x[i]=math.clamp(orig+step*sign,lo[i],hi[i]);local s=cost(x);if s<score then score=s;pick=x[i];changed=true end end
    x[i]=pick
   end
   if not changed then break end
  end end
  if not bestCost or score<bestCost then best,bestCost=table.clone(x),score end
 end
 -- Refine the full native FK with damped least squares, avoiding coordinate
 -- descent artifacts around the contact derivative. This is authoring only.
 local function residual(x)
  local cf=fk(x);local p=(cf:PointToWorldSpace(edge)-targetPoint)*5
  local d=cf:VectorToWorldSpace(dir)-targetDir;local f=cf:VectorToWorldSpace(face)-targetFace
  return {p.X,p.Y,p.Z,d.X,d.Y,d.Z,f.X,f.Y,f.Z,x[5]*.001,x[6]*.001,x[7]*.001}
 end
 local function norm(v)local n=0;for _,a in v do n+=a*a end;return n end
 for iter=1,150 do
  local r=residual(best);local jac={}
  for j=1,7 do local x=table.clone(best);x[j]+=.02;local b=residual(x);jac[j]={};for i=1,#r do jac[j][i]=(b[i]-r[i])/.02 end end
  local matrix={}
  for j=1,7 do
   matrix[j]={};for k=1,7 do local v=j==k and .00001 or 0;for i=1,#r do v+=jac[j][i]*jac[k][i] end;matrix[j][k]=v end
   local v=0;for i=1,#r do v-=jac[j][i]*r[i] end;matrix[j][8]=v
  end
  for j=1,7 do
   local pivot=j;for k=j+1,7 do if math.abs(matrix[k][j])>math.abs(matrix[pivot][j]) then pivot=k end end
   matrix[j],matrix[pivot]=matrix[pivot],matrix[j]
   local d=matrix[j][j];for k=j,8 do matrix[j][k]/=d end
   for row=1,7 do if row~=j then local f=matrix[row][j];for k=j,8 do matrix[row][k]-=f*matrix[j][k] end end end
  end
  local accepted=false
  for _,scale in {1,.5,.25,.1,.02} do
   local x={};for j=1,7 do x[j]=math.clamp(best[j]+math.clamp(matrix[j][8],-10,10)*scale,lo[j],hi[j]) end
   if norm(residual(x))<norm(r) then best=x;accepted=true;break end
  end
  if not accepted then break end
 end
 prior=best
 local cf=fk(best)
 table.insert(result,{age=t,parameters=best,cost=bestCost,target=vec(root.CFrame:PointToObjectSpace(targetPoint)),actual=vec(root.CFrame:PointToObjectSpace(cf:PointToWorldSpace(edge)))})
 task.wait()
end
print('SOLVED_NATURAL '..game.HttpService:JSONEncode(result));c:Destroy()
