local T=require(script.Parent.TDInventoryTheme)
local Text=require(game:GetService('ReplicatedStorage').Shared.ExpeditionText)
local M={}
local active

function M.create(parent,player)
 local gui=Instance.new('ScreenGui');gui.Name='AdventureStartingNotice';gui.IgnoreGuiInset=true;gui.ResetOnSpawn=false;gui.DisplayOrder=9999;gui.Enabled=false;gui.Parent=parent
 local shade=Instance.new('Frame');shade.Name='Shade';shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=T.color.ink;shade.BackgroundTransparency=.35;shade.BorderSizePixel=0;shade.Active=true;shade.Parent=gui
 local card=T.frame(shade,'Card',UDim2.fromScale(.5,.5),UDim2.new(1,-40,0,152));card.AnchorPoint=Vector2.new(.5,.5)
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(480,152);cap.Parent=card
 local title=T.label(card,'Title',Text.Starting,UDim2.fromOffset(16,24),UDim2.new(1,-32,0,40),22,T.color.gold);title.TextXAlignment=Enum.TextXAlignment.Center
 local detail=T.label(card,'Detail',Text.StartingDetail,UDim2.fromOffset(20,72),UDim2.new(1,-40,0,52),14);detail.TextXAlignment=Enum.TextXAlignment.Center
 local pending=false
 local function refresh()
  local lobby=player:GetAttribute('K0SessionPhase')=='Lobby'
  if not lobby then pending=false end
  gui.Enabled=lobby and (pending or player:GetAttribute('TLTAdventureStarting')==true)
 end
 local connections={}
 for _,name in ipairs({'K0SessionPhase','TLTAdventureStarting'})do table.insert(connections,player:GetAttributeChangedSignal(name):Connect(refresh))end
 gui.Destroying:Connect(function()for _,connection in ipairs(connections)do connection:Disconnect()end end)
 refresh()
 return {gui=gui,setPending=function(value)pending=value==true;refresh()end}
end

function M.start(player)
 active=M.create(player:WaitForChild('PlayerGui'),player)
end
function M.setPending(value)
 if active then active.setPending(value)end
end
return M
