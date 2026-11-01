local Players=game:GetService('Players')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'isolated local place only')
local Camera=require(game.StarterPlayer.StarterPlayerScripts.Client.AdventureCamera)
local report={kind='ADVENTURE_CAMERA_ZOOM_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='CameraZoomQA';fixture.Parent=workspace
local ok,err=xpcall(function()
 check(Camera.maximum('Tutorial')==22,'battle zoom extends to 22 studs')
 for _,phase in ipairs({'Lobby','LoadingLobby','ReturningLobby','Respawning'})do check(Camera.maximum(phase)==22,phase..' uses the expanded lobby zoom limit')end
 check(Camera.min==6,'minimum zoom remains unchanged')
 local focus=Vector3.new(20000,1000,20000)
 local old=Camera.constrain(focus,focus+Vector3.new(0,10,40),{})
 check(math.abs((old.Position-focus).Magnitude-22)<.01,'unobstructed view reaches the new limit')
 local near=Camera.constrain(focus,focus+Vector3.new(0,4,10),{})
 check((near.Position-focus).Magnitude<18,'closer zoom remains available')
 local wall=Instance.new('Part');wall.Anchored=true;wall.Size=Vector3.new(40,40,1);wall.Position=focus+Vector3.new(0,5,8);wall.Parent=fixture
 local blocked=Camera.constrain(focus,focus+Vector3.new(0,10,25),{wall})
 check(blocked.Position.Z<wall.Position.Z-0.5,'collision keeps the camera before a wall')
 local low=Camera.constrain(focus,focus+Vector3.new(0,-10,22),{})
 check((low.Position-focus).Unit.Y>=math.sin(Camera.minPitch)-.001,'downward orbit remains above the minimum pitch')
end,debug.traceback)
fixture:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
