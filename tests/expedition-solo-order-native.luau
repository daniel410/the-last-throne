assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local gui=Instance.new('ScreenGui');gui.Name='SoloOrderQA';gui.Parent=game.CoreGui
local report={kind='EXPEDITION_SOLO_ORDER_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local view=require(client.ExpeditionView).create(gui,function()end);view.panel.Visible=true
 local list=view.panel.PartyList
 local function first()
  local top=list.Solo;check(top~=nil,'solo action exists')
  for _,item in ipairs(list:GetChildren())do if item:IsA('GuiObject')and item~=top then check(item.LayoutOrder>top.LayoutOrder,'solo is first above '..item.Name)end end
  task.wait();for _,item in ipairs(list:GetChildren())do if item:IsA('GuiObject')and item~=top then check(item.AbsolutePosition.Y>=top.AbsolutePosition.Y+top.AbsoluteSize.Y,'layout actually puts solo first')end end
 end
 view.render({role='Lobby',rejoin={id='run'},list={{id='1',host='Ada',count=1,target=2}}});first()
 check(list.Solo.Active and list.Rejoin.Active,'solo and rejoin both remain available')
 view.render({role='Lobby',list={}});first();check(list.Solo.Active,'solo available without party')
 view.render({role='Lobby',rejoin={id='run'},party={members={{userId=7,name='Ada',classId='knight',level=1,main=0,arrived=true,ready=false}},hostId=7,target=2,status='forming'}});first()
 check(not list.Solo.Active and list.Solo.Caption.Text:find('LEAVE PARTY FIRST',1,true)~=nil,'in-party solo clearly disabled until leaving')
 check(list.Leave.Active and list.Ready.Active,'party controls remain usable')
 view.render({role='Battle'});check(not list:FindFirstChild('Solo') and list:FindFirstChild('Battle'),'battle keeps return instructions')
 view.render({role='Lobby',travelling=true});check(not list:FindFirstChild('Solo') and list:FindFirstChild('Travelling'),'travel lock keeps progress notice')
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
