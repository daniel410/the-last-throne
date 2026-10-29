-- Actual R6/R15 joints and engine death in an empty unpublished Studio.
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Http=game:GetService('HttpService')
assert(game.PlaceId==0 and #Players:GetPlayers()==0,'Death fixture requires an empty local place')
local Fall=require(game.ServerScriptService.Server.Spawn.HeroDeathFall)
local report={kind='HERO_DEATH_NATIVE',checks=0,failures={}}
local fixture=Instance.new('Folder');fixture.Name='HeroDeathQa';fixture.Parent=workspace
local function check(v,message) report.checks+=1;assert(v,message) end
local function joints(model)
 local count=0;for _,v in ipairs(model:GetDescendants()) do if v:IsA('Motor6D') or v:IsA('AnimationConstraint') then count+=1 end end;return count
end
local ok,err=xpcall(function()
 Run:Run()
 local floor=Instance.new('Part');floor.Name='Floor';floor.Size=Vector3.new(80,2,80);floor.Position=Vector3.new(300,99,300);floor.Anchored=true;floor.Parent=fixture
 for i,rigType in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}) do
  local description=Instance.new('HumanoidDescription')
  local character=Players:CreateHumanoidModelFromDescriptionAsync(description,rigType);description:Destroy();character.Parent=fixture
  character:PivotTo(CFrame.new(290+i*8,104,300))
  local human=character:FindFirstChildOfClass('Humanoid');local root=character.HumanoidRootPart
  Fall.prepare(human)
  check(not human.BreakJointsOnDeath,'spawn prevents joint destruction')
  check(not Fall.play(character) and not root.Anchored,'living hero cannot become a corpse')
  local count=joints(character);check(count>5,'fixture has a complete native rig')
  human.Health=0;task.wait(.1)
  check(Fall.play(character),'dead hero begins forward fall')
  check(not Fall.play(character),'duplicate death does not restart the animation')
  task.wait(.8)
  check(joints(character)==count,'all rig joints remain connected after actual death')
  check(root.Anchored and root.CFrame.LookVector.Y<-.95,'hero lies face down without physics scatter')
  check(root.Position.Y>100 and root.Position.Y<102,'corpse rests above the real floor')
  for _,part in ipairs(character:GetDescendants()) do if part:IsA('BasePart') then check(not part.CanCollide and not part.CanQuery,'corpse cannot collide or remain a hit target: '..part.Name) end end
  character:Destroy()
 end
end,debug.traceback)
if not ok then table.insert(report.failures,err) end
fixture:Destroy();Run:Stop();report.pass=ok
print('HERO_DEATH_NATIVE '..Http:JSONEncode(report));assert(ok,'See HERO_DEATH_NATIVE')
