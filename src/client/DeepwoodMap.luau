local Players=game:GetService('Players')
local UIS=game:GetService('UserInputService')
local Run=game:GetService('RunService')
local Theme=require(script.Parent.TDInventoryTheme)
local State=require(script.Parent.DeepwoodMapState)
local Canvas=require(script.Parent.DeepwoodMapCanvas)
local Map={}
function Map.start(button)
 local player=Players.LocalPlayer
 local gui=Instance.new('ScreenGui');gui.Name='DeepwoodWorldMap';gui.ResetOnSpawn=false;gui.DisplayOrder=43;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=player:WaitForChild('PlayerGui')
 local panel=Theme.frame(gui,'WorldMap',UDim2.fromScale(.5,.5),UDim2.fromOffset(800,650));panel.AnchorPoint=Vector2.new(.5,.5);panel.BackgroundTransparency=.15;panel.Visible=false
 Theme.label(panel,'Title','DEEPWOOD · WORLD MAP',UDim2.fromOffset(16,10),UDim2.new(1,-84,0,32),18,Theme.color.gold)
 local close=Theme.button(panel,'Close','X',UDim2.new(1,-54,0,8),UDim2.fromOffset(42,42))
 local area=Instance.new('Frame');area.Name='Atlas';area.Position=UDim2.fromOffset(18,60);area.Size=UDim2.new(1,-36,1,-132);area.BackgroundColor3=Color3.fromRGB(8,17,27);area.BorderSizePixel=0;area.ClipsDescendants=true;area.Parent=panel
 local atlas=Canvas.create(area)
 local legend=Theme.label(panel,'Legend','▲ YOU   ◆ CURRENT OBJECTIVE   ◇ CHECKPOINT\nGreen: explored · Dark: unexplored · Locked: finish the previous story',UDim2.new(0,18,1,-65),UDim2.new(1,-36,0,52),12)
 local function open(value)
  value=value and State.current and not State.current.training and player:GetAttribute('K0SessionPhase')=='Tutorial'
  panel.Visible=value==true;player:SetAttribute('TLTMapOpen',panel.Visible)
 end
 if button then button.Activated:Connect(function() open(not panel.Visible) end) end
 close.Activated:Connect(function() open(false) end)
 UIS.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.M then open(not panel.Visible) end end)
 local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  if player:GetAttribute('K0SessionPhase')~='Tutorial' or not State.current or State.current.training then open(false) end
  if not panel.Visible then return end
  local camera=workspace.CurrentCamera;if camera then panel.Size=UDim2.fromOffset(math.min(800,camera.ViewportSize.X-24),math.min(650,camera.ViewportSize.Y-24)) end
  local c=player.Character;local root=c and c:FindFirstChild('HumanoidRootPart');local human=c and c:FindFirstChildOfClass('Humanoid')
  atlas.update(State.current,root and human and human.Health>0 and root or nil,State.target)
 end)
 return {open=open,atlas=atlas,panel=panel}
end
return Map
