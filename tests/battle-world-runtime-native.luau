-- Isolated engine harness. The appended code runs as the actual server Script,
-- so plugin-only properties cannot accidentally pass this regression again.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated engine only')
local Run=game:GetService('RunService')
assert(not Run:IsRunning(),'fresh edit session required')
workspace:SetAttribute('TLTStudioRole','Battle')
local server=game.ServerScriptService.Server
server.Source..=[[
task.defer(function()
 local report={kind='BATTLE_WORLD_RUNTIME_NATIVE',checks=0,epics={}}
 local function check(value,message)report.checks+=1;assert(value,message)end
 local ok,err=xpcall(function()
  check(workspace:GetAttribute('TLTServerRole')=='Battle','actual Battle bootstrap')
  check(not workspace:FindFirstChild('DeepwoodCampaign'),'no campaign before admission')
  check(workspace:FindFirstChild('BattleArrival')~=nil,'arrival staging floor exists')
  for epic=1,#Content.epics do
   local mission
   for _,chapter in ipairs(Content.chapters)do if chapter.epic==epic then mission=chapter.id;break end end
   local started=os.clock();previewWorld(assert(mission))
   check(deepwood.loadedEpics[epic],'selected epic ready '..epic)
   check(deepwood.spawns[Content.epics[epic].hub]~=nil,'hub spawn exists '..epic)
   check(deepwood.folder:FindFirstChild(Content.epics[epic].hub..'AccountStorage')~=nil,'storage initialized '..epic)
   local count=#deepwood.folder:GetDescendants();previewWorld(mission)
   check(#deepwood.folder:GetDescendants()==count,'repeat admission reuses world '..epic)
   report.epics[epic]={mission=mission,elapsed=os.clock()-started,instances=count}
  end
  check(workspace:GetAttribute('TLTCombatReady')==true,'combat initialized')
  for _,name in ipairs({'K0Action','DeepwoodRequest','ExpeditionRequest','InventoryRequest'})do
   check(game.ReplicatedStorage.Remotes:FindFirstChild(name)~=nil,'runtime remote '..name)
  end
  local elder=assert(deepwood.terrain['DW-03']:FindFirstChild('TDElderTree'))
  for _,name in ipairs({'trunk_geom','roots_geom'})do
   local part=assert(elder:FindFirstChild(name,true))
   local template=assert(game.ServerStorage.TDMapModels.ForestLandmark:FindFirstChild(name,true))
   check(part.CanCollide and part.CanQuery,'elder remains solid '..name)
   check(part.CollisionFidelity==template.CollisionFidelity,'authored collision preserved '..name)
   local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
   params.FilterDescendantsInstances={part};params.RespectCanCollide=true
   check(workspace:Blockcast(CFrame.new(part.Position-Vector3.new(100,0,0)),Vector3.new(4,5,4),Vector3.new(200,0,0),params)~=nil,'elder stops hero '..name)
  end
 end,debug.traceback)
 report.pass=ok;report.error=err
 local encoded=game.HttpService:JSONEncode(report)
 print('BATTLE_WORLD_RUNTIME_NATIVE '..encoded)
 workspace:SetAttribute('TLTWorldRuntimeReport',encoded)
end)
]]
Run:Run()
local encoded
for _=1,480 do
 task.wait(.5);encoded=workspace:GetAttribute('TLTWorldRuntimeReport')
 if encoded then break end
end
local report=encoded and game.HttpService:JSONDecode(encoded)
Run:Stop()
assert(report,'server world initialization timed out')
assert(report.pass,report.error)
return report
