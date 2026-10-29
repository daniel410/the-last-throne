local Chest = {}
function Chest.create(lobby)
	local model = Instance.new("Model")
	model.Name = "DawnspireAccountStorage"
	local function part(name, size, offset, color)
		local value = Instance.new("Part")
		value.Name, value.Size, value.Position = name, size, lobby.origin + Vector3.new(12, 0, 24) + offset
		value.Anchored, value.CanCollide = true, true
		value.Material, value.Color = Enum.Material.Wood, color
		value.Parent = model
		return value
	end
	local body = part("Chest", Vector3.new(5, 3, 3), Vector3.new(0, 1.5, 0), Color3.fromRGB(20, 29, 45))
	part("Lid", Vector3.new(5.3, 0.6, 3.3), Vector3.new(0, 3.25, 0), Color3.fromRGB(40, 65, 99))
	for _, x in ipairs({-1.7, 1.7}) do
		local band = part("GoldBand", Vector3.new(0.28, 3.6, 3.4), Vector3.new(x, 1.8, 0), Color3.fromRGB(222, 185, 106))
		band.Material = Enum.Material.Metal
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name, prompt.ActionText, prompt.ObjectText = "OpenAccountStorage", "Open Storage", "Dawnspire Storage"
	prompt.KeyboardKeyCode, prompt.GamepadKeyCode = Enum.KeyCode.F, Enum.KeyCode.ButtonX
	prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 0, 12, false
	prompt.Parent = body
	model.Parent = lobby.folder
	return body, prompt
end
return Chest
