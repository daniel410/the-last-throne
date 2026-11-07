-- Execute the real ReplicatedFirst script against delayed/reordered services.
-- These are lifecycle simulations, not Roblox renderer/teleport acceptance.
local config=assert(loadfile('src/shared/ExpeditionConfig.luau'))()
local roleEnv=setmetatable({script={Parent={WaitForChild=function()return config end}},require=function(value)return value end},{__index=_G})
local Role=assert(loadfile('src/shared/PlaceRole.luau','t',roleEnv))()
local checks = 0
local function check(value, message) checks = checks + 1; assert(value, message) end
local vector = {}
vector.__sub = function(a,b) return setmetatable({Magnitude=math.abs(a.x-b.x)},vector) end
local function pos(x) return setmetatable({x=x},vector) end
local function run(role, incoming, failStream, demandStream, slowGates)
 local frame, destroyedAt, removed, created, requests = 0, nil, false, 0, 0
 local deferred = {}
 local parent = {}
 local gui = {Parent=nil}
 function gui:Destroy() destroyedAt=frame;self.Parent=nil end
 local human = {Health=100}
 local root = {Position=pos(100)}
 local character = {spawnReady=false}
 function character:IsDescendantOf() return true end
 function character:GetAttribute() return self.spawnReady end
 function character:FindFirstChild() return root end
 function character:FindFirstChildOfClass() return human end
 local attrs = {K0SessionPhase='Lobby',TLTTravelLock=true}
 local player = {Character=character,GameplayPaused=false}
 function player:GetAttribute(key) return attrs[key] end
 function player:WaitForChild() return parent end
 function player:RequestStreamAroundAsync()
  requests=requests+1
  if failStream and requests==1 then error('transient streaming failure') end
 end
 local camera = {CameraSubject=human,CameraType='Custom',Focus={Position=pos(100)}}
 local world = {CurrentCamera=camera,StreamingEnabled=true}
 function world:GetAttribute() return frame>=6 end
 function world:FindFirstChild(name) return name end
 function world:Raycast(_,_,params)
  check(params.RespectCanCollide and #params.FilterDescendantsInstances==3,'exclude character and staging geometry')
  return frame>=12 and (not demandStream or requests>0) and {} or nil
 end
 local runService = {IsStudio=function() return true end,RenderStepped={Wait=function()
  frame=frame+1;assert(frame<40,'loading must finish after readiness')
  -- Delayed initialization must never dismiss the cover.
  if frame<=5 then check(not destroyedAt,'temporary Lobby phase remains covered') end
  if frame==6 then attrs.K0SessionPhase=role=='Battle' and 'Tutorial' or 'Lobby' end
  if frame==7 then character.spawnReady=true end
  if frame==8 and not slowGates or frame==22 then attrs.TLTBattleClientReady=true end
  if frame==9 then attrs.TLTTravelLock=slowGates==true;camera.Focus.Position=pos(0) end
  if frame==23 then attrs.TLTTravelLock=false end
  if slowGates and frame<=23 then check(not destroyedAt,'streaming alone cannot bypass battle UI or party lock') end
  if frame==10 then camera.Focus.Position=pos(100);player.GameplayPaused=true end
  if frame==11 then player.GameplayPaused=false end
  if frame<=12 then check(not destroyedAt,'no reveal before destination streams') end
  if frame==13 then
   -- Invalidate readiness during the async streaming request.
   character.spawnReady=false
   for _,fn in ipairs(deferred) do fn() end;deferred={}
  end
  if frame==15 then character.spawnReady=true end
  if frame>=16 then for _,fn in ipairs(deferred) do fn() end;deferred={} end
 end}}
 local first = {}
 function first:RemoveDefaultLoadingScreen()
  check(gui.Parent==parent and gui.Enabled and gui.DisplayOrder==10000,'opaque cover installed before default removal')
  removed=true
 end
 local teleport = {GetArrivingTeleportGui=function() return incoming and gui or nil end}
 local services={Players={LocalPlayer=player},TeleportService=teleport,ReplicatedFirst=first,RunService=runService}
 local env=setmetatable({
  game={PlaceId=role=='Battle' and config.battlePlaceId or config.lobbyPlaceId,GetService=function(_,name) return services[name] end},workspace=world,
  script={Parent={WaitForChild=function(_,name) return name end}},
  require=function(name) if name=='PlaceRole' then return Role end;return {create=function() created=created+1;return gui end} end,
  Enum={CameraType={Custom='Custom'},RaycastFilterType={Exclude='Exclude'}},
  RaycastParams={new=function()return {}end},Vector3={new=function()return pos(0)end},
  task={spawn=function(fn)deferred[#deferred+1]=fn end},
 },{__index=_G})
 assert(loadfile('src/loading/ArrivalLoading.client.luau','t',env))()
 if role=='Lobby' and not incoming then
  check(not removed and created==0,'ordinary lobby retains its normal startup')
 else
  check(removed and destroyedAt>=17,'wait through readiness regression and rendered frames')
  check(created==(incoming and 0 or 1),'reuse arriving artwork or use approved fallback')
  check(requests==(failStream and 2 or 1),'stream request errors retry without exposing platform')
 end
end
run('Lobby',false,false)
run('Lobby',true,false)
run('Battle',true,false)
run('Battle',false,false)
run('Battle',true,true)
run('Battle',true,false,true)
run('Lobby',true,false,true)
run('Battle',true,false,true,true)
print('arrival-loading: '..checks..' checks PASS')
