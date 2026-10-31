-- Read-only saved combat totals, equipment sources and a separate unsaved preview.
local Shared=game:GetService('ReplicatedStorage').Shared
local TextService=game:GetService('TextService')
local Theme=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Preview=require(Shared.SkillStatPreview)
local Growth=require(Shared.HeroProgression)
local Catalog=require(Shared.ItemCatalog)
local Text=require(Shared.CombatStatText)
local InventoryText=require(Shared.InventoryText)
local View={}
local function number(value)
 return string.format('%.2f',value):gsub('0+$',''):gsub('%.$','')
end
local function signed(value) return (value>=0 and '+' or '')..number(value) end
function View.render(parent,hero,snapshot,draft,position,width,state,redraw)
 state=state or {}
 local panel=Menu.frame(parent,'CombatStats',position,UDim2.fromOffset(width,1))
 local available=width-24
 local function label(name,value,y,size,color)
  local height=math.ceil(TextService:GetTextSize(value,size,Enum.Font.GothamMedium,Vector2.new(available,10000)).Y)+6
  local item=Theme.label(panel,name,value,UDim2.fromOffset(12,y),UDim2.fromOffset(available,height),size,color)
  return item,height
 end
 local _,titleH=label('Title',Text.Title,10,18,Theme.color.gold)
 local _,currentH=label('Current',Text.Current,12+titleH,12,Theme.color.text)
 local y=14+titleH+currentH
 local _,bonusH=label('AttackBonus',string.format(Text.AttackBonus,signed((snapshot.stats or {}).power or 0)),y,12,Theme.color.green)
 y+=bonusH
 local _,basicH=label('BasicAttack',string.format(Text.BasicAttack,Text.Labels[hero.baseClassId=='mage' and 'magicPower' or 'physicalPower']),y,11,Theme.color.muted)
 y+=basicH+6
 local after=Growth.copy(hero.progression);local spent=0
 for key,value in pairs(draft) do after.stats[key]+=value;spent+=value end
 for _,entry in ipairs(Preview.breakdown(hero.baseClassId,hero.progression,snapshot.stats,spent>0 and after or nil)) do
  local row=Instance.new('Frame');row.Name=entry.key;row.Position=UDim2.fromOffset(12,y);row.Size=UDim2.fromOffset(available,spent>0 and 70 or 48)
  row.BackgroundColor3=Theme.color.ink;row.BackgroundTransparency=.25;row.BorderSizePixel=0;row.Parent=panel
  Theme.label(row,'Name',Text.Labels[entry.key],UDim2.fromOffset(8,2),UDim2.new(.6,-8,0,24),13,Theme.color.text)
  local total=Theme.label(row,'Total',number(entry.total),UDim2.new(.6,0,0,0),UDim2.new(.4,-8,0,26),19,Theme.color.gold)
  total.Font=Enum.Font.GothamBold;total.TextXAlignment=Enum.TextXAlignment.Right
  Theme.label(row,'Breakdown',string.format(Text.HeroAndGear,number(entry.hero),signed(entry.gear)),UDim2.fromOffset(8,26),UDim2.new(1,-16,0,18),11,Theme.color.silver)
  if entry.draft then
   local delta=entry.draft-entry.total
   Theme.label(row,'Draft',string.format(Text.Draft,number(entry.total),number(entry.draft),signed(delta)),UDim2.fromOffset(8,46),UDim2.new(1,-16,0,20),11,delta~=0 and Theme.color.green or Theme.color.muted)
  end
  y+=row.Size.Y.Offset+6
 end
 if spent>0 then local _,height=label('DraftNote',Text.DraftNote,y,12,Theme.color.green);y+=height+8 end
 local toggle=Theme.button(panel,'GearDetails',state.gearExpanded and Text.HideGear or Text.ShowGear,UDim2.fromOffset(12,y),UDim2.fromOffset(available,44))
 toggle.Activated:Connect(function() state.gearExpanded=not state.gearExpanded;redraw() end)
 y+=52
 if state.gearExpanded then
  local sources=Preview.gearSources(hero.heroId,snapshot.items,Catalog)
  if #sources==0 then local _,height=label('NoGear',Text.NoGear,y,12,Theme.color.muted);y+=height+6 end
  for _,source in ipairs(sources) do
   local _,nameH=label('Gear_'..source.slot,string.format(Text.GearItem,InventoryText.Slots[source.slot],source.name),y,13,Theme.color.gold);y+=nameH
   local parts={}
   for _,entry in ipairs({{'power',Text.GearPower},{'armor',Text.GearArmor},{'health',Text.GearHealth}}) do
    local value=source.stats[entry[1]] or 0
    if value~=0 then table.insert(parts,string.format(entry[2],signed(value))) end
   end
   local _,height=label('Bonus_'..source.slot,#parts>0 and table.concat(parts,' · ') or Text.NoBonus,y,12,Theme.color.green)
   y+=height+10
  end
 end
 for _,entry in ipairs({{'HeroNote',Text.HeroNote},{'DefenseNote',Text.DefenseNote}}) do
  local _,height=label(entry[1],entry[2],y,11,Theme.color.muted);y+=height+6
 end
 panel.Size=UDim2.fromOffset(width,y+8)
 return y+8
end
return View
