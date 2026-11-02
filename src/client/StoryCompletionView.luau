-- TD completion card with a brief gold accent; it never pauses combat or starts a mission.
local Theme=require(script.Parent.TDInventoryTheme)
local Text=require(game.ReplicatedStorage.Shared.StoryCompletion).text
local Tween=game:GetService('TweenService');local GuiService=game:GetService('GuiService')
local View={}
function View.create(parent,onContinue)
 local panel=Theme.frame(parent,'StoryCompletion',UDim2.fromScale(.5,.5),UDim2.fromOffset(660,440));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false;panel.ZIndex=10
 local scale=Instance.new('UIScale');scale.Parent=panel
 local heading=Theme.label(panel,'Heading','',UDim2.fromOffset(20,14),UDim2.new(1,-116,0,30),22,Theme.color.gold)
 local close=Theme.button(panel,'Close',Text.close,UDim2.new(1,-92,0,12),UDim2.fromOffset(76,44))
 local accent=Instance.new('Frame');accent.Name='CompletionAccent';accent.BorderSizePixel=0;accent.BackgroundColor3=Theme.color.gold;accent.Position=UDim2.fromOffset(20,52);accent.Size=UDim2.new(1,-40,0,3);accent.Parent=panel
 local list=Instance.new('ScrollingFrame');list.Name='Summary';list.Position=UDim2.fromOffset(20,66);list.Size=UDim2.new(1,-40,1,-136);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=6;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,9);layout.Parent=list
 local button=Theme.button(panel,'Continue','',UDim2.new(0,20,1,-60),UDim2.new(1,-40,0,44),true)
 local api={panel=panel,button=button};local current;local previousSelection;local tweens={}
 local function stop()for _,t in ipairs(tweens)do t:Cancel()end;table.clear(tweens)end
 local function render()
  if not current then return end
  heading.Text=current.heading;heading.TextSize=panel.Size.X.Offset<550 and 18 or 22;button.Caption.Text=current.action
  for _,v in ipairs(list:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end
  local lines={{current.title,18,Theme.color.gold},{current.outcome,14},{current.reward,17,Theme.color.green},{current.saved,12},
   {current.nextTitle,17,Theme.color.gold},{current.region,13},{current.objective,14},{current.guidance,14},{current.support,13,Theme.color.gold}}
  for i,row in ipairs(lines)do if row[1] and row[1]~='' then
   local h=game.TextService:GetTextSize(row[1],row[2],Enum.Font.GothamMedium,Vector2.new(math.max(180,panel.Size.X.Offset-68),2000)).Y+8
   local label=Theme.label(list,'Line'..i,row[1],UDim2.new(),UDim2.new(1,-16,0,h),row[2],row[3]);label.LayoutOrder=i;label.TextYAlignment=Enum.TextYAlignment.Top
  end end
 end
 function api:resize(w,h)panel.Size=UDim2.fromOffset(math.min(680,math.max(280,w-24)),math.min(480,math.max(240,h-24)));render()end
 function api:dismiss()
  stop();panel.Visible=false
  local chosen=GuiService.SelectedObject
  if chosen and chosen:IsDescendantOf(panel)then GuiService.SelectedObject=previousSelection and previousSelection.Parent and previousSelection or nil end
  previousSelection=nil
 end
 function api:show(data)
  self:dismiss();current=data
  local camera=workspace.CurrentCamera;if camera then self:resize(camera.ViewportSize.X,camera.ViewportSize.Y)else render()end
  list.CanvasPosition=Vector2.zero;panel.Visible=true;scale.Scale=.96;accent.BackgroundTransparency=.65
  tweens={Tween:Create(scale,TweenInfo.new(.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1}),Tween:Create(accent,TweenInfo.new(.45),{BackgroundTransparency=0})}
  for _,t in ipairs(tweens)do t:Play()end
  if game.UserInputService.GamepadEnabled then previousSelection=GuiService.SelectedObject;GuiService.SelectedObject=button end
 end
 button.Activated:Connect(function()local value=current;api:dismiss();if value and onContinue then onContinue(value.nextId)end end)
 close.Activated:Connect(function()api:dismiss()end)
 local input=game.UserInputService.InputBegan:Connect(function(event)
  if panel.Visible and (event.KeyCode==Enum.KeyCode.Escape or event.KeyCode==Enum.KeyCode.ButtonB)then api:dismiss()end
 end)
 local resize=parent:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()if panel.Visible then local c=workspace.CurrentCamera;if c then api:resize(c.ViewportSize.X,c.ViewportSize.Y)end end end)
 function api:destroy()self:dismiss();input:Disconnect();resize:Disconnect();panel:Destroy()end
 return api
end
return View
