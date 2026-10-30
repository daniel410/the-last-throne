-- Keep Roblox orbit/zoom controls, then constrain the final living adventure
-- camera. Death/cutscene cameras keep their own authority.
local Run=game:GetService('RunService')
local Workspace=game:GetService('Workspace')
local Bounds=require(game:GetService('ReplicatedStorage').Shared.DeepwoodBounds)
local Camera={min=6,max=18,minPitch=math.rad(22),maxPitch=math.rad(72),radius=.6}
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
function Camera.start()
 local p=game:GetService('Players').LocalPlayer
 local function apply()
  if p.CameraMinZoomDistance~=Camera.min then p.CameraMinZoomDistance=Camera.min end
  if p.CameraMaxZoomDistance~=Camera.max then p.CameraMaxZoomDistance=Camera.max end
 end
 apply();p.CharacterAdded:Connect(apply)
 p:GetPropertyChangedSignal('CameraMinZoomDistance'):Connect(apply)
 p:GetPropertyChangedSignal('CameraMaxZoomDistance'):Connect(apply)
 Run:BindToRenderStep('DeepwoodGroundedCamera',Enum.RenderPriority.Camera.Value+2,function()
  Camera.update(p.Character,p:GetAttribute('K0SessionPhase')=='Tutorial' and p:GetAttribute('TLTRoute')~='Training')
 end)
end
return Camera
