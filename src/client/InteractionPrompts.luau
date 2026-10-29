-- Stable authored key labels: Roblox's keyboard-layout label can render F as ㄹ.
-- Native prompts still own keyboard/gamepad timing and server Triggered validation.
local Prompts=game:GetService('ProximityPromptService')
local Players=game:GetService('Players')
local TweenService=game:GetService('TweenService')
local UI={}
function UI.start()
 local guiParent=Players.LocalPlayer:WaitForChild('PlayerGui')
 local views={}
 local function remove(prompt)
  local view=views[prompt];if not view then return end
  if view.tween then view.tween:Cancel() end
  for _,c in ipairs(view.connections) do c:Disconnect() end
  view.gui:Destroy();views[prompt]=nil
 end
 Prompts.PromptShown:Connect(function(prompt,inputType)
  if prompt.Style~=Enum.ProximityPromptStyle.Custom then return end
  remove(prompt)
  local gui=Instance.new('BillboardGui');gui.Name='InteractionPrompt';gui.Adornee=prompt.Parent;gui.Size=UDim2.fromOffset(340,88);gui.AlwaysOnTop=true;gui.Active=true;gui.StudsOffsetWorldSpace=Vector3.new(0,2.5,0);gui.Parent=guiParent
  local frame=Instance.new('Frame');frame.Size=UDim2.fromScale(1,1);frame.BackgroundColor3=Color3.fromRGB(8,16,28);frame.BackgroundTransparency=.18;frame.BorderSizePixel=0;frame.Parent=gui
  local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,12);corner.Parent=frame
  local function label(name,text,position,size,fontSize,color)
   local t=Instance.new('TextLabel');t.Name=name;t.Text=text;t.Position=position;t.Size=size;t.BackgroundTransparency=1;t.TextColor3=color or Color3.fromRGB(248,244,226);t.Font=Enum.Font.GothamBold;t.TextSize=fontSize;t.TextXAlignment=Enum.TextXAlignment.Left;t.TextWrapped=true;t.AutoLocalize=false;t.Parent=frame;return t
  end
  local key
  if inputType==Enum.ProximityPromptInputType.Touch then key='TOUCH'
  elseif inputType==Enum.ProximityPromptInputType.Gamepad then key=prompt.GamepadKeyCode.Name:gsub('^Button','')
  else key=prompt.KeyboardKeyCode.Name end
  local keyLabel=label('Key',key,UDim2.fromOffset(8,8),UDim2.fromOffset(64,43),28);keyLabel.TextXAlignment=Enum.TextXAlignment.Center
  local verb=label('Method',prompt.HoldDuration>0 and 'HOLD' or 'PRESS',UDim2.fromOffset(8,49),UDim2.fromOffset(64,24),11,Color3.fromRGB(229,189,101));verb.TextXAlignment=Enum.TextXAlignment.Center
  label('Object',prompt.ObjectText,UDim2.fromOffset(84,8),UDim2.new(1,-96,0,28),12,Color3.fromRGB(177,192,204))
  label('Action',prompt.ActionText,UDim2.fromOffset(84,36),UDim2.new(1,-96,0,36),16)
  local fill=Instance.new('Frame');fill.Name='HoldProgress';fill.Position=UDim2.new(0,0,1,-4);fill.Size=UDim2.new(0,0,0,4);fill.BackgroundColor3=Color3.fromRGB(229,189,101);fill.BorderSizePixel=0;fill.Parent=frame
  local button=Instance.new('TextButton');button.Name='HoldButton';button.Text='';button.BackgroundTransparency=1;button.Size=UDim2.fromScale(1,1);button.Parent=frame
  local view={gui=gui,connections={}};views[prompt]=view
  local function reset()
   if view.tween then view.tween:Cancel();view.tween=nil end;fill.Size=UDim2.new(0,0,0,4)
  end
  table.insert(view.connections,prompt.PromptButtonHoldBegan:Connect(function()
   reset();view.tween=TweenService:Create(fill,TweenInfo.new(prompt.HoldDuration,Enum.EasingStyle.Linear),{Size=UDim2.new(1,0,0,4)});view.tween:Play()
  end))
  table.insert(view.connections,prompt.PromptButtonHoldEnded:Connect(reset))
  table.insert(view.connections,prompt.Triggered:Connect(reset))
  local holding=false
  local function release() if holding then holding=false;prompt:InputHoldEnd() end end
  table.insert(view.connections,button.InputBegan:Connect(function(input)
   if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then holding=true;prompt:InputHoldBegin() end
  end))
  table.insert(view.connections,button.InputEnded:Connect(release))
  table.insert(view.connections,button.MouseLeave:Connect(release))
 end)
 Prompts.PromptHidden:Connect(remove)
end
return UI
