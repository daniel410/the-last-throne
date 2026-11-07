-- TD HomeDock geometry/art; RPG roster and server-authoritative intentions.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local Art=require(script.Parent.TDLobbyDockArt)
local Check=require(script.Parent.TDLobbySelectionCheck)
local Growth=require(RS.Shared.HeroProgression)
local M={}
local ORDER={'knight','elf','dwarf','mage'}
local NAMES={knight='Knight',elf='Elf',dwarf='Dwarf',mage='Mage'}
local PORTRAITS={knight='rbxassetid://103255177842108',elf='rbxassetid://80894238854345',dwarf='rbxassetid://74628903359757'}
local TEXT={play='PLAY',heroes='HEROES',choose='Select a hero to begin.',loading='Loading Hero Progress...',waiting='Saving hero selection...',level='%s Hero Lv.%d',xp='%d / %d XP',max='MAX XP'}
local BLOCKERS={'TLTHeroSelectionOpen','TLTInventoryOpen','TLTProgressionOpen','TLTSettingsOpen','TLTLobbyPanelOpen','TLTLobbyTopMenuOpen','TLTTravelLock'}
local function caption(parent,name,text)
 local label=Instance.new('TextLabel')
 label.Name,label.Text,label.BackgroundTransparency=name,text,1
 label.Font,label.TextSize,label.TextColor3=Enum.Font.GothamBlack,20,Color3.new(1,1,1)
 label.TextStrokeColor3,label.TextStrokeTransparency=Color3.new(0,0,0),0
 label.ZIndex=parent.ZIndex+3;label.AutoLocalize=false;label.Parent=parent
 return label
