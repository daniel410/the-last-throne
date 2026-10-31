local Players=game:GetService('Players');local Run=game:GetService('RunService')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'isolated local place only')
local server=game.ServerScriptService.Server
local Fall=require(server.Combat.EnemyDeathFall)
local Field=require(server.World.TrainingField)
local report={kind='ENEMY_DEATH_FALL_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local fixture=Instance.new('Folder');fixture.Name='EnemyDeathQA';fixture.Parent=workspace
local ok,err=xpcall(function()
 Run:Run()
 local floor=Instance.new('Part');floor.Name='Floor';floor.Size=Vector3.new(300,2,100);floor.Position=Vector3.new(10000,-1,10000);floor.Anchored=true;floor.Parent=fixture
 local enemies=Instance.new('Folder');enemies.Name='Enemies';enemies.Parent=fixture
 local actors={}
 for index,kind in ipairs({'Goblin','Orc','Ogre','Shaman','IceElf','IceTroll','VolcanoShaman','Imp'})do
  local model=Field.makeEnemy(enemies,kind,9900+index*18,10000,1,1)
  local root=model.HumanoidRootPart;root.Anchored=true
  local human=model:FindFirstChildOfClass('Humanoid');Fall.prepare(human,kind)
  check(not human.BreakJointsOnDeath,kind..' keeps its rig')
  check(not Fall.play(model,kind,enemies),kind..' cannot fall while alive')
  local forward=root.CFrame.LookVector;local start=root.Position
  human.Health=0;task.wait(.04)
  check(Fall.play(model,kind,enemies),kind..' starts falling')
  check(not Fall.play(model,kind,enemies),kind..' fall is idempotent')
  table.insert(actors,{kind=kind,model=model,root=root,forward=forward,start=start})
 end
 for _,kind in ipairs({'Slime','IceWolf','IceBear','KingIceBear','LavaSlime','MagmaWorm'})do check(not Fall.supports(kind),kind..' is excluded')end
 task.wait(.8)
 for _,a in ipairs(actors)do
  check(a.root.CFrame.UpVector:Dot(a.forward)>.95,a.kind..' falls forward')
  check((a.root.Position-a.start):Dot(a.forward)>0,a.kind..' moves toward the front')
  check(a.root.Anchored and not a.root.CanQuery and not a.root.CanCollide,a.kind..' corpse does not obstruct combat')
  check(a.model.TdMonsterVisual.Body.Transparency<1,a.kind..' remains visible after falling')
  check(a.root:FindFirstChild('RootJoint')~=nil,a.kind..' retains the root joint')
  local bottom=math.huge
  for _,part in ipairs(a.model.TdMonsterVisual:GetDescendants())do if part:IsA('BasePart')then
   for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do bottom=math.min(bottom,part.CFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)*.5).Y)end end end
  end end
  check(bottom>-.2 and bottom<.4,a.kind..' visible bounds rest near the floor: '..bottom)
 end
 task.wait(1.3)
 for _,a in ipairs(actors)do check(a.model.TdMonsterVisual.Body.Transparency>.99,a.kind..' disappears after the hold')end
end,debug.traceback)
fixture:Destroy();if Run:IsRunning()then Run:Stop()end
if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
