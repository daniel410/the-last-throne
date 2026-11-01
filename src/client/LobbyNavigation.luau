-- Illustrated navigation tiles; Diamond Shop uses the original TD lobby artwork.
local RS=game:GetService('ReplicatedStorage')
local TextService=game:GetService('TextService')
local T=require(script.Parent.TDInventoryTheme)
local Sizing=require(script.Parent.LobbyNavigationSizing)
local Bridge=require(script.Parent.LobbyMenuBridge)
local LobbyArt=require(RS.Shared.TDUI.LobbyHomeArtAssets)
local M={}
function M.create(parent,actions)
 local rail=Instance.new('Frame');rail.Name='LobbyNavigation';rail.BackgroundTransparency=1;rail.AnchorPoint=Vector2.new(0,.5);rail.Position=UDim2.new(0,10,.5,-30);rail.Size=UDim2.fromOffset(180,268);rail.Parent=parent
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
    local textSize=metrics.height<64 and 14 or metrics.width<100 and 16 or math.clamp(math.floor(metrics.width*.17),18,34)
    local label=b.Caption
    local bounds=TextService:GetTextSize(label.Text,textSize,Enum.Font.GothamBlack,Vector2.new(10000,1000))
    -- TD uses fixed-size, outlined text. Fit RPG's longer names on one line.
    label.TextSize=math.min(textSize,math.floor(textSize*(metrics.width-2)/math.max(1,bounds.X)))
    local compact=metrics.height<64
    label.TextScaled=compact;label.TextWrapped=compact
    if compact then
     label.TextSize=textSize
     local limit=label:FindFirstChildOfClass('UITextSizeConstraint') or Instance.new('UITextSizeConstraint')
     limit.MinTextSize=9;limit.MaxTextSize=textSize;limit.Parent=label
    end
    local captionY=compact and .65 or (b:GetAttribute('NavigationCaptionY') or .79)
    local captionH=b:GetAttribute('NavigationCaptionH') or .19
    local height=math.max(metrics.height*(compact and .32 or captionH),label.TextSize+6)
    label.Position=UDim2.fromOffset(0,math.max(0,math.min(metrics.height-height,metrics.height*captionY)))
    label.Size=UDim2.new(1,0,0,height)
   end
  end
  local top=viewport.X<530 and 72 or 8
  local available=viewport.Y-12-top
  rail.Position=UDim2.new(0,10,0,top+available/2)
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
 Bridge.Event:Connect(function(action)if action=='Quest'then actions.close();guide('Quest')end end)
 local function icon(button,id,index)
  local art
  if id=='LoginRewards' then
   art=T.icon(button,'login_rewards',UDim2.fromOffset(12,0),UDim2.fromOffset(64,48))
  elseif id=='DiamondShop' then
   art=T.sprite(button,'NavigationIcon','shop',UDim2.fromOffset(12,0),UDim2.fromOffset(64,48),LobbyArt)
   local crop=LobbyArt.regions.shop
   button:SetAttribute('NavigationCaptionY',crop.captionY)
   button:SetAttribute('NavigationCaptionH',crop.captionH)
  else
   art=Instance.new('ImageLabel');art.Name='NavigationIcon';art.BackgroundTransparency=1
   art.Image=id=='Blacksmith' and 'rbxassetid://97662984602605' or 'rbxassetid://137280207574223'
   -- Roblox renders the 2172x724 upload at 1024x341.
   art.ImageRectOffset=Vector2.new(math.round((index-1)*204.8),70)
   art.ImageRectSize=Vector2.new(math.round(index*204.8)-art.ImageRectOffset.X,190)
   art.Position=UDim2.fromOffset(12,0);art.Size=UDim2.fromOffset(64,48)
   art.ScaleType=Enum.ScaleType.Fit;art.Parent=button
  end
  art.Position=UDim2.fromScale(0,0);art.Size=UDim2.fromScale(1,1)
  art.ZIndex=3
 end
 for index,entry in ipairs({{'Heroes','HEROES'},{'ItemShop','POTION SHOP'},{'Blacksmith','BLACKSMITH'},{'Quest','QUEST'},{'Maps','MAPS'},{'DiamondShop','DIAMOND SHOP'},{'LoginRewards','LOGIN REWARDS'}}) do
  local b=T.button(rail,entry[1],entry[2],UDim2.new(),UDim2.fromOffset(88,64))
  -- The login icon is unframed; the other navigation artwork includes its own frame.
  b.LayoutOrder=index;b.BackgroundTransparency=1;b.TDButtonArt.Visible=entry[1]=='LoginRewards';b.TDButtonArt.ZIndex=2
  b.Caption.Font=Enum.Font.GothamBlack;b.Caption.TextColor3=Color3.new(1,1,1)
  b.Caption.TextStrokeColor3=Color3.new(0,0,0);b.Caption.TextStrokeTransparency=0
  b.Caption.TextScaled=false;b.Caption.TextWrapped=false;b.Caption.ZIndex=4
  b:SetAttribute('NavigationCaptionY',entry[1]=='LoginRewards' and .78 or .80)
  b:SetAttribute('NavigationCaptionH',entry[1]=='LoginRewards' and .20 or .18)
  icon(b,entry[1],index);b.Activated:Connect(function()
   panel.Visible=false
   if entry[1]=='Heroes' then actions.close();Bridge:Fire('Heroes')
   elseif entry[1]=='Quest' or entry[1]=='Maps' then actions.close();guide(entry[1])
   else actions.open(entry[1]) end
  end)
 end
 resize()
 return {rail=rail,panel=panel,showGuide=guide,update=function(s) snapshot=s;atlas.update(s);journal.update(s) end,
  dailyAvailable=function(available)local b=rail:FindFirstChild('LoginRewards');if b then b.Caption.Text=available and 'LOGIN REWARDS !'or 'LOGIN REWARDS';resize() end end}
end
return M
