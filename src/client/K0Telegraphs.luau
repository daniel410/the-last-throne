-- Local visualisation of server-authored enemy attack geometry. It does not
-- calculate hits or change the server's combat state.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))

local Telegraphs = {}
local SEGMENTS = 16
local Settings=require(script.Parent.GameSettings)

local function createLine(parent)
	local part = Instance.new("Part")
	part.Name = "AttackOutline"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Transparency = 1
	part.Parent = parent
	return part
end

local function line(part, from, to, color)
	local distance = (to - from).Magnitude
	if distance < 0.01 then
		part.Transparency = 1
		return
	end
	part.Color = color
	part.Size = Vector3.new(0.14, 0.06, distance)
	part.CFrame = CFrame.lookAt((from + to) / 2, to)
	part.Transparency = 0.12
end

local function visualFor(model, parent)
	local folder = Instance.new("Folder")
	folder.Name = "EnemyTelegraph"
	folder.Parent = parent
	local lines = {}
	for index = 1, SEGMENTS + 2 do lines[index] = createLine(folder) end
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AttackWarning"
	billboard.Size = UDim2.fromOffset(160, 32)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 4.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.Parent = folder
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextSize = 15
	label.Parent = billboard
	return { model = model, folder = folder, lines = lines, billboard = billboard, label = label }
end

local function hide(visual)
	visual.billboard.Enabled = false
	for _, part in visual.lines do part.Transparency = 1 end
end

local function attack(model)
 local state=model:GetAttribute("K0EnemyState")
 local warning=model:GetAttribute("K0Telegraph")
 local origin=model:GetAttribute("K0AttackOrigin")
 local direction=model:GetAttribute("K0AttackDirection")
 local range=model:GetAttribute("K0AttackRange")
 local angle=model:GetAttribute("K0AttackAngle")
 local root=model:FindFirstChild("HumanoidRootPart")
 local human=model:FindFirstChildOfClass("Humanoid")
 if (state~="Windup" and state~="Active") or (warning~="Melee" and warning~="Unblockable")
  or typeof(origin)~="Vector3" or typeof(direction)~="Vector3" or typeof(range)~="number"
  or typeof(angle)~="number" or not root or human and human.Health<=0 then return end
 local horizontal=Vector3.new(direction.X,0,direction.Z)
 if horizontal.Magnitude<.01 or range<=0 then return end
 return {origin=origin,direction=horizontal.Unit,range=math.clamp(range,0,30),angle=math.clamp(angle,0,360),warning=warning,root=root}
end

local function draw(visual,data,params)
 local color=data.warning=="Unblockable" and Color3.fromRGB(255,73,58) or Color3.fromRGB(255,190,52)
 local function ground(position)
  local hit=Workspace:Raycast(Vector3.new(position.X,data.origin.Y+8,position.Z),Vector3.new(0,-96,0),params)
  return hit and hit.Normal.Y>.4 and hit.Position+Vector3.new(0,.16,0) or nil
 end
 local center=ground(data.origin)
 if not center then hide(visual);return end
 local function endpoint(degrees)
  local direction=CFrame.Angles(0,math.rad(degrees),0):VectorToWorldSpace(data.direction)
  return ground(data.origin+direction*data.range)
 end
 local function segment(index,a,b)
  if a and b then line(visual.lines[index],a,b,color) else visual.lines[index].Transparency=1 end
 end
 local first=endpoint(-data.angle/2);local previous=first
 for index=1,SEGMENTS do
  local nextPoint=endpoint(-data.angle/2+data.angle*index/SEGMENTS)
  segment(index,previous,nextPoint);previous=nextPoint
 end
 if data.angle<359 then
  segment(SEGMENTS+1,center,first);segment(SEGMENTS+2,center,previous)
 else
  visual.lines[SEGMENTS+1].Transparency=1;visual.lines[SEGMENTS+2].Transparency=1
 end
 visual.billboard.Adornee=data.root;visual.billboard.Enabled=true
 visual.label.Text=data.warning=="Unblockable" and Text.Unblockable or Text.IncomingAttack
 visual.label.TextColor3=color
end

