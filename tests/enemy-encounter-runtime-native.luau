-- Execute every authored phase in native geometry, including phase-three follow-ups.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Shared=game.ReplicatedStorage.Shared
local Profiles=require(Shared.EnemyCombatProfiles)
local Patterns=require(Shared.EnemyPatterns)
local Runtime=require(game.ServerScriptService.Server.Combat.EnemyPatternRuntime)
local folder=Instance.new('Folder');folder.Name='EncounterRuntimeQA';folder.Parent=workspace
local function actor(name,position)
 local model=Instance.new('Model');model.Name=name
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Size=Vector3.new(2,2,1);root.Position=position;root.Anchored=true;root.Parent=model
 local human=Instance.new('Humanoid');human.Parent=model;model.PrimaryPart=root;model.Parent=folder
 return {model=model,root=root,character=model,humanoid=human,attackSeq=0,spawnPosition=position,config={attacks={{damage=121}},leashRange=65}}
end
local enemy=actor('Enemy',Vector3.new(30000,4,30000))
local target=actor('Hero',enemy.spawnPosition+Vector3.new(0,0,-4))
local checks,casts=0,0
local function check(v,m)checks+=1;assert(v,m)end
local hits,launches={},0
local ctx={emit=function(message)if message.kind=='projectile'then launches+=1 end end,
 hit=function(_,_,sample)hits[#hits+1]=sample end,valid=function()return true end,
 floor=function(point)return {Position=Vector3.new(point.X,1,point.Z),Normal=Vector3.yAxis}end,
 raycast=function()return nil end}
for kind,profile in pairs(Patterns.profiles)do
 local healths=profile.boss and {1,.55,.2}or {1}
 for _,health in ipairs(healths)do for _,mode in ipairs({'Easy','Hard','Insane','Hell'})do
  for _,base in ipairs(profile.attacks)do
   local d=Profiles.resolve(kind,base,mode,health)
   enemy.root.Position=enemy.spawnPosition;target.root.Position=enemy.spawnPosition+Vector3.new(0,0,-4)
   hits={};launches=0;casts+=1
   Runtime.begin(enemy,target,d,0,function()end)
   for frame=0,math.ceil((d.windup+d.active)*30)do Runtime.step(enemy,frame/30,{target},ctx)end
   local budget,seen=0,{}
   for _,hit in ipairs(hits)do
    check(not seen[hit.pulse],'same target cannot receive duplicate fan or pulse damage')
    seen[hit.pulse]=true;budget+=hit.definition.damage
   end
   check(budget<=121,'phase combination exceeds no original raw budget: '..d.id)
   check(launches<=9 and #enemy.attack.projectiles<=9,'finite phase projectile budget')
   check(d.phase==Profiles.phase(kind,health),'real phase selected')
   Runtime.cancel(enemy,function()end);enemy.attack=nil
   if casts%40==0 then task.wait()end
  end
 end end
end
check(casts==1320,'all 50 species and 23 three-phase bosses exercised')
folder:Destroy()
print('ENEMY_ENCOUNTER_RUNTIME_NATIVE '..game.HttpService:JSONEncode({checks=checks,casts=casts,frameRate=30}))
