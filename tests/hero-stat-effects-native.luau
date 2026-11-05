-- Isolated source fixture: production server entry points and client poses.
assert(game.PlaceId==0,'Unpublished isolated place required')
local RS=game:GetService('ReplicatedStorage')
local G=require(RS.Shared.HeroProgression)
local K=require(RS.Shared.K0Config)
local production=game.ServerScriptService.Server.Combat.CombatService
local private=Instance.new('ModuleScript');private.Parent=production.Parent
private.Source=production.Source:gsub('\nreturn CombatService%s*$', '\nreturn {startAttack=startAttack,setPlayerState=setPlayerState,checkMovement=checkMovement}')
local api=require(private)
local clients=game.StarterPlayer.StarterPlayerScripts.Client
local motions={elf=require(clients.K0BowMotion),mage=require(clients.K0MageMotion),knight=require(clients.K0MeleeMotion),dwarf=require(clients.K0MeleeMotion)}
local n=0
local function near(a,b,label)n+=1;assert(math.abs(a-b)<.0001,label..': '..tostring(a)..' / '..tostring(b))end
for _,classId in ipairs({'knight','elf','dwarf','mage'})do
 local characters={}
 local poses={}
 for _,rate in ipairs({1,2})do
  local model=Instance.new('Model');model.Parent=workspace;table.insert(characters,model)
  local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=model
  local hum=Instance.new('Humanoid');hum.Parent=model
  model:SetAttribute('K0ClassId',classId)
  local state={character=model,humanoid=hum,root=root,baseClassId=classId,attackProfile=K.BasicAttackProfiles[classId],derived={attackRate=rate,moveRate=1.3,physicalPower=100,magicPower=100},combo=0,lastAttackFinished=-math.huge,attackSeq=0,feedbackSeq=0,mode='Idle'}
  api.startAttack(state,10)
  local base=K.BasicAttackProfiles[classId].attacks[1]
  near(state.attack.definition.windup,base.windup/rate,'server windup '..classId)
  near(state.attack.definition.recovery,base.recovery/rate,'server recovery '..classId)
  near(model:GetAttribute('K0BasicAttackRate'),rate,'replicated rate')
  near(hum.WalkSpeed,K.AttackSpeed*1.3,'attack walking')
  api.setPlayerState(state,'Idle');near(hum.WalkSpeed,K.WalkSpeed*1.3,'walk speed')
  state.sprinting=true;state.mode='';api.setPlayerState(state,'Idle');near(hum.WalkSpeed,K.SprintSpeed*1.3,'sprint speed')
  api.setPlayerState(state,'Block');near(hum.WalkSpeed,K.GuardSpeed*1.3,'guard walking')
  api.setPlayerState(state,'Dodge');near(hum.WalkSpeed,0,'dodge remains driven separately')
  state.mode='Idle';state.sprinting=false;state.lastMotionAt=0
  state.lastMotionPosition=root.Position;state.lastSafePivot=model:GetPivot();state.movementBudget=0
  root.CFrame=CFrame.new(root.Position+Vector3.new(K.WalkSpeed*1.3*.25*1.3,0,0))
  assert(api.checkMovement(state,.25),'DEX movement is accepted by server budget');n+=1
  root.CFrame=CFrame.new(root.Position+Vector3.new(100,0,0))
  assert(not api.checkMovement(state,1),'excess movement still rejected');n+=1
  model:SetAttribute('K0State','Attack')
  model:SetAttribute('K0AttackStartedAt',100)
  poses[rate]=motions[classId].forCharacter(model,100+base.windup*.6/rate)
 end
 local a,b=assert(poses[1]),assert(poses[2])
 if classId=='elf' or classId=='mage' then near(a.time,b.time,'same normalized pose '..classId)
 else
  for channel,angle in pairs(a.angles)do near((angle-b.angles[channel]).Magnitude,0,'same normalized pose '..classId..' '..channel)end
 end
 for _,model in ipairs(characters)do model:Destroy()end
end
private:Destroy()
print('HERO_STAT_EFFECTS_NATIVE PASS '..n..' checks; synthetic identities/native Humanoid and client pose evaluation, no player input or device acceptance')