end
function M.create(parent,player,chooseHero,playAction,world)
 world=world or workspace
 local root=Instance.new('Frame');root.Name='HomeRoot';root.Size=UDim2.fromScale(1,1);root.BackgroundTransparency=1;root.Parent=parent
 local dock=Instance.new('Frame');dock.Name='HomeDock';dock.BackgroundTransparency=1;dock.Parent=root
 local play=Instance.new('TextButton');play.Name='HomePlayButton';play.AutoLocalize=false;play.Parent=dock;Art.play(play)
 local playTitle=caption(play,'PlayTitle',TEXT.play);playTitle.Size=UDim2.fromScale(1,1)
 local heading=caption(dock,'HeroesHeading',TEXT.heroes);heading.TextSize=14
 local cards={}
 local state,busy,inventory,notice=nil,false,nil,nil
 local suppressed=false
 local connections={}
 local function allowed()
  if not state or state.phase~='Lobby' or suppressed or busy or world:GetAttribute('TLTServerRole')=='Battle' then return false end
  for _,key in ipairs(BLOCKERS) do if player:GetAttribute(key) then return false end end
  return true
 end
 for _,classId in ipairs(ORDER) do
  local card=Instance.new('TextButton');card.Name='Hero_'..classId;card.AutoLocalize=false;card.Parent=dock;Art.enamel(card)
  card:SetAttribute('HeroClass',classId)
  local border=Instance.new('UIStroke');border.Name='HeroSelectionBorder';border.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;border.Parent=card
  local image
  if classId=='mage' then image=T.icon(card,'arcanist',UDim2.fromOffset(8,8),UDim2.new(1,-16,1,-16));image.Name='HeroPortrait'
  else image=Instance.new('ImageLabel');image.Name='HeroPortrait';image.BackgroundTransparency=1;image.Image=PORTRAITS[classId];image.Position=UDim2.fromOffset(8,8);image.Size=UDim2.new(1,-16,1,-16);image.ScaleType=Enum.ScaleType.Fit;image.Parent=card end
  image.ZIndex=card.ZIndex+1
  local name=caption(card,'HeroName',NAMES[classId]);name.Position=UDim2.new(0,2,1,-18);name.Size=UDim2.new(1,-4,0,18);name.TextSize=14;name.Font=Enum.Font.GothamBold
  name.BackgroundColor3=Color3.fromRGB(12,27,54);name.BackgroundTransparency=.15;name.ZIndex=image.ZIndex+1
  local marker=caption(card,'HeroSelectedMarker','');marker.Position=UDim2.new(1,-24,0,1);marker.Size=UDim2.fromOffset(20,20);marker.ZIndex=name.ZIndex+1;Check.apply(marker);marker.Visible=false
  local selectedTag=caption(card,'HeroSelectedTag','SELECTED');selectedTag.Position=UDim2.fromOffset(4,3);selectedTag.Size=UDim2.new(1,-8,0,17);selectedTag.TextSize=10;selectedTag.TextColor3=Color3.fromRGB(12,27,54);selectedTag.TextStrokeTransparency=1;selectedTag.BackgroundColor3=Color3.fromRGB(255,215,90);selectedTag.BackgroundTransparency=0;selectedTag.ZIndex=marker.ZIndex+1;selectedTag.Visible=false
  card.Activated:Connect(function() if allowed() and state.canManage then chooseHero(classId) end end)
  cards[classId]=card
 end
 local xp=caption(dock,'HomeHeroProgress',TEXT.loading)
 local amount=caption(dock,'HomeXPAmount','')
 local track=Instance.new('Frame');track.Name='HomeXPTrack';track.BackgroundColor3=Color3.fromRGB(12,27,54);track.BorderSizePixel=0;track.ClipsDescendants=true;track.Parent=dock
 local edge=Instance.new('UIStroke');edge.Color=Color3.fromRGB(170,207,250);edge.Thickness=2;edge.Parent=track
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,8);corner.Parent=track
 local fill=Instance.new('Frame');fill.Name='HomeXPFill';fill.BackgroundColor3=Color3.new(1,1,1);fill.BorderSizePixel=0;fill.Parent=track
 corner:Clone().Parent=fill
 local light=Instance.new('UIGradient');light.Rotation=90;light.Color=ColorSequence.new(Color3.fromRGB(80,250,255),Color3.fromRGB(0,178,244));light.Parent=fill
 local function layout(size)
  local w,h=size.X,size.Y
  local short,large=h<500,w>=1500 and h>=700
  local portraitH=short and 46 or w<600 and math.max(44,math.floor((w-60)/4)) or large and 136 or 96
  local portraitW=math.clamp(large and math.floor(w*.095) or w>=600 and not short and math.floor(w*.09) or portraitH,56,170)
  local spacing=w<600 and 6 or large and 18 or short and 10 or 12
  local deckW=4*portraitW+3*spacing
  local playH=short and 44 or w<600 and 48 or large and 72 or 58
  local playSlotH=short and 52 or w<600 and 60 or large and 90 or 72
  local progressH=large and 58 or 48
  local portraitY=playSlotH+24
  local progressY=portraitY+portraitH+(short and 4 or 10)
  local deckH=progressY+progressH
  dock.Size=UDim2.fromOffset(deckW,deckH);dock.Position=UDim2.fromOffset((w-deckW)/2,h-deckH-12)
  local playW=short and 224 or w<600 and math.min(240,math.floor((w-44)*.8)) or large and 440 or 320
  play.Size=UDim2.fromOffset(playW,playH);play.Position=UDim2.fromOffset((deckW-playW)/2,0)
  playTitle.TextSize=short and 26 or w<600 and 30 or large and 51 or 38
  heading.Position=UDim2.fromOffset(0,playSlotH+3);heading.Size=UDim2.new(1,0,0,18)
  for i,classId in ipairs(ORDER) do
   local card=cards[classId];local selected=card:GetAttribute('HeroSelected')==true
   local compact=short or w<600
   card.Position=UDim2.fromOffset((i-1)*(portraitW+spacing),portraitY);card.Size=UDim2.fromOffset(portraitW,portraitH)
   -- Compact cards keep the portrait clear: a thin outline and corner check
   -- replace the desktop's filled selection labels.
   card.HeroSelectedTag.Visible=selected and not compact
   card.HeroSelectedMarker.Size=UDim2.fromOffset(compact and 12 or 20,compact and 12 or 20)
   card.HeroSelectedMarker.Position=compact and UDim2.new(1,-16,0,3) or UDim2.new(1,-24,0,1)
   card.HeroSelectionBorder.Thickness=selected and (compact and 2 or 5) or 1
   local filled=selected and not compact
   card.HeroName.BackgroundColor3=filled and Color3.fromRGB(255,215,90) or Color3.fromRGB(12,27,54)
   card.HeroName.TextColor3=filled and Color3.fromRGB(12,27,54) or Color3.new(1,1,1)
   card.HeroName.TextStrokeTransparency=filled and 1 or 0
  end
  local amountW=w<600 and 94 or short and 108 or large and 176 or 144
  local gap=w<600 and 6 or 12
  track.Position=UDim2.fromOffset(0,progressY+progressH-20);track.Size=UDim2.fromOffset(math.max(24,deckW-amountW-gap),18)
  xp.Position=UDim2.fromOffset(0,progressY);xp.Size=UDim2.fromOffset(deckW,progressH-22);xp.TextXAlignment=Enum.TextXAlignment.Center;xp.TextWrapped=false
  amount.Position=UDim2.fromOffset(deckW-amountW,progressY+progressH-22);amount.Size=UDim2.fromOffset(amountW,22);amount.TextXAlignment=Enum.TextXAlignment.Right
  xp.TextSize=(w<600 or short) and 16 or large and 22 or 18;amount.TextSize=(w<600 or short) and 14 or large and 20 or 16
 end
 local function render()
  root.Visible=allowed() or busy and state~=nil and state.phase=='Lobby' and not suppressed
  for _,key in ipairs(BLOCKERS) do if player:GetAttribute(key) then root.Visible=false end end
  if world:GetAttribute('TLTServerRole')=='Battle' then root.Visible=false end
  for _,classId in ipairs(ORDER) do
   local card=cards[classId];local selected=false
   for _,hero in ipairs(state and state.heroes or {}) do if hero.classId==classId and hero.heroId==state.selectedHeroId then selected=true end end
   card:SetAttribute('HeroSelected',selected);card.HeroSelectedMarker.Visible=selected
   card.HeroPortrait.ImageColor3=selected and Color3.new(1,1,1) or Color3.fromRGB(185,195,210)
   card.HeroSelectionBorder.Color=selected and Color3.fromRGB(255,225,115) or Color3.fromRGB(120,145,175)
   card.Active=allowed() and state.canManage==true;card.Selectable=card.Active;card.AutoButtonColor=card.Active
  end
  play.Active=allowed();play.Selectable=play.Active;play.AutoButtonColor=play.Active
  local hero=inventory and inventory.ready==true and state and inventory.heroes[state.selectedHeroId] or nil
  local g=hero and hero.progression
  local ready=type(g)=='table' and inventory.heroId==state.selectedHeroId
  local selectedClass
  for _,entry in ipairs(state and state.heroes or {}) do if entry.heroId==state.selectedHeroId then selectedClass=entry.classId;break end end
  xp.Text=notice or (busy and TEXT.waiting) or (ready and string.format(TEXT.level,NAMES[selectedClass] or 'Hero',g.level)) or (state and not state.selectedHeroId and TEXT.choose) or TEXT.loading
  track.Visible=ready and not busy and not notice;amount.Visible=track.Visible
  xp:SetAttribute('ProgressReady',track.Visible)
  if ready then local max=Growth.xpToNext(g.level);amount.Text=g.level>=Growth.maxLevel and TEXT.max or string.format(TEXT.xp,g.xp,max);fill.Size=UDim2.fromScale(max>0 and math.clamp(g.xp/max,0,1) or 0,1) end
  layout(root.AbsoluteSize)
 end
 play.Activated:Connect(function() if allowed() then playAction() end end)
 table.insert(connections,root:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() layout(root.AbsoluteSize) end))
 for _,key in ipairs(BLOCKERS) do table.insert(connections,player:GetAttributeChangedSignal(key):Connect(render)) end
 table.insert(connections,world:GetAttributeChangedSignal('TLTServerRole'):Connect(render))
 root.Destroying:Connect(function() for _,c in ipairs(connections) do c:Disconnect() end end)
 render()
 return {root=root,cards=cards,play=play,layout=layout,
  update=function(value,pending) state=value;busy=pending==true;notice=nil;render() end,
  inventory=function(value) if type(value)~='table' or type(value.heroes)~='table' or inventory and value.revision<inventory.revision then return end;inventory=value;render() end,
  suppress=function(value) suppressed=value==true;render() end,
  error=function(value) notice=value;render() end}
end
return M
