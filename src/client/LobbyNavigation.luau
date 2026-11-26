-- TD original pictures, shared nameplates, metrics and RPG-only subject adapter.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local Sizing=require(script.Parent.LobbyNavigationSizing)
local Bridge=require(script.Parent.LobbyMenuBridge)
local Art=require(script.Parent.LobbyNavigationArt)
local M={}
local iconTitles={ItemShop='POTIONS',DiamondShop='DIAMONDS',LoginRewards='REWARDS',Quest='QUESTS'}
local entries={{'Heroes','HEROES'},{'ItemShop','POTION SHOP'},{'Blacksmith','BLACKSMITH'},{'Quest','QUEST'},{'Maps','MAPS'},{'DiamondShop','DIAMOND SHOP'},{'LoginRewards','LOGIN REWARDS'}}
function M.create(parent,actions)
 local rail=Instance.new('Frame');rail.Name='LobbyNavigation';rail.BackgroundTransparency=1;rail.AnchorPoint=Vector2.new(0,0);rail.Position=UDim2.new(0,10,.5,-30);rail.Size=UDim2.fromOffset(180,268);rail.Parent=parent
 local grid=Instance.new('UIGridLayout');grid.CellSize=UDim2.fromOffset(88,64);grid.CellPadding=UDim2.fromOffset(4,4);grid.FillDirectionMaxCells=2;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=rail
 local scale=Instance.new('UIScale');scale.Parent=rail
 local function resize()
  local viewport=parent.AbsoluteSize
  if viewport.X<=0 or viewport.Y<=0 then return end
  local metrics=Sizing.measure(viewport.X,viewport.Y)
  local shortPortrait=viewport.X<500 and viewport.Y>viewport.X and viewport.Y<680
   and viewport.X>=3*metrics.width+2*metrics.gap+24
  local columns=shortPortrait and 3 or 2
  local rows=math.ceil(#entries/columns)
  local rowGap=shortPortrait and math.min(metrics.rowGap,8) or metrics.rowGap
  grid.FillDirectionMaxCells=columns
  grid.CellSize=UDim2.fromOffset(metrics.width,metrics.height)
  grid.CellPadding=UDim2.fromOffset(metrics.gap,rowGap)
  local height=rows*metrics.height+(rows-1)*rowGap
  rail.Size=UDim2.fromOffset(columns*metrics.width+(columns-1)*metrics.gap,height)
  scale.Scale=1
  for _,b in ipairs(rail:GetChildren()) do
   if b:IsA('TextButton') then
    b.Caption.Text=iconTitles[b.Name] or b:GetAttribute('NavigationLabel') or b.Caption.Text
    Art.layout(b)
   end
  end
  local x=metrics.large and math.floor(viewport.X*.0284) or 12
  local y=metrics.large and math.max(100,math.floor(viewport.Y*.155)) or math.max(100,math.floor(viewport.Y*.19))
  if viewport.Y<500 then y=68 end
  local bottomClearance=12
  if shortPortrait then
   local portraitHeight=math.max(44,math.floor((viewport.X-60)/4))
   bottomClearance=viewport.Y<500 and 194 or 162+portraitHeight -- Roster, PLAY, XP and a gap.
  end
  y=math.min(y,math.max(8,viewport.Y-height-bottomClearance))
  rail.Position=UDim2.fromOffset(x,y)
 end
 local resizeConnection=parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
 rail.Destroying:Connect(function() resizeConnection:Disconnect() end)
 resize()
 local panel=T.frame(parent,'LobbyGuide',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(1100,850);cap.Parent=panel
 require(script.Parent.LobbyPanelLayout).bind(panel)
 local title=T.label(panel,'Title','',UDim2.fromOffset(20,10),UDim2.new(1,-92,0,44),20,T.color.gold)
 T.fitText(title)
 local close=T.button(panel,'Close','X',UDim2.new(1,-60,0,10),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local body=T.label(panel,'Contents','',UDim2.fromOffset(24,60),UDim2.new(1,-48,1,-80),15,T.color.text);body.TextYAlignment=Enum.TextYAlignment.Top
 local atlas=require(script.Parent.LobbyAtlas).create(panel)
 local journal=require(script.Parent.LobbyQuestJournal).create(panel)
 local snapshot
 local sideButton=T.button(panel,'TessaGuide','TESSA',UDim2.new(1,-220,0,10),UDim2.fromOffset(152,44));sideButton.Visible=false
 sideButton.Activated:Connect(function()Bridge:Fire('FindTessa')end)
 local function layoutGuideHeader()
  local width=math.clamp(math.floor(panel.AbsoluteSize.X*.36),100,152)
  sideButton.Size=UDim2.fromOffset(width,44)
  sideButton.Position=UDim2.new(1,-68-width,0,10)
  title.Size=UDim2.new(1,sideButton.Visible and -100-width or -92,0,44)
 end
 panel:GetPropertyChangedSignal('AbsoluteSize'):Connect(layoutGuideHeader)
 local function guide(kind)
  sideButton.Visible=kind=='Maps';layoutGuideHeader()
  body.Visible=false;atlas.root.Visible=kind=='Maps';journal.root.Visible=kind=='Quest'
  title.Text=kind=='Quest' and require(RS.Shared.LobbyQuestText).Title or 'ADVENTURE MAPS'
  if kind=='Maps'then atlas.show(snapshot)else journal.show(snapshot)end
  panel.Visible=true
 end
 local bridgeConnection=Bridge.Event:Connect(function(action)if action=='Quest'then actions.close();guide('Quest')end end)
 panel.Destroying:Connect(function()bridgeConnection:Disconnect()end)
 for index,entry in ipairs(entries) do
  local b=T.button(rail,entry[1],entry[2],UDim2.new(),UDim2.fromOffset(88,64))
  -- Every entry uses the same TD picture/nameplate structure.
  b:SetAttribute('NavigationLabel',entry[2])
  b.LayoutOrder=index;b.BackgroundTransparency=1;b.TDButtonArt.Visible=false;b.TDButtonArt.ZIndex=2
  b.Caption.Font=Enum.Font.GothamBlack;b.Caption.TextColor3=Color3.new(1,1,1)
  b.Caption.TextStrokeColor3=Color3.new(0,0,0);b.Caption.TextStrokeTransparency=0
  b.Caption.TextScaled=false;b.Caption.TextWrapped=false;b.Caption.ZIndex=4
  Art.apply(b,entry[1]);b.Activated:Connect(function()
   panel.Visible=false
   if entry[1]=='Heroes' then actions.close();Bridge:Fire('Heroes')
   elseif entry[1]=='Quest' or entry[1]=='Maps' then actions.close();guide(entry[1])
   else actions.open(entry[1]) end
  end)
 end
 resize()
 return {rail=rail,panel=panel,showGuide=guide,update=function(s) snapshot=s;local side=require(RS.Shared.LobbySideQuests).project(s);sideButton.Caption.Text=(side.symbol~=''and side.symbol..' 'or '')..'TESSA'..(side.count>0 and ' ('..side.count..')'or '');atlas.update(s);journal.update(s) end,
  dailyAvailable=function(available)local b=rail:FindFirstChild('LoginRewards');if b then b:SetAttribute('RewardAvailable',available);resize() end end}
end
return M
