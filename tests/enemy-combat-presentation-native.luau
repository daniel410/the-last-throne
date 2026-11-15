-- Run in an isolated local Place with production client/shared modules or bundled deps.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts:FindFirstChild('Client')
local function dependency(name,shared)
 if deps and deps[name]then return deps[name]end
 return require(shared and game.ReplicatedStorage.Shared[name]or Client[name])
end
local Profiles=dependency('EnemyCombatProfiles',true)
local Patterns=dependency('EnemyPatterns',true)
local Snapshot=dependency('EnemyPatternDefinition')
local Pose=dependency('EnemyPatternPose')
local Effects=dependency('EnemyPatternEffects')
local Geometry=dependency('EnemyAttackGeometry',true)
local Runtime=deps and deps.EnemyPatternRuntime or require(game.ServerScriptService.Server.Combat.EnemyPatternRuntime)
local Http=game:GetService('HttpService')
local checks=0
local function check(value,message)checks+=1;assert(value,message)end
local fixture=Instance.new('Folder');fixture.Name='CombatPresentationQA';fixture.Parent=workspace
local model=Instance.new('Model');model.Name='Monster';model.Parent=fixture
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.new(0,4,0);root.Anchored=true;root.CanCollide=false;root.Parent=model
local humanoid=Instance.new('Humanoid');humanoid.Parent=model
local seq=0
for kind,profile in pairs(Patterns.profiles)do
 model:SetAttribute('EnemyKind',kind)
 for _,base in ipairs(profile.attacks)do
  for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
   seq+=1
   local d=Profiles.resolve(kind,base,mode,.4)
   model:SetAttribute('K0AttackSeq',seq);model:SetAttribute('K0PatternId',d.id)
   model:SetAttribute('K0PatternDefinition',Http:JSONEncode(d))
   local snapshot=Snapshot.get(model)
   check(math.abs(snapshot.speed-d.speed)<.000001 and snapshot.pulses==d.pulses and math.abs(snapshot.windup-d.windup)<.000001,'streaming restores actual difficulty geometry '..d.id)
   local event=Snapshot.message({model=model,sequence=seq,id=d.id,definition=d})
   check(event==d,'begin event retains resolved definition '..d.id)
   local attack={start=0,w=d.windup,a=d.active,r=d.recovery}
   for pulse=1,d.pulses do
    local at=d.windup+(pulse-1)*d.interval
    check(math.abs(Pose.phase(model,at,attack)-.62)<.00001,'every difficulty pulse matches contact '..d.id)
    local before={Pose.accent(model,at-.00001,attack):GetComponents()}
    local after={Pose.accent(model,at+.00001,attack):GetComponents()}
    for i,v in ipairs(before)do check(math.abs(v-after[i])<.001,'no repeated strike root snap '..d.id)end
   end
   local original=root.CFrame
   Pose.joint(model,'weapon',.62)
   check(root.CFrame==original,'presentation cannot move authoritative root')
  end
 end
end
-- Multi-shot warnings are full swept-width lanes, including each side shot.
local world=Instance.new('Folder');world.Name='DeepwoodCampaign';world.Parent=workspace
local floor=Instance.new('Part');floor.Name='ForestGround';floor.Anchored=true;floor.Size=Vector3.new(120,1,120);floor.Parent=world
local camera=workspace.CurrentCamera;local previous=camera and camera.CFrame
if camera then camera.CFrame=CFrame.lookAt(Vector3.new(0,32,35),Vector3.zero)end
local function warning(d,sequence,at)
 model:SetAttribute('K0AttackSeq',sequence);model:SetAttribute('K0PatternId',d.id)
 model:SetAttribute('K0PatternDefinition',Http:JSONEncode(d))
 Effects.receive({kind='begin',model=model,sequence=sequence,id=d.id,definition=d,origin=root.Position,direction=Vector3.new(0,0,-1),aim=Vector3.new(0,4,-12),at=at})
 Effects.render(at+.1)
 local folder=workspace:FindFirstChild('EnemyPatternWarning')
 check(folder~=nil,'resolved warning constructed')
 return folder
