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
 local frame=Theme.frame(root,'DeathPenaltyNotice',UDim2.fromScale(.5,.28),UDim2.new(.85,0,0,80));frame.AnchorPoint=Vector2.new(.5,.5);frame.Visible=false;frame.ZIndex=20
 local limit=Instance.new('UISizeConstraint');limit.MaxSize=Vector2.new(600,200);limit.Parent=frame
 local label=Theme.label(frame,'Message','',UDim2.fromOffset(12,8),UDim2.new(1,-24,1,-16),18,Theme.color.text)
 label.Font=Enum.Font.GothamBold;label.TextXAlignment=Enum.TextXAlignment.Center;label.ZIndex=21
 local sequence=0
 local function update()
  sequence+=1;local current=sequence
  local status=player:GetAttribute('TLTDeathXPState')
  local message=Notice.message(status,player:GetAttribute('TLTDeathXPLost'))
  frame.Visible=message~=nil
  if not message then return end
  label.Text=message
  label.TextColor3=status=='Saved' and (player:GetAttribute('TLTDeathXPLost') or 0)>0 and Theme.color.error or Theme.color.text
  local width=math.max(160,math.min(600,root.AbsoluteSize.X*.85)-24)
  local height=TextService:GetTextSize(message,18,Enum.Font.GothamBold,Vector2.new(width,10000)).Y
  frame.Size=UDim2.new(.85,0,0,math.max(64,height+24))
  if status~='Saving' then task.delay(10,function() if current==sequence and frame.Parent then frame.Visible=false end end) end
 end
 local noticeConnection=player:GetAttributeChangedSignal('TLTDeathXPNotice'):Connect(update)
 frame.Destroying:Connect(function() noticeConnection:Disconnect() end)
 root:GetPropertyChangedSignal('AbsoluteSize'):Connect(function() if frame.Visible then update() end end)
 update()
 return frame
end
return Notice
