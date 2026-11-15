-- Actual server/client geometry must agree through every boss phase and mode.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Shared=game.ReplicatedStorage.Shared
local Client=game.StarterPlayer.StarterPlayerScripts:FindFirstChild('Client')
local P=deps and deps.EnemyPatterns or require(Shared.EnemyPatterns)
local Profiles=deps and deps.EnemyCombatProfiles or require(Shared.EnemyCombatProfiles)
local R=deps and deps.EnemyPatternRuntime or require(game.ServerScriptService.Server.Combat.EnemyPatternRuntime)
local FX=deps and deps.EnemyPatternEffects or require(Client.EnemyPatternEffects)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local origin,aim,direction=Vector3.new(0,4,0),Vector3.new(13,4,-11),Vector3.new(0,0,-1)
local kinds=0
for kind,profile in pairs(P.profiles)do
 if profile.boss then
  kinds+=1
  for _,health in ipairs({1,.55,.2})do for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
   for _,base in ipairs(profile.attacks)do
    local d=Profiles.resolve(kind,base,mode,health)
    local attack={pattern=d,origin=origin,aim=aim,direction=direction}
    for pulse=1,d.pulses do
     local g,center,dir=FX.geometryFrame(attack,pulse)
     local _,expected,expectedDirection=R.frame(attack,pulse)
     check((center-expected).Magnitude<.000001,'server/client phase center '..kind..' '..mode..' '..pulse)
     local authored=Profiles.pulseGeometry(d,pulse)
     check(g.shape==authored.shape and g.width==authored.width and g.radius==authored.radius,'final pulse shape is preserved')
     check((dir-expectedDirection).Magnitude<.000001,'announced lane rotation matches the committed pulse')
    end
   end
  end end
 end
end
check(kinds==23,'all authored bosses have three-phase geometry coverage')
local world=Instance.new('Folder');world.Name='DeepwoodCampaign';world.Parent=workspace
local floor=Instance.new('Part');floor.Name='ForestGround';floor.Anchored=true;floor.Size=Vector3.new(160,1,160);floor.Parent=world
local model=Instance.new('Model');model.Name='PulseBoundaryQA';model.Parent=world
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=origin;root.Anchored=true;root.CanCollide=false;root.Parent=model
local human=Instance.new('Humanoid');human.Parent=model
local camera=workspace.CurrentCamera;local oldCamera=camera and camera.CFrame
if camera then camera.CFrame=CFrame.lookAt(Vector3.new(0,35,38),Vector3.zero)end
local sequence=0
local function preview(kind,index,health)
 sequence+=1
 local d=Profiles.resolve(kind,P.get(kind).attacks[index],'Hell',health)
 model:SetAttribute('EnemyKind',kind);model:SetAttribute('K0AttackSeq',sequence);model:SetAttribute('K0PatternId',d.id)
 model:SetAttribute('K0PatternDefinition',game.HttpService:JSONEncode(d))
 local at=workspace:GetServerTimeNow()
 local a={d=d,origin=origin,aim=aim,direction=direction,castOrigin=origin+Vector3.yAxis,at=at}
 FX.receive({kind='begin',model=model,sequence=sequence,id=d.id,definition=d,origin=origin,aim=aim,direction=direction,castOrigin=a.castOrigin,at=at})
 FX.render(at+.1)
 local folder=workspace:FindFirstChild('EnemyPatternWarning')
 check(folder~=nil,'phase preview exists')
 return a,folder
end
local a,folder=preview('KingOgre',4,.2)
local ring,circle=false,false
for _,p in ipairs(folder:GetChildren())do if p:IsA('BasePart')then
 local shape=p:GetAttribute('WarningShape');ring=ring or shape=='ring';circle=circle or shape=='circle'
 if shape=='circle'then
  local g,center=FX.geometryFrame(a,p:GetAttribute('WarningPulse'))
  local delta=Vector3.new(p.Position.X-center.X,0,p.Position.Z-center.Z)
  check(math.abs(delta.Magnitude-g.radius)<.05,'heart-cycle circle is centered on the boss, not the locked target')
 end
end end
check(ring and circle,'ring/circle/ring follow-up shapes are visible during the first windup')
FX.receive({kind='cancel',model=model,sequence=sequence})
a,folder=preview('Warlord',4,.55)
local pulses={}
for _,p in ipairs(folder:GetChildren())do if p:IsA('BasePart')then
 local pulse=p:GetAttribute('WarningPulse');pulses[pulse]=true
 local g,center,dir=FX.geometryFrame(a,pulse);local right=Vector3.new(-dir.Z,0,dir.X)
 local delta=p.Position-center;local x,z=delta:Dot(right),delta:Dot(dir)
 local boundary=math.min(math.abs(math.abs(x)-g.width),math.abs(z),math.abs(z-g.range))
 check(boundary<.02,'each crossed lane boundary matches its actual rotated rectangle')
end end
check(pulses[1]and pulses[2],'both crossed cuts are warned before the first contact')
FX.receive({kind='cancel',model=model,sequence=sequence})
if camera then camera.CFrame=oldCamera end
model:SetAttribute('K0PatternId',nil);world:Destroy();FX.render(workspace:GetServerTimeNow())
print('ENEMY_PULSE_GEOMETRY_NATIVE '..game.HttpService:JSONEncode({checks=checks,bosses=kinds,phases=3,modes=4}))
