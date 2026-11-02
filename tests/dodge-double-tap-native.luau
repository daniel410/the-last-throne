-- Isolated module-only QA place, actual server functions and native R6/R15 rigs.
local Players=game:GetService('Players')
local combat=game.ServerScriptService.Server.Combat.CombatService
local copy=combat:Clone();copy.Name='DodgeDoubleTapQA'
copy.Source=copy.Source:gsub('\nreturn CombatService%s*$',[[
return {startDodge=startDodge,acceptAction=acceptAction,clearAction=clearAction,moveDodge=moveDodge,
 playerStates=playerStates,context=function(fn)contextResolver=fn end}
]])
copy.Parent=combat.Parent
local api=require(copy)
local visual=require(game.StarterPlayer.StarterPlayerScripts.Client.K0SwordVisual)
local config=require(game.ReplicatedStorage.Shared.K0Config)
local rules=require(game.ReplicatedStorage.Shared.DodgeRules)
local checks=0
local function check(value,label)checks+=1;assert(value,label)end
local function near(a,b,label)check(math.abs(a-b)<.002,label..' '..tostring(a)..' ~= '..tostring(b))end
local function frameNear(a,b,label)
 near((a.Position-b.Position).Magnitude,0,label..' position')
 local _,angle=a:ToObjectSpace(b):ToAxisAngle();near(angle,0,label..' rotation')
