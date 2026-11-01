local CAS=game:GetService('ContextActionService')
local UIS=game:GetService('UserInputService')
local GuiService=game:GetService('GuiService')
local Prompts=game:GetService('ProximityPromptService')
local Theme=require(script.Parent.TDInventoryTheme)
local Settings=require(script.Parent.GameSettings)
local Text=require(game.ReplicatedStorage.Shared.SettingsText)
local M={}
function M.create(player,onVisibility)
 local parent=player:WaitForChild('PlayerGui')
 local old=parent:FindFirstChild('GameSettings');if old then old:Destroy() end
 local gui=Instance.new('ScreenGui');gui.Name='GameSettings';gui.ResetOnSpawn=false;gui.DisplayOrder=80;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local launcher=Theme.button(gui,'OpenSettings',Text.Title,UDim2.new(),UDim2.fromOffset(156,44))
 launcher.Visible=false -- Hidden before any constructor waits or phase replication.
 require(script.Parent.TopMenuLayout).bind(gui,launcher,3)
 local shade=Instance.new('Frame');shade.Name='Overlay';shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=Color3.new();shade.BackgroundTransparency=.3;shade.Active=true;shade.Visible=false;shade.Parent=gui
 local panel=Theme.frame(shade,'SettingsPanel',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-80));panel.AnchorPoint=Vector2.new(.5,.5)
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(620,520);cap.Parent=panel
 require(script.Parent.LobbyPanelLayout).bind(panel,player)
 Theme.label(panel,'Title',Text.Title,UDim2.fromOffset(20,12),UDim2.new(1,-104,0,38),24,Theme.color.gold)
 local close=Theme.button(panel,'Close',Text.Close,UDim2.new(1,-90,0,12),UDim2.fromOffset(76,44))
 Theme.label(panel,'Description',Text.Description,UDim2.fromOffset(20,60),UDim2.new(1,-40,0,28),14)
 local list=Instance.new('ScrollingFrame');list.Name='Options';list.BackgroundTransparency=1;list.BorderSizePixel=0;list.Position=UDim2.fromOffset(16,96);list.Size=UDim2.new(1,-32,1,-150);list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.ScrollBarThickness=5;list.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 Theme.label(panel,'SessionNote',Text.SessionNote,UDim2.new(0,20,1,-44),UDim2.new(1,-40,0,36),12,Theme.color.muted)
 local opened=false;local previousFocus;local previousPrompts;local connections={};local toggles={}
 local function connect(signal,callback) table.insert(connections,signal:Connect(callback)) end
 local function showLauncher()
  local phase=player:GetAttribute('K0SessionPhase')
  launcher.Visible=not opened and phase~=nil and phase~='LoadingLobby' and phase~='ReturningLobby' and phase~='Lobby' and phase~='Tutorial' and phase~='LoadingTutorial' and phase~='Respawning'
   and not player:GetAttribute('TLTInventoryOpen') and not player:GetAttribute('TLTProgressionOpen')
 end
 local function setOpen(value)
  value=value==true and not player:GetAttribute('TLTTravelLock')
  if value==opened then return end
  opened=value;shade.Visible=value;player:SetAttribute('TLTSettingsOpen',value);showLauncher()
  if value then
   previousFocus=GuiService.SelectedObject
   previousPrompts=Prompts.Enabled;Prompts.Enabled=false
   CAS:BindActionAtPriority('SettingsMovement',function()return Enum.ContextActionResult.Sink end,false,4300,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.Thumbstick1)
   if UIS:GetLastInputType().Name:match('^Gamepad') then GuiService.SelectedObject=toggles.attacks end
  else
   CAS:UnbindAction('SettingsMovement')
   if previousPrompts~=nil then Prompts.Enabled=previousPrompts;previousPrompts=nil end
   if previousFocus and previousFocus.Parent and previousFocus.Visible then GuiService.SelectedObject=previousFocus end
  end
  if onVisibility then onVisibility(value) end
 end
 for index,option in ipairs(Settings.options) do
  local row=Theme.frame(list,option.id,UDim2.new(),UDim2.new(1,-8,0,104));row.LayoutOrder=index
  Theme.label(row,'Name',Text[option.title],UDim2.fromOffset(12,8),UDim2.new(1,-120,0,36),16,Theme.color.gold)
  Theme.label(row,'Hint',Text[option.hint],UDim2.fromOffset(12,46),UDim2.new(1,-120,0,50),12)
  local button=Theme.button(row,'Toggle','',UDim2.new(1,-96,0,30),UDim2.fromOffset(84,44));toggles[option.id]=button
  local function refresh()
   local enabled=Settings.enabled(player,option.id)
   button.Caption.Text=enabled and Text.On or Text.Off
   button:SetAttribute('Enabled',enabled)
   button.Caption.TextColor3=enabled and Theme.color.green or Theme.color.muted
  end
  connect(button.Activated,function()Settings.toggle(player,option.id)end)
  connect(player:GetAttributeChangedSignal(option.attribute),refresh);refresh()
 end
 connect(launcher.Activated,function()setOpen(true)end)
 connect(close.Activated,function()setOpen(false)end)
 for _,attribute in ipairs({'TLTInventoryOpen','TLTProgressionOpen','TLTMapOpen','TLTStoryOpen','TLTTravelLock'}) do
  connect(player:GetAttributeChangedSignal(attribute),function()
   if player:GetAttribute(attribute) then setOpen(false) end;showLauncher()
  end)
 end
 connect(player:GetAttributeChangedSignal('K0SessionPhase'),function()
  local phase=player:GetAttribute('K0SessionPhase')
  if phase~='Lobby' and phase~='Tutorial' then setOpen(false) end;showLauncher()
 end)
 CAS:BindActionAtPriority('SettingsBack',function(_,state)
  if not opened then return Enum.ContextActionResult.Pass end
  if state==Enum.UserInputState.Begin then setOpen(false) end
  return Enum.ContextActionResult.Sink
 end,false,4400,Enum.KeyCode.ButtonB)
 gui.Destroying:Connect(function()
  setOpen(false);CAS:UnbindAction('SettingsBack')
  for _,connection in ipairs(connections) do connection:Disconnect() end
 end)
 showLauncher()
 return {open=function()setOpen(true)end,close=function()setOpen(false)end,isOpen=function()return opened end,gui=gui,toggles=toggles}
end
return M
