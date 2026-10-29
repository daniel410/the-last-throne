-- Native camera instances; manual render API calls, not a default Play camera acceptance test.
local Players=game:GetService('Players')
local Http=game:GetService('HttpService')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'Camera fixture requires an empty local place')
local Controller=require(game.StarterPlayer.StarterPlayerScripts.Client.HeroDeathCamera)
local report={kind='HERO_DEATH_CAMERA_NATIVE',checks=0,failures={}}
local function check(v,message) report.checks+=1;assert(v,message) end
local original=workspace.CurrentCamera
local camera=Instance.new('Camera');camera.CameraType=Enum.CameraType.Custom;camera.Parent=workspace;workspace.CurrentCamera=camera
local fixture=Instance.new('Folder');fixture.Name='DeathCameraFixture';fixture.Parent=workspace
local function hero(name)
 local model=Instance.new('Model');model.Name=name;model.Parent=fixture
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.CFrame=CFrame.new(300,104,300);root.Parent=model
 local body=Instance.new('Part');body.Name='Torso';body.Anchored=true;body.LocalTransparencyModifier=1;body.Parent=model
 local human=Instance.new('Humanoid');human.Parent=model
 return model,root,body,human
end
local ok,err=xpcall(function()
 local first,root,body=hero('OldLife')
 camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(10,8,14),root.Position)
 local origin=camera.CFrame.Position
 Controller.update(first,true)
 check(camera.CameraType==Enum.CameraType.Scriptable,'fall uses a controlled camera')
 check((camera.CFrame.Position-origin).Magnitude<.001,'fall preserves a visible third-person distance')
 check(body.LocalTransparencyModifier==0,'default camera fading cannot hide the intact hero')
 root.CFrame=CFrame.new(301,100.65,300)*CFrame.Angles(-math.pi/2,0,0)
 Controller.update(first,true)
 check((camera.CFrame.Position-origin).Magnitude<.001,'camera does not sink with the falling body')
 local nextLife,_,_,nextHuman=hero('NewLife')
 Controller.update(nextLife,false)
 check(camera.CameraType==Enum.CameraType.Custom,'next life restores the previous camera type')
 check(camera.CameraSubject==nextHuman,'next life restores the new humanoid subject')
 check(not nextLife.HumanoidRootPart.Anchored==false,'camera controller does not mutate the prepared root')
end,debug.traceback)
Controller.update(nil,false);workspace.CurrentCamera=original;camera:Destroy();fixture:Destroy()
if not ok then table.insert(report.failures,err) end;report.pass=ok
print('HERO_DEATH_CAMERA_NATIVE '..Http:JSONEncode(report));assert(ok,'See HERO_DEATH_CAMERA_NATIVE')
