local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Tutorial = require(ReplicatedStorage.Shared.TrainingTutorial)

local Coach = {}
local GOLD = Color3.fromRGB(255, 206, 100)

function Coach.create(player)
	local waypoint = Instance.new("Part")
	waypoint.Name = "LocalTrainingWaypoint"
	waypoint.Shape = Enum.PartType.Cylinder
	waypoint.Size = Vector3.new(0.12, Tutorial.radius * 2, Tutorial.radius * 2)
	waypoint.CFrame = CFrame.new(Tutorial.waypoint) * CFrame.Angles(0, 0, math.pi / 2)
	waypoint.Anchored, waypoint.CanCollide, waypoint.CanTouch, waypoint.CanQuery = true, false, false, false
	waypoint.CastShadow = false
	waypoint.Material, waypoint.Color, waypoint.Transparency = Enum.Material.Neon, GOLD, 0.45

	local target = Instance.new("Highlight")
	target.Name = "LocalTrainingTarget"
	target.DepthMode = Enum.HighlightDepthMode.Occluded
	target.FillTransparency = 1
	target.OutlineColor = GOLD
	target.Enabled = false
	target.Parent = Workspace

	local function updateTarget()
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local nearest, distance = nil, 60
		if root then
			for _, enemy in ipairs(CollectionService:GetTagged(Tutorial.enemyTag)) do
				local humanoid = enemy:FindFirstChildOfClass("Humanoid")
				local enemyRoot = enemy.PrimaryPart
				if humanoid and humanoid.Health > 0 and enemyRoot and enemy:IsDescendantOf(Workspace) then
					local range = (root.Position - enemyRoot.Position).Magnitude
					if range < distance then nearest, distance = enemy, range end
				end
			end
		end
		target.Adornee, target.Enabled = nearest, nearest ~= nil
	end

	local previous, connection
	return function(lesson)
		if lesson == previous then return end
		previous = lesson
		waypoint.Parent = if lesson == "moved" then Workspace else nil
		if lesson == "attacked" or lesson == "usedSkill" or lesson == "cast" or lesson == "followUp" then
			updateTarget()
			if not connection then
				local elapsed = 0
				connection = RunService.Heartbeat:Connect(function(delta)
					elapsed += delta
					if elapsed < 0.25 then return end
					elapsed = 0
					updateTarget()
				end)
			end
		else
			if connection then connection:Disconnect(); connection = nil end
			target.Enabled, target.Adornee = false, nil
		end
	end
end

return Coach
