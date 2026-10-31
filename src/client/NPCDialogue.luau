-- Local closeable conversation; no reward, unlock or transaction authority.
local D={}
function D.start()
 local Players=game:GetService('Players');local RS=game:GetService('ReplicatedStorage');local UIS=game:GetService('UserInputService')
 local gui=Instance.new('ScreenGui');gui.Name='NPCDialogue';gui.ResetOnSpawn=false;gui.DisplayOrder=65;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=Players.LocalPlayer:WaitForChild('PlayerGui')
 local panel=Instance.new('Frame');panel.Name='Conversation';panel.AnchorPoint=Vector2.new(.5,1);panel.Position=UDim2.new(.5,0,1,-136);panel.Size=UDim2.new(.9,0,0,180);panel.BackgroundColor3=Color3.fromRGB(21,31,44);panel.Visible=false;panel.Parent=gui
 local bounds=Instance.new('UISizeConstraint');bounds.MaxSize=Vector2.new(610,180);bounds.Parent=panel
 local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(0,12);corner.Parent=panel
 local border=Instance.new('UIStroke');border.Color=Color3.fromRGB(206,174,105);border.Thickness=2;border.Parent=panel
 local function label(name,pos,size,font,textSize)
  local t=Instance.new('TextLabel');t.Name=name;t.Position=pos;t.Size=size;t.BackgroundTransparency=1;t.Font=font;t.TextSize=textSize;t.TextColor3=Color3.fromRGB(247,237,212);t.TextXAlignment=Enum.TextXAlignment.Left;t.TextYAlignment=Enum.TextYAlignment.Top;t.TextWrapped=true;t.AutoLocalize=false;t.Parent=panel;return t
 end
 local title=label('Speaker',UDim2.fromOffset(18,14),UDim2.new(1,-96,0,25),Enum.Font.GothamBold,17)
 local text=label('Dialogue',UDim2.fromOffset(18,50),UDim2.new(1,-36,1,-64),Enum.Font.Gotham,16)
 local close=Instance.new('TextButton');close.Name='Close';close.Text='CLOSE';close.AutoLocalize=false;close.Font=Enum.Font.GothamBold;close.TextSize=12;close.TextColor3=Color3.fromRGB(247,237,212);close.BackgroundColor3=Color3.fromRGB(47,65,84);close.Size=UDim2.fromOffset(68,44);close.Position=UDim2.new(1,-76,0,4);close.Parent=panel
 local previous
 local function dismiss()
  panel.Visible=false
  local service=game:GetService('GuiService')
  if service.SelectedObject==close then service.SelectedObject=previous and previous.Parent and previous or nil end
  previous=nil
 end
 close.Activated:Connect(dismiss)
 UIS.InputBegan:Connect(function(input) if panel.Visible and (input.KeyCode==Enum.KeyCode.ButtonB or input.KeyCode==Enum.KeyCode.Escape) then dismiss() end end)
 RS:WaitForChild('Remotes'):WaitForChild('NPCDialogue').OnClientEvent:Connect(function(data)
  title.Text=data.name..' · '..data.role;text.Text=data.text;panel.Visible=true
  if UIS.GamepadEnabled then previous=game:GetService('GuiService').SelectedObject;game:GetService('GuiService').SelectedObject=close end
 end)
 Players.LocalPlayer:GetAttributeChangedSignal('K0SessionPhase'):Connect(dismiss)
end
return D
