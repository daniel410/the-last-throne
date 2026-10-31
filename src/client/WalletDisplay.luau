-- Shared read-only view of server inventory snapshots. No panel or input target.
local Theme=require(script.Parent.TDInventoryTheme)
local Text=require(game:GetService('ReplicatedStorage').Shared.LobbyText)
local Wallet={}
local views=setmetatable({},{__mode='k'})
local current
local function render(frame)
 local wallet=current and current.ready and current.wallet
 for _,item in ipairs({{'Gold','gold'},{'Diamonds','diamonds'}}) do
  frame[item[1]].Text=string.format('%s  %s',Text[item[1]],wallet and tostring(wallet[item[2]]) or '—')
 end
end
function Wallet.update(snapshot)
 current=snapshot
 for frame in pairs(views) do if frame.Parent then render(frame) end end
end
function Wallet.create(parent)
 local frame=Instance.new('Frame');frame.Name='Wallet';frame.BackgroundTransparency=1;frame.BorderSizePixel=0;frame.Size=UDim2.fromOffset(208,56);frame.Active=false;frame.Parent=parent
 for i,item in ipairs({{'Gold','gold',Theme.color.gold},{'Diamonds','diamonds',Color3.fromRGB(164,221,255)}}) do
  Theme.icon(frame,item[2],UDim2.fromOffset(2,(i-1)*28),UDim2.fromOffset(24,24))
  local label=Theme.label(frame,item[1],'',UDim2.fromOffset(32,(i-1)*28),UDim2.new(1,-34,0,26),17,item[3])
  label.Font=Enum.Font.GothamBold;label.TextXAlignment=Enum.TextXAlignment.Right;label.TextWrapped=false;label.TextScaled=true;label.TextStrokeTransparency=.25;label.TextStrokeColor3=Color3.fromRGB(15,24,30)
  local limits=Instance.new('UITextSizeConstraint');limits.MinTextSize=12;limits.MaxTextSize=17;limits.Parent=label
 end
 views[frame]=true;render(frame);return frame
end
return Wallet
