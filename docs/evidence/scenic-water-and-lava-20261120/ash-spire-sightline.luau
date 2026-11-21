assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local V = Vector3.new
local model = assert(world.folder:FindFirstChild('AshSpireVent', true))
local source = model:GetAttribute('Source')
local hot = model.LavaCurtainCore
local solids = {workspace.Terrain}
local changed = {}
for _, item in ipairs(world.folder:GetDescendants()) do
	if item:IsA('BasePart') and item.Transparency < .65 and (item.Position - source).Magnitude < 370 then
		table.insert(solids, item)
		if not item.CanQuery then
			item.CanQuery = true
			table.insert(changed, item)
		end
	end
end
local viewRay = RaycastParams.new()
viewRay.FilterType = Enum.RaycastFilterType.Include
viewRay.FilterDescendantsInstances = solids
local floorRay = RaycastParams.new()
floorRay.RespectCanCollide = true
local best
for _, x in ipairs({-130, -155, -185}) do
	for _, z in ipairs({-96, -72, -48, -24, 0, 24, 48, 72, 96, 120, 144}) do
		local sample = V(source.X + x, 170, source.Z + z)
		local floor = workspace:Raycast(sample, V(0, -100, 0), floorRay)
		if not floor or floor.Position.Y < 118 or floor.Position.Y > 144 then continue end
		local origin = floor.Position + V(0, 6.5, 0)
		local visible = 0
		for _, f in ipairs({-.42, -.21, 0, .21, .42}) do
			local target = hot.CFrame * V(0, 0, hot.Size.Z * f)
			local hit = workspace:Raycast(origin, target - origin, viewRay)
			if hit and hit.Instance:IsDescendantOf(model) then visible += 1 end
		end
		local row = {visible = visible, origin = origin, aim = hot.Position}
		print('ASH_VISION', visible, origin)
		if not best or visible > best.visible then best = row end
	end
end
for _, part in ipairs(changed) do part.CanQuery = false end
assert(best, 'no grounded views found')
print('ASH_BEST', best.visible, best.origin)
