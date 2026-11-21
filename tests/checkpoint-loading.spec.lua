-- Execute the real controller against delayed replication and stream responses.
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local mt={};local function V(x)return setmetatable({x=x,Magnitude=math.abs(x)},mt)end
mt.__sub=function(a,b)return V(a.x-b.x)end
local attrs={K0SessionPhase='Tutorial'};local appearance=true;local ground=true
local root={Position=V(0)};local human={Health=100}
local character={GetAttribute=function(_,name)return name=='TLTLocalAppearanceReady'and appearance or name=='K0SpawnReady'end,
 FindFirstChild=function()return root end,FindFirstChildOfClass=function()return human end}
local player={Character=character,GameplayPaused=false}
function player:GetAttribute(k)return attrs[k]end
function player:SetAttribute(k,v)attrs[k]=v end
function player:WaitForChild()return {}end
local streamCalls,failStream,streamWaits=0,false,0
function player:RequestStreamAroundAsync()
 streamCalls=streamCalls+1
 local waits=streamWaits;for _=1,waits do coroutine.yield()end
 if failStream then failStream=false;error('network failure')end
end
local created,destroyed,bound=0,0,false
local cover={create=function()created=created+1;return {Destroy=function()destroyed=destroyed+1 end}end}
local queue={}
local taskMock={spawn=function(fn)queue[#queue+1]=coroutine.create(fn)end,wait=coroutine.yield}
local function pump()
 local old=queue;queue={}
 for _,co in ipairs(old)do local ok,e=coroutine.resume(co);assert(ok,e);if coroutine.status(co)~='dead'then queue[#queue+1]=co end end
end
local frame,event
local run={RenderStepped={Connect=function(_,fn)frame=fn end}}
local available,connected=true,0
local remote={OnClientEvent={Connect=function(_,fn)connected=connected+1;event=fn end}}
local rs={WaitForChild=function(_,name,timeout)
 check(name=='Remotes' and timeout==10,'remote folder wait has a timeout')
 return {WaitForChild=function(_,child,childTimeout)
  check(child=='CheckpointTravelState' and childTimeout==10,'checkpoint event wait has a timeout')
  return available and remote or nil
 end}
end}
local camera={CameraSubject=human,CameraType='Custom',Focus={Position=V(0)}}
local world={StreamingEnabled=true,CurrentCamera=camera,Raycast=function()return ground and {}or nil end}
local actions={BindActionAtPriority=function()bound=true end,UnbindAction=function()bound=false end}
local env=setmetatable({game={ReplicatedStorage=rs,GetService=function(_,name)return name=='RunService'and run or actions end},
 script={Parent={TravelLoadingScreen=true}},require=function()return cover end,workspace=world,task=taskMock,
 Enum={ContextActionResult={Sink='Sink'},ContextActionPriority={High={Value=3000}},PlayerActions={GetEnumItems=function()return {}end},
 CameraType={Custom='Custom'},RaycastFilterType={Exclude='Exclude'}},Vector3={new=function()return V(0)end},RaycastParams={new=function()return {}end},
 typeof=function(v)return getmetatable(v)==mt and 'Vector3'or type(v)end},{__index=_G})
local UI=assert(loadfile('src/client/CheckpointLoading.luau','t',env))();UI.start(player);pump()
local function frames(n)for _=1,n do frame()end end
check(created==0,'warm travel has no unsolicited cover')
event('Begin',1);frames(4);check(attrs.TLTCheckpointLoading and bound and destroyed==0,'cover and movement block while server builds')
event('Arrived',1,V(100));pump();frames(4);check(destroyed==0,'wait for destination position replication')
root.Position=V(100);camera.Focus.Position=V(100);appearance=false;frames(4);check(destroyed==0,'wait for appearance')
appearance=true;ground=false;frames(4);check(destroyed==0,'wait for real ground')
ground=true;player.GameplayPaused=true;frames(4);check(destroyed==0,'wait for streaming pause')
player.GameplayPaused=false;frames(2);check(destroyed==0,'wait for stable rendered frames');frames(1)
check(destroyed==1 and not bound and not attrs.TLTCheckpointLoading,'ready closes cover and releases input')
event('Begin',2);event('Cancelled',1);event('Arrived',1,V(100));frames(3);check(destroyed==1,'stale outcomes cannot close next request')
event('Cancelled',2);check(destroyed==2 and not bound,'server failure closes cover')
event('Begin',3);human.Health=0;frame();check(destroyed==3,'death closes cover');human.Health=100
event('Begin',4);player.Character={};frame();check(destroyed==4,'character replacement closes cover');player.Character=character
event('Begin',5);attrs.K0SessionPhase='Lobby';frame();check(destroyed==5,'leaving adventure closes cover');attrs.K0SessionPhase='Tutorial'
event('Begin',6);failStream=true;event('Arrived',6,V(100));pump();frames(4);check(destroyed==5,'failed stream remains covered')
pump();frames(3);check(destroyed==6 and streamCalls==3,'stream retries then reveals')
event('Begin',7);event('Arrived',7,V(100));event('Cancelled',7);event('Begin',8);pump();frames(4)
check(destroyed==7 and attrs.TLTCheckpointLoading,'late stream result cannot reveal newer request')
event('Cancelled',8);event('Begin',8);check(created==8 and destroyed==8 and not bound,'duplicate begin is ignored')
-- A subsequent warm checkpoint can complete while the first cover is still up.
event('Begin',9);event('Arrived',9,V(200));pump();frames(4)
event('Arrived',10,V(300));root.Position=V(300);camera.Focus.Position=V(300);pump();frames(3)
check(destroyed==9 and not bound,'new warm destination releases an older cold cover')
event('Arrived',11,V(400));check(created==9,'warm travel without a pending cover creates none')
event('Begin',12);streamWaits=1;event('Arrived',12,V(500));pump()
streamWaits=3;event('Arrived',13,V(600));root.Position=V(600);camera.Focus.Position=V(600);pump();frames(4)
check(destroyed==9 and bound,'old in-flight stream cannot mark a newer destination ready')
event('Cancelled',12);event('Arrived',12,V(500));frames(4)
check(destroyed==9 and bound,'superseded request cannot cancel or redirect the new arrival')
pump();pump();frames(3);check(destroyed==9,'new destination still waits for its own stream')
pump();frames(3);check(destroyed==10 and not bound,'new destination closes only after its own stream')
available=false;UI.start(player);pump()
check(connected==1 and #queue==0,'a missing event ends setup without blocking or binding')
print('checkpoint-loading: '..checks..' checks PASS')
