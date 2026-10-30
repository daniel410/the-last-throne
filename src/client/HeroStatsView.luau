local RS=game:GetService('ReplicatedStorage')
local Menu=require(script.Parent.HeroMenuChrome)
local Theme=require(script.Parent.TDInventoryTheme)
local Artwork=require(script.Parent.ItemArtwork)
local Glyph=require(script.Parent.SkillGlyph)
local Catalog=require(RS.Shared.ItemCatalog)
local Text=require(RS.Shared.InventoryText)
local Growth=require(RS.Shared.HeroProgression)
local Preview=require(RS.Shared.SkillStatPreview)
local SkillText=require(RS.Shared.SkillStatText)
local Config=require(RS.Shared.K0Config)
local TextService=game:GetService('TextService')
local View={}
local portraits={knight='103255177842108',elf='80894238854345',dwarf='74628903359757',mage='91907986271282'}
local full={STR='Strength',DEX='Dexterity',INT='Intelligence',VIT='Vitality'}
function View.render(body,hero,snapshot,derived,draft,pending,redraw,send,resetDraft,openBag)
 local width=math.max(280,body.AbsoluteSize.X-8);local narrow=width<760
 local g,classId=hero.progression,hero.baseClassId
 local points=Growth.points(g);local spent=0;for _,v in pairs(draft) do spent+=v end
 local editable=snapshot.ready and (snapshot.atHub or snapshot.canInvest) and not pending
 local leftW=narrow and width-8 or math.floor(width*.48)
 local left=Menu.frame(body,'HeroEquipment',UDim2.fromOffset(4,4),UDim2.fromOffset(leftW,560))
 local heading=Menu.plaque(left,'HeroTitle',string.upper(Catalog.classes[classId])..'  /  Lv. '..g.level,UDim2.fromOffset(10,10),UDim2.new(1,-20,0,46));heading.Caption.TextSize=18
 local image=Instance.new('ImageLabel');image.Name='HeroPortrait';image.BackgroundTransparency=1;image.Position=UDim2.fromOffset(70,66);image.Size=UDim2.new(1,-140,1,-116);image.Image='rbxassetid://'..portraits[classId];image.ScaleType=Enum.ScaleType.Crop;image.Parent=left
 local slotSize=narrow and 50 or 62
 for i,slot in ipairs(Catalog.slots) do
  local right=i>4;local row=(i-1)%4;local item
  for _,candidate in ipairs(snapshot.items or {}) do if candidate.location.kind=='equipped' and candidate.location.heroId==hero.heroId and candidate.location.slot==slot then item=candidate;break end end
  local cell=Menu.frame(left,'EquipSlot_'..slot,UDim2.new(right and 1 or 0,right and -slotSize-12 or 12,0,76+row*108),UDim2.fromOffset(slotSize,slotSize))
  cell:SetAttribute('DefinitionId',item and item.definitionId or '')
  if item then Artwork.create(cell,Catalog.items[item.definitionId],UDim2.fromOffset(4,4),UDim2.new(1,-8,1,-8)) end
  local caption=Theme.label(cell,'SlotName',Text.Slots[slot],UDim2.new(0,-6,1,4),UDim2.new(1,12,0,26),9,Theme.color.silver);caption.TextXAlignment=Enum.TextXAlignment.Center
 end
 local xp=g.level==80 and 'XP MAX' or string.format('xp %d/%d',g.xp,Growth.xpToNext(g.level))
 local xpLabel=Theme.label(left,'XP',xp,UDim2.new(0,12,1,-42),UDim2.new(1,-24,0,28),14,Theme.color.gold);xpLabel.TextXAlignment=Enum.TextXAlignment.Center
 local x=narrow and 4 or leftW+24;local y=narrow and 584 or 4;local rw=narrow and width-8 or width-x-4
 local right=Menu.frame(body,'StatAllocation',UDim2.fromOffset(x,y),UDim2.fromOffset(rw,616))
 Theme.label(right,'Points','AVAILABLE STAT POINTS  '..(points-spent),UDim2.fromOffset(18,12),UDim2.new(1,-36,0,36),16,Theme.color.gold)
 for i,key in ipairs(Growth.statKeys) do
  local rowY=62+(i-1)*88
  local row=Instance.new('Frame');row.Name=key;row.Position=UDim2.fromOffset(12,rowY);row.Size=UDim2.new(1,-24,0,86);row.BackgroundColor3=Color3.fromRGB(6,24,47);row.BorderSizePixel=0;row.Parent=right
  local symbol=Menu.node(row,'StatSymbol','',UDim2.fromOffset(8,8),44,true,false)
  Glyph.draw(symbol,key=='STR' and 'dwarf' or key=='DEX' and 'elf' or key=='INT' and 'mage' or 'knight',{root=1},36,true)
  local value=Theme.label(row,'Value',key..'  '..derived.totalStats[key],UDim2.fromOffset(64,0),UDim2.new(1,-174,0,32),18,Theme.color.text)
  Theme.label(row,'Meaning',full[key]..'  '..Growth.bases[classId].stats[key]..' + '..g.stats[key]..' + '..draft[key],UDim2.fromOffset(64,28),UDim2.new(1,-174,0,26),10,Theme.color.silver)
  Theme.label(row,'EffectHint',Preview.statHint(classId,key,g),UDim2.fromOffset(12,56),UDim2.new(1,-24,0,28),10,Theme.color.muted)
  local minus=Theme.button(row,'Minus','−',UDim2.new(1,-104,0,11),UDim2.fromOffset(40,44))
  local plus=Theme.button(row,'Plus','+',UDim2.new(1,-56,0,11),UDim2.fromOffset(44,44))
  Theme.enabled(minus,editable and draft[key]>0);Theme.enabled(plus,editable and points>spent)
  minus.Activated:Connect(function() if minus.Active then draft[key]-=1;redraw() end end)
  plus.Activated:Connect(function() if plus.Active then draft[key]+=1;redraw() end end)
 end
 Theme.label(right,'Derived',string.format('POWER %d   MAGIC %d   ARMOR %d',math.floor(derived.physicalPower+.5),math.floor(derived.magicPower+.5),derived.armor),UDim2.fromOffset(18,426),UDim2.new(1,-36,0,28),12,Theme.color.silver)
 for i,entry in ipairs({{'MAX HP',derived.health,Color3.fromRGB(214,48,68)},{'MAX MP',derived.mana,Color3.fromRGB(61,148,255)}}) do
  local box=Menu.frame(right,'Resource'..i,UDim2.new((i-1)*.5,12,0,470),UDim2.new(.5,-24,0,58))
  Theme.label(box,'Value',entry[1]..'  '..entry[2],UDim2.fromOffset(10,2),UDim2.new(1,-20,0,24),12,entry[2]>0 and Theme.color.text or Theme.color.muted)
  local bar=Instance.new('Frame');bar.Position=UDim2.fromOffset(10,32);bar.Size=UDim2.new(1,-20,0,10);bar.BackgroundColor3=entry[2]>0 and entry[3] or Theme.color.ink;bar.BorderSizePixel=0;bar.Parent=box
 end
 local cancel=Theme.button(right,'CancelDraft','CANCEL DRAFT',UDim2.new(0,12,1,-64),UDim2.new(.5,-18,0,46))
 local apply=Theme.button(right,'ApplyPoints','CONFIRM',UDim2.new(.5,6,1,-64),UDim2.new(.5,-18,0,46),true)
 cancel.Caption.TextSize=12;Theme.enabled(apply,editable and spent>0)
 cancel.Activated:Connect(function() resetDraft();redraw() end)
 apply.Activated:Connect(function() if apply.Active then send('AllocateStats',{stats=Growth.copy(draft)}) end end)
 local bottom=y+636
 local note=Theme.label(body,'StatNote',SkillText.StatNote,UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,50),11,Theme.color.muted)
 bottom+=58
 if pending then
  local retry=Theme.button(body,'RetrySave','RETRY SAVE',UDim2.fromOffset(12,bottom),UDim2.fromOffset(width-24,44));retry.Activated:Connect(openBag);bottom+=54
 end
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
