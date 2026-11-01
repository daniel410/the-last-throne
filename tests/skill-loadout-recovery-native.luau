-- Actual growth GUI + account rules, isolated transport/Player. No live storage.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Use an isolated local fixture')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local C=require(game.ReplicatedStorage.Shared.ItemCatalog)
local root=Instance.new('Folder');root.Name='LoadoutRecoveryQA';root.Parent=workspace
local playerGui=Instance.new('Folder');playerGui.Name='PlayerGui';playerGui.Parent=root
local harness=Instance.new('ModuleScript');harness.Name='LoadoutTransportQA';harness.Source=[[local H={sent={}};local event=Instance.new('BindableEvent');H.remotes={}
function H.remotes:WaitForChild(name) return {OnClientEvent=event.Event,FireServer=function(_,cmd) if name=='HeroProgressionRequest' then table.insert(H.sent,cmd) end end} end
return H]];harness.Parent=client
local module=client.HeroGrowthGui:Clone();module.Name='LoadoutRecoveryQA'
local source=module.Source
source=source:gsub('local Players=game:GetService%("Players"%)',[[local Players={LocalPlayer={WaitForChild=function()return script.PlayerGui.Value end,GetAttribute=function(_,k)return script.PlayerGui.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.PlayerGui.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.PlayerGui.Value:GetAttributeChangedSignal(k)end}}]])
source=source:gsub('local CAS=game:GetService%("ContextActionService"%)','local CAS={BindAction=function()end,BindActionAtPriority=function()end,UnbindAction=function()end}')
source=source:gsub('local remotes=RS:WaitForChild%("Remotes"%)','local remotes=require(script.Parent.LoadoutTransportQA).remotes')
source=source:gsub(' task.spawn%(function%(%) while gui.Parent do.-end end%)','')
source=source:gsub('return {open=function','return {qaReceive=receiveInventory,qaSend=send,open=function')
module.Source=source;module.Parent=client
local ref=Instance.new('ObjectValue');ref.Name='PlayerGui';ref.Value=playerGui;ref.Parent=module
local n=0;local function check(v,m)n+=1;assert(v,m)end
local ok,err=xpcall(function()
 local view=require(module).create();local transport=require(harness)
 local p=assert(R.addHero(R.new(7),'mage','mage',C));p.heroes.mage.progression=G.new(5);p.heroes.mage.level=5
 local function snapshot(profile,safe)
  return {ready=true,atHub=false,canInvest=safe~=false,heroId='mage',revision=profile.revision,items={},heroes=R.copy(profile.heroes)}
 end
 view.qaReceive(snapshot(p));view.open('Skills')
 local gui=playerGui.HeroGrowthGui;local panel=gui.Overlay.InventoryPanel;local content=panel.Content
 local slot=content.CombatLoadout.Slot4
 view.qaReceive(snapshot(p),'poll')
 check(content.CombatLoadout.Slot4==slot,'unchanged polls retain pressed slot buttons')
 view.qaSend('SetSkillSlot',{slot=4,skill=30})
 local first=transport.sent[1];check(first and first.slot==4 and first.skill==30,'Lv5 Wind Lance choice sends index30 to slot4')
 p=assert(R.progress(p,{action='AwardXP',heroId='mage',stream='qa',sequence=1,amount=1},{serverReward=true},C))
 local rejected,reason=R.progress(p,first,{canInvest=true},C)
 check(not rejected and reason=='Changed','concurrent XP reproduces rejected save')
 view.qaReceive(snapshot(p)) -- New state may arrive before the rejection.
 local newest=R.copy(p);newest.revision+=1;view.qaReceive(snapshot(newest))
 view.qaReceive(snapshot(p),first.requestId,reason)
 local retry=transport.sent[2]
 check(retry and retry.revision==newest.revision and retry.requestId~=first.requestId,'late rejection rebases once against newest revision')
 check(retry.slot==4 and retry.skill==30,'retry preserves the exact selected skill and slot')
 p=assert(R.progress(newest,retry,{canInvest=true},C))
 view.qaReceive(snapshot(p),retry.requestId)
 check(p.heroes.mage.progression.skillSlots[4]==30,'server stores Wind Lance in fourth slot')
 check(panel.Message.Text=='Hero saved.','save success survives render')
 view.qaReceive(snapshot(p),'poll2');check(panel.Message.Text=='Hero saved.','poll does not overwrite save feedback')
 view.qaSend('SetSkillSlot',{slot=4,skill=30});local third=transport.sent[3]
 view.qaReceive(snapshot(p),third.requestId,'Changed');local fourth=transport.sent[4]
 check(fourth~=nil,'next separate user choice permits one rebase')
 view.qaReceive(snapshot(p),fourth.requestId,'Changed')
 check(#transport.sent==4,'repeated revision conflict never retries in a loop')
 check(panel.Message.Text:find('Your hero changed',1,true)~=nil,'final failure stays visible')
 view.qaSend('SetSkillSlot',{slot=4,skill=30});local fifth=transport.sent[5]
 view.qaReceive(snapshot(p,false),fifth.requestId,'UnsafeGrowth')
 check(#transport.sent==5 and panel.Message.Text:find('Move away',1,true),'unsafe save shows actionable reason without retry')
 view.qaReceive(snapshot(p));view.qaSend('SetSkillSlot',{slot=4,skill=30});local sixth=transport.sent[6]
 view.qaReceive(snapshot(p),sixth.requestId,'SaveUnknown')
 view.qaSend('SetSkillSlot',{slot=4,skill=30})
 check(#transport.sent==6 and panel.Message.Text:find('pending',1,true),'unknown save retains original request and feedback')
 view.close();gui:Destroy()
end,debug.traceback)
root:Destroy();module:Destroy();harness:Destroy()
print('SKILL_LOADOUT_RECOVERY_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=n,error=not ok and tostring(err) or nil}))
assert(ok,err)
