-- Isolated engine UI lifecycle checks; no teleport or live account writes.
return function(Starting,View,root,player,signal)
 local checks=0
 local function check(value,message)checks+=1;assert(value,message)end
 local attrs={K0SessionPhase='Lobby'}
 player.GetAttribute=function(_,name)return attrs[name]end
 player.WaitForChild=function()return root.Parent.Parent end
 local function attribute(name,value)attrs[name]=value;signal:Fire(name);task.wait()end
 Starting.start(player)
 local gui=root.Parent.Parent.AdventureStartingNotice
 local sent={}
 local view=View.create(root,function(command)table.insert(sent,command)end)
 local state={role='Lobby',configured=true,hero={classId='knight'},selection={missionId='DW-01',difficultyId='Easy'},missions={},list={}}
 view.render(state)
 check(not gui.Enabled,'idle lobby has no starting overlay')
 view.request({action='Solo'})
 check(gui.Enabled and #sent==1,'solo displays progress synchronously before any server response')
 check(gui.Shade.Card.Title.Text=='ADVENTURE STARTING...','English departure title')
 check(gui.Shade.Active and gui.Shade.Card.TDPanelArt:GetAttribute('TDArtKey')=='panel','input shield and approved TD frame')
 view.request({action='Solo'});check(#sent==1,'repeated click sends no second request')
 view.panel.Visible=false;check(gui.Enabled,'closing adventure panel cannot hide departure progress')
 view.render(state);check(gui.Enabled,'unrelated polling does not clear pending departure')
 state.requestId=sent[1].requestId;view.render(state,'Entry unavailable')
 check(not gui.Enabled,'rejected solo clears progress for retry')
 view.request({action='Launch'});check(gui.Enabled,'party leader sees immediate progress')
 attribute('TLTAdventureStarting',true)
 state.requestId=sent[2].requestId;state.travelling=true;view.render(state)
 check(gui.Enabled,'accepted departure stays visible through teleport preparation')
 attribute('TLTAdventureStarting',false);state.travelling=false;view.render(state,'Travel failed')
 check(not gui.Enabled,'failed travel releases departure overlay')
 attribute('TLTAdventureStarting',true)
 check(gui.Enabled and not view.panel.Visible,'non-host sees server departure with menu closed')
 for _,size in ipairs({Vector2.new(1108,707),Vector2.new(844,390),Vector2.new(667,375)})do
  -- The actual overlay scales against its own screen, independently of the menu.
  gui.Shade.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.05)
  local card=gui.Shade.Card
  check(card.AbsoluteSize.X<=480 and card.AbsoluteSize.X<=size.X-40,'card fits viewport width')
  check(card.AbsolutePosition.Y>=0 and card.AbsolutePosition.Y+card.AbsoluteSize.Y<=size.Y,'card fits viewport height')
 end
 attribute('K0SessionPhase','LoadingTutorial');check(not gui.Enabled,'Studio adventure transition releases overlay')
 attribute('TLTAdventureStarting',false);attribute('K0SessionPhase','Lobby')
 check(not gui.Enabled,'return to lobby has no stale local pending state')
 gui:Destroy()
 return {kind='ADVENTURE_STARTING_NATIVE',checks=checks,pass=true}
end
