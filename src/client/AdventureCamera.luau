-- Keep Roblox orbit/zoom controls, then constrain the final living adventure
-- camera. Death/cutscene cameras keep their own authority.
local Run=game:GetService('RunService')
local Input=game:GetService('UserInputService')
local Workspace=game:GetService('Workspace')
local Bounds=require(game:GetService('ReplicatedStorage').Shared.CampaignBounds)
local Camera={min=6,lobbyMin=24,max=32,lobbyMax=32,minPitch=0,maxPitch=math.rad(72),radius=.6}
function Camera.minimum(phase)
 -- Keep the hero above the HomeDock PLAY button at the closest lobby zoom.
 return phase=='Lobby' and Camera.lobbyMin or Camera.min
end
function Camera.maximum(phase)
 return phase=='Tutorial' and Camera.max or Camera.lobbyMax
end
function Camera.constrain(focus,position,geometry)
 local offset=position-focus;local distance=math.clamp(offset.Magnitude,.75,Camera.max)
 local horizontal=Vector3.new(offset.X,0,offset.Z)
 if horizontal.Magnitude<.001 then horizontal=Vector3.new(0,0,1) else horizontal=horizontal.Unit end
 local pitch=math.clamp(math.asin(math.clamp(offset.Y/math.max(.001,offset.Magnitude),-1,1)),Camera.minPitch,Camera.maxPitch)
 local destination=focus+horizontal*math.cos(pitch)*distance+Vector3.new(0,math.sin(pitch)*distance,0)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances=geometry;params.RespectCanCollide=true
 local direction=destination-focus
 local hit=Workspace:Spherecast(focus,Camera.radius,direction,params)
 if hit then destination=focus+direction.Unit*math.max(.1,hit.Distance-.15) end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances=geometry;overlap.RespectCanCollide=true;overlap.MaxParts=1
 local floor=Bounds.surface(destination.X,destination.Z) or Bounds.backgroundHeight
 -- Spherecast does not report initial overlaps. An unsafe endpoint retreats to
 -- the known above-ground focus instead of leaving the camera inside the floor.
 if destination.Y<floor+Camera.radius or #Workspace:GetPartBoundsInRadius(destination,Camera.radius,overlap)>0 then destination=focus end
 if (destination-focus).Magnitude<.05 then destination=focus+Vector3.new(0,.1,0) end
 return CFrame.lookAt(destination,focus)
end
function Camera.update(character,enabled)
 local camera=Workspace.CurrentCamera
 if not enabled or not camera or camera.CameraType~=Enum.CameraType.Custom or not character then return end
 local root=character:FindFirstChild('HumanoidRootPart');local human=character:FindFirstChildOfClass('Humanoid')
 if not root or not human or human.Health<=0 then return end
 local world=Workspace:FindFirstChild('DeepwoodCampaign');if not world then return end
 local geometry={Workspace.Terrain}
 for _,name in ipairs({'TerrainBlockout','GroundedForest'}) do local folder=world:FindFirstChild(name);if folder then table.insert(geometry,folder) end end
 local focus=camera.Focus.Position
 if (focus-root.Position).Magnitude>8 then focus=root.Position+Vector3.new(0,1.5,0) end
 local ground=Bounds.surface(root.Position.X,root.Position.Z) or Bounds.backgroundHeight
 focus=Vector3.new(focus.X,math.max(root.Position.Y+1,focus.Y,ground+2),focus.Z)
 camera.CFrame=Camera.constrain(focus,camera.CFrame.Position,geometry)
 camera.Focus=CFrame.new(focus)
end
local function lobbyView(camera, character, playTop)
 if not camera or camera.CameraType ~= Enum.CameraType.Custom or not character or not playTop then return end
 local humanoid = character:FindFirstChildOfClass('Humanoid')
 if not humanoid or not humanoid.RootPart or humanoid.Health <= 0 or camera.CameraSubject ~= humanoid then return end

 local view = camera.CFrame
 local bounds, size = character:GetBoundingBox()
 local localBounds = view:ToObjectSpace(bounds)
 local half = size / 2
 -- At steep orbit angles the lowest point on screen can be a robe or a weapon.
 local lowestSlope = math.huge
 for x = -1, 1, 2 do
  for y = -1, 1, 2 do
   for z = -1, 1, 2 do
    local corner = localBounds:PointToWorldSpace(Vector3.new(x * half.X, y * half.Y, z * half.Z))
    if corner.Z >= 0 then return end
    lowestSlope = math.min(lowestSlope, corner.Y / -corner.Z)
   end
  end
 end

 local clearY = playTop - math.max(10, camera.ViewportSize.Y * .03)
 local clearRay = camera:ScreenPointToRay(0, clearY, 0)
 local clearDirection = view:VectorToObjectSpace(clearRay.Direction)
 local clearSlope = clearDirection.Y / -clearDirection.Z
 if lowestSlope >= clearSlope then return end
 return view * CFrame.Angles(math.atan(lowestSlope) - math.atan(clearSlope), 0, 0)
end

function Camera.start(getLobbyPlayTop)
 local p=game:GetService('Players').LocalPlayer
 local function apply()
  local minimum=Camera.minimum(p:GetAttribute('K0SessionPhase'))
  if p.CameraMinZoomDistance~=minimum then p.CameraMinZoomDistance=minimum end
  local maximum=Camera.maximum(p:GetAttribute('K0SessionPhase'))
  if p.CameraMaxZoomDistance~=maximum then p.CameraMaxZoomDistance=maximum end
 end
 apply();p.CharacterAdded:Connect(apply)
 p:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(apply)
 p:GetPropertyChangedSignal('CameraMaxZoomDistance'):Connect(apply)
 p:GetAttributeChangedSignal('K0SessionPhase'):Connect(apply)
 local framedCamera, originalView, framedView
 Run:BindToRenderStep('RestoreLobbyCamera', Enum.RenderPriority.Input.Value - 1, function()
  -- Roblox uses the previous view for movement and orbit. Give it the native view back first.
  if framedCamera and framedCamera == Workspace.CurrentCamera
   and framedCamera.CameraType == Enum.CameraType.Custom and framedCamera.CFrame == framedView then
   framedCamera.CFrame = originalView
  end
  framedCamera, originalView, framedView = nil, nil, nil
 end)
 Run:BindToRenderStep('AdventureCameraPresentation', Enum.RenderPriority.Camera.Value + 2, function()
  local phase = p:GetAttribute('K0SessionPhase')
  if phase == 'Lobby' and Input.TouchEnabled and getLobbyPlayTop then
   local camera = Workspace.CurrentCamera
   local view = lobbyView(camera, p.Character, getLobbyPlayTop())
   if view then
    framedCamera, originalView = camera, camera.CFrame
    camera.CFrame = view
    framedView = camera.CFrame
   end
  elseif phase == 'Tutorial' and p:GetAttribute('TLTRoute') ~= 'Training' then
   Camera.update(p.Character, true)
  end
 end)
end
return Camera
