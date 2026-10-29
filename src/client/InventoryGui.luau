local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local Catalog = require(ReplicatedStorage.Shared.ItemCatalog)
local Text = require(ReplicatedStorage.Shared.InventoryText)
local BaseTheme = require(script.Parent.TDInventoryTheme)
local Chrome = require(script.Parent.InventoryChrome)
local Artwork = require(script.Parent.ItemArtwork)
local Theme = setmetatable({frame=Chrome.frame},{__index=BaseTheme})
local PotionIcon = require(script.Parent.PotionIcon)
local Color = Theme.color
local InventoryGui = {}

function InventoryGui.create(onVisibility, feedback)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild("InventoryGui")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "InventoryGui", false, 60
	gui.ScreenInsets, gui.ZIndexBehavior = Enum.ScreenInsets.CoreUISafeInsets, Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui
	local launcher = Theme.button(gui,"OpenBag",Text.Bag .. "  [B]",UDim2.new(1,-142,0,10),UDim2.fromOffset(128,44))
	local badge = Theme.label(launcher,"UnclaimedBadge","",UDim2.new(1,-30,0,-8),UDim2.fromOffset(32,24),12,Color.gold)
	badge.Visible = false
	local shade = Instance.new("Frame")
	shade.Name, shade.Size, shade.BackgroundColor3 = "InventoryOverlay", UDim2.fromScale(1,1), Color.ink
	shade.BackgroundTransparency, shade.BorderSizePixel, shade.Active, shade.Visible = .2,0,true,false
	shade.Parent = gui
	local shell = Theme.frame(shade,"InventoryPanel",UDim2.fromScale(.5,.5),UDim2.new(1,-24,1,-24))
	shell.AnchorPoint = Vector2.new(.5,.5)
	local constraint = Instance.new("UISizeConstraint"); constraint.MaxSize = Vector2.new(1160,760); constraint.Parent = shell
	local plaque=Theme.sprite(shell,"TitlePlaque","shellDetails",UDim2.new(.5,-150,0,-24),UDim2.fromOffset(300,58)); plaque.SliceScale=.32
	Theme.label(shell,"Eyebrow",Text.Eyebrow,UDim2.fromOffset(24,14),UDim2.new(1,-130,0,18),11,Color.silver)
	local title = Theme.label(shell,"Title",Text.Title,UDim2.fromOffset(24,35),UDim2.new(1,-140,0,35),26,Color.gold)
	title.Font = Enum.Font.GothamBlack
	title.Parent=plaque; title.TextXAlignment=Enum.TextXAlignment.Center
	local close = Theme.button(shell,"CloseBag","X",UDim2.new(1,-68,0,18),UDim2.fromOffset(44,44))
	close.BackgroundColor3=Color3.fromRGB(155,24,40)
	close.TDButtonArt.ImageColor3=Color3.fromRGB(255,170,180)
	close.Caption.Text="X"; close.Caption.TextSize=24
	local gear = Theme.button(shell,"ViewEquipment",Text.ViewGear,UDim2.fromOffset(20,78),UDim2.fromOffset(156,40))
	local heroLabel = Theme.label(shell,"HeroName","",UDim2.fromOffset(344,78),UDim2.new(1,-368,0,40),14,Color.silver)
	local filters = Instance.new("Frame"); filters.Name="Filters"; filters.BackgroundTransparency=1; filters.Parent=shell
	local filterButtons = {}
	for index, category in ipairs({"All","Equipment","Consumables","Materials"}) do
		filterButtons[category] = Theme.button(filters,"Filter_"..category,Text[category],UDim2.new(),UDim2.new())
	end
	local sort = Theme.button(shell,"SortItems","SORT: NAME",UDim2.new(),UDim2.fromOffset(130,40))
	local content = Instance.new("Frame"); content.Name="Content"; content.BackgroundTransparency=1; content.Parent=shell
	local function list(name)
		local panel=Theme.frame(content,name,UDim2.new(),UDim2.new())
		local heading=Theme.label(panel,"Heading","",UDim2.fromOffset(14,10),UDim2.new(1,-28,0,25),13,Color.gold)
		heading.TextXAlignment=Enum.TextXAlignment.Center
		heading.BackgroundColor3,heading.BackgroundTransparency=Color.ink,.15
		local scroll=Instance.new("ScrollingFrame")
		scroll.Name,scroll.Position,scroll.Size="Items",UDim2.fromOffset(12,43),UDim2.new(1,-24,1,-55)
		scroll.BackgroundTransparency,scroll.BorderSizePixel,scroll.ScrollBarThickness=1,0,4
		scroll.ScrollBarImageColor3,scroll.AutomaticCanvasSize,scroll.CanvasSize=Color.gold,Enum.AutomaticSize.Y,UDim2.new()
		scroll.ScrollingDirection=Enum.ScrollingDirection.Y; scroll.Parent=panel
		local grid=Instance.new("UIGridLayout"); grid.CellPadding=UDim2.fromOffset(8,8); grid.SortOrder=Enum.SortOrder.LayoutOrder; grid.Parent=scroll
		local empty=Theme.label(panel,"Empty",Text.Empty,UDim2.fromOffset(20,70),UDim2.new(1,-40,0,80),15,Color.muted)
		return {panel=panel,heading=heading,scroll=scroll,grid=grid,empty=empty}
	end
	local heroPanel=Theme.frame(content,"HeroPreview",UDim2.new(),UDim2.new())
	local portrait=Instance.new("ImageLabel")
	portrait.Name,portrait.BackgroundTransparency,portrait.ScaleType="HeroPortrait",1,Enum.ScaleType.Crop
	portrait.Position,portrait.Size,portrait.Parent=UDim2.fromOffset(5,40),UDim2.new(1,-10,1,-108),heroPanel
	local portraits={knight="rbxassetid://103255177842108",elf="rbxassetid://80894238854345",dwarf="rbxassetid://74628903359757",mage="rbxassetid://91907986271282"}
	heroLabel.Parent=heroPanel
	gear.Parent=heroPanel
	local equipmentSlots=Instance.new("Frame"); equipmentSlots.Name="EquipmentSlots"; equipmentSlots.BackgroundTransparency=1; equipmentSlots.Size=UDim2.fromScale(1,1); equipmentSlots.Parent=heroPanel
	local bag,storage = list("BagItems"),list("StorageItems")
	local details=Theme.frame(content,"ItemDetails",UDim2.new(),UDim2.new())
	local detailScroll=Instance.new("ScrollingFrame")
	detailScroll.Name,detailScroll.Position,detailScroll.Size="Description",UDim2.fromOffset(16,14),UDim2.new(1,-32,1,-88)
	detailScroll.BackgroundTransparency,detailScroll.BorderSizePixel,detailScroll.ScrollBarThickness=1,0,4
	detailScroll.AutomaticCanvasSize,detailScroll.CanvasSize,detailScroll.ScrollingDirection=Enum.AutomaticSize.Y,UDim2.new(),Enum.ScrollingDirection.Y
	detailScroll.Parent=details
	local primary=Theme.button(details,"PrimaryAction",Text.Equip,UDim2.new(0,12,1,-110),UDim2.new(1,-24,0,46),false)
	local lockItem=Theme.button(details,"ToggleLock",Text.Lock,UDim2.new(0,12,1,-58),UDim2.new(.5,-16,0,44))
	local discard=Theme.button(details,"DiscardItem",Text.Discard,UDim2.new(.5,4,1,-58),UDim2.new(.5,-16,0,44))
	lockItem.Caption.TextSize,discard.Caption.TextSize=10,11
	discard.BackgroundColor3=Color3.fromRGB(115,27,39)
	local discardOverlay=Instance.new("Frame")
	discardOverlay.Name,discardOverlay.Size,discardOverlay.BackgroundColor3="DiscardOverlay",UDim2.fromScale(1,1),Color.ink
	discardOverlay.BackgroundTransparency,discardOverlay.Active,discardOverlay.Visible,discardOverlay.ZIndex=.12,true,false,20
	discardOverlay.Parent=shade
	local discardDialog=Theme.frame(discardOverlay,"DiscardDialog",UDim2.fromScale(.5,.5),UDim2.new(1,-40,0,300))
	discardDialog.AnchorPoint=Vector2.new(.5,.5)
	local dialogLimit=Instance.new("UISizeConstraint");dialogLimit.MaxSize=Vector2.new(460,300);dialogLimit.Parent=discardDialog
	local discardPrompt=Theme.label(discardDialog,"Prompt","",UDim2.fromOffset(20,20),UDim2.new(1,-40,0,76),17,Color.gold)
	Theme.label(discardDialog,"Hint",Text.DiscardHint,UDim2.fromOffset(20,100),UDim2.new(1,-40,0,48),12,Color.muted)
	local discardQuantity=Instance.new("TextBox")
	discardQuantity.Name,discardQuantity.Text,discardQuantity.ClearTextOnFocus="DiscardQuantity","1",false
	discardQuantity.Position,discardQuantity.Size=UDim2.fromOffset(20,158),UDim2.new(1,-40,0,44)
	discardQuantity.BackgroundColor3,discardQuantity.TextColor3,discardQuantity.TextSize=Color.ink,Color.text,18
	discardQuantity.Parent=discardDialog
	local confirmDiscard=Theme.button(discardDialog,"ConfirmDiscard",Text.ConfirmDiscard,UDim2.new(.5,4,1,-66),UDim2.new(.5,-24,0,46))
	local cancelDiscard=Theme.button(discardDialog,"CancelDiscard",Text.Cancel,UDim2.new(0,20,1,-66),UDim2.new(.5,-24,0,46))
	confirmDiscard.Caption.TextSize=11
	local discardTarget
	local footer=Instance.new("Frame")
	footer.Name,footer.Position,footer.Size="FooterBacking",UDim2.new(0,20,1,-68),UDim2.new(1,-40,0,54)
	footer.BackgroundColor3,footer.BackgroundTransparency,footer.BorderSizePixel=Color.ink,.12,0
	footer.Parent=shell
	local message=Theme.label(shell,"InventoryMessage",Text.Loading,UDim2.new(0,24,1,-60),UDim2.new(1,-48,0,32),13,Color.silver)
	local mode=Theme.label(shell,"SaveMode",Text.Session,UDim2.new(0,24,1,-25),UDim2.new(1,-48,0,18),10,Color.muted)
	local retry=Theme.button(shell,"RetryRequest",Text.Retry,UDim2.new(1,-212,1,-66),UDim2.fromOffset(188,42))
	retry.Visible=false
	local bagTab=Theme.button(shell,"BagTab",Text.BagTab,UDim2.new(),UDim2.new())
	local storageTab=Theme.button(shell,"StorageTab",Text.StorageTab,UDim2.new(),UDim2.new())
	local pendingButton=Theme.button(shell,"OpenPending",Text.Pending,UDim2.new(),UDim2.new()); pendingButton.Visible=false
	local closeClaims=Theme.button(shell,"CloseClaims","X  CLOSE CLAIMS",UDim2.new(),UDim2.new());closeClaims.Visible=false;closeClaims.BackgroundColor3=Color3.fromRGB(135,27,40)
	local claimsOverlay=Instance.new("Frame")
	claimsOverlay.Name,claimsOverlay.Size,claimsOverlay.BackgroundColor3="ClaimsOverlay",UDim2.fromScale(1,1),Color.ink
	claimsOverlay.BackgroundTransparency,claimsOverlay.Active,claimsOverlay.Visible,claimsOverlay.ZIndex=.12,true,false,10
	claimsOverlay.Parent=shade
	local claimsPanel=Chrome.frame(claimsOverlay,"ClaimsPopup",UDim2.fromScale(.5,.5),UDim2.new(1,-48,1,-64));claimsPanel.AnchorPoint=Vector2.new(.5,.5)
	local claimsLimit=Instance.new("UISizeConstraint");claimsLimit.MaxSize=Vector2.new(980,680);claimsLimit.Parent=claimsPanel
	local claimsTitle=Theme.label(claimsPanel,"ClaimsTitle",Text.Pending,UDim2.fromOffset(20,12),UDim2.new(1,-92,0,42),24,Color.gold)
	closeClaims.Parent=claimsPanel;closeClaims.Caption.Text="X";closeClaims.Caption.TextSize=24
	local snapshot,remote,pending,selectedId,accessorySlot,actionForSelection,quantityBox
	local opened,storageMode,gearMode,mobileDetail=false,false,false,false
	local category,sourceTab,sortMode="Equipment","bag","Name"
	local expandedDetails=false
	local quantity=1
	local compact=false
	local render,resize,send
	local previousFocus
	local function requestState()
		if remote then remote:FireServer({action="GetState",requestId=HttpService:GenerateGUID(false)}) end
	end
	local function getSelected()
		for _, item in ipairs(snapshot and snapshot.items or {}) do if item.instanceId==selectedId then return item end end
	end
	local function setMessage(text,error)
		message.Text,message.TextColor3=text,error and Color.error or Color.silver
		if error and not opened and feedback then feedback(text) end
	end
	local function setOpen(value)
		opened=value; shade.Visible=value; launcher.Visible=not value and not player:GetAttribute("TLTProgressionOpen")
		discardOverlay.Visible=false; discardTarget=nil
		if not value then claimsOverlay.Visible=false end
		player:SetAttribute("TLTInventoryOpen",value)
		if onVisibility then onVisibility(value) end
		if value then
			previousFocus=GuiService.SelectedObject
			ContextActionService:BindActionAtPriority("InventoryMovement",function() return Enum.ContextActionResult.Sink end,false,4000,
				Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.Thumbstick1)
			requestState(); resize(); render()
			if UserInputService:GetLastInputType().Name:match("^Gamepad") then GuiService.SelectedObject=close end
		else
			ContextActionService:UnbindAction("InventoryMovement")
			if previousFocus and previousFocus.Parent and previousFocus.Visible then GuiService.SelectedObject=previousFocus else GuiService.SelectedObject=nil end
		end
	end
	player:GetAttributeChangedSignal("TLTProgressionOpen"):Connect(function() launcher.Visible=not opened and not player:GetAttribute("TLTProgressionOpen") end)
	local function choose(item)
		selectedId,accessorySlot,quantity,quantityBox=item.instanceId,nil,1,nil
		expandedDetails=false
		mobileDetail=true
		resize(); render()
	end
	local function command(action,slot,destination)
		local item=getSelected()
		if not item or not snapshot or pending then return end
		if quantityBox then quantity=tonumber(quantityBox.Text) end
		if action=="Deposit" or action=="Withdraw" or action=="Claim" then
			if not quantity or quantity%1~=0 or quantity<1 or quantity>item.quantity then setMessage(Text.Errors.InvalidQuantity,true); return end
		end
		send({requestId=HttpService:GenerateGUID(false),action=action,heroId=snapshot.heroId,instanceId=item.instanceId,
			itemVersion=item.version,revision=snapshot.revision,slot=slot,quantity=quantity,destination=destination})
	end
	local function detailLabel(name,text,y,height,size,color)
		return Theme.label(detailScroll,name,text,UDim2.fromOffset(2,y),UDim2.new(1,-8,0,height),size,color)
	end
	local function clearChildren(parent,kind)
		for _, child in ipairs(parent:GetChildren()) do if not kind or child:IsA(kind) then child:Destroy() end end
	end
	local function renderDetails()
		if quantityBox and quantityBox.Parent then quantity=tonumber(quantityBox.Text) end
		clearChildren(detailScroll)
		actionForSelection,quantityBox=nil,nil
		local y=0
		if compact or sourceTab=="pending" and claimsPanel.AbsoluteSize.X<700 then
			local back=Theme.button(detailScroll,"BackToItems","BACK TO ITEMS",UDim2.fromOffset(0,0),UDim2.new(1,-6,0,44))
			back.Activated:Connect(function() mobileDetail=false; resize() end); y=50
		end
		local item=getSelected()
		lockItem.Visible,discard.Visible=false,false
		if not item then
			detailLabel("Prompt",snapshot and not snapshot.heroId and Text.SelectHero or Text.SelectItem,y,50,22,Color.gold)
			detailLabel("Hint",Text.SelectHint,y+58,100,14,Color.muted)
			primary.Visible=false; return
		end
		local def=Catalog.items[item.definitionId]
		local hero=snapshot.heroes[snapshot.heroId]
		if storageMode and not compact and sourceTab~="pending" then
			Artwork.create(detailScroll,def,UDim2.fromOffset(0,0),UDim2.fromOffset(90,90))
			local name=detailLabel("ItemName",def.name,0,36,20,Color.text); name.Position=UDim2.fromOffset(106,0); name.Size=UDim2.new(1,-112,0,36)
			local loc=item.location.kind
			actionForSelection=loc=="storage" and "Withdraw" or loc=="pending" and "Claim" or loc=="bag" and "Deposit" or nil
			if item.quantity>1 and actionForSelection then
				local label=detailLabel("QuantityLabel",Text.Quantity,42,22,11,Color.muted); label.Position=UDim2.fromOffset(106,40)
				quantityBox=Instance.new("TextBox"); quantityBox.Name,quantityBox.Text="MoveQuantity",tostring(quantity or 1)
				quantityBox.Position,quantityBox.Size=UDim2.fromOffset(106,64),UDim2.fromOffset(110,36)
				quantityBox.ClearTextOnFocus,quantityBox.BackgroundColor3,quantityBox.TextColor3=false,Color.ink,Color.text
				quantityBox.TextSize,quantityBox.Parent=16,detailScroll
				local entry=quantityBox; local id=selectedId
				entry.FocusLost:Connect(function() if selectedId==id then quantity=tonumber(entry.Text) end end)
			end
			primary.Visible=actionForSelection~=nil
			if actionForSelection then primary.Caption.Text=Text[actionForSelection]; Theme.enabled(primary,not pending and snapshot.ready and snapshot.safe and snapshot.atStorage) end
			return
		end
		if item.location.kind=="equipped" then
			detailLabel("EquippedStatus",string.format(Text.EquippedSlot,Text.Slots[item.location.slot]),y,26,13,Color.gold);y=y+30
		end
		if def.slot and item.location.kind=="bag" and not snapshot.safe then
			detailLabel("ActionBlockedReason",Text.EquipHint,y,64,13,Color.error);y=y+68
		elseif def.slot and item.location.kind=="bag" and def.classId and hero and def.classId~=hero.baseClassId then
			detailLabel("ActionBlockedReason",Text.Errors.WrongClass,y,56,13,Color.error);y=y+60
		elseif def.slot and hero and hero.level<(def.level or 1) then
			detailLabel("ActionBlockedReason",Text.Errors.LevelRequired,y,48,13,Color.error);y=y+52
		end
		local heading=detailLabel("ItemName",def.name,y,46,20,Color.text); heading.TextXAlignment=Enum.TextXAlignment.Center; heading.Font=Enum.Font.GothamBold; y=y+48
		Artwork.create(detailScroll,def,UDim2.fromOffset(12,y),UDim2.new(1,-32,0,156)); y=y+160
		local classText=def.classId and string.format(Text.Class,Catalog.classes[def.classId]) or Text.Compatible
		detailLabel("Requirements",classText.."  •  "..string.format(Text.Level,def.level or 1),y,28,11,Color.muted); y=y+32
		if def.restore then detailLabel("RestoreAmount",string.format(Text.RestoreAmount,def.amount,def.glyph),y,30,16,def.restore=="health" and Color.error or Color.silver); y=y+34 end
		if expandedDetails then
			detailLabel("Rarity",string.upper(def.rarity).."  •  "..string.upper(def.category),y,22,11,Color.silver); y=y+26
			detailLabel("Binding",(item.binding=="character" and Text.CharacterBound or Text.Bound)..(item.locked and "  •  "..Text.Locked or ""),y,26,11,Color.gold); y=y+30
		end
		if def.slot then
			if def.slot=="accessory" and item.location.kind=="bag" and not storageMode then
				detailLabel("ChooseSlot",Text.ChooseAccessory,y,36,13,Color.silver); y=y+40
				for index=1,2 do
					local slot="accessory"..index
					local button=Theme.button(detailScroll,"Choose_"..slot,(accessorySlot==slot and "[X] " or "")..Text["Accessory"..index],UDim2.new((index-1)*.5,0,0,y),UDim2.new(.5,-5,0,44))
					button.Caption.TextSize=11
					button.Activated:Connect(function() accessorySlot=slot; renderDetails() end)
				end
				y=y+50
			end
			local compareSlot=def.slot=="accessory" and accessorySlot or def.slot
			local current
			for _, other in ipairs(snapshot.items) do
				if other.location.kind=="equipped" and other.location.heroId==snapshot.heroId and other.location.slot==compareSlot then current=Catalog.items[other.definitionId] end
			end
			local lines={Text.Current.."  →  "..Text.Selected}
			for _, key in ipairs({"power","armor","health"}) do
				local before,after=current and current.stats[key] or 0,def.stats[key] or 0
				local suffix=key=="power" and "%" or ""
				lines[#lines+1]=string.format("%s   %d%s → %d%s   (%+d%s)",Text.Stats[key],before,suffix,after,suffix,after-before,suffix)
			end
			detailLabel("Comparison",table.concat(lines,"\n"),y,94,13,Color.text); y=y+100
		end
		if expandedDetails then detailLabel("DescriptionText",def.description,y,70,13,Color.muted); y=y+76 end
		local more=Theme.button(detailScroll,"ToggleDetails",expandedDetails and Text.LessDetails or Text.MoreDetails,UDim2.fromOffset(0,y),UDim2.new(1,-6,0,36))
		more.Activated:Connect(function() expandedDetails=not expandedDetails; renderDetails() end); y=y+42
		local loc=item.location.kind
		if loc=="equipped" then actionForSelection="Unequip"
		elseif loc=="storage" then actionForSelection="Withdraw"
		elseif loc=="pending" then actionForSelection="Claim"
		elseif storageMode then actionForSelection="Deposit"
		elseif def.slot then actionForSelection="Equip"
		elseif def.restore then actionForSelection="Use" end
		if (actionForSelection=="Deposit" or actionForSelection=="Withdraw" or actionForSelection=="Claim") and item.quantity>1 then
			detailLabel("QuantityLabel",Text.Quantity.."  (1–"..item.quantity..")",y,22,13,Color.silver); y=y+28
			quantityBox=Instance.new("TextBox")
			quantityBox.Name,quantityBox.Text="MoveQuantity",tostring(quantity or 1)
			quantityBox.Position,quantityBox.Size=UDim2.fromOffset(0,y),UDim2.new(1,-6,0,44)
			quantityBox.ClearTextOnFocus,quantityBox.BackgroundColor3,quantityBox.TextColor3=false,Color.ink,Color.text
			quantityBox.Font,quantityBox.TextSize=Enum.Font.GothamBold,16
			quantityBox.Parent=detailScroll
			local entry=quantityBox
			local selectedWhenCreated=selectedId
			entry.FocusLost:Connect(function() if selectedId==selectedWhenCreated then quantity=tonumber(entry.Text) end end)
			y=y+52
		end
		if def.restore and loc=="bag" and not storageMode then
			for index=1,2 do
				local button=Theme.button(detailScroll,"AssignQuick"..index,Text[index==1 and "AssignZ" or "AssignC"],UDim2.new((index-1)*.5,0,0,y),UDim2.new(.5,-5,0,44))
				button.Activated:Connect(function() command("Assign",index) end)
				Theme.enabled(button,not pending and snapshot.ready and snapshot.safe)
			end
			y=y+50
		end
		if loc=="bag" or loc=="equipped" then
			lockItem.Visible=true;lockItem.Caption.Text=item.locked and Text.Unlock or Text.Lock
			Theme.enabled(lockItem,not pending and snapshot.ready)
			discard.Visible=loc=="bag"
			Theme.enabled(discard,not pending and snapshot.ready and snapshot.safe and not item.locked)
			if item.locked then detailLabel("LockNotice",Text.LockHint,y,52,12,Color.gold);y=y+56 end
		end
		detailLabel("StatsNotice",def.slot and Text.StatsHint or def.restore and (snapshot.atHub and Text.UseInField or Text.PotionHint) or Text.HubHint,y,55,12,Color.muted)
		primary.Visible=actionForSelection~=nil
		if actionForSelection then
			primary.Caption.Text=Text[actionForSelection]
			local enabled=not pending and snapshot.ready and hero~=nil
			if actionForSelection~="Use" then enabled=enabled and snapshot.safe end
			if actionForSelection=="Deposit" or actionForSelection=="Withdraw" then enabled=enabled and snapshot.atStorage end
			if actionForSelection=="Claim" then enabled=enabled and snapshot.atHub end
			if actionForSelection=="Use" and snapshot.atHub then enabled=false end
			if actionForSelection=="Equip" then enabled=enabled and (not def.classId or hero.baseClassId==def.classId) and hero.level>=(def.level or 1) and (def.slot~="accessory" or accessorySlot~=nil) end
			if actionForSelection=="Equip" and not snapshot.safe then primary.Caption.Text=Text.CombatLocked end
			Theme.enabled(primary,enabled==true)
		end
	end
	local function renderList(view,kind)
		clearChildren(view.scroll,"GuiObject")
		local items={}
		for _, item in ipairs(snapshot and snapshot.items or {}) do
			local def=Catalog.items[item.definitionId]
			if item.location.kind==kind and (kind~="bag" and kind~="equipped" or item.location.heroId==snapshot.heroId)
				and (kind=="pending" or category=="All" or def.category==category) then table.insert(items,item) end
		end
		table.sort(items,function(a,b)
			local ad,bd=Catalog.items[a.definitionId],Catalog.items[b.definitionId]
			if sortMode=="Level" and (ad.level or 1)~=(bd.level or 1) then return (ad.level or 1)>(bd.level or 1) end
			if ad.name~=bd.name then return ad.name<bd.name end
			return a.instanceId<b.instanceId
		end)
		view.empty.Visible=#items==0
		if not getSelected() and #items>0 and kind~="storage" then
			selectedId=items[1].instanceId
			for _,item in ipairs(items) do local def=Catalog.items[item.definitionId]; if def.slot=="weapon" and def.classId==(snapshot.heroes[snapshot.heroId] or {}).baseClassId then selectedId=item.instanceId; break end end
		end
		local filled=#items
		for index=1,math.max(filled,12) do
			local item=items[index]
			local def=item and Catalog.items[item.definitionId]
			local card=Chrome.card(view.scroll,item and "Item_"..item.instanceId or "EmptySlot"..index,UDim2.new(),UDim2.new(),item and selectedId==item.instanceId,item~=nil)
			card.LayoutOrder=index
			if def then
				Artwork.create(card,def,UDim2.fromOffset(7,3),UDim2.new(1,-14,.67,-3))
				local name=Theme.label(card,"ItemName",def.name,UDim2.new(0,4,.68,0),UDim2.new(1,-8,.3,-2),10,Color.text)
				name.TextXAlignment=Enum.TextXAlignment.Center
				local flag=def.category=="Materials" and "x"..item.quantity or ""
				if def.restore then flag="x"..item.quantity end
				if item.locked then flag="LOCK  "..flag end
				local count=Theme.label(card,"ItemStatus",flag,UDim2.fromOffset(4,3),UDim2.new(1,-8,0,15),10,Color.silver); count.TextXAlignment=Enum.TextXAlignment.Right; count.TextStrokeTransparency=.3
				card.Activated:Connect(function() choose(item) end)
			else
				local empty=Theme.label(card,"EmptyMark","◇",UDim2.fromScale(.25,.25),UDim2.fromScale(.5,.5),22,Color3.fromRGB(40,62,83)); empty.TextXAlignment=Enum.TextXAlignment.Center
			end
		end
	end
	render=function()
		if not opened then return end
		local focus=GuiService.SelectedObject
		local focusName=focus and focus:IsDescendantOf(gui) and focus.Name
		local hero=snapshot and snapshot.heroes[snapshot.heroId]
		heroLabel.Text=hero and Catalog.classes[hero.baseClassId].."  •  LV "..hero.level or ""
		title.Text=storageMode and Text.StorageTitle or Text.Title
		portrait.Image=hero and portraits[hero.baseClassId] or ""
		portrait.ImageTransparency=gearMode and .35 or 0
		equipmentSlots:ClearAllChildren()
		equipmentSlots.Visible=gearMode
		if gearMode and hero then
			for index,slot in ipairs(Catalog.slots) do
				local item
				for _,candidate in ipairs(snapshot.items) do if candidate.location.kind=="equipped" and candidate.location.heroId==snapshot.heroId and candidate.location.slot==slot then item=candidate end end
				local right=index>4; local row=(index-1)%4
				local cell=Chrome.card(equipmentSlots,"EquipSlot_"..slot,UDim2.new(right and 1 or 0,right and -60 or 8,0,54+row*62),UDim2.fromOffset(52,54),item and selectedId==item.instanceId,item~=nil)
				if item then Artwork.create(cell,Catalog.items[item.definitionId],UDim2.fromOffset(4,1),UDim2.fromOffset(44,38)); cell.Activated:Connect(function() choose(item) end) end
				local caption=Theme.label(cell,"SlotLabel",Text.Slots[slot],UDim2.fromOffset(0,38),UDim2.fromOffset(52,14),8,Color.silver); caption.TextXAlignment=Enum.TextXAlignment.Center
			end
		end
		mode.Text=snapshot and not snapshot.sessionOnly and Text.Saved or Text.Session
		gear.Caption.Text=gearMode and Text.ViewBag or Text.ViewGear
		bag.heading.Text=sourceTab=="pending" and Text.Pending or snapshot and string.format(Text.BagCount,snapshot.bagUsed,snapshot.bagCapacity) or Text.BagTab
		storage.heading.Text=snapshot and string.format(Text.StorageCount,snapshot.storageUsed,snapshot.storageCapacity) or Text.StorageTab
		for key,button in pairs(filterButtons) do button.TDButtonArt.ImageColor3=key==category and Color3.fromRGB(150,205,255) or Color3.new(1,1,1) end
		if sourceTab=="pending" then renderList(bag,"pending")
		else renderList(bag,"bag") end
		renderList(storage,"storage")
		renderDetails()
		if not pending and snapshot then setMessage(not hero and Text.SelectHero or snapshot.safe and Text.Safe or Text.Combat) end
		if focusName then
			local restored=gui:FindFirstChild(focusName,true)
			if restored and restored:IsA("GuiButton") and restored.Visible and restored.Selectable then GuiService.SelectedObject=restored end
		end
	end
	resize=function()
		local width,height=shell.AbsoluteSize.X,shell.AbsoluteSize.Y
		compact=width<900
		shell.Eyebrow.Visible=false
		plaque.Position,plaque.Size=UDim2.new(.5,compact and -108 or -150,0,-20),UDim2.fromOffset(compact and 216 or 300,54)
		title.Position,title.Size,title.TextSize=UDim2.fromOffset(12,4),UDim2.new(1,-24,1,-8),compact and 19 or 26
		close.Position,close.Size=UDim2.new(1,-56,0,8),UDim2.fromOffset(44,44)
		sort.Position,sort.Size=UDim2.new(1,-174,0,12),UDim2.fromOffset(108,32)
		sort.Caption.TextSize=11
		pendingButton.Position,pendingButton.Size=UDim2.fromOffset(20,12),UDim2.fromOffset(178,32)
		pendingButton.Visible=snapshot~=nil and snapshot.pending>0 and sourceTab~="pending"
		closeClaims.Visible=sourceTab=="pending"
		closeClaims.Position,closeClaims.Size=UDim2.new(1,-62,0,12),UDim2.fromOffset(44,44)
		closeClaims.Caption.TextSize=24
		pendingButton.Caption.Text=Text.Pending.." ("..tostring(snapshot and snapshot.pending or 0)..")"
		pendingButton.Caption.TextSize=11
		heroLabel.Position,heroLabel.Size,heroLabel.TextSize=UDim2.fromOffset(10,8),UDim2.new(1,-20,0,26),12
		heroLabel.TextXAlignment=Enum.TextXAlignment.Center
		local top=116
		local cw=width-40
		local heroWidth=math.floor(cw*.24)
		local detailWidth=math.floor(cw*.28)
		local listWidth=cw-heroWidth-detailWidth-24
		local filterLeft,filterWidth=20+heroWidth+12,listWidth
		gear.Parent=compact and shell or heroPanel
		gear.Position,gear.Size=UDim2.new(0,12,1,-54),UDim2.new(1,-24,0,42)
		gear.Caption.TextSize=12
		if storageMode then filterLeft,filterWidth=20,cw end
		if compact then
			local third=(width-56)/3
			gear.Position,gear.Size=UDim2.fromOffset(20,70),UDim2.fromOffset(third,44)
			sort.Position,sort.Size=UDim2.fromOffset(28+third,70),UDim2.fromOffset(third,44)
			pendingButton.Position,pendingButton.Size=UDim2.fromOffset(36+third*2,70),UDim2.fromOffset(third,44)
			pendingButton.Caption.Text="CLAIMS "..tostring(snapshot and snapshot.pending or 0)
			gear.Caption.TextSize,sort.Caption.TextSize,pendingButton.Caption.TextSize=10,10,10
			filterLeft,filterWidth=20,cw
			top=176
			if storageMode or sourceTab=="pending" then top=top+50 end
		end
		filters.Position,filters.Size=UDim2.fromOffset(filterLeft,compact and 124 or 68),UDim2.fromOffset(filterWidth,compact and 44 or 38)
		local fw=(filterWidth-18)/4
		for index,name in ipairs({"All","Equipment","Consumables","Materials"}) do
			local button=filterButtons[name]
			button.Position,button.Size=UDim2.fromOffset((index-1)*(fw+6),0),UDim2.fromOffset(fw,compact and 44 or 38)
			button.Caption.TextSize=compact and 10 or 11; button.Caption.Text=compact and Text.ShortFilters[name] or Text[name]
		end
		sort.Visible=true
		content.Position,content.Size=UDim2.fromOffset(20,top),UDim2.new(1,-40,1,-top-62)
		footer.Position,footer.Size=UDim2.new(0,20,1,-54),UDim2.new(1,-40,0,42)
		message.Position,message.Size,message.TextSize=UDim2.new(0,24,1,-51),UDim2.new(1,-48,0,20),11
		mode.Position,mode.TextSize=UDim2.new(0,24,1,-28),9
		local tabs=compact and (storageMode or sourceTab=="pending")
		bagTab.Visible,storageTab.Visible=tabs,tabs and storageMode
		bagTab.Position,bagTab.Size=UDim2.fromOffset(20,top-48),UDim2.fromOffset((cw-8)/2,42)
		storageTab.Position,storageTab.Size=UDim2.fromOffset(28+(cw-8)/2,top-48),UDim2.fromOffset((cw-8)/2,42)
		detailScroll.Position,detailScroll.Size=UDim2.fromOffset(12,12),UDim2.new(1,-24,1,-132)
		primary.Position,primary.Size=UDim2.new(0,12,1,-110),UDim2.new(1,-24,0,46)
		if compact then
			heroPanel.Position,heroPanel.Size=UDim2.new(),UDim2.fromScale(1,1)
			heroPanel.Visible=gearMode and not mobileDetail and not storageMode
			bag.panel.Position,bag.panel.Size=UDim2.new(),UDim2.fromScale(1,1)
			storage.panel.Position,storage.panel.Size=UDim2.new(),UDim2.fromScale(1,1)
			details.Position,details.Size=UDim2.new(),UDim2.fromScale(1,1)
			bag.panel.Visible=not mobileDetail and not heroPanel.Visible and (not storageMode or sourceTab~="storage")
			storage.panel.Visible=not mobileDetail and storageMode and sourceTab=="storage"
			details.Visible=mobileDetail
		elseif storageMode and sourceTab~="pending" then
			heroPanel.Visible=false
			bag.panel.Position,bag.panel.Size=UDim2.new(),UDim2.new(.5,-6,1,-142)
			storage.panel.Position,storage.panel.Size=UDim2.new(.5,6,0,0),UDim2.new(.5,-6,1,-142)
			details.Position,details.Size=UDim2.new(0,0,1,-130),UDim2.new(1,0,0,130)
			bag.panel.Visible,storage.panel.Visible,details.Visible=true,true,true
			detailScroll.Size=UDim2.new(.72,-24,1,-24)
			primary.Position,primary.Size=UDim2.new(.74,0,.5,-23),UDim2.new(.24,0,0,46)
		else
			heroPanel.Visible=true; heroPanel.Position,heroPanel.Size=UDim2.new(),UDim2.new(0,heroWidth,1,0)
			bag.panel.Position,bag.panel.Size=UDim2.fromOffset(heroWidth+12,0),UDim2.new(0,listWidth,1,0)
			details.Position,details.Size=UDim2.new(1,-detailWidth,0,0),UDim2.new(0,detailWidth,1,0)
			bag.panel.Visible,storage.panel.Visible,details.Visible=true,false,true
		end
		claimsOverlay.Visible=opened and sourceTab=="pending"
		content.Parent=sourceTab=="pending" and claimsPanel or shell
		message.Parent=sourceTab=="pending" and claimsPanel or shell
		if sourceTab=="pending" then
			claimsTitle.Text=Text.Pending.." ("..tostring(snapshot and snapshot.pending or 0)..")"
			content.Position,content.Size=UDim2.fromOffset(18,74),UDim2.new(1,-36,1,-130)
			message.Position,message.Size=UDim2.new(0,20,1,-48),UDim2.new(1,-40,0,36)
			heroPanel.Visible,storage.panel.Visible=false,false
			if claimsPanel.AbsoluteSize.X<700 then
				bag.panel.Position,bag.panel.Size=UDim2.new(),UDim2.fromScale(1,1)
				details.Position,details.Size=UDim2.new(),UDim2.fromScale(1,1)
				bag.panel.Visible,details.Visible=not mobileDetail,mobileDetail
			else
				bag.panel.Position,bag.panel.Size=UDim2.new(),UDim2.new(.56,-8,1,0)
				details.Position,details.Size=UDim2.new(.56,8,0,0),UDim2.new(.44,-8,1,0)
				bag.panel.Visible,details.Visible=true,true
			end
		end
		for _,view in ipairs({bag,storage}) do
			view.heading.Position,view.heading.Size,view.heading.BackgroundTransparency=UDim2.fromOffset(10,5),UDim2.new(1,-20,0,24),1
			view.heading.TextSize,view.heading.TextXAlignment=12,Enum.TextXAlignment.Right
			view.scroll.Position,view.scroll.Size=UDim2.fromOffset(10,36),UDim2.new(1,-20,1,-46)
			local available=math.max(70,view.panel.AbsoluteSize.X-24)
			local columns=math.clamp(math.floor((available+8)/94),2,4)
			local cell=math.floor((available-(columns-1)*8)/columns)
			view.grid.CellSize=UDim2.fromOffset(cell,cell)
		end
	end
	send=function(value)
		if not remote or pending then return end
		pending=value; retry.Visible=false; setMessage(Text.Waiting)
		remote:FireServer(value)
		renderDetails()
		task.delay(8,function()
			if pending~=value then return end
			retry.Visible=true; message.Size=UDim2.new(1,-254,0,32); setMessage(Text.Uncertain,true)
		end)
	end
	primary.Activated:Connect(function() if actionForSelection then command(actionForSelection,accessorySlot,actionForSelection=="Claim" and "bag" or nil) end end)
	lockItem.Activated:Connect(function() if lockItem.Active then command("Lock") end end)
	local function closeDiscard()
		discardOverlay.Visible=false;discardTarget=nil
		if UserInputService:GetLastInputType().Name:match("^Gamepad") then GuiService.SelectedObject=discard end
	end
	cancelDiscard.Activated:Connect(closeDiscard)
	discard.Activated:Connect(function()
		local item=getSelected()
		if not discard.Active or not item or pending then return end
		discardTarget={instanceId=item.instanceId,itemVersion=item.version,revision=snapshot.revision,heroId=snapshot.heroId,quantity=item.quantity,definitionId=item.definitionId}
		discardQuantity.Text="1"
		discardPrompt.Text=string.format(Text.DiscardConfirm,1,Catalog.items[item.definitionId].name)
		discardOverlay.Visible=true
		if UserInputService:GetLastInputType().Name:match("^Gamepad") then GuiService.SelectedObject=cancelDiscard end
	end)
	discardQuantity:GetPropertyChangedSignal("Text"):Connect(function()
		if discardTarget then
			local n=tonumber(discardQuantity.Text)
			discardPrompt.Text=n and n%1==0 and n>=1 and n<=discardTarget.quantity and string.format(Text.DiscardConfirm,n,Catalog.items[discardTarget.definitionId].name) or Text.Errors.InvalidQuantity
		end
	end)
	confirmDiscard.Activated:Connect(function()
		local target=discardTarget
		if not target or pending then return end
		local count=tonumber(discardQuantity.Text)
		if not count or count%1~=0 or count<1 or count>target.quantity then discardPrompt.Text=Text.Errors.InvalidQuantity;return end
		if not snapshot or snapshot.revision~=target.revision or snapshot.heroId~=target.heroId then closeDiscard();setMessage(Text.Errors.Changed,true);return end
		closeDiscard()
		send({requestId=HttpService:GenerateGUID(false),action="Discard",heroId=target.heroId,instanceId=target.instanceId,itemVersion=target.itemVersion,revision=target.revision,quantity=count})
	end)
	retry.Activated:Connect(function() if pending and remote then remote:FireServer(pending); setMessage(Text.Waiting) end end)
	launcher.Activated:Connect(function() storageMode,sourceTab=false,"bag"; setOpen(true) end)
	close.Activated:Connect(function() setOpen(false) end)
	gear.Activated:Connect(function() gearMode=not gearMode; storageMode=false; sourceTab="bag"; mobileDetail=false; resize(); render() end)
	bagTab.Activated:Connect(function() sourceTab="bag"; mobileDetail=false; resize(); render() end)
	storageTab.Activated:Connect(function() sourceTab="storage"; mobileDetail=false; resize(); render() end)
	pendingButton.Activated:Connect(function() sourceTab="pending"; selectedId=nil;accessorySlot=nil;quantity=1;gearMode=false; mobileDetail=false; resize(); render() end)
	closeClaims.Activated:Connect(function() sourceTab="bag";selectedId=nil;mobileDetail=false;resize();render() end)
	for key,button in pairs(filterButtons) do button.Activated:Connect(function() category=key; selectedId=nil; mobileDetail=false; resize(); render() end) end
	sort.Activated:Connect(function() sortMode=sortMode=="Name" and "Level" or "Name"; sort.Caption.Text="SORT: "..string.upper(sortMode); render() end)
	shell:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() resize(); render() end)
	ContextActionService:BindActionAtPriority("InventoryToggle",function(_,state)
		if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
		if not UserInputService:GetFocusedTextBox() then storageMode,sourceTab=false,"bag"; setOpen(not opened) end
		return Enum.ContextActionResult.Sink
	end,false,4100,Enum.KeyCode.B,Enum.KeyCode.ButtonSelect)
	ContextActionService:BindActionAtPriority("InventoryBack",function(_,state)
		if not opened then return Enum.ContextActionResult.Pass end
		if state==Enum.UserInputState.Begin then
			if discardOverlay.Visible then closeDiscard();return Enum.ContextActionResult.Sink end
			if sourceTab=="pending" then sourceTab="bag";selectedId=nil;mobileDetail=false;resize();render();return Enum.ContextActionResult.Sink end
			if compact and mobileDetail then mobileDetail=false; resize() else setOpen(false) end
		end
		return Enum.ContextActionResult.Sink
	end,false,4100,Enum.KeyCode.ButtonB)
	task.spawn(function()
		local remotes=ReplicatedStorage:WaitForChild("Remotes")
		remote=remotes:WaitForChild("InventoryRequest")
		remotes:WaitForChild("InventoryState").OnClientEvent:Connect(function(value,requestId,errorCode)
			if type(value)~="table" or type(value.items)~="table" or type(value.revision)~="number" then return end
			if snapshot and value.revision<snapshot.revision then return end
			local changed=not snapshot or snapshot.revision~=value.revision or snapshot.heroId~=value.heroId or snapshot.safe~=value.safe or snapshot.atStorage~=value.atStorage or snapshot.ready~=value.ready
			snapshot=value
			badge.Text, badge.Visible=tostring(value.pending),value.pending>0
			local completed=pending and requestId==pending.requestId and errorCode~="Busy"
			local equipped=completed and not errorCode and (pending.action=="Equip" or pending.action=="Unequip")
			if equipped then gearMode=true;mobileDetail=compact and false or mobileDetail end
			if discardOverlay.Visible and discardTarget and (value.revision~=discardTarget.revision or value.heroId~=discardTarget.heroId) then closeDiscard() end
			if completed then
				if errorCode=="SaveUnknown" then retry.Visible=true
				else pending=nil; retry.Visible=false; message.Size=UDim2.new(1,-48,0,32) end
			end
			resize()
			if changed then render() elseif completed then renderDetails() end
			if errorCode then setMessage(Text.Errors[errorCode] or Text.Errors.Unavailable,true)
			elseif completed and not pending then setMessage(equipped and Text.GearApplied or Text.SavedAction) end
		end)
		remotes:WaitForChild("InventoryOpenStorage").OnClientEvent:Connect(function()
			storageMode,gearMode,sourceTab,mobileDetail=true,false,"bag",false
			setOpen(true)
		end)
		requestState()
		while gui.Parent do task.wait(2); if opened and not pending then requestState() end end
	end)
	resize()
	return {
		isOpen=function() return opened end,
		close=function() setOpen(false) end,
		refresh=requestState,
		use=function(slot)
			if pending or not snapshot or not snapshot.ready or not snapshot.heroId then return end
			local hero=snapshot.heroes[snapshot.heroId]
			local definitionId=hero and hero.quickSlots[slot]
			for _,item in ipairs(snapshot.items) do
				if item.location.kind=="bag" and item.location.heroId==snapshot.heroId and item.definitionId==definitionId then
					send({requestId=HttpService:GenerateGUID(false),action="Use",heroId=snapshot.heroId,instanceId=item.instanceId,itemVersion=item.version,revision=snapshot.revision})
					return
				end
			end
			setMessage(Text.Errors.ItemEmpty,true)
		end,
	}
end
return InventoryGui
