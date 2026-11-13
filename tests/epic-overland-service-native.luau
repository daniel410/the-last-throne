-- Exercise the actual save queue with lost save responses and region load errors.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated scene only')
local RS=game.ReplicatedStorage;local C=require(RS.Shared.CampaignContent)
local original=game.ServerScriptService.Server.Story.DeepwoodService
local source=original.Source
local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true))
source=source:sub(1,first-1)..'local function publish(...)table.insert(qaNotices,{...})end\n'..source:sub(last)
source=source:gsub('return Service\n',[[function Service.qa(settings,p,c,g)
 options=settings;queues={}
 enqueuePersonal(p,'qa',c,g)
end
return Service
]])
local notices={};local fn=assert(loadstring(source,'OverlandSaveQueueQA'))
setfenv(fn,setmetatable({script=original,qaNotices=notices},{__index=getfenv()}));local service=fn()
local character=Instance.new('Model');character.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
local human=Instance.new('Humanoid');human.RequiresNeck=false;human.Parent=character
local player={Parent=game.Players,Character=character}
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
for index,edge in ipairs(C.overlandLinks)do for _,failLoad in ipairs({false,true})do
 local chapter=C.byId[edge[1]];local nextChapter=C.byId[edge[2]]
 local before={main=index*7-1,flags={},clears={},expeditionMission=chapter.id}
 local after={main=index*7,flags={},clears={[chapter.id]=true},expeditionMission=nextChapter.id}
 local journal=before;local saves,prepares,moves=0,0,0;local calls=0
 root.Position=Vector3.new(table.unpack(C.zones[edge[1]].center))+Vector3.new(0,4,0);local at=root.CFrame
 service.qa({world={spawns={[nextChapter.zone]={CFrame=CFrame.new(table.unpack(C.zones[nextChapter.zone].center))}}},
  inventory={storyState=function()return journal end,growth=function()return {level=80}end,
   expedition=function()return {runId='qa-run',firstClear=true}end,
   storyEvent=function()
    calls+=1
    if calls==1 then return 'SaveUnknown'end
    journal=after;saves+=1
   end},
  heroSession={getCombatContext=function()return {heroId='qa'}end},
  combat={relocateForStoryGate=function()moves+=1 end},
  prepareStory=function(id)
   check(journal==after,'preparation waits for confirmed save');check(id==nextChapter.id,'next epic prepared')
   prepares+=1;if failLoad then error('injected region load failure')end
  end},player,chapter,chapter.goals[#chapter.goals])
 task.wait(.1);check(prepares==0 and moves==0 and journal==before,'unknown save response keeps hero in current region')
 local deadline=os.clock()+4;repeat task.wait(.1)until prepares==1 or os.clock()>deadline
 check(saves==1 and prepares==1,'save retried exactly once before preparing')
 check(moves==0 and root.CFrame==at,'completion and load failure never relocate the hero')
 check(journal.expeditionMission==nextChapter.id,'next saved story remains current')
 local notice=notices[#notices][3]
 check(type(notice)=='string'and notice:find(failLoad and 'could not load'or 'on foot',1,true),'walk or recovery instruction published')
end end
-- The server rejects crossing before the previous epic is complete.
local spawns={};for id,z in pairs(C.zones)do spawns[id]={CFrame=CFrame.new(table.unpack(z.center))}end
for index,edge in ipairs(C.overlandLinks)do
 local journal={main=index*7-1,expeditionMission=edge[1]};local corrections=0
 local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world={spawns=spawns},
  heroSession={getActiveHero=function()return {heroId='qa'}end},
  inventory={storyState=function()return journal end,expedition=function()return {missionId=edge[1]}end},
  combat={relocateForStoryGate=function(_,cf)corrections+=1;character:PivotTo(cf)end},notice=function()end})
 player.GetAttribute=function(_,key)return key=='K0SessionPhase'and 'Tutorial'or nil end
 root.CFrame=spawns[edge[1]].CFrame+Vector3.new(0,4,0);gate.update(player)
 root.CFrame=spawns[edge[2]].CFrame+Vector3.new(0,4,0);gate.update(player)
 check(corrections==1,'server rejects unfinished epic crossing')
 journal.main=index*7;root.CFrame=spawns[edge[2]].CFrame+Vector3.new(0,4,0);gate.update(player)
 check(corrections==1,'confirmed completion opens the crossing')
 gate.remove(player)
end
character:Destroy()
print('OVERLAND_SAVE_QUEUE '..checks..' checks passed')
-- Project only the current epic and the immediate outgoing boundary blockade.
local gates=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodGates).create()
for epic=1,5 do
 local s={main=(epic-1)*7,flags={},clears={},expeditionMission=C.mainChapters[(epic-1)*7+1].id}
 gates.update({journal=s})
 local found=false
 for _,model in ipairs(workspace.PersonalStoryGates:GetChildren())do
  local id=model:GetAttribute('StoryZone');local z=C.zones[id]
  check(z.epic==epic or epic<5 and id==C.overlandLinks[epic][2],'no distant blockade allocation')
  if epic<5 and id==C.overlandLinks[epic][2]then found=true end
 end
 check(epic==5 or found,'outgoing road has a visible story obstacle')
 s.main=epic*7;gates.update({journal=s})
 if epic<5 then for _,m in ipairs(workspace.PersonalStoryGates:GetChildren())do check(m:GetAttribute('StoryZone')~=C.overlandLinks[epic][2],'completed epic removes outgoing obstacle and collider')end end
end
gates.destroy()
print('OVERLAND_SERVICE_PASS '..checks)