end
local d=Profiles.resolve('IceElf',Patterns.get('IceElf').attacks[2],'Hell',1)
local now=workspace:GetServerTimeNow();local laneWarning=warning(d,seq+1,now)
local lateral=0
for _,edge in ipairs(laneWarning:GetChildren())do if edge:IsA('BasePart')then lateral=math.max(lateral,math.abs(edge.Position.X))end end
check(lateral>4,'side-shot lanes have visible full width')
Effects.receive({kind='cancel',model=model,sequence=seq+1})
local ring=Profiles.resolve('KingIceGolem',Patterns.get('KingIceGolem').attacks[4],'Hell',1)
local ringWarning=warning(ring,seq+2,now)
Effects.render(now+ring.windup+.02)
check(not ringWarning.Parent,'next expanding ring replaces old boundary before next pulse')
Effects.receive({kind='cancel',model=model,sequence=seq+2})
-- A staff socket offset and a close diagonal target must produce the same
-- warned lanes and actual server trajectories. Moving the visual socket after
-- the tell cannot retarget the already committed release.
local socket=Instance.new('Attachment');socket.Name='EnemyCastSocket';socket.Position=Vector3.new(3,1,-1);socket.Parent=root
local enemy={model=model,root=root,humanoid=humanoid,config={attacks={{damage=120}},leashRange=65},spawnPosition=root.Position,attackSeq=seq+2}
local events={}
model:SetAttribute('EnemyKind','IceElf')
local attack=Runtime.begin(enemy,{root={Position=Vector3.new(5,4,-4)}},d,0,function(message)table.insert(events,message);Effects.receive(message)end)
local begin=events[1]
Effects.render(begin.at+.1)
local committedWarning=workspace:FindFirstChild('EnemyPatternWarning')
check(committedWarning~=nil and begin.castOrigin==attack.castOrigin,'server cast origin is in the begin snapshot')
check(model:GetAttribute('K0PatternCastOrigin')==begin.castOrigin,'streaming retains the same cast origin')
socket.Position+=Vector3.new(2,1,0)
local context={valid=function()return false end,raycast=function()return nil end,emit=function(message)table.insert(events,message)end}
Runtime.step(enemy,d.windup,{},context)
local launches={}
for _,message in ipairs(events)do if message.kind=='projectile'then
 launches[message.shot]=message
 check(message.origin==begin.castOrigin,'post-tell socket motion cannot move a launch')
end end
check(#launches==d.fan,'server releases every warned fan lane')
local laneEdges={}
for _,edge in ipairs(committedWarning:GetChildren())do if edge:IsA('BasePart')then
 local shot=edge:GetAttribute('WarningLane');local launch=launches[shot]
 check(launch~=nil,'each warning edge identifies its actual shot')
 laneEdges[shot]=(laneEdges[shot]or 0)+1
 local finish=launch.origin+launch.direction*d.range
 local distance=Geometry.segmentDistance(edge.Position.X,0,edge.Position.Z,launch.origin.X,0,launch.origin.Z,finish.X,0,finish.Z)
 check(distance>=1.37 and distance<=1.42,'warning includes the true swept projectile width and end caps')
end end
for shot=1,d.fan do check((laneEdges[shot]or 0)>=22,'each projectile lane has side edges and round end caps')end
Runtime.cancel(enemy,Effects.receive);enemy.attack=nil
-- Dash contact is clipped to the warned rectangle; there is no extra capsule
-- reach behind its start, beyond its end or outside its visible width.
local dash=Profiles.resolve('MagmaWorm',Patterns.get('MagmaWorm').attacks[2],'Hell',1)
local dashWarning=warning(dash,seq+4,now)
local maxX,minZ,maxZ=0,math.huge,-math.huge
for _,edge in ipairs(dashWarning:GetChildren())do if edge:IsA('BasePart')then
 for _,sign in ipairs({-1,1})do
  local endpoint=edge.CFrame:PointToWorldSpace(Vector3.new(0,0,sign*edge.Size.Z*.5))
  maxX=math.max(maxX,math.abs(endpoint.X-root.Position.X));minZ=math.min(minZ,endpoint.Z-root.Position.Z);maxZ=math.max(maxZ,endpoint.Z-root.Position.Z)
 end
end end
check(math.abs(maxX-dash.width)<.01,'dash warning uses the exact server width')
check(math.abs(minZ+dash.dashDistance)<.01 and math.abs(maxZ)<.01,'dash warning ends exactly at the server range')
Effects.receive({kind='cancel',model=model,sequence=seq+4})
if camera then camera.CFrame=previous end
model:SetAttribute('K0PatternId',nil);fixture:Destroy();world:Destroy()
print('ENEMY_COMBAT_PRESENTATION_NATIVE '..Http:JSONEncode({checks=checks,attacks=seq}))
