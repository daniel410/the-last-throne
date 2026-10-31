-- Actual damage/AI code, controlled clock and native Humanoids. No client authority.
local folder=Instance.new('Folder');folder.Name='DwarfStunQA';folder.Parent=workspace
local original=game.ServerScriptService.Server.Combat.CombatService;local copy=original:Clone();copy.Name='DwarfStunQA'
copy.Source=copy.Source:gsub('\nreturn CombatService%s*$',[[
return {damage=damageEnemy,step=stepEnemy,reset=resetEnemy,beginAttack=beginEnemyAttack,setFolder=function(f)enemyFolder=f end}
]])
copy.Parent=original.Parent;local api=require(copy);api.setFolder(folder)
local C=require(game.ReplicatedStorage.Shared.K0Config);local report={kind='DWARF_STUN_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local function rig(name,pos)
 local m=Instance.new('Model');m.Name=name;local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.CFrame=CFrame.new(pos);r.Parent=m;m.PrimaryPart=r
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.BreakJointsOnDeath=false;h.MaxHealth=10000;h.Health=10000;h.Parent=m;m.Parent=folder;return m,r,h
end
local ok,err=xpcall(function()
 local pm,pr,ph=rig('Attacker',Vector3.new(0,100,0));local state={feedbackSeq=0,baseClassId='dwarf',heroId='qa-dwarf',player={UserId=-901,Parent=game.Players},character=pm,root=pr,humanoid=ph}
 for _,boss in ipairs({false,true})do
  local m,r,h=rig(boss and 'Boss' or 'Normal',Vector3.new(0,100,-3));m:SetAttribute('StoryBoss',boss)
  local enemy={id=1,model=m,root=r,humanoid=h,kind='Goblin',config=C.Enemy.Goblin,mode='Windup',posture=60,postureImmuneUntil=0,lastPostureDamage=0,pathToken=0,pathPending=true,nextMoveAt=math.huge,nextPathAt=math.huge,reconsiderAt=math.huge,spawnPosition=r.Position,spawnPivot=m:GetPivot()}
  local function hit(time,d)local a={hits={},hitCount=0,attackPower=10,counterDamage=0,isSkill=true,definition=d,direction=Vector3.new(0,0,-1)};api.damage(state,enemy,a,time);return a end
  enemy.attack={definition=C.Enemy.Goblin.attacks[1]}
  local a=hit(10,C.Skills.dwarf[3]);check(enemy.stunUntil==15,'successful Ground Slam grants exactly five seconds, including bosses')
  check(enemy.attack==nil and enemy.mode=='Stunned'and h.WalkSpeed==0 and not enemy.pathPending,'stun cancels attacks and pending movement')
  api.damage(state,enemy,a,11);check(enemy.stunUntil==15,'same swing cannot refresh stun twice')
  api.step(enemy,14.999,1/60);check(enemy.mode=='Stunned'and h.WalkSpeed==0,'enemy cannot move or attack before five seconds')
  api.step(enemy,15,1/60);check(enemy.stunUntil==nil and m:GetAttribute('K0EnemyStunUntil')==nil and h.WalkSpeed==enemy.config.walkSpeed,'expiry restores AI and speed')
  hit(20,C.Skills.dwarf[3]);hit(22,C.Skills.dwarf[3]);check(enemy.stunUntil==27,'new hit refreshes from impact rather than adding durations')
  api.reset(enemy);check(enemy.stunUntil==nil and m:GetAttribute('K0EnemyStunUntil')==nil,'leash reset removes stun')
  for _,d in ipairs(C.Skills.dwarf)do if d.stunDuration then
   enemy.posture=60;enemy.postureImmuneUntil=math.huge;hit(40,d);check(enemy.stunUntil==45,'all connected roots use five seconds: '..d.id);api.reset(enemy)
  end end
  local basic=C.BasicAttackProfiles.dwarf.attacks[1];hit(50,basic);check(enemy.stunUntil==nil,'basic attacks never inherit skill stun')
 end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();copy:Destroy();report.pass=#report.failures==0;print('DWARF_STUN_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Dwarf stun native failed')
