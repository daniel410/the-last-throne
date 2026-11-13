-- Same authority/near-socket constraints for all three common Mage spells.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)
local copies={}
local function api(source,tail)
 local m=source:Clone();m.Name='MagicDirectionQA';m.Source=m.Source:gsub('return %w+%s*$',function()return tail end);m.Parent=source.Parent;copies[#copies+1]=m;return require(m)
end
local Service=api(game.ServerScriptService.Server.Combat.CombatService,[[return {start=startSkill,clear=clearAction,shot=applyArrowShot,enemies=enemyStates,setFolder=function(f)enemyFolder=f end,spy=function(f)damageEnemy=f end}]])
local Visual=api(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual,'return {origin=weaponOrigin}')
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local folder=Instance.new('Folder');folder.Parent=workspace;Service.setFolder(folder)
local function rig()
 local c=Instance.new('Model');c.Parent=folder;local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.CanCollide=false;r.Position=Vector3.new(20000,1000,20000);r.Parent=c
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;return c,r,h
end
local c,root,h=rig();local enemy,er,eh=rig();c:SetAttribute('K0ClassId','mage');c:SetAttribute('K0AttackSeq',9)
Service.enemies[enemy]={model=enemy,root=er,humanoid=eh,id=1};local hits=0;Service.spy(function()hits+=1 end)
local checks=0;local function check(v,m)checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 for index=1,3 do for _,distance in {8,32}do for _,yaw in {0,90,-90,180}do
  local d=Config.Skills.mage[index];er.Position=root.Position+CFrame.Angles(0,math.rad(yaw),0).LookVector*distance;hits=0
  local state={character=c,root=root,humanoid=h,baseClassId='mage',attackSeq=9,spellSeq=0,feedbackSeq=0,
   attack={started=100,definition=d,isSkill=true,isSpell=true,direction=Vector3.new(0,0,-1),targetModel=enemy,hits={},hitCount=0,maxTargets=d.maxTargets,maxHeight=10}}
  Service.shot(state,101);local p=string.split(c:GetAttribute('K0SpellVisual'),'|')
  local first=Vector3.new(tonumber(p[2]),tonumber(p[3]),tonumber(p[4]));local last=Vector3.new(tonumber(p[5]),tonumber(p[6]),tonumber(p[7]))
  check((last-first).Unit:Dot(Vector3.new(0,0,-1))>.9999,'Mage spell cannot home sideways or behind the prepared cast')
  check(hits==(yaw==0 and 1 or 0),'Mage frontal hit remains; off-axis homing hit is removed')
  check(c:GetAttribute('K0AttackAim')=='9|0.000000|0.000000|-1.000000','Final resolved spell ray also drives owner facing')
 end end end
 for _,policy in {true,false}do for slot=1,3 do
  h.AutoRotate=policy;er.Position=root.Position+Vector3.new(0,0,-12)
  local state={character=c,root=root,humanoid=h,baseClassId='mage',attackProfile=Config.BasicAttackProfiles.mage,
   attackSeq=0,feedbackSeq=0,combo=0,mode='Idle',skillSlots={1,2,3},slotCount=3,skillReadyAt={},mana=1000,maxMana=1000}
  Service.start(state,slot,100,enemy)
  check(c:GetAttribute('K0AttackAim')~=nil,'Mage publishes facing during preparation, before its projectile exists')
  check(c:GetAttribute('K0AttackAutoRotate')==policy,'Server publishes original rotation policy including false')
  check(state.mana==1000-Config.Skills.mage[slot].manaCost,'Facing changes never alter spell mana cost')
  Service.clear(state);check(c:GetAttribute('K0AttackAim')==nil and h.AutoRotate==policy,'Cast end clears heading and restores policy')
 end end
 local model=Instance.new('Model');model:SetAttribute('WeaponClassId','mage');model.Parent=c
 local grip=Instance.new('Part');grip.Name='WeaponGrip';grip.Anchored=true;grip.Parent=model
 local tip=Instance.new('Attachment');tip.Name='WeaponTip';tip.Parent=grip
 for _,x in {-1.5,1.5}do for _,distance in {3.2,14.5,40}do for _,height in {0,.8}do
  grip.Position=root.Position+Vector3.new(x,height,-3);local endpoint=root.Position+Vector3.new(0,0,-distance)
  local first=Visual.origin(c,root.Position,endpoint,'mage');local flight=endpoint-first
  check(Vector3.new(flight.X,0,flight.Z).Unit:Dot(Vector3.new(0,0,-1))>.99999,'Staff height and small socket parallax never add a sideways magic flight component')
  check(math.abs(first.Y-tip.WorldPosition.Y)<.001,'Horizontal alignment preserves real staff launch height')
 end end end
end,debug.traceback)
for _,m in copies do m:Destroy()end;folder:Destroy()
print('MAGIC_SHOT_DIRECTION_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=checks,error=err}));assert(ok,err)
