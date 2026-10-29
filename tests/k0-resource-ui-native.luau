-- Isolated Studio GUI fixture using the actual HUD and lobby modules. Only
-- LocalPlayer is replaced with a PlayerGui double; rendering/input is not tested.
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local HttpService = game:GetService("HttpService")
assert(game.PlaceId == 0 and #Players:GetPlayers() == 0, "UI fixture requires an empty local place")

local client = assert(StarterPlayer.StarterPlayerScripts:FindFirstChild("Client"))
local fixture = Instance.new("Folder")
fixture.Name = "K0ResourceUiFixture"
fixture.Parent = workspace
local playerGui = Instance.new("Folder")
playerGui.Name = "PlayerGui"
playerGui.Parent = fixture
local copies = {}
local report = { kind = "K0_RESOURCE_UI_NATIVE", checks = 0, failures = {},
	coverage = "Actual GUI constructors and state refresh, native GUI instances, LocalPlayer double; no rendered client or device" }

local function check(condition, message)
	report.checks += 1
	assert(condition, message)
end
local function copyModule(name)
	local original = assert(client:FindFirstChild(name))
	local replacement = [[local Players = { LocalPlayer = { WaitForChild = function(_, name)
  assert(name == "PlayerGui"); return script.FixturePlayerGui.Value
end } }]]
	local source, count = original.Source:gsub('local Players = game:GetService%("Players"%)', function() return replacement end)
	assert(count == 1, name .. " LocalPlayer binding changed")
	local copy = Instance.new("ModuleScript")
	copy.Name, copy.Source = "ResourceUiQa" .. name, source
	local value = Instance.new("ObjectValue")
	value.Name, value.Value, value.Parent = "FixturePlayerGui", playerGui, copy
	copy.Parent = client
	table.insert(copies, copy)
	return require(copy)
end

local ok, failure = xpcall(function()
	local hud = copyModule("K0Hud").create()
	local status = playerGui.DeepwoodTrainingHud.Root.Status
	local label, value, track = status.MANALabel, status.MANAValue, status.MANATrack
	check(not label.Visible and not value.Visible and not track.Visible, "empty hero has no mana bar")
	check(status.Size.Y.Offset == 87, "empty status panel fits one bar")
	for _, classId in ipairs({ "knight", "elf", "dwarf" }) do
		hud.setClass(classId)
		hud.setMana(nil, nil)
		check(not label.Visible and status.Size.Y.Offset == 87, classId .. " shows health only")
	end
	hud.setClass("mage")
	hud.setMana(85, 100)
	check(label.Visible and value.Visible and track.Visible, "mage mana bar is visible")
	check(value.Text == "85 / 100" and status.Size.Y.Offset == 132, "mana amount and panel size are correct")
	hud.setMana(0, 100)
	check(value.Text == "0 / 100" and label.Visible, "empty mana pool remains visible")
	hud.setMana(nil, nil)
	check(not label.Visible and status.Size.Y.Offset == 87, "changing heroes hides stale mana")
	-- Capability-driven display does not itself grant Elf a pool or advancement.
	hud.setClass("elf")
	hud.setMana(25, 40)
	check(label.Visible and value.Text == "25 / 40", "replicated mana capability controls the bar")
	for _, child in ipairs(status:GetDescendants()) do
		check(not string.find(string.lower(child.Name), "stamina", 1, true), "status has no stamina control")
	end

	local lobby = copyModule("HeroLobbyGui").create(function() end)
	local slots = playerGui.HeroLobbyGui.Shade.HeroPanel.SkillManagement.SkillSlots
	local config = require(game:GetService("ReplicatedStorage").Shared.K0Config)
	for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
		local hero = { heroId = "test", classId = classId, skillSlots = {1, 2, 3, 0, 0}, practiceAdvanced = false }
		lobby.setState({ phase = "Lobby", heroes = {hero}, selectedHeroId = "test", canManage = true, canStart = true })
		for index = 1, 3 do
			local actual = slots["Slot" .. index].Text
			local skill = config.Skills[classId][index]
			check(string.find(actual, skill.name, 1, true) ~= nil, classId .. " slot shows its skill")
			check(string.find(actual, tostring(skill.cooldown) .. "s cooldown", 1, true) ~= nil, classId .. " slot shows its cooldown")
			check(string.find(string.upper(actual), "STAMINA", 1, true) == nil, classId .. " slot has no stamina cost")
			if skill.magic then
				check(string.find(actual, tostring(skill.manaCost) .. " MP", 1, true) ~= nil, "magic slot shows MP cost")
			else
				check(string.find(actual, " MP", 1, true) == nil, "physical slot has no MP cost")
			end
		end
		check(string.find(slots.Slot4.Text, "LOCKED", 1, true) ~= nil, classId .. " fourth slot remains locked")
		hero.practiceAdvanced = true
		lobby.setState({ phase = "Lobby", heroes = {hero}, selectedHeroId = "test", canManage = true, canStart = true })
		check(string.find(slots.Slot4.Text, "EMPTY", 1, true) ~= nil, classId .. " practice slot remains empty")
	end
end, debug.traceback)
if not ok then table.insert(report.failures, tostring(failure)) end
for _, module in ipairs(copies) do module:Destroy() end
fixture:Destroy()
report.pass = ok
print("K0_RESOURCE_UI_NATIVE " .. HttpService:JSONEncode(report))
assert(ok, "Resource UI fixture failed; see K0_RESOURCE_UI_NATIVE")
