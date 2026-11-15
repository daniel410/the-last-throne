assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'Isolated local fixture required')
local RS=game:GetService('ReplicatedStorage')
local P=require(RS.Shared.EnemyPatterns)
local Profiles=require(RS.Shared.EnemyCombatProfiles)
local R=require(game.ServerScriptService.Server.Combat.EnemyPatternRuntime)
local Snapshot=require(game.StarterPlayer.StarterPlayerScripts.Client.EnemyPatternDefinition)
local folder=Instance.new('Folder');folder.Name='EnemyCombatQA';folder.Parent=workspace
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local function actor(name,position)
 local model=Instance.new('Model');model.Name=name
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Anchored=true;root.Position=position;root.Parent=model
 model.PrimaryPart=root;model.Parent=folder
 return {model=model,character=model,root=root,config={attacks={{damage=121}},leashRange=65},spawnPosition=position,attackSeq=0}
end
local e=actor('Enemy',Vector3.new(20000,4,20000))
local t=actor('Hero',Vector3.new(20000,4,19996))
local hits,events={},{}
local allowed=true
local function emit(m)table.insert(events,m)end
local ctx={emit=emit,hit=function(_,_,a)table.insert(hits,a)end,valid=function()return allowed end,
 raycast=function()return nil end,floor=function(pos)return {Position=Vector3.new(pos.X,1,pos.Z),Normal=Vector3.yAxis}end}
local casts=0
for kind,profile in pairs(P.profiles)do
 e.kind=kind;e.model:SetAttribute('EnemyKind',kind)
 for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  for _,base in ipairs(profile.attacks)do
   local d=Profiles.resolve(kind,base,mode,.4)
   e.root.Position=e.spawnPosition;t.root.Position=e.spawnPosition+Vector3.new(0,0,-4);hits={};events={}
   R.begin(e,t,d,0,emit);casts+=1
   check(events[1].definition.id==d.id and events[1].definition.active==d.active,'event uses final definition')
   check(Snapshot.get(e.model).speed==d.speed and Snapshot.get(e.model).pulses==d.pulses,'streaming snapshot matches server')
   local seen,total={},0
   for frame=0,math.ceil((d.windup+d.active)*60)do R.step(e,frame/60,{t},ctx)end
   for _,hit in ipairs(hits)do
    check(not seen[hit.pulse],'one hit per pulse');seen[hit.pulse]=true;total+=hit.definition.damage
   end
   check(total<=121,'entire cast stays within exact damage budget')
   check(#e.attack.projectiles<=9,'finite projectiles')
   R.cancel(e,emit);e.attack=nil
   check(e.model:GetAttribute('K0PatternDefinition')==nil,'cancel clears resolved snapshot')
  end
 end
end
-- Direction and target points never home after the warning has committed.
local fire=Profiles.resolve('VolcanoShaman',P.get('VolcanoShaman').attacks[2],'Hell',1)
e.root.Position=e.spawnPosition;t.root.Position=e.spawnPosition+Vector3.new(0,0,-4);hits={};events={}
local a=R.begin(e,t,fire,0,emit);local aim=a.aim
t.root.Position+=Vector3.new(15,0,0)
for f=0,240 do R.step(e,f/60,{t},ctx)end
check(a.aim==aim and #hits==0,'persistent fire keeps warned location and can be escaped')
-- Every persistent tick resolves immunity afresh; late frames do not replay contact.
t.root.Position=aim;hits={};a=R.begin(e,t,fire,0,emit)
R.step(e,fire.windup,{t},ctx);allowed=false
R.step(e,fire.windup+fire.interval,{t},ctx)
check(#hits==1,'run invalidation rejects later tick');allowed=true
hits={};a=R.begin(e,t,fire,0,emit);R.step(e,10,{t},ctx)
check(#hits==0,'lag does not replay old contact')
local dash
for _,d in ipairs(P.get('MagmaWorm').attacks)do if d.motion=='dash'then dash=Profiles.resolve('MagmaWorm',d,'Hard',1)end end
check(dash~=nil,'dash fixture exists')
e.root.Position=e.spawnPosition;R.begin(e,t,dash,0,emit)
R.step(e,dash.windup+.2,{t},ctx)
check(e.root.Position==e.spawnPosition,'delayed dash cannot teleport across unsampled space')
local function dashAt(offset)
 e.root.Position=e.spawnPosition;t.root.Position=e.spawnPosition+Vector3.new(0,0,-4);hits={}
 R.begin(e,t,dash,0,emit)
 t.root.Position=e.spawnPosition+offset
 for f=0,math.ceil((dash.windup+dash.active)*120)do R.step(e,f/120,{t},ctx)end
 return #hits
end
check(dashAt(Vector3.new(dash.width+.5,0,-4))==0,'dash cannot damage outside warned side edge')
check(dashAt(Vector3.new(0,0,-dash.dashDistance-.5))==0,'dash cannot damage past warned endpoint')
check(dashAt(Vector3.new(0,0,-4))==1,'swept dash retains contact inside warning')
e.root.Position=e.spawnPosition;t.root.Position=aim;hits={}
R.begin(e,t,fire,0,emit)
for f=0,math.ceil((fire.windup+fire.active)*60)do R.step(e,f/60,{t},ctx)end
local budget=0;for _,hit in ipairs(hits)do budget+=hit.definition.damage end
check(#hits==fire.pulses and budget==121,'stationary target receives exactly one raw damage budget')
R.cancel(e,emit);e.attack=nil;folder:Destroy()
print('ENEMY_COMBAT_NATIVE '..checks..' checks PASS; '..casts..' resolved casts')
