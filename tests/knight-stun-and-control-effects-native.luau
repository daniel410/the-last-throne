-- Real damage/AI + client presentation instances, controlled clock. No input claim.
assert(game.PlaceId==0,'Local fixture required')
local report={kind='KNIGHT_STUN_CONTROL_EFFECTS_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local C=require(game.ReplicatedStorage.Shared.K0Config);local A=require(game.ReplicatedStorage.Shared.AdvancedSkills)
local Fx=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyControlEffects)
local Hit=require(game.StarterPlayer.StarterPlayerScripts.Client.K0HitEffects)
local Visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0EnemyVisual)
local original=game.ServerScriptService.Server.Combat.CombatService;local copy=original:Clone();copy.Name='KnightControlQA'
copy.Source=copy.Source:gsub('\nreturn CombatService%s*$',[[
return {damage=damageEnemy,step=stepEnemy,reset=resetEnemy,setFolder=function(f)enemyFolder=f end,setStoryDamage=function(f)storyDamageHandler=f end}
]])
copy.Parent=original.Parent;local api=require(copy)
local folder=Instance.new('Folder');folder.Name='KnightControlQA';folder.Parent=workspace;api.setFolder(folder)
local function rig(name,pos)
 local m=Instance.new('Model');m.Name=name;local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.CFrame=CFrame.new(pos);r.Parent=m;m.PrimaryPart=r
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.BreakJointsOnDeath=false;h.MaxHealth=10000;h.Health=10000;h.Parent=m;m.Parent=folder;return m,r,h
end
local ok,err=xpcall(function()
 local pm,pr,ph=rig('Attacker',Vector3.new(0,100,0));local state={feedbackSeq=0,baseClassId='knight',heroId='qa-knight',player={UserId=-902,Parent=game.Players},character=pm,root=pr,humanoid=ph}
 local skills={};for _,list in ipairs({C.Skills.knight})do for _,d in ipairs(list)do
  local expected=d.id=='knight.common.bash' or d.root==1 or d.requiresShield
  check((d.stunDuration==5)==(expected==true),'shield family only: '..d.id)
  if d.stunDuration then table.insert(skills,d)end
 end end;check(#skills==11,'eleven base/derived/common shield-root skills stun')
 for _,boss in ipairs({false,true})do
  local m,r,h=rig(boss and 'Boss' or 'Normal',Vector3.new(0,100,-3));m:SetAttribute('StoryBoss',boss);m:SetAttribute('TdMonsterTargetHeight',6)
  local e={id=1,model=m,root=r,humanoid=h,kind='Goblin',config=C.Enemy.Goblin,mode='Windup',posture=60,postureImmuneUntil=0,lastPostureDamage=0,pathToken=0,pathPending=true,nextMoveAt=math.huge,nextPathAt=math.huge,reconsiderAt=math.huge,spawnPosition=r.Position,spawnPivot=m:GetPivot()}
  local function hit(t,d)
   local a={hits={},hitCount=0,attackPower=10,counterDamage=0,isSkill=true,definition=d,direction=Vector3.new(0,0,-1)};api.damage(state,e,a,t);return a
  end
  for _,d in ipairs(skills)do
   e.posture=60;e.postureImmuneUntil=math.huge;e.attack={};local a=hit(10,d)
   check(e.stunUntil==15 and e.mode=='Stunned' and h.WalkSpeed==0 and not e.attack,'actual five-second shield skill: '..d.id)
   check(m:GetAttribute('K0EnemyStunClass')=='knight','server publishes latest real stun source')
   api.damage(state,e,a,11);check(e.stunUntil==15,'duplicate attack cannot extend stun')
   api.step(e,14.999,1/60);check(h.WalkSpeed==0 and e.mode=='Stunned','no early shield stun expiry')
   api.step(e,15,1/60);check(not e.stunUntil and m:GetAttribute('K0EnemyStunClass')==nil and h.WalkSpeed==e.config.walkSpeed,'expiry clears cue and restores AI')
  end
  hit(20,C.Skills.knight[1]);hit(22,C.Skills.knight[1]);check(e.stunUntil==27,'shield re-hit refreshes latest impact plus five')
  local s=assert(Fx.bind(m));local stamp=workspace:GetServerTimeNow();m:SetAttribute('K0EnemyStunUntil',stamp+5)
  local hp,cf,walk=h.Health,r.CFrame,h.WalkSpeed
  check(Fx.update(s,stamp) and #s.stars==3,'three orbiting shield stun stars')
  local marker=s.marker;local old=s.stars[1].Position;Fx.update(s,stamp+.5)
  check(s.marker==marker and #s.stars==3 and s.stars[1].Position~=old,'stars orbit without duplication')
  check(s.stars[1].StunStar.Star.TextColor3.B>s.stars[1].StunStar.Star.TextColor3.R,'knight uses cyan stars')
  m:SetAttribute('K0EnemyStunClass','dwarf');Fx.update(s,stamp+1)
  check(s.stars[1].StunStar.Star.TextColor3.R>s.stars[1].StunStar.Star.TextColor3.B,'latest dwarf hit changes stars to gold')
  check(not Fx.update(s,stamp+5) and not s.marker and not s.stars,'stars disappear at server expiry')
  check(h.Health==hp and r.CFrame==cf and h.WalkSpeed==walk,'visual cue changes no health, root or movement authority')
  m:SetAttribute('K0AttackDownUntil',stamp+4);m:SetAttribute('K0AttackDownMultiplier',.85);m:SetAttribute('K0DefenseBreakUntil',stamp+4);m:SetAttribute('K0ProvokeUntil',stamp+4)
  local text=Visual.statusText(m,stamp);check(text:find('STUNNED') and text:find('TAUNTED') and text:find('ATK') and text:find('DAMAGE TAKEN'),'combined actual effects visible in status text')
  api.reset(e);check(m:GetAttribute('K0EnemyStunUntil')==nil and m:GetAttribute('K0EnemyStunClass')==nil,'reset clears both stun cue attributes')
  api.setStoryDamage(function()return 0 end);m:SetAttribute('DeepwoodEncounter','QA:shielded');hit(40,C.Skills.knight[1]);check(not e.stunUntil,'blocked zero-damage story hit cannot stun');api.setStoryDamage(nil);m:SetAttribute('DeepwoodEncounter',nil)
  hit(50,C.Skills.knight[1]);m:SetAttribute('K0EnemyStunUntil',stamp+10);Fx.update(s,stamp);h.Health=0;check(not Fx.update(s,stamp+1) and not s.stars,'death clears persistent stars');m:Destroy()
 end
 -- All Knight/Dwarf authored skill IDs get a family-specific impact, while
 -- root health and server attributes remain untouched by the local renderer.
 local target,root,human=rig('ImpactTarget',Vector3.new(20,100,0))
 local hp=human.Health
 for _,class in ipairs({'knight','dwarf'})do for _,list in ipairs({C.Skills[class]})do for _,d in ipairs(list)do
  local before={}for _,m in ipairs(workspace:GetChildren())do if m.Name=='K0HitEffect'then before[m]=true end end
  check(Hit.show(target,root.Position,10,class,'Goblin',Vector3.new(0,0,-1),d.id),'confirmed skill renders: '..d.id)
  local found;for _,m in ipairs(workspace:GetChildren())do if m.Name=='K0HitEffect' and not before[m]then found=m end end
  check(found and found:GetAttribute('K0SkillEffectId')==d.id and found:FindFirstChild('K0SkillImpact'),'descendant has visible impact rather than generic fallback')
 end end end
 check(human.Health==hp and not target:GetAttribute('K0EnemyStunUntil'),'impact renderer cannot apply stun or damage')
 for _,m in ipairs(workspace:GetChildren())do if m.Name=='K0HitEffect'then m:Destroy()end end
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
folder:Destroy();copy:Destroy();report.pass=#report.failures==0;print('KNIGHT_STUN_CONTROL_EFFECTS_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Knight control effects failed')
