-- Local owner control holds yaw across locomotion frames and restores policy.
local F=require(game.StarterPlayer.StarterPlayerScripts.Client.AttackFacing)
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Parent=workspace
for _,class in {'elf','mage'}do for _,policy in {true,false}do
 local c=Instance.new('Model');c.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(20000,1000,20000);root.Parent=c
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;h.AutoRotate=policy
 c:SetAttribute('K0ClassId',class);c:SetAttribute('K0State','Idle');F.update(c)
 c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackSeq',8);c:SetAttribute('K0AttackAim','8|0|0|-1');c:SetAttribute('K0AttackAutoRotate',policy)
 for _,yaw in {33,90,-90,180}do for _,fps in {30,60,144}do
  for frame=1,3 do
   root.CFrame=CFrame.new(root.Position)*CFrame.Angles(0,math.rad(yaw),0)
   root.AssemblyLinearVelocity=Vector3.new(3,0,4);local at=root.Position;local velocity=root.AssemblyLinearVelocity
   check(F.update(c),'Owner control follows valid cast')
   check(root.CFrame.LookVector:Dot(Vector3.new(0,0,-1))>.99999,'Body cannot drift sideways from the accepted cast ray')
   check(not h.AutoRotate,'Walking AutoRotate cannot undo heading during simulation')
   check((root.Position-at).Magnitude<.001 and (root.AssemblyLinearVelocity-velocity).Magnitude<.001,'Holding heading preserves movement and velocity')
  end
 end end
 c:SetAttribute('K0State','Idle');F.update(c);check(h.AutoRotate==policy,'Original server rotation policy is restored')
 c:SetAttribute('K0State','Attack');c:SetAttribute('K0AttackAim','7|1|0|0');local before=root.CFrame
 check(not F.update(c)and root.CFrame==before,'A stale sequence cannot rotate the player')
 c:SetAttribute('K0AttackAim','8|0|0|-1');F.update(c);c:SetAttribute('K0State','Dodge');h.AutoRotate=false;before=root.CFrame
 check(not F.update(c)and root.CFrame==before and not h.AutoRotate,'Dodge takes over facing without a competing cast controller')
 c:Destroy()
end end
F.clear();folder:Destroy();print('CAST_FACING_NATIVE '..game.HttpService:JSONEncode({pass=true,checks=checks}))
