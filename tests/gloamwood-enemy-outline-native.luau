assert(game.PlaceId == 0 and #game:GetService("Players"):GetPlayers() == 0)
local client = game:GetService("StarterPlayer").StarterPlayerScripts.Client
local EnemyOutline = require(client.GloamwoodEnemyOutline)
local Mood = require(client.DeepwoodAtmosphere)
local Lighting = game:GetService("Lighting")
local checks = 0
local function check(condition, message)
	assert(condition, message)
	checks += 1
end

for _, module in ipairs({client.GloamwoodEnemyOutline, client.K0EnemyVisual, client.DeepwoodAtmosphere}) do
	check(loadstring(module.Source), module.Name .. " compiles")
end
local originalAmbient = Lighting.Ambient
Mood.update("Gloamwood")
check(Mood.currentMode() == "Gloamwood" and Lighting.ClockTime == 0, "Gloamwood remains at midnight")
check(Lighting.Ambient == Color3.fromRGB(122, 138, 162), "Gloamwood shadow fill is active")
Mood.update("HauntedGraveyard")
check(Mood.currentMode() == "HauntedGraveyard" and Lighting.Ambient == Color3.fromRGB(122, 137, 160), "adjacent moonlit profile keeps its own light")
Mood.update(nil)
check(Mood.currentMode() == nil and Lighting.Ambient == originalAmbient, "leaving the campaign restores authored lighting")

local folder = Instance.new("Folder")
folder.Parent = workspace
local function spawnModel(name, x, y, z)
	local model = Instance.new("Model")
	model.Name = name
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Anchored = true
	root.Position = Vector3.new(x, y, z)
	root.Parent = model
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model
	model.Parent = folder
	return model
end
local outlines = {}
local function refresh(origin)
	EnemyOutline.update(outlines, folder:GetChildren(), origin)
end
local function highlight(model)
	return model:FindFirstChild("GloamwoodEnemyOutline")
end

local spider = spawnModel("Webling", 0, 0, 48)
local distant = spawnModel("Silkweaver", 0, 0, 49)
local elevated = spawnModel("Gloambat", 0, 30, 40)
local dead = spawnModel("FallenWebling", 0, 0, 5)
dead.Humanoid.Health = 0
refresh(Vector3.zero)
local originalOutline = highlight(spider)
check(originalOutline and originalOutline.Adornee == spider, "living enemy at the distance boundary is outlined")
check(originalOutline.DepthMode == Enum.HighlightDepthMode.Occluded, "geometry can occlude the outline")
check(originalOutline.FillTransparency == 1 and originalOutline.OutlineTransparency > 0, "the outline is subtle and shows the monster's surface")
check(not highlight(distant) and not highlight(elevated) and not highlight(dead), "distant, vertically distant, and dead enemies are excluded")
refresh(Vector3.zero)
check(highlight(spider) == originalOutline, "steady refresh reuses the existing instance")

for _, effectName in ipairs({"K0TargetHighlight", "ProvokeEffect", "GravityEffect"}) do
	local effect = Instance.new("Highlight")
	effect.Name = effectName
	effect.Parent = spider
	refresh(Vector3.zero)
	check(not highlight(spider) and effect.Parent == spider, effectName .. " keeps priority")
	effect:Destroy()
	refresh(Vector3.zero)
	check(highlight(spider), "outline returns after " .. effectName)
end

local crowd = {}
for distance = 12, 1, -1 do
	crowd[distance] = spawnModel("Enemy" .. distance, distance, 0, 0)
end
refresh(Vector3.zero)
for distance, model in ipairs(crowd) do
	check((highlight(model) ~= nil) == (distance <= 10), "only the ten closest enemies are outlined")
end
check(not highlight(spider), "nearby enemies replace the outline at the far edge")
crowd[1].Humanoid.Health = 0
crowd[2].Parent = nil
refresh(Vector3.zero)
check(not highlight(crowd[1]) and not highlight(crowd[2]), "death and stream-out remove outlines")
check(highlight(crowd[11]) and highlight(crowd[12]), "vacant slots pass to the next closest enemies")
refresh(nil)
check(next(outlines) == nil and not highlight(crowd[12]), "a missing or dead player clears the outlines")
refresh(Vector3.zero)
EnemyOutline.clear(outlines)
check(next(outlines) == nil and not highlight(crowd[12]), "region or folder teardown removes all outlines")
crowd[2]:Destroy()
folder:Destroy()
print("Gloamwood enemy visibility: " .. checks .. " checks passed")
