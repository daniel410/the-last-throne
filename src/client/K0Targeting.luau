-- Client-only screen picking. The server independently validates every target.
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.K0Config)
local Assist = require(Shared.TargetAssistRules)
local Targeting = {}

function Targeting.valid(model)
	local field = Workspace:FindFirstChild("DeepwoodK0")
	local enemies = field and field:FindFirstChild("Enemies")
	local humanoid = model and model:FindFirstChildOfClass("Humanoid")
	return enemies and model and model.Parent == enemies and humanoid and humanoid.Health > 0
		and model:FindFirstChild("HumanoidRootPart") ~= nil
end

function Targeting.definition(character, action)
	if not character then return nil end
	local classId = character:GetAttribute("K0ClassId")
	if action == "Attack" then
		local profile = Config.BasicAttackProfiles[classId]
		local combo = character:GetAttribute("K0Combo") or 0
		if not profile then return nil end
		local definition = {}
		for key, value in pairs(profile.attacks[combo % #profile.attacks + 1]) do definition[key] = value end
		definition.maxHeight = profile.maxHeight
		definition.ranged = classId == "elf"
		return definition
	end
	local slot = action:match("^Skill([12345])$")
	if action == "CastArcane" and classId == "mage" then slot = "1" end
	local id = slot and character:GetAttribute("K0EquippedSkill" .. slot)
	if action == "Ultimate" then id = character:GetAttribute("K0UltimateId") end
	if not id or id == "" then return nil end
	for _, definition in ipairs(Config.Skills[classId] or {}) do
		if definition.id == id and Assist.directional(definition) then return definition end
	end
	return nil
end

-- Moving away takes priority over facing the old target. Stationary manual
-- selections may turn freely; automatic selection stays in the forward cone.
function Targeting.resolve(character, action, preferred, automatic, preferredAutomatic)
	local definition = Targeting.definition(character, action)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local camera = Workspace.CurrentCamera
	if not definition or not root or not humanoid or not camera then return nil end
	local moving = humanoid.MoveDirection.Magnitude > Assist.movementThreshold
	local forward = moving and humanoid.MoveDirection or root.CFrame.LookVector
	forward = Vector3.new(forward.X, 0, forward.Z)
	if forward.Magnitude <= Assist.movementThreshold then return nil end
	forward = forward.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	params.RespectCanCollide = true
	local function eligible(model, manual)
		if not Targeting.valid(model) then return false end
		local enemyRoot = model:FindFirstChild("HumanoidRootPart")
		local delta = enemyRoot.Position - root.Position
		local flat = Vector3.new(delta.X, 0, delta.Z)
		local distance = definition.ranged and delta.Magnitude or flat.Magnitude
		if not Assist.inRange(distance, math.abs(delta.Y), definition) then return false end
		if (moving or not manual) and flat.Magnitude > 0.01 and not Assist.inFront(forward:Dot(flat.Unit)) then return false end
		local _, visible = camera:WorldToViewportPoint(enemyRoot.Position)
		if not visible then return false end
		local hit = Workspace:Raycast(root.Position, delta, params)
		return not hit or hit.Instance:IsDescendantOf(model)
	end
	if preferred and (automatic or not preferredAutomatic) and eligible(preferred, not preferredAutomatic) then return preferred end
	if not automatic then return nil end
	local field = Workspace:FindFirstChild("DeepwoodK0")
	local enemies = field and field:FindFirstChild("Enemies")
	local best, bestDistance
	for _, enemy in ipairs(enemies and enemies:GetChildren() or {}) do
		if eligible(enemy, false) then
			local distance = (enemy.HumanoidRootPart.Position - root.Position).Magnitude
			if not bestDistance or distance < bestDistance or distance == bestDistance and enemy.Name < best.Name then
				best, bestDistance = enemy, distance
			end
		end
	end
	return best
end

function Targeting.pick(screenPosition, character)
	local field = Workspace:FindFirstChild("DeepwoodK0")
	local enemies = field and field:FindFirstChild("Enemies")
	local camera = Workspace.CurrentCamera
	if not enemies or not camera or not character then return nil end
	-- Query the visible TD meshes locally without changing server physics.
	for _, enemy in ipairs(enemies:GetChildren()) do
		local visual = enemy:FindFirstChild("TdMonsterVisual")
		if visual then
			for _, part in ipairs(visual:GetDescendants()) do
				if part:IsA("BasePart") and not part.CanCollide then part.CanQuery = true end
			end
		end
	end
	local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	local part = hit and hit.Instance
	while part and part.Parent ~= enemies do part = part.Parent end
	if Targeting.valid(part) then return part end
	return nil
end

return Targeting
