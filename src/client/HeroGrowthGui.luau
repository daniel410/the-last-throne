-- TD silver/gold hero window. All investments are confirmed by the account server.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CAS=game:GetService("ContextActionService")
local Http=game:GetService("HttpService")
local Theme=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.InventoryChrome)
local Growth=require(RS.Shared.HeroProgression)
local Config=require(RS.Shared.K0Config)
local Gui={}
local portraits={knight="103255177842108",elf="80894238854345",dwarf="74628903359757",mage="91907986271282"}
local names={knight="KNIGHT",elf="ELF ARCHER",dwarf="DWARF AXE THROWER",mage="MAGE"}
local errors={Busy="A save is in progress. Try again shortly.",Changed="Your hero changed. Review the refreshed values and try again.",WaitForLobby="Return to Dawnspire to invest points or change skills.",NotEnoughStatPoints="Not enough stat points. Clear your draft and try again.",NotEnoughSkillPoints="Earn another level to gain a skill point.",SkillMaxRank="This basic skill has reached level 4.",SaveUnknown="Save confirmation is pending. Press RETRY SAVE to check the same request.",AccountBusy="This account is active elsewhere. Rejoin to load safely.",Unavailable="Hero data is unavailable. Rejoin to load safely.",InvalidRequest="This change was rejected. Refresh your hero and try again.",Incompatible="Hero data could not be loaded safely. Rejoin and try again."}
function Gui.create(onVisibility)
	local player=Players.LocalPlayer
	local gui=Instance.new("ScreenGui"); gui.Name="HeroGrowthGui"; gui.ResetOnSpawn=false; gui.DisplayOrder=55; gui.Parent=player:WaitForChild("PlayerGui")
	local launch=Theme.button(gui,"OpenHero","HERO [H]",UDim2.new(1,-278,0,16),UDim2.fromOffset(128,40))
	local overlay=Instance.new("Frame"); overlay.Name="Overlay"; overlay.Size=UDim2.fromScale(1,1); overlay.BackgroundColor3=Color3.new(0,0,0); overlay.BackgroundTransparency=.25; overlay.Visible=false; overlay.Parent=gui
	local panel=Chrome.frame(overlay,"InventoryPanel",UDim2.fromScale(.5,.5),UDim2.new(1,-24,1,-40)); panel.AnchorPoint=Vector2.new(.5,.5)
	local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(940,600); limit.Parent=panel
	Theme.label(panel,"Title","HERO",UDim2.fromOffset(20,10),UDim2.new(1,-120,0,32),22,Theme.color.gold)
	local close=Theme.button(panel,"Close","X",UDim2.new(1,-62,0,10),UDim2.fromOffset(44,34))
	local statsTab=Theme.button(panel,"StatsTab","STATS",UDim2.fromOffset(18,54),UDim2.new(.5,-24,0,38))
	local skillsTab=Theme.button(panel,"SkillsTab","SKILLS",UDim2.new(.5,6,0,54),UDim2.new(.5,-24,0,38))
	local body=Instance.new("ScrollingFrame"); body.Name="Content"; body.Position=UDim2.fromOffset(18,104); body.Size=UDim2.new(1,-36,1,-166); body.BackgroundTransparency=1; body.BorderSizePixel=0; body.ScrollBarThickness=5; body.Parent=panel
	local message=Theme.label(panel,"Message","",UDim2.new(0,18,1,-54),UDim2.new(1,-36,0,42),12,Theme.color.muted)
	local remotes=RS:WaitForChild("Remotes")
	local remote=remotes:WaitForChild("HeroProgressionRequest")
	local inventoryRemote=remotes:WaitForChild("InventoryRequest")
	local snapshot,pending
	local tab="Stats"
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
		if value then getState(); render() end
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
		local image=Instance.new("ImageLabel"); image.Name="TDHero"; image.BackgroundTransparency=1; image.Size=UDim2.new(1,-12,1,-42); image.Position=UDim2.fromOffset(6,4); image.Image="rbxassetid://"..portraits[classId]; image.ScaleType=Enum.ScaleType.Fit; image.Parent=portraitFrame
		label(portraitFrame,"Level","LEVEL "..g.level,portraitHeight-36,28,18,Theme.color.gold)
		local info=Theme.label(body,"HeroName",names[classId],UDim2.fromOffset(narrow and 122 or 0,narrow and 2 or 376),UDim2.fromOffset(narrow and math.max(130,body.AbsoluteSize.X-132) or portraitWidth,32),narrow and 16 or 20,Theme.color.gold)
		local xp=g.level==80 and "MAX LEVEL" or string.format("XP  %d / %d",g.xp,Growth.xpToNext(g.level))
		Theme.label(body,"XP",xp,UDim2.fromOffset(narrow and 122 or 0,narrow and 42 or 414),UDim2.fromOffset(narrow and math.max(130,body.AbsoluteSize.X-132) or portraitWidth,24),13,Theme.color.green)
		Theme.label(body,"Resources",string.format("HP %d   MP %d",derived.health,derived.mana),UDim2.fromOffset(narrow and 122 or 0,narrow and 72 or 446),UDim2.fromOffset(narrow and math.max(130,body.AbsoluteSize.X-132) or portraitWidth,42),14)
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
		else
			label(content,"Points","AVAILABLE SKILL POINTS   "..skillPoints,0,30,16,Theme.color.gold)
			label(content,"Budget","+1 per level  /  Basic skill mastery: 3 ranks",30,24,11,Theme.color.muted)
			for index,base in ipairs(Config.Skills[classId]) do
				local skill=Growth.skill(classId,index,base,g)
				local y=62+(index-1)*128
				local row=Chrome.frame(content,"Skill"..index,UDim2.fromOffset(0,y),UDim2.new(1,0,0,120))
				Chrome.diamond(row,"Node",UDim2.fromOffset(24,25),18,Theme.color.gold)
				local title=label(row,"Name",base.name.."  Lv."..(1+g.mastery[index]),4,36,14,Theme.color.gold); title.Position=UDim2.fromOffset(44,4); title.Size=UDim2.new(1,-50,0,36)
				local effect=skill.damage>0 and string.format("Damage x%.2f",skill.damage) or string.format("Provoke %.1fs",skill.provokeDuration)
				if skill.slowDuration then effect=effect..string.format(" / Slow %.1fs",skill.slowDuration) end
				label(row,"Effect",effect,40,24,12)
				label(row,"Cost",string.format("%gs cooldown%s",skill.cooldown,skill.manaCost and " / "..skill.manaCost.." MP" or ""),66,24,11,Theme.color.muted)
				local train=Theme.button(row,"Train","+1 LV / 1 SP",UDim2.new(1,-142,1,-38),UDim2.fromOffset(134,32),true)
				Theme.enabled(train,editable and skillPoints>0 and g.mastery[index]<3)
				train.Activated:Connect(function() if editable then send("TrainSkill",{skill=index}) end end)
			end
			label(content,"LoadoutTitle","COMBAT LOADOUT  /  Tap a slot to cycle",454,28,13,Theme.color.gold)
			for slot=1,3 do
				local index=g.skillSlots[slot]; local skill=Config.Skills[classId][index]
				local button=Theme.button(content,"Slot"..slot,slot.."  "..(skill and skill.name or "EMPTY"),UDim2.fromOffset(0,490+(slot-1)*42),UDim2.new(1,0,0,36))
				Theme.enabled(button,editable)
				button.Activated:Connect(function() if editable then send("SetSkillSlot",{slot=slot,skill=(index+1)%4}) end end)
			end
			label(content,"Advancement","SLOTS 4 / 5 LOCKED\nRequires Level 20 / 40 and completed advancement.\nAdvancement paths and ultimate skills are in development.",622,74,11,Theme.color.muted)
		end
		if pending then
			local retry=Theme.button(content,"RetrySave","RETRY SAVE",UDim2.fromOffset(0,tab=="Stats" and 500 or 710),UDim2.new(1,0,0,38))
			retry.Activated:Connect(function() if pending then remote:FireServer(pending); show("Checking the same save...") end end)
		end
		body.CanvasSize=UDim2.fromOffset(0,(narrow and 172 or 0)+(tab=="Stats" and (pending and 550 or 496) or (pending and 760 or 706)))
		if not snapshot.atHub and not pending then show("Return to Dawnspire to invest points or change skills.") end
	end
	statsTab.Activated:Connect(function() tab="Stats"; render() end)
	skillsTab.Activated:Connect(function() tab="Skills"; render() end)
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
