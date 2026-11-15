-- Isolated engine checks for server-backed support, counter and status feedback.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture only')
local Client=game.StarterPlayer.StarterPlayerScripts:FindFirstChild('Client')
local M=deps and deps.EnemyMechanicEffects or require(Client.EnemyMechanicEffects)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='EnemyMechanicQA';fixture.Parent=workspace
local function actor(name,x)
 local model=Instance.new('Model');model.Name=name
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Position=Vector3.new(x,4,0);root.Anchored=true;root.CanCollide=false;root.Parent=model
 local humanoid=Instance.new('Humanoid');humanoid.Parent=model
 model:SetAttribute('K0EnemyId',name);model:SetAttribute('TdMonsterTargetHeight',5);model.Parent=fixture
 return model,root,humanoid
end
local caster,sourceRoot,sourceHuman=actor('SupportCaster',0)
local ally,allyRoot,allyHuman=actor('ProtectedAlly',8)
local hero,heroRoot,heroHuman=actor('Hero',-6)
local now=workspace:GetServerTimeNow()
local camera=workspace.CurrentCamera;local oldCamera=camera and camera.CFrame
if camera then camera.CFrame=CFrame.lookAt(Vector3.new(0,18,25),Vector3.zero)end
local sourceCF,allyCF=sourceRoot.CFrame,allyRoot.CFrame
local sourceHP,allyHP,heroHP=sourceHuman.Health,allyHuman.Health,heroHuman.Health
local function support(kind,sequence)
 caster:SetAttribute('K0SupportKind',kind);caster:SetAttribute('K0SupportSeq',sequence)
 caster:SetAttribute('K0SupportUntil',now+2);caster:SetAttribute('K0SupportTargetId','ProtectedAlly')
 M.observe(ally,now)
 M.receive({kind='support',model=caster,target=ally,support=kind,sequence=sequence,untilTime=now+2,at=now})
 M.render(now)
end
support('Ward',1)
local line=sourceRoot:FindFirstChild('EnemySupportTether')
check(line~=nil and #line:GetChildren()==3,'Ward shows its ally tether during the actual channel')
check(sourceRoot.EnemyMechanicState.Status.Text=='Ward','Ward uses a readable existing-scale label')
for _,part in ipairs(line:GetChildren())do check(part.Color.R>part.Color.B,'Ward tether is gold')end
M.receive({kind='supportEnd',model=caster,sequence=1,result='Interrupted'})
M.render(now+.1)
check(not sourceRoot:FindFirstChild('EnemySupportTether')and not sourceRoot:FindFirstChild('EnemyMechanicState'),'interruption removes cast feedback before delayed attributes arrive')
support('Rally',2)
line=sourceRoot:FindFirstChild('EnemySupportTether')
check(line~=nil,'Rally starts a new independent channel')
for _,part in ipairs(line:GetChildren())do check(part.Color.B>part.Color.R,'Rally tether is purple')end
M.receive({kind='supportEnd',model=caster,sequence=1,result='Cancelled'})
M.render(now+.1)
check(sourceRoot:FindFirstChild('EnemySupportTether')~=nil,'an old cancellation cannot hide the new channel')
ally:SetAttribute('K0RallyUntil',now+3);M.observe(ally,now)
M.receive({kind='supportEnd',model=caster,sequence=2,result='Released'});M.render(now+.2)
check(not sourceRoot:FindFirstChild('EnemySupportTether'),'a released channel leaves no tether')
check(allyRoot.EnemyMechanicState.Status.Text=='Rally','a released Rally remains visible on its recipient')
ally:SetAttribute('K0RallyUntil',nil);ally:SetAttribute('K0WardUntil',now+2);ally:SetAttribute('K0WardAmount',30)
M.observe(ally,now);M.render(now+.3)
check(allyRoot.EnemyMechanicState.Status.Text=='Ward','Ward requires an actual remaining shield amount')
ally:SetAttribute('K0WardAmount',0);M.render(now+.4)
check(not allyRoot:FindFirstChild('EnemyMechanicState'),'depleted Ward feedback is removed immediately')
for _,key in ipairs({'Burn','Venom','Chill','Web','Weakness','Soul'})do hero:SetAttribute('K0Enemy'..key..'Until',now+1)end
M.receive({kind='status',target=hero});M.render(now+.5)
local status=heroRoot:FindFirstChild('EnemyMechanicMotifs');check(status~=nil,'confirmed afflictions create target-bound motifs')
local kinds={}
for _,part in ipairs(status:GetChildren())do
 local kind=part:GetAttribute('Mechanic');if kind then kinds[kind]=true end
 check(not part.CanCollide and not part.CanTouch and not part.CanQuery and part.Anchored,'status art cannot collide or supply hits')
end
local count=0;for _ in pairs(kinds)do count+=1 end
check(count==6,'all six real elemental effects have distinct motifs')
check(heroRoot.EnemyMechanicState.Status.Text:find('Webbed',1,true)~=nil,'status labels explain real control effects')
M.render(now+1.1)
check(not heroRoot:FindFirstChild('EnemyMechanicMotifs')and not heroRoot:FindFirstChild('EnemyMechanicState'),'expired elemental effects leave no visuals')
ally:SetAttribute('K0ExposedUntil',now+2)
M.receive({kind='weakness',model=ally,untilTime=now+2,side='flank',at=now});M.render(now+1.2)
check(allyRoot.EnemyMechanicState.Status.Text=='Exposed · Flank','actual directional counter windows are readable')
allyHuman.Health=0;M.render(now+1.3)
check(not allyRoot:FindFirstChild('EnemyMechanicMotifs')and not allyRoot:FindFirstChild('EnemyMechanicState'),'death removes buffs and counter visuals')
check(sourceRoot.CFrame==sourceCF and allyRoot.CFrame==allyCF,'presentation never moves either combat root')
check(sourceHuman.Health==sourceHP and heroHuman.Health==heroHP and allyHP==100,'presentation never applies health changes')
if camera then camera.CFrame=oldCamera end
fixture:Destroy();M.render(now+5)
print('ENEMY_MECHANIC_EFFECTS_NATIVE '..game.HttpService:JSONEncode({checks=checks,scope='support cancellation, six real statuses, exposure and cleanup'}))
