local T=require(script.Parent.TDInventoryTheme)
local Menu=require(script.Parent.HeroMenuChrome)
local V={}
function V.create(parent,send)
 local panel=Menu.frame(parent,'Expedition',UDim2.fromScale(.5,.5),UDim2.new(1,-32,1,-100));panel.AnchorPoint=Vector2.new(.5,.5);panel.Visible=false
 local cap=Instance.new('UISizeConstraint');cap.MaxSize=Vector2.new(950,700);cap.Parent=panel
 T.label(panel,'Title','ADVENTURES & PARTIES',UDim2.fromOffset(20,12),UDim2.new(1,-88,0,30),20,T.color.gold)
 local close=T.button(panel,'Close','X',UDim2.new(1,-62,0,12),UDim2.fromOffset(44,44));close.Activated:Connect(function() panel.Visible=false end)
 local description=T.label(panel,'Description','Solo or a private expedition with 2-4 heroes.',UDim2.fromOffset(20,48),UDim2.new(1,-40,0,44),12)
 local scroll=Instance.new('ScrollingFrame');scroll.Name='PartyList';scroll.Position=UDim2.fromOffset(16,100);scroll.Size=UDim2.new(1,-32,1,-178);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=panel
 local layout=Instance.new('UIListLayout');layout.Padding=UDim.new(0,10);layout.Parent=scroll
 local notice=T.label(panel,'Notice','Select your hero before starting or joining.',UDim2.new(0,20,1,-68),UDim2.new(1,-40,0,52),12)
 local function action(name,caption,data)
  local b=T.button(scroll,name,caption,UDim2.new(),UDim2.new(1,-8,0,48));b.Activated:Connect(function() send(data);notice.Text='Please wait...' end);return b
 end
 local function render(s,message)
  for _,child in ipairs(scroll:GetChildren()) do if child:IsA('GuiObject') then child:Destroy() end end
  description.Text=string.format('%s · %d / %d players\n%s',s.role=='Battle' and 'BATTLE SERVER' or 'DAWNSPIRE LOBBY',s.population or 0,s.capacity or 20,s.studio and 'Studio preview: no cross-server travel or persistent saves.' or 'Your saved hero and progress travel with you.')
  if s.travelling then T.label(scroll,'Travelling','Saving complete. Travelling to your expedition...',UDim2.new(),UDim2.new(1,-8,0,80),16)
  elseif s.role=='Battle' then T.label(scroll,'Battle','Use the map menu to return to the lobby. If disconnected, rejoin this expedition from the lobby within 15 minutes.',UDim2.new(),UDim2.new(1,-8,0,100),14)
  else
   if s.rejoin then action('Rejoin','REJOIN EXPEDITION · up to 15 minutes',{action='Rejoin'}) end
   if s.party then
    local p=s.party
    T.label(scroll,'PartyTitle','PARTY · '..#p.members..' / '..p.target..' · '..p.status,UDim2.new(),UDim2.new(1,-8,0,34),16,T.color.gold)
    local me=game.Players.LocalPlayer and game.Players.LocalPlayer.UserId;local ready=false
    for _,m in ipairs(p.members) do
     T.label(scroll,'Member'..m.userId,string.format('%s%s · %s Lv%d · Story %d · %s',m.userId==p.hostId and 'LEADER · ' or '',m.name,m.classId,m.level,math.min(7,m.main+1),not m.arrived and 'Travelling' or m.ready and 'READY' or 'Not ready'),UDim2.new(),UDim2.new(1,-8,0,48),13)
     if m.userId==me then ready=m.ready end
    end
    if p.status=='forming' then
     action('Ready',ready and 'NOT READY' or 'READY',{action='Ready',ready=not ready})
     if p.hostId==me then action('Launch','START PARTY ADVENTURE',{action='Launch'}) end
    end
    action('Leave','LEAVE PARTY',{action='Leave'})
   else
    action('Solo','START SOLO ADVENTURE',{action='Solo'})
    for n=2,4 do action('Create'..n,'CREATE '..n..'-HERO PARTY',{action='Create',target=n}) end
    T.label(scroll,'Recruiting','RECRUITING PARTIES · all lobby servers',UDim2.new(),UDim2.new(1,-8,0,38),14,T.color.gold)
    for _,p in ipairs(s.list or {}) do action('Join'..p.id,string.format('JOIN · %s · %d / %d',p.host,p.count,p.target),{action='Join',id=p.id}) end
    if #(s.list or {})==0 then T.label(scroll,'NoParties','No open parties. Create one for other heroes to join.',UDim2.new(),UDim2.new(1,-8,0,52),13) end
   end
   action('Refresh','REFRESH PARTIES',{action='GetState'})
  end
  notice.Text=message or (s.party and 'All members must gather in this lobby, select heroes with the same next main story, and ready up.' or 'Solo adventures and parties use their own battle server. Training is entered from the lobby.')
 end
 return {panel=panel,render=render}
end
return V
