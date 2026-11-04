-- A single battle place hosts multiple regions, so artwork is selected independently
-- of gameplay progress. TeleportService carries this GUI only within this experience.
local TeleportService=game:GetService('TeleportService')
local ContentProvider=game:GetService('ContentProvider')
local M={}
local images={
 'rbxassetid://125359077730192', -- Deepwood
 'rbxassetid://119442635735506', -- Frozen Vale
 'rbxassetid://125067552170259', -- Ember Caldera
}
function M.create(index)
 local gui=Instance.new('ScreenGui');gui.Name='TravelLoadingScreen';gui.IgnoreGuiInset=true;gui.ResetOnSpawn=false;gui.DisplayOrder=10000
 local bg=Instance.new('ImageLabel');bg.Name='Background';bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Color3.fromRGB(8,16,30);bg.BorderSizePixel=0;bg.Image=images[index];bg.ScaleType=Enum.ScaleType.Crop;bg.Parent=gui
 local shade=Instance.new('Frame');shade.Name='Shade';shade.BackgroundColor3=Color3.fromRGB(5,12,24);shade.BackgroundTransparency=.4;shade.BorderSizePixel=0;shade.Size=UDim2.fromScale(1,1);shade.Parent=bg
 local label=Instance.new('TextLabel');label.Name='Loading';label.BackgroundTransparency=1;label.AnchorPoint=Vector2.new(1,1);label.Position=UDim2.new(1,-28,1,-28);label.Size=UDim2.fromOffset(210,40);label.Font=Enum.Font.GothamBold;label.Text='LOADING...';label.TextSize=20;label.TextColor3=Color3.new(1,1,1);label.TextStrokeTransparency=.25;label.TextXAlignment=Enum.TextXAlignment.Right;label.Parent=shade
 return gui,bg
end
function M.start(player)
 local gui,bg=M.create(Random.new():NextInteger(1,#images))
 local function register()
  local ok,err=pcall(function() TeleportService:SetTeleportGui(gui) end)
  if not ok then warn('Could not set travel loading screen: '..tostring(err)) end
 end
 register()
 task.spawn(function() pcall(function() ContentProvider:PreloadAsync({bg}) end) end)
 player.OnTeleport:Connect(function(state)
  if state==Enum.TeleportState.Failed then register() end
 end)
end
return M
