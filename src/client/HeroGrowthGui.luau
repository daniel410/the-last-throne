-- TD silver/gold hero window. All investments are confirmed by the account server.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CAS=game:GetService("ContextActionService")
local Http=game:GetService("HttpService")
local Theme=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.InventoryChrome)
local Menu=require(script.Parent.HeroMenuChrome)
local SkillTree=require(script.Parent.HeroSkillTree)
local StatsView=require(script.Parent.HeroStatsView)
local Advanced=require(RS.Shared.AdvancedSkills)
local Growth=require(RS.Shared.HeroProgression)
local Config=require(RS.Shared.K0Config)
local SkillPreview=require(RS.Shared.SkillStatPreview)
local Navigation=require(RS.Shared.NavigationText)
local Gui={}
local portraits={knight="103255177842108",elf="80894238854345",dwarf="74628903359757",mage="91907986271282"}
local names={knight="KNIGHT",elf="ELF ARCHER",dwarf="DWARF AXE THROWER",mage="MAGE"}
local errors={UnsafeGrowth="Move away from enemies and wait five seconds after combat to invest points or change skills.",SkillLocked="Reach the required level and complete any listed advancement first.",UltimateSeparate="Your ultimate uses its own button. Choose a regular skill for slots 1–5.",InvalidAdvancement="This advancement is unavailable. Review your current path.",LevelRequired="Reach the required hero level before advancing.",TrialRequired="Defeat more training foes to complete this advancement trial.",Busy="A save is in progress. Try again shortly.",Changed="Your hero changed. Review the refreshed values and try again.",WaitForLobby="Return to Hub and select your hero before trying this action.",NotEnoughStatPoints="Not enough stat points. Clear your draft and try again.",NotEnoughSkillPoints="Earn another level to gain a skill point.",SkillMaxRank="This basic skill has reached level 4.",SaveUnknown="Save confirmation is pending. Press RETRY SAVE to check the same request.",AccountBusy="This account is active elsewhere. Rejoin to load safely.",Unavailable="Hero data is unavailable. Rejoin to load safely.",InvalidRequest="This change was rejected. Refresh your hero and try again.",Incompatible="Hero data could not be loaded safely. Rejoin and try again."}
function Gui.create(onVisibility)
	local player=Players.LocalPlayer
	local gui=Instance.new("ScreenGui"); gui.Name="HeroGrowthGui"; gui.ResetOnSpawn=false; gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.DisplayOrder=55; gui.Parent=player:WaitForChild("PlayerGui")
	local launch=Theme.button(gui,"OpenHero",Navigation.statsButton,UDim2.new(1,-278,0,0),UDim2.fromOffset(128,44))
	require(script.Parent.TopMenuLayout).bind(gui,launch,2)
	local overlay=Instance.new("Frame"); overlay.Name="Overlay"; overlay.Size=UDim2.fromScale(1,1); overlay.BackgroundColor3=Color3.new(0,0,0); overlay.BackgroundTransparency=.25; overlay.Visible=false; overlay.Active=true; overlay.Parent=gui
	local panel=Menu.frame(overlay,"InventoryPanel",UDim2.fromScale(.5,.5),UDim2.new(1,-24,1,-40)); panel.AnchorPoint=Vector2.new(.5,.5)
	local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(1240,800); limit.Parent=panel
	local title=Menu.plaque(panel,"TitlePlaque",Navigation.statsSkills,UDim2.new(.5,-180,0,-24),UDim2.fromOffset(360,58))
	local close=Theme.button(panel,"Close","X",UDim2.new(1,-62,0,10),UDim2.fromOffset(44,44))
	local statsTab=Theme.button(panel,"StatsTab","STATS",UDim2.fromOffset(18,54),UDim2.new(1/3,-16,0,38))
	local skillsTab=Theme.button(panel,"SkillsTab","SKILLS",UDim2.new(1/3,6,0,54),UDim2.new(1/3,-16,0,38))
	local advanceTab=Theme.button(panel,"AdvanceTab","ADVANCE",UDim2.new(2/3,-6,0,54),UDim2.new(1/3,-12,0,38))
	local body=Instance.new("ScrollingFrame"); body.Name="Content"; body.Position=UDim2.fromOffset(18,104); body.Size=UDim2.new(1,-36,1,-166); body.BackgroundTransparency=1; body.BorderSizePixel=0; body.ScrollBarThickness=5; body.Parent=panel
	local message=Theme.label(panel,"Message","",UDim2.new(0,18,1,-54),UDim2.new(1,-36,0,42),12,Theme.color.muted)
	local function resizeChrome()
		local width,height=panel.AbsoluteSize.X,panel.AbsoluteSize.Y
		local short=height>0 and height<400
		local wide=short and width>=600
		if short then
			title.Position=wide and UDim2.fromOffset(10,2) or UDim2.new(.5,-95,0,2)
			title.Size=UDim2.fromOffset(190,40);title.Caption.TextSize=15
			close.Position=UDim2.new(1,-52,0,1)
			local left=wide and 205 or 12
			local available=wide and width-265 or width-24
			local y=wide and 1 or 44
			local w=(available-12)/3
			for i,b in ipairs({statsTab,skillsTab,advanceTab}) do
			 b.Position=UDim2.fromOffset(left+(i-1)*(w+6),y);b.Size=UDim2.fromOffset(w,40);b.Caption.TextSize=12
			end
			local top=wide and 48 or 90
			body.Position=UDim2.fromOffset(12,top);body.Size=UDim2.new(1,-24,1,-top-34)
			message.Position=UDim2.new(0,14,1,-31);message.Size=UDim2.new(1,-28,0,26);message.TextSize=10
		else
			title.Position=UDim2.new(.5,-180,0,-24);title.Size=UDim2.fromOffset(360,58);title.Caption.TextSize=22
			close.Position=UDim2.new(1,-62,0,10)
			statsTab.Position,statsTab.Size=UDim2.fromOffset(18,54),UDim2.new(1/3,-16,0,38)
			skillsTab.Position,skillsTab.Size=UDim2.new(1/3,6,0,54),UDim2.new(1/3,-16,0,38)
			advanceTab.Position,advanceTab.Size=UDim2.new(2/3,-6,0,54),UDim2.new(1/3,-12,0,38)
			body.Position,body.Size=UDim2.fromOffset(18,104),UDim2.new(1,-36,1,-166)
			message.Position,message.Size,message.TextSize=UDim2.new(0,18,1,-54),UDim2.new(1,-36,0,42),12
		end
	end
	panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeChrome)
	resizeChrome()
	local remotes=RS:WaitForChild("Remotes")
	local remote=remotes:WaitForChild("HeroProgressionRequest")
	local inventoryRemote=remotes:WaitForChild("InventoryRequest")
	local snapshot,pending
	local tab="Stats"
	local treeState={selected=1}
 local statState={gearExpanded=false}
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
	local function showLaunch()
		local phase=player:GetAttribute("K0SessionPhase")
		launch.Visible=not opened and not player:GetAttribute("TLTInventoryOpen") and not player:GetAttribute("TLTSettingsOpen") and phase~="Lobby" and phase~="Tutorial" and phase~="Respawning" and phase~="LoadingTutorial"
	end
	local function visible(value)
		if value and player:GetAttribute("K0SessionPhase")=="Respawning" then return end
		opened=value; overlay.Visible=value;showLaunch(); player:SetAttribute("TLTProgressionOpen",value)
		if onVisibility then onVisibility(value) end
		if value then
			CAS:BindActionAtPriority("HeroGrowthMovement",function() return Enum.ContextActionResult.Sink end,false,4000,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.Thumbstick1)
			getState(); render()
		else CAS:UnbindAction("HeroGrowthMovement") end
	end
	player:GetAttributeChangedSignal("TLTInventoryOpen"):Connect(showLaunch)
	player:GetAttributeChangedSignal("TLTSettingsOpen"):Connect(showLaunch)
	player:GetAttributeChangedSignal("K0SessionPhase"):Connect(showLaunch)
	local function label(parent,name,text,y,height,size,color)
		return Theme.label(parent,name,text,UDim2.fromOffset(12,y),UDim2.new(1,-24,0,height),size or 14,color)
	end
	render=function()
		for _,child in ipairs(body:GetChildren()) do child:Destroy() end
		local hero=snapshot and snapshot.heroes[snapshot.heroId]
		local g=hero and hero.progression
		if not g then
			local needsHero=snapshot and snapshot.ready and not snapshot.heroId
			label(body,"Loading",needsHero and Navigation.selectHeroGrowth or Navigation.loadingHero,12,70)
			if needsHero and player:GetAttribute("K0SessionPhase")=="Lobby" then
				local choose=Theme.button(body,"SelectHero",Navigation.selectHero,UDim2.fromOffset(12,90),UDim2.fromOffset(180,44),true)
				choose.Activated:Connect(function() visible(false); require(script.Parent.LobbyMenuBridge):Fire("Heroes") end)
			end
			body.CanvasSize=UDim2.fromOffset(0,150); return
		end
		local classId=hero.baseClassId
		title.Caption.Text=Navigation.statsSkills
		for _,entry in ipairs({{statsTab,"Stats"},{skillsTab,"Skills"},{advanceTab,"Advance"}}) do entry[1].TDButtonArt.ImageColor3=tab==entry[2] and Color3.fromRGB(132,206,255) or Color3.new(1,1,1) end
		if tab=="Skills" then
			treeState.retry=function() if pending then remote:FireServer(pending);show("Checking the same save...") end end
			local height=SkillTree.render(body,hero,snapshot,treeState,send,render,pending)
			body.CanvasSize=UDim2.fromOffset(0,height)
			if not snapshot.atHub and not pending then show(snapshot.canInvest and "You can invest points and change your loadout here. Return to Hub to advance." or errors.UnsafeGrowth) end
			return
		end
		local preview=Growth.copy(g)
		local spent=0; for k,v in pairs(draft) do preview.stats[k]=preview.stats[k]+v; spent=spent+v end
		local statPoints,skillPoints=Growth.points(g)
		local derived=SkillPreview.derived(classId,preview,snapshot.stats)
		local narrow=body.AbsoluteSize.X<620
		if tab=="Stats" then
			local height=StatsView.render(body,hero,snapshot,derived,draft,pending,render,send,resetDraft,function() if pending then remote:FireServer(pending);show("Checking the same save...") end end,statState)
			body.CanvasSize=UDim2.fromOffset(0,height)
			if not snapshot.atHub and not pending then show(snapshot.canInvest and "You can invest points and change your loadout here. Return to Hub to advance." or errors.UnsafeGrowth) end
			return
		end
		local portraitWidth=narrow and 110 or math.floor(body.AbsoluteSize.X*.37)
		local portraitHeight=narrow and 156 or 368
		local portraitFrame=Chrome.frame(body,"HeroPortrait",UDim2.fromOffset(0,0),UDim2.fromOffset(portraitWidth,portraitHeight))
		local image=Instance.new("ImageLabel");image.BackgroundTransparency=1;image.Size=UDim2.fromScale(1,1);image.Image="rbxassetid://"..portraits[classId];image.ScaleType=Enum.ScaleType.Fit;image.Parent=portraitFrame
		local content=Instance.new("Frame");content.Name="Growth";content.BackgroundTransparency=1;content.Position=UDim2.fromOffset(narrow and 0 or portraitWidth+18,narrow and 172 or 0);content.Size=UDim2.new(1,narrow and -4 or -portraitWidth-22,0,700);content.Parent=body
		local editable=snapshot.ready and snapshot.atHub and not pending
		if tab=="Advance" then
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
			label(content,"AdvancementNote","Complete each trial in Hub. Reaching a level alone does not advance your hero. Slots 4 / 5 open at Level 5 / 10. The ultimate uses its own button after the final Level 80 advancement.\nNew path skills are learned at their listed levels after the matching stage is complete.",546,102,12,Theme.color.muted)
			content:SetAttribute("ContentHeight",660)
		end
		if pending then
			local retry=Theme.button(content,"RetrySave","RETRY SAVE",UDim2.fromOffset(0,tab=="Stats" and 500 or content:GetAttribute("ContentHeight") or 710),UDim2.new(1,0,0,38))
			retry.Activated:Connect(function() if pending then remote:FireServer(pending); show("Checking the same save...") end end)
		end
		body.CanvasSize=UDim2.fromOffset(0,(narrow and 172 or 0)+(tab=="Stats" and (pending and 550 or 496) or (content:GetAttribute("ContentHeight") or 706)+(pending and 50 or 0)))
		if not snapshot.atHub and not pending then show(snapshot.canInvest and "You can invest points and change your loadout here. Return to Hub to advance." or errors.UnsafeGrowth) end
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
	end,false,Enum.KeyCode[Navigation.statsKey])
	remotes:WaitForChild("InventoryState").OnClientEvent:Connect(function(value,requestId,reason)
		if type(value)~="table" or type(value.heroes)~="table" or snapshot and value.revision<snapshot.revision then return end
		local changed=not snapshot or snapshot.revision~=value.revision or snapshot.heroId~=value.heroId
		if snapshot and snapshot.heroId~=value.heroId then treeState={selected=1} end
		snapshot=value
		if pending and requestId==pending.requestId then
			if reason~="SaveUnknown" and reason~="Busy" then pending=nil end
			show(reason and (errors[reason] or "Change rejected. Refresh your hero and try again.") or "Hero saved.")
		end
		if changed then resetDraft() end
		if opened then render() end
	end)
	remotes:WaitForChild("K0HeroState").OnClientEvent:Connect(function() if opened then getState() end end)
 task.spawn(function() while gui.Parent do task.wait(2);if opened and not pending then getState() end end end)
 showLaunch()
	return {open=function(which) tab=which or "Stats"; visible(true) end,close=function() visible(false) end,isOpen=function() return opened end}
end
return Gui
