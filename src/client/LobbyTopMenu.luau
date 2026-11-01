-- TD menu-list art and spacing over the existing RPG actions.
local T=require(script.Parent.TDInventoryTheme)
local HomeArt=require(game.ReplicatedStorage.Shared.TDUI.LobbyHomeArtAssets)
local UIS=game:GetService('UserInputService')
local M={}
function M.create(player,actions)
 local gui=Instance.new('ScreenGui');gui.Name='LobbyTopMenu';gui.ResetOnSpawn=false;gui.DisplayOrder=75;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild('PlayerGui')
 local toggle=T.button(gui,'Menu','MENU',UDim2.new(1,-124,0,8),UDim2.fromOffset(112,44))
 toggle:SetAttribute('ChromeControl','menu');toggle.TDButtonArt.SliceScale=.25
 toggle.Caption.Position=UDim2.fromOffset(24,4);toggle.Caption.Size=UDim2.new(1,-36,1,-8)
 toggle.Caption.TextSize=14;toggle.Caption.TextColor3=Color3.new(1,1,1)
 toggle.Caption.TextStrokeColor3=Color3.fromRGB(8,16,30);toggle.Caption.TextStrokeTransparency=.1
 T.icon(toggle,'settings',UDim2.new(0,2,.5,-10),UDim2.fromOffset(20,20))
 local menu=T.frame(gui,'Actions',UDim2.new(1,-244,0,56),UDim2.fromOffset(232,336));menu.Visible=false
 menu.TDPanelArt.SliceScale=.45
 local list=Instance.new('ScrollingFrame');list.Name='MenuList';list.Size=UDim2.fromScale(1,1);list.BackgroundTransparency=1;list.BorderSizePixel=0
 list.ScrollBarThickness=4;list.ScrollingDirection=Enum.ScrollingDirection.Y;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=menu
 local padding=Instance.new('UIPadding');padding.PaddingLeft=UDim.new(0,16);padding.PaddingRight=UDim.new(0,16);padding.PaddingTop=UDim.new(0,16);padding.PaddingBottom=UDim.new(0,16);padding.Parent=list
 local layout=Instance.new('UIListLayout');layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Padding=UDim.new(0,6);layout.Parent=list
 local function artBackground(control,art)
  local confirmed=false
  local function ready()
   if not control.Parent then return end
   local loaded=art.IsLoaded or confirmed
   control.BackgroundTransparency=loaded and 1 or 0
   for _,v in control:GetChildren()do if v:IsA('UIStroke')then v.Enabled=not loaded end end
  end
  art:GetPropertyChangedSignal('IsLoaded'):Connect(ready);ready()
  task.spawn(function()pcall(function()
   game:GetService('ContentProvider'):PreloadAsync({art},function(_,status)
    if status==Enum.AssetFetchStatus.Success then confirmed=true;ready()end
   end)
  end)end)
 end
 artBackground(menu,menu.TDPanelArt)
 local buttons={}
 local entries={
  {'SUPPLIES','Bag','Gear & Bag','bag'},
  {'PROGRESS','Hero','Stats & Skills','hero'},
  {'','Journal','Journal [J]','quests'},
  {'MORE','Settings','Settings','settings'},
 }
 for i,row in ipairs(entries)do
  if row[1]~='' then
   local category=T.label(list,'Category_'..row[1],row[1],UDim2.new(),UDim2.new(1,-8,0,20),14,Color3.fromRGB(205,183,129))
   category.LayoutOrder=i*2-1;category.Font=Enum.Font.GothamBold;category.TextXAlignment=Enum.TextXAlignment.Center
  end
  local b=T.button(list,row[2],row[3],UDim2.new(),UDim2.new(1,-8,0,52));b.LayoutOrder=i*2
  b.TDButtonArt.SliceScale=.45
  local emblem
  if row[4]=='bag' then
   local source=HomeArt.overrides.shop or HomeArt
   emblem=T.sprite(b,'TDIcon_bag','bag',UDim2.new(0,10,.5,0),UDim2.fromOffset(40,40),{image=source.image,width=source.width,height=source.height,renderWidth=source.renderWidth,renderHeight=source.renderHeight,regions={bag=HomeArt.navigationBodies.shop}})
  else emblem=T.icon(b,row[4],UDim2.new(0,10,.5,0),UDim2.fromOffset(40,40))end
  emblem.AnchorPoint=Vector2.new(0,.5)
  artBackground(b,b.TDButtonArt)
  b.Caption.Position=UDim2.fromOffset(60,2);b.Caption.Size=UDim2.new(1,-84,1,-4)
  b.Caption.Font=Enum.Font.GothamBold;b.Caption.TextSize=16;b.Caption.TextColor3=Color3.fromRGB(245,240,223)
  b.Caption.TextStrokeColor3=Color3.fromRGB(8,16,30);b.Caption.TextStrokeTransparency=.1
  buttons[row[2]]=b
 end
 local function resize(size)
  size=size or gui.AbsoluteSize
  local w=math.min(232,math.max(1,size.X-24))
  local h=math.min(336,math.max(1,size.Y-68))
  menu.Size=UDim2.fromOffset(w,h);menu.Position=UDim2.new(1,-w-12,0,56)
 end
 local open=false
 local function setOpen(value)
  open=value==true and gui.Enabled;menu.Visible=open;player:SetAttribute('TLTLobbyTopMenuOpen',open)
  if open then resize() end
 end
 local function refresh()
  local enabled=player:GetAttribute('K0SessionPhase')=='Lobby' and workspace:GetAttribute('TLTServerRole')~='Battle'
   and not player:GetAttribute('TLTInventoryOpen') and not player:GetAttribute('TLTProgressionOpen')
   and not player:GetAttribute('TLTHeroSelectionOpen') and not player:GetAttribute('TLTSettingsOpen') and not player:GetAttribute('TLTLobbyPanelOpen') and not player:GetAttribute('TLTTravelLock')
  gui.Enabled=enabled
  if not enabled and open then setOpen(false)end
 end
 local function choose(id)
  if not open or not buttons[id]then return end
  setOpen(false);actions[id]()
 end
 toggle.Activated:Connect(function()setOpen(not open)end)
 for id,b in pairs(buttons)do local key=id;b.Activated:Connect(function()choose(key)end)end
 local connections={}
 table.insert(connections,gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize))
 resize()
 for _,attribute in ipairs({'TLTHeroSelectionOpen','K0SessionPhase','TLTInventoryOpen','TLTProgressionOpen','TLTSettingsOpen','TLTLobbyPanelOpen','TLTTravelLock'})do
  table.insert(connections,player:GetAttributeChangedSignal(attribute):Connect(refresh))
 end
 table.insert(connections,workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(refresh))
 table.insert(connections,UIS.InputBegan:Connect(function(input,processed)
  if not processed and gui.Enabled and input.KeyCode==Enum.KeyCode.J and not UIS:GetFocusedTextBox()then setOpen(false);actions.Journal()end
 end))
 gui.Destroying:Connect(function()if open then player:SetAttribute('TLTLobbyTopMenuOpen',false)end;for _,c in ipairs(connections)do c:Disconnect()end end)
 refresh()
 return {gui=gui,menu=menu,buttons=buttons,toggle=function()setOpen(not open)end,choose=choose,resize=resize}
end
return M
