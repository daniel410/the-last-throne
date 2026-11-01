-- Same shell, revive emblem and safe-area position as TD's ReopenRejoin launcher.
local T=require(script.Parent.TDInventoryTheme)
local Chrome=require(game:GetService('ReplicatedStorage').Shared.TDUI.BattleChromeArtAssets)
local M={}
function M.create(parent,checkRejoin)
 local button=T.button(parent,'ReopenRejoin','CHECK REJOIN',UDim2.fromOffset(12,12),UDim2.fromOffset(136,44))
 button.BackgroundTransparency=1
 button:SetAttribute('ChromeControl','rejoin')
 button.TDButtonArt.SliceScale=.45
 local emblem=T.sprite(button,'RejoinEmblem','revive',UDim2.new(0,10,.5,0),UDim2.fromOffset(28,28),Chrome)
 emblem.AnchorPoint=Vector2.new(0,.5)
 button.Caption.Position=UDim2.fromOffset(48,4)
 button.Caption.Size=UDim2.new(1,-72,1,-8)
 button.Caption.Font=Enum.Font.GothamBold;button.Caption.TextSize=16
 button.Caption.TextColor3=Color3.new(1,1,1)
 button.Caption.TextStrokeColor3=Color3.fromRGB(8,16,30);button.Caption.TextStrokeTransparency=.1
 button.Activated:Connect(function()if button.Visible and button.Active then checkRejoin()end end)
 return button
end
return M
