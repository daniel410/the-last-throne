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
local function copyModule(name, mobileViewport)
	local original = assert(client:FindFirstChild(name))
	local replacement = [[local Players = { LocalPlayer = { WaitForChild = function(_, name)
  assert(name == "PlayerGui"); return script.FixturePlayerGui.Value
end } }]]
	local source, count = original.Source:gsub('local Players = game:GetService%("Players"%)', function() return replacement end)
	assert(count == 1, name .. " LocalPlayer binding changed")
	if mobileViewport then
		source=source:gsub('local UserInputService = game:GetService%("UserInputService"%)','local UserInputService = {TouchEnabled=true}')
		source=source:gsub('local viewport = root.AbsoluteSize',string.format('local viewport = Vector2.new(%d,%d)',mobileViewport.X,mobileViewport.Y))
	end
	local copy = Instance.new("ModuleScript")
	copy.Name, copy.Source = "ResourceUiQa" .. name, source
	local value = Instance.new("ObjectValue")
	value.Name, value.Value, value.Parent = "FixturePlayerGui", playerGui, copy
	copy.Parent = client
	table.insert(copies, copy)
	return require(copy)
end

local ok, failure = xpcall(function()
 local enemy=Instance.new('Model');enemy:SetAttribute('K0AttackDownUntil',14);enemy:SetAttribute('K0AttackDownMultiplier',.85);enemy:SetAttribute('K0DefenseBreakUntil',14)
 local enemyVisual=require(client.K0EnemyVisual)
 check(enemyVisual.statusText(enemy,10):find('ATK %-15%%')~=nil,'provoke attack reduction is visible')
 check(enemyVisual.statusText(enemy,10):find('DAMAGE TAKEN %+10%%')~=nil,'provoke vulnerability is accurate')
 check(enemyVisual.statusText(enemy,14)=='','debuff text disappears on expiry')
 enemy:Destroy()
 local atlasParent=Instance.new('Frame');atlasParent.Size=UDim2.fromOffset(700,500);atlasParent.Parent=playerGui
 local atlas=require(client.DeepwoodMapCanvas).create(atlasParent)
 local content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
 local progress=require(game:GetService('ReplicatedStorage').Shared.DeepwoodProgress)
 local journal=progress.new();local mapHero=Instance.new('Part');mapHero.CFrame=CFrame.new(Vector3.new(table.unpack(content.zones['DW-01'].center)))
 atlas.update({journal=journal},mapHero,mapHero.Position)
 check(atlas.pin.Visible and atlas.objective.Visible,'world map projects actual hero and objective')
 check(atlas.rows['DW-01'].status.Text=='UNEXPLORED' and atlas.rows['DW-02'].status.Text=='LOCKED','map distinguishes accessible unknown and story lock')
 journal=assert(progress.reveal(journal,'DW-01',6,6));atlas.update({journal=journal},mapHero,nil)
 check(atlas.rows['DW-01'].name.Text==content.zones['DW-01'].name and not atlas.objective.Visible,'visited region uses friendly name and stale target clears')
 check(atlas.rows['DW-01'].cells[66].BackgroundColor3~=atlas.rows['DW-01'].cells[1].BackgroundColor3,'discovery clears only nearby fog')
 atlas.update({journal=progress.new()},nil,nil)
 check(not atlas.pin.Visible and atlas.rows['DW-01'].status.Text=='UNEXPLORED','hero switch clears previous discovery and pin')
 for _,d in ipairs(atlasParent:GetDescendants()) do
  if d:IsA('TextLabel') then check(not d.Text:find('DW%-'),'development map IDs are absent from text') end
  check(not d:IsA('ViewportFrame') and not d:IsA('BasePart'),'full map never clones the 3D world')
 end
 atlasParent:Destroy();mapHero:Destroy()
	local hud = copyModule("K0Hud").create()
	local status = playerGui.DeepwoodTrainingHud.Root.Status
	local label, value, track = status.MANALabel, status.MANAValue, status.MANATrack
	check(not label.Visible and not value.Visible and not track.Visible, "empty hero has no mana bar")
	check(status.Size.Y.Offset == 100, "empty status panel fits one bar")
	for _, classId in ipairs({ "knight", "elf", "dwarf" }) do
		hud.setClass(classId)
		hud.setMana(nil, nil)
		check(not label.Visible and status.Size.Y.Offset == 100, classId .. " shows health only")
	end
	hud.setClass("mage")
	hud.setMana(85, 100)
	check(label.Visible and value.Visible and track.Visible, "mage mana bar is visible")
	check(value.Text == "85 / 100" and status.Size.Y.Offset == 145, "mana amount and panel size are correct")
	hud.setMana(0, 100)
	check(value.Text == "0 / 100" and label.Visible, "empty mana pool remains visible")
	hud.setMana(nil, nil)
	check(not label.Visible and status.Size.Y.Offset == 100, "changing heroes hides stale mana")
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
	check(playerGui.DeepwoodTopHud.Root.Minimap.MapActions.BackToLobby.Caption.Text ~= "", "return control keeps a readable caption")
	check(playerGui.DeepwoodTopHud.Root.Minimap.MapActions:FindFirstChild('Training')==nil,'training entry is absent from the adventure menu')
	check(root:FindFirstChild("BackToLobby")==nil and not playerGui.DeepwoodTopHud.Root.Minimap.MapActions.Visible,"top-right long return button moves into the collapsed map menu")
	hud.setHealth(45, 90)
	check(status.HEALTHValue.Text == "45 / 90" and status.HEALTHTrack.FillWindow.Fill.Size.X.Scale == .5, "HP value and TD fill follow current health")
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
 character:SetAttribute('K0StatPoints',4);character:SetAttribute('K0SkillPoints',1);hud.setCooldowns(character)
 check(status.GrowthPoints.Visible and status.GrowthPoints.Text:find('4 STAT POINTS',1,true) and status.GrowthPoints.Text:find('1 SKILL POINTS',1,true),'earned growth points are visible in combat HUD')
 character:SetAttribute('K0StatPoints',0);character:SetAttribute('K0SkillPoints',0);hud.setCooldowns(character)
 check(not status.GrowthPoints.Visible,'spent points do not leave a stale HUD notice')

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
	local mapRoot=Instance.new("Part");mapRoot.Name="HumanoidRootPart";mapRoot.Position=Vector3.new(18,3,36);mapRoot.CFrame=CFrame.new(mapRoot.Position);mapRoot.Parent=character
	task.wait(.12);hud.setCooldowns(character)
	local marker=playerGui.DeepwoodTopHud.Root.Minimap.PlayerMarker
	check(marker.Visible and math.abs(marker.Position.X.Scale-.6)<.001 and math.abs(marker.Position.Y.Scale-.7)<.001,"minimap projects the actual hero position north-up")
	check(playerGui.DeepwoodTopHud.Root.Minimap.MapPreview:IsA('Frame') and not playerGui.DeepwoodTopHud.Root.Minimap.MapActions.Visible,"2D map is visible while its menu stays collapsed")
 check(marker.Size.X.Offset==28 and marker.TextSize==24 and marker.ZIndex>3,"larger player arrow sits above enemy dots")
 local map=playerGui.DeepwoodTopHud.Root.Minimap
 check(map.WorldMap.Position.X.Offset<0 and map.WorldMap.Position.Y.Offset<=0,'full map button sits at minimap upper-left vertex')
 check(map.PlayerLabel.Visible and map.PlayerLabel.Text=="YOU" and map.PlayerPulse.Visible,"player has a readable YOU label and pulse")
 mapRoot.Position=Vector3.new(500,3,500);task.wait(.12);hud.setCooldowns(character)
 check(marker.Visible and marker:GetAttribute('AtMapEdge')==true,"player stays visible outside the local map on a bridge")
 local offset=Vector2.new(marker.Position.X.Scale-.5,marker.Position.Y.Scale-.5)
 check(math.abs(offset.Magnitude-.38)<.001,"edge marker remains inside the circular map")
 local human=Instance.new('Humanoid');human.Parent=character;human.Health=0;task.wait(.12);hud.setCooldowns(character)
 check(not marker.Visible and not map.PlayerLabel.Visible and not map.PlayerPulse.Visible,"dead hero has no stale position marker")
	character:Destroy()

	local lobby = copyModule("HeroLobbyGui").create(function() end)
	local panel = playerGui.HeroLobbyGui.Shade.HeroPanel.SkillManagement
	local slots = panel.SkillSlots
	check(string.find(panel.Instructions.Text, "level 20 advancement for slot 4", 1, true) ~= nil, "slot 4 requires the level 20 advancement")
	check(string.find(panel.Instructions.Text, "level 40 for slot 5", 1, true) ~= nil, "slot 5 requires the level 40 advancement")
	for _,resource in ipairs({"HEALTH","MANA"}) do
		local bar=status[resource.."Track"]
		check(bar.FillWindow.ClipsDescendants,"resource fill clips at the inner window")
		check(bar.Position.X.Offset>=14 and bar.Size.X.Offset<=-28,"resource frame stays inside horizontal panel rails")
		check(bar.Position.Y.Offset+bar.Size.Y.Offset<=status.Size.Y.Offset-16 or resource=="MANA" and not bar.Visible,"resource frame clears the lower rail")
		check(bar.TDResourceFrame.Position==UDim2.new() and bar.TDResourceFrame.Size==UDim2.fromScale(1,1),"resource artwork never extends beyond its track")
	end
 check(not root.Actions.Ultimate.Visible,'ultimate button hidden for an unqualified hero')
 character:SetAttribute('K0UltimateId',require(game.ReplicatedStorage.Shared.AdvancedSkills).branches.steel_knight.skills[13].id)
 hud.setCooldowns(character)
 check(root.Actions.Ultimate.Visible,'server-granted ultimate reveals the separate button')
 character:SetAttribute('K0UltimateId','')
 hud.setCooldowns(character)
 check(not root.Actions.Ultimate.Visible,'switching to an unqualified hero hides ultimate again')
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
	local statsView=require(client.HeroStatsView)
	local tree=require(client.HeroSkillTree)
	local growth=require(game:GetService("ReplicatedStorage").Shared.HeroProgression)
	local advanced=require(game:GetService("ReplicatedStorage").Shared.AdvancedSkills)
	local body=Instance.new("Frame");body.Size=UDim2.fromOffset(1160,700);body.Parent=playerGui
 for _,path in ipairs(advanced.order.knight) do
  for _,d in ipairs(advanced.branches[path].skills) do
   if d.root==3 then
    body:ClearAllChildren()
    local g=growth.new(80);g.branch=path;g.stage=4
    tree.render(body,{baseClassId="knight",progression=g},{ready=true,atHub=true},{path=path,selected=d.index},function() end,function() end,nil)
    local details=body.SkillDetails
    check(details.Effect.Text:find("15%%") and details.Effect.Text:find("10%%"),"descendant detail explains inherited debuffs")
    check(details.Effect.Position.Y.Offset+details.Effect.Size.Y.Offset<=details.Cost.Position.Y.Offset,"wrapped effect never overlaps cooldown cost")
    check(details.MasteryHint.Position.Y.Offset+details.MasteryHint.Size.Y.Offset<=details.Size.Y.Offset,"expanded details retain mastery hint")
   end
  end
 end

 body:ClearAllChildren()
 local fieldGrowth=growth.new(2);local fieldHero={heroId='field',baseClassId='knight',progression=fieldGrowth}
 local fieldSnapshot={ready=true,atHub=false,canInvest=true,items={}}
 statsView.render(body,fieldHero,fieldSnapshot,growth.derived('knight',fieldGrowth),{STR=0,DEX=0,INT=0,VIT=0},nil,function() end,function() end,function() end,function() end)
 check(body.StatAllocation.STR.Plus.Active,'safe field enables stat investment')
 body:ClearAllChildren();tree.render(body,fieldHero,fieldSnapshot,{path='steel_knight',selected=1},function() end,function() end,nil)
 check(body.SkillDetails.Train.Active,'safe field enables skill-point investment')
 check(body.CombatLoadout.Slot1.Active,'safe field permits loadout editing')
 for _,classId in ipairs({'knight','elf','dwarf','mage'}) do
  for _,case in ipairs({{4,30,false},{5,30,true},{10,31,true},{15,32,true}}) do
   body:ClearAllChildren()
   local hero={heroId='field',baseClassId=classId,progression=growth.new(case[1])}
   tree.render(body,hero,fieldSnapshot,{selected=case[2]},function() end,function() end,nil)
   check(body.CombatLoadout.Slot4.Active==case[3],classId..' slot4 follows level and selected common skill')
   body:ClearAllChildren()
   tree.render(body,hero,{ready=true,atHub=false,canInvest=false},{selected=case[2]},function() end,function() end,nil)
   check(not body.CombatLoadout.Slot4.Active,'unsafe field disables loadout')
  end
 end
	for _,classId in ipairs({"knight","elf","dwarf","mage"}) do
		for _,path in ipairs(advanced.order[classId]) do
			for _,level in ipairs({1,80}) do
				body:ClearAllChildren()
				local g=growth.new(level)
				if level==80 then g.branch=path;g.stage=4 end
				local h={baseClassId=classId,progression=g}
				local height=tree.render(body,h,{ready=true,atHub=true},{path=path,selected=1},function() end,function() end,nil)
				local count=0
				for _,node in ipairs(body.SkillMap:GetChildren()) do if node:GetAttribute("SkillIndex") then count+=1 end end
				check(count==19,classId.." selected branch has exactly nineteen actual skill nodes")
				check(body:FindFirstChild("SkillDetails") and body:FindFirstChild("CombatLoadout"),"tree keeps detail and loadout controls")
				check(height>500,"tree reports scrollable content height")
				check(body.SkillMap.Skill1:FindFirstChild("SkillGlyph")~=nil,"basic skill uses a distinct native action symbol")
				check(body.CombatLoadout.Slot4.Active==(level>=5),"loadout slot eligibility follows level")
			end
		end
		body:ClearAllChildren()
		local g=growth.new(2)
		local h={heroId="test",baseClassId=classId,progression=g}
		local draft={STR=0,DEX=0,INT=0,VIT=0}
		local height=statsView.render(body,h,{ready=true,atHub=true,items={}},growth.derived(classId,g),draft,nil,function() end,function() end,function() end,function() end)
		local slots=0;for _,v in ipairs(body.HeroEquipment:GetChildren()) do if v.Name:match("^EquipSlot_") then slots+=1 end end
		check(slots==8,"stats view contains eight actual equipment slots")
		check(body.StatAllocation.STR.Plus.Active,"level two has investable stat points")
		check(not body.StatAllocation.ApplyPoints.Active,"empty draft cannot be confirmed")
		check(height>500,"stats view reports scrollable content")
	end
	body:Destroy()
	local inactiveTouch=Instance.new('ScreenGui');inactiveTouch.Name='InactiveTouch';inactiveTouch.Enabled=false;inactiveTouch.Parent=playerGui
	local staleJump=Instance.new('TextButton');staleJump.Name='JumpButton';staleJump.Size=UDim2.fromOffset(80,80);staleJump.Position=UDim2.fromOffset(20,10);staleJump.Parent=inactiveTouch
	for _,size in ipairs({Vector2.new(1050,506),Vector2.new(844,390),Vector2.new(740,360),Vector2.new(568,320),Vector2.new(390,844)}) do
		copyModule('K0Hud',size).create()
		local mobile=playerGui.DeepwoodTrainingHud.Root
		local actions,bar=mobile.Actions,mobile.SkillBar
		check(bar.Position.Y.Scale==1 and bar.Position.Y.Offset==-12,'mobile items and skills stay at the bottom')
		check(actions.Attack.Size==UDim2.fromOffset(64,64),'mobile attack is reduced to64px')
		check(actions.Block.Size==actions.Dodge.Size and actions.Dodge.Size==actions.Sprint.Size,'mobile defensive actions have equal size')
		check(actions.Block.Position.X.Offset==actions.Dodge.Position.X.Offset and actions.Dodge.Position.X.Offset==actions.Sprint.Position.X.Offset,'mobile defensive actions form one column')
		check(actions.Sprint.Position.Y.Offset<actions.Block.Position.Y.Offset and actions.Block.Position.Y.Offset<actions.Dodge.Position.Y.Offset,'mobile order is Sprint Block Dodge')
		check(actions.Position.Y==UDim.new(1,0),'mobile defensive column reaches the safe bottom edge')
		check(actions.Attack.Position==UDim2.fromOffset(90,0),'hidden jump UI cannot lift attack away from the right side of Sprint')
		local scale=actions.UIScale.Scale
		local attackBottom=size.Y+actions.Position.Y.Offset-actions.Size.Y.Offset*scale+(actions.Attack.Position.Y.Offset+64)*scale
		check(attackBottom<size.Y-88,'mobile attack clears the default jump height')
		check(bar.Size.X.Offset*bar.UIScale.Scale<=(size.X<600 and size.X-40 or size.X-280)+.1,'bottom row fits the available width')
	end

end, debug.traceback)
if not ok then table.insert(report.failures, tostring(failure)) end
for _, module in ipairs(copies) do module:Destroy() end
fixture:Destroy()
report.pass = ok
print("K0_RESOURCE_UI_NATIVE " .. HttpService:JSONEncode(report))
assert(ok, "Resource UI fixture failed; see K0_RESOURCE_UI_NATIVE")
