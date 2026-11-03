# Generate an isolated Studio runner; does not modify Studio or access live DataStores.
from pathlib import Path
import re,json
root=Path.cwd()
seeds=['src/server/Network/ExpeditionService.luau','tests/expedition-presentation.spec.lua','tests/expedition-departure.spec.lua','tests/expedition-store.spec.lua','tests/difficulty-enhancement.spec.lua','src/client/ArmoryView.luau','src/client/ExpeditionView.luau','src/server/Inventory/InventoryService.luau','src/client/AdventureReplay.luau']
sources={}
def add(path):
 if path in sources:return
 p=root/path
 if not p.exists():raise RuntimeError(path)
 s=p.read_text();sources[path]=s
 for dep in re.findall(r'dofile\([\'"]([^\'"]+)[\'"]\)',s):add(dep)
 for name in re.findall(r'load\([\'"]([^\'"]+)[\'"]\)',s):add('src/shared/'+name+'.luau')
 for name in re.findall(r'(?:Shared|\.Shared)\.([A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)?)',s):
  dep='src/shared/'+name.replace('.','/')+'.luau'
  if (root/dep).is_file():add(dep)
 for name in re.findall(r'require\(script\.Parent\.([A-Za-z0-9_]+)\)',s):
  dep=str(p.parent.relative_to(root)/ (name+'.luau'))
  if (root/dep).is_file():add(dep)
