-- Local visualisation of server-authored enemy attack geometry. It does not
-- calculate hits or change the server's combat state.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Text = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("K0Text"))

local Telegraphs = {}
local SEGMENTS = 16

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

local function update(visual)
	local model = visual.model
	local state = model:GetAttribute("K0EnemyState")
	local warning = model:GetAttribute("K0Telegraph")
	local origin = model:GetAttribute("K0AttackOrigin")
	local direction = model:GetAttribute("K0AttackDirection")
	local range = model:GetAttribute("K0AttackRange")
	local angle = model:GetAttribute("K0AttackAngle")
	local root = model:FindFirstChild("HumanoidRootPart")
	if (state ~= "Windup" and state ~= "Active") or (warning ~= "Melee" and warning ~= "Unblockable")
		or typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" or typeof(range) ~= "number"
		or typeof(angle) ~= "number" or direction.Magnitude < 0.01 or not root then
		hide(visual)
		return
	end
	-- This prototype's training field is flat at Y=0. Geometry here is a
	-- warning, while the server still decides obstruction, range, and hits.
	local center = Vector3.new(origin.X, 0.2, origin.Z)
	local horizontal = Vector3.new(direction.X, 0, direction.Z)
	if horizontal.Magnitude < 0.01 then hide(visual) return end
	horizontal = horizontal.Unit
	range = math.clamp(range, 0, 30)
	angle = math.clamp(angle, 0, 360)
	local color = if warning == "Unblockable" then Color3.fromRGB(255, 73, 58) else Color3.fromRGB(255, 190, 52)
	local function endpoint(degrees)
		local rotated = CFrame.Angles(0, math.rad(degrees), 0):VectorToWorldSpace(horizontal)
		return center + rotated * range
	end
	local previous = endpoint(-angle / 2)
	for index = 1, SEGMENTS do
		local nextPoint = endpoint(-angle / 2 + angle * index / SEGMENTS)
		line(visual.lines[index], previous, nextPoint, color)
		previous = nextPoint
	end
	if angle < 359 then
		line(visual.lines[SEGMENTS + 1], center, endpoint(-angle / 2), color)
		line(visual.lines[SEGMENTS + 2], center, endpoint(angle / 2), color)
	else
		visual.lines[SEGMENTS + 1].Transparency = 1
		visual.lines[SEGMENTS + 2].Transparency = 1
	end
	visual.billboard.Adornee = root
	visual.billboard.Enabled = true
	visual.label.Text = if warning == "Unblockable" then Text.Unblockable else Text.IncomingAttack
	visual.label.TextColor3 = color
end

function Telegraphs.start()
	task.spawn(function()
		local field = Workspace:WaitForChild("DeepwoodK0", 30)
		local enemies = field and field:WaitForChild("Enemies", 10)
		if not enemies then return end
		local container = Instance.new("Folder")
		container.Name = "K0LocalTelegraphs"
		container.Parent = Workspace
		local visuals = {}
		local function add(model)
			if model:IsA("Model") and not visuals[model] then
				visuals[model] = visualFor(model, container)
			end
		end
		local function remove(model)
			local visual = visuals[model]
			if visual then
				visual.folder:Destroy()
				visuals[model] = nil
			end
		end
		for _, model in enemies:GetChildren() do add(model) end
		enemies.ChildAdded:Connect(add)
		enemies.ChildRemoved:Connect(remove)
		RunService.RenderStepped:Connect(function()
			for _, visual in visuals do update(visual) end
		end)
	end)
end

return Telegraphs
