-- Keep lobby menu targets aligned while fitting narrow viewports.
local M={}
function M.bind(gui,button,index)
 local function layout()
  local width=math.min(176,math.max(44,math.floor(((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1280)-30)/3)))
  button.Size=UDim2.fromOffset(width,44)
  button.Position=UDim2.new(1,-14-width-(index-1)*(width+8),0,0)
 end
 if button.Name=='OpenHero' or button.Name=='OpenBag' or button.Name=='OpenSettings' then
  button.Caption.TextScaled=true
  local cap=Instance.new('UITextSizeConstraint');cap.MaxTextSize=14;cap.MinTextSize=10;cap.Parent=button.Caption
 end
 local connection
 local function cameraChanged()
  if connection then connection:Disconnect() end
  local camera=workspace.CurrentCamera
  if camera then connection=camera:GetPropertyChangedSignal('ViewportSize'):Connect(layout) end
  layout()
 end
 local cameraConnection=workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(cameraChanged)
 gui.Destroying:Connect(function() cameraConnection:Disconnect();if connection then connection:Disconnect() end end)
 cameraChanged()
end
return M
