local Camera={min=6,max=18}
function Camera.start()
 local p=game:GetService('Players').LocalPlayer
 local function apply()
  if p.CameraMinZoomDistance~=Camera.min then p.CameraMinZoomDistance=Camera.min end
  if p.CameraMaxZoomDistance~=Camera.max then p.CameraMaxZoomDistance=Camera.max end
 end
 apply();p.CharacterAdded:Connect(apply)
 p:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(apply)
 p:GetPropertyChangedSignal('CameraMaxZoomDistance'):Connect(apply)
end
return Camera
