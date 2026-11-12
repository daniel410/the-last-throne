assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated spell fixture only')
local RS=game.ReplicatedStorage
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Patterns=require(RS.Shared.EnemyPatterns)
local Profiles=require(RS.Shared.EnemySpellProfiles)
local V=require(Client.EnemySpellVFX)
local Pixel=require(Client.PixelFX)
local checks,kinds,attacks,projectiles=0,0,0,0
local function check(v,m)checks+=1;assert(v,m)end
local owner=Instance.new('Model');owner.Name='SpellCasterQA';owner.Parent=workspace
local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=owner
local h=Instance.new('Humanoid');h.Parent=owner
local at=workspace:GetServerTimeNow();local direction=Vector3.new(0,0,-1)
local signatures={};local seq=1
local function inspect(r,stage,d)
 check(r~=nil,'created '..stage..' '..d.id)
 check(#r.parts>0 and #r.parts<=32,'bounded nonempty motif '..d.id)
 for _,v in ipairs(r.parts)do
  local p=v.part
  check(p.Anchored and not p.CanCollide and not p.CanTouch and not p.CanQuery,'cosmetic geometry '..d.id)
  for _,n in ipairs({p.CFrame:GetComponents()})do check(n==n and math.abs(n)<10000,'finite transform '..d.id)end
 end
 check(r.model:GetAttribute('SpellId')==d.id,'spell identity '..d.id)
end
for kind,profile in pairs(Patterns.profiles)do
 kinds+=1
 local p=Profiles.get(profile.attacks[1]);check(p~=nil,'explicit species profile '..kind)
 local signature=p.motif..'/'..p.ornament
 check(not signatures[signature],'unique species composition '..kind);signatures[signature]=kind
 for _,d in ipairs(profile.attacks)do
  attacks+=1;seq+=1;owner:SetAttribute('K0AttackSeq',seq)
  local c=V.charge(d,owner,seq,at);inspect(c,'charge',d)
  for _,u in ipairs({0,.3,.8,1})do V.pose(c,CFrame.new(0,3,0)*CFrame.Angles(0,u,0),u,.3+u*.65)end
  V.destroy(c)
  if d.shape=='projectile'then
   projectiles+=1
   local r=V.projectile(d,owner,seq,Vector3.new(0,3,0),direction,at);inspect(r,'projectile',d)
   check(r.parts[1].part:FindFirstChild('SpellWake')~=nil,'projectile wake '..d.id)
   for _,age in ipairs({0,.1,.4})do
    local point=Vector3.new(0,3,0)+direction*d.speed*age
    V.pose(r,CFrame.lookAt(point,point+direction),age,1)
    check((r.position-point).Magnitude<.0001,'authoritative straight trajectory '..d.id)
   end
   V.destroy(r)
  else
   local r=V.pulse(d,Vector3.zero,direction,at,owner,seq);inspect(r,'pulse',d)
   if d.shape=='ring'then
    for _,v in ipairs(r.parts)do local p=v.part.Position;check(Vector3.new(p.X,0,p.Z).Magnitude>d.innerRadius+.2,'ring safe center remains clear '..d.id)end
   end
   V.step(at+.2);V.destroy(r)
  end
  local r=V.impact(d,Vector3.new(0,2,0),at,owner,seq);inspect(r,'impact',d)
  V.step(at+1);check(V.count()==0,'all phases expire '..d.id);Pixel.clear()
 end
end
local d=Patterns.get('QueenIceElf').attacks[2]
owner:SetAttribute('K0AttackSeq',seq)
for i=1,100 do V.projectile(d,owner,seq,Vector3.new(i,3,0),direction,at)end
local count,parts=V.count();check(count<=64 and parts<=640,'global geometry budget')
V.cancel(owner,seq);check(V.count()==0,'cancel removes every phase')
for i=1,100 do V.impact(d,Vector3.zero,at,owner,seq)end
local important=V.projectile(d,owner,seq,Vector3.zero,direction,at)
check(important~=nil,'traveling spell takes priority over optional impacts')
V.clear();Pixel.clear()
V.charge(d,owner,seq,at);owner:SetAttribute('K0AttackSeq',seq+1);V.step(at+.1);check(V.count()==0,'new sequence removes stale charge')
owner:SetAttribute('K0AttackSeq',seq)
V.projectile(d,owner,seq,Vector3.zero,direction,at);h.Health=0;V.step(at+.1);check(V.count()==0,'death removes projectile')
h.Health=100
V.pulse(d,Vector3.zero,direction,at,owner,seq);owner.Parent=nil;V.step(at+.1);check(V.count()==0,'stream out removes pulse')
owner:Destroy();V.clear();Pixel.clear()
-- Exercise the actual event router, including cancellation and late/replayed traffic.
local FX=require(Client.EnemyPatternEffects)
local caster=Instance.new('Model');caster.Name='SpellEventQA';caster.Parent=workspace
local health=Instance.new('Humanoid');health.Parent=caster
local floorWorld=Instance.new('Folder');floorWorld.Name='DeepwoodCampaign';floorWorld.Parent=workspace
local floor=Instance.new('Part');floor.Name='Ground';floor.Anchored=true;floor.Position=Vector3.new(0,-1,0);floor.Size=Vector3.new(100,2,100);floor.Parent=floorWorld
local d=Patterns.get('IceElf').attacks[1];local current=workspace:GetServerTimeNow()
caster:SetAttribute('EnemyKind','IceElf');caster:SetAttribute('K0AttackSeq',901)
local message={kind='projectile',id=d.id,model=caster,sequence=901,pulse=1,shot=1,origin=Vector3.new(0,3,0),direction=direction,at=current}
FX.receive(message);FX.receive(message)
check(V.count()==1,'duplicate projectile never doubles')
FX.render(current+.1)
check(workspace:FindFirstChild('EnemyMagicProjectile')~=nil,'router retains actual traveling motif')
FX.receive({kind='projectileEnd',model=caster,sequence=901,pulse=1,shot=1,position=Vector3.new(0,3,-5)})
check(not workspace:FindFirstChild('EnemyMagicProjectile'),'end removes travel geometry')
FX.receive(message)
check(not workspace:FindFirstChild('EnemyMagicProjectile'),'ended shot cannot resurrect')
FX.receive({kind='cancel',model=caster,sequence=901})
check(V.count()==0,'cancel clears travel and impact')
FX.receive(message);check(V.count()==0,'canceled sequence cannot recreate VFX')
caster:SetAttribute('K0AttackSeq',902)
local d=Patterns.get('KingIceGolem').attacks[4]
local pulse={kind='pulse',id=d.id,model=caster,sequence=902,pulse=1,position=Vector3.new(0,3,0),at=workspace:GetServerTimeNow()}
FX.receive(pulse);FX.receive(pulse)
check(V.count()==1,'pulse deduplicated')
V.clear();floor:Destroy();pulse.pulse=2;FX.receive(pulse)
check(V.count()==0,'streamed-out floor emits no airborne eruption')
caster:SetAttribute('K0AttackSeq',903);FX.receive(message)
check(V.count()==0,'older sequence ignored')
pulse.sequence=903;pulse.at=workspace:GetServerTimeNow()-1;FX.receive(pulse)
check(V.count()==0,'old pulse ignored')
health.Health=0;message.sequence=903;message.at=workspace:GetServerTimeNow();FX.receive(message)
check(V.count()==0,'dead caster cannot recreate projectile')
caster:Destroy();floorWorld:Destroy();V.clear();Pixel.clear()
print('MONSTER_SPELL_VFX_NATIVE '..game.HttpService:JSONEncode({checks=checks,kinds=kinds,attacks=attacks,projectiles=projectiles}))
