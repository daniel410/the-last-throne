assert(game.Name=="TheLastThrone-Battle-0.67.0.rbxlx")
do
-- Local real-engine scenery contract, including smooth Terrain (not a mock renderer).
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local fixture only')
local Server=game.ServerScriptService.Server
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Bounds=require(Shared.CampaignBounds)
local world=require(Server.World.DeepwoodWorld).create()
require(Server.World.FrozenValeWorld).create(world)
require(Server.World.EmberCalderaWorld).create(world)
require(Server.World.LateEpicWorld).create(world)
require(Server.World.DeepwoodActivityWorld).create(world)
local report={kind='EPIC_WORLD_ART_NATIVE',checks=0,pass=false,sites={},failures={}}
local function check(v,msg)report.checks+=1;assert(v,msg)end
local before={};local rays={};local anchors={};local lanes={}
for _,p in ipairs(world.folder:GetDescendants())do if p:IsA('BasePart')and p.CanCollide then before[p]={p.CFrame,p.Size,p.CanQuery}end end
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain,workspace.Terrain};params.RespectCanCollide=true
local function planarDistance(p,a,b)
 local dx,dz=b.X-a.X,b.Z-a.Z;local t=math.clamp(((p.X-a.X)*dx+(p.Z-a.Z)*dz)/math.max(.001,dx*dx+dz*dz),0,1)
 return math.sqrt((p.X-a.X-t*dx)^2+(p.Z-a.Z-t*dz)^2)
end
for id in pairs(Content.zones)do table.insert(anchors,{p=world.spawns[id].Position,r=36})end
for _,chapter in ipairs(Content.chapters)do
 local previous=world.spawns[chapter.zone].Position
 for _,g in ipairs(chapter.goals)do
  local p=Vector3.new(table.unpack(g.position));table.insert(anchors,{p=p,r=#g.enemies>0 and 78 or 22});table.insert(lanes,{previous,p,21});previous=p
  for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then table.insert(anchors,{p=Vector3.new(table.unpack(step.position)),r=23})end end
 end
end
for _,edge in ipairs(Access.edges)do local aa,bb=Bounds.ends(edge);table.insert(lanes,{Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb)),44})end
local actors=world.folder:FindFirstChild('NPCActors')
if actors then for _,m in ipairs(actors:GetChildren())do if m:IsA('Model')and m.PrimaryPart then table.insert(anchors,{p=m.PrimaryPart.Position,r=23})end end end
local function protected(p)
 for _,a in ipairs(anchors)do if math.abs(p.Y-a.p.Y)<25 and planarDistance(p,a.p,a.p)<a.r then return true end end
 for _,l in ipairs(lanes)do if math.abs(p.Y-(l[1].Y+l[2].Y)/2)<30 and planarDistance(p,l[1],l[2])<l[3]then return true end end
 return false
end
local function saveRay(p)
 local strict=protected(p)
 local hit=workspace:Raycast(p+Vector3.new(0,strict and 3 or 100,0),Vector3.new(0,strict and -8 or -110,0),params)
 if hit and math.abs(hit.Position.Y-p.Y)<1 then table.insert(rays,{p=p,y=hit.Position.Y,strict=protected(p)})end
end
for id,z in pairs(Content.zones)do
 local c=Vector3.new(table.unpack(z.center))
 for x=-4,4 do for zz=-4,4 do saveRay(c+Vector3.new(x*z.size[1]/10,0,zz*z.size[2]/10))end end
 saveRay(world.spawns[id].Position-Vector3.new(0,.1,0))
end
for _,chapter in ipairs(Content.chapters)do for _,g in ipairs(chapter.goals)do
 saveRay(Vector3.new(table.unpack(g.position)))
 for _,s in ipairs(g.activity and g.activity.steps or {})do if s.position then saveRay(Vector3.new(table.unpack(s.position)))end end
end end
for _,edge in ipairs(Access.edges)do
 local aa,bb=Bounds.ends(edge);local a,b=Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb))
 for i=0,24 do saveRay(a:Lerp(b,i/24))end
end
local legacySurfaces={}
local legacy=world.terrain:FindFirstChild('DeepwoodPlaces')
if legacy then for _,part in ipairs(legacy:GetDescendants())do
 if part:IsA('BasePart')and part.CanCollide and (part.Name=='WalkableTerrace'or part.Name=='WalkableRamp'or part.Name=='TerraceLanding')then
  local single=RaycastParams.new();single.FilterType=Enum.RaycastFilterType.Include;single.FilterDescendantsInstances={part};single.RespectCanCollide=true
  for x=-2,2 do for z=-2,2 do
   local q=part.CFrame:PointToWorldSpace(Vector3.new(x*part.Size.X/5,0,z*part.Size.Z/5))
   local hit=workspace:Raycast(q+Vector3.new(0,100,0),Vector3.new(0,-200,0),single)
   if hit then table.insert(legacySurfaces,{p=hit.Position,name=part.Name})end
  end end
 end