-- One controller per streamed enemy folder. Inactive distant enemies allocate no Parts.
function Telegraphs.create(enemies,player)
 local container=Instance.new("Folder");container.Name="K0LocalTelegraphs";container.Parent=Workspace
 local visuals={};local hazards={};local controller={}
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.RespectCanCollide=true
 local function remove(model)
  local visual=visuals[model]
  if visual then visual.folder:Destroy();visuals[model]=nil end
 end
 local function addHazard(part)
  if part:IsA('BasePart') and part.Name=='CorruptionWarning' then
   local campaign=Workspace:FindFirstChild('DeepwoodCampaign')
   if campaign and part:IsDescendantOf(campaign) then
    hazards[part]=part.LocalTransparencyModifier
    part.LocalTransparencyModifier=Settings.enabled(player,'attacks') and hazards[part] or 1
   end
  end
 end
 local campaign=Workspace:FindFirstChild('DeepwoodCampaign')
 if campaign then for _,part in ipairs(campaign:GetChildren()) do addHazard(part) end end
 local hazardAdded=Workspace.DescendantAdded:Connect(addHazard)
 local hazardRemoved=Workspace.DescendantRemoving:Connect(function(part)
  if hazards[part]~=nil then part.LocalTransparencyModifier=hazards[part];hazards[part]=nil end
 end)
 function controller.update()
  for part,original in pairs(hazards) do part.LocalTransparencyModifier=Settings.enabled(player,'attacks') and original or 1 end
  local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
  local human=character and character:FindFirstChildOfClass("Humanoid")
  if not Settings.enabled(player,'attacks') or player:GetAttribute('K0SessionPhase')~='Tutorial' or not root or not human or human.Health<=0 then
   for model in pairs(visuals) do remove(model) end;return
  end
  local surfaces={Workspace.Terrain}
  for _,name in ipairs({'DeepwoodK0','DeepwoodCampaign'}) do
   local world=Workspace:FindFirstChild(name)
   if world then for _,key in ipairs({'TerrainBlockout','GroundedForest'}) do
    local surface=world:FindFirstChild(key);if surface then table.insert(surfaces,surface) end
   end end
  end
  params.FilterDescendantsInstances=surfaces
  for model in pairs(visuals) do
   local enemyRoot=model:FindFirstChild('HumanoidRootPart')
   if model.Parent~=enemies or not enemyRoot or (enemyRoot.Position-root.Position).Magnitude>180 then remove(model) end
  end
  for _,model in ipairs(enemies:GetChildren()) do if model:IsA('Model') then
   local enemyRoot=model:FindFirstChild('HumanoidRootPart')
   local data=enemyRoot and (enemyRoot.Position-root.Position).Magnitude<=180 and attack(model)
   if data then
    local visual=visuals[model]
    if not visual then visual=visualFor(model,container);visuals[model]=visual end
    draw(visual,data,params)
   elseif visuals[model] then hide(visuals[model]) end
  end end
 end
 local removed=enemies.ChildRemoved:Connect(remove)
 local changed=player:GetAttributeChangedSignal('TLTAttackRangesEnabled'):Connect(controller.update)
 function controller.destroy()
  removed:Disconnect();changed:Disconnect();hazardAdded:Disconnect();hazardRemoved:Disconnect()
  for part,original in pairs(hazards) do part.LocalTransparencyModifier=original end
  container:Destroy();table.clear(visuals);table.clear(hazards)
 end
 return controller
end

function Telegraphs.start()
 local player=game:GetService('Players').LocalPlayer
 local current,controller;local elapsed=0
 -- Rebind after streaming removes/reintroduces the training/epic enemy container.
 RunService.RenderStepped:Connect(function(dt)
  elapsed+=dt;if elapsed<1/30 then return end;elapsed=0
  local field=Workspace:FindFirstChild('DeepwoodK0')
  local enemies=field and field:FindFirstChild('Enemies')
  if enemies~=current then
   if controller then controller.destroy();controller=nil end
   current=enemies;if enemies then controller=Telegraphs.create(enemies,player) end
  end
  if controller then controller.update() end
 end)
end
return Telegraphs
