assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated QA only')
assert(not workspace:FindFirstChild('DeepwoodCampaign'),'fresh geometry fixture')
local modules=game.ServerScriptService.Server.World
local P=require(modules.CampaignPreparation)
local W=require(modules.CampaignWorld)
local Art=require(modules.EpicWorldArt)
local originalCreate,originalConnect=W.create,Art.connectOverland
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
local world=P.new();local report={}
local ok,err=xpcall(function()
 local started=os.clock();P.prepare(5,world);world.readyEpics[5]=true
 report.epic5Seconds=os.clock()-started
 local hg=world.spawns['HG-01'];local oldNodes=world.nodes
 local survivor=Instance.new('Folder');survivor.Name='ConcurrentEncounterSentinel';survivor.Parent=world.folder
 local builds=0
 W.create=function(epic,stage)
  if epic==4 then builds+=1 end
  local result=originalCreate(epic,stage)
  if epic==4 and builds==1 then error('injected after full regional geometry, before commit')end
  return result
 end
 check(not pcall(P.prepare,4,world),'stage failure surfaced')
 check(world.spawns['EC-01']==nil and not world.geometryEpics[4] and not world.loadedEpics[4],'failed stage publishes no nodes or readiness')
 check(not workspace:FindFirstChild('CampaignPreparing'),'failed stage cleaned up')
 check(hg.Parent and world.spawns['HG-01']==hg and world.nodes==oldNodes and survivor.Parent==world.folder,'existing world and concurrent gameplay survive')
 check(P.prepare(5,world)==world and world.readyEpics[5],'existing epic remains usable')
 Art.connectOverland=function(w)
  if w==world then
   local parent=w.folder:FindFirstChild('OverlandRoads')or Instance.new('Folder');parent.Name='OverlandRoads';parent.Parent=w.folder
   local partial=Instance.new('Model');partial.Name='EC-07_HG-01';partial.Parent=parent
   error('injected partial road')
  end
  return originalConnect(w)
 end
 check(not pcall(P.prepare,4,world),'road failure surfaced')
 check(world.geometryEpics[4]and not world.loadedEpics[4],'committed geometry retained but not ready')
 check(world.spawns['HG-01']==hg and survivor.Parent==world.folder,'road failure preserves live region')
 Art.connectOverland=originalConnect
 P.prepare(4,world);world.readyEpics[4]=true
 check(builds==2 and world.loadedEpics[4],'road retry reuses geometry')
 check(world.folder.OverlandRoads['EC-07_HG-01']:GetAttribute('BuildComplete')==true,'incomplete road replaced')
 for _,id in ipairs({3,2,1})do P.prepare(id,world);world.readyEpics[id]=true end
 check(world.nodes==oldNodes and world.spawns['HG-01']==hg,'all regions preserve table and spawn identity')
 for _,id in ipairs({1,2,3,4,5})do check(world.loadedEpics[id]and world.readyEpics[id],'all ready')end
 check(#world.folder.OverlandRoads:GetChildren()==4,'exactly four connections')
 check(#world.folder.NPCActors:GetChildren()==32,'all baseline actors preserved')
 check(not game:FindFirstChild('NPCActors')and not workspace:FindFirstChild('CampaignPreparing'),'no staging actor leak')
 survivor:Destroy()
 local count=#world.folder:GetDescendants();for i=1,5 do P.prepare(i,world)end
 check(#world.folder:GetDescendants()==count,'retry and warm entry have no duplicates')
 report.instances=count;report.checks=checks
end,debug.traceback)
W.create=originalCreate;Art.connectOverland=originalConnect
assert(ok,err)
return report
