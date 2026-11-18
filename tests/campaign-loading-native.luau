-- Fresh isolated Edit scene with project models; never a live Place.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local QA only')
local Server=game.ServerScriptService.Server
local C=require(game.ReplicatedStorage.Shared.CampaignContent)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
-- Execute the real admission function with controlled builders and yield races.
local source=Server.Source
local first=assert(source:find('local building=false',1,true))
local last=assert(source:find('local function trainingDestination',first,true))
local code=source:sub(first,last-1)..'\nreturn previewWorld'
local function fixture(failure)
 local loaded,calls={},{}
 local world={loadedEpics=loaded}
 local starts,refreshes=0,0
 local story={start=function()starts+=1 end,refreshWorld=function()refreshes+=1 end}
 local create={create=function(epic,prior)
  calls[#calls+1]=epic;task.wait()
  if failure then error('injected builder failure')end
  check(prior==nil or prior==world,'world identity retained')
  loaded[epic]=true;return world
 end}
 local env=setmetatable({Content=C,script=Server,workspace={SetAttribute=function()end},
  require=function(module)check(module==Server.World.CampaignWorld,'only campaign builder required');return create end,
  world={enemies={}},story=story,startCombat=function()end,addRegionalStorage=function(id)check(loaded[id],'storage after destination ready')end,
  print=function()end},{__index=getfenv()})
 local fn=assert(loadstring(code));setfenv(fn,env)
 return fn(),calls,world,function()return starts,refreshes end
end
for epic=1,5 do
 local prepare,calls,w,counts=fixture()
 local mission=C.mainChapters[(epic-1)*7+1].id
 prepare(mission);check(#calls==1 and calls[1]==epic,'admission constructs exactly destination epic')
 prepare(mission);check(#calls==1,'repeat admission reuses world')
 local starts,refreshes=counts();check(starts==1 and refreshes==0,'story service starts once')
 check(not pcall(prepare,'unknown-mission'),'reject invalid mission')
end
local prepare,calls,w,counts=fixture()
local finished=0
for _,epic in ipairs({5,5,4,5})do task.spawn(function()prepare(C.mainChapters[(epic-1)*7+1].id);finished+=1 end)end
local deadline=os.clock()+5
while finished<4 and os.clock()<deadline do task.wait()end
check(finished==4 and #calls==2 and w.loadedEpics[5]and w.loadedEpics[4],'concurrent admission builds each epic once')
local starts,refreshes=counts();check(starts==1 and refreshes==1,'refresh existing story after extra epic')
local failed,failureCalls=fixture(true)
check(not pcall(failed,'HG-01'),'builder failure rejects admission')
check(not pcall(failed,'HG-01')and #failureCalls==1,'partial failed geometry never treated as ready')
-- Actual region gate: missing geometry and unfinished roads cannot be entered.
local Gate=require(Server.Story.DeepwoodRegionAccess)
local B=require(game.ReplicatedStorage.Shared.CampaignBounds)
assert(not workspace:FindFirstChild('DeepwoodCampaign'),'fresh geometry fixture required')
local World=require(Server.World.CampaignWorld)
local t=os.clock();local world=World.create(5)
local geometry={epic5Seconds=os.clock()-t,epic5Instances=#world.folder:GetDescendants(),reverse={}}
check(world.loadedEpics[5]and not world.loadedEpics[1]and not world.loadedEpics[4],'standalone epic5 geometry')
for _,epic in ipairs({4,3,2,1})do
 local started=os.clock();local nextWorld=World.create(epic,world)
 check(nextWorld==world and world.loadedEpics[5],'reverse loading retains original story tables')
 geometry.reverse[#geometry.reverse+1]={epic=epic,seconds=os.clock()-started}
end
local instances=#world.folder:GetDescendants()
for epic=1,5 do check(World.create(epic,world)==world,'loaded epic reused')end
check(#world.folder:GetDescendants()==instances,'no duplicate geometry on reentry')
check(#world.folder.OverlandRoads:GetChildren()==4,'all reverse links created')
geometry.finalInstances=instances
local character=Instance.new('Model');character.Name='LoadingGateQA';character.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Anchored=true;root.Parent=character;character.PrimaryPart=root
local human=Instance.new('Humanoid');human.RequiresNeck=false;human.HipHeight=2;human.Parent=character
local player={Character=character,GetAttribute=function(_,k)return k=='K0SessionPhase'and 'Tutorial'end}
for _,edge in ipairs(C.overlandLinks)do for side=1,2 do
 local from,to=edge[side],edge[3-side];local journal={main=35,flags={},clears={},expeditionMission=from}
 local moves=0
 local gate=Gate.create({world=world,heroSession={getActiveHero=function()return {heroId='qa'}end},
 inventory={storyState=function()return journal end,expedition=function()return {missionId=from}end},
 combat={relocateForStoryGate=function(_,cf)moves+=1;character:PivotTo(cf)end},notice=function()end})
 root.Position=world.spawns[from].Position+Vector3.new(0,3,0);gate.update(player)
 local a,b=B.ends(edge);local mid=(Vector3.new(table.unpack(a))+Vector3.new(table.unpack(b)))/2
 local road=world.folder.OverlandRoads:FindFirstChild(from..'_'..to)or world.folder.OverlandRoads:FindFirstChild(to..'_'..from)
 road:SetAttribute('BuildComplete',false);root.Position=mid+Vector3.new(0,3,0);gate.update(player)
 check(moves==1,'unfinished overland road rejected '..from..' to '..to..' moves='..moves)
 road:SetAttribute('BuildComplete',true)
 world.loadedEpics[C.zones[to].epic]=nil
 root.Position=world.spawns[to].Position+Vector3.new(0,3,0);gate.update(player)
 check(moves==2,'partial destination spawns do not grant entry')
 world.loadedEpics[C.zones[to].epic]=true
 root.Position=world.spawns[to].Position+Vector3.new(0,3,0);gate.update(player)
 check(moves==2,'ready destination permits return travel')
 gate.remove(player)
end end
character:Destroy()
return {checks=checks,pass=true,geometry=geometry}
