-- Dedicated death receipt notice; ordinary quest/combat feedback cannot overwrite it.
local Text=require(game:GetService('ReplicatedStorage').Shared.K0Text)
local TextService=game:GetService('TextService')
local Theme=require(script.Parent.TDInventoryTheme)
local Notice={}
function Notice.message(status,lost)
 if status=='Saved' and type(lost)=='number' then return string.format(Text.DeathXPLost,lost) end
 if status=='Training' then return Text.DeathXPTraining end
 if status=='Saving' then return Text.DeathXPSaving end
 if status=='Unavailable' then return Text.DeathXPUnavailable end
 return nil
end
function Notice.create(root,player)
 local frame=Instance.new('Frame');frame.Name='DeathPenaltyNotice';frame.Position=UDim2.fromScale(.5,.28);frame.Size=UDim2.new(.85,0,0,120);frame.AnchorPoint=Vector2.new(.5,.5);frame.BackgroundTransparency=1;frame.Visible=false;frame.ZIndex=20;frame.Parent=root
 local limit=Instance.new('UISizeConstraint');limit.MaxSize=Vector2.new(600,250);limit.Parent=frame
 local label=Theme.label(frame,'Message','',UDim2.fromOffset(12,8),UDim2.new(1,-24,1,-64),18,Theme.color.text)
 label.Font=Enum.Font.GothamBold;label.TextXAlignment=Enum.TextXAlignment.Center;label.TextStrokeTransparency=0;label.ZIndex=21
 local confirm=Theme.button(frame,'Confirm',Text.DeathNoticeConfirm,UDim2.new(.5,-60,1,-48),UDim2.fromOffset(120,40))
 confirm.ZIndex=21;confirm.TDButtonArt.ZIndex=22;confirm.Caption.ZIndex=23
 confirm.Activated:Connect(function() frame.Visible=false end)
 local function layout()
  local width=math.max(160,math.min(600,root.AbsoluteSize.X*.85)-24)
  local height=TextService:GetTextSize(label.Text,18,Enum.Font.GothamBold,Vector2.new(width,10000)).Y
  frame.Size=UDim2.new(.85,0,0,math.max(104,height+72))
 end
 local function update()
  local status=player:GetAttribute('TLTDeathXPState')
  local message=Notice.message(status,player:GetAttribute('TLTDeathXPLost'))
  frame.Visible=message~=nil
  if not message then return end
  label.Text=message
  label.TextColor3=status=='Saved' and (player:GetAttribute('TLTDeathXPLost') or 0)>0 and Theme.color.error or Theme.color.text
  layout()
 end
 local noticeConnection=player:GetAttributeChangedSignal('TLTDeathXPNotice'):Connect(update)
 local sizeConnection=root:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() if frame.Visible then layout() end end)
 frame.Destroying:Connect(function() noticeConnection:Disconnect();sizeConnection:Disconnect() end)
 update()
 return frame
end
return Notice
