-- Isolated native client-presentation fixture. No network transport or audio
-- output device is implied by this test; server confirmation is tested separately.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "Hit effects QA requires a local empty place")
local visual = require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.K0HitEffects)
local result = { kind = "K0_HIT_EFFECTS_NATIVE", checks = 0, failures = {}, samples = {},
	coverage = "Native presentation instances and cleanup; no real player, RemoteEvent transport, visual or audible acceptance" }
local function check(value, label) result.checks += 1; assert(value, label) end
local function holders()
	local list = {}
	for _, child in ipairs(workspace:GetChildren()) do if child.Name == "K0HitEffect" then table.insert(list, child) end end
	return list
end
local ok, err = xpcall(function()
	if not RunService:IsRunning() then RunService:Run() end
	local model = Instance.new("Model"); model.Name = "QaImpactTarget"; model.Parent = workspace
	local target = Instance.new("Part"); target.Anchored = true; target.Parent = model
	local bar = Instance.new("BillboardGui"); bar.Name = "EnemyHealthBar"; bar.StudsOffsetWorldSpace = Vector3.new(0, 3, 0); bar.Parent = model
	check(not visual.show(model, Vector3.zero, 0, "knight", "Goblin"), "zero damage is rejected")
	check(not visual.show(model, Vector3.zero, 12, "unknown", "Goblin"), "unknown class is rejected")
	check(not visual.show(model, Vector3.new(0/0, 0, 0), 12, "knight", "Goblin"), "non-finite position rejected")
	check(#holders() == 0, "invalid events create no effects")
	for _, classId in ipairs({ "knight", "dwarf", "mage", "elf" }) do
		local before = {}; for _, h in ipairs(holders()) do before[h] = true end
		check(visual.show(model, Vector3.new(0, 50, 0), 75, classId, classId == "dwarf" and "Slime" or "Goblin"), classId .. " accepted")
		local h; for _, candidate in ipairs(holders()) do if not before[candidate] then h = candidate end end
		check(h ~= nil and h.Anchored and not h.CanCollide and not h.CanQuery and not h.CanTouch, "inert local effect")
		check(h:FindFirstChild("K0ImpactFlash") ~= nil and h:FindFirstChild("K0HitFlash") ~= nil, "impact and monster flash created")
		check(h:FindFirstChild("K0DamageNumber").Amount.Text == "75", "actual damage number shown")
		check(h.K0DamageNumber.StudsOffsetWorldSpace.Y >= 3.8, "damage number clears the health bar")
		local particles = 0; for _, child in ipairs(h:GetChildren()) do if child.Name == (classId == "dwarf" and "K0GelDroplet" or "K0ImpactSpark") then particles += 1 end end
		check(particles == 5, "material-appropriate particles")
		local sound = h:FindFirstChild("K0HitSound")
		check(sound ~= nil and sound.SoundId ~= "" and sound.Volume > 0, "class impact sound created")
		table.insert(result.samples, { class = classId, sound = sound.SoundId, speed = sound.PlaybackSpeed })
		task.wait(0.09)
	end
	local skillSamples = {
		{ "knight", "knight.common.bash", "shield" }, { "knight", "knight.common.whirlwind", "sweep" },
		{ "dwarf", "dwarf.common.overhead", "chop" }, { "dwarf", "dwarf.common.throw", "axe" }, { "dwarf", "dwarf.common.ground", "shockwave" },
		{ "elf", "elf.common.aimed", "precision" }, { "elf", "elf.common.rapid", "rapid" }, { "elf", "elf.common.multi", "multi" },
		{ "mage", "mage.common.mana_bolt", "mana" }, { "mage", "mage.common.water_ball", "water" }, { "mage", "mage.common.gravity", "gravity" },
	}
	for _, item in ipairs(skillSamples) do
		local before = {}; for _, h in ipairs(holders()) do before[h] = true end
		check(visual.show(model, Vector3.new(0, 50, 0), 50, item[1], "Goblin", Vector3.new(0, 0, -1), item[2]), "skill hit accepted")
		local h; for _, candidate in ipairs(holders()) do if not before[candidate] then h = candidate end end
		check(h and h:GetAttribute("K0SkillEffectId") == item[2], "skill identity preserved")
		check(h.K0SkillImpact:GetAttribute("Style") == item[3], "correct skill impact style")
	end
	local before = {}; for _, h in ipairs(holders()) do before[h] = true end
	check(visual.show(model, Vector3.zero, 10, "elf", "Goblin", Vector3.new(0, 0, -1), "mage.common.gravity"), "cross-class ID falls back")
	local h; for _, candidate in ipairs(holders()) do if not before[candidate] then h = candidate end end
	check(h and h:FindFirstChild("K0SkillImpact") == nil, "cross-class ID cannot choose wrong effect")
	for _ = 1, 30 do check(visual.show(model, Vector3.zero, 1, "knight", "Goblin"), "bounded effect accepts valid hit") end
	check(#holders() <= 24, "effect count is bounded")
	task.wait(1.4)
	check(#holders() == 0, "temporary effects clean up")
	model:Destroy()
end, debug.traceback)
if not ok then table.insert(result.failures, tostring(err)) end
result.pass = #result.failures == 0
print("K0_HIT_EFFECTS_NATIVE " .. HttpService:JSONEncode(result))
assert(result.pass, "Hit effect fixture failed; see K0_HIT_EFFECTS_NATIVE")
