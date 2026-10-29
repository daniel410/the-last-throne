-- Keep the intact forward fall in view; restore the normal camera on the next life.
local Workspace=game:GetService('Workspace')
local Camera={}
local held
function Camera.update(character,falling)
 local camera=Workspace.CurrentCamera
 if not camera then return end
 if not falling or not character then
  if held then
   if held.camera==camera then
    camera.CameraType=held.kind
    local human=character and character:FindFirstChildOfClass('Humanoid')
    if human then camera.CameraSubject=human end
   end
   held=nil
  end
  return
 end
 local root=character:FindFirstChild('HumanoidRootPart');if not root then return end
 if not held or held.character~=character or held.camera~=camera then
  local position=camera.CFrame.Position
  if (position-root.Position).Magnitude<6 or position.Y<root.Position.Y+2 then
   local back=Vector3.new(-root.CFrame.LookVector.X,0,-root.CFrame.LookVector.Z)
   if back.Magnitude<.01 then back=Vector3.new(0,0,1) else back=back.Unit end
   position=root.Position+back*11+Vector3.new(0,6,0)
  end
  held={camera=camera,kind=camera.CameraType,character=character,position=position}
 end
 camera.CameraType=Enum.CameraType.Scriptable
 local target=root.Position+Vector3.new(0,.6,0)
 camera.CFrame=CFrame.lookAt(held.position,target);camera.Focus=CFrame.new(target)
 for _,part in ipairs(character:GetDescendants()) do if part:IsA('BasePart') then part.LocalTransparencyModifier=0 end end
end
return Camera
