local T=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local Check=require(script.Parent.TDLobbySelectionCheck)
local RS=game:GetService('ReplicatedStorage')
local Text=require(RS.Shared.ExpeditionText)
local AT=require(RS.Shared.AdventureText)
local D=require(RS.Shared.Difficulty)
local V={}
local portraits={knight='103255177842108',elf='80894238854345',dwarf='74628903359757',mage='91907986271282'}
local function reason(info,mission)
 if not info then return Text.SelectHero end
 if info.reason=='DifficultyLevel'then return string.format(Text.Level,info.requiredLevel or info.level)end
 if info.reason=='PreviousDifficulty'then return string.format(Text.Previous,mission,info.previous or 'Easy')end
 if info.reason=='StoryLocked'then return string.format(Text.Story,info.storyMain or 0)end
 return Text[info.reason]or AT[info.reason]or Text.Unavailable
end
function V.create(parent,send)
 local player=game.Players.LocalPlayer
 local panel=T.frame(parent,'Expedition',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(950,700);cap.Parent=panel
 require(script.Parent.LobbyPanelLayout).bind(panel,player)
 local title=Menu.plaque(panel,'Title',Text.Title,UDim2.new(.5,-150,0,8),UDim2.fromOffset(300,38));title.Caption.TextSize=20
 local close=Instance.new('TextButton');close.Name='Close';close.Text='';close.BackgroundTransparency=1;close.Size=UDim2.fromOffset(44,44);close.Position=UDim2.new(1,-54,0,6);close.Parent=panel
 T.icon(close,'close',UDim2.new(),UDim2.fromScale(1,1));close.Activated:Connect(function()panel.Visible=false end)
 local portrait=Instance.new('ImageLabel');portrait.Name='HeroPortrait';portrait.BackgroundTransparency=1;portrait.Size=UDim2.fromOffset(38,38);portrait.Position=UDim2.fromOffset(16,48);portrait.ScaleType=Enum.ScaleType.Crop;portrait.Parent=panel
 local summary=T.label(panel,'SelectedMission','',UDim2.fromOffset(62,48),UDim2.new(1,-80,0,38),15,T.color.gold)
 local modeHost=Instance.new('Frame');modeHost.Name='Modes';modeHost.BackgroundTransparency=1;modeHost.Parent=panel
 local tabs=Instance.new('Frame');tabs.Name='Tabs';tabs.BackgroundTransparency=1;tabs.Parent=panel
 local scroll=Instance.new('ScrollingFrame');scroll.Name='PartyList';scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=scroll
 local notice=T.label(panel,'Notice',Text.SelectHero,UDim2.new(0,18,1,-86),UDim2.new(1,-36,0,32),12,T.color.muted)
 local footer=Instance.new('Frame');footer.Name='Footer';footer.BackgroundTransparency=1;footer.Position=UDim2.new(0,16,1,-50);footer.Size=UDim2.new(1,-32,0,44);footer.Parent=panel
 local current,pending,latestRequestId,tab,order=nil,nil,nil,'Details',0
 local render,draw
 local function resize()
  local short=panel.AbsoluteSize.Y<430
  title.Size=UDim2.fromOffset(short and 240 or 300,short and 32 or 38);title.Position=UDim2.new(.5,short and -120 or -150,0,8)
  portrait.Position=UDim2.fromOffset(16,short and 40 or 50);portrait.Size=UDim2.fromOffset(short and 30 or 38,short and 30 or 38);summary.Position=UDim2.fromOffset(short and 52 or 62,short and 40 or 50);summary.Size=UDim2.new(1,-112,0,short and 30 or 38)
  modeHost.Position=UDim2.fromOffset(16,short and 76 or 96);modeHost.Size=UDim2.new(1,-32,0,48)
  tabs.Position=UDim2.fromOffset(16,short and 130 or 152);tabs.Size=UDim2.new(1,-32,0,36)
  local top=short and 172 or 196
  scroll.Position=UDim2.fromOffset(16,top);scroll.Size=UDim2.new(1,-32,1,-top-86)
  if short then
   title.Position=UDim2.fromOffset(12,4);title.Size=UDim2.fromOffset(140,40);title.Caption.TextSize=14
   portrait.Visible=false
   summary.Position=UDim2.fromOffset(160,4);summary.Size=UDim2.new(1,-220,0,40);summary.TextSize=12
   modeHost.Position=UDim2.fromOffset(12,52);modeHost.Size=UDim2.new(0,128,1,-64)
   tabs.Position=UDim2.fromOffset(152,52);tabs.Size=UDim2.new(1,-168,0,44)
   scroll.Position=UDim2.fromOffset(152,104);scroll.Size=UDim2.new(1,-168,1,-190)
   notice.Position=UDim2.new(0,152,1,-82);notice.Size=UDim2.new(1,-168,0,28);notice.TextSize=11
   footer.Position=UDim2.new(0,152,1,-50);footer.Size=UDim2.new(1,-168,0,44)
  else
   notice.Position=UDim2.new(0,18,1,-86);notice.Size=UDim2.new(1,-36,0,32)
   footer.Position=UDim2.new(0,16,1,-50);footer.Size=UDim2.new(1,-32,0,44)
  end
  for i,mode in ipairs(D.order)do
   local b=modeHost:FindFirstChild('Mode'..mode)
   if b then
    b.Position=short and UDim2.fromOffset(0,(i-1)*48) or UDim2.new((i-1)/4,3,0,0)
    b.Size=short and UDim2.fromOffset(128,44) or UDim2.new(.25,-6,1,0)
    b.Caption.TextSize=short and 11 or 13
   end
  end
 end
 panel:GetPropertyChangedSignal('AbsoluteSize'):Connect(resize);resize()
 local function clear(host)for _,child in ipairs(host:GetChildren())do if child:IsA('GuiObject')then child:Destroy()end end end
 local function ordered(item)order+=1;item.LayoutOrder=order;return item end
 local function line(name,caption,height,color)return ordered(T.label(scroll,name,caption,UDim2.new(),UDim2.new(1,-10,0,height or 32),13,color))end
 local function recover(id)
  if not pending or pending.id~=id or pending.polling then return end
  pending.polling=true
  task.spawn(function()
   task.wait(.5)
   while panel.Parent and pending and pending.id==id do
    send({action='GetState',requestId=id});task.wait(2)
   end
  end)
 end
 local function request(command)
  if pending then return end
  local id=game:GetService('HttpService'):GenerateGUID(false):gsub('%-','')
  command.requestId=id;latestRequestId=id;pending={id=id,action=command.action};draw(Text.Applying)
  send(command)
  task.delay(8,function()if panel.Parent and pending and pending.id==id then draw(Text.Refreshing);recover(id)end end)
 end
 local function button(host,name,caption,command,position,size,primary,enabled)
  local b=T.button(host,name,caption,position or UDim2.new(),size or UDim2.new(1,-10,0,44),primary)
  T.enabled(b,enabled==true and not pending)
  b.Activated:Connect(function()if b.Active then request(command)end end)
  return b
 end
 local function action(name,caption,command,enabled)return ordered(button(scroll,name,caption,command,nil,nil,false,enabled~=false))end
 local function mark(b,selected,locked)
  b.Caption.ZIndex=2
  if locked then
   local disabled=T.sprite(b,'DisabledTemplate','shellDisabled',UDim2.new(),UDim2.fromScale(1,1))
   local art=b.TDButtonArt
   for _,key in ipairs({'Image','ImageRectOffset','ImageRectSize','ScaleType','SliceCenter'})do art[key]=disabled[key]end
   art:SetAttribute('TDArtKey','shellDisabled');art.SliceScale=.32;disabled:Destroy()
   b.Caption.TextColor3=T.color.muted
  end
  if selected then
   local check=T.label(b,'SelectedCheck','',UDim2.fromOffset(6,12),UDim2.fromOffset(22,22),18);Check.apply(check);check.ZIndex=3
   local stroke=Instance.new('UIStroke');stroke.Color=T.color.gold;stroke.Thickness=2;stroke.Parent=b
  end
 end
 local function heroArt(host,classId)
  local art=Instance.new('ImageLabel');art.Name='Portrait';art.Image='rbxassetid://'..(portraits[classId]or portraits.knight);art.BackgroundTransparency=1;art.Size=UDim2.fromOffset(40,40);art.Position=UDim2.fromOffset(4,4);art.ScaleType=Enum.ScaleType.Crop;art.Parent=host
 end
 draw=function(message)
  if not current then return end
  local s=current;order=0;clear(scroll);clear(modeHost);clear(footer);clear(tabs)
  local selected=s.selection or {missionId='DW-01',difficultyId='Easy'};local mission
  for _,m in ipairs(s.missions or {})do if m.id==selected.missionId then mission=m;break end end
  local access=mission and mission.modes[selected.difficultyId]
  summary.Text=(mission and mission.region or '')..' · '..(mission and mission.title or selected.missionId)
  portrait.Visible=s.hero~=nil;portrait.Image=s.hero and 'rbxassetid://'..(portraits[s.hero.classId]or portraits.knight)or ''
  local party=s.party;local canConfigure=s.role=='Lobby'and not s.travelling and not s.busy and(not party or party.hostId==player.UserId and party.status=='forming')
  for i,mode in ipairs(D.order)do
   local info=mission and mission.modes[mode];local locked=not info or not info.allowed
   local caption=mode..' · Lv'..(info and info.level or D.entryLevels[mode])..(locked and '\n'..Text.Locked or '')
   local b=button(modeHost,'Mode'..mode,caption,{action='Configure',missionId=selected.missionId,difficultyId=mode},UDim2.new((i-1)/4,3,0,0),UDim2.new(.25,-6,1,0),false,canConfigure)
   b.Caption.TextSize=13;mark(b,mode==selected.difficultyId,locked)
  end
  for i,item in ipairs({{'Details',Text.MissionTab},{'Missions',Text.MissionsTab},{'Party',Text.PartyTab}})do
   local b=T.button(tabs,item[1],item[2],UDim2.new((i-1)/3,3,0,0),UDim2.new(1/3,-6,1,0))
   mark(b,tab==item[1],false)
   b.Activated:Connect(function()tab=item[1];scroll.CanvasPosition=Vector2.zero;draw(message)end)
  end
  local blocked=access and not access.allowed and reason(access,selected.missionId)or not access and Text.SelectHero or nil
  local info=message
  if s.travelling then
   line('Travelling',Text.Travelling,60,T.color.gold);info=Text.Travelling
  elseif s.role=='Battle'then
   line('Battle',Text.Battle,72);info=Text.Battle
  elseif tab=='Missions'then
   local region
   for _,m in ipairs(s.missions or {})do
    if m.region~=region then region=m.region;line('Region'..m.id,region or '',28,T.color.gold)end
    local a=m.modes[selected.difficultyId]
    local b=action('Mission'..m.id,m.title..(a and not a.allowed and ' · '..Text.Locked or ''),{action='Configure',missionId=m.id,difficultyId=selected.difficultyId},canConfigure)
    mark(b,m.id==selected.missionId,not a or not a.allowed)
   end
  elseif tab=='Party'then
   if party then
    line('PartyTitle',string.format('PARTY · %d/%d',#party.members,party.target),28,T.color.gold)
    for _,m in ipairs(party.members)do
     local row=ordered(T.frame(scroll,'Member'..m.userId,UDim2.new(),UDim2.new(1,-10,0,66)));heroArt(row,m.classId)
     T.label(row,'Hero',(m.userId==party.hostId and Text.LeaderBadge or '')..m.name..' · '..string.format(Text.Hero,Text.Class[m.classId]or m.classId,m.level),UDim2.fromOffset(52,2),UDim2.new(1,-60,0,28),13)
     local why=not m.eligible and reason(m,selected.missionId)or not m.ready and Text.WaitingReady or Text.Eligible
     T.label(row,'Entry',why,UDim2.fromOffset(52,28),UDim2.new(1,-60,0,34),12,m.eligible and(m.ready and T.color.green or T.color.gold)or T.color.error)
    end
    action('Leave',Text.Leave,{action='Leave'})
   else
    for n=2,4 do action('Create'..n,string.format(Text.Create,n),{action='Create',target=n})end
    line('Recruiting',Text.Recruiting,28,T.color.gold)
    for _,p in ipairs(s.list or {})do action('Join'..p.id,string.format(Text.Join,p.host,p.count,p.target),{action='Join',id=p.id})end
    if #(s.list or {})==0 then line('NoParties',Text.NoParties,44)end
   end
   action('Refresh',Text.Refresh,{action='GetState'})
  else
   local card=ordered(T.frame(scroll,'MissionCard',UDim2.new(),UDim2.new(1,-10,0,56)))
   T.icon(card,'maps',UDim2.fromOffset(8,5),UDim2.fromOffset(42,46))
   T.label(card,'Objective',string.format(Text.Objective,mission and mission.objective or ''),UDim2.fromOffset(60,4),UDim2.new(1,-70,1,-8),14)
   if access then
    if blocked then line('Blocked',blocked,36,T.color.error)end
    local encounter=access.encounter
    if encounter then
     for _,entry in ipairs({{'normal','Enemies'},{'boss','Bosses'}})do
      local row=encounter[entry[1]]
      if row then line(entry[2],string.format(Text[entry[2]],row.levelMin,row.levelMax,row.hpMin,row.hpMax,encounter.players),36,T.color.gold)end
     end
     line('DefeatRewards',string.format(Text.Defeats,access.xpCapped and 0 or encounter.xp,encounter.gold),36)
    end
    if s.rejoin and s.rejoin.rulesVersion==1 then line('OriginalRules',Text.OriginalRules,36,T.color.muted)end
    line('Risk',string.format(Text.Risk,access.hp or 1,access.damage or 1,access.bossHP or 1,access.bossDamage or 1),32)
    line('RiskNote',Text.RiskNote,28,T.color.muted)
    line('FirstReward',string.format(Text.First,access.xpCapped and 0 or access.firstXP or 0,access.firstGold or 0)..(access.firstClear and ''or Text.Claimed),40,access.firstClear and T.color.gold or T.color.muted)
    line('RepeatReward',string.format(Text.Repeat,access.xpCapped and 0 or access.repeatXP or 0,access.repeatGold or 0),32,T.color.gold)
    if access.xpCapped then line('XPCap',Text.Capped,28)end
    if (access.cache or 0)>0 then line('Materials',string.format(Text.Materials,access.gems,access.stones,access.cache),40);line('Equipment',Text.Equipment,32);line('RewardBand',string.format(Text.RewardBand,access.rewardBand or 1),36)end
    if selected.difficultyId=='Hell'then line('HellRepeat',Text.RepeatHell,44,T.color.gold)end
   end
   if s.studio then line('Studio',Text.Studio,36,T.color.muted)end
  end
  local available=s.role=='Lobby'and not s.travelling and not s.busy and(s.studio or s.configured~=false)
  if party then
   local me;for _,m in ipairs(party.members)do if m.userId==player.UserId then me=m end end
   local forming=party.status=='forming'
   button(footer,'Ready',me and me.ready and Text.Unready or Text.Ready,{action='Ready',ready=not(me and me.ready)},UDim2.new(),UDim2.new(.42,-4,1,0),false,available and forming and me and(me.ready or me.eligible))
   button(footer,'Launch',Text.Launch,{action='Launch'},UDim2.new(.42,4,0,0),UDim2.new(.58,-4,1,0),true,available and party.hostId==player.UserId and party.launchAllowed==true)
   info=info or(not party.launchAllowed and Text.PartyBlocked or Text.Eligible)
  else
   if s.rejoin then button(footer,'Rejoin',Text.Rejoin,{action='Rejoin'},UDim2.new(),UDim2.new(.3,-4,1,0),false,available)end
   button(footer,'Solo',Text.Solo,{action='Solo'},UDim2.new(s.rejoin and .3 or 0,s.rejoin and 4 or 0,0,0),UDim2.new(s.rejoin and .7 or 1,s.rejoin and -4 or 0,1,0),true,available and access and access.allowed)
   info=info or blocked or Text.Eligible
  end
  if not available and not s.travelling and s.role=='Lobby'then info=s.busy and Text.Saving or Text.Config end
  notice.Text=pending and(message or Text.Applying)or info or Text.Eligible
  resize()
 end
 render=function(s,message)
  if s.requestId and latestRequestId and s.requestId~=latestRequestId then return end
  if s.ackOnly then
   if pending and s.requestId==pending.id then draw(Text.Refreshing);recover(pending.id)end
   return
  end
  if pending and s.requestId==pending.id then pending=nil end
  local position=scroll.CanvasPosition
  current=s;draw(message);scroll.CanvasPosition=position
 end
 panel:GetPropertyChangedSignal('Visible'):Connect(function()if panel.Visible then scroll.CanvasPosition=Vector2.zero end end)
 return {panel=panel,render=render,showTab=function(value)tab=value;scroll.CanvasPosition=Vector2.zero;draw()end,isPending=function()return pending~=nil end,request=request}
end
return V
