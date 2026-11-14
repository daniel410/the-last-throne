local RS=game:GetService('ReplicatedStorage')
local Http=game:GetService('HttpService')
local T=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Copy=require(RS.Shared.DeliveryText)
local Catalog=require(RS.Shared.ItemCatalog)
local V={}
function V.create(parent,send)
 local function frame(name,title,icon)
  local panel=Menu.frame(parent,name,UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100))
  panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
  require(script.Parent.LobbyPanelLayout).bind(panel)
  T.icon(panel,icon,UDim2.fromOffset(20,10),UDim2.fromOffset(32,32))
  T.label(panel,'Title',title,UDim2.fromOffset(60,10),UDim2.new(1,-145,0,32),20,T.color.gold)
  T.button(panel,'Close',Copy.Close,UDim2.new(1,-60,0,8),UDim2.fromOffset(44,44)).Activated:Connect(function()panel.Visible=false end)
  local status=T.label(panel,'Status','',UDim2.new(0,20,1,-100),UDim2.new(1,-40,0,42),12,T.color.muted)
  return panel,status
 end
 local redeem,redeemStatus=frame('RedeemCode',Copy.RedeemTitle,'redeem')
 local mailbox,mailStatus=frame('Mailbox',Copy.MailTitle,'mailbox')
 local input=Instance.new('TextBox');input.Name='Code';input.Position=UDim2.fromOffset(20,66)
 input.Size=UDim2.new(1,-40,0,46);input.BackgroundColor3=T.color.ink;input.TextColor3=T.color.text
 input.PlaceholderText=Copy.CodeHint;input.PlaceholderColor3=T.color.muted;input.Text='';input.ClearTextOnFocus=false
 input.AutoLocalize=false;input.MultiLine=false;input.Font=Enum.Font.GothamMedium;input.TextSize=16;input.TextTruncate=Enum.TextTruncate.AtEnd;input.Parent=redeem
 input:GetPropertyChangedSignal('Text'):Connect(function()if #input.Text>64 then input.Text=input.Text:sub(1,64)end end)
 local redeemButton=T.button(redeem,'Redeem',Copy.Redeem,UDim2.new(0,20,1,-54),UDim2.new(1,-40,0,44),true)
 local list=Instance.new('ScrollingFrame');list.Name='Messages';list.Position=UDim2.fromOffset(20,58)
 list.Size=UDim2.new(1,-40,1,-166);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=6
 list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=mailbox
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,12);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local refresh=T.button(mailbox,'Refresh',Copy.Refresh,UDim2.new(0,20,1,-54),UDim2.new(1,-40,0,44))
 local state={status='Loading',mails={}};local pending,waiting,feedback=nil,false,''
 local render
 local function requestState()send({action='GetState'})end
 local function transmit()
  if waiting or not pending then return end
  waiting=true;feedback='';local command=pending
  send(command);render()
  task.delay(10,function()
   if pending==command and waiting then waiting=false;feedback=Copy.SaveUnknown;render()end
  end)
 end
 local function submit(action,value)
  if waiting then return end
  if pending then transmit();return end
  if state.status~='Ready'then requestState();return end
  if action=='Redeem'and (type(value)~='string'or not value:match('%S'))then feedback=Copy.InvalidRequest;render();return end
  pending={action=action,value=value,requestId=Http:GenerateGUID(false):gsub('%-','')};transmit()
 end
 local function rewardsText(rewards)
  local parts={}
  if (rewards.gold or 0)>0 then table.insert(parts,string.format(Copy.Gold,rewards.gold))end
  if (rewards.diamonds or 0)>0 then table.insert(parts,string.format(Copy.Diamonds,rewards.diamonds))end
  for _,item in ipairs(rewards.items or {})do
   local def=Catalog.items[item.definitionId]
   table.insert(parts,string.format(Copy.Item,def and (def.displayName or def.name)or item.definitionId,item.quantity))
  end
  return table.concat(parts,' · ')
 end
 render=function()
  local message=feedback~=''and feedback or Copy[state.status]or (state.status~='Ready'and Copy.Unavailable or '')
  redeemStatus.Text=message;mailStatus.Text=message
  redeemButton.Caption.Text=waiting and Copy.Sending or pending and Copy.Check or Copy.Redeem
  refresh.Caption.Text=waiting and Copy.Sending or pending and Copy.Check or Copy.Refresh
  T.enabled(redeemButton,not waiting);T.enabled(refresh,not waiting)
  input.TextEditable=not pending
  for _,child in ipairs(list:GetChildren())do if child:IsA('GuiObject')then child:Destroy()end end
  if #(state.mails or {})==0 then
   T.label(list,'Empty',state.status=='Ready'and Copy.Empty or Copy.Loading,UDim2.new(),UDim2.new(1,-12,0,48),14,T.color.muted)
  end
  for i,mail in ipairs(state.mails or {})do
   local card=Instance.new('Frame');card.Name='Mail_'..mail.id;card.BackgroundTransparency=1
   card.Size=UDim2.new(1,-12,0,0);card.AutomaticSize=Enum.AutomaticSize.Y;card.LayoutOrder=i;card.Parent=list
   local rows=Instance.new('UIListLayout');rows.Padding=UDim.new(0,6);rows.SortOrder=Enum.SortOrder.LayoutOrder;rows.Parent=card
   local function line(name,text,size,color,order)
    local label=T.label(card,name,text,UDim2.new(),UDim2.new(1,-4,0,0),size,color)
    label.AutomaticSize=Enum.AutomaticSize.Y;label.TextWrapped=true;label.TextYAlignment=Enum.TextYAlignment.Top;label.LayoutOrder=order
    return label
   end
   line('Title',mail.title,17,T.color.gold,1)
   line('Sender',mail.sender or 'The Last Throne Team',12,T.color.muted,2)
   line('Body',mail.body,14,T.color.text,3)
   local reward=rewardsText(mail.rewards or {})
   if reward~=''then line('Rewards',reward,13,T.color.gold,4)end
   local button=T.button(card,'Claim',mail.claimed and Copy.Claimed or reward~=''and Copy.Claim or Copy.Read,UDim2.new(),UDim2.new(1,-4,0,44),true)
   button.LayoutOrder=5;T.enabled(button,not mail.claimed and not pending and state.status=='Ready')
   button.Activated:Connect(function()if not mail.claimed then submit('ClaimMail',mail.id)end end)
  end
 end
 redeemButton.Activated:Connect(function()submit('Redeem',input.Text)end)
 input.FocusLost:Connect(function(enter)if enter then submit('Redeem',input.Text)end end)
 refresh.Activated:Connect(function()if pending then transmit()else requestState()end end)
 local function receive(data)
  if type(data)~='table'or type(data.state)~='table'then return end
  if pending and data.requestId~=pending.requestId then return end
  state=data.state
  if pending and data.requestId==pending.requestId then
   waiting=false
   if data.claimed then
    feedback=pending.action=='ClaimMail'and Copy.ReadSuccess or Copy.Success
    pending=nil
   elseif data.error=='SaveUnknown'or data.error=='Busy'or data.error=='AccountBusy'then feedback=Copy[data.error]
   else feedback=Copy[data.error]or Copy.Unavailable;pending=nil end
  else feedback=''end
  render()
 end
 render()
 task.spawn(function()
  while parent.Parent do
   task.wait(3)
   if (mailbox.Visible or redeem.Visible)and not pending and (state.status=='Loading'or state.status=='Busy')then requestState()end
  end
 end)
 return {panels={redeem,mailbox},receive=receive,open=function(kind)
  (kind=='Mailbox'and mailbox or redeem).Visible=true;requestState()
 end,close=function()redeem.Visible=false;mailbox.Visible=false end}
end
return V
