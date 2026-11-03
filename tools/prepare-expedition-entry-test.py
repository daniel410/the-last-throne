# Builds an isolated native GUI/account-projection test; no live remote requests.
from pathlib import Path
import runpy
ns=runpy.run_path('tools/review-expedition-ui.py')
code=ns['code'].split('local view=req')[0].replace('TLT_ExpeditionUIReview','TLT_ExpeditionEntryTest').replace('gui.Parent=originalGame.CoreGui','gui.Parent=originalGame.StarterGui')
code+='''
local sent={}
local view=req(tree.src.client.ExpeditionView).create(root,function(c)table.insert(sent,c)end)
local P=req(tree.src.shared.ExpeditionPresentation)
local R=req(tree.src.server.Inventory.InventoryRules);local C=req(tree.src.shared.ItemCatalog);local G=req(tree.src.shared.HeroProgression)
local profile=assert(R.addHero(R.new(42),'hero','knight',C));local hero=profile.heroes.hero
local state={role='Lobby',configured=true,studio=false,population=1,capacity=20,selection={missionId='DW-01',difficultyId='Easy'},missions=P.missions(hero),list={},hero={classId='knight',level=1}}
local ok,result=xpcall(function()
local n=0;local function check(v,label)n+=1;assert(v,label)end
local function show()view.render(state);view.panel.Visible=true;task.wait(.1)end
local function button(name)return assert(view.panel:FindFirstChild(name,true),name)end
show()
local measures={}
for _,size in ipairs({Vector2.new(1108,707),Vector2.new(844,390),Vector2.new(667,375)})do
 root.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.1)
 local b=button('Solo');local p=view.panel
 check(b.AbsolutePosition.Y>=p.AbsolutePosition.Y and b.AbsolutePosition.Y+b.AbsoluteSize.Y<=p.AbsolutePosition.Y+p.AbsoluteSize.Y,'start remains inside panel')
 check(b.Parent==p.Footer and b.Active and b.AbsoluteSize.Y>=44,'start fixed outside scroll and active on Easy Lv1')
 check(p.PartyList.AbsoluteSize.Y>=90,'mobile details viewport remains usable')
 local lastRight=0
 for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  local m=button('Mode'..mode)
  check(m.AbsoluteSize.Y>=44 and m.AbsoluteSize.X>=140,'mode touch target')
  check(m.AbsolutePosition.X>=lastRight,'mode does not overlap its neighbor');lastRight=m.AbsolutePosition.X+m.AbsoluteSize.X
 end
 check(button('ModeHell').Caption.ZIndex>button('ModeHell').TDButtonArt.ZIndex,'locked caption stays above disabled art')
 check(button('ModeHell').TDButtonArt:GetAttribute('TDArtKey')=='shellDisabled','locked mode uses disabled TD art')
 check(button('ModeEasy'):FindFirstChild('SelectedCheck'):GetAttribute('TDSelectionCheck'),'selected mode uses TD check geometry')
 table.insert(measures,{root={size.X,size.Y},panel={p.AbsoluteSize.X,p.AbsoluteSize.Y},scrollHeight=p.PartyList.AbsoluteSize.Y,startY=b.AbsolutePosition.Y-p.AbsolutePosition.Y,startHeight=b.AbsoluteSize.Y})
end
root.Size=UDim2.fromOffset(1108,707);task.wait(.1)
view.request({action='Configure',missionId='DW-01',difficultyId='Hell'})
check(view.isPending()and not button('Solo').Active,'Configure locks departure immediately')
view.request({action='Solo'});check(#sent==1,'fast second action never leaves client')
local id=sent[1].requestId;check(type(id)=='string'and #id>0,'request correlated')
view.render(state);check(view.isPending(),'unrelated polling snapshot cannot acknowledge selection')
view.render({ackOnly=true,requestId=id,error='Busy'});task.wait(.6)
check(sent[2]and sent[2].action=='GetState'and sent[2].requestId==id,'rate limit recovery requests authoritative state')
state.selection.difficultyId='Hell';state.requestId=id;show()
check(not view.isPending()and not button('Solo').Active,'authoritative locked selection releases pending but blocks entry')
view.request({action='Configure',missionId='DW-01',difficultyId='Easy'})
local nextId=sent[#sent].requestId
view.render(state);check(view.isPending(),'late prior acknowledgement cannot unlock newer selection')
state.selection.difficultyId='Easy';state.requestId=nextId;show();check(button('Solo').Active,'new acknowledged Easy restores entry')
view.showTab('Missions');task.wait(.1);check(button('Solo').Active and button('Solo').Parent==view.panel.Footer,'full mission list cannot bury start')
view.showTab('Details')
hero.level=80;hero.progression=G.new(80);hero.expeditions={version=1,clears={['DW-01']={Easy=true,Hard=true,Insane=true}},cacheProgress={}}
state.hero.level=80;state.missions=P.missions(hero);state.selection.difficultyId='Hell';state.requestId=nil;show()
check(button('Solo').Active,'eligible Hell remains repeatable')
check(button('RepeatReward').Text:find('393 Gold',1,true)and button('RepeatReward').Text:find('0 XP',1,true),'reward projection reflects mode and level cap')
check(button('HellRepeat').Text:find('without a daily limit',1,true),'Hell unlimited repeat explained')
local other=R.copy(hero);other.level=1;other.progression=G.new(1)
local party={id='party',hostId=42,target=2,status='forming',missionId='DW-01',difficultyId='Hell',members={['42']={userId=42,name='Knight',classId='knight',level=80,main=0,ready=true,arrived=true},['43']={userId=43,name='Mage',classId='mage',level=1,main=0,ready=true,arrived=true}}}
local function partyView()state.party=P.party(party,function(m)return m.userId==42 and hero or other end);show()end
partyView();view.showTab('Party');task.wait(.1)
check(not button('Launch').Active,'underlevel party member blocks launch')
check(button('Member43').Entry.Text:find('Reach Lv80',1,true),'blocked member gets specific action')
other.level=80;other.progression=G.new(80);party.members['43'].level=80;party.members['43'].ready=false;partyView()
check(not button('Launch').Active and button('Member43').Entry.Text=='Waiting for Ready.','unready eligible member explained')
party.members['43'].ready=true;partyView();check(button('Launch').Active,'whole ready eligible party can depart')
state.party=nil;state.configured=false;show();check(not button('Solo').Active and view.panel.Notice.Text:find('not configured',1,true),'unconfigured battle disabled and explained')
state.configured=true;state.travelling=true;show();check(not button('Solo').Active and not button('ModeEasy').Active,'travel locks configuration and entry')
state.travelling=false;state.busy=true;show();check(not button('Solo').Active and view.panel.Notice.Text==req(tree.src.shared.ExpeditionText).Saving,'saving explained')
state.busy=false;state.selection.difficultyId='Easy';state.hero.level=1;state.missions=P.missions(assert(R.addHero(R.new(44),'starter','knight',C)).heroes.starter);view.showTab('Details');show()
-- Drive the actual network handler with a fake clock and in-memory Studio map.
local clock=10;local responses={};local serverPlayers={};local actors={}
local removals={Connect=function()end};serverPlayers.PlayerRemoving=removals
local p1={UserId=42,DisplayName='Knight',Parent=serverPlayers,GetAttribute=function()return 'Lobby'end}
local p2={UserId=43,DisplayName='Mage',Parent=serverPlayers,GetAttribute=function()return 'Lobby'end}
actors[42]=p1;actors[43]=p2
function serverPlayers:GetPlayers()return {p1,p2}end
function serverPlayers:GetPlayerByUserId(id)return actors[id]end
local remotes={};local fakeRS={Shared=tree.src.shared,Remotes=remotes}
local serverGame={JobId='entry-test',GetService=function(_,name)
 if name=='Players'then return serverPlayers end
 if name=='ReplicatedStorage'then return fakeRS end
 if name=='RunService'then return {IsStudio=function()return true end}end
 if name=='TeleportService'then return {TeleportInitFailed={Connect=function()end}}end
 return originalGame:GetService(name)
end}
local fakeInstance={new=function(kind)
 assert(kind=='RemoteEvent')
 local event={Connect=function(self,fn)self.fn=fn end}
 return setmetatable({OnServerEvent=event,FireClient=function(_,p,s)table.insert(responses,{player=p,state=s})end},{__newindex=function(self,k,v)rawset(self,k,v);if k=='Parent'then v[self.Name]=self end end})
end}
local serverFn=assert(loadstring(sources['src/server/Network/ExpeditionService.luau']))
setfenv(serverFn,setmetatable({game=serverGame,script=tree.src.server.Network.ExpeditionService,require=req,Instance=fakeInstance,workspace={SetAttribute=function()end},task={spawn=function()end},os=setmetatable({clock=function()return clock end},{__index=os})},{__index=getfenv()}))
local network=serverFn()
network.start({role='Lobby',inventory={expedition=function()end,expeditionHero=function(p)return p==p1 and hero or other end,storyState=function()return {main=0}end,growth=function(p)return {level=p==p1 and hero.level or other.level}end},heroSession={getActiveHero=function(p)return {heroId='h'..p.UserId,classId=p==p1 and 'knight'or 'mage'}end,getInventoryContext=function(p)return {heroId='h'..p.UserId,atHub=true}end}})
local function command(p,c)remotes.ExpeditionRequest.OnServerEvent.fn(p,c)end
local function latest(p)for i=#responses,1,-1 do if responses[i].player==p then return responses[i].state end end end
command(p1,{action='Configure',missionId='DW-01',difficultyId='Hell',requestId='configure'})
check(latest(p1).selection.difficultyId=='Hell'and latest(p1).requestId=='configure'and not latest(p1).error,'successful Configure acknowledged without a false error')
clock+=.1;command(p1,{action='Solo',requestId='fast'})
check(latest(p1).ackOnly and latest(p1).requestId=='fast','network throttle replies instead of silently dropping')
clock+=.5;command(p1,{action='GetState',requestId='recover'})
check(not latest(p1).ackOnly and latest(p1).requestId=='recover'and latest(p1).selection.difficultyId=='Hell','authoritative refresh retains configured mode')
clock+=1;command(p1,{action='Create',target=2,requestId='create'})
local partyId=latest(p1).party.id
clock+=1;command(p2,{action='Join',id=partyId,requestId='join'})
check(#latest(p1).party.members==2,'party join immediately updates leader')
clock+=1;command(p1,{action='Ready',ready=true,requestId='ready1'})
clock+=1;command(p2,{action='Ready',ready=true,requestId='ready2'})
check(latest(p1).party.launchAllowed and latest(p2).party.launchAllowed,'all ready eligibility sent to both members')
clock+=1;command(p1,{action='Configure',missionId='DW-01',difficultyId='Easy',requestId='changed'})
check(not latest(p2).party.launchAllowed and not latest(p2).party.members[1].ready,'configuration change immediately invalidates party readiness')
_G.TLTExpeditionEntryTest={gui=gui,signal=signal,root=root,view=view,state=state,party=party,partyView=partyView,hero=hero,other=other,projection=P}
return {checks=n,measurements=measures,scope='native GUI with server projection fixtures; no live account, remote or Teleport'}
end,debug.traceback)
if not ok then gui:Destroy();signal:Destroy();error(result)end
return result
'''
Path('builds/expedition-entry-test.luau').write_text(code)
print('Prepared builds/expedition-entry-test.luau')
