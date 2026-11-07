-- Landscape-only detail view. The lobby/battle launchers remain unchanged.
local Shared=game:GetService('ReplicatedStorage').Shared
local Theme=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Artwork=require(script.Parent.ItemArtwork)
local Growth=require(Shared.HeroProgression)
local Preview=require(Shared.SkillStatPreview)
local Config=require(Shared.K0Config)
local Catalog=require(Shared.ItemCatalog)
local Text=require(Shared.CombatStatText)
local SkillText=require(Shared.SkillStatText)
local InventoryText=require(Shared.InventoryText)
local Navigation=require(Shared.NavigationText)
local Investment=require(script.Parent.StatInvestmentPreview)
local TextService=game:GetService('TextService')
local View={}
local portraits={knight='103255177842108',elf='80894238854345',dwarf='74628903359757',mage='91907986271282'}
local symbols={STR='damage',DEX='range',INT='emblemDetails',VIT='support'}
local function number(value) return string.format('%.3f',value):gsub('0+$',''):gsub('%.$','') end
local function signed(value) return (value>=0 and '+' or '')..number(value) end
local function frame(parent,name,x,y,w,h)
 return Menu.frame(parent,name,UDim2.fromOffset(x,y),UDim2.fromOffset(w,h))
end
local function button(parent,name,text,x,y,w,callback,enabled,primary)
 local b=Theme.button(parent,name,text,UDim2.fromOffset(x,y),UDim2.fromOffset(w,44),primary)
 b.Caption.Position=UDim2.fromOffset(4,2);b.Caption.Size=UDim2.new(1,-8,1,-4);b.Caption.TextSize=12
 Theme.enabled(b,enabled~=false)
 b.Activated:Connect(function() if b.Active then callback() end end)
 return b
