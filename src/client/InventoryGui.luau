local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local Catalog = require(ReplicatedStorage.Shared.ItemCatalog)
local Text = require(ReplicatedStorage.Shared.InventoryText)
local Theme = require(script.Parent.TDInventoryTheme)
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
	Theme.label(shell,"Eyebrow",Text.Eyebrow,UDim2.fromOffset(24,14),UDim2.new(1,-130,0,18),11,Color.silver)
	local title = Theme.label(shell,"Title",Text.Title,UDim2.fromOffset(24,35),UDim2.new(1,-140,0,35),26,Color.gold)
	title.Font = Enum.Font.GothamBlack
	local close = Theme.button(shell,"CloseBag","X",UDim2.new(1,-68,0,18),UDim2.fromOffset(44,44))
	close.Caption.Text = ""; Theme.icon(close,"close",UDim2.fromOffset(5,5),UDim2.fromOffset(34,34))
	local gear = Theme.button(shell,"ViewEquipment",Text.ViewGear,UDim2.fromOffset(20,78),UDim2.fromOffset(156,40))
	local organize = Theme.button(shell,"Organize",Text.Organize,UDim2.fromOffset(184,78),UDim2.fromOffset(144,40))
	local heroLabel = Theme.label(shell,"HeroName","",UDim2.fromOffset(344,78),UDim2.new(1,-368,0,40),14,Color.silver)
	local filters = Instance.new("Frame"); filters.Name="Filters"; filters.BackgroundTransparency=1; filters.Parent=shell
	local filterButtons = {}
	for index, category in ipairs({"All","Equipment","Consumables","Materials"}) do
		filterButtons[category] = Theme.button(filters,"Filter_"..category,Text[category],UDim2.new(),UDim2.new())
	end
	local search = Instance.new("TextBox")
	search.Name,search.PlaceholderText,search.Text = "ItemSearch",Text.Search,""
	search.BackgroundColor3,search.TextColor3,search.PlaceholderColor3=Color.ink,Color.text,Color.muted
	search.Font,search.TextSize,search.ClearTextOnFocus=Enum.Font.GothamMedium,14,false
	search.Parent=shell
	local sort = Theme.button(shell,"SortItems","SORT: NAME",UDim2.new(),UDim2.fromOffset(130,40))
	local content = Instance.new("Frame"); content.Name="Content"; content.BackgroundTransparency=1; content.Parent=shell
	local function list(name)
		local panel=Theme.frame(content,name,UDim2.new(),UDim2.new())
		local heading=Theme.label(panel,"Heading","",UDim2.fromOffset(14,10),UDim2.new(1,-28,0,25),13,Color.gold)
		local scroll=Instance.new("ScrollingFrame")
		scroll.Name,scroll.Position,scroll.Size="Items",UDim2.fromOffset(12,43),UDim2.new(1,-24,1,-55)
		scroll.BackgroundTransparency,scroll.BorderSizePixel,scroll.ScrollBarThickness=1,0,4
		scroll.ScrollBarImageColor3,scroll.AutomaticCanvasSize,scroll.CanvasSize=Color.gold,Enum.AutomaticSize.Y,UDim2.new()
		scroll.ScrollingDirection=Enum.ScrollingDirection.Y; scroll.Parent=panel
		local grid=Instance.new("UIGridLayout"); grid.CellPadding=UDim2.fromOffset(8,8); grid.SortOrder=Enum.SortOrder.LayoutOrder; grid.Parent=scroll
		local empty=Theme.label(panel,"Empty",Text.Empty,UDim2.fromOffset(20,70),UDim2.new(1,-40,0,80),15,Color.muted)
		return {panel=panel,heading=heading,scroll=scroll,grid=grid,empty=empty}
	end
	local bag,storage = list("BagItems"),list("StorageItems")
	local details=Theme.frame(content,"ItemDetails",UDim2.new(),UDim2.new())
	local detailScroll=Instance.new("ScrollingFrame")
	detailScroll.Name,detailScroll.Position,detailScroll.Size="Description",UDim2.fromOffset(16,14),UDim2.new(1,-32,1,-88)
	detailScroll.BackgroundTransparency,detailScroll.BorderSizePixel,detailScroll.ScrollBarThickness=1,0,4
	detailScroll.AutomaticCanvasSize,detailScroll.CanvasSize,detailScroll.ScrollingDirection=Enum.AutomaticSize.Y,UDim2.new(),Enum.ScrollingDirection.Y
	detailScroll.Parent=details
	local primary=Theme.button(details,"PrimaryAction",Text.Equip,UDim2.new(0,16,1,-64),UDim2.new(1,-32,0,46),true)
	local message=Theme.label(shell,"InventoryMessage",Text.Loading,UDim2.new(0,24,1,-60),UDim2.new(1,-48,0,32),13,Color.silver)
	local mode=Theme.label(shell,"SaveMode",Text.Session,UDim2.new(0,24,1,-25),UDim2.new(1,-48,0,18),10,Color.muted)
	local retry=Theme.button(shell,"RetryRequest",Text.Retry,UDim2.new(1,-212,1,-66),UDim2.fromOffset(188,42))
	retry.Visible=false
	local bagTab=Theme.button(shell,"BagTab",Text.BagTab,UDim2.new(),UDim2.new())
	local storageTab=Theme.button(shell,"StorageTab",Text.StorageTab,UDim2.new(),UDim2.new())
	local pendingButton=Theme.button(shell,"OpenPending",Text.Pending,UDim2.new(),UDim2.new()); pendingButton.Visible=false
	local snapshot,remote,pending,selectedId,accessorySlot,actionForSelection,quantityBox
	local opened,storageMode,gearMode,organizing,mobileDetail=false,false,false,false,false
	local category,sourceTab,sortMode="All","bag","Name"
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
		opened=value; shade.Visible=value; launcher.Visible=not value
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
	local function choose(item)
		selectedId,accessorySlot,quantity=item.instanceId,nil,1
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
		clearChildren(detailScroll)
		actionForSelection,quantityBox=nil,nil
		local y=0
		if compact then
			local back=Theme.button(detailScroll,"BackToItems","BACK TO ITEMS",UDim2.fromOffset(0,0),UDim2.new(1,-6,0,40))
			back.Activated:Connect(function() mobileDetail=false; resize() end); y=50
		end
		local item=getSelected()
		if not item then
			detailLabel("Prompt",snapshot and not snapshot.heroId and Text.SelectHero or Text.SelectItem,y,50,22,Color.gold)
			detailLabel("Hint",Text.SelectHint,y+58,100,14,Color.muted)
			primary.Visible=false; return
		end
		local def=Catalog.items[item.definitionId]
		local hero=snapshot.heroes[snapshot.heroId]
		local classText=def.classId and string.format(Text.Class,Catalog.classes[def.classId]) or Text.Compatible
		detailLabel("ItemName",def.name,y,60,22,Color.gold).Font=Enum.Font.GothamBold; y=y+64
		detailLabel("Rarity",string.upper(def.rarity).."  •  "..string.upper(def.category),y,24,11,Color.silver); y=y+28
		detailLabel("Requirements",classText.."\n"..string.format(Text.Level,def.level or 1),y,46,13,Color.muted); y=y+52
		detailLabel("Binding",(item.binding=="character" and Text.CharacterBound or Text.Bound)..(item.locked and "  •  "..Text.Locked or ""),y,26,11,Color.gold); y=y+32
		if def.slot then
			if def.slot=="accessory" and item.location.kind=="bag" and not storageMode then
				detailLabel("ChooseSlot",Text.ChooseAccessory,y,36,13,Color.silver); y=y+40
				for index=1,2 do
					local slot="accessory"..index
					local button=Theme.button(detailScroll,"Choose_"..slot,(accessorySlot==slot and "[X] " or "")..Text["Accessory"..index],UDim2.new((index-1)*.5,0,0,y),UDim2.new(.5,-5,0,42))
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
		detailLabel("DescriptionText",def.description,y,70,13,Color.muted); y=y+76
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
			quantityBox.FocusLost:Connect(function() quantity=tonumber(quantityBox.Text) end)
			y=y+52
		end
		if def.restore and loc=="bag" and not storageMode then
			for index=1,2 do
				local button=Theme.button(detailScroll,"AssignQuick"..index,Text[index==1 and "AssignZ" or "AssignC"],UDim2.new((index-1)*.5,0,0,y),UDim2.new(.5,-5,0,42))
				button.Activated:Connect(function() command("Assign",index) end)
				Theme.enabled(button,not pending and snapshot.ready and snapshot.safe)
			end
			y=y+50
		end
		if organizing and loc=="bag" then
			local lock=Theme.button(detailScroll,"ToggleLock",item.locked and Text.Unlock or Text.Lock,UDim2.fromOffset(0,y),UDim2.new(1,-6,0,42))
			lock.Activated:Connect(function() command("Lock") end); Theme.enabled(lock,not pending and snapshot.ready); y=y+50
		end
		detailLabel("StatsNotice",Text.StatsHint,y,55,11,Color.muted)
		primary.Visible=actionForSelection~=nil
		if actionForSelection then
			primary.Caption.Text=Text[actionForSelection]
			local enabled=not pending and snapshot.ready and hero~=nil
			if actionForSelection~="Use" then enabled=enabled and snapshot.safe end
			if actionForSelection=="Deposit" or actionForSelection=="Withdraw" then enabled=enabled and snapshot.atStorage end
			if actionForSelection=="Claim" then enabled=enabled and snapshot.atHub end
			if actionForSelection=="Equip" then enabled=enabled and (not def.classId or hero.baseClassId==def.classId) and hero.level>=(def.level or 1) and (def.slot~="accessory" or accessorySlot~=nil) end
			Theme.enabled(primary,enabled==true)
		end
	end
	local function renderList(view,kind)
		clearChildren(view.scroll,"GuiObject")
		local items={}
		for _, item in ipairs(snapshot and snapshot.items or {}) do
			local def=Catalog.items[item.definitionId]
			if item.location.kind==kind and (kind~="bag" and kind~="equipped" or item.location.heroId==snapshot.heroId)
				and (gearMode or category=="All" or def.category==category)
				and (search.Text=="" or string.find(string.lower(def.name),string.lower(search.Text),1,true)) then table.insert(items,item) end
		end
		table.sort(items,function(a,b)
			local ad,bd=Catalog.items[a.definitionId],Catalog.items[b.definitionId]
			if sortMode=="Level" and (ad.level or 1)~=(bd.level or 1) then return (ad.level or 1)>(bd.level or 1) end
			if ad.name~=bd.name then return ad.name<bd.name end
			return a.instanceId<b.instanceId
		end)
		view.empty.Visible=#items==0
		if gearMode and kind=="equipped" then
			local ordered={}
			for _, slot in ipairs(Catalog.slots) do
				local equipped
				for _, item in ipairs(items) do if item.location.slot==slot then equipped=item end end
				ordered[#ordered+1]=equipped or {emptySlot=slot,instanceId="empty_"..slot}
			end
			items=ordered; view.empty.Visible=false
		end
		for index,item in ipairs(items) do
			local def=not item.emptySlot and Catalog.items[item.definitionId]
			local card=Instance.new("TextButton")
			card.Name,card.LayoutOrder,card.Text="Item_"..item.instanceId,index,""
			card.BackgroundColor3,card.BorderSizePixel,card.Selectable=Color.ink,0,true
			card.AutoButtonColor=false; card.Parent=view.scroll
			local art=Theme.sprite(card,"ItemFrame","portrait",UDim2.new(),UDim2.fromScale(1,1)); art.SliceScale=.22
			local border=Instance.new("UIStroke"); border.Color=selectedId==item.instanceId and Color.gold or Color.silver; border.Transparency=selectedId==item.instanceId and 0 or .65; border.Thickness=selectedId==item.instanceId and 2 or 1; border.Parent=card
			local glyph=Theme.label(card,"ItemGlyph",def and def.glyph or "—",UDim2.fromOffset(8,8),UDim2.new(1,-16,0,38),24,def and def.rarity=="Uncommon" and Color.green or Color.gold)
			glyph.TextXAlignment,glyph.Font=Enum.TextXAlignment.Center,Enum.Font.GothamBlack
			if def and def.classId then
				glyph.TextSize,glyph.TextXAlignment=11,Enum.TextXAlignment.Right
				Theme.icon(card,({knight="swordsman",elf="archer",dwarf="axe",mage="arcanist"})[def.classId],UDim2.new(.5,-22,0,6),UDim2.fromOffset(44,44))
			end
			local name=Theme.label(card,"ItemName",def and def.name or Text.Slots[item.emptySlot],UDim2.fromOffset(8,49),UDim2.new(1,-16,0,38),12,Color.text)
			name.TextXAlignment=Enum.TextXAlignment.Center
			local flag=item.emptySlot and "EMPTY" or item.location.kind=="equipped" and Text.Slots[item.location.slot]
				or item.quantity>1 and "x"..item.quantity or def.classId and Catalog.classes[def.classId] or "Lv "..(def.level or 1)
			if item.locked then flag=Text.Locked.."  "..flag end
			local status=Theme.label(card,"ItemStatus",flag,UDim2.new(0,7,1,-24),UDim2.new(1,-14,0,18),10,Color.silver)
			status.TextXAlignment=Enum.TextXAlignment.Center
			card.Activated:Connect(function() if not item.emptySlot then choose(item) end end)
		end
	end
	render=function()
		if not opened then return end
		local focus=GuiService.SelectedObject
		local focusName=focus and focus:IsDescendantOf(gui) and focus.Name
		local hero=snapshot and snapshot.heroes[snapshot.heroId]
		heroLabel.Text=hero and Catalog.classes[hero.baseClassId].."  •  LV "..hero.level or ""
		title.Text=storageMode and Text.StorageTitle or gearMode and Text.EquipmentTitle or Text.Title
		mode.Text=snapshot and not snapshot.sessionOnly and Text.Saved or Text.Session
		gear.Caption.Text=gearMode and Text.ViewBag or Text.ViewGear
		organize.Caption.Text=organizing and Text.Done or Text.Organize
		bag.heading.Text=gearMode and Text.EquipmentTitle or sourceTab=="pending" and Text.Pending or snapshot and string.format(Text.BagCount,snapshot.bagUsed,snapshot.bagCapacity) or Text.BagTab
		storage.heading.Text=snapshot and string.format(Text.StorageCount,snapshot.storageUsed,snapshot.storageCapacity) or Text.StorageTab
		for key,button in pairs(filterButtons) do button.TDButtonArt.ImageColor3=key==category and Color3.fromRGB(150,205,255) or Color3.new(1,1,1) end
		if gearMode then renderList(bag,"equipped")
		elseif sourceTab=="pending" then renderList(bag,"pending")
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
		compact=width<820
		title.TextSize=compact and 20 or 26
		shell.Eyebrow.Visible=width>=500
		heroLabel.Visible=width>=650
		local tabs=storageMode or sourceTab=="pending"
		local top=organizing and 218 or 168
		if tabs then top=top+48 end
		filters.Position,filters.Size=UDim2.fromOffset(20,122),UDim2.new(1,-40,0,38)
		local fw=math.max(1,(width-58)/4)
		local index=0
		for _,name in ipairs({"All","Equipment","Consumables","Materials"}) do
			local button=filterButtons[name]
			button.Position,button.Size=UDim2.fromOffset(index*(fw+6),0),UDim2.fromOffset(fw,38)
			button.Caption.TextSize=width<500 and 10 or 12; index=index+1
		end
		search.Visible,sort.Visible=organizing,organizing
		search.Position,search.Size=UDim2.fromOffset(20,166),UDim2.new(1,-180,0,40)
		sort.Position=UDim2.new(1,-150,0,166)
		content.Position,content.Size=UDim2.fromOffset(20,top),UDim2.new(1,-40,1,-top-76)
		local tabY=organizing and 212 or 164
		bagTab.Visible,storageTab.Visible=tabs,storageMode
		bagTab.Position,bagTab.Size=UDim2.fromOffset(20,tabY),UDim2.fromOffset(152,40)
		storageTab.Position,storageTab.Size=UDim2.fromOffset(180,tabY),UDim2.fromOffset(164,40)
		pendingButton.Position,pendingButton.Size=UDim2.new(1,-236,0,78),UDim2.fromOffset(212,40)
		pendingButton.Visible=snapshot~=nil and snapshot.pending>0
		if compact then
			pendingButton.Position,pendingButton.Size=UDim2.new(1,-166,0,18),UDim2.fromOffset(90,44)
			pendingButton.Caption.Text="CLAIMS "..tostring(snapshot and snapshot.pending or 0)
			pendingButton.Caption.TextSize=10
			title.Size=UDim2.new(1,pendingButton.Visible and -196 or -100,0,35)
		end
		local cw=width-40
		if compact then
			bag.panel.Position,bag.panel.Size=UDim2.new(),UDim2.fromScale(1,1)
			storage.panel.Position,storage.panel.Size=UDim2.new(),UDim2.fromScale(1,1)
			details.Position,details.Size=UDim2.new(),UDim2.fromScale(1,1)
			bag.panel.Visible=not mobileDetail and (not storageMode or sourceTab~="storage")
			storage.panel.Visible=not mobileDetail and storageMode and sourceTab=="storage"
			details.Visible=mobileDetail
		else
			local detailWidth=300
			local listWidth=cw-detailWidth-12
			local dual=storageMode and sourceTab~="pending"
			bag.panel.Position,bag.panel.Size=UDim2.new(),UDim2.fromOffset(dual and (listWidth-10)/2 or listWidth,content.AbsoluteSize.Y)
			storage.panel.Position,storage.panel.Size=UDim2.fromOffset((listWidth+10)/2,0),UDim2.fromOffset((listWidth-10)/2,content.AbsoluteSize.Y)
			details.Position,details.Size=UDim2.new(1,-detailWidth,0,0),UDim2.new(0,detailWidth,1,0)
			bag.panel.Visible,storage.panel.Visible,details.Visible=true,dual,true
		end
		for _,view in ipairs({bag,storage}) do
			local available=math.max(80,view.panel.AbsoluteSize.X-32)
			local columns=math.max(1,math.floor((available+8)/116))
			view.grid.CellSize=UDim2.fromOffset(math.floor((available-(columns-1)*8)/columns),116)
		end
		if width<380 then
			gear.Size,organize.Size=UDim2.fromOffset(140,40),UDim2.fromOffset(134,40); organize.Position=UDim2.fromOffset(168,78)
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
	retry.Activated:Connect(function() if pending and remote then remote:FireServer(pending); setMessage(Text.Waiting) end end)
	launcher.Activated:Connect(function() storageMode,sourceTab=false,"bag"; setOpen(true) end)
	close.Activated:Connect(function() setOpen(false) end)
	gear.Activated:Connect(function() gearMode=not gearMode; storageMode=false; sourceTab="bag"; mobileDetail=false; resize(); render() end)
	organize.Activated:Connect(function() organizing=not organizing; resize(); render() end)
	bagTab.Activated:Connect(function() sourceTab="bag"; mobileDetail=false; resize(); render() end)
	storageTab.Activated:Connect(function() sourceTab="storage"; mobileDetail=false; resize(); render() end)
	pendingButton.Activated:Connect(function() sourceTab="pending"; gearMode=false; mobileDetail=false; resize(); render() end)
	for key,button in pairs(filterButtons) do button.Activated:Connect(function() category=key; gearMode=false; mobileDetail=false; resize(); render() end) end
	search:GetPropertyChangedSignal("Text"):Connect(function() render() end)
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
			if completed then
				if errorCode=="SaveUnknown" then retry.Visible=true
				else pending=nil; retry.Visible=false; message.Size=UDim2.new(1,-48,0,32) end
			end
			resize()
			if changed then render() else renderDetails() end
			if errorCode then setMessage(Text.Errors[errorCode] or Text.Errors.Unavailable,true)
			elseif completed and not pending then setMessage(Text.SavedAction) end
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
