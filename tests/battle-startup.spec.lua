-- Lifecycle/routing contract; native map construction is covered separately.
local Content=dofile('src/shared/CampaignContent.luau')
local Access=dofile('src/shared/CampaignAccess.luau')
local checks=0
local function check(ok,message)checks=checks+1;assert(ok,message)end
local calls={}
local function object(class)
 local o={ClassName=class,children={}}
 function o:SetAttribute(k,v)self[k]=v end
 function o:FindFirstChild(k)return self.children[k]end
 return setmetatable(o,{__newindex=function(t,k,v)rawset(t,k,v);if k=='Parent' and v then v.children[t.Name]=t end end})
end
local modules=setmetatable({},{__index=function(_,k)return k end})
local workspace=object('Workspace')
local function forest(world)
 if not world then
  world={folder=object('Model'),terrain=object('Folder'),spawns={},nodes={},positions={}}
 end
 world.positions['DW-01']=true;return world
end
local function build(name)
 return {create=function(world,epic)
  calls[#calls+1]={name=name,epic=epic}
  if name=='DeepwoodWorld'then return forest(world)end
  return world
 end}
end
local env=setmetatable({game={GetService=function()return {Shared={CampaignContent='Content',CampaignAccess='Access'}}end},script={Parent=modules},workspace=workspace,Instance={new=object},require=function(name)
 if name=='Content'then return Content elseif name=='Access'then return Access end
 return build(name)
end},{__index=_G})
local World=assert(loadfile('src/server/World/CampaignWorld.luau','t',env))()
local zones=0
for epic=1,5 do
 local scope=World.scope(epic);local n=0
 for id,z in pairs(scope.content.zones)do
  n=n+1;check((z.epic or 1)==epic,'scope excludes other epics: '..id)
 end
 for _,edge in ipairs(scope.access.edges)do check(scope.content.zones[edge[1]]and scope.content.zones[edge[2]],'both ends belong to selected epic')end
 for _,chapter in ipairs(scope.content.chapters)do check((chapter.epic or 1)==epic,'chapter scoped');check(scope.content.byId[chapter.id]==chapter,'canonical IDs retained')end
 check(n>=7,'epic includes main zones');zones=zones+n
end
local total=0;for _ in pairs(Content.zones)do total=total+1 end
check(zones==total,'all authored zones partitioned once')
for _,bad in ipairs({0,6,-1,1.5,'1'})do check(not pcall(World.scope,bad),'reject unknown epic')end
for epic=1,5 do
 calls={};local world=World.create(epic);check(world.loadedEpics[epic],'selected epic ready')
 local expected=({'DeepwoodWorld','LateEpicWorld','FrozenValeWorld','EmberCalderaWorld','LateEpicWorld'})[epic]
 check(calls[1].name==expected,'only selected region builder runs first')
 check(#calls==3,'one region + activity + art, no unrelated regions')
 if epic==2 or epic==5 then check(calls[1].epic==epic,'late epic split')end
 local before=#calls;check(World.create(epic,world)==world and #calls==before,'repeat entry reuses completed epic')
 if epic~=1 then
  check(World.create(1,world)==world,'adding Deepwood retains tables for active story services')
  check(world.loadedEpics[epic]and world.loadedEpics[1],'existing epic readiness retained')
 end
end
local Deferred=dofile('src/server/Combat/DeferredCombat.luau')
local loads,starts=0,0
local api=Deferred.new(function()loads=loads+1;return {start=function()starts=starts+1 end,refreshEquipment=function(_,value)return value end}end)
check(api.isSafeForEquipment({})==false,'no combat access before start')
local allowed,why=api.canUseInventoryItem({},{})
check(not allowed and why=='WaitForLobby','items fail closed before start')
api.refreshEquipment({},'before');check(loads==0,'inventory/roster reads do not require combat')
api.start();api.start();check(loads==1 and starts==1,'combat starts once across repeated entries')
check(api.refreshEquipment({},'after')=='after','forward real implementation after start')
print('battle-startup: '..checks..' checks PASS')