end
function View.render(body,hero,snapshot,derived,draft,pending,redraw,send,resetDraft,retry,state)
 local width,height=body.AbsoluteSize.X-8,math.max(120,body.AbsoluteSize.Y-2)
 local section=state.section or 'Combat'
 local g,classId=hero.progression,hero.baseClassId
 local spent=0;for _,v in pairs(draft) do spent+=v end
 local editable=snapshot.ready and (snapshot.atHub or snapshot.canInvest) and not pending
 local points=Growth.points(g)
 local sideW=math.clamp(math.floor(width*.21),112,172)
 local mainX,mainW=sideW+16,width-sideW-20
 local side=frame(body,'MobileHero',4,4,sideW,height-8)
 local showIdentity=height>=244
 local portrait=Instance.new('ImageLabel');portrait.Name='HeroPortrait';portrait.BackgroundTransparency=1;portrait.Position=UDim2.fromOffset(6,4);portrait.Size=UDim2.fromOffset(32,32);portrait.Image='rbxassetid://'..portraits[classId];portrait.ScaleType=Enum.ScaleType.Crop;portrait.Visible=showIdentity;portrait.Parent=side
 local identity=Theme.label(side,'Identity',Catalog.classes[classId]..' / Lv. '..g.level,UDim2.fromOffset(42,0),UDim2.new(1,-48,0,40),11,Theme.color.gold);identity.Visible=showIdentity
 for i,entry in ipairs(Navigation.mobileStatSections) do
  local twoColumns=height<196
  local tabW=twoColumns and (sideW-12)/2 or sideW-8
  local tabX=8+(twoColumns and (i-1)%2*(tabW+4) or 0)
  local tabY=(showIdentity and 48 or 4)+(twoColumns and math.floor((i-1)/2) or i-1)*48
  local b=button(body,'Section'..entry.id,entry.id=='Points' and (entry.label..' '..(points-spent)) or entry.label,tabX,tabY,tabW,function() state.section=entry.id;state.scrollY=0;redraw() end,true,section==entry.id)
  if twoColumns then b.Caption.TextSize=10 end
  b:SetAttribute('Selected',section==entry.id)
 end
 local hasFooter=pending or section=='Points' or section=='Combat'
 local scroll=Instance.new('ScrollingFrame');scroll.Name='MobileDetail';scroll.Position=UDim2.fromOffset(mainX,4);scroll.Size=UDim2.fromOffset(mainW,math.max(24,height-(hasFooter and 54 or 8)));scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=4;scroll.ScrollingDirection=Enum.ScrollingDirection.Y;scroll.CanvasPosition=Vector2.new(0,state.scrollY or 0);scroll.Parent=body
 scroll:GetPropertyChangedSignal('CanvasPosition'):Connect(function() state.scrollY=scroll.CanvasPosition.Y end)
 local top=0
 local function label(parent,name,text,x,y,w,h,size,color)
  return Theme.label(parent,name,text,UDim2.fromOffset(x,y),UDim2.fromOffset(w,h),size,color)
 end
 local function measured(text,size,w)
  return math.ceil(TextService:GetTextSize(text,size,Enum.Font.GothamMedium,Vector2.new(w,10000)).Y)+6
 end
 if section=='Combat' then
  top=0
  local after=Growth.copy(g);for key,v in pairs(draft) do after.stats[key]+=v end
  local basicText=Preview.basicAttackText(classId,g,snapshot.stats,spent>0 and after or nil)
  local basicHeight=measured(basicText,12,mainW-8)
  label(scroll,'BasicDamage',basicText,4,top,mainW-8,basicHeight,12,Theme.color.gold)
  top+=basicHeight+8
  local entries=Preview.breakdown(classId,g,snapshot.stats,spent>0 and after or nil)
  local columns=mainW>=480 and 3 or 2
  local cellW=(mainW-8-(columns-1)*6)/columns
  local rowH=spent>0 and 68 or 46
  for i,entry in ipairs(entries) do
   local x=4+((i-1)%columns)*(cellW+6);local y=top+math.floor((i-1)/columns)*(rowH+4)
   local row=Instance.new('Frame');row.Name=entry.key;row.Position=UDim2.fromOffset(x,y);row.Size=UDim2.fromOffset(cellW,rowH);row.BackgroundColor3=Theme.color.ink;row.BackgroundTransparency=.15;row.BorderSizePixel=0;row.Parent=scroll
   label(row,'Name',Text.Labels[entry.key],6,0,cellW*.60-6,24,11,Theme.color.text)
   local total=label(row,'Total',number(entry.total),cellW*.60,0,cellW*.40-6,24,17,Theme.color.gold);total.TextXAlignment=Enum.TextXAlignment.Right
   label(row,'Breakdown',string.format(Text.HeroAndGear,number(entry.hero),signed(entry.gear)),6,24,cellW-12,20,11,Theme.color.silver)
   if entry.draft then label(row,'Draft',string.format(Text.Draft,number(entry.total),number(entry.draft),signed(entry.draft-entry.total)),6,44,cellW-12,22,11,Theme.color.green) end
  end
  top+=math.ceil(#entries/columns)*(rowH+4)
  local bonus=string.format(Text.AttackBonus,signed((snapshot.stats or {}).power or 0))
  label(scroll,'AttackBonus',bonus,4,top,mainW-8,22,12,Theme.color.green);top+=26
  if state.gearExpanded then
   local sources=Preview.gearSources(hero.heroId,snapshot.items,Catalog)
   if #sources==0 then label(scroll,'NoGear',Text.NoGear,4,top,mainW-8,26,12,Theme.color.muted);top+=30 end
   for _,source in ipairs(sources) do
    local text=string.format(Text.GearItem,InventoryText.Slots[source.slot],source.name)
    local parts={}
    for _,entry in ipairs({{'power',Text.GearPower},{'armor',Text.GearArmor},{'health',Text.GearHealth}}) do local v=source.stats[entry[1]] or 0;if v~=0 then table.insert(parts,string.format(entry[2],signed(v))) end end
    text..='\n'..(#parts>0 and table.concat(parts,' · ') or Text.NoBonus)
    local h=measured(text,12,mainW-8);label(scroll,'Gear_'..source.slot,text,4,top,mainW-8,h,12,Theme.color.silver);top+=h+6
   end
  end
  local h=measured(Text.HeroNote..'\n'..Text.DefenseNote,11,mainW-8)
  label(scroll,'CombatNotes',Text.HeroNote..'\n'..Text.DefenseNote,4,top,mainW-8,h,11,Theme.color.muted);top+=h
 elseif section=='Points' then
  top=0
  local w=(mainW-14)/2
  for i,key in ipairs(Growth.statKeys) do
   local x=4+((i-1)%2)*(w+6);local y=top+math.floor((i-1)/2)*50
   local row=Instance.new('Frame');row.Name=key;row.Position=UDim2.fromOffset(x,y);row.Size=UDim2.fromOffset(w,46);row.BackgroundColor3=Theme.color.ink;row.BackgroundTransparency=.15;row.BorderSizePixel=0;row.Parent=scroll
   local icon=Theme.sprite(row,'StatIcon',symbols[key],UDim2.fromOffset(3,7),UDim2.fromOffset(30,30))
   local textX=w>=240 and 36 or 6;icon.Visible=w>=240
   label(row,'Value',key..'  '..derived.totalStats[key],textX,0,w-textX-102,24,13,Theme.color.text)
   label(row,'Meaning','DRAFT +'..draft[key],textX,24,w-textX-102,20,11,Theme.color.silver)
   button(row,'Minus','−',w-96,1,44,function() draft[key]-=1;redraw() end,editable and draft[key]>0)
   button(row,'Plus','+',w-48,1,44,function() draft[key]+=1;redraw() end,editable and points>spent)
  end
  top+=100
  top+=Investment.render(scroll,hero,snapshot,draft,4,top,mainW-8)+8
  for _,key in ipairs(Growth.statKeys) do
   local text=key..' · '..Preview.statHint(classId,key,g);local h=measured(text,11,mainW-8)
   label(scroll,'Hint'..key,text,4,top,mainW-8,h,11,Theme.color.muted);top+=h+2
  end
  local h=measured(SkillText.StatNote,11,mainW-8);label(scroll,'StatNote',SkillText.StatNote,4,top,mainW-8,h,11,Theme.color.muted);top+=h
 elseif section=='Gear' then
  local columns=4;local w=(mainW-26)/columns
  for i,slot in ipairs(Catalog.slots) do
   local x=4+((i-1)%columns)*(w+6);local y=math.floor((i-1)/columns)*78
   local cell=frame(scroll,'EquipSlot_'..slot,x,y,w,52)
   local item
   for _,candidate in ipairs(snapshot.items or {}) do if candidate.location.kind=='equipped' and candidate.location.heroId==hero.heroId and candidate.location.slot==slot then item=candidate;break end end
   cell:SetAttribute('DefinitionId',item and item.definitionId or '')
   if item then Artwork.create(cell,Catalog.items[item.definitionId],UDim2.fromOffset(5,5),UDim2.new(1,-10,1,-10)) end
   label(scroll,'SlotName_'..slot,InventoryText.Slots[slot],x,y+54,w,20,11,Theme.color.silver)
  end
  top=156
 else
  local after=Growth.copy(g);for key,v in pairs(draft) do after.stats[key]+=v end
  local noteH=measured(SkillText.PreviewNote,11,mainW-8)
  label(scroll,'PreviewNote',SkillText.PreviewNote,4,top,mainW-8,noteH,11,Theme.color.muted);top+=noteH+6
  for _,entry in ipairs(Preview.equipped(g,classId)) do
   local skill=Config.Skills[classId][entry.index]
   local title=entry.slot==0 and string.format(SkillText.Ultimate,skill.name) or string.format(SkillText.SkillSlot,entry.slot,skill.name)
   local text=Preview.scalingText(classId,skill)..'\n'..Preview.effectText(classId,entry.index,g,snapshot.stats,spent>0 and after or nil)
   local titleH=measured(title,12,mainW-24);local textH=measured(text,12,mainW-24)
   local row=frame(scroll,'SkillPreview'..entry.slot,4,top,mainW-8,titleH+textH+16)
   label(row,'SkillName',title,8,4,mainW-24,titleH,12,Theme.color.gold)
   label(row,'Estimate',text,8,titleH+6,mainW-24,textH,12,Theme.color.text)
   top+=titleH+textH+24
  end
 end
 scroll.CanvasSize=UDim2.fromOffset(0,top+8)
 local footerY=height-44
 if pending then button(body,'RetrySave','RETRY SAVE',mainX,footerY,mainW,retry,true)
 elseif section=='Points' then
  local w=(mainW-6)/2
  button(body,'CancelDraft','CANCEL DRAFT',mainX,footerY,w,function() resetDraft();redraw() end,true)
  button(body,'ApplyPoints','CONFIRM',mainX+w+6,footerY,w,function() send('AllocateStats',{stats=Growth.copy(draft)}) end,editable and spent>0,true)
 elseif section=='Combat' then
  button(body,'GearDetails',state.gearExpanded and Text.HideGear or Text.ShowGear,mainX,footerY,mainW,function() state.gearExpanded=not state.gearExpanded;redraw() end,true)
 end
 body.ScrollingEnabled=false
 return height
end
return View
