-- TD presentation only; the server supplies saved recruitment and live support status.
local Theme=require(script.Parent.TDInventoryTheme)
local Text=require(game.ReplicatedStorage.Shared.SupporterText)
local View={}
function View.create(parent,buy)
 local player=game:GetService('Players').LocalPlayer
 local gui=Instance.new('ScreenGui');gui.Name='SupporterDetails';gui.ResetOnSpawn=false;gui.DisplayOrder=70;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local panel=Theme.frame(gui,'SupporterPanel',UDim2.fromScale(.5,.5),UDim2.fromOffset(700,510));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false;panel.Active=true
 local title=Theme.label(panel,'Title',Text.title,UDim2.fromOffset(18,12),UDim2.new(1,-98,0,32),18,Theme.color.gold)
 local close=Theme.button(panel,'Close',Text.close,UDim2.new(1,-88,0,10),UDim2.fromOffset(76,40))
 local portrait=Theme.icon(panel,'nun',UDim2.fromOffset(18,58),UDim2.fromOffset(76,76))
 local name=Theme.label(panel,'Name','',UDim2.fromOffset(108,58),UDim2.new(1,-126,0,28),19,Theme.color.gold)
 local role=Theme.label(panel,'Role','',UDim2.fromOffset(108,88),UDim2.new(1,-126,0,38),13)
 local list=Instance.new('ScrollingFrame');list.Name='Information';list.Position=UDim2.fromOffset(18,144);list.Size=UDim2.new(1,-36,1,-162);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=6;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,10);layout.Parent=list
 local api={gui=gui,panel=panel,close=close};local previous;local data;local pending=false
 local offers=require(game.ReplicatedStorage.Shared.SupportPassRules).offers
 local terms=Theme.label(panel,'PurchaseTerms',Text.purchaseTerms,UDim2.new(0,18,1,-124),UDim2.new(1,-36,0,44),11,Theme.color.gold);terms.Visible=false
 local buttons={}
 for i,offer in ipairs(offers)do
  local button=Theme.button(panel,'Buy'..offer.stories,string.format(Text.purchase,offer.stories,offer.stories==1 and '' or 'S',offer.price),UDim2.new((i-1)/3,18,1,-74),UDim2.new(1/3,-24,0,56),true)
  button.Caption.TextSize=12;button.Visible=false;buttons[i]=button
  button.Activated:Connect(function()if buy and data and data.canBuy and not pending then buy(offer,data)end end)
 end
 local function render()
  if not data then return end
  name.Text=data.name;role.Text=data.role
  for _,v in ipairs(list:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end
  local lines={data.status}
  if data.pass then
   table.insert(lines,string.format(Text.account,data.pass.credits,data.pass.story))
   if data.pass.active then table.insert(lines,string.format(Text.activeStory,data.pass.story))end
  end
  if data.lobby then table.insert(lines,data.balance~=nil and string.format(Text.balance,data.balance) or Text.balanceUnknown)end
  if data.message then table.insert(lines,data.message)end
  list.Size=UDim2.new(1,-36,1,data.lobby and -280 or -162)
  terms.Visible=data.lobby==true
  for i,button in ipairs(buttons)do
   button.Visible=data.lobby==true
   Theme.enabled(button,data.canBuy==true and not pending and (data.balance or 0)>=offers[i].price)
  end
  for _,line in ipairs(data.lines)do table.insert(lines,line)end
  local width=math.max(180,panel.Size.X.Offset-54)
  for i,line in ipairs(lines)do
   local size=i==1 and 14 or 13
   local h=game:GetService('TextService'):GetTextSize(line,size,Enum.Font.GothamMedium,Vector2.new(width,2000)).Y+8
   local label=Theme.label(list,'Info'..i,line,UDim2.new(),UDim2.new(1,-12,0,h),size,i==1 and Theme.color.gold or Theme.color.text)
   label.LayoutOrder=i;label.TextYAlignment=Enum.TextYAlignment.Top
  end
 end
 function api:resize(width,height)
  local short=height<440
  panel.Size=UDim2.fromOffset(math.max(260,math.min(760,width-(short and 24 or 80))),math.max(240,math.min(540,height-(short and 24 or 90))))
  render()
 end
 function api:setPending(value)pending=value==true;render()end
 function api:dismiss()
  panel.Visible=false;if player then player:SetAttribute('TLTSupporterOpen',false)end
  local service=game:GetService('GuiService')
  if service.SelectedObject==close then service.SelectedObject=previous and previous.Parent and previous or nil end
  previous=nil
 end
 function api:open(value)
  if type(value)~='table' or value.id~='selene' or type(value.lines)~='table' then return false end
  data=value;panel.Visible=true;if player then player:SetAttribute('TLTSupporterOpen',true)end;list.CanvasPosition=Vector2.zero
  local camera=workspace.CurrentCamera;if camera then self:resize(camera.ViewportSize.X,camera.ViewportSize.Y)else render()end
  if game:GetService('UserInputService').GamepadEnabled then
   if game:GetService('GuiService').SelectedObject~=close then previous=game:GetService('GuiService').SelectedObject end
   game:GetService('GuiService').SelectedObject=close
  end
  return true
 end
 function api:update(value)
  if panel.Visible and value and value.id=='selene' and (not data or data.key~=value.key or data.following~=value.following or data.unlocked~=value.unlocked or (data.pass and data.pass.credits)~=(value.pass and value.pass.credits))then
   local position=list.CanvasPosition;data=value;render()
   task.defer(function()if list.Parent then list.CanvasPosition=position end end)
  end
 end
 close.Activated:Connect(function()api:dismiss()end)
 local input=game:GetService('UserInputService').InputBegan:Connect(function(event)
  if panel.Visible and (event.KeyCode==Enum.KeyCode.Escape or event.KeyCode==Enum.KeyCode.ButtonB)then api:dismiss()end
 end)
 local viewport=gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()if panel.Visible then api:resize(gui.AbsoluteSize.X,gui.AbsoluteSize.Y)end end)
 function api:destroy()self:dismiss();input:Disconnect();viewport:Disconnect();gui:Destroy()end
 return api
end
return View
