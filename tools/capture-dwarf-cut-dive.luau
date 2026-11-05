-- Evaluated native joint poses for Blender review; no Player or server movement.
local V=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local A=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(Instance.new('HumanoidDescription'),Enum.HumanoidRigType.R15)
c.Parent=workspace;c:PivotTo(CFrame.new(0,500,0))
local m=Instance.new('Model');m.Parent=c;local w=assert(A.attachInto(m,c,'dwarf'));local root=c.HumanoidRootPart
local joints={}
for _,j in ipairs(c:GetDescendants())do if(j:IsA('Motor6D')or j:IsA('AnimationConstraint'))and j.Part0 and j.Part1 then joints[j.Part1]=j end end
local function frame(p)local j=joints[p];return j and frame(j.Part0)*j.C0*j.Transform*j.C1:Inverse()or p.CFrame end
local offset=w.grip.CFrame:ToObjectSpace(m.Weapon.CFrame)
local data={rig='R15',scope='Actual native joint FK; body boxes are presentation proxies.',clips={}}
c:SetAttribute('K0ClassId','dwarf');c:SetAttribute('K0Combo',1)
for _,kind in ipairs({'Cut','Dive'})do
 c:SetAttribute('K0State','Dodge');c:SetAttribute('K0DodgeKind',nil);V.renderArms(c,1/60,99)
 c:SetAttribute('K0State',kind=='Cut'and'Attack'or'Dodge');c:SetAttribute('K0AttackStartedAt',100)
 c:SetAttribute('K0DodgeKind',kind=='Dive'and'SideRoll'or nil);c:SetAttribute('K0DodgeStartedAt',100);c:SetAttribute('K0DodgeSide',1)
 data.clips[kind]={}
 local times=kind=='Cut'and{0,.11,.18,.22,.29,.42}or{0,.10,.165,.30,.40,.55}
 for _,age in ipairs(times)do
  V.renderArms(c,1/60,100+age);V.renderCharacter(c,1/60,100+age)
  local row={age=age,parts={}}
  for _,p in ipairs(c:GetChildren())do
   if p:IsA('BasePart')and p~=root then
    row.parts[p.Name]={cf={root.CFrame:ToObjectSpace(frame(p)):GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z}}
   end
  end
  row.parts.Weapon={cf={root.CFrame:ToObjectSpace(frame(w.grip)*offset):GetComponents()},size={m.Weapon.Size.X,m.Weapon.Size.Y,m.Weapon.Size.Z}}
  table.insert(data.clips[kind],row)
 end
end
print('CUT_DIVE_POSES '..game.HttpService:JSONEncode(data));c:Destroy()
