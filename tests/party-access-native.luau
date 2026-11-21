-- Run from Studio's Edit command context in a local candidate Place.
local shared=game.ReplicatedStorage.Shared
local network=game.ServerScriptService.Server.Network
local client=game.StarterPlayer.StarterPlayerScripts.Client
local profileRules=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local items=require(shared.ItemCatalog)
local checks=0
local function check(value,message)
 checks+=1
 assert(value,message)
end
local function loadModule(module,overrides)
 local fn=assert(loadstring(module.Source,module.Name))
 setfenv(fn,setmetatable(overrides,{__index=getfenv()}))
 return fn()
end
local function signal() return {Connect=function()end} end
local people={}
local players={PlayerRemoving=signal()}
function players:GetPlayers() return people end
function players:GetPlayerByUserId(uid)
 for _,p in ipairs(people) do if p.UserId==uid then return p end end
end
local function actor(uid)
 local profile=assert(profileRules.addHero(profileRules.new(uid),'hero','knight',items))
 local p={UserId=uid,DisplayName='Hero'..uid,Parent=players,hero=profile.heroes.hero}
 function p:GetAttribute(name) if name=='K0SessionPhase' then return 'Lobby' end end
 function p:GetAttributeChangedSignal() return signal() end
 table.insert(people,p)
 return p
end
local host,guest,observer=actor(1),actor(2),actor(3)
local remotes={}
local rs={Shared=shared,Remotes=remotes}
local fakeGame={JobId='party-access-test'}
function fakeGame:GetService(name)
 if name=='Players' then return players end
 if name=='ReplicatedStorage' then return rs end
 if name=='RunService' then return {IsStudio=function()return true end} end
 if name=='TeleportService' then return {TeleportInitFailed=signal()} end
 return game:GetService(name)
end
local remoteFactory={}
function remoteFactory.new(kind)
 assert(kind=='RemoteEvent')
 local event={Connect=function(self,fn) self.fn=fn end}
 local remote={OnServerEvent=event,FireClient=function(_,p,state) p.state=state end}
 return setmetatable(remote,{__newindex=function(self,key,value)
  rawset(self,key,value)
  if key=='Parent' then value[self.Name]=self end
 end})
end
local now=0
local service=loadModule(network.ExpeditionService,{
 game=fakeGame,script=network.ExpeditionService,Instance=remoteFactory,
 task={spawn=function()end},workspace={SetAttribute=function()end},
 os={time=function()return 100 end,clock=function()return now end},
})
service.start({
 role='Lobby',
 inventory={
  expeditionHero=function(p)return p.hero end,expedition=function()end,
  storyState=function(p)return p.hero.deepwood end,growth=function()return {level=1}end,
 },
 heroSession={
  getActiveHero=function()return {heroId='hero',classId='knight'}end,
  getInventoryContext=function()return {heroId='hero',atHub=true}end,
 },
})
local function command(p,action,fields)
 now+=1
 local request=fields or {};request.action=action
 remotes.ExpeditionRequest.OnServerEvent.fn(p,request)
 return p.state
end
local private=command(host,'Create',{target=3,password='0042'}).party
check(private and private.passwordRequired and private.password==nil,'host sees a lock flag without password')
local listings=command(guest,'GetState').list
check(#listings==1 and listings[1].passwordRequired and listings[1].password==nil,'recruitment shows lock without password')
local id=private.id
check(command(guest,'Join',{id=id}).error=='PasswordRequired','server rejects missing password')
check(command(guest,'Join',{id=id,password='0043'}).error=='WrongPassword','server rejects wrong password')
check(command(guest,'Join',{id=id,password='0042'}).party.id==id,'server accepts four digits with initial zeroes')
check(command(guest,'KickMember',{id=id,memberId=3}).error=='PartyManageLeaderOnly','non-leader cannot kick from network handler')
check(command(guest,'SetPassword',{id=id,password='1234'}).error=='PartyManageLeaderOnly','non-leader cannot change password from network handler')
check(command(host,'KickMember',{id='different',memberId=2}).error=='PartyChanged','stale party management request is rejected')
check(command(host,'KickMember',{id=id,memberId=2}).party.members[2]==nil,'host removes member from roster')
check(not guest.state.party and guest.state.error=='PartyKicked','removed player receives fresh state and notice')
check(command(guest,'Join',{id=id,password='0042'}).error=='PartyKickedBlocked','kicked account cannot rejoin that party')
check(command(host,'SetPassword',{id=id,password=''}).party.passwordRequired==false,'party leader can remove password')
check(command(observer,'Join',{id=id}).party.id==id,'public party accepts a join without password')
check(command(guest,'Create',{target=2}).party.passwordRequired==false,'kicked player can immediately create a public party')

local uiGame={Players={LocalPlayer=host}}
function uiGame:GetService(name) return game:GetService(name) end
local viewModule=loadModule(client.ExpeditionView,{game=uiGame,script=client.ExpeditionView})
local gui=Instance.new('ScreenGui');gui.Name='PartyAccessQA';gui.Parent=game.CoreGui
local ok,err=xpcall(function()
 local root=Instance.new('Frame');root.Parent=gui
 local view=viewModule.create(root,function()end)
 view.panel.Visible=true
 view.render(host.state);view.showTab('Party')
 local roster=view.panel.PartyList
 check(roster.Member3.Kick3 and not roster.Member1:FindFirstChild('Kick1'),'leader sees Kick only on another member')
 check(roster.SetPassword.Active and not roster:FindFirstChild('RemovePassword'),'public party can be locked')
 for _,size in ipairs({Vector2.new(1108,707),Vector2.new(667,375)}) do
  root.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.15)
  local row=roster.Member3
  check(row.Kick3.AbsoluteSize.Y>=44,'kick touch target is at least 44 pixels high')
  check(row.Hero.AbsolutePosition.X+row.Hero.AbsoluteSize.X<=row.Kick3.AbsolutePosition.X,'kick does not overlap member name')
  check(view.panel.PartyDialogOverlay.PartyDialog.AbsoluteSize.X<=view.panel.AbsoluteSize.X,'dialog fits the panel')
 end
 uiGame.Players.LocalPlayer=observer
 local visitor=viewModule.create(root,function()end)
 visitor.panel.Visible=true
 visitor.render(observer.state);visitor.showTab('Party')
 check(not visitor.panel.PartyList.Member1:FindFirstChild('Kick1') and not visitor.panel.PartyList:FindFirstChild('SetPassword'),'non-leader sees no management controls')
 visitor.render({role='Lobby',configured=true,missions=host.state.missions,selection=host.state.selection,list=listings})
 task.wait(.15)
 local recruitment=visitor.panel.PartyList
 check(recruitment.CreatePassword:IsA('TextBox') and recruitment.Create2.Active,'optional password input leaves public create available')
 check(recruitment['Listing'..id].Destination.Text:find('PASSWORD REQUIRED',1,true),'locked recruitment is labelled')
 recruitment.CreatePassword.Text='0071'
 visitor.render({role='Lobby',configured=true,missions=host.state.missions,selection=host.state.selection,list=listings})
 check(recruitment.CreatePassword.Text=='0071','background state refresh preserves password entry')
end,debug.traceback)
gui:Destroy()
assert(ok,err)
return 'Party access native: '..checks..' checks passed'
