-- Compare against immutable 0.86.4 skill playback, independently of the new
-- basic cadence. Baseline Config/Advanced source is injected by the fixture.
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local currentM=require(Client.K0MeleeMotion)
local currentA=require(Client.AdvancedSkillMotion)
local currentS=require(Client.K0ShieldBashMotion)
local report={kind='MELEE_SKILL_TEMPO_ISOLATION_NATIVE',checks=0,poses=0,maxDegrees=0,pass=false}
local function check(v,label)report.checks+=1;assert(v,label)end
local folder=Instance.new('Folder');folder.Name='MeleeTempoSkillBaseline';folder.Parent=game.ServerStorage
local oldConfig=Instance.new('ModuleScript');oldConfig.Name='Config';oldConfig.Source=tempoBaselineConfigSource;oldConfig.Parent=folder
local clone=Client:Clone();clone.Name='Client';if clone:IsA('LocalScript')then clone.Disabled=true end;clone.Parent=folder
clone.AdvancedSkillMotion.Source=tempoBaselineAdvancedSource
for _,name in {'K0MeleeMotion','AdvancedSkillMotion','K0ShieldBashMotion'}do
 local source=clone[name].Source
 for _,needle in {'game.ReplicatedStorage.Shared.K0Config','game:GetService("ReplicatedStorage").Shared.K0Config'}do
  source=source:gsub(needle:gsub('(%W)','%%%1'),function()return 'script.Parent.Parent.Config'end)
 end
 clone[name].Source=source
end
local ok,err=xpcall(function()
 local oldC=require(oldConfig);local oldM=require(clone.K0MeleeMotion);local oldA=require(clone.AdvancedSkillMotion);local oldS=require(clone.K0ShieldBashMotion)
 local function sample(M,A,S,classId,d,age,rig)
  if d.advanced then return A.sample(classId,d,age,rig)end
  if d.id=='knight.common.bash'then return S.sample(age,rig)end
  return M.sample(classId,1,age,nil,nil,d.id,rig)
 end
 for _,classId in {'knight','dwarf'}do
  for index,d in Config.Skills[classId]do
   local baseline=oldC.Skills[classId][index]
   for key,value in baseline do if type(value)~='table'then check(d[key]==value,'Skill definition unchanged '..d.id..'/'..key)end end
   for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15}do for i=0,80 do
    local age=(d.windup+d.active+d.recovery)*i/80
    local a=sample(oldM,oldA,oldS,classId,baseline,age,rig)
    local b=sample(currentM,currentA,currentS,classId,d,age,rig)
    check((a==nil)==(b==nil),'Specialist/fallback ownership unchanged '..d.id)
    if not a then continue end
    report.poses+=1
    if a.angles then for channel,angle in a.angles do
     local degrees=(angle-b.angles[channel]).Magnitude;report.maxDegrees=math.max(report.maxDegrees,degrees)
     check(degrees<.003,'Skill choreography preserved '..d.id..'/'..channel..' t='..age..' error='..degrees)
    end else for _,channel in {'right','left','elbow','leftElbow','wrist','torso','weapon'}do
     if a[channel]then local x,y={a[channel]:GetComponents()},{b[channel]:GetComponents()};for k,value in x do check(math.abs(value-y[k])<.00002,'Shield channel preserved '..channel..' t='..age..' error='..math.abs(value-y[k]))end end
    end end
    check(math.abs((a.axeStrikeTurn or 0)-(b.axeStrikeTurn or 0))<.00001,'Axe yaw preserved')
    if a.root then check(b.root~=nil and(a.root.Position-b.root.Position).Magnitude<.00001,'Skill root preserved')end
   end end
  end
 end
end,debug.traceback)
folder:Destroy();report.pass=ok;print('MELEE_SKILL_TEMPO_ISOLATION_NATIVE '..game.HttpService:JSONEncode(report));assert(ok,err)
