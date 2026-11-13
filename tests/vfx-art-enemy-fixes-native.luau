-- ART revisions: real engine geometry, warning pixel cues, ring safety and cleanup.
assert(game.PlaceId==0 and game.GameId==0 and #game.Players:GetPlayers()==0,'Local fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local V=require(Client.EnemySpellVFX);local Art=require(Client.EnemySpellArt)
local Effects=require(Client.EnemyPatternEffects);local Patterns=require(game.ReplicatedStorage.Shared.EnemyPatterns)
local report={checks=0,failures={}}
local function check(value,message)report.checks+=1;assert(value,message)end
local original=game.HttpService:JSONEncode(Patterns.profiles)
local camera=workspace.CurrentCamera;local oldCamera=camera.CFrame;camera.CFrame=CFrame.new(0,18,25)
local world=Instance.new('Folder');world.Name='DeepwoodK0';world.Parent=workspace
local floor=Instance.new('Part');floor.Name='Ground';floor.Anchored=true;floor.Size=Vector3.new(160,.5,160);floor.Position=Vector3.new(0,-.25,0);floor.Parent=world
local actor=Instance.new('Model');actor.Name='EnemyArtQA';actor.Parent=world
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(1.4,2,1);root.Position=Vector3.new(0,2,0);root.Anchored=true;root.Parent=actor
local human=Instance.new('Humanoid');human.Parent=actor
local function countNamed(model,name)
 local count=0;for _,v in ipairs(model:GetDescendants())do if v.Name==name then count+=1 end end;return count
end
local function clean()
 V.clear();local a,b=V.count();local c,d,e,f=Art.count();check(a+b+c+d+e+f==0,'all independent VFX reservations returned')
end
local function create(kind,index,stage)
 clean();local d=Patterns.get(kind).attacks[index or 1];local now=workspace:GetServerTimeNow()
 local r=stage=='impact'and V.impact(d,Vector3.new(0,2,0),now,nil,nil,Vector3.zAxis)or V.projectile(d,nil,nil,Vector3.new(0,3,0),-Vector3.zAxis,now)
 check(r~=nil and #r.parts<=32,'bounded production record '..d.id);return r,now
end
local ok,err=xpcall(function()
 -- Actual definitions, both blockability states, all six authored shapes.
 local samples={{'KingShaman',1},{'Veyr',4},{'Goblin',1},{'Ghoul',2},{'Orc',1},{'IceWolf',2},{'Slime',1},{'Shaman',2},{'Veyr',3},{'KingShaman',4},{'CalderaTitan',2},{'LavaSlime',2}}
 for index,row in ipairs(samples)do
  local d=Patterns.get(row[1]).attacks[row[2]];local now=workspace:GetServerTimeNow();local seq=31000+index
  actor:SetAttribute('EnemyKind',row[1]);actor:SetAttribute('K0AttackSeq',seq);actor:SetAttribute('K0PatternId',d.id)
  actor:SetAttribute('K0EnemyAttackClock',string.format('%d|%.6f|%.6f|%.6f|%.6f|%d',seq,now,d.windup,d.active,d.recovery,d.heavy and 1 or 0))
  actor:SetAttribute('K0PatternOrigin',Vector3.new(0,2,0));actor:SetAttribute('K0PatternDirection',-Vector3.zAxis);actor:SetAttribute('K0PatternAim',Vector3.new(0,2,-8))
  Effects.observe(actor,now);Effects.render(now+d.windup*.8)
  local warning=assert(workspace:FindFirstChild('EnemyPatternWarning'));local edges=0;local marks=0
  for _,part in ipairs(warning:GetDescendants())do if part:IsA('BasePart')then
   edges+=1;check(part.Name=='WarningEdge','non-color cues add no world geometry')
   check(part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery,'warning remains cosmetic')
   local pattern=part:FindFirstChild('UnblockablePattern')
   if pattern then
    marks+=1;check(not d.blockable,'blockable warnings keep a plain boundary '..d.id)
    check(pattern:IsA('BillboardGui')and pattern.Adornee==part and not pattern.AlwaysOnTop,'pixel cue remains occluded and attached to its original edge')
    check(pattern.StudsOffsetWorldSpace==Vector3.zero and pattern.Size==UDim2.fromOffset(20,20)and pattern.MaxDistance==100,'cue has a fixed readable pixel size and no world displacement')
    check(#pattern:GetChildren()==2,'cue has two parallel slashes')
    for _,dash in ipairs(pattern:GetChildren())do
     check(dash.Size==UDim2.fromOffset(3,16)and dash.Rotation==32 and dash:FindFirstChildOfClass('UIStroke')~=nil,'slashes have readable thickness and a contrast outline')
    end
    if d.shape=='ring'then
     local q=part.Position;check(Vector3.new(q.X,0,q.Z).Magnitude>d.innerRadius+1,'ring cues attach only to outer boundary, never the safe-hole contour')
    end
   end
  end end
  check(edges>0,'all shape warnings remain present')
  check(marks==(d.blockable and 0 or math.min(4,edges)),'non-color markers are bounded to four per warning '..d.id)
  Effects.receive({kind='cancel',model=actor,sequence=seq});check(not workspace:FindFirstChild('EnemyPatternWarning'),'cancel removes cue and original boundary together')
 end
 local styles={};local impSize,bossSize
 for _,row in ipairs({{'Imp','EmberHeart'},{'MagmaImp','ForkedFlame'},{'VolcanoShaman','CinderFanBlade'},{'KingVolcanoShaman','VentFlame'},{'InfernoOverlord','InfernoCrown'}})do
  local r=create(row[1]);check(r.model:FindFirstChild(row[2],true)~=nil,'species has a primary flame shape '..row[1])
  check(r.model:FindFirstChild('EmberHeart',true):IsA('WedgePart'),'selected flames do not share an opaque round head')
  local style=r.model:GetAttribute('SpellStyle');check(not styles[style],'distinct fire presentation style '..row[1]);styles[style]=true
  if row[1]=='Imp'then impSize=r.art.flare.size elseif row[1]=='InfernoOverlord'then bossSize=r.art.flare.size end
 end
 check(bossSize>impSize,'boss flame has a stronger local silhouette hierarchy without global lighting changes')
 local snow=create('KingIceBear');check(countNamed(snow.model,'SnowBranch')==6,'snow has forked crystal branches')
 local sand=create('Mummy');check(countNamed(sand.model,'SandRay')==0 and countNamed(sand.model,'SandGrain')==5,'sand is a cluster of grains, not a recolored six-ray star')
 for _,v in ipairs(sand.parts)do if v.part.Name=='SandGrain'then check(v.part:IsA('WedgePart')and v.part.Material==Enum.Material.Sand,'sand carries a rough grain material')end end
 clean()
 local ringCount=0
 for _,profile in pairs(Patterns.profiles)do for _,d in ipairs(profile.attacks)do if d.shape=='ring'then
  ringCount+=1;local now=workspace:GetServerTimeNow();local r=assert(V.pulse(d,Vector3.zero,-Vector3.zAxis,now,nil,nil))
  check(#r.parts<=32 and countNamed(r.model,'HazardBandCrack')==8,'ring gains bounded interior hazard accents '..d.id)
  for _,age in ipairs({0,.12,.35,.6})do
   V.step(now+age)
   for _,piece in ipairs(r.parts)do
    local p=piece.part
    for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
     local q=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5);local radius=Vector3.new(q.X,0,q.Z).Magnitude
     check(radius>d.innerRadius,'whole ring geometry stays outside the safe hole '..d.id)
     if p.Name=='HazardBandCrack'then check(radius<=d.radius+.01,'new hazard-band geometry stays inside the authored outer boundary '..d.id)end
    end end end
   end
   for _,line in ipairs(r.art.lines)do
    local a,b=line.a.WorldPosition,line.b.WorldPosition
    local c=a+line.a.WorldAxis*line.beam.CurveSize0;local e=b-line.b.WorldAxis*line.beam.CurveSize1
    for sample=0,8 do local t=sample/8;local q=a*(1-t)^3+c*3*(1-t)^2*t+e*3*(1-t)*t*t+b*t^3
     check(Vector3.new(q.X,0,q.Z).Magnitude-line.beam.Width0*.5>d.innerRadius,'curved ribbon including its width never enters the safe hole '..d.id)
    end
   end
   for _,emitter in ipairs(r.art.emitters)do
    local e=emitter.e;local maxSize=0;for _,key in ipairs(e.Size.Keypoints)do maxSize=math.max(maxSize,key.Value)end
    local angle=math.min(90,e.SpreadAngle.X+e.SpreadAngle.Y)
    local spread=e.Speed.Max*e.Lifetime.Max*math.sin(math.rad(angle))+maxSize*.5
    check(Vector3.new(emitter.offset.X,0,emitter.offset.Z).Magnitude-spread>d.innerRadius,'bounded particle cone stays outside the safe hole '..d.id)
   end
  end
  clean()
 end end end
 check(ringCount==12,'every authored ring reviewed')
 for _,row in ipairs({{'Shaman','ArcaneContactRune'},{'Lich','SoulContactAscent'},{'Veyr','ShadowContactInfall'},{'Silkweaver','WebContactThread'}})do
  local r,now=create(row[1],1,'impact');check(r.model:FindFirstChild(row[2],true)~=nil,'contact has a family-specific flow '..row[1])
  check(not r.model:FindFirstChild('ExpandingShockwave',true),'selected contacts replace the shared circular shockwave')
  if row[1]=='Lich'then local p=r.model:FindFirstChild('SoulWisp',true);local y=p.Position.Y;V.step(now+.16);check(p.Position.Y>y+.1,'soul contact rises')
  elseif row[1]=='Veyr'then local p=r.model:FindFirstChild('RiftFragment',true);local radius=(p.Position-r.position).Magnitude;V.step(now+.16);check((p.Position-r.position).Magnitude<radius,'shadow contact converges inward')
  elseif row[1]=='Silkweaver'then local p=r.model:FindFirstChild('ImpactSilk',true);local length=p.Size.Z;V.step(now+.18);check(p.Size.Z>length and p.Size.X<.05,'web contact extends thin threads rather than throwing generic cubes')end
 end
 clean()
 for i=1,100 do
  local d=Patterns.get(i%2==0 and 'InfernoOverlord'or 'KingIceGolem').attacks[4]
  V.pulse(d,Vector3.zero,-Vector3.zAxis,workspace:GetServerTimeNow(),nil,nil)
 end
 local records,parts=V.count();local beams,particles,lights,flares=Art.count()
 check(records<=64 and parts<=640 and beams<=192 and particles<=480 and lights<=6 and flares<=32,'mixed revised effects preserve all original global budgets')
 clean();check(game.HttpService:JSONEncode(Patterns.profiles)==original,'all authoritative attack definitions remain unchanged')
end,debug.traceback)
V.clear();actor:Destroy();world:Destroy();camera.CFrame=oldCamera
if not ok then report.failures[#report.failures+1]=err end
report.pass=ok;print('VFX_ART_ENEMY_FIXES_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
