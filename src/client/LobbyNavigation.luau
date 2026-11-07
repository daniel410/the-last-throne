-- TD original pictures, shared nameplates, metrics and RPG-only subject adapter.
local RS=game:GetService('ReplicatedStorage')
local T=require(script.Parent.TDInventoryTheme)
local Sizing=require(script.Parent.LobbyNavigationSizing)
local Bridge=require(script.Parent.LobbyMenuBridge)
local Art=require(script.Parent.LobbyNavigationArt)
local M={}
local iconTitles={ItemShop='POTIONS',DiamondShop='DIAMONDS',LoginRewards='REWARDS',Quest='QUESTS'}
function M.create(parent,actions)
 local rail=Instance.new('Frame');rail.Name='LobbyNavigation';rail.BackgroundTransparency=1;rail.AnchorPoint=Vector2.new(0,0);rail.Position=UDim2.new(0,10,.5,-30);rail.Size=UDim2.fromOffset(180,268);rail.Parent=parent
 local grid=Instance.new('UIGridLayout');grid.CellSize=UDim2.fromOffset(88,64);grid.CellPadding=UDim2.fromOffset(4,4);grid.FillDirectionMaxCells=2;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=rail
 local scale=Instance.new('UIScale');scale.Parent=rail
 local function resize()
  local viewport=parent.AbsoluteSize
  if viewport.X<=0 or viewport.Y<=0 then return end
  local metrics=Sizing.measure(viewport.X,viewport.Y)
  grid.CellSize=UDim2.fromOffset(metrics.width,metrics.height)
  grid.CellPadding=UDim2.fromOffset(metrics.gap,metrics.rowGap)
  local height=4*metrics.height+3*metrics.rowGap
  rail.Size=UDim2.fromOffset(2*metrics.width+metrics.gap,height)
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
  y=math.min(y,math.max(8,viewport.Y-height-12))
  rail.Position=UDim2.fromOffset(x,y)
 end
 local resizeConnection=parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize)
 rail.Destroying:Connect(function() resizeConnection:Disconnect() end)
 resize()
 local panel=T.frame(parent,'LobbyGuide',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(1100,850);cap.Parent=panel
 require(script.Parent.LobbyPanelLayout).bind(panel)
 local title=T.label(panel,'Title','',UDim2.fromOffset(20,12),UDim2.new(1,-85,0,34),20,T.color.gold)
 local close=T.button(panel,'Close','X',UDim2.new(1,-60,0,10),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local body=T.label(panel,'Contents','',UDim2.fromOffset(24,60),UDim2.new(1,-48,1,-80),15,T.color.text);body.TextYAlignment=Enum.TextYAlignment.Top
 local atlas=require(script.Parent.LobbyAtlas).create(panel)
 local journal=require(script.Parent.LobbyQuestJournal).create(panel)
 local snapshot
 local function guide(kind)
  body.Visible=false;atlas.root.Visible=kind=='Maps';journal.root.Visible=kind=='Quest'
  title.Text=kind=='Quest' and require(RS.Shared.LobbyQuestText).Title or 'ADVENTURE MAPS'
  if kind=='Maps'then atlas.show(snapshot)else journal.show(snapshot)end
  panel.Visible=true
 end
 local bridgeConnection=Bridge.Event:Connect(function(action)if action=='Quest'then actions.close();guide('Quest')end end)
 panel.Destroying:Connect(function()bridgeConnection:Disconnect()end)
 for index,entry in ipairs({{'Heroes','HEROES'},{'ItemShop','POTION SHOP'},{'Blacksmith','BLACKSMITH'},{'Quest','QUEST'},{'Maps','MAPS'},{'DiamondShop','DIAMOND SHOP'},{'LoginRewards','LOGIN REWARDS'}}) do
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
 return {rail=rail,panel=panel,showGuide=guide,update=function(s) snapshot=s;atlas.update(s);journal.update(s);require(script.Parent.DawnspireHomecoming).update(s) end,
  dailyAvailable=function(available)local b=rail:FindFirstChild('LoginRewards');if b then b:SetAttribute('RewardAvailable',available);resize() end end}
end
return M
