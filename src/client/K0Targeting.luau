-- Client-only screen picking. The server independently validates every target.
local Workspace = game:GetService("Workspace")
local Targeting = {}

function Targeting.valid(model)
	local field = Workspace:FindFirstChild("DeepwoodK0")
	local enemies = field and field:FindFirstChild("Enemies")
	local humanoid = model and model:FindFirstChildOfClass("Humanoid")
	return enemies and model and model.Parent == enemies and humanoid and humanoid.Health > 0
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
