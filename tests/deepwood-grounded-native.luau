-- Native geometry/camera/authority acceptance. Synthetic player identity and
-- story state; no live account, published teleport or physical device claim.
local Http=game:GetService('HttpService')
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local report={kind='DEEPWOOD_GROUNDED_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function near(a,b,t,m)check(math.abs(a-b)<=t,m..': '..tostring(a)..' vs '..tostring(b))end
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.DeepwoodContent)
local Access=require(Shared.DeepwoodAccess)
local Bounds=require(Shared.DeepwoodBounds)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local fixture=Instance.new('Folder');fixture.Name='GroundedQa';fixture.Parent=workspace
local world
local ok,err=xpcall(function()
 local started=os.clock();world=require(game.ServerScriptService.Server.World.DeepwoodWorld).create();report.worldCreateSeconds=os.clock()-started
 local base=world.folder.GroundedForest.PersistentGround
 check(base.ModelStreamingMode==Enum.ModelStreamingMode.Persistent,'simple safety foundation survives stream-out')
 report.persistentColliders=#base:GetChildren();check(report.persistentColliders<450,'persistent geometry remains bounded')
 local floors={base}
 for _,v in ipairs(world.terrain:GetChildren()) do
  if v:IsA('BasePart') and v.Name:find('ConnectedPath_',1,true)==1 then table.insert(floors,v)
  elseif v:IsA('Model') and v:FindFirstChild('ForestGround') then table.insert(floors,v.ForestGround) end
 end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances=floors;params.RespectCanCollide=true
 local function ground(x,z)
  local hit=workspace:Raycast(Vector3.new(x,200,z),Vector3.new(0,-400,0),params)
  check(hit~=nil,'continuous physical ground exists');return hit.Position.Y
 end
 for id,z in pairs(Content.zones) do
  near(ground(z.center[1],z.center[3]),z.center[2],.25,id..' clearing height retained')
  local sp=world.spawns[id].Position;near(ground(sp.X,sp.Z),z.center[2],.25,id..' checkpoint is supported')
  check(Bounds.supported(sp.X,z.center[2]+3,sp.Z),id..' living root accepted')
  check(not Bounds.supported(sp.X,z.center[2]-2,sp.Z),id..' under-floor root rejected')
 end
 for _,edge in ipairs(Access.edges) do
  local start,finish,t0,t1=Bounds.ends(edge);check(t0<t1,'regions have a valid connecting gap')
  near(start[2],Content.zones[edge[1]].center[2],.001,'ramp starts at clearing height')
  near(finish[2],Content.zones[edge[2]].center[2],.001,'ramp ends at clearing height')
  for n=0,20 do
   local t=n/20;local x=start[1]+(finish[1]-start[1])*t;local z=start[3]+(finish[3]-start[3])*t
   local expected=start[2]+(finish[2]-start[2])*t
   near(ground(x,z),expected,.35,'trail joins both clearing edges without a step')
   check(Bounds.supported(x,expected+3,z),'corridor root accepted')
  end
  local p=Vector3.new(table.unpack(start))+Vector3.new(0,3,0);local q=Vector3.new(table.unpack(finish))+Vector3.new(0,3,0)
  local walls={};for _,model in ipairs(world.folder.GroundedForest:GetChildren()) do if model~=base then table.insert(walls,model) end end
  local cast=RaycastParams.new();cast.FilterType=Enum.RaycastFilterType.Include;cast.FilterDescendantsInstances=walls;cast.RespectCanCollide=true
  local hit=workspace:Blockcast(CFrame.new(p),Vector3.new(2,4,2),q-p,cast)
  check(hit==nil,'forest walls leave the authorized ramp mouth open')
 end
 for _,v in ipairs(world.terrain:GetChildren()) do check(v.Name~='BridgeParapet','old bridge parapets are absent') end
 for _,model in ipairs(world.folder.GroundedForest:GetChildren()) do if model.Name:find('ForestTrail_',1,true)==1 then
  for _,v in ipairs(model:GetDescendants()) do check(not v:GetAttribute('TLTWorldBoundary'),'road sides remain free of enclosing walls') end
 end end
 for _,edge in ipairs(Access.edges) do
  local a,b=Bounds.ends(edge);local dx,dz=b[1]-a[1],b[3]-a[3];local length=math.sqrt(dx*dx+dz*dz)
  for _,offset in ipairs({-36,0,36}) do
   local x=(a[1]+b[1])/2-dz/length*offset;local z=(a[3]+b[3])/2+dx/length*offset
   local y=ground(x,z);check(Bounds.supported(x,y+3,z),'wide grass verge is walkable and supported')
  end
 end
 for index,edge in ipairs(Access.edges) do
  local a,b=Bounds.ends(edge);local mid=Vector3.new((a[1]+b[1])/2,200,(a[3]+b[3])/2)
  local d=Vector3.new(b[1]-a[1],0,b[3]-a[3]).Unit;local side=Vector3.new(-d.Z,0,d.X)
  local p=RaycastParams.new();p.FilterType=Enum.RaycastFilterType.Include;p.FilterDescendantsInstances={world.folder.GroundedForest['EarthShoulders_'..index]}
  local inner=workspace:Raycast(mid+side*49,Vector3.new(0,-400,0),p)
  local outer=workspace:Raycast(mid+side*111,Vector3.new(0,-400,0),p)
  check(inner and outer and inner.Position.Y>outer.Position.Y+5,'earth shoulder slopes down outward without a vertical road wall')
 end
 -- A regular walking capsule cannot leave any non-entrance clearing edge.
 local boundaries=0
 for _,v in ipairs(world.folder.GroundedForest:GetDescendants()) do if v:IsA('BasePart') and v:GetAttribute('TLTWorldBoundary') then
  boundaries+=1;check(v.CanCollide and v.CanQuery,'boundary has authoritative solid collision')
  check(v.Position.Y+v.Size.Y/2>=16,'boundary rises above normal jump height')
 end end
 report.boundaries=boundaries;check(boundaries>300,'all clearing/trail sides receive boundaries')
 local wallParams=RaycastParams.new();wallParams.FilterType=Enum.RaycastFilterType.Include;wallParams.FilterDescendantsInstances={world.folder.GroundedForest};wallParams.RespectCanCollide=true
 for id,z in pairs(Content.zones) do
  for _,side in ipairs({{1,0,z.size[1]/2,z.size[2]},{-1,0,z.size[1]/2,z.size[2]},{0,1,z.size[2]/2,z.size[1]},{0,-1,z.size[2]/2,z.size[1]}}) do
   for n=1,10 do
    local nx,nz,extent,length=table.unpack(side);local tx,tz=-nz,nx
    local x=z.center[1]+nx*(extent-4)+tx*((n-.5)/10-.5)*length
    local zz=z.center[3]+nz*(extent-4)+tz*((n-.5)/10-.5)*length
    if not Bounds.connection(x,zz,40) and not Bounds.region(x+nx*12,zz+nz*12,0,id) then
     local hit=workspace:Blockcast(CFrame.new(x-nx*12,z.center[2]+3,zz-nz*12),Vector3.new(2,4,2),Vector3.new(nx*30,0,nz*30),wallParams)
     check(hit~=nil,'normal movement cannot cross clearing edge '..id)
    end
   end
  end
 end
 -- Server recovery must not reuse a different hero/life or change HP/MP.
 local character=Instance.new('Model');character.Parent=fixture
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character
 local human=Instance.new('Humanoid');human.RequiresNeck=false;human.Parent=character
 character.PrimaryPart=root;character:SetAttribute('K0Mana',37)
 local player={Character=character,GetAttribute=function()return 'Tutorial'end}
 local hero={heroId='grounded-hero',training=false};local state={main=7};local moves=0
 local gate=require(game.ServerScriptService.Server.Story.DeepwoodRegionAccess).create({world=world,heroSession={getActiveHero=function()return hero end},inventory={storyState=function()return state end},combat={relocateForStoryGate=function(_,cf)moves+=1;character:PivotTo(cf);return true end},notice=function()end})
 root.CFrame=world.spawns['DW-01'].CFrame+Vector3.new(0,4,0);gate.update(player);local safe=root.Position
 state.main=0;root.Position=Vector3.new(table.unpack(Content.zones['DW-02'].center))+Vector3.new(0,3,0);gate.update(player)
 near((root.Position-safe).Magnitude,0,.001,'valid ground in a locked story still returns to authorized footing');state.main=7
 root.Position=safe+Vector3.new(-5000,0,0);gate.update(player);near((root.Position-safe).Magnitude,0,.001,'outside world returns to last safe footing')
 root.Position=safe-Vector3.new(0,30,0);gate.update(player);near((root.Position-safe).Magnitude,0,.001,'fall is recovered before void death')
 check(human.Health==100 and character:GetAttribute('K0Mana')==37,'boundary rescue never heals or refills mana')
 hero.heroId='another-hero';root.Position=safe+Vector3.new(-5000,0,0);gate.update(player)
 near((root.Position-(world.spawns['DW-07'].Position+Vector3.new(0,4,0))).Magnitude,0,.001,'hero switch uses its checkpoint instead of stale safe pivot')
 hero.training=true;local before=moves;root.Position=Vector3.zero;gate.update(player);check(moves==before,'training is outside adventure boundary authority')
 gate.remove(player)
 world.folder.GroundedForest:SetAttribute('GroundedForestVersion',1)
 local stale=Instance.new('Part');stale.Name='BridgeParapet';stale.Parent=world.terrain
 require(game.ServerScriptService.Server.World.DeepwoodGroundedWorld).create(world.folder)
 check(not world.terrain:FindFirstChild('BridgeParapet'),'reused Studio scene drops rejected parapets')
 check(world.folder.GroundedForest.PersistentGround.TrailSupport_7.Size.X==96,'reused Studio scene upgrades the grass verge')
 local camera=require(client.AdventureCamera);local focus=Vector3.new(20000,1000,20000)
 for _,distance in ipairs({6,18,60}) do for _,y in ipairs({-100,-10,0,10,100}) do for n=1,8 do
  local a=n*math.pi/4;local cf=camera.constrain(focus,focus+Vector3.new(math.cos(a)*distance,y,math.sin(a)*distance),{})
  local d=cf.Position-focus;local pitch=math.asin(d.Unit.Y)
  check(d.Magnitude<=18.001,'camera never zooms beyond its contract')
  check(pitch>=camera.minPitch-.001 and pitch<=camera.maxPitch+.001,'orbit stays above ground and below overhead limit')
 end end end
 local wall=Instance.new('Part');wall.Anchored=true;wall.Size=Vector3.new(20,20,1);wall.Position=focus+Vector3.new(0,4,6);wall.Parent=fixture
 local cf=camera.constrain(focus,focus+Vector3.new(0,-10,18),{wall})
 check(cf.Position.Z<wall.Position.Z-1,'camera volume stops before the wall')
 local live=workspace.CurrentCamera;local oldCf,oldFocus,oldType=live.CFrame,live.Focus,live.CameraType
 root.CFrame=world.spawns['DW-01'].CFrame+Vector3.new(0,4,0)
 live.Focus=CFrame.new(root.Position+Vector3.new(0,1.5,0));live.CFrame=CFrame.lookAt(root.Position-Vector3.new(0,20,10),root.Position)
 live.CameraType=Enum.CameraType.Scriptable;local scripted=live.CFrame;camera.update(character,true)
 check(live.CFrame==scripted,'scripted death/cutscene camera retains authority')
 live.CameraType=Enum.CameraType.Custom;camera.update(character,true)
 check(live.CFrame.Position.Y>Content.zones['DW-01'].center[2]+1,'actual camera update cannot remain under the floor')
 human.Health=0;local dead=live.CFrame;camera.update(character,true);check(live.CFrame==dead,'dead hero camera is not constrained by living orbit')
 live.CFrame=oldCf;live.Focus=oldFocus;live.CameraType=oldType
 local mood=require(client.DeepwoodAtmosphere);local lighting=game.Lighting;local oldFog,oldClock=lighting.FogEnd,lighting.ClockTime
 local atmosphere=Instance.new('Atmosphere');atmosphere.Name='QaOriginalAtmosphere';atmosphere.Parent=lighting
 mood.update(true);check(lighting.FogStart==180 and lighting.FogEnd==340,'only the far background fades to a bright sky color')
 check(lighting.Ambient.R>.5 and lighting.ExposureCompensation>=0,'daylight stays bright without a dark color grade')
 check(not lighting:FindFirstChild('DeepwoodForestGrade'),'rejected green color grading is absent')
 check(atmosphere.Parent==nil,'Atmosphere cannot suppress distance fog')
 mood.update(false);check(atmosphere.Parent==lighting and lighting.FogEnd==oldFog and lighting.ClockTime==oldClock,'lobby/training lighting restored exactly')
 atmosphere:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
require(client.DeepwoodAtmosphere).update(false);fixture:Destroy()
report.pass=#report.failures==0
print('DEEPWOOD_GROUNDED_NATIVE '..Http:JSONEncode(report));assert(report.pass,'Grounded world QA failed')