for seed in seeds:add(seed)
lines=['local sources={']+['['+json.dumps(k)+']='+json.dumps(v,ensure_ascii=False)+','for k,v in sources.items()]+['}']
lines.append('''
local originalGame=game
local compiled,cache={},{}
local function pure(path)
 if cache[path]then return cache[path]end
 local source=assert(sources[path],path)
 local fn,reason=loadstring(source,'@'..path);assert(fn,reason)
 local env=setmetatable({game=false,dofile=pure,print=function()end},{__index=getfenv()})
 setfenv(fn,env);local value=fn();cache[path]=value or true;return value
end
pure('tests/difficulty-enhancement.spec.lua')
pure('tests/expedition-departure.spec.lua')
pure('tests/expedition-store.spec.lua')
pure('tests/expedition-presentation.spec.lua')
local tree={};local nodes={}
for path in pairs(sources)do
 local parent=tree
 local parts={};for part in path:gmatch('[^/]+')do table.insert(parts,part)end
 for i,part in ipairs(parts)do
  local name=part:gsub('%.luau$',''):gsub('%.lua$','')
  if not parent[name]then parent[name]={Parent=parent}end
  parent=parent[name]
 end
 parent.path=path;nodes[path]=parent
end
local signal=Instance.new('BindableEvent');local fixturePlayer={UserId=42,GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Lobby'or nil end,GetAttributeChangedSignal=function()return signal.Event end}
local proxy=setmetatable({ReplicatedStorage={Shared=tree.src.shared},Players={LocalPlayer=fixturePlayer}},{__index=function(_,key)return originalGame[key]end})
function proxy:GetService(name)
 if name=='ReplicatedStorage'then return self.ReplicatedStorage end
 if name=='Players'then return self.Players end
 return originalGame:GetService(name)
end
local nativeCache={}
local function nativeRequire(node)
 if nativeCache[node]then return nativeCache[node]end
 local fn,why=loadstring(assert(sources[node.path],node.path),'@'..node.path);assert(fn,why)
 setfenv(fn,setmetatable({game=proxy,script=node,require=nativeRequire},{__index=getfenv()}))
 local result=fn();nativeCache[node]=result;return result
end
local C=nativeRequire(tree.src.shared.ItemCatalog)
local R=nativeRequire(tree.src.server.Inventory.InventoryRules)
local profile=assert(R.addHero(R.new(42),'hero','knight',C));profile.wallet.gold=10000
local snapshot={ready=true,revision=profile.revision,heroId='hero',heroes=profile.heroes,items={},wallet=profile.wallet,atHub=true}
for _,item in pairs(profile.items)do table.insert(snapshot.items,item)end
-- Exercise the actual account service with isolated remotes/session storage.
local oldService=proxy.GetService
local events,threads={},{};local lastInventoryError
local fakeRemotes={};local attrs={K0SessionPhase='Lobby'}
local fakePlayers={}
local actor={UserId=42,Parent=fakePlayers,GetAttribute=function(_,key)return attrs[key]end,SetAttribute=function(_,key,v)attrs[key]=v end}
local fakeRS={Shared=tree.src.shared,Remotes=fakeRemotes,FindFirstChild=function(_,name)return name=='Remotes'and fakeRemotes end}
local taskProxy=setmetatable({spawn=function(fn,...)local thread=task.spawn(fn,...);table.insert(threads,thread);return thread end},{__index=task})
local instanceProxy={new=function(kind,...)
 if kind~='RemoteEvent'then return Instance.new(kind,...)end
 local e={};function e:Connect(fn)self.fn=fn;return {Disconnect=function()end}end;function e:Fire(...)return self.fn(...)end
 return setmetatable({OnServerEvent=e,event=e,FireClient=function(_,_,_,_,reason)lastInventoryError=reason end},{__newindex=function(self,key,v)rawset(self,key,v);if key=='Parent'then v[self.Name]=self end end})
end}
local serviceGame={GetService=function(_,name)
 if name=='ReplicatedStorage'then return fakeRS end
 if name=='Players'then return fakePlayers end
 if name=='RunService'then return {IsStudio=function()return true end}end
 return originalGame:GetService(name)
end,BindToClose=function()end}
local serviceFn=assert(loadstring(sources['src/server/Inventory/InventoryService.luau']))
setfenv(serviceFn,setmetatable({game=serviceGame,script=tree.src.server.Inventory.InventoryService,require=nativeRequire,task=taskProxy,Instance=instanceProxy,workspace={GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Lobby'or nil end}},{__index=getfenv()}))
local inventory=serviceFn()
local ctx={heroId='service-hero',generation=1,atHub=true}
inventory.start({prompts={},heroSession={getInventoryContext=function()return ctx end,refresh=function()end,isBusy=function()return false end},combat={isSafeForEquipment=function()return true end,refreshEquipment=function()end}})
local serviceOK,serviceError=xpcall(function()
 assert(inventory.open(actor));assert(not inventory.createHero(actor,'service-hero','knight'))
 assert(not inventory.beginExpedition(actor,'service-hero','DW-01','Easy','service-first'))
 local function finish(run)
  attrs.K0SessionPhase='Tutorial';ctx.atHub=false
  local c=nativeRequire(tree.src.shared.CampaignContent).byId['DW-01']
  for _,g in ipairs(c.goals)do if not g.optional then
   if g.activity and g.activity.steps then
    for _,step in ipairs(g.activity.steps)do assert(not inventory.storyEvent(actor,'service-hero',c.id,g.id,step.choices and step.choices[1].id,step.id,run))end
   else assert(not inventory.storyEvent(actor,'service-hero',c.id,g.id,g.choice and 'sanctuary',nil,run))end
  end end
  assert(inventory.expedition(actor,'service-hero').completed)
 end
 attrs.K0SessionPhase='Tutorial';ctx.atHub=false
 inventory.reveal(actor,'service-hero','DW-01',2,2);task.wait(.1)
 assert(inventory.storyState(actor,'service-hero').explored['DW-01']['1'],'saved fog missing from service projection')
 finish('service-first');local money=inventory.snapshot(actor).wallet.gold;local diamonds=inventory.snapshot(actor).wallet.diamonds
 attrs.K0SessionPhase='Lobby';ctx.atHub=true
 assert(not inventory.beginExpedition(actor,'service-hero','DW-01','Easy','service-replay'));finish('service-replay')
 assert(inventory.snapshot(actor).wallet.gold==money+45,'service replay reward did not commit')
 assert(inventory.snapshot(actor).wallet.diamonds==diamonds,'service replay duplicated Diamonds')
 attrs.K0SessionPhase='Lobby';ctx.atHub=true
 local s=inventory.snapshot(actor);local item
 for _,v in ipairs(s.items)do if v.definitionId=='knight_weapon_fine'and v.location.kind=='bag'then item=v;break end end
 assert(not inventory.shop(actor,{action='Enhance',store='blacksmith',heroId='service-hero',requestId='service-enhance',revision=s.revision,instanceId=item.instanceId,itemVersion=item.version}))
 s=inventory.snapshot(actor);for _,v in ipairs(s.items)do if v.instanceId==item.instanceId then item=v end end
 fakeRemotes.InventoryRequest.event:Fire(actor,{action='Equip',heroId='service-hero',requestId='service-equip',revision=s.revision,instanceId=item.instanceId,itemVersion=item.version})
 task.wait(.1)
 assert(math.abs(inventory.stats(actor,'service-hero').power-10.3)<.00001,'enhanced equipment not reflected in service stats: '..tostring(inventory.stats(actor,'service-hero').power)..' error='..tostring(lastInventoryError))
end,debug.traceback)
for _,thread in ipairs(threads)do pcall(task.cancel,thread)end
for _,event in ipairs(events)do event:Destroy()end
assert(serviceOK,serviceError)
local gui=Instance.new('ScreenGui');gui.Name='TLT_DifficultySmoke' ;gui.Enabled=false;gui.Parent=originalGame:GetService('CoreGui')
local ok,result=xpcall(function()
 local armory=nativeRequire(tree.src.client.ArmoryView).create(gui,function()end,false,'blacksmith')
 armory.render(snapshot);armory.setMode('Enhance')
 local forgeButtons=0
 for _,node in ipairs(armory.panel:GetDescendants())do if node:IsA('TextButton')and node.Name:match('Action')then forgeButtons=forgeButtons+1 end end
 assert(forgeButtons>=4,'forge equipment and exchange actions missing')
 assert(armory.panel:FindFirstChild('EnhanceTab'),'TD enhance tab missing')
 -- A live Lobby does not create DeepwoodState: commerce must never wait for it.
 local replayFn=assert(loadstring(sources['src/client/AdventureReplay.luau']))
 local lobbyGame={GetService=function(_,name)
  if name=='Players'then return {LocalPlayer=fixturePlayer}end
  if name=='ReplicatedStorage'then return {Shared=tree.src.shared,WaitForChild=function(_,name)assert(name=='Remotes');return {}end}end
  if name=='RunService'then return {IsStudio=function()return false end}end
  return originalGame:GetService(name)
 end}
 setfenv(replayFn,setmetatable({game=lobbyGame,script=tree.src.client.AdventureReplay,require=nativeRequire,workspace={GetAttribute=function()return 'Lobby'end},task={spawn=function()error('Lobby cannot wait for battle world remotes')end,delay=task.delay}},{__index=getfenv()}))
 replayFn().start(gui);assert(gui:FindFirstChild('PlayAgain')and not gui.PlayAgain.Visible,'live Lobby replay startup failed')
 local view=nativeRequire(tree.src.client.ExpeditionView).create(gui,function()end)
 local modes={};for _,name in ipairs({'Easy','Hard','Insane','Hell'})do modes[name]={allowed=name=='Easy',level=name=='Easy'and 1 or 80,reason='PreviousDifficulty'}end
 view.render({role='Lobby',population=1,capacity=20,selection={missionId='DW-01',difficultyId='Easy'},missions={{id='DW-01',title='Convoy Rescue',modes=modes}}})
 for _,name in ipairs({'Easy','Hard','Insane','Hell'})do assert(view.panel:FindFirstChild('Mode'..name,true),'mode missing '..name)end
 assert(view.panel:FindFirstChild('Solo',true).Active,'Lv1 Easy solo unexpectedly disabled')
 view.render({role='Lobby',population=1,capacity=20,selection={missionId='DW-01',difficultyId='Hell'},missions={{id='DW-01',title='Convoy Rescue',modes=modes}}})
 assert(not view.panel:FindFirstChild('Solo',true).Active,'locked Hell solo not disabled')
 for _,size in ipairs({Vector2.new(1200,800),Vector2.new(844,390)})do
  armory.panel.Size=UDim2.fromOffset(size.X-40,size.Y-40);armory.render(snapshot);armory.setMode('Enhance');task.wait(.1)
  for _,b in ipairs(armory.panel:GetDescendants())do if b:IsA('TextButton')and b.Visible then assert(b.AbsoluteSize.Y>=43,'touch target below44 '..b.Name)end end
 end
 return {pure='difficulty, enhancement, departure recovery and store checks passed in native Luau',service='durable begin, first/repeat completion, forge/equip and equipment stats passed',forgeButtons=forgeButtons,ui='four modes, locked entry, enhancement and desktop/mobile controls passed'}
end,debug.traceback)
gui:Destroy();signal:Destroy();assert(ok,result);return result
''')
(root/'builds').mkdir(exist_ok=True)
(root/'builds/difficulty-native-smoke.luau').write_text('\n'.join(lines))
print(json.dumps({'files':len(sources),'bytes':sum(len(s)for s in sources.values())}))