end
local floor=Instance.new('Part');floor.Size=Vector3.new(200,1,200);floor.Position=Vector3.new(10000,0,10000);floor.Anchored=true;floor.Parent=workspace
local character
local ok,err=xpcall(function()
 for _,rigType in ipairs({Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15})do
  for _,classId in ipairs({'knight','elf','dwarf','mage'})do
   character=Players:CreateHumanoidModelFromDescriptionAsync(Instance.new('HumanoidDescription'),rigType)
   character.Name='DodgeFixture';character:PivotTo(CFrame.new(10000,4,10000));character.Parent=workspace
   local root=character.HumanoidRootPart
   local player={Parent=Players,Character=character}
   local s={player=player,character=character,root=root,humanoid=character.Humanoid,baseClassId=classId,
    heroId='qa',heroEpoch=1,characterGeneration=1,mode='Idle',feedbackSeq=0,combo=0,dodgeSeq=0,
    lastGuardStarted=-math.huge,attackProfile=config.BasicAttackProfiles[classId],attackSeq=0,
    slotCount=3,skillSlots={1,2,3},skillReadyAt={},mana=100,maxMana=100}
   api.context(function()return {heroId='qa',baseClassId=classId,epoch=1,characterGeneration=1}end)
   api.playerStates[player]=s
   character:SetAttribute('K0SpawnReady',true);character:SetAttribute('K0ClassId',classId)
   for _,direction in ipairs({Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,-1)})do
    api.clearAction(s);s.mode='Idle'
    api.acceptAction(s,'Dodge',direction,10)
    check(s.dodge and s.dodge.kind=='Backstep','first accepted backstep')
    near(s.dodge.direction:Dot(root.CFrame.LookVector),-1,'first always backward')
    local previous=s.dodge
    api.acceptAction(s,'Dodge',direction,10.15)
    check(s.dodge~=previous and s.dodge.kind=='SideRoll','second immediately rolls')
    near(s.dodge.started,10.15,'second timestamp')
    near(s.dodge.direction:Dot(root.CFrame.LookVector),0,'sideways only')
    local side=direction.X<0 and -1 or 1
    near(s.dodge.direction:Dot(root.CFrame.RightVector),side,'selected side')
    local roll=s.dodge
    api.acceptAction(s,'Dodge',direction,10.16)
    check(s.dodge==roll,'third press cannot restart roll')
    local started=character:GetAttribute('K0DodgeStartedAt')
    local joint=character:FindFirstChild('LowerTorso') and character.LowerTorso:FindFirstChild('Root') or root:FindFirstChild('RootJoint')
    assert(joint,'root joint')
    local physicsBefore=root.CFrame
    for _,hz in ipairs({30,144})do
     for frame=0,math.ceil(config.Dodge.duration*hz)do
      local age=math.min(config.Dodge.duration,frame/hz)
      visual.renderArms(character,1/hz,started+age)
      local angle,drop=rules.rollPose(age,config.Dodge.duration-.1,side)
      local basis=joint.C0.Rotation
      local expected=basis:Inverse()*CFrame.new(0,drop,0)*CFrame.Angles(0,0,angle)*basis
      frameNear(joint.Transform,expected,'root animation '..rigType.Name..' '..classId)
      frameNear(root.CFrame,physicsBefore,'physics root stays upright')
     end
    end
    character:SetAttribute('K0State','Idle')
    for _=1,45 do visual.renderArms(character,1/60,started+1)end
    frameNear(joint.Transform,CFrame.identity,'roll restores neutral')
   end
   api.clearAction(s);s.mode='Idle';api.acceptAction(s,'Dodge',nil,20)
   local first=s.dodge;api.acceptAction(s,'Dodge',nil,20.30001)
   check(s.dodge==first,'late second does not roll')
   -- Actual server sweep still blocks walls and ledges, including side rolls.
   for _,blocked in ipairs({'wall','ledge'})do
    api.clearAction(s);s.mode='Idle';root.CFrame=CFrame.new(10000,4,10000)
    if blocked=='ledge' then root.CFrame=CFrame.new(10105,4,10000)end
    api.acceptAction(s,'Dodge',nil,30);api.acceptAction(s,'Dodge',Vector3.xAxis,30.1)
    local wall
    if blocked=='wall' then
     wall=Instance.new('Part');wall.Anchored=true;wall.Size=Vector3.new(1,12,12);wall.Position=root.Position+Vector3.new(3,0,0);wall.Parent=workspace
    end
    local before=root.Position;api.moveDodge(s,30.4)
    check(s.dodge.blocked,'collision/ledge stops roll')
    check((root.Position-before).Magnitude<config.Dodge.distance,'cannot cross obstacle')
    if wall then wall:Destroy()end
   end
   api.clearAction(s);s.mode='Idle';root.CFrame=CFrame.new(10000,4,10000)
   api.acceptAction(s,'Dodge',nil,40);api.moveDodge(s,40.1)
   check(character:GetAttribute('K0Invulnerable')==true,'backstep invulnerability')
   api.acceptAction(s,'Dodge',Vector3.xAxis,40.15)
   local before=root.Position
   api.moveDodge(s,40.35)
   check(character:GetAttribute('K0Invulnerable')==true,'roll invulnerability')
   api.moveDodge(s,40.45)
   near((root.Position-before).Magnitude,config.Dodge.distance,'free side roll distance')
   local moved=root.Position;api.moveDodge(s,40.45)
   near((root.Position-moved).Magnitude,0,'repeated sample cannot move twice')
   check(character:GetAttribute('K0Invulnerable')==false,'roll invulnerability expires')
   api.acceptAction(s,'Skill1',nil,40.46)
   check(s.attack and s.attack.isSkill and s.dodge==nil,'ready skill interrupts side roll')
   check(character:GetAttribute('K0DodgeKind')==nil,'skill clears roll presentation')
   for _,mode in ipairs({'Dead','Stunned'})do
    api.clearAction(s);s.mode=mode
    api.acceptAction(s,'Dodge',nil,50)
    check(s.dodge==nil,mode..' blocks dodge')
   end
   api.clearAction(s);api.playerStates[player]=nil;character:Destroy();character=nil
  end
 end
end,debug.traceback)
if character then character:Destroy()end
floor:Destroy();copy:Destroy()
print('DODGE_DOUBLE_TAP_NATIVE '..game.HttpService:JSONEncode({pass=ok,checks=checks,error=ok and '' or tostring(err)}))
assert(ok,err)
