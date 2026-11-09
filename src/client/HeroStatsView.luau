local RS=game:GetService('ReplicatedStorage')
local Menu=require(script.Parent.HeroMenuChrome)
local Theme=require(script.Parent.TDInventoryTheme)
local Artwork=require(script.Parent.ItemArtwork)
local Glyph=require(script.Parent.SkillGlyph)
local Catalog=require(RS.Shared.ItemCatalog)
local Text=require(RS.Shared.InventoryText)
local Growth=require(RS.Shared.HeroProgression)
local GrowthText=require(RS.Shared.K0Text)
local Preview=require(RS.Shared.SkillStatPreview)
local SkillText=require(RS.Shared.SkillStatText)
local Config=require(RS.Shared.K0Config)
local Navigation=require(RS.Shared.NavigationText)
local MobileView=require(script.Parent.MobileHeroStatsView)
local CombatStats=require(script.Parent.CombatStatsView)
local CombatText=require(RS.Shared.CombatStatText)
local Investment=require(script.Parent.StatInvestmentPreview)
local TextService=game:GetService('TextService')
local View={}
local portraits={knight='103255177842108',elf='80894238854345',dwarf='74628903359757',mage='91907986271282'}
local full={STR='Strength',DEX='Dexterity',INT='Intelligence',VIT='Vitality'}
function View.render(body,hero,snapshot,derived,draft,pending,redraw,send,resetDraft,openBag,statState)
 statState=statState or {}
 if statState.mobile and body.AbsoluteSize.X>=480 and body.AbsoluteSize.X>body.AbsoluteSize.Y then return MobileView.render(body,hero,snapshot,derived,draft,pending,redraw,send,resetDraft,openBag,statState) end
 local mobile=statState.mobile==true
 local section=statState.section or 'Combat'
 local width=math.max(240,body.AbsoluteSize.X-8);local narrow=mobile or width<760
 local top=mobile and 56 or 52
 if mobile then
  for i,entry in ipairs(Navigation.mobileStatSections) do
   local w=(width-24)/4
   local button=Theme.button(body,'Section'..entry.id,entry.id=='Points' and (entry.label..' '..(Growth.points(hero.progression)-(draft.STR+draft.DEX+draft.INT+draft.VIT))) or entry.label,UDim2.fromOffset(4+(i-1)*(w+6),4),UDim2.fromOffset(w,44),section==entry.id)
   button.Caption.Position=UDim2.fromOffset(2,2);button.Caption.Size=UDim2.new(1,-4,1,-4);button.Caption.TextSize=12
   button:SetAttribute('Selected',section==entry.id)
   button.Activated:Connect(function() statState.section=entry.id;body.CanvasPosition=Vector2.zero;redraw() end)
  end
 end
 local function finish(height)
  if pending then
   local retry=Theme.button(body,'RetrySave','RETRY SAVE',UDim2.fromOffset(12,height),UDim2.fromOffset(width-24,44));retry.Activated:Connect(openBag);height+=54
  end
  return height+12
 end
 local g,classId=hero.progression,hero.baseClassId
 local points=Growth.points(g);local spent=0;for _,v in pairs(draft) do spent+=v end
 if not mobile then
  local available=Menu.plaque(body,'AvailableStatPoints',string.format(CombatText.AvailablePoints,points-spent),UDim2.fromOffset(4,4),UDim2.fromOffset(width-8,40))
  available.Caption.TextSize=16
 end
 local editable=snapshot.ready and (snapshot.atHub or snapshot.canInvest) and not pending
 local threeColumn=not mobile and width>=960
 local leftW=threeColumn and math.floor(width*.24) or narrow and width-8 or math.floor(width*.48)
 local x=narrow and 4 or leftW+20
 local rw=threeColumn and math.floor(width*.35) or narrow and width-8 or width-x-4
 local allocationX=threeColumn and x+rw+16 or x
 local allocationW=threeColumn and width-allocationX-4 or rw
 local allocationHeight=threeColumn and 480 or 616
 local summaryHeight=0
 if not mobile or section=='Combat' then
  summaryHeight=CombatStats.render(body,hero,snapshot,draft,UDim2.fromOffset(x,top),rw,statState,redraw)
  if mobile then return finish(top+summaryHeight+8) end
  summaryHeight+=48
 end
 local short=narrow and body.AbsoluteSize.Y<260
 local allocationY=summaryHeight+24
 local leftY=mobile and top or narrow and (short and allocationY+636 or summaryHeight+24) or top
 if not mobile or section=='Gear' then
 local left=Menu.frame(body,'HeroEquipment',UDim2.fromOffset(4,leftY),UDim2.fromOffset(leftW,threeColumn and 450 or mobile and 430 or 560))
 local heading=Menu.plaque(left,'HeroTitle',string.upper(Catalog.classes[classId])..'  /  Lv. '..g.level,UDim2.fromOffset(10,10),UDim2.new(1,-20,0,46));heading.Caption.TextSize=mobile and 14 or 18
 local image=Instance.new('ImageLabel');image.Name='HeroPortrait';image.BackgroundTransparency=1;image.Position=UDim2.fromOffset(threeColumn and 48 or 70,66);image.Size=UDim2.new(1,threeColumn and -96 or -140,1,-116);image.Image='rbxassetid://'..portraits[classId];image.ScaleType=Enum.ScaleType.Crop;image.Parent=left
 local slotSize=threeColumn and 44 or narrow and 50 or 62
 for i,slot in ipairs(Catalog.slots) do
  local right=i>4;local row=(i-1)%4;local item
  for _,candidate in ipairs(snapshot.items or {}) do if candidate.location.kind=='equipped' and candidate.location.heroId==hero.heroId and candidate.location.slot==slot then item=candidate;break end end
  local cell=Menu.frame(left,'EquipSlot_'..slot,UDim2.new(right and 1 or 0,right and -slotSize-12 or 12,0,76+row*(threeColumn and 82 or mobile and 74 or 108)),UDim2.fromOffset(slotSize,slotSize))
  cell:SetAttribute('DefinitionId',item and item.definitionId or '')
  if item then Artwork.create(cell,Catalog.items[item.definitionId],UDim2.fromOffset(4,4),UDim2.new(1,-8,1,-8)) end
  local caption=Theme.label(cell,'SlotName',Text.Slots[slot],UDim2.new(0,-6,1,4),UDim2.new(1,12,0,26),9,Theme.color.silver);caption.TextXAlignment=Enum.TextXAlignment.Center
 end
 local xp=g.level==Growth.maxLevel and string.format(GrowthText.TotalXPMax,Growth.totalXP(g)) or string.format(GrowthText.TotalXP,Growth.totalXP(g),Growth.xpAtLevel(g.level+1))
 local xpLabel=Theme.label(left,'XP',xp,UDim2.new(0,12,1,-42),UDim2.new(1,-24,0,28),14,Theme.color.gold);xpLabel.TextXAlignment=Enum.TextXAlignment.Center
 if mobile then return finish(leftY+450) end
 end
 local y=threeColumn and top or mobile and top or narrow and (short and allocationY or leftY+580) or summaryHeight+24
 if not mobile or section=='Points' then
 local right=Menu.frame(body,'StatAllocation',UDim2.fromOffset(allocationX,y),UDim2.fromOffset(allocationW,allocationHeight))
 Theme.label(right,'Points',string.format(CombatText.AvailablePoints,points-spent),UDim2.fromOffset(18,12),UDim2.new(1,-36,0,36),16,Theme.color.gold)
 for i,key in ipairs(Growth.statKeys) do
  local rowY=(threeColumn and 52 or 62)+(i-1)*(threeColumn and 68 or 88)
  local row=Instance.new('Frame');row.Name=key;row.Position=UDim2.fromOffset(12,rowY);row.Size=UDim2.new(1,-24,0,threeColumn and 64 or 86);row.BackgroundColor3=Color3.fromRGB(6,24,47);row.BorderSizePixel=0;row.Parent=right
  local symbol=Menu.node(row,'StatSymbol','',UDim2.fromOffset(8,8),44,true,false)
  Glyph.draw(symbol,key=='STR' and 'dwarf' or key=='DEX' and 'elf' or key=='INT' and 'mage' or 'knight',{root=1},36,true)
  if mobile or threeColumn then symbol.Visible=false end
  local value=Theme.label(row,'Value',key..'  '..derived.totalStats[key],UDim2.fromOffset((mobile or threeColumn) and 12 or 64,0),UDim2.new(1,(mobile or threeColumn) and -126 or -174,0,32),mobile and 16 or 18,Theme.color.text)
  Theme.label(row,'Meaning',full[key]..'  '..Growth.bases[classId].stats[key]..' + '..g.stats[key]..' + '..draft[key]..(key=='DEX'and string.format(CombatText.GearDexSuffix,(snapshot.stats or {}).dexterity or 0)or ''),UDim2.fromOffset((mobile or threeColumn) and 12 or 64,threeColumn and 24 or 28),UDim2.new(1,(mobile or threeColumn) and -126 or -174,0,threeColumn and 20 or 26),10,Theme.color.silver)
  Theme.label(row,'EffectHint',Preview.statHint(classId,key,g),UDim2.fromOffset(12,threeColumn and 44 or 56),UDim2.new(1,-24,0,threeColumn and 20 or 28),threeColumn and 9 or 10,Theme.color.muted)
  local minus=Theme.button(row,'Minus','−',UDim2.new(1,-104,0,11),UDim2.fromOffset(44,44))
  local plus=Theme.button(row,'Plus','+',UDim2.new(1,-56,0,11),UDim2.fromOffset(44,44))
  Theme.enabled(minus,editable and draft[key]>0);Theme.enabled(plus,editable and points>spent)
  minus.Activated:Connect(function() if minus.Active then draft[key]-=1;redraw() end end)
  plus.Activated:Connect(function() if plus.Active then draft[key]+=1;redraw() end end)
 end
 local previewY=threeColumn and 330 or 426
 local previewHeight=Investment.render(right,hero,snapshot,draft,12,previewY,allocationW-24)
 local resourceY=previewY+previewHeight+12
 allocationHeight=resourceY+(threeColumn and 48 or 58)+84
 right.Size=UDim2.fromOffset(allocationW,allocationHeight)
 for i,entry in ipairs({{'MAX HP',derived.health,Color3.fromRGB(214,48,68)},{'MAX MP',derived.mana,Color3.fromRGB(61,148,255)}}) do
  local box=Menu.frame(right,'Resource'..i,UDim2.new((i-1)*.5,12,0,resourceY),UDim2.new(.5,-24,0,threeColumn and 48 or 58))
  Theme.label(box,'Value',entry[1]..'  '..entry[2],UDim2.fromOffset(10,2),UDim2.new(1,-20,0,24),12,entry[2]>0 and Theme.color.text or Theme.color.muted)
  local bar=Instance.new('Frame');bar.Position=UDim2.fromOffset(10,32);bar.Size=UDim2.new(1,-20,0,10);bar.BackgroundColor3=entry[2]>0 and entry[3] or Theme.color.ink;bar.BorderSizePixel=0;bar.Parent=box
 end
 local cancel=Theme.button(right,'CancelDraft','CANCEL DRAFT',UDim2.new(0,12,1,-64),UDim2.new(.5,-18,0,46))
 local apply=Theme.button(right,'ApplyPoints','CONFIRM',UDim2.new(.5,6,1,-64),UDim2.new(.5,-18,0,46),true)
 cancel.Caption.TextSize=12;Theme.enabled(apply,editable and spent>0)
 cancel.Activated:Connect(function() resetDraft();redraw() end)
 apply.Activated:Connect(function() if apply.Active then send('AllocateStats',{stats=Growth.copy(draft)}) end end)
 if not mobile and narrow and short then
  leftY=y+allocationHeight+20
  body.HeroEquipment.Position=UDim2.fromOffset(4,leftY)
 end
 end
 local bottom=mobile and (section=='Points' and y+allocationHeight+20 or top) or threeColumn and math.max(y+allocationHeight,top+summaryHeight-48,leftY+450)+20 or math.max(y+allocationHeight+20,leftY+580)
 local note=Theme.label(body,'StatNote',SkillText.StatNote,UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,50),11,Theme.color.muted)
 bottom+=58
 if pending then
  local retry=Theme.button(body,'RetrySave','RETRY SAVE',UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,44));retry.Activated:Connect(openBag);bottom+=54
 end
 if mobile and section=='Points' then return bottom+12 end
 local function measured(text,size,available)
  return math.ceil(TextService:GetTextSize(text,size,Enum.Font.GothamMedium,Vector2.new(available,10000)).Y)+6
 end
 local previewGrowth=Growth.copy(g)
 for key,value in pairs(draft) do previewGrowth.stats[key]+=value end
 Theme.label(body,'PreviewTitle',SkillText.PreviewTitle,UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,32),16,Theme.color.gold)
 bottom+=36
 local noteHeight=measured(SkillText.PreviewNote,11,width-24)
 Theme.label(body,'PreviewNote',SkillText.PreviewNote,UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,noteHeight),11,Theme.color.muted)
 bottom+=noteHeight+12
 for _,entry in ipairs(Preview.equipped(g,classId)) do
  local base=Config.Skills[classId][entry.index]
  local title=entry.slot==0 and string.format(SkillText.Ultimate,base.name) or string.format(SkillText.SkillSlot,entry.slot,base.name)
  local text=Preview.scalingText(classId,base)..'\n'..Preview.effectText(classId,entry.index,g,snapshot.stats,spent>0 and previewGrowth or nil)
  local titleHeight=measured(title,13,width-48)
  local textHeight=measured(text,12,width-48)
  local row=Menu.frame(body,'SkillPreview'..entry.slot,UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,titleHeight+textHeight+28))
  Theme.label(row,'SkillName',title,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,titleHeight),13,Theme.color.gold)
  Theme.label(row,'Estimate',text,UDim2.fromOffset(12,titleHeight+12),UDim2.new(1,-24,0,textHeight),12,Theme.color.text)
  bottom+=row.Size.Y.Offset+12
 end
 return bottom+12
end
return View
