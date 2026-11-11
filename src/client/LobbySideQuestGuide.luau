-- Personal TD-themed guide, world marker and local directions; server owns all rewards.
local RS=game:GetService('ReplicatedStorage')
local S=require(RS.Shared.LobbySideQuests)
local Design=require(RS.Shared.DawnspireDesign)
local Text=require(RS.Shared.LobbySideQuestText)
local T=require(script.Parent.TDInventoryTheme)
local Chrome=require(script.Parent.LobbyChromeVisibility)
local Guide={}
function Guide.create(parent,options)
 local player=options.player or game.Players.LocalPlayer
 local snapshot,state,pending,marker,target,highlight
 local seen,showAll,showMap={},false,false
 local findingUntil=0
 local panel=T.frame(parent,'LobbySideQuestGuide',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 require(script.Parent.LobbyPanelLayout).bind(panel,player)
 local title=T.label(panel,'Title',Text.title,UDim2.fromOffset(16,10),UDim2.new(1,-80,0,36),18,T.color.gold)
 title.TextTruncate=Enum.TextTruncate.AtEnd;title.TextWrapped=false
 local close=T.button(panel,'Close','X',UDim2.new(1,-56,0,8),UDim2.fromOffset(44,44))
 local list=Instance.new('ScrollingFrame');list.Name='Requests';list.Position=UDim2.fromOffset(12,58);list.Size=UDim2.new(1,-24,1,-118);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=5;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local all=T.button(panel,'ViewAll',Text.all,UDim2.new(0,12,1,-52),UDim2.new(.5,-18,0,44))
 local find=T.button(panel,'FindTessa',Text.find,UDim2.new(.5,6,1,-52),UDim2.new(.5,-18,0,44))
 local toast=T.frame(parent,'SideQuestNotice',UDim2.new(.5,0,0,12),UDim2.new(1,-24,0,116));toast.AnchorPoint=Vector2.new(.5,0);toast.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(520,116);cap.Parent=toast
 local message=T.label(toast,'Message','',UDim2.fromOffset(12,6),UDim2.new(1,-24,0,48),14,T.color.gold)
 local toastFind=T.button(toast,'FindTessa',Text.find,UDim2.fromOffset(12,62),UDim2.new(.6,-18,0,44))
 local later=T.button(toast,'Later',Text.later,UDim2.new(.6,6,0,62),UDim2.new(.4,-18,0,44))
 local status='';local render,updateWorld,refresh
 local function lobby()return player and player:GetAttribute('K0SessionPhase')=='Lobby'and workspace:GetAttribute('TLTServerRole')~='Battle'end
 local function send(command)
  if pending or not state or not state.heroId then return end
  command.heroId=state.heroId;command.requestId=game:GetService('HttpService'):GenerateGUID(false):gsub('%-','')
  pending=command;status=Text.saving;if render then render()end
  options.send(command)
  task.spawn(function()
   while panel.Parent and pending==command do task.wait(2);if pending==command then options.send(command)end end
  end)
 end
 local function dismiss()
  panel.Visible=false
  local gs=game:GetService('GuiService');if gs.SelectedObject and gs.SelectedObject:IsDescendantOf(panel)then gs.SelectedObject=nil end
 end
 close.Activated:Connect(dismiss)
 local function open(map)
  if not lobby()then return end
  options.close();toast.Visible=false;showMap=map==true;if showMap then findingUntil=os.clock()+30 end;showAll=false;panel.Visible=true;render()
  if game:GetService('UserInputService').GamepadEnabled then game:GetService('GuiService').SelectedObject=close end
 end
 local function line(host,name,text,y,height,size,color)
  local v=T.label(host,name,text,UDim2.fromOffset(12,y),UDim2.new(1,-24,0,height),size or 13,color or T.color.text);v.TextYAlignment=Enum.TextYAlignment.Top;return v
 end
 local function height(text,size,width)
  return math.max(size+6,game:GetService('TextService'):GetTextSize(text,size,Enum.Font.GothamMedium,Vector2.new(math.max(100,width),10000)).Y+8)
 end
 local function mapCard()
  local box=T.frame(list,'DawnspireMap',UDim2.new(),UDim2.new(1,-8,0,256));box.LayoutOrder=0
  line(box,'MapTitle',Text.mapTitle,8,26,14,T.color.gold)
  local area=Instance.new('Frame');area.Name='Courtyard';area.Position=UDim2.fromOffset(12,38);area.Size=UDim2.new(1,-24,0,152);area.BackgroundColor3=T.color.ink;area.BorderSizePixel=0;area.Parent=box
  local function dot(name,caption,x,z,color)
   local v=T.button(area,name,caption,UDim2.new(),UDim2.fromOffset(88,44));v.AnchorPoint=Vector2.new(.5,.5);v.Caption.TextSize=11;v.Caption.TextColor3=color
   local function place()
    local width,depth=area.AbsoluteSize.X,area.AbsoluteSize.Y
    local px=(x/Design.floorSize.X+.5)*width;local pz=(z/Design.floorSize.Z+.5)*depth
    v.Position=UDim2.fromOffset(math.clamp(px,math.min(44,width/2),math.max(width-44,width/2)),math.clamp(pz,math.min(22,depth/2),math.max(depth-22,depth/2)))
   end
   area:GetPropertyChangedSignal('AbsoluteSize'):Connect(place);task.defer(function()if area.Parent then place()end end)
   return v
  end
  local origin=Vector3.new(0,96,512)
  local tessaAt=target and target.Parent and target.Position-origin or Design.tessaOffset
  local tessa=dot('Tessa',(state and state.symbol or '')..' '..Text.tessa,tessaAt.X,tessaAt.Z,T.color.gold);tessa.Activated:Connect(function()showMap=false;render()end)
  local character=player and player.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
  local relative=root and root.Position-origin or Vector3.new(0,0,30)
  local you=dot('You',Text.you,relative.X,relative.Z,T.color.silver)
  local route=Instance.new('Frame');route.Name='Route';route.AnchorPoint=Vector2.new(.5,.5);route.BackgroundColor3=T.color.gold;route.BorderSizePixel=0;route.ZIndex=1;route.Parent=area
  local function routeLayout()
   local a,b=you.AbsolutePosition+you.AbsoluteSize/2,tessa.AbsolutePosition+tessa.AbsoluteSize/2
   local delta=b-a;route.Position=UDim2.fromOffset((a.X+b.X)/2-area.AbsolutePosition.X,(a.Y+b.Y)/2-area.AbsolutePosition.Y);route.Size=UDim2.fromOffset(delta.Magnitude,3);route.Rotation=math.deg(math.atan2(delta.Y,delta.X))
  end
  area:GetPropertyChangedSignal('AbsoluteSize'):Connect(routeLayout);task.defer(function()if area.Parent then routeLayout()end end)
  tessa.ZIndex=2;you.ZIndex=2
  line(box,'MapHint',Text.mapHint,198,50,12)
 end
 render=function()
  for _,v in ipairs(list:GetChildren())do if v:IsA('GuiObject')then v:Destroy()end end
  if showMap then mapCard()end
  local width=math.max(180,panel.AbsoluteSize.X-56)
  if status~=''then local v=T.label(list,'SaveStatus',status,UDim2.new(),UDim2.new(1,-8,0,height(status,13,width)),13,T.color.gold);v.LayoutOrder=1 end
  local rows=state and state.rows or {}
  if #rows==0 then local v=T.label(list,'Empty',state and state.loaded and Text.empty or Text.loading,UDim2.new(),UDim2.new(1,-8,0,100),14);v.LayoutOrder=2 end
  for i,row in ipairs(rows)do if showAll or i==1 then
   local card=T.frame(list,'Quest_'..row.id,UDim2.new(),UDim2.new(1,-8,0,220));card.LayoutOrder=i+2;card:SetAttribute('QuestId',row.id);card:SetAttribute('Phase',row.phase)
   local y=10
   local heading=(i==1 and Text.recommended..' · 'or '')..row.region..'\n'..row.title
   local h=height(heading,14,width);line(card,'Heading',heading,y,h,14,T.color.gold);y=y+h
   if row.brief~=''then h=height(row.brief,12,width);line(card,'Brief',row.brief,y,h,12);y=y+h end
   h=height(row.hint,13,width);line(card,'NextAction',row.hint,y,h,13);y=y+h
   -- Hints preserve field discovery; no puzzle answers or auto-accept.
   h=height(row.reward,12,width);line(card,'Reward',row.reward,y,h,12,T.color.gold);y=y+h+4
   local action=T.button(card,'Action',row.action,UDim2.fromOffset(12,y),UDim2.new(1,-24,0,44));action.Active=pending==nil and state.loaded;action.AutoButtonColor=action.Active
   action.Activated:Connect(function()
    if pending or not state.loaded then return end
    if row.canReport then
     local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
     if not target or not root or (root.Position-target.Position).Magnitude>12 then status=Text.approach;showMap=true;render();updateWorld();return end
     send({action='Report',questId=row.id,runId=row.runId})
    else dismiss();options.select(row.id,row.difficultyId)end
   end)
   card.Size=UDim2.new(1,-8,0,y+54)
  end end
  local narrow=panel.AbsoluteSize.X<420
  all.Caption.TextSize=narrow and 11 or 13;find.Caption.TextSize=narrow and 11 or 13
  all.Caption.Text=showAll and (narrow and Text.top or Text.recommendation)or (narrow and Text.allShort or Text.all)..' ('..#rows..')'
 end
 all.Activated:Connect(function()showAll=not showAll;render()end)
 find.Activated:Connect(function()showMap=not showMap;render();updateWorld()end)
 toastFind.Activated:Connect(function()open(true)end)
 later.Activated:Connect(function()toast.Visible=false end)
 local function npc()
  local lobbyModel=workspace:FindFirstChild('DawnspireLobbyPrototype');local folder=lobbyModel and lobbyModel:FindFirstChild('DawnspireResidents')
  local model=folder and folder:FindFirstChild('Tessa');return model and model.PrimaryPart
 end
 updateWorld=function()
  local part=npc()
  local root=player and player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local distance=root and part and (root.Position-part.Position).Magnitude
  if not lobby()or distance and distance<=10 then findingUntil=0 end
  local finding=os.clock()<findingUntil
  local visible=lobby()and state and state.loaded and (state.symbol~=''or finding)
  if target~=part then
   if marker then marker:Destroy();marker=nil end
   if highlight then highlight:Destroy();highlight=nil end
   target=part
  end
  if part and not marker then
   marker=Instance.new('BillboardGui');marker.Name='PersonalSideQuestMarker';marker.Adornee=part;marker.Size=UDim2.fromOffset(220,78);marker.StudsOffset=Vector3.new(0,10,0);marker.AlwaysOnTop=true;marker.MaxDistance=180;marker.Parent=parent
   local symbol=T.label(marker,'Symbol','',UDim2.new(),UDim2.new(1,0,0,44),36,T.color.gold);symbol.TextXAlignment=Enum.TextXAlignment.Center;symbol.TextStrokeTransparency=.1
   local caption=T.label(marker,'State','',UDim2.fromOffset(0,44),UDim2.new(1,0,0,34),13,T.color.gold);caption.TextXAlignment=Enum.TextXAlignment.Center;caption.TextStrokeTransparency=.1
   highlight=Instance.new('Highlight');highlight.Name='PersonalTessaGuide';highlight.Adornee=part.Parent;highlight.FillTransparency=1;highlight.OutlineColor=T.color.gold;highlight.Parent=part.Parent
  end
  if marker then marker.Enabled=visible==true;marker.Symbol.Text=state and state.symbol~=''and state.symbol or Text.tessa;marker.State.Text=finding and distance and string.format(Text.direction,math.floor(distance+.5))or state and state.label..' ('..state.count..')'or ''end
  if highlight then highlight.Enabled=visible and finding or false end
 end
 refresh=function()
  updateWorld()
  if not lobby()then dismiss();toast.Visible=false;return end
  if Chrome.blocked(player)or panel.Visible then toast.Visible=false;return end
  if pending or not state or not state.notice then return end
  local key=state.heroId..':'..state.noticeKey
  if seen[key]then return end
  seen[key]=true;message.Text=state.notice.canReport and Text.readyNotice or Text.availableNotice;toast.Visible=true
  send({action='Notice',questId=state.notice.id,noticeState=state.notice.noticeState,noticeKey=state.noticeKey})
 end
 panel:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()if panel.Visible then render()end end)
 panel:GetPropertyChangedSignal('Visible'):Connect(function()if not panel.Visible then showMap=false end;updateWorld()end)
 local input=game:GetService('UserInputService').InputBegan:Connect(function(v,processed)
  if panel.Visible and (v.KeyCode==Enum.KeyCode.Escape or v.KeyCode==Enum.KeyCode.ButtonB)then dismiss()end
 end)
 parent.Destroying:Connect(function()input:Disconnect();if marker then marker:Destroy()end;if highlight then highlight:Destroy()end end)
 task.spawn(function()while panel.Parent do refresh();task.wait(.5)end end)
 return {panel=panel,toast=toast,open=open,find=function()open(true)end,close=dismiss,
  update=function(s)snapshot=s;if pending and S.settled(s,pending)then status=pending.action=='Report'and Text.reported or '';pending=nil end;local nextState=S.project(s);if not state or state.heroId~=nextState.heroId or state.symbol~=nextState.symbol or nextState.symbol==''then toast.Visible=false end;state=nextState;if panel.Visible then render()end;refresh()end,
  receive=function(data)
   if not pending or data.requestId~=pending.requestId then return end
   if data.error=='Busy'or data.error=='SaveUnknown'or data.error=='AccountBusy'then status=Text.unknown
   else local action=pending.action;pending=nil;status=data.error and (data.error=='StoryLocked'or data.error=='AdventureChanged')and Text.unavailable or data.error and Text.failed or action=='Report'and Text.reported or ''end
   if panel.Visible then render()end
  end,
  state=function()return state end}
end
return Guide
