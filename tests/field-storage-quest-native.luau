-- Studio Edit-mode, isolated RPG account and real character/chest geometry.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local server=game.ServerScriptService.Server
local content=require(game.ReplicatedStorage.Shared.CampaignContent)
local progress=require(game.ReplicatedStorage.Shared.DeepwoodProgress)
local function instrument(original,extra)
 local module=original:Clone()
 module.Source=module.Source:gsub('\nreturn (%w+)%s*$',function(name)return '\n'..extra..'\nreturn '..name end)
 module.Parent=original.Parent
 return require(module)
end
local folder=Instance.new('Folder',workspace)
local char=Instance.new('Model',folder)
local root=Instance.new('Part',char);root.Name='HumanoidRootPart';root.Anchored=true
Instance.new('Humanoid',char);char:SetAttribute('K0SpawnReady',true)
local p={UserId=70001,Parent=game.Players,Character=char,SetAttribute=function()end,GetAttribute=function()return 'Tutorial'end}
local session=instrument(server.Lobby.HeroSessionService,[[
function HeroSessionService.qa(player,bounds)
 sessions[player]={player=player,selectedHeroId='hero',byId={hero={heroId='hero',baseClassId='mage'}},generation=1,revision=0,
  character=player.Character,ready=true,phase='Tutorial',mode='Tutorial'}
 settings={hubBounds=bounds,lobbyBounds={center=Vector3.zero,size=Vector3.one}}
end]])
local inv=instrument(server.Inventory.InventoryService,[[
Service.qaCommand=handle
function Service.qaCapture()stateRemote={FireClient=function(_,p,_,_,reason)p.lastError=reason end}end]])
local bounds,chests={},{}
session.qa(p,bounds)
inv.start({chests=chests,prompts={},heroSession=session,combat={refreshEquipment=function()end,isSafeForEquipment=function()return false end}})
inv.qaCapture()
assert(inv.open(p));assert(not inv.createHero(p,'hero','mage'))
local source=server.Source
local a=assert(source:find('local function addRegionalStorage',1,true))
local b=assert(source:find('local building=false',a,true))
local bootstrap=Instance.new('ModuleScript',folder)
bootstrap.Source='return function(script,Content,deepwood,hubBounds,inventory)\n'..source:sub(a,b-1)..'return addRegionalStorage end'
local world={positions={},folder=folder}
local create=require(bootstrap)(server,content,world,bounds,inv)
local function command(action,id,seq)
 local snapshot=inv.snapshot(p)
 for _,item in ipairs(snapshot.items)do if item.instanceId==id then
  inv.qaCommand(p,{requestId='storage-'..seq,heroId='hero',revision=snapshot.revision,
   itemVersion=item.version,instanceId=id,quantity=item.quantity,action=action})
  return
 end end
 error('item missing')
end
for i,epic in ipairs(content.epics)do
 world.positions[epic.hub]=Vector3.new(table.unpack(content.zones[epic.hub].center))
 create(i)
 local chest=chests[i]
 root.Position=chest.Position+Vector3.new(0,3,10)
 local snapshot=inv.snapshot(p)
 assert(snapshot.atHub and snapshot.atStorage,epic.hub..' denies storage at its prompt')
 local id
 for _,item in ipairs(snapshot.items)do if item.location.kind=='bag' then id=item.instanceId;break end end
 command('Deposit',assert(id),i..'-in');assert(not p.lastError,p.lastError)
 assert(inv.snapshot(p).storageUsed==snapshot.storageUsed+1)
 command('Withdraw',id,i..'-out');assert(not p.lastError,p.lastError)
 assert(inv.snapshot(p).storageUsed==snapshot.storageUsed)
 root.Position=chest.Position+Vector3.new(30,3,0)
 assert(not inv.snapshot(p).atStorage,epic.hub..' permits remote storage')
end
local journal=inv.storyState(p,'hero')
local chapter
for _,c in ipairs(content.chapters)do if c.side and progress.canAccept(journal,c) then chapter=c;break end end
local node={part=chests[1],chapter=assert(chapter)}
local story=instrument(server.Story.DeepwoodService,[[
function Service.qa(player,node,inventory)
 offers[player]={node=node,heroId='hero',character=player.Character}
 options={heroSession={getCombatContext=function()return {heroId='hero'}end},inventory=inventory}
 publish=function()end
end]])
story.qa(p,node,inv)
root.Position=node.part.Position+Vector3.new(20,0,0)
assert(not story.acceptQuest(p,chapter.id),'a remote player accepted the offer')
root.Position=node.part.Position+Vector3.new(0,3,0)
assert(story.acceptQuest(p,chapter.id),'offered side quest was rejected')
local deadline=os.clock()+3
repeat task.wait() until not story.hasPendingEvents(p) or os.clock()>deadline
assert(progress.accepted(inv.storyState(p,'hero'),chapter),'side quest queue did not save to the account')
assert(not story.acceptQuest(p,chapter.id),'offer could be consumed twice')
folder:Destroy()
print('FIELD_STORAGE_QUEST_NATIVE PASS: 5 regional deposits and withdrawals, distance gates, optional quest acceptance and replay')
