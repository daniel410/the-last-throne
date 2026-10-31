-- Keep lobby menu targets aligned while fitting narrow viewports.
local M={}
function M.bind(gui,button,index)
 local function layout()
  local width=math.min(128,math.max(44,math.floor(((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1280)-30)/3)))
  button.Size=UDim2.fromOffset(width,44)
  button.Position=UDim2.new(1,-14-width-(index-1)*(width+8),0,0)
 end
 local connection
 local function cameraChanged()
  if connection then connection:Disconnect() end
  local camera=workspace.CurrentCamera
  if camera then connection=camera:GetPropertyChangedSignal('ViewportSize'):Connect(layout) end
  layout()
 end
 workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(cameraChanged)
 cameraChanged()
end
return M
