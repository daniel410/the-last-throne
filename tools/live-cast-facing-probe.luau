-- Run only in a fresh local Studio training client; never a published session.
assert(game.PlaceId==0 and game:GetService('RunService'):IsStudio())
local player=game.Players.LocalPlayer
assert(player and player:GetAttribute('TLTInventoryMode')=='Studio session')
local character=assert(player.Character);local humanoid=character:FindFirstChildOfClass('Humanoid')
local class=character:GetAttribute('K0ClassId');assert(class=='elf'or class=='mage')
assert(character:GetAttribute('K0State')=='Idle')
local client=player.PlayerScripts.Client;local Facing=require(client.AttackFacing);local Bow=require(client.K0BowMotion)
local Run=game:GetService('RunService');local remote=game.ReplicatedStorage.Remotes.K0Action
local report={class=class,frames=0,maxFacingDegrees=0,maxFlightYawDegrees=0,projectileFrames=0,movementDistance=0,nockedAfterRelease=0,events={},started=workspace:GetServerTimeNow()}
local before=character.HumanoidRootPart.Position;local parts=setmetatable({},{__mode='k'});local connections={};local direction=Vector3.xAxis
local function angle(a,b)return math.deg(math.acos(math.clamp(a:Dot(b),-1,1)))end
local function flat(v)return Vector3.new(v.X,0,v.Z)end
local ok,err=xpcall(function()
 connections[1]=Run.RenderStepped:Connect(function()
  local root=character.HumanoidRootPart;report.movementDistance+=flat(root.Position-before).Magnitude;before=root.Position
  if character:GetAttribute('K0State')~='Attack'then return end
  local aim=Facing.direction(character);if not aim then return end
  if workspace:GetServerTimeNow()-(character:GetAttribute('K0AttackStartedAt')or math.huge)<.06 then return end
  report.frames+=1;report.maxFacingDegrees=math.max(report.maxFacingDegrees,angle(flat(root.CFrame.LookVector).Unit,aim))
  local id=character:GetAttribute('K0SkillId')
  if class=='elf'and not id then
   local fields=string.split(character:GetAttribute('K0ArrowRelease')or'','|');local at=tonumber(fields[3])
   if tonumber(fields[1])==character:GetAttribute('K0AttackSeq')and at and workspace:GetServerTimeNow()>at+.025 then
    local pose=Bow.forCharacter(character,workspace:GetServerTimeNow());if pose and pose.nocked then report.nockedAfterRelease+=1 end
   end
  end
  if id=='elf.common.rapid'or id=='elf.common.multi'then return end -- Intentional simultaneous spread lanes.
  for _,model in workspace:GetChildren()do
   local part=model.Name=='K0VisualArrow'and model:FindFirstChild('Shaft')or model:IsA('BasePart')and(model.Name=='K0VisualSpell'or model.Name=='K0WaterBall')and model
   if part then local old=parts[part];if old then local delta=flat(part.Position-old);if delta.Magnitude>.01 then report.projectileFrames+=1;report.maxFlightYawDegrees=math.max(report.maxFlightYawDegrees,angle(delta.Unit,aim))end end;parts[part]=part.Position end
  end
 end)
 connections[2]=character:GetAttributeChangedSignal(class=='elf'and'K0ArrowVisual'or'K0SpellVisual'):Connect(function()
  report.events[#report.events+1]={seq=character:GetAttribute('K0AttackSeq'),skill=character:GetAttribute('K0SkillId'),aim=character:GetAttribute('K0AttackAim'),release=character:GetAttribute('K0ArrowRelease'),started=character:GetAttribute('K0AttackStartedAt'),at=workspace:GetServerTimeNow()}
 end)
 Run:BindToRenderStep('TLTCastFacingQAInput',Enum.RenderPriority.Input.Value+1,function()humanoid:Move(character:GetAttribute('K0State')=='Attack'and direction or Vector3.zero,false)end)
 local actions=class=='elf'and{'Attack','Skill1','Skill2','Skill3'}or{'Skill1','Skill2','Skill3'}
 for i,action in actions do direction=i%2==0 and -Vector3.xAxis or Vector3.xAxis;remote:FireServer(action);task.wait(1.7)end
 task.wait(.2)
end,debug.traceback)
Run:UnbindFromRenderStep('TLTCastFacingQAInput');humanoid:Move(Vector3.zero)
for _,connection in connections do connection:Disconnect()end
report.ended=workspace:GetServerTimeNow();report.finalState=character:GetAttribute('K0State');report.autoRotateAfter=humanoid.AutoRotate
report.pass=ok and report.frames>10 and report.projectileFrames>0 and report.movementDistance>.5 and report.maxFacingDegrees<.1 and report.maxFlightYawDegrees<.1 and report.nockedAfterRelease==0 and report.autoRotateAfter
report.error=err
shared.TLTLiveCastFacingQA=report
return game.HttpService:JSONEncode(report)
