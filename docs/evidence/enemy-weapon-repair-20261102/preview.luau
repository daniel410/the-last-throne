-- Execute with MANIFEST (decoded local manifest JSON) in the Edit tool context.
local storage=game.ServerStorage
local library=Instance.new('Folder');library.Name='DeepwoodWeaponRepairModels'
local imported={}
for _,model in workspace:GetChildren()do
 if string.find(model.Name,'Weapon_Repair')then
  for _,p in model:GetDescendants()do if p:IsA('MeshPart')and string.find(p.Name,'__')then imported[p.Name]=p end end
 end
end
for kind,data in pairs(MANIFEST.models)do
 local model=Instance.new('Model');model.Name=kind
 for _,record in data.parts do
  local part=assert(imported[kind..'__'..record.name]):Clone();part.Name=record.name
  part.CFrame=CFrame.new(table.unpack(record.center))*CFrame.Angles(0,math.pi,0)
  part.Size=Vector3.new(table.unpack(record.size));part.Anchored=true;part.CanCollide=false;part.Parent=model
 end
 local height=Instance.new('NumberValue');height.Name='TargetHeight';height.Value=kind=='ogre'and 6.05 or 7.6;height.Parent=model
 model.Parent=library
end
assert(not storage:FindFirstChild(library.Name),'Do not replace unrelated templates')
library.Parent=storage
local review=Instance.new('Folder');review.Name='TLTWeaponRepairReview';review.Parent=workspace
review:SetAttribute('PreviousCameraCFrame',workspace.CurrentCamera.CFrame)
local clips=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyClips)
for index,kind in ipairs({'ogre','warlord'})do
 local h=kind=='ogre'and 6.05 or 7.6
 for row,contact in ipairs({false,true})do
  local model=library[kind]:Clone();model.Name=kind..(contact and '_Contact' or '_Rest');model.Parent=review
  local x=index==1 and -6 or 6;local z=contact and 10 or 0
  local feet=CFrame.new(10000+x,0,10000+z)*CFrame.Angles(0,math.pi,0)
  local pivot=CFrame.new(feet:PointToWorldSpace(Vector3.new(kind=='ogre'and .39 or -.4,kind=='ogre'and .68 or .7,0)*h))
  local p=clips.models[kind=='ogre'and 'Ogre' or 'Warlord'].clips.Attack.weapon[125]
  local angles=CFrame.Angles(math.rad(kind=='warlord'and -p[1]or p[1]),math.rad(p[2]),math.rad(kind=='warlord'and -p[3]or p[3]))
  for _,part in model:GetChildren()do if part:IsA('MeshPart')then
   part.Size*=h;part.CFrame=feet*CFrame.new(part.Position*h)*part.CFrame.Rotation
   if contact and (part.Name==(kind=='ogre'and 'ArmR'or'ArmL') or part.Name=='Weapon')then part.CFrame=pivot*angles*pivot:Inverse()*part.CFrame end
  end end
 end
end
local cam=workspace.CurrentCamera;cam.Focus=CFrame.new(10000,3,10005);cam.CFrame=CFrame.lookAt(Vector3.new(10000,15,9972),Vector3.new(10000,3,10005));cam.FieldOfView=45
local sources=Instance.new('Folder');sources.Name='TLTWeaponRepairImportSources';sources.Parent=storage
for _,o in workspace:GetChildren()do if string.find(o.Name,'Weapon_Repair')then o.Parent=sources end end
return {templateModels=#library:GetChildren(),previewModels=#review:GetChildren()}
