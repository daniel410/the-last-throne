-- TD silver/gold hero window. All investments are confirmed by the account server.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CAS=game:GetService("ContextActionService")
local Http=game:GetService("HttpService")
local Theme=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.InventoryChrome)
local Advanced=require(RS.Shared.AdvancedSkills)
local Growth=require(RS.Shared.HeroProgression)
local Config=require(RS.Shared.K0Config)
local Gui={}
local portraits={knight="103255177842108",elf="80894238854345",dwarf="74628903359757",mage="91907986271282"}
local names={knight="KNIGHT",elf="ELF ARCHER",dwarf="DWARF AXE THROWER",mage="MAGE"}
local errors={SkillLocked="Complete the required advancement and reach the skill level first.",InvalidAdvancement="This advancement is unavailable. Review your current path.",LevelRequired="Reach the required hero level before advancing.",TrialRequired="Defeat more training foes to complete this advancement trial.",Busy="A save is in progress. Try again shortly.",Changed="Your hero changed. Review the refreshed values and try again.",WaitForLobby="Return to Dawnspire to invest points or change skills.",NotEnoughStatPoints="Not enough stat points. Clear your draft and try again.",NotEnoughSkillPoints="Earn another level to gain a skill point.",SkillMaxRank="This basic skill has reached level 4.",SaveUnknown="Save confirmation is pending. Press RETRY SAVE to check the same request.",AccountBusy="This account is active elsewhere. Rejoin to load safely.",Unavailable="Hero data is unavailable. Rejoin to load safely.",InvalidRequest="This change was rejected. Refresh your hero and try again.",Incompatible="Hero data could not be loaded safely. Rejoin and try again."}
function Gui.create(onVisibility)
	local player=Players.LocalPlayer
	local gui=Instance.new("ScreenGui"); gui.Name="HeroGrowthGui"; gui.ResetOnSpawn=false; gui.DisplayOrder=55; gui.Parent=player:WaitForChild("PlayerGui")
	local launch=Theme.button(gui,"OpenHero","HERO [H]",UDim2.new(1,-278,0,16),UDim2.fromOffset(128,40))
	local overlay=Instance.new("Frame"); overlay.Name="Overlay"; overlay.Size=UDim2.fromScale(1,1); overlay.BackgroundColor3=Color3.new(0,0,0); overlay.BackgroundTransparency=.25; overlay.Visible=false; overlay.Active=true; overlay.Parent=gui
	local panel=Chrome.frame(overlay,"InventoryPanel",UDim2.fromScale(.5,.5),UDim2.new(1,-24,1,-40)); panel.AnchorPoint=Vector2.new(.5,.5)
	local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(940,600); limit.Parent=panel
	Theme.label(panel,"Title","HERO",UDim2.fromOffset(20,10),UDim2.new(1,-120,0,32),22,Theme.color.gold)
	local close=Theme.button(panel,"Close","X",UDim2.new(1,-62,0,10),UDim2.fromOffset(44,34))
	local statsTab=Theme.button(panel,"StatsTab","STATS",UDim2.fromOffset(18,54),UDim2.new(1/3,-16,0,38))
	local skillsTab=Theme.button(panel,"SkillsTab","SKILLS",UDim2.new(1/3,6,0,54),UDim2.new(1/3,-16,0,38))
	local advanceTab=Theme.button(panel,"AdvanceTab","ADVANCE",UDim2.new(2/3,-6,0,54),UDim2.new(1/3,-12,0,38))
	local body=Instance.new("ScrollingFrame"); body.Name="Content"; body.Position=UDim2.fromOffset(18,104); body.Size=UDim2.new(1,-36,1,-166); body.BackgroundTransparency=1; body.BorderSizePixel=0; body.ScrollBarThickness=5; body.Parent=panel
	local message=Theme.label(panel,"Message","",UDim2.new(0,18,1,-54),UDim2.new(1,-36,0,42),12,Theme.color.muted)
	local remotes=RS:WaitForChild("Remotes")
	local remote=remotes:WaitForChild("HeroProgressionRequest")
	local inventoryRemote=remotes:WaitForChild("InventoryRequest")
	local snapshot,pending
	local tab="Stats"
	local skillView=0
	local selectedEquip
	local selectedBranch
	local draft={STR=0,DEX=0,INT=0,VIT=0}
	local opened=false
	local render
	local function getState() inventoryRemote:FireServer({action="GetState",requestId=Http:GenerateGUID(false)}) end
	local function show(text) message.Text=text end
	local function resetDraft() draft={STR=0,DEX=0,INT=0,VIT=0} end
	local function send(action,args)
		if pending or not snapshot or not snapshot.ready or not snapshot.heroId then return end
		local cmd={action=action,heroId=snapshot.heroId,revision=snapshot.revision,requestId=Http:GenerateGUID(false)}
		for k,v in pairs(args or {}) do cmd[k]=v end
		pending=cmd; remote:FireServer(cmd); show("Saving hero..."); render()
		task.delay(10,function() if pending==cmd then show(errors.SaveUnknown); render() end end)
	end
	local function visible(value)
		opened=value; overlay.Visible=value; player:SetAttribute("TLTProgressionOpen",value)
		if onVisibility then onVisibility(value) end
		if value then
			CAS:BindActionAtPriority("HeroGrowthMovement",function() return Enum.ContextActionResult.Sink end,false,4000,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.Thumbstick1)
			getState(); render()
		else CAS:UnbindAction("HeroGrowthMovement") end
	end
	local function label(parent,name,text,y,height,size,color)
		return Theme.label(parent,name,text,UDim2.fromOffset(12,y),UDim2.new(1,-24,0,height),size or 14,color)
	end
	render=function()
		for _,child in ipairs(body:GetChildren()) do child:Destroy() end
		local hero=snapshot and snapshot.heroes[snapshot.heroId]
		local g=hero and hero.progression
		if not g then label(body,"Loading","Select a hero in Dawnspire to view growth.",12,70); body.CanvasSize=UDim2.fromOffset(0,100); return end
		local classId=hero.baseClassId
		if selectedEquip and not Advanced.unlocked(g,classId,selectedEquip) then selectedEquip=nil end
		local preview=Growth.copy(g)
		local spent=0; for k,v in pairs(draft) do preview.stats[k]=preview.stats[k]+v; spent=spent+v end
		local statPoints,skillPoints=Growth.points(g)
		local derived=Growth.derived(classId,preview)
		local equipment=snapshot.stats or {health=0,power=0,armor=0}
		derived.health=derived.health+(equipment.health or 0)
		derived.armor=derived.armor+(equipment.armor or 0)
		derived.physicalPower=math.floor(derived.physicalPower*(1+(equipment.power or 0)/100)+.5)
		derived.magicPower=math.floor(derived.magicPower*(1+(equipment.power or 0)/100)+.5)
		local narrow=body.AbsoluteSize.X<620
		local portraitWidth=narrow and 110 or math.floor(body.AbsoluteSize.X*.37)
		local portraitHeight=narrow and 156 or 368
		local portraitFrame=Chrome.frame(body,"HeroPortrait",UDim2.fromOffset(0,0),UDim2.fromOffset(portraitWidth,portraitHeight))
		local image=Instance.new("ImageLabel"); image.Name="TDHero"; image.BackgroundTransparency=1; image.Size=UDim2.new(1,-12,1,narrow and -42 or -76); image.Position=UDim2.fromOffset(6,4); image.Image="rbxassetid://"..portraits[classId]; image.ScaleType=Enum.ScaleType.Fit; image.Parent=portraitFrame
		label(portraitFrame,"Level","LEVEL "..g.level,portraitHeight-(narrow and 36 or 68),28,18,Theme.color.gold)
		if not narrow then label(portraitFrame,"Resources",string.format("HP %d   MP %d",derived.health,derived.mana),portraitHeight-36,28,14) end
		local info=Theme.label(body,"HeroName",names[classId],UDim2.fromOffset(narrow and 122 or 0,narrow and 2 or 376),UDim2.fromOffset(narrow and math.max(130,body.AbsoluteSize.X-132) or portraitWidth,32),narrow and 16 or 20,Theme.color.gold)
		local xp=g.level==80 and "MAX LEVEL" or string.format("XP  %d / %d",g.xp,Growth.xpToNext(g.level))
		Theme.label(body,"XP",xp,UDim2.fromOffset(narrow and 122 or 0,narrow and 42 or 414),UDim2.fromOffset(narrow and math.max(130,body.AbsoluteSize.X-132) or portraitWidth,24),13,Theme.color.green)
		local resources=Theme.label(body,"Resources",string.format("HP %d   MP %d",derived.health,derived.mana),UDim2.fromOffset(narrow and 122 or 0,narrow and 72 or 446),UDim2.fromOffset(narrow and math.max(130,body.AbsoluteSize.X-132) or portraitWidth,42),14)
		resources.Visible=narrow
		local content=Instance.new("Frame"); content.Name="Growth"; content.BackgroundTransparency=1; content.Position=UDim2.fromOffset(narrow and 0 or portraitWidth+18,narrow and 172 or 0); content.Size=UDim2.new(1,narrow and -4 or -portraitWidth-22,0,700); content.Parent=body
		local editable=snapshot.ready and snapshot.atHub and not pending
		if tab=="Stats" then
			label(content,"Points","AVAILABLE STAT POINTS   "..(statPoints-spent),0,30,16,Theme.color.gold)
			label(content,"Budget","+4 per level  /  Base + invested + draft",30,24,11,Theme.color.muted)
			for index,key in ipairs(Growth.statKeys) do
				local y=62+(index-1)*58
				local row=Chrome.frame(content,key,UDim2.fromOffset(0,y),UDim2.new(1,0,0,52))
				label(row,"Value",string.format("%s   %d  (%d + %d + %d)",key,derived.totalStats[key],Growth.bases[classId].stats[key],g.stats[key],draft[key]),0,50,14)
				local minus=Theme.button(row,"Minus","-",UDim2.new(1,-92,0,8),UDim2.fromOffset(38,36))
				local plus=Theme.button(row,"Plus","+",UDim2.new(1,-48,0,8),UDim2.fromOffset(38,36))
				row.Value.Size=UDim2.new(1,-110,1,0)
				Theme.enabled(minus,editable and draft[key]>0); Theme.enabled(plus,editable and statPoints>spent)
				minus.Activated:Connect(function() if editable and draft[key]>0 then draft[key]=draft[key]-1; render() end end)
				plus.Activated:Connect(function() if editable and statPoints>spent then draft[key]=draft[key]+1; render() end end)
			end
			label(content,"Derived",string.format("POWER %d   MAGIC %d   ARMOR %d",derived.physicalPower,derived.magicPower,derived.armor),302,38,13,Theme.color.silver)
			label(content,"Effects","STR: melee power  /  DEX: bow power\nINT: magic power & Mage MP  /  VIT: HP & armor",342,44,11,Theme.color.muted)
			local cancel=Theme.button(content,"CancelDraft","CANCEL DRAFT",UDim2.fromOffset(0,398),UDim2.new(.5,-5,0,42))
			local apply=Theme.button(content,"ApplyPoints","APPLY POINTS",UDim2.new(.5,5,0,398),UDim2.new(.5,-5,0,42),true)
			Theme.enabled(apply,editable and spent>0)
			cancel.Activated:Connect(function() resetDraft(); render() end)
			apply.Activated:Connect(function() if editable and spent>0 then send("AllocateStats",{stats=Growth.copy(draft)}) end end)
			label(content,"CommitNote","Applied points are permanent. Cancel only clears this draft.",448,40,11,Theme.color.muted)
		elseif tab=="Advance" then
			selectedBranch=g.branch~="" and g.branch or selectedBranch
			if not selectedBranch or Advanced.branches[selectedBranch].classId~=classId then selectedBranch=Advanced.order[classId][1] end
			label(content,"PathHeading","CLASS ADVANCEMENT",0,30,16,Theme.color.gold)
			for i,id in ipairs(Advanced.order[classId]) do
				local data=Advanced.branches[id]
				local button=Theme.button(content,"Path"..i,data.name..(id==selectedBranch and "  *" or ""),UDim2.new((i-1)/2,(i-1)*5,0,42),UDim2.new(.5,-5,0,48),id==selectedBranch)
				Theme.enabled(button,g.stage==0 and not pending)
				button.Activated:Connect(function() if g.stage==0 then selectedBranch=id;render() end end)
			end
			label(content,"Identity","Base class stays permanent. Path selection is saved.\nPath names and combat balance are provisional.",100,52,12,Theme.color.muted)
			local nextStage=g.stage+1
			for stage=1,4 do
				local y=164+(stage-1)*78
				local row=Chrome.frame(content,"Stage"..stage,UDim2.fromOffset(0,y),UDim2.new(1,0,0,70))
				label(row,"Title",string.format("LEVEL %d  /  STAGE %d  %s",stage*20,stage,stage<=g.stage and "COMPLETE" or "LOCKED"),0,30,14,stage<=g.stage and Theme.color.green or Theme.color.gold)
				label(row,"Trial",string.format("Training trial: %d / %d foes defeated",math.min(g.battleWins,stage*3),stage*3),32,30,12,Theme.color.muted)
			end
			if nextStage<=4 then
				local ready=editable and g.level>=nextStage*20 and g.battleWins>=nextStage*3
				local button=Theme.button(content,"CompleteAdvancement","COMPLETE STAGE "..nextStage,UDim2.fromOffset(0,490),UDim2.new(1,0,0,44),true)
				Theme.enabled(button,ready)
				button.Activated:Connect(function() if ready then send("Advance",{branch=selectedBranch,stage=nextStage}) end end)
			end
			label(content,"AdvancementNote","Complete each trial in Dawnspire. Reaching a level alone does not advance your hero. Stage 1 opens slot 4; stage 2 opens slot 5.\nNew path skills are learned at their listed levels after the matching stage is complete.",546,102,12,Theme.color.muted)
			content:SetAttribute("ContentHeight",660)
		else
			label(content,"Points","SKILL POINTS   "..skillPoints.."  /  +1 PER LEVEL",0,30,15,Theme.color.gold)
			for view=0,4 do
				local button=Theme.button(content,"Filter"..view,view==0 and "BASIC" or tostring(view*20),UDim2.new(view/5,0,0,36),UDim2.new(.2,-4,0,34),skillView==view)
				button.Activated:Connect(function() skillView=view;render() end)
			end
			local path=g.branch~="" and g.branch or selectedBranch or Advanced.order[classId][1]
			if not Advanced.branches[path] or Advanced.branches[path].classId~=classId then path=Advanced.order[classId][1] end
			local shown={}
			for index,base in ipairs(Config.Skills[classId]) do
				if (skillView==0 and index<=3) or base.branch==path and base.stage==skillView then table.insert(shown,index) end
			end
			for order,index in ipairs(shown) do
				local base=Config.Skills[classId][index]
				local skill=Growth.skill(classId,index,base,g)
				local learned=Advanced.unlocked(g,classId,index)
				local y=84+(order-1)*164
				local row=Chrome.frame(content,"Skill"..index,UDim2.fromOffset(0,y),UDim2.new(1,0,0,156))
				Theme.icon(row,skill.icon or ({knight="shieldbearer",elf="archer",dwarf="axe",mage="arcanist"})[classId],UDim2.fromOffset(8,6),UDim2.fromOffset(40,40))
				local title=label(row,"Name",base.name.."  Lv."..(1+g.mastery[index]),4,36,13,learned and Theme.color.gold or Theme.color.muted);title.Position=UDim2.fromOffset(52,4);title.Size=UDim2.new(1,-58,0,36)
				local effect=skill.damage>0 and string.format("Damage x%.2f",skill.damage) or string.format("Provoke %.1fs",skill.provokeDuration)
				if skill.pulses and skill.pulses>1 then effect=effect.." x "..skill.pulses.." hits" end
				label(row,"Effect",effect,48,22,12)
				label(row,"Cost",string.format("%gs CD%s  /  %s",skill.cooldown,skill.manaCost and " / "..skill.manaCost.." MP" or "",skill.form or "basic"),72,22,11,Theme.color.muted)
				local nextEffect=string.format("Next: +%d%% base damage",index<=3 and (Growth.mastery[classId][index] or 0)*100 or 4)
				if classId=="knight" and index==3 then nextEffect="Next: +0.2s provoke"
				elseif classId=="mage" and index==3 then nextEffect="Next: +3% damage / +0.2s slow" end
				local reason=learned and (g.mastery[index]<3 and nextEffect or "MAX MASTERY") or string.format("LOCKED: Level %d / Stage %d",base.level or 1,base.stage or 0)
				local note=label(row,"Requirement",reason,92,18,10,Theme.color.muted)
				local equip=Theme.button(row,"Equip","EQUIP",UDim2.fromOffset(8,114),UDim2.fromOffset(100,32))
				Theme.enabled(equip,editable and learned)
				equip.Activated:Connect(function()
					if editable and learned then selectedEquip=index;render();body.CanvasPosition=Vector2.new(0,(narrow and 172 or 0)+84+#shown*164+8) end
				end)
				local train=Theme.button(row,"Train","+1 LV / 1 SP",UDim2.new(1,-142,1,-38),UDim2.fromOffset(134,32),true)
				Theme.enabled(train,editable and learned and skillPoints>0 and g.mastery[index]<3)
				train.Activated:Connect(function() if editable and learned then send("TrainSkill",{skill=index}) end end)
			end
			local y=84+#shown*164+8
			label(content,"LoadoutTitle",selectedEquip and ("EQUIP: "..Config.Skills[classId][selectedEquip].name) or "COMBAT LOADOUT / Tap a slot to cycle",y,28,13,Theme.color.gold)
			local unlocked={0};for index=1,29 do if Advanced.unlocked(g,classId,index) then table.insert(unlocked,index) end end
			for slot=1,5 do
				local index=g.skillSlots[slot];local skill=Config.Skills[classId][index]
				local active=slot<=Advanced.slotCount(g)
				local button=Theme.button(content,"Slot"..slot,slot.."  "..(active and (skill and skill.name or "EMPTY") or "LOCKED - ADVANCE"),UDim2.fromOffset(0,y+34+(slot-1)*42),UDim2.new(1,0,0,36))
				Theme.enabled(button,editable and active)
				button.Activated:Connect(function()
					if not editable or not active then return end
					local position=1;for i,v in ipairs(unlocked) do if v==index then position=i;break end end
					send("SetSkillSlot",{slot=slot,skill=selectedEquip or unlocked[position%#unlocked+1]})
				end)
			end
			label(content,"PathNote","Path: "..Advanced.branches[path].name.." (provisional)\nSkills are learned free; mastery uses separate SP.\nUltimate: Level 80 and stage 4. Uses a combat slot in this trial.",y+252,78,11,Theme.color.muted)
			content:SetAttribute("ContentHeight",y+342)
		end
		if pending then
			local retry=Theme.button(content,"RetrySave","RETRY SAVE",UDim2.fromOffset(0,tab=="Stats" and 500 or content:GetAttribute("ContentHeight") or 710),UDim2.new(1,0,0,38))
			retry.Activated:Connect(function() if pending then remote:FireServer(pending); show("Checking the same save...") end end)
		end
		body.CanvasSize=UDim2.fromOffset(0,(narrow and 172 or 0)+(tab=="Stats" and (pending and 550 or 496) or (content:GetAttribute("ContentHeight") or 706)+(pending and 50 or 0)))
		if not snapshot.atHub and not pending then show("Return to Dawnspire to invest points or change skills.") end
	end
	advanceTab.Activated:Connect(function() tab="Advance";body.CanvasPosition=Vector2.zero;render() end)
	statsTab.Activated:Connect(function() tab="Stats";body.CanvasPosition=Vector2.zero; render() end)
	skillsTab.Activated:Connect(function() tab="Skills";body.CanvasPosition=Vector2.zero; render() end)
	launch.Activated:Connect(function() visible(not opened) end)
	close.Activated:Connect(function() visible(false) end)
	body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if opened then render() end end)
	CAS:BindAction("HeroGrowthToggle",function(_,state)
		if state==Enum.UserInputState.Begin and not game:GetService("UserInputService"):GetFocusedTextBox() then visible(not opened) end
		return Enum.ContextActionResult.Sink
	end,false,Enum.KeyCode.H)
	remotes:WaitForChild("InventoryState").OnClientEvent:Connect(function(value,requestId,reason)
		if type(value)~="table" or type(value.heroes)~="table" or snapshot and value.revision<snapshot.revision then return end
		local changed=not snapshot or snapshot.revision~=value.revision or snapshot.heroId~=value.heroId
		snapshot=value
		if pending and requestId==pending.requestId then
			if reason~="SaveUnknown" and reason~="Busy" then pending=nil end
			show(reason and (errors[reason] or "Change rejected. Refresh your hero and try again.") or "Hero saved.")
		end
		if changed then resetDraft() end
		if opened then render() end
	end)
	remotes:WaitForChild("K0HeroState").OnClientEvent:Connect(function() if opened then getState() end end)
	return {open=function(which) tab=which or "Stats"; visible(true) end,close=function() visible(false) end,isOpen=function() return opened end}
end
return Gui
