-- Battle-style compact menu for the lobby's existing hero, bag, journal and settings actions.
local T=require(script.Parent.TDInventoryTheme)
local Navigation=require(game.ReplicatedStorage.Shared.NavigationText)
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
 local menu=T.frame(gui,'Actions',UDim2.new(1,-178,0,56),UDim2.fromOffset(168,192));menu.Visible=false
 local buttons={}
 for i,row in ipairs({{'Hero',Navigation.statsButton},{'Bag',Navigation.bagButton},{'Journal','JOURNAL [J]'},{'Settings',Navigation.settings}})do
  local b=T.button(menu,row[1],row[2],UDim2.fromOffset(10,8+(i-1)*44),UDim2.fromOffset(148,i==4 and 44 or 36))
  if i<=2 then b.Caption.TextScaled=true;local cap=Instance.new('UITextSizeConstraint');cap.MinTextSize=9;cap.MaxTextSize=13;cap.Parent=b.Caption end
  buttons[row[1]]=b
 end
 local open=false
 local function setOpen(value)
  open=value==true and gui.Enabled;menu.Visible=open;player:SetAttribute('TLTLobbyTopMenuOpen',open)
  if open then
   local y=math.max(0,math.min(56,gui.AbsoluteSize.Y-menu.Size.Y.Offset-8))
   menu.Position=UDim2.new(1,-178,0,y)
  end
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
 for _,attribute in ipairs({'TLTHeroSelectionOpen','K0SessionPhase','TLTInventoryOpen','TLTProgressionOpen','TLTSettingsOpen','TLTLobbyPanelOpen','TLTTravelLock'})do
  table.insert(connections,player:GetAttributeChangedSignal(attribute):Connect(refresh))
 end
 table.insert(connections,workspace:GetAttributeChangedSignal('TLTServerRole'):Connect(refresh))
 table.insert(connections,UIS.InputBegan:Connect(function(input,processed)
  if not processed and gui.Enabled and input.KeyCode==Enum.KeyCode.J and not UIS:GetFocusedTextBox()then setOpen(false);actions.Journal()end
 end))
 gui.Destroying:Connect(function()if open then player:SetAttribute('TLTLobbyTopMenuOpen',false)end;for _,c in ipairs(connections)do c:Disconnect()end end)
 refresh()
 return {gui=gui,menu=menu,buttons=buttons,toggle=function()setOpen(not open)end,choose=choose}
end
return M