end end
local start=os.clock()
local ok,err=xpcall(function()
 require(Server.World.EpicWorldArt).create(world)
 report.generationSeconds=os.clock()-start
 local art=world.folder.EpicWorldArt;local total=0
 for p,v in pairs(before)do check(p.Parent and p.CFrame==v[1]and p.Size==v[2]and p.CanQuery==v[3]and p.CanCollide,'existing collision retained '..p.Name)end
 report.protectedGroundSamples=0;report.sculptedSamples=0;report.maxRaisedGround=0
 for _,ray in ipairs(rays)do
  local hit=workspace:Raycast(ray.p+Vector3.new(0,ray.strict and 3 or 100,0),Vector3.new(0,ray.strict and -8 or -110,0),params)
  check(hit~=nil,'supported floor retained '..tostring(ray.p))
  local rise=hit.Position.Y-ray.y
  if ray.strict then report.protectedGroundSamples+=1;check(math.abs(rise)<.15,'protected encounter/spawn/NPC/corridor stays clear '..tostring(ray.p))
  else check(rise>=-.15 and rise<=48,'bounded optional terrain shoulders');if rise>.5 then report.sculptedSamples+=1;report.maxRaisedGround=math.max(report.maxRaisedGround,rise)end end
 end
 check(report.protectedGroundSamples>1000,'broad protection coverage')
 check(report.sculptedSamples>15,'actual raised terrain, not decorative-only terrain claims')
 local onlyTerrain=RaycastParams.new();onlyTerrain.FilterType=Enum.RaycastFilterType.Include;onlyTerrain.FilterDescendantsInstances={workspace.Terrain}
 for _,surface in ipairs(legacySurfaces)do
  local hit=workspace:Raycast(surface.p+Vector3.new(0,80,0),Vector3.new(0,-160,0),onlyTerrain)
  check(not hit or hit.Position.Y<=surface.p.Y+.15,'old optional walk surface cannot be buried '..surface.name)
 end
 report.legacyWalkSurfaceSamples=#legacySurfaces
 report.groundSamples=#rays
 for id in pairs(Content.zones)do
  local site=art:FindFirstChild(id);check(site~=nil,'every main/optional site dressed '..id)
  check(site:GetAttribute('Landmark')~=nil and site:GetAttribute('Theme')~=nil,'authored site identity '..id)
  local parts=0
  for _,p in ipairs(site:GetDescendants())do
   if p:IsA('BasePart')then
    parts+=1;check(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch,'scenery cannot change physics or hit queries')
    check(p:GetAttribute('TLTDecorative')==true,'scenery budget opt-in')
    local limit=p:GetAttribute('TLTSceneryDistance');check(not limit or limit<=900,'bounded backdrop distance')
   elseif p:IsA('LuaSourceContainer')then check(false,'no executable asset content')end
  end
  check(parts>150 and parts<4000,'bounded authored site density '..id)
  report.sites[id]={theme=site:GetAttribute('Theme'),landmark=site:GetAttribute('Landmark'),parts=parts};total+=parts
 end
 local meshes=0
 for _,p in ipairs(art:GetDescendants())do
  if p:IsA('BasePart')then check(not p.CanCollide and not p.CanQuery,'all route scenery non-physical')end
  if p:IsA('MeshPart')then meshes+=1;check(p.MeshId~='','original reusable TD mesh')end
 end
 report.siteParts=total;report.reusedMeshInstances=meshes
 check(art:GetAttribute('BuildComplete')==true and art:GetAttribute('ArtVersion')==2,'only fully generated v2 worlds are cached')
 local count=#art:GetDescendants();require(Server.World.EpicWorldArt).create(world)
 check(#art:GetDescendants()==count,'idempotent rebuild')
 report.totalDescendants=count;report.pass=true
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
print('EPIC_WORLD_ART_NATIVE '..game.HttpService:JSONEncode(report))
assert(ok,err)


end
do
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='LATE_EPICS_PRESENTATION_NATIVE',checks=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local V=require(client.LateEpicPresentation)
local world=assert(workspace:FindFirstChild('DeepwoodCampaign'));local props=world.LateEpicProps
V.update({flags={['HG-07:portal']=true,['HG-07:crownheart']=true,['GW-07:exit']=true}})
check(props.InvasionPortal.LocalTransparencyModifier==1,'saved portal closure is personal')
check(props.Crownheart.LocalTransparencyModifier==1,'recovered heart leaves the throne')
for _,name in ipairs({'InvasionPortalVisual','CrownheartVisual'})do local m=assert(props:FindFirstChild(name));local n=0;for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then n+=1;check(p.LocalTransparencyModifier==1,'saved completion hides derived visual '..name)end end;check(n>5,'actual multi-part finale visual')end
local streamed=Instance.new('Part');streamed.Name='LateStreamedPortal';streamed:SetAttribute('LateStoryHideKey','HG-07:portal');streamed.Parent=props;task.wait()
check(streamed.LocalTransparencyModifier==1,'late streamed object reapplies confirmed completion')
V.update({flags={}})
check(props.InvasionPortal.LocalTransparencyModifier==0 and streamed.LocalTransparencyModifier==0,'switching to unfinished hero restores portal')
for _,name in ipairs({'InvasionPortalVisual','CrownheartVisual'})do for _,p in ipairs(props[name]:GetDescendants())do if p:IsA('BasePart')then check(p.LocalTransparencyModifier==0,'unfinished hero restores derived visual '..name)end end end
streamed:Destroy()
local lobby=require(game.ServerScriptService.Server.World.LobbyWorld).create()
local Home=require(client.DawnspireHomecoming)
Home.update({heroId='done',heroes={done={deepwood={clears={['HG-07']=true}}}}})
check(lobby.folder:FindFirstChild('DawnspireHomecoming')~=nil,'complete hero sees restored Dawnspire throne')
check(lobby.folder.DawnspireHomecoming.Crownheart.HomecomingGreeting.TextLabel.Text:find('WELCOME HOME',1,true),'English homecoming greeting')
Home.update({heroId='new',heroes={new={deepwood={clears={}}}}})
check(lobby.folder:FindFirstChild('DawnspireHomecoming')==nil,'unfinished hero cannot inherit another hero ending')
report.pass=true;print('LATE_EPICS_PRESENTATION_NATIVE '..game.HttpService:JSONEncode(report));lobby.folder:Destroy() -- isolate the explicit homecoming fixture from subsequent Battle bootstrap assertion

end
do
-- Real TD meshes and Motor6Ds, only in an isolated local place with no real players.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.HauntedGraveyardClips)
local Rigs=require(game.ReplicatedStorage.Shared.HauntedGraveyardRigs)
local Field=require(Server.World.TrainingField);local Combat=require(game.ReplicatedStorage.Shared.LateEpicCombat)
local folder=Instance.new('Folder');folder.Name='HauntedMotionAcceptance';folder.Parent=workspace
local report={kind='HAUNTED_MONSTER_MOTION_NATIVE',checks=0,species={},failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function bodyCF(s)return s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()end
local function bottom(cf,points)local y=math.huge;for _,p in ipairs(points)do y=math.min(y,cf:PointToWorldSpace(p).Y)end;return y end
local function sole(s,ch)return bottom(bodyCF(s)*s.joints[ch].C0*s.joints[ch].Transform*s.joints[ch].C1:Inverse(),s.legs[ch].points)end
local ok,err=xpcall(function()
 check(next(Clips.models)==nil,'HG sampled tables stay unloaded until their first regional model')
 for _,kind in ipairs(Clips.kinds)do
  local profile=Clips.get(kind)
  local m=Field.makeEnemy(folder,kind,10000,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m),kind..' motion binding');local root=m.HumanoidRootPart;local original=root.CFrame;local hp=m.Humanoid.Health
  local row={source=Rigs[kind].template,maxStoppedFootLift=0};report.species[kind]=row
  check(m:GetAttribute('TdMonsterTemplate')==Rigs[kind].template,'original TD template retained')
  check(s.profile==profile,'dedicated HG profile replaces unrelated species alias')
  check(s.profile.hasLegs==(m.TdMonsterVisual:FindFirstChild('LegL')~=nil or m.TdMonsterVisual:FindFirstChild('LegBL')~=nil),'profile matches actual independent legs')
  check(s.profile.quadruped==(kind=='Hellhound'),'only Hellhound uses diagonal quadruped gait')
  for clip,channels in pairs(profile.clips)do for ch,samples in pairs(channels)do
   check(#samples==201,'201 evaluated F-curve samples')
   for _,v in ipairs(samples)do for _,x in ipairs(v)do check(x==x and math.abs(x)<10000,'finite bounded pose')end end
   if clip=='Idle'or clip=='Walk'or clip=='Stunned'then for i,v in ipairs(samples[1])do check(math.abs(v-samples[201][i])<.00001,'seamless loop')end end
  end end
  if profile.groundPoints then check(#s.bodyPoints>=3 and #s.bodyPoints<=64,'bounded real lower-surface support samples')end
  if profile.rigidArms then for _,clip in pairs(profile.clips)do for _,ch in ipairs({'weapon','off'})do for _,values in ipairs(clip[ch])do for _,x in ipairs(values)do check(x==0,'fused garments/weapons keep one anchor')end end end end end
  for _,phase in ipairs({.15,.35,.65,.85})do
   for _,state in ipairs({'Windup','Active','Recovery','Stunned','Exposed'})do
    s.phase=phase;s.move=1;m:SetAttribute('K0EnemyState',state);m:SetAttribute('K0EnemyAttackClock','1|1000|1|0.2|0.8|0');m:SetAttribute('K0EnemyStunUntil',state=='Stunned'and 2000 or nil)
    Motion.step(s,1/60,1001)
    for ch,leg in pairs(s.legs)do local gap=sole(s,ch)-leg.bottom;row.maxStoppedFootLift=math.max(row.maxStoppedFootLift,math.abs(gap));check(math.abs(gap)<.002,'old walk phase cannot lift a planted attack/stunned foot')end
   end
  end
  m:SetAttribute('K0EnemyStunUntil',nil)
  for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
   local attack=Combat.profiles[kind].attacks[clip:find('Heavy')and 2 or 1]or Combat.profiles[kind].attacks[1]
   for _,hz in ipairs({30,60,144})do
    local q=assert(Motion.bind(m));m:SetAttribute('K0EnemyState','Windup')
    m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|3000|'..attack.windup..'|'..attack.active..'|'..attack.recovery..'|'..(clip:find('Heavy')and'1'or'0'))
    Motion.step(q,1/hz,3000+attack.windup)
    local hit=Motion.sample(kind,clip,.62)
    for _,ch in ipairs(Clips.channels)do for i,v in ipairs(hit[ch])do check(math.abs(q.pose[ch][i]-v)<.001,'native contact aligns to unchanged server windup at '..hz..'Hz')end end
    check(root.CFrame==original and m.Humanoid.Health==hp,'presentation cannot move authoritative root or change health')
    if not profile.hasLegs then check(math.abs(bottom(bodyCF(q),q.bodyPoints)-q.bodyBottom)<.002,'fused lower surface remains grounded at contact')end
    if q.weaponFX then check(q.weaponFX.trail.Enabled,'weapon/focus accent appears only at server-aligned contact');m:SetAttribute('K0EnemyState','Idle');m:SetAttribute('K0EnemyAttackClock',nil);Motion.step(q,1/hz,3010);check(not q.weaponFX.trail.Enabled,'no idle weapon trail')end
    Motion.unbind(q)
   end
  end
  if kind=='Skeleton'or kind=='SkeletonKnight'then
   check(m:GetAttribute('TdWeaponArm')=='ArmL'and s.joints.weapon.Name=='Right Shoulder','sword arm, not shield, owns the attack')
   row.bladeForwardTravel={}
   for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
    m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|6000|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0'))
    local function tip(now)Motion.step(s,1/60,now);local motor=s.joints.weapon;return (bodyCF(s)*motor.C0*motor.Transform*motor.C1:Inverse()*s.weaponFX.socketInArm).Position end
    local ready,contact=tip(6000.8),tip(6001);row.bladeForwardTravel[clip]=ready.Z-contact.Z
    check(ready.Z-contact.Z>.05,'actual blade tip moves toward enemy at contact')
   end
  end
  if profile.hasLegs then
   local p=Motion.sample(kind,'Walk',.2);check(p.rightLeg[1]*p.leftLeg[1]<0,'opposite legs alternate')
   if profile.quadruped then check(math.abs(p.weapon[1]-p.rightLeg[1])<.001 and math.abs(p.off[1]-p.leftLeg[1])<.001,'diagonal limbs share phase')end
   m:SetAttribute('K0EnemyState','Chase');m:SetAttribute('K0EnemyAttackClock',nil);s.phase=0;s.move=1;s.position=root.Position
   local leg=s.legs.rightLeg;local point=Vector3.zero;local minY=math.huge
   for _,v in ipairs(leg.points)do point+=v;minY=math.min(minY,v.Y)end;point=point/#leg.points;point=Vector3.new(point.X,minY,point.Z)
   local low,high=math.huge,-math.huge;local cycle=profile.stride*s.height/6;local motor=s.joints.rightLeg
   for frame=1,120 do local t=frame/120;root.CFrame=original*CFrame.new(0,0,-profile.stride*s.height*t);Motion.step(s,cycle/120,4000+cycle*t)
    if t>=.125 and t<=.5 then local v=(root.CFrame*bodyCF(s)*motor.C0*motor.Transform*motor.C1:Inverse()):PointToWorldSpace(point);low=math.min(low,v.Z);high=math.max(high,v.Z)end
   end
   row.stanceSlipHeightFraction=(high-low)/s.height;check(row.stanceSlipHeightFraction<.03,'stance-foot drift below 3% of height at 6 studs/s');root.CFrame=original
  elseif profile.rigidArms then
   local a,b=Motion.sample(kind,'Attack',.4).body,Motion.sample(kind,'Attack',.62).body
   check(math.abs(a[3]-b[3])>.02 and math.abs(a[4]-b[4])>3,'fused monster still has a readable preparation/contact difference')
  end
  if kind=='Lich'or kind=='LichSovereign'then check(s.weaponFX and #s.weaponFX.shards==3,'staff focus is attached to actual TD staff part')end
  Motion.unbind(s);m:Destroy();task.wait()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();Run:Stop();report.pass=ok
print('HAUNTED_MONSTER_MOTION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)

end

do
-- Unpublished real Studio geometry, TD MeshParts and server story APIs.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture only')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(4)end
local RS=game.ReplicatedStorage;local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='FROZEN_VALE_NATIVE',scope='motion-and-story',checks=0,failures={},weapons={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='FrozenValeNativeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress);local Rigs=require(RS.Shared.FrozenValeRigs)
 local world=require(Server.World.CampaignWorld).create();check(world.folder:GetAttribute('FrozenValeReady'),'campaign bootstrap')
 local Bounds=require(RS.Shared.CampaignBounds)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain};params.RespectCanCollide=true
 for id,z in pairs(require(RS.Shared.FrozenValeContent).zones)do
  check(world.spawns[id]~=nil,'checkpoint '..id)
  local center=Vector3.new(table.unpack(z.center));local hit=workspace:Raycast(center+Vector3.new(0,2,0),Vector3.new(0,-6,0),params)
  check(hit and math.abs(hit.Position.Y-center.Y)<.1,'actual snow surface '..id)
 end
 for _,edge in ipairs(require(RS.Shared.FrozenValeContent).edges)do
  local a,b=Bounds.ends(edge);a,b=Vector3.new(table.unpack(a)),Vector3.new(table.unpack(b))
  for i=0,10 do local p=a:Lerp(b,i/10);local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
   check(hit~=nil,'continuous snow trail '..edge[1]..':'..i)
   check(hit and math.abs(hit.Position.Y-p.Y)<.25,'snow trail and authority height agree')
  end
 end
 local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.FrozenValeClips);local Field=require(Server.World.TrainingField)
 for kind,spec in pairs(Rigs)do
  local model=Field.makeEnemy(folder,kind,10000+report.checks,10000,1,1);model.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(model));local health=model.Humanoid.Health;local root=model.HumanoidRootPart;local initial=root.CFrame
  check(model:GetAttribute('TdMonsterTemplate')==spec.template,kind..' TD source selected')
  check(s.profile.quadruped==(kind=='IceWolf' or kind=='IceBear' or kind=='KingIceBear'),kind..' anatomy')
  local count=0;for _ in pairs(s.legs)do count+=1 end
  check(count==(s.profile.quadruped and 4 or kind=='QueenIceElf' and 0 or 2),kind..' independent legs')
  for _,clip in ipairs({'Idle','Walk','Stunned'})do
   for _,ch in ipairs(Clips.channels)do local a,b=Motion.sample(kind,clip,0)[ch],Motion.sample(kind,clip,1)[ch]
    for i,value in ipairs(a)do check(math.abs(value-b[i])<1e-5,kind..' seamless loop')end
   end
  end
  for _,hz in ipairs({30,60,144})do for sequence=1,4 do
   local heavy=sequence>=3;local clip=(heavy and 'Heavy' or 'Attack')..(sequence%2==0 and 'Alt' or '')
   model:SetAttribute('K0EnemyState','Windup');model:SetAttribute('K0EnemyAttackClock',sequence..'|500|1.2|.15|1.4|'..(heavy and '1' or '0'))
   Motion.step(s,1/hz,500.96)
   local before=s.caster and s.caster.bones.ForearmR.Transform or s.joints.weapon and s.joints.weapon.Transform
   Motion.step(s,1/hz,501.2)
   if s.caster then
    local pose=require(Client.RegionalCasterMotion).sample(kind,clip,.62,s.height)
    for name,cf in pose do local delta=cf:Inverse()*s.caster.bones[name].Transform;local _,angle=delta:ToAxisAngle();check(delta.Position.Magnitude<.0001 and math.abs(angle)<.002,kind..' imported Bone contact '..name)end
   else
    for _,ch in ipairs(Clips.channels)do for i,value in ipairs(Motion.sample(kind,clip,.62)[ch])do check(math.abs(s.pose[ch][i]-value)<.0001,kind..' exact server contact at '..hz..'Hz')end end
   end
   if spec.socket then
    check(s.weaponFX and s.weaponFX.trail.Enabled,kind..' actual moving weapon trail')
    local delta=(before:Inverse()*(s.caster and s.caster.bones.ForearmR.Transform or s.joints.weapon.Transform));local _,angle=delta:ToAxisAngle()
    if s.caster then check(math.abs(angle)>.01,kind..' skinned elbow advances at contact') else check(math.abs(angle)>.05,kind..' weapon advances at contact')end
    check(s.weaponFX.a.Position.Magnitude>0,kind..' authored tip follows original mesh')
   end
   Motion.step(s,1/hz,503)
   check(not s.weaponFX or not s.weaponFX.trail.Enabled,kind..' recovery clears trail')
   check(root.CFrame==initial and model.Humanoid.Health==health,kind..' visual motion cannot move server root or damage')
  end end
  if s.weaponFX then model:SetAttribute('K0EnemyStunUntil',600);Motion.step(s,1/60,550);check(not s.weaponFX.trail.Enabled,kind..' stun clears weapon')end
  Motion.unbind(s);check(not model.TdMonsterVisual:FindFirstChild('K0WeaponPresentation',true),kind..' presentation cleaned on unbind');model:Destroy()
 end
 -- Saved personal journal starts at the old Deepwood boundary, without rewriting old flags.
 local journal=P.new()
 for n=1,7 do local c=C.mainChapters[n];for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
  else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary' or nil))end
 end end end
 check(P.validate(journal) and journal.main==7,'old saved journal before FV')
 local Rules=require(Server.Inventory.InventoryRules);local Catalog=require(RS.Shared.ItemCatalog)
 local profile=assert(Rules.addHero(Rules.new(911),'qa','knight',Catalog));profile.heroes.qa.deepwood=journal
 local original=Server.Story.DeepwoodService;local copy=original:Clone();copy.Name='FrozenValeServiceQA'
 local source=copy.Source;local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true));copy.Source=source:sub(1,first-1)..'local function publish(player,message)player.message=message end\n'..source:sub(last);copy.Parent=original.Parent
 local story=require(copy);local combat=require(Server.Combat.CombatService);local xp,gold=0,0;local saveFaults={'SaveUnknown','Busy'};local firstEvent;local attempts=0;local expedition
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local h=Instance.new('Humanoid');h.Parent=character;h.MaxHealth=1000;h.Health=1000
 local player={UserId=911,Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
 local inventory={storyState=function()return P.copy(profile.heroes.qa.deepwood)end,
  expedition=function(owner,hero)check(owner==player and hero=='qa','expedition reads the active personal hero');return expedition end,
  storyEvent=function(_,hero,c,g,choice,step,runId)
   if not firstEvent then firstEvent={hero,c,g,choice=choice,step=step,runId=runId,coins=profile.heroes.qa.deepwood.coins,revision=profile.revision}end
   if c==firstEvent[2] and g==firstEvent[3] then
    attempts+=1
    check(hero==firstEvent[1] and choice==firstEvent.choice and step==firstEvent.step and runId==firstEvent.runId,'retry preserves personal event identity')
    check(profile.heroes.qa.deepwood.coins==firstEvent.coins and profile.revision==firstEvent.revision and not profile.heroes.qa.deepwood.flags[c..':'..g],'unconfirmed save cannot advance or award story rewards')
    local fault=table.remove(saveFaults,1);if fault then return fault end
   end
   local nextState,reason
   if g=='@selene' then nextState,reason=Rules.selectSelene(profile,hero,choice)
   elseif g=='@accept' then nextState,reason=Rules.acceptQuest(profile,hero,c,choice==true)
   else nextState,reason=Rules.story(profile,hero,c,g,choice,Catalog,step)end
   if nextState then profile=nextState end;return reason
  end,
  -- Support-pass ownership is pre-provisioned in this story fixture, not purchased here.
  supportState=function()return {active=true,credits=0}end,
  activateSupport=function(owner,hero)check(owner==player and hero=='qa','camp uses the fixture-owned active support pass')end,
  awardXP=function(_,_,amount,_,coins)xp+=amount;gold+=coins or 0 end}
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession={getActiveHero=function()return {heroId='qa',training=false}end,getCombatContext=function()return {heroId='qa'}end},combat=combat})
 check(story.destination(player,'qa')==world.spawns['FV-01'],'Deepwood save resumes in Frozen Vale')
 expedition={missionId='FV-02',runId='qa-destination'}
 check(story.destination(player,'qa')==world.spawns['FV-02'],'active personal expedition selects its mission checkpoint')
 expedition=nil
 check(story.destination(player,'qa')==world.spawns['FV-01'],'cleared expedition falls back to saved campaign checkpoint')
 root.Position=world.refugeCompanionCamp.PrimaryPart.Position;check(not story.selectSelene(player,true),'locked refuge cannot select companion before entry')
 local function alive(key)local out={}for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key..':legacy' and m.Humanoid.Health>0 and not m:GetAttribute('StoryPacified')then table.insert(out,m)end end;return out end
 local function drain(c,g)
  local key=c.id..':'..g.id
  for _=1,80 do local models=alive(key);if #models==0 then break end
   check(#models<=require(RS.Shared.DeepwoodEncounterBalance).packSize(c,g),'finite capped pack')
   for _,m in ipairs(models)do
    if m:GetAttribute('StoryBoss')then
     local human=m.Humanoid;local damage=story.bossDamage(m,human.Health*5);human:TakeDamage(damage);task.wait(.01)
     check(human.Health>0 and m:GetAttribute('StoryPacified'),'guardian survives lethal proposed damage')
     check(story.bossDamage(m,100000)==0,'pacified guardian rejects repeated damage')
     story.defeated(m);story.defeated(m)
    else m.Humanoid.Health=0;task.wait(.003);story.defeated(m);story.defeated(m)end
   end
   task.wait(.01)
  end
  check(#alive(key)==0,'finite encounter drains');task.wait(.1)
 end
 for n=8,14 do local c=C.mainChapters[n]
  for _,g in ipairs(c.goals)do
   local node=world.nodes[c.id..':'..g.id];check(node and node.prompt,'actual objective anchor')
   root.Position=node.part.Position
   if #g.enemies>0 then story.interact(player,c.id,g.id);drain(c,g)
   elseif g.activity and g.activity.mode=='travel' then story.interactStep(player,c.id,g.id,g.activity.steps[1].id)
   else story.interact(player,c.id,g.id)end
   if n==8 and g==c.goals[1]then
    check(story.hasPendingEvents(player),'unconfirmed event stays queued')
    check(not inventory.storyState().flags[c.id..':'..g.id],'progress stays unconfirmed before retry')
    local deadline=os.clock()+5
    repeat task.wait(.05)until not story.hasPendingEvents(player)or os.clock()>deadline
    check(attempts==3 and #saveFaults==0 and not story.hasPendingEvents(player),'SaveUnknown and Busy retry the same event to confirmed completion')
   else task.wait(.1)end
   check(inventory.storyState().flags[c.id..':'..g.id],'service saves '..c.id..':'..g.id)
  end
  check(inventory.storyState().main==n,'correct checkpoint advancement')
  if n==8 then root.Position=world.refugeCompanionCamp.PrimaryPart.Position;check(story.selectSelene(player,true),'safe refuge companion selection');task.wait(.1);check(inventory.storyState().seleneFollowing,'companion preference saved at refuge')end
 end
 check(story.destination(player,'qa')==world.spawns['EC-01'],'completed Frozen Vale resumes at next epic')
 check(inventory.storyState().coins==5650 and P.validate(inventory.storyState()),'canonical story reward once, compatible journal')
 check(xp>0 and gold>0,'actual battle server rewards')
 -- Optional quest acceptance is personal and distinct from reports.
 for _,c in ipairs(C.chapters)do if c.epic==2 and c.side then
  root.Position=world.nodes[c.id..':'..c.goals[1].id].part.Position;story.interact(player,c.id,c.goals[1].id);check(story.acceptQuest(player,c.id),'optional request acceptance');task.wait(.1)
  for _,g in ipairs(c.goals)do if not inventory.storyState().flags[c.id..':'..g.id]then
   root.Position=world.nodes[c.id..':'..g.id].part.Position;story.interact(player,c.id,g.id);if #g.enemies>0 then drain(c,g)end;task.wait(.1)
  end end
  check(inventory.storyState().clears[c.id],'optional report saved')
 end end
 check(inventory.storyState().coins==5650,'optional quests never invent fixed budgets')
 character:Destroy();copy:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();report.pass=#report.failures==0
print('FROZEN_VALE_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'regional regression failed')

end
do
-- Unpublished real Studio geometry, TD MeshParts and server story APIs.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture only')
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(4)end
local RS=game.ReplicatedStorage;local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='EMBER_CALDERA_NATIVE',scope='motion-and-story',checks=0,failures={},weapons={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='EmberCalderaNativeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress);local Rigs=require(RS.Shared.EmberCalderaRigs)
 local world=require(Server.World.CampaignWorld).create();check(world.folder:GetAttribute('EmberCalderaReady'),'campaign bootstrap')
 local Bounds=require(RS.Shared.CampaignBounds)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain};params.RespectCanCollide=true
 for id,z in pairs(require(RS.Shared.EmberCalderaContent).zones)do
  check(world.spawns[id]~=nil,'checkpoint '..id)
  local center=Vector3.new(table.unpack(z.center));local hit=workspace:Raycast(center+Vector3.new(0,2,0),Vector3.new(0,-6,0),params)
  check(hit and math.abs(hit.Position.Y-center.Y)<.1,'actual snow surface '..id)
 end
 for _,edge in ipairs(require(RS.Shared.EmberCalderaContent).edges)do
  local a,b=Bounds.ends(edge);a,b=Vector3.new(table.unpack(a)),Vector3.new(table.unpack(b))
  for i=0,10 do local p=a:Lerp(b,i/10);local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
   check(hit~=nil,'continuous snow trail '..edge[1]..':'..i)
   check(hit and math.abs(hit.Position.Y-p.Y)<.25,'snow trail and authority height agree')
  end
 end
 local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.EmberCalderaClips);local Field=require(Server.World.TrainingField)
 for kind,spec in pairs(Rigs)do
  local model=Field.makeEnemy(folder,kind,10000+report.checks,10000,1,1);model.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(model));local health=model.Humanoid.Health;local root=model.HumanoidRootPart;local initial=root.CFrame
  check(model:GetAttribute('TdMonsterTemplate')==spec.template,kind..' TD source selected')
  check(s.profile.quadruped==false,kind..' anatomy')
  local count=0;for _ in pairs(s.legs)do count+=1 end
  check(count==((kind=='LavaSlime' or kind=='MagmaWorm' or kind=='VolcanoShaman' or kind=='KingVolcanoShaman') and 0 or 2),kind..' independent legs')
  for _,clip in ipairs({'Idle','Walk','Stunned'})do
   for _,ch in ipairs(Clips.channels)do local a,b=Motion.sample(kind,clip,0)[ch],Motion.sample(kind,clip,1)[ch]
    for i,value in ipairs(a)do check(math.abs(value-b[i])<1e-5,kind..' seamless loop')end
   end
  end
  for _,hz in ipairs({30,60,144})do for sequence=1,4 do
   local heavy=sequence>=3;local clip=(heavy and 'Heavy' or 'Attack')..(sequence%2==0 and 'Alt' or '')
   model:SetAttribute('K0EnemyState','Windup');model:SetAttribute('K0EnemyAttackClock',sequence..'|500|1.2|.15|1.4|'..(heavy and '1' or '0'))
   Motion.step(s,1/hz,500.96)
   local before=s.caster and s.caster.bones.ForearmR.Transform or s.joints.weapon and s.joints.weapon.Transform
   Motion.step(s,1/hz,501.2)
   if s.caster then
    local pose=require(Client.RegionalCasterMotion).sample(kind,clip,.62,s.height)
    for name,cf in pose do local delta=cf:Inverse()*s.caster.bones[name].Transform;local _,angle=delta:ToAxisAngle();check(delta.Position.Magnitude<.0001 and math.abs(angle)<.002,kind..' imported Bone contact '..name)end
   else
    for _,ch in ipairs(Clips.channels)do for i,value in ipairs(Motion.sample(kind,clip,.62)[ch])do check(math.abs(s.pose[ch][i]-value)<.0001,kind..' exact server contact at '..hz..'Hz')end end
   end
   if spec.socket then
    check(s.weaponFX and s.weaponFX.trail.Enabled,kind..' actual moving weapon trail')
    local delta=(before:Inverse()*(s.caster and s.caster.bones.ForearmR.Transform or s.joints.weapon.Transform));local _,angle=delta:ToAxisAngle()
    if s.caster then check(math.abs(angle)>.01,kind..' skinned elbow advances at contact')else check(math.abs(angle)>.05,kind..' weapon advances at contact')end
    check(s.weaponFX.a.Position.Magnitude>0,kind..' authored tip follows original mesh')
   end
   Motion.step(s,1/hz,503)
   check(not s.weaponFX or not s.weaponFX.trail.Enabled,kind..' recovery clears trail')
   check(root.CFrame==initial and model.Humanoid.Health==health,kind..' visual motion cannot move server root or damage')
  end end
  if s.weaponFX then model:SetAttribute('K0EnemyStunUntil',600);Motion.step(s,1/60,550);check(not s.weaponFX.trail.Enabled,kind..' stun clears weapon')end
  Motion.unbind(s);check(not model.TdMonsterVisual:FindFirstChild('K0WeaponPresentation',true),kind..' presentation cleaned on unbind');model:Destroy()
 end
 -- Saved personal journal starts at the old Deepwood boundary, without rewriting old flags.
 local journal=P.new()
 for n=1,14 do local c=C.mainChapters[n];for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
  else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary' or nil))end
 end end end
 check(P.validate(journal) and journal.main==14,'old saved journal before EC')
 local Rules=require(Server.Inventory.InventoryRules);local Catalog=require(RS.Shared.ItemCatalog)
 local profile=assert(Rules.addHero(Rules.new(911),'qa','knight',Catalog));profile.heroes.qa.deepwood=journal
 local original=Server.Story.DeepwoodService;local copy=original:Clone();copy.Name='EmberCalderaServiceQA'
 local source=copy.Source;local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true));copy.Source=source:sub(1,first-1)..'local function publish(player,message)player.message=message end\n'..source:sub(last);copy.Parent=original.Parent
 local story=require(copy);local combat=require(Server.Combat.CombatService);local xp,gold=0,0;local saveFaults={'SaveUnknown','Busy'};local firstEvent;local attempts=0;local expedition;local liftAttempts=0
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local h=Instance.new('Humanoid');h.Parent=character;h.MaxHealth=1000;h.Health=1000
 local player={UserId=911,Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
 local inventory={storyState=function()return P.copy(profile.heroes.qa.deepwood)end,
  expedition=function(owner,hero)check(owner==player and hero=='qa','expedition reads the active personal hero');return expedition end,
  storyEvent=function(_,hero,c,g,choice,step,runId)
   if not firstEvent then firstEvent={hero,c,g,choice=choice,step=step,runId=runId,coins=profile.heroes.qa.deepwood.coins,revision=profile.revision}end
   if c==firstEvent[2] and g==firstEvent[3] then
    attempts+=1
    check(hero==firstEvent[1] and choice==firstEvent.choice and step==firstEvent.step and runId==firstEvent.runId,'retry preserves personal event identity')
    check(profile.heroes.qa.deepwood.coins==firstEvent.coins and profile.revision==firstEvent.revision and not profile.heroes.qa.deepwood.flags[c..':'..g],'unconfirmed save cannot advance or award story rewards')
    local fault=table.remove(saveFaults,1);if fault then return fault end
   end
   if c=='EC-01' and g=='lift' then
    liftAttempts+=1
    check(not profile.heroes.qa.deepwood.flags['EC-01:lift'],'lift awaits confirmed personal progress')
    if liftAttempts==1 then return 'SaveUnknown'end
   end
   local nextState,reason
   if g=='@selene' then nextState,reason=Rules.selectSelene(profile,hero,choice)
   elseif g=='@accept' then nextState,reason=Rules.acceptQuest(profile,hero,c,choice==true)
   else nextState,reason=Rules.story(profile,hero,c,g,choice,Catalog,step)end
   if nextState then profile=nextState end;return reason
  end,
  -- Support-pass ownership is pre-provisioned in this story fixture, not purchased here.
  supportState=function()return {active=true,credits=0}end,
  activateSupport=function(owner,hero)check(owner==player and hero=='qa','camp uses the fixture-owned active support pass')end,
  awardXP=function(_,_,amount,_,coins)xp+=amount;gold+=coins or 0 end}
 local testedCombat=table.clone(combat)
 testedCombat.relocateForStoryGate=function(owner,pivot)check(owner==player and profile.heroes.qa.deepwood.flags['EC-01:lift'],'lift transfer requires confirmed personal save');character:PivotTo(pivot);return true end
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession={getActiveHero=function()return {heroId='qa',training=false}end,getCombatContext=function()return {heroId='qa'}end},combat=testedCombat})
 check(story.destination(player,'qa')==world.spawns['EC-01'],'Frozen Vale save resumes in Ember Caldera')
 expedition={missionId='EC-02',runId='qa-destination'}
 check(story.destination(player,'qa')==world.spawns['EC-02'],'active personal expedition selects its mission checkpoint')
 expedition=nil
 check(story.destination(player,'qa')==world.spawns['EC-01'],'cleared expedition falls back to saved campaign checkpoint')
 root.Position=world.emberCompanionCamp.PrimaryPart.Position;check(not story.selectSelene(player,true),'locked refuge cannot select companion before entry')
 local function alive(key)local out={}for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key..':legacy' and m.Humanoid.Health>0 and not m:GetAttribute('StoryPacified')then table.insert(out,m)end end;return out end
 local function drain(c,g)
  local key=c.id..':'..g.id
  for _=1,80 do local models=alive(key);if #models==0 then break end
   check(#models<=require(RS.Shared.DeepwoodEncounterBalance).packSize(c,g),'finite capped pack')
   for _,m in ipairs(models)do
    if m:GetAttribute('EnemyKind')=='InfernoOverlord'then
     local human=m.Humanoid;local max=human.MaxHealth
     human:TakeDamage(story.bossDamage(m,max*5));check(math.abs(human.Health/max-.65)<.0001,'Inferno phase two clamps first lethal hit')
     human:TakeDamage(story.bossDamage(m,max*5));check(math.abs(human.Health/max-.30)<.0001,'Inferno phase three clamps second lethal hit')
     check(m:GetAttribute('StoryPhase')==3 and not m:GetAttribute('StoryPacified'),'Inferno uses lethal combat, separate from ice guardians')
     human:TakeDamage(story.bossDamage(m,max*5));task.wait(.01);story.defeated(m);story.defeated(m)
    else m.Humanoid.Health=0;task.wait(.003);story.defeated(m);story.defeated(m)end
   end
   task.wait(.01)
  end
  check(#alive(key)==0,'finite encounter drains');task.wait(.1)
 end
 for n=15,21 do local c=C.mainChapters[n]
  for _,g in ipairs(c.goals)do
   local node=world.nodes[c.id..':'..g.id];check(node and node.prompt,'actual objective anchor')
   root.Position=node.part.Position
   if #g.enemies>0 then story.interact(player,c.id,g.id);drain(c,g)
   elseif g.activity and g.activity.mode=='escort'then
    story.interact(player,c.id,g.id)
    for _=1,300 do
     if inventory.storyState().flags[c.id..':'..g.id]then break end
     local escort
     for _,m in ipairs(world.folder:GetChildren())do if m:IsA('Model') and m:GetAttribute('NPCPrivateOwnerUserId')==911 then escort=m;break end end
     check(escort and escort.PrimaryPart,'per-owner dwarf rescue actor')
     root.Position=escort.PrimaryPart.Position+Vector3.new(0,3,0);story.stepActivities(.2);task.wait(.001)
    end
   elseif g.activity and (g.activity.mode=='travel' or g.activity.mode=='mechanism') then story.interactStep(player,c.id,g.id,g.activity.steps[1].id)
   else story.interact(player,c.id,g.id)end
   if n==15 and g==c.goals[1]then
    check(story.hasPendingEvents(player),'unconfirmed event stays queued')
    check(not inventory.storyState().flags[c.id..':'..g.id],'progress stays unconfirmed before retry')
    local deadline=os.clock()+5
    repeat task.wait(.05)until not story.hasPendingEvents(player)or os.clock()>deadline
    check(attempts==3 and #saveFaults==0 and not story.hasPendingEvents(player),'SaveUnknown and Busy retry the same event to confirmed completion')
   elseif c.id=='EC-01' and g.id=='lift'then
    check(story.hasPendingEvents(player)and not inventory.storyState().flags['EC-01:lift'],'unconfirmed lift stays queued')
    check((root.Position-world.spawns['EC-02'].Position).Magnitude>10,'unconfirmed lift cannot transfer the hero')
    local deadline=os.clock()+5
    repeat task.wait(.05)until not story.hasPendingEvents(player)or os.clock()>deadline
    check(liftAttempts==2 and not story.hasPendingEvents(player),'lift retry confirms once before transfer')
   else task.wait(.1)end
   check(inventory.storyState().flags[c.id..':'..g.id],'service saves '..c.id..':'..g.id)
   if c.id=='EC-01' and g.id=='lift'then check((root.Position-world.spawns['EC-02'].Position).Magnitude<10,'repaired lift transfers to prepared safe city checkpoint after save')end
  end
  check(inventory.storyState().main==n,'correct checkpoint advancement')
  if n==15 then root.Position=world.emberCompanionCamp.PrimaryPart.Position;check(story.selectSelene(player,true),'safe refuge companion selection');task.wait(.1);check(inventory.storyState().seleneFollowing,'companion preference saved at refuge')end
 end
 check(story.destination(player,'qa')==world.spawns['GW-01'],'completed Ember Caldera resumes at next epic')
 check(inventory.storyState().coins==10290 and P.validate(inventory.storyState()),'canonical story reward once, compatible journal')
 check(xp>0 and gold>0,'actual battle server rewards')
 -- Optional quest acceptance is personal and distinct from reports.
 for _,c in ipairs(C.chapters)do if c.epic==3 and c.side then
  root.Position=world.nodes[c.id..':'..c.goals[1].id].part.Position;story.interact(player,c.id,c.goals[1].id);check(story.acceptQuest(player,c.id),'optional request acceptance');task.wait(.1)
  for _,g in ipairs(c.goals)do if not inventory.storyState().flags[c.id..':'..g.id]then
   root.Position=world.nodes[c.id..':'..g.id].part.Position;story.interact(player,c.id,g.id);if #g.enemies>0 then drain(c,g)end;task.wait(.1)
  end end
  check(inventory.storyState().clears[c.id],'optional report saved')
 end end
 check(inventory.storyState().coins==10290,'optional quests never invent fixed budgets')
 local expectedXP,expectedGold=0,0;local balance=require(RS.Shared.DeepwoodEncounterBalance)
 local function add(specs)for _,spec in ipairs(specs)do expectedXP+=(8+2*spec.level)*(balance.isBoss(spec.kind)and 5 or 1)*spec.count;expectedGold+=(3+math.floor(spec.level/2))*(balance.isBoss(spec.kind)and 10 or 1)*spec.count end end
 for _,c in ipairs(C.chapters)do if c.epic==3 then for _,g in ipairs(c.goals)do add(g.enemies);for _,wave in ipairs(g.bossEncounter and g.bossEncounter.waves or {})do add(wave.enemies)end end end end
 check(xp==expectedXP and gold==expectedGold,'all kill rewards are exact and duplicate callbacks pay once')
 character:Destroy();copy:Destroy()
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();report.pass=#report.failures==0
print('EMBER_CALDERA_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'regional regression failed')

end
do
-- Behavioral regressions found during per-species native/Blender review.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion);local Clips={channels={'body','weapon','off','rightLeg','leftLeg'},models={}};for _,module in ipairs({Client.FrozenValeClips,Client.EmberCalderaClips})do for kind,p in pairs(require(module).models)do Clips.models[kind]=p end end;local Field=require(Server.World.TrainingField)
local report={kind='REGIONAL_INDIVIDUAL_REVIEW_NATIVE',checks=0,failures={},species={}}
local function check(value,message)report.checks+=1;assert(value,message)end
local folder=Instance.new('Folder');folder.Name='IndividualMotionAcceptance';folder.Parent=workspace
local function sole(s,ch)
 local leg=s.legs[ch];local motor=s.joints[ch];local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
 local cf=body*motor.C0*motor.Transform*motor.C1:Inverse();local bottom=math.huge
 for _,v in ipairs(leg.points)do bottom=math.min(bottom,cf:PointToWorldSpace(v).Y)end
 return bottom
end
local ok,err=xpcall(function()
 for kind,profile in pairs(Clips.models)do
  local m=Field.makeEnemy(folder,kind,10000,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m));local root=m.HumanoidRootPart;local original=root.CFrame;local hp=m.Humanoid.Health
  if kind=='IceTrollKing'then check(m:GetAttribute('TdWeaponArm')=='ArmL'and s.joints.weapon.Name=='Right Shoulder','Ice Troll King attacks with its club hand')end
  local row={maxStoppedFootLift=0};report.species[kind]=row
  -- Enter attacks/stuns with either leg mid-swing; the previous gait must not leak into the pose.
  for _,phase in ipairs({.15,.35,.65,.85})do
   for _,state in ipairs({'Windup','Active','Recovery','Stunned','Exposed'})do
    s.phase=phase;s.move=1;m:SetAttribute('K0EnemyState',state)
    m:SetAttribute('K0EnemyAttackClock','1|1000|1|0.2|0.8|0');m:SetAttribute('K0EnemyStunUntil',state=='Stunned'and 2000 or nil)
    Motion.step(s,1/60,1001)
    for ch,leg in pairs(s.legs)do
     local gap=sole(s,ch)-leg.bottom;row.maxStoppedFootLift=math.max(row.maxStoppedFootLift,math.abs(gap))
     check(math.abs(gap)<.002,kind..' '..state..' plants both feet regardless of old gait phase')
    end
   end
  end
  m:SetAttribute('K0EnemyStunUntil',nil)
  for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
   local poses={}
   for _,hz in ipairs({30,60,144})do
    local q=assert(Motion.bind(m));m:SetAttribute('K0EnemyState','Windup')
    m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|3000|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0'))
    Motion.step(q,1/hz,3001);table.insert(poses,q.pose)
    local hit=Motion.sample(kind,clip,.62)
    if q.caster then
     local target=require(Client.RegionalCasterMotion).sample(kind,clip,.62,q.height)
     for name,cf in target do local delta=cf:Inverse()*q.caster.bones[name].Transform;local _,angle=delta:ToAxisAngle();check(delta.Position.Magnitude<.0001 and math.abs(angle)<.002,kind..' imported exact contact '..name)end
    else
     for _,ch in ipairs(Clips.channels)do for i,v in ipairs(hit[ch])do check(math.abs(q.pose[ch][i]-v)<.001,kind..' exact contact at '..hz..'Hz')end end
    end
    check(root.CFrame==original and m.Humanoid.Health==hp,'pose cannot change server root/health')
    Motion.unbind(q)
   end
  end
  if kind=='IceTrollKing'then
   m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock','1|6000|1|0.2|0.8|0')
   local function tipAt(now)
    Motion.step(s,1/60,now);local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse();local motor=s.joints.weapon
    return (body*motor.C0*motor.Transform*motor.C1:Inverse()*s.weaponFX.socketInArm).Position
   end
   local ready,contact=tipAt(6000.8),tipAt(6001);row.clubForwardTravel=ready.Z-contact.Z
   check(row.clubForwardTravel>.02,'Ice Troll King actual club tip moves forward at contact')
  end
  if profile.hasLegs then
   local p=Motion.sample(kind,'Walk',.2);local guard=Motion.sample(kind,'Idle',0).weapon[1]
   if profile.quadruped then
    check(math.abs(p.weapon[1]-p.rightLeg[1])<.001 and math.abs(p.off[1]-p.leftLeg[1])<.001,kind..' diagonal limbs share phase')
   else
    if kind~='IceElf' then check((p.weapon[1]-guard)*(kind=='IceTrollKing'and p.leftLeg[1]or p.rightLeg[1])>0,kind..' anatomical arm counter-swing')end
   end
   check(p.rightLeg[1]*p.leftLeg[1]<0,kind..' opposite feet alternate')
   m:SetAttribute('K0EnemyState','Chase');m:SetAttribute('K0EnemyAttackClock',nil)
   s.phase=0;s.move=1;s.position=root.Position
   local leg=s.legs.rightLeg;local point=Vector3.zero;local minY=math.huge
   for _,v in ipairs(leg.points)do point+=v;minY=math.min(minY,v.Y)end
   point=point/#leg.points;point=Vector3.new(point.X,minY,point.Z)
   local low,high=math.huge,-math.huge;local cycle=profile.stride*s.height/6;local motor=s.joints.rightLeg
   for frame=1,120 do
    local t=frame/120;root.CFrame=original*CFrame.new(0,0,-profile.stride*s.height*t)
    Motion.step(s,cycle/120,4000+cycle*t)
    if t>=.125 and t<=.5 then
     local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
     local solePoint=(root.CFrame*body*motor.C0*motor.Transform*motor.C1:Inverse()):PointToWorldSpace(point)
     low=math.min(low,solePoint.Z);high=math.max(high,solePoint.Z)
    end
   end
   row.stanceSlipHeightFraction=(high-low)/s.height
   check(row.stanceSlipHeightFraction<.03,kind..' planted foot drift stays below 3% of body height at 6 studs/s')
   root.CFrame=original

  end
  if profile.quadruped then
   for _,phase in ipairs({.25,.75})do
    s.phase=phase;s.move=1;s.pose=Motion.sample(kind,'Walk',phase);m:SetAttribute('K0EnemyState','Chase');m:SetAttribute('K0EnemyAttackClock',nil);s.position=root.Position
    Motion.step(s,0,5000)
    local gaps={};for ch,leg in pairs(s.legs)do gaps[ch]=sole(s,ch)-leg.bottom end
    check(math.abs(gaps.weapon-gaps.rightLeg)<.002 and math.abs(gaps.off-gaps.leftLeg)<.002,kind..' diagonal feet lift together')
    check(phase==.25 and gaps.off>.01 or phase==.75 and gaps.weapon>.01,kind..' returning diagonal actually clears ground')
   end
  end
  Motion.unbind(s);m:Destroy()
 end
 local profile=Clips.models.LavaSlime
 for _,channels in pairs(profile.clips)do for _,v in ipairs(channels.body)do check(math.abs(v[7]*v[8]*v[9]-1)<.025,'lava volume preserved while compressing')end end
 -- Imported caster articulation, seams and interruption are covered against GLB
 -- skinning fixtures in regional-caster-runtime-native.luau.

end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();Run:Stop();report.pass=#report.failures==0
print('REGIONAL_INDIVIDUAL_REVIEW_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'individual review acceptance failed')

end
do
-- Behavioral regressions found during per-species native/Blender review.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Run=game:GetService('RunService');Run:Run();task.wait(1)
local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Motion=require(Client.K0EnemyMotion);local Clips=require(Client.K0EnemyClips);local Field=require(Server.World.TrainingField)
local report={kind='DEEPWOOD_INDIVIDUAL_REVIEW_NATIVE',checks=0,failures={},species={}}
local function check(value,message)report.checks+=1;assert(value,message)end
local folder=Instance.new('Folder');folder.Name='IndividualMotionAcceptance';folder.Parent=workspace
local function sole(s,ch)
 local leg=s.legs[ch];local motor=s.joints[ch];local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
 local cf=body*motor.C0*motor.Transform*motor.C1:Inverse();local bottom=math.huge
 for _,v in ipairs(leg.points)do bottom=math.min(bottom,cf:PointToWorldSpace(v).Y)end
 return bottom
end
local ok,err=xpcall(function()
 for kind,profile in pairs(Clips.models)do
  local m=Field.makeEnemy(folder,kind,10000,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m));local root=m.HumanoidRootPart;local original=root.CFrame;local hp=m.Humanoid.Health
  local row={maxStoppedFootLift=0};report.species[kind]=row
  -- Enter attacks/stuns with either leg mid-swing; the previous gait must not leak into the pose.
  for _,phase in ipairs({.15,.35,.65,.85})do
   for _,state in ipairs({'Windup','Active','Recovery','Stunned','Exposed'})do
    s.phase=phase;s.move=1;m:SetAttribute('K0EnemyState',state)
    m:SetAttribute('K0EnemyAttackClock','1|1000|1|0.2|0.8|0');m:SetAttribute('K0EnemyStunUntil',state=='Stunned'and 2000 or nil)
    Motion.step(s,1/60,1001)
    for ch,leg in pairs(s.legs)do
     local gap=sole(s,ch)-leg.bottom;row.maxStoppedFootLift=math.max(row.maxStoppedFootLift,math.abs(gap))
     check(math.abs(gap)<.002,kind..' '..state..' plants both feet regardless of old gait phase')
    end
   end
  end
  m:SetAttribute('K0EnemyStunUntil',nil)
  for _,clip in ipairs({'Attack','AttackAlt','Heavy','HeavyAlt'})do
   local poses={}
   for _,hz in ipairs({30,60,144})do
    local q=assert(Motion.bind(m));m:SetAttribute('K0EnemyState','Windup')
    m:SetAttribute('K0EnemyAttackClock',(clip:find('Alt')and'2'or'1')..'|3000|1|0.2|0.8|'..(clip:find('Heavy')and'1'or'0'))
    Motion.step(q,1/hz,3001);table.insert(poses,q.pose)
    local hit=Motion.sample(kind,clip,.62)
    for _,ch in ipairs(Clips.channels)do for i,v in ipairs(hit[ch])do check(math.abs(q.pose[ch][i]-v)<.001,kind..' exact contact at '..hz..'Hz')end end
    check(root.CFrame==original and m.Humanoid.Health==hp,'pose cannot change server root/health')
    Motion.unbind(q)
   end
  end
  if profile.hasLegs then
   local p=Motion.sample(kind,'Walk',.2);local guard=Motion.sample(kind,'Idle',0).weapon[1]
   local opposite=kind=='Warlord'and p.leftLeg[1]or p.rightLeg[1]
   check((p.weapon[1]-guard)*opposite>0,kind..' anatomical arm counter-swings opposite its own leg')
   check(p.rightLeg[1]*p.leftLeg[1]<0,kind..' legs alternate rather than march together')
   m:SetAttribute('K0EnemyState','Chase');m:SetAttribute('K0EnemyAttackClock',nil)
   s.phase=0;s.move=1;s.position=root.Position
   local leg=s.legs.rightLeg;local point=Vector3.zero;local minY=math.huge
   for _,v in ipairs(leg.points)do point+=v;minY=math.min(minY,v.Y)end
   point=point/#leg.points;point=Vector3.new(point.X,minY,point.Z)
   local low,high=math.huge,-math.huge;local cycle=profile.stride*s.height/6;local motor=s.joints.rightLeg
   for frame=1,120 do
    local t=frame/120;root.CFrame=original*CFrame.new(0,0,-profile.stride*s.height*t)
    Motion.step(s,cycle/120,4000+cycle*t)
    if t>=.125 and t<=.5 then
     local body=s.joint.C0*s.joint.Transform*s.joint.C1:Inverse()
     local solePoint=(root.CFrame*body*motor.C0*motor.Transform*motor.C1:Inverse()):PointToWorldSpace(point)
     low=math.min(low,solePoint.Z);high=math.max(high,solePoint.Z)
    end
   end
   row.stanceSlipHeightFraction=(high-low)/s.height
   check(row.stanceSlipHeightFraction<.03,kind..' planted foot drift stays below 3% of body height at 6 studs/s')
   root.CFrame=original

  end
  Motion.unbind(s);m:Destroy()
 end
 local frozen=require(Client.FrozenValeClips);check(frozen.models.IceWolf.reviewedGait,'reviewed quadruped gait is shared with Frozen Vale')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();Run:Stop();report.pass=#report.failures==0
print('DEEPWOOD_INDIVIDUAL_REVIEW_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'individual review acceptance failed')

end
do
-- Late container and partial atomic-rig arrival, stream-out/in, no test hook.
assert(game.PlaceId==0,'Local fixture required')
local Run=game:GetService('RunService');local started=not Run:IsRunning();if started then Run:Run();task.wait(1)end
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Visual=require(Client.K0EnemyVisual);Visual.start()
local Field=require(game.ServerScriptService.Server.World.TrainingField)
local result={kind='ENEMY_STREAMING_PRESENTATION_NATIVE',checks=0,failures={}}
local function check(v,m)result.checks+=1;assert(v,m)end
local field=Instance.new('Model');field.Name='DeepwoodK0';field.Parent=workspace
local source=Instance.new('Folder');source.Parent=workspace
local camera=workspace.CurrentCamera;local cameraFrame=camera and camera.CFrame
if camera then camera.CFrame=CFrame.new(10000,15,10012)end
local ok,err=xpcall(function()
 local template=Field.makeEnemy(source,'Goblin',10000,10000,1,1);template.HumanoidRootPart.Anchored=true
 for pass=1,2 do
  local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=field
  local model=Instance.new('Model');model.Name='LateGoblin';model:SetAttribute('EnemyKind','Goblin');model:SetAttribute('TdMonsterTargetHeight',5);model.Parent=enemies
  task.wait(.1) -- First bind happens before any parts exist.
  for _,o in ipairs(template:GetChildren())do o.Parent=model end
  model.PrimaryPart=model.HumanoidRootPart;model:SetAttribute('K0EnemyStunUntil',workspace:GetServerTimeNow()+5);model:SetAttribute('K0EnemyStunClass','knight');model:SetAttribute('K0EnemyState','Stunned')
  task.wait(.25)
  check(model:FindFirstChild('ControlStunFX')~=nil,'late rig gets control effect after initial empty arrival '..pass)
  local count=0;for _,o in ipairs(model.HumanoidRootPart:GetChildren())do if o.Name:match('^StunOrbit')then count+=1 end end
  check(count==3,'streamed rig gets exactly one three-star cue')
  check(model.HumanoidRootPart.RootJoint.Transform~=CFrame.identity,'late rig gets authored motion without manual rebinding')
  -- RenderStepped does not run in a zero-player Run fixture, so countdown UI
  -- is checked in Client QA. Heartbeat/PreSimulation observers are real here.
  enemies.Parent=nil;task.wait(.15)
  check(not model:FindFirstChild('ControlStunFX'),'stream-out clears persistent effects')
  count=0;for _,o in ipairs(model.HumanoidRootPart:GetChildren())do if o.Name:match('^StunOrbit')then count+=1 end end
  check(count==0,'stream-out removes all orbit attachments')
  for _,o in ipairs(model:GetChildren())do o.Parent=template end
  enemies:Destroy()
 end
end,debug.traceback)
if not ok then table.insert(result.failures,tostring(err))end
source:Destroy();field:Destroy();if started then Run:Stop()end
if camera and cameraFrame then camera.CFrame=cameraFrame end
result.pass=#result.failures==0;print('ENEMY_STREAMING_PRESENTATION_NATIVE '..game.HttpService:JSONEncode(result));assert(result.pass,'Late streaming presentation failed')

end
do
local Run=game:GetService('RunService')
local report={kind='BATTLE_BOOTSTRAP_NATIVE',checks=0,failures={},coverage='Native battle-role startup; no real Player admission or published teleport'}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,e=xpcall(function()
 check(game.ServerStorage.ServerRole.Value=='Battle','battle artifact selects battle role')
 Run:Run();task.wait(3)
 check(workspace:GetAttribute('TLTServerRole')=='Battle','battle bootstrap active')
 check(not workspace:FindFirstChild('DawnspireLobbyPrototype'),'battle does not construct public lobby')
 check(workspace:FindFirstChild('DeepwoodCampaign')~=nil,'battle builds campaign')
 for _,name in ipairs({'K0HeroRequest','InventoryRequest','ExpeditionRequest','ArmoryRequest','DeepwoodRequest'}) do check(game.ReplicatedStorage.Remotes:FindFirstChild(name)~=nil,name..' initialized') end
 check(require(game.ReplicatedStorage.Shared.ExpeditionConfig).battleCapacity==4,'four authorized participants maximum')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(e)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('BATTLE_BOOTSTRAP_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Battle bootstrap failed')

end
do
-- Run only in a newly opened, unpublished test fixture with no human players.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture only')
local RS=game.ReplicatedStorage;local Server=game.ServerScriptService.Server;local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Run=game:GetService('RunService');if not Run:IsRunning()then Run:Run();task.wait(3)end
local report={kind='LATE_EPICS_NATIVE',checks=0,models={},scope='real-engine-with-fake-account-and-player'}
local function check(v,m)report.checks+=1;assert(v,m)end
local folder=Instance.new('Folder');folder.Name='LateEpicsNativeQA';folder.Parent=workspace
local ok,err=xpcall(function()
 local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress)
 require(Server.World.TrainingField).create()
 local world=require(Server.World.CampaignWorld).create()
 check(world.lateEpicsReady and #world.lateCompanionCamps==2,'late world bootstrap and companion camps')
 for _,entry in ipairs(world.lateCompanionCamps)do check(entry.model:GetAttribute('TLTNPC')and entry.model:GetAttribute('LateEpicCamp'),'Selene appears at late safe camps without requiring recruitment')end
 local late=require(RS.Shared.LateEpicContent);local Bounds=require(RS.Shared.CampaignBounds)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.terrain};params.RespectCanCollide=true
 for id,z in pairs(late.zones)do
  local p=Vector3.new(table.unpack(z.center));local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
  check(hit and math.abs(hit.Position.Y-p.Y)<.1,'actual ground '..id);check(world.spawns[id]~=nil,'checkpoint '..id)
 end
 for _,edge in ipairs(late.edges)do
  local a,b=Bounds.ends(edge);a,b=Vector3.new(table.unpack(a)),Vector3.new(table.unpack(b))
  for i=0,10 do local p=a:Lerp(b,i/10);local hit=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-8,0),params)
   check(hit and math.abs(hit.Position.Y-p.Y)<.3,'continuous trail and authoritative height '..edge[1]..':'..i)
  end
 end
 local Field=require(Server.World.TrainingField);local Motion=require(Client.K0EnemyMotion);local profiles=require(RS.Shared.LateEpicCombat).profiles
 for kind in pairs(profiles)do
  local m=Field.makeEnemy(folder,kind,10000+report.checks*2,10000,1,1);m.HumanoidRootPart.Anchored=true
  local s=assert(Motion.bind(m),kind..' motion binding');local cf=m.HumanoidRootPart.CFrame;local hp=m.Humanoid.Health
  for _,hz in ipairs({30,60,144})do
   m:SetAttribute('K0EnemyState','Chase');Motion.step(s,1/hz,100)
   for sequence=1,4 do
    m:SetAttribute('K0EnemyState','Windup');m:SetAttribute('K0EnemyAttackClock',sequence..'|500|1.2|.18|1.5|'..(sequence>=3 and '1'or '0'))
    for _,age in ipairs({.1,.9,1.2,1.35,2.5})do Motion.step(s,1/hz,500+age);check(m.Humanoid.Health==hp and m.HumanoidRootPart.CFrame==cf,'motion never owns roots or damage')end
   end
  end
  check(m:FindFirstChild('TdMonsterVisual')~=nil,kind..' actual visual')
  for _,p in ipairs(m.TdMonsterVisual:GetDescendants())do if p:IsA('BasePart')then check(not p.CanCollide and not p.CanQuery and p.Massless,'cosmetic geometry does not block combat')end end
  local entry={kind=kind,template=m:GetAttribute('TdMonsterTemplate'),prototype=m:GetAttribute('GloamwoodPrototypeVersion')~=nil,parts=#m.TdMonsterVisual:GetChildren()}
  if entry.prototype then check(s.gloam and #s.gloam>0,'prototype appendage animation bound')else check(m.TdMonsterVisual.Body:IsA('MeshPart'),'HG uses TD MeshParts')end
  table.insert(report.models,entry);Motion.unbind(s);m:Destroy();task.wait()
 end
 local journal=P.new()
 for n=1,21 do local c=C.mainChapters[n];for _,g in ipairs(c.goals)do if not g.optional then
  if g.activity and g.activity.steps then for _,step in ipairs(g.activity.steps)do journal=assert(P.apply(journal,c.id,g.id,step.choices and step.choices[1].id,step.id))end
  else journal=assert(P.apply(journal,c.id,g.id,g.choice and 'sanctuary'))end
 end end end
 local Rules=require(Server.Inventory.InventoryRules);local Catalog=require(RS.Shared.ItemCatalog)
 local profile=assert(Rules.addHero(Rules.new(911),'qa','knight',Catalog));profile.heroes.qa.deepwood=journal
 local original=Server.Story.DeepwoodService;local copy=original:Clone();copy.Name='LateEpicServiceQA'
 local source=copy.Source;local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true))
 copy.Source=source:sub(1,first-1)..'local function publish(player,message)player.message=message end\n'..source:sub(last);copy.Parent=original.Parent
 local story=require(copy);local combat=table.clone(require(Server.Combat.CombatService));if not RS:FindFirstChild('Remotes')then combat.start(workspace.DeepwoodK0.Enemies,function()return nil end)end;local faults={'SaveUnknown','Busy'};local retries=0;local xp,gold=0,0;local activeMission
 local character=Instance.new('Model');character.Parent=folder
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=character;character.PrimaryPart=root
 local human=Instance.new('Humanoid');human.MaxHealth=1000;human.Health=1000;human.Parent=character
 local player={UserId=911,Parent=game.Players,Character=character,GetAttribute=function()return 'Tutorial'end}
 local inventory={storyState=function()return P.copy(profile.heroes.qa.deepwood)end,expedition=function()return activeMission end,
  storyEvent=function(_,hero,c,g,choice,step)
   if c=='GW-01' and g=='maeve'then retries+=1;local fault=table.remove(faults,1);if fault then return fault end end
   local nextState,reason=Rules.story(profile,hero,c,g,choice,Catalog,step);if nextState then profile=nextState end;return reason
  end,supportState=function()return {active=true,credits=0}end,activateSupport=function()end,
  awardXP=function(_,_,amount,_,coins)xp+=amount;gold+=coins or 0 end}
 story.start({world=world,enemies=workspace.DeepwoodK0.Enemies,inventory=inventory,heroSession={getActiveHero=function()return {heroId='qa',training=false}end,getCombatContext=function()return {heroId='qa'}end},combat=combat})
 check(story.destination(player,'qa')==world.spawns['GW-01'],'existing EC complete save resumes at Gloamwood')
 root.Position=world.lateCompanionCamps[2].model.PrimaryPart.Position;check(not story.supportCampAccess(player,'qa'),'late camp cannot bypass story gate')
 local function alive(key)
  local out={};for _,m in ipairs(workspace.DeepwoodK0.Enemies:GetChildren())do if m:GetAttribute('DeepwoodEncounter')==key..':legacy' and m.Humanoid.Health>0 then table.insert(out,m)end end;return out
 end
 local function drain(c,g)
  local key=c.id..':'..g.id
  for _=1,100 do
   local models=alive(key);if #models==0 then break end
   check(#models<=require(RS.Shared.DeepwoodEncounterBalance).packSize(c,g),'bounded active pack')
   for _,m in ipairs(models)do
    local h=m.Humanoid;local max=h.MaxHealth;local kind=m:GetAttribute('EnemyKind')
    if kind=='Veyr'then
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.7)<.0001 and m:GetAttribute('StoryShield'),'Veyr clamps lethal hit at shield stage')
     check(story.bossDamage(m,max)==0,'shield stops damage')
     root.Position+=Vector3.new(500,0,0);check(not story.breakPillar(player,key..':legacy',1),'distant player cannot break shield link')
     for index=1,2 do root.Position=m.HumanoidRootPart.Position+Vector3.new(index==1 and -22 or 22,0,0);check(story.breakPillar(player,key..':legacy',index),'solo breaks each link')end
     check(not story.breakPillar(player,key..':legacy',2),'duplicate link interaction ignored')
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.35)<.0001,'Veyr final phase preserves boundary')
    elseif kind=='WidowQueen'then
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.65)<.0001,'queen first phase boundary')
     h:TakeDamage(story.bossDamage(m,max*5));check(math.abs(h.Health/max-.30)<.0001,'queen second phase boundary')
    end
    h:TakeDamage(story.bossDamage(m,max*5));task.wait(.003);story.defeated(m);story.defeated(m)
   end
   task.wait(.01)
  end
  check(#alive(key)==0,'finite battle ends');task.wait(.1)
 end
 for n=22,35 do
  local c=C.mainChapters[n]
  for _,g in ipairs(c.goals)do
   local node=assert(world.nodes[c.id..':'..g.id]);check(node.prompt~=nil,'actual objective anchor')
   root.Position=node.part.Position+Vector3.new(500,0,0);story.interact(player,c.id,g.id);check(not inventory.storyState().flags[c.id..':'..g.id],'distant interaction rejected')
   root.Position=node.part.Position
   if #g.enemies>0 then story.interact(player,c.id,g.id);drain(c,g)
   elseif g.activity.mode=='escort'then
    story.interact(player,c.id,g.id)
    for _=1,350 do
     if inventory.storyState().flags[c.id..':'..g.id]then break end
     local actor;for _,m in ipairs(world.folder:GetChildren())do if m:IsA('Model')and m:GetAttribute('NPCPrivateOwnerUserId')==911 then actor=m;break end end
     check(actor and actor.PrimaryPart,'personal Tali rescue actor');root.Position=actor.PrimaryPart.Position+Vector3.new(0,3,0);story.stepActivities(.2);task.wait(.001)
    end
   elseif g.activity.mode=='dialogue'then story.interact(player,c.id,g.id)
   else story.interactStep(player,c.id,g.id,g.activity.steps[1].id)end
   if n==22 and g.id=='maeve'then
    check(story.hasPendingEvents(player)and not inventory.storyState().flags['GW-01:maeve'],'save failure cannot advance story')
    local deadline=os.clock()+5;repeat task.wait(.05)until not story.hasPendingEvents(player)or os.clock()>deadline
    check(retries==3 and #faults==0,'same event retries unknown/busy save')
   else task.wait(.1)end
   check(inventory.storyState().flags[c.id..':'..g.id],'server saves '..c.id..':'..g.id)
  end
  check(inventory.storyState().main==n and P.validate(inventory.storyState()),'checkpoint valid after chapter')
  if n==28 then check(story.destination(player,'qa')==world.spawns['HG-01'],'forest completion resumes at final epic')end
 end
 check(story.destination(player,'qa')==world.spawns['HG-02'],'complete campaign resumes at final safe hub')
 check(inventory.storyState().coins==16570,'story Gold awarded once')
 check(xp>0 and gold>0,'battle rewards use server kills')
 activeMission={missionId='HG-07',runId='qa-resume'}
 -- A completed campaign still uses the safe hub; real mission entry handles active run context.
 check(inventory.storyState().flags['HG-07:crownheart']and inventory.storyState().flags['HG-07:portal'],'final recovery and portal closure saved')
 local registry=world.folder.NPCActors
 local maeves=0;for _,actor in ipairs(registry:GetChildren())do if actor:GetAttribute('NPCActorScope')and actor:GetAttribute('NPCActorIdentity')then
  check(actor.PrimaryPart~=nil,'late named actor at authored scene anchor');if actor.Name=='Maeve'then maeves+=1 end
 end end
 report.scopedMaeves=maeves;report.finalMain=inventory.storyState().main;report.finalGold=inventory.storyState().coins
 copy:Destroy()
end,debug.traceback)
report.ok=ok;report.error=not ok and err or nil
folder:Destroy()
print(game.HttpService:JSONEncode(report))
assert(ok,err)
return report

end
