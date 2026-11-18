-- Actual region access + asynchronous preparation policy with a stub builder.
-- This validates eligibility/lifecycle, not geometry generation or live teleport.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated Edit QA only')
local Server=game.ServerScriptService.Server
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local Gate=require(Server.Story.DeepwoodRegionAccess)
local Streaming=require(Server.Story.CampaignStreaming)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='StoryPrefetchQA';fixture.Parent=workspace
local character=Instance.new('Model');character.Parent=fixture
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Anchored=true;root.Parent=character;character.PrimaryPart=root
local human=Instance.new('Humanoid');human.HipHeight=2;human.RequiresNeck=false;human.Parent=character
local locked=true
local player={Character=character,GetAttribute=function(_,key)
 if key=='K0SessionPhase'then return 'Tutorial'elseif key=='TLTTravelLock'then return locked end
end}
local hero={heroId='qa'}
local ok,err=xpcall(function()
 for index,edge in ipairs(Content.overlandLinks)do
  local from,to=edge[1],edge[2]
  local journal={main=index*7-1,flags={},clears={},expeditionMission=from}
  local world={folder=fixture,spawns={},loadedEpics={[Content.zones[from].epic]=true}}
  for _,id in ipairs(edge)do world.spawns[id]={CFrame=CFrame.new(table.unpack(Content.zones[id].center))}end
  local requests,completed,moves=0,false,0
  local prepare=Streaming.create({world=world,prepareStory=function(id)
   requests+=1;check(id==to,'next epic target');task.wait(.02)
   world.loadedEpics[Content.zones[to].epic]=true;completed=true
  end})
  local gate=Gate.create({world=world,prepareNearby=prepare,
   heroSession={getActiveHero=function()return hero end},
   inventory={storyState=function()return journal end,expedition=function()return {missionId=from}end},
   combat={relocateForStoryGate=function(_,cf)moves+=1;character:PivotTo(cf)end},notice=function()end})
  root.CFrame=world.spawns[from].CFrame+Vector3.new(0,3,0)
  locked=true;character:SetAttribute('K0SpawnReady',true);gate.update(player)
  check(requests==0,'initial travel lock prevents background work')
  locked=false;character:SetAttribute('K0SpawnReady',false);gate.update(player)
  check(requests==0,'unfinished character spawn prevents background work')
  character:SetAttribute('K0SpawnReady',true);gate.update(player)
  check(not completed,'story update returns before background construction completes')
  for i=1,4 do gate.update(player)end
  task.wait(.05)
  check(requests==1 and completed,'stationary story entry prepares next epic once')
  check(journal.main==index*7-1 and moves==0,'prefetch never changes journal or relocates hero')
  root.CFrame=world.spawns[to].CFrame+Vector3.new(0,3,0);gate.update(player)
  check(moves==1,'fully prepared next epic still denied before completion')
  journal.main=index*7
  root.CFrame=world.spawns[to].CFrame+Vector3.new(0,3,0);gate.update(player)
  check(moves==1,'confirmed completion permits entering prepared epic')
  root.CFrame=world.spawns[from].CFrame+Vector3.new(0,3,0);gate.update(player)
  check(requests==1,'returning to outgoing story reuses prepared neighbour')
  gate.remove(player)
 end
end,debug.traceback)
fixture:Destroy()
assert(ok,err)
return {pass=true,checks=checks,coverage='actual region gate and scheduler; stub geometry builder; four epic transitions'}
