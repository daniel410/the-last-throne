local Players=game:GetService('Players');local Run=game:GetService('RunService')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'isolated local place only')
local server=game.ServerScriptService.Server
local field=require(server.World.TrainingField)
local report={kind='ENEMY_DEATH_LIFECYCLE_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='EnemyLifecycleQA';fixture.Parent=workspace
local clone=server.Combat.CombatService:Clone();clone.Name='EnemyLifecycleCombatQA';clone.Parent=server.Combat
local ok,err=xpcall(function()
 Run:Run()
 local ground=Instance.new('Part');ground.Size=Vector3.new(100,2,100);ground.Position=Vector3.new(12000,-1,12000);ground.Anchored=true;ground.Parent=fixture
 local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=fixture
 local training=field.makeEnemy(enemies,'Goblin',11980,12000,1,1);training.HumanoidRootPart.Anchored=true
 local story=field.makeEnemy(enemies,'Orc',12020,12000,1,1);story.HumanoidRootPart.Anchored=true;story:SetAttribute('DeepwoodEncounter','qa')
 local service=require(clone);local defeated=0
 service.setStoryDefeatHandler(function(model)if model==story then defeated+=1 end end)
 service.start(enemies,function()return nil end)
 check(not training.Humanoid.BreakJointsOnDeath and not story.Humanoid.BreakJointsOnDeath,'registration prepares both kinds of encounter')
 training.Humanoid.Health=0;story.Humanoid.Health=0;task.wait(.2)
 check(defeated==1,'story defeat is credited immediately once')
 check(training:GetAttribute('K0EnemyState')=='Dead' and story:GetAttribute('K0EnemyState')=='Dead','combat ends on death')
 check(training:GetAttribute('K0EnemyDeathFalling') and story:GetAttribute('K0EnemyDeathFalling'),'both start the fall')
 task.wait(2.1)
 check(not story.Parent,'story corpse is removed after presentation')
 check(training.Parent==enemies and training.TdMonsterVisual.Body.Transparency>.99,'training corpse is hidden before respawn')
 task.wait(3.3)
 check(not training.Parent,'old training corpse is removed at respawn')
 local replacement=enemies:FindFirstChild('Goblin')
 check(replacement and replacement~=training and replacement.Humanoid.Health>0,'training enemy respawns alive on schedule')
 check(defeated==1,'presentation does not duplicate story credit')
end,debug.traceback)
fixture:Destroy();clone:Destroy();if Run:IsRunning()then Run:Stop()end
if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
