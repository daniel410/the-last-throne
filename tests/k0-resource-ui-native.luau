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

	local root = playerGui.DeepwoodTrainingHud.Root
	check(status.TDPanelArt.Image ~= "", "status uses original TD panel")
	check(status.HEALTHTrack.TDResourceFrame.Image == "rbxassetid://97570429280107", "health uses pinned TD battle chrome")
	check(root.Actions.Attack.TDButtonArt:GetAttribute("TDArtKey") == "shellUpgrade", "primary attack uses TD green shell")
	check(root.BackToLobby.Caption.Text ~= "", "return control keeps a readable caption")
	check(root.BackToLobby.Position.Y.Offset >= 68, "return control reserves the top-right bag row")
	hud.setHealth(45, 90)
	check(status.HEALTHValue.Text == "45 / 90" and status.HEALTHTrack.Fill.Size.X.Scale == .5, "HP value and TD fill follow current health")
	local character = Instance.new("Model")
	character:SetAttribute("K0ClassId", "knight")
	character:SetAttribute("K0SkillSlotCount", 3)
	local skills = require(game:GetService("ReplicatedStorage").Shared.K0Config).Skills.knight
	character:SetAttribute("K0EquippedSkill1", skills[1].id)
	character:SetAttribute("K0SkillReady1", workspace:GetServerTimeNow() + 10)
	character:SetAttribute("K0ItemCount1", 7)
	character:SetAttribute("K0ItemDefinition1", "mana_potion")
	hud.setCooldowns(character)
	check(root.SkillBar.Item1.Caption.Text == "Small MP" and root.SkillBar.Item1.ItemCount.Text == "x7", "quick item follows reassignment and count")
	check(root.SkillBar.Skill1.Cooldown.Visible and not root.SkillBar.Skill1.Icon.Visible, "cooldown stays inside its skill control")
	check(root.SkillBar.Skill4.Caption.Text == "LOCKED" and not root.SkillBar.Skill4.Active, "fourth slot stays locked without advancement")
	check(root.SkillBar.Skill2.Caption.Text == "EMPTY" and not root.SkillBar.Skill2.Active, "unassigned slot stays inactive")
	character:SetAttribute("K0SkillSlotCount", 5)
	character:SetAttribute("K0SkillReady1", 0)
	hud.setCooldowns(character)
	check(not root.SkillBar.Skill1.Cooldown.Visible and root.SkillBar.Skill1.Icon.Visible, "ready skill clears stale countdown")
	check(root.SkillBar.Skill5.Caption.Text == "EMPTY", "practice slot count does not invent an ability")
	local catalog = require(game:GetService("ReplicatedStorage").Shared.ItemCatalog)
	local icons = require(client.PotionIcon)
	for _, id in ipairs(catalog.potions) do
		local def = catalog.items[id]
		local icon = icons.create(playerGui, def, UDim2.new(), UDim2.fromOffset(40, 40))
		check(icon:GetAttribute("DefinitionId") == id and icon.Glass.SizeMark.Text == (def.potionTier == 4 and "XL" or def.potionSize:sub(1, 1)), "icon identity and size mark: " .. id)
		check(icon.Glass.SizeMark.BackgroundTransparency == 1, "size text never covers the potion with a background: " .. id)
		icon:Destroy()
		character:SetAttribute("K0ItemDefinition1", id)
		character:SetAttribute("K0ItemCount1", 99)
		hud.setCooldowns(character)
		check(root.SkillBar.Item1.PotionIcon:GetAttribute("DefinitionId") == id, "assigned icon switches to " .. id)
		check(root.SkillBar.Item1.ItemCount.Text == "x99" and root.SkillBar.Item1.Caption.Text == def.potionSize .. " " .. def.glyph, "assigned size and quantity: " .. id)
	end
	character:SetAttribute("K0ItemCount1", 0)
	hud.setCooldowns(character)
	check(root.SkillBar.Item1.ItemCount.Text == "x0" and root.SkillBar.Item1.PotionIcon:GetAttribute("DefinitionId") == "mana_potion_xl", "empty stack keeps its assigned icon and displays zero")
	character:Destroy()

	local lobby = copyModule("HeroLobbyGui").create(function() end)
	local panel = playerGui.HeroLobbyGui.Shade.HeroPanel.SkillManagement
	local slots = panel.SkillSlots
	check(string.find(panel.Instructions.Text, "level 20 advancement for slot 4", 1, true) ~= nil, "slot 4 requires the level 20 advancement")
	check(string.find(panel.Instructions.Text, "level 40 for slot 5", 1, true) ~= nil, "slot 5 requires the level 40 advancement")
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
