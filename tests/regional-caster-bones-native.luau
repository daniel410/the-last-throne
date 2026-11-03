-- The assembler supplies local `fixtures` from the exported candidate GLBs.
-- Real Roblox Bone transform contract only: no new mesh assets are loaded.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture only')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(4)end
local report={kind='REGIONAL_CASTER_BONES_NATIVE',scope='Bone hierarchy and exported key poses; no imported candidate mesh or skin deformation',checks=0,failures={}}
local function check(v,label)report.checks+=1;assert(v,label)end
local function cf(m)
 -- glTF preserves tiny exporter scale roundoff; Roblox CFrame requires a
 -- rigid orthonormal basis. Strip scale before comparing Bone transforms.
 local right=Vector3.new(m[1][1],m[2][1],m[3][1]).Unit
 local up=Vector3.new(m[1][2],m[2][2],m[3][2]);up=(up-right*up:Dot(right)).Unit
 return CFrame.fromMatrix(Vector3.new(m[1][4],m[2][4],m[3][4]),right,up,right:Cross(up))
end
local folder=Instance.new('Folder');folder.Name='MR01BoneContractQA';folder.Parent=workspace
local ok,err=xpcall(function()
 for kind,fixture in pairs(fixtures)do
  local root=Instance.new('MeshPart');root.Name=kind;root.Anchored=true;root.CanCollide=false;root.Parent=folder
  local original=root.CFrame;local bones,byName={},{}
  for i,spec in ipairs(fixture.bones)do
   local b=Instance.new('Bone');b.Name=spec.name;bones[i]=b;byName[spec.name]=i
  end
  for i,spec in ipairs(fixture.bones)do
   local parent=byName[spec.parent];local b=bones[i]
   b.Parent=parent and bones[parent]or root
   b.CFrame=parent and cf(fixture.bones[parent].rest):Inverse()*cf(spec.rest)or cf(spec.rest)
  end
  for _,side in ipairs({'R','L'})do
   check(bones[byName['Forearm'..side]].Parent==bones[byName['Upper'..side]],kind..' elbow hierarchy')
   check(bones[byName['Hand'..side]].Parent==bones[byName['Forearm'..side]],kind..' wrist hierarchy')
  end
  for _,pose in ipairs(fixture.poses)do
   for i,spec in ipairs(fixture.bones)do
    local parent=byName[spec.parent]
    local localPose=parent and cf(pose.world[parent]):Inverse()*cf(pose.world[i])or cf(pose.world[i])
    bones[i].Transform=bones[i].CFrame:Inverse()*localPose
   end
   for i,spec in ipairs(fixture.bones)do
    local delta=cf(pose.world[i]):Inverse()*bones[i].TransformedWorldCFrame
    check(delta.Position.Magnitude<.0001,kind..' '..pose.clip..' '..spec.name..' position')
    local _,angle=delta:ToAxisAngle();check(math.abs(angle)<.002,kind..' '..pose.clip..' '..spec.name..' rotation')
   end
   local staff,hand=byName.Staff,byName.HandR
   local staffSkin=bones[staff].TransformedWorldCFrame*cf(fixture.bones[staff].bind)
   local handSkin=bones[hand].TransformedWorldCFrame*cf(fixture.bones[hand].bind)
   local delta=handSkin:Inverse()*staffSkin
   check(delta.Position.Magnitude<.0001,kind..' '..pose.clip..' common wrist position')
   local _,angle=delta:ToAxisAngle();check(math.abs(angle)<.002,kind..' '..pose.clip..' common wrist rotation')
   check(root.CFrame==original,kind..' no root motion')
  end
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();report.pass=#report.failures==0
print('REGIONAL_CASTER_BONES_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'MR-01 Bone contract failed')
