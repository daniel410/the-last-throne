-- Run only in the isolated rbxlx fixture; never in a player's published session.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated player-free fixture required')
local Shared=game.ReplicatedStorage.Shared
local C=require(Shared.CampaignContent)
local report={kind='CAMPAIGN_REORDER_NATIVE',checks=0,worlds={},pass=false}
local function check(v,m)report.checks+=1;assert(v,m)end
local World=require(game.ServerScriptService.Server.World.CampaignWorld)
local world
for epic=1,5 do
 world=World.create(epic,world)
 check(world.loadedEpics[epic],'world ready '..epic)
 local scope=World.scope(epic);local count=0
 for id in pairs(scope.content.zones)do
  count+=1
  local spawn=assert(world.spawns[id],'missing region spawn '..id)
  check(spawn.Parent==world.folder and spawn.Enabled,'enabled spawn '..id)
 end
 local prefix=C.epics[epic].hub:sub(1,2)
 for _,c in ipairs(scope.content.chapters)do
  check(c.id:sub(1,2)==prefix,'no wrong theme in loaded epic')
  for _,g in ipairs(c.goals)do
   local node=world.nodes[c.id..':'..g.id]
   check(node~=nil,'actual objective exists '..c.id..':'..g.id)
  end
 end
 table.insert(report.worlds,{epic=epic,region=C.epics[epic].region,zones=count})
 task.wait()
end
local props=world.folder:FindFirstChild('LateEpicProps')
local count=0;for _,child in ipairs(world.folder:GetChildren())do if child.Name=='LateEpicProps'then count+=1 end end
check(count==1,'GW/HG share the streamed completion prop container')
check(props:FindFirstChild('Crownheart')and props:FindFirstChild('InvasionPortal'),'finale props survive two late region builds')
check(world.folder:FindFirstChild('GW-01_SP')and world.folder:FindFirstChild('FV-01_SP'),'GW second and FV third have actual spawns')
local region=world.terrain:FindFirstChild('GW-01')
check(region and region:GetAttribute('EpicId')=='Gloamwood','epic2 remains Gloamwood, never winter')
local _,size=region:GetBoundingBox();check(size.Magnitude>0,'actual forest geometry built')
-- Verify the actual runtime uses region identity for calm/hazard behavior.
local source=game.ServerScriptService.Server.Story.DeepwoodService.Source
check(source:find("e.chapter.id:sub(1,2)=='FV' and model",1,true)~=nil,'winter-only nonlethal guardian rule')
check(source:find("e.chapter.id:sub(1,2)=='EC' and 'FurnaceHeatWarning'",1,true)~=nil,'furnace hazard remains volcanic')
local D=require(Shared.Difficulty);local B=require(Shared.DeepwoodEncounterBalance)
local model=Instance.new('Model')
local body=assert(source:match('(local function applyBalance.-)\nlocal spawnWave'))
local apply=assert(loadstring('return function(Balance)\n'..body..'\nreturn applyBalance end'))()(B)
for _,id in ipairs({'GW-01','GW-07','FV-01','EC-07','HG-07'})do
 local c=C.byId[id]
 for _,g in ipairs(c.goals)do for _,batch in ipairs(B.encounterWaves(c,g,1))do for index,spec in ipairs(batch)do
  for _,version in ipairs({9,10})do
   apply(model,spec,1,'Easy',version,index)
   local hp,damage,level=B.unitStats(spec,1,'Easy',version,index)
   local xp,gold=B.rewards(spec,'Easy',version)
   check(model:GetAttribute('StoryLevel')==level and model:GetAttribute('StoryHealth')==hp and model:GetAttribute('StoryDamage')==damage,'server bridge applies pinned/current stat contract')
   check(model:GetAttribute('StoryRewardXP')==xp and model:GetAttribute('StoryRewardGold')==gold,'server bridge applies pinned/current reward contract')
  end
 end end end
end
model:Destroy()
report.pass=true
print('CAMPAIGN_REORDER_NATIVE '..game.HttpService:JSONEncode(report));return report
