local role=require(game.ReplicatedStorage.Shared.PlaceRole).resolve(
 game.PlaceId,game:GetService('RunService'):IsStudio(),workspace:GetAttribute('TLTStudioRole'))
game:GetService('StarterPlayer').CameraMaxZoomDistance=32
workspace:SetAttribute('TLTServerRole',role)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local story=require(script.Story.DeepwoodService)
local spawnService=require(script.Spawn.SpawnService)
local heroSession=require(script.Lobby.HeroSessionService)
local inventory=require(script.Inventory.InventoryService)
local combat=require(script.Combat.DeferredCombat).new(function()return require(script.Combat.CombatService)end)
local expedition=require(script.Network.ExpeditionService)
local world,deepwood,lobby,storyStarted
local sessionOptions
if role=='Lobby' then lobby=require(script.World.LobbyWorld).create()
else
 -- A verified expedition chooses the epic after arrival. No campaign or combat
 -- is generated while waiting for its server-side admission ticket.
 local folder=Instance.new('Folder');folder.Name='BattleArrival';folder.Parent=workspace
 local floor=Instance.new('Part');floor.Name='ArrivalFloor';floor.Anchored=true;floor.Size=Vector3.new(28,2,28);floor.Position=Vector3.new(0,4998,0);floor.Parent=folder
 local sp=Instance.new('SpawnLocation');sp.Anchored=true;sp.Size=Vector3.new(12,.2,12);sp.Position=Vector3.new(0,4999.1,0);sp.Neutral=true;sp.Duration=0;sp.Parent=folder
 lobby={folder=folder,spawn=sp,origin=sp.Position,bounds={center=sp.Position,size=Vector3.new(220,40,220)}}
end
local chests,prompts={},{}
if role=='Lobby' then
 local chest,prompt=require(script.World.StorageChest).create(lobby);table.insert(chests,chest);table.insert(prompts,prompt)
end
inventory.start({chests=chests,prompts=prompts,heroSession=heroSession,combat=combat,storyPending=story.hasPendingEvents,supportCampAccess=story.supportCampAccess})
require(script.Lobby.DailyLoginService).start(inventory)
require(script.Lobby.DeliveryService).start(inventory)
local function startCombat()
 if not world then
  local folder=Instance.new('Model');folder.Name='DeepwoodK0';folder.Parent=workspace
  local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=folder
  world={folder=folder,enemies=enemies}
  combat.start(enemies,heroSession.getCombatContext,inventory.awardXP)
  workspace:SetAttribute('TLTCombatReady',true)
 end
end
local building=false
local buildFailure
local function previewWorld(missionId)
 local chapter=assert(Content.byId[missionId],'Battle entry needs a verified mission')
 local epic=chapter.epic or 1
 -- Serialise different arrivals and Studio party requests across terrain yields.
 while building do task.wait()end
 if buildFailure then error(buildFailure)end
 if deepwood and deepwood.loadedEpics[epic]then return end
 building=true
 local ok,err=xpcall(function()
  startCombat()
  -- Returning to earlier unlocked epics remains possible after reconnecting.
  for id=1,epic do if not deepwood or not deepwood.loadedEpics[id]then
   deepwood=require(script.World.CampaignWorld).create(id,deepwood)
   if deepwood.positions['DW-03']and sessionOptions then
    sessionOptions.outpostBounds={center=deepwood.positions['DW-03'],size=Vector3.new(220,24,200)}
   end
   local hub=Content.epics[id].hub
   local offset=id==1 and Vector3.new(-55,0,-10)or Vector3.new(45,0,id==3 and 75 or 80)
   local chest,prompt=require(script.World.StorageChest).create({folder=deepwood.folder,origin=deepwood.positions[hub]+offset})
   chest.Parent.Name=hub..'AccountStorage';prompt.ObjectText=Content.zones[hub].name..' Storage';inventory.addStorage(chest,prompt)
  end end
  if not storyStarted then
   story.start({world=deepwood,enemies=world.enemies,inventory=inventory,heroSession=heroSession,combat=combat,prepareStory=previewWorld});storyStarted=true
  else story.refreshWorld()end
 end,debug.traceback)
 building=false
 if not ok then buildFailure=tostring(err);error(err)end
end
local function trainingDestination()
 if not world or not world.spawn then
  local prior=world
  local training=require(script.World.TrainingField).create(prior)
  if prior then
   prior.spawn=training.spawn
   for _,enemy in ipairs(training.enemies:GetChildren())do combat.addStoryEnemy(enemy)end
  else
   world=training;combat.start(world.enemies,heroSession.getCombatContext,inventory.awardXP)
   workspace:SetAttribute('TLTCombatReady',true)
  end
 end
 return world.spawn
end
expedition.start({role=role,heroSession=heroSession,inventory=inventory,previewWorld=previewWorld})
sessionOptions={inventory=inventory,combat=combat,lobbySpawn=lobby.spawn,tutorialSpawn=lobby.spawn,
 trainingDestination=trainingDestination,tutorialDestination=function(p,id)return story.destination(p,id)end,
 lobbyBounds=lobby.bounds,requestSpawn=spawnService.requestSpawn,network=expedition}
heroSession.start(sessionOptions)
require(script.Cosmetics.KnightAppearance).start()
require(script.Cosmetics.ArmorAppearance).start()
require(script.Cosmetics.HeroPalette).start()
local merchant=role=='Lobby' and require(script.World.WeaponMerchant).create(lobby) or nil
require(script.Lobby.MerchantService).start({inventory=inventory,merchant=merchant})
local facilities=role=='Lobby' and require(script.World.LobbyLandmarks).create(lobby) or nil
require(script.Lobby.FacilityService).start({facilities=facilities,heroSession=heroSession,expedition=expedition})
local residents=role=='Lobby' and require(script.World.LobbyResidents).create(lobby,facilities,prompts[1]) or nil
if role=='Lobby' then require(script.World.ItemShop).create(lobby) end
require(script.Lobby.NPCService).start({residents=residents,inventory=inventory})
if role=='Lobby' then
 local companions=Instance.new('Folder');companions.Name='LobbyCompanions';companions.Parent=lobby.folder
 require(script.Lobby.SeleneDeparture).start({folder=companions,inventory=inventory,heroSession=heroSession})
end
spawnService.start(lobby.spawn,{
 resolveDestination=function(player,previous)
  local phase=player:GetAttribute('K0SessionPhase');local h=heroSession.getActiveHero(player)
  if h and (phase=='Respawning' or phase=='LoadingTutorial' or phase=='Tutorial')then return h.training and world.spawn or story.destination(player,h.heroId)end
  return previous
 end,onLifeStarted=heroSession.onLifeStarted,onReady=heroSession.onReady,onLifeEnded=heroSession.onLifeEnded,
})
