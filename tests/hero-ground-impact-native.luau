-- Ground flight follows the accepted cast clock. Only a positive server pulse renders impact.
assert(game.PlaceId==0 and game.GameId==0,"Local fixture only")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)
local camera=workspace.CurrentCamera
local oldCamera=camera.CFrame
local originalOther=FX.isOtherHero
local checks,skills=0,0
local function check(value,label)
 checks+=1
 assert(value,label)
end
local origin=Vector3.new(0,310,0)
local target=origin-Vector3.zAxis*12
camera.CFrame=CFrame.new(origin+Vector3.new(0,10,12))
local floor=Instance.new("Part")
floor.Size=Vector3.new(90,1,90)
floor.Position=origin-Vector3.yAxis*3
floor.Anchored=true
floor.Parent=workspace
local character=Instance.new("Model")
character.Parent=workspace
local root=Instance.new("Part")
root.Name="HumanoidRootPart"
root.Position=origin
root.Anchored=true
root.Parent=character

local function findIncoming(id,pulse)
 for _,child in workspace:GetChildren() do
  if child.Name=="HeroSkillIncoming" and child:GetAttribute("SkillId")==id
   and child:GetAttribute("Pulse")==pulse then return child end
 end
end

local function advanceUntil(deadline,predicate)
 repeat
  local value=predicate()
  if value then return value end
  task.wait()
 until workspace:GetServerTimeNow()>=deadline
end

local function opening(d,seq,remaining)
 local now=workspace:GetServerTimeNow()
 local contact=now+remaining
 local started=contact-d.windup-(d.hitDelay or 0)
 character:SetAttribute("K0State","Attack")
 character:SetAttribute("K0SkillId",d.id)
 character:SetAttribute("K0AttackSeq",seq)
 Visual.play(character,d.id,origin,target,0,nil,seq,started,started)
 return contact,started
end

local ok,err=xpcall(function()
 for id,row in pairs(Catalog.byId) do
  local d=row.definition
  local lead=FX.groundLead(d)
  if lead then
   FX.clear()
   skills+=1
   local contact=workspace:GetServerTimeNow()+lead
   local incoming=assert(FX.incoming(character,d,target,1,1,contact,function() return true end))
   local carrier=incoming:FindFirstChild("VFXCarrier")
   local beam=carrier:FindFirstChildWhichIsA("Beam")
   local y=beam.Attachment1.WorldPosition.Y
   FX.step(contact-.006)
   check(beam.Attachment1.WorldPosition.Y<y-4,"Descent reaches terrain before impact "..id)
   check(not incoming:FindFirstChildWhichIsA("ParticleEmitter",true) and not incoming:FindFirstChild("SoftGlow",true),"Incoming uses only shape and short wake "..id)
   FX.step(contact+.001)
   check(not incoming.Parent,"Descent expires on the shared clock "..id)
   local impact=assert(FX.skill(character,id,origin,target,1,{}))
   for _,name in ipairs({"FallingShardVolume","SpiritCanopyLeaf","MortarShellBody","AshDescent","HailDescent","ArrowRain","IconFallingFeather","IconBallisticEcho"}) do
    check(not impact:FindFirstChild(name,true),"Impact never repeats a fall "..id)
   end
  end
 end
 check(skills==10,"All three heroes' scheduled ground skills are covered")

 FX.clear()
 local d=Catalog.byId["dwarf.gunner.siege_pattern"].definition
 local contact,started=opening(d,10,.32)
 Visual.play(character,d.id,origin,target,0,nil,10,started,started)
 local cue=advanceUntil(contact-.04,function() return findIncoming(d.id,1) end)
 check(cue and cue.VFXCarrier.Position==target+Vector3.new(-3,0,-2),"First scheduled shell uses first scatter center")
 local active=FX.count()
 Visual.play(character,d.id,origin,target,0,nil,10,started,started)
 check(FX.count()==active,"Duplicate opening has no presentation side effects")
 Visual.play(character,d.id,origin,target+Vector3.new(-3,0,-2),1,{},10,workspace:GetServerTimeNow(),started)
 check(not cue.Parent,"An accepted early impact consumes its incoming cue immediately")
 local second=advanceUntil(contact+d.interval-.04,function() return findIncoming(d.id,2) end)
 check(second and second.VFXCarrier.Position==target+Vector3.new(3,0,0),"Second pulse follows its own scatter center")
 character:SetAttribute("K0State","Dodge")
 FX.step(workspace:GetServerTimeNow())
 check(not second.Parent,"An interrupted cast drops the in-flight cue")

 FX.clear()
 contact=opening(d,11,.28)
 character:SetAttribute("TLTDeathFalling",true)
 task.wait(.15)
 check(not findIncoming(d.id,1),"A queued shell cannot spawn after death")
 character:SetAttribute("TLTDeathFalling",nil)
 character:SetAttribute("K0AttackSeq",12)
 task.wait(d.interval)
 check(not findIncoming(d.id,2),"A newer action drops stale queued pulses")

 FX.clear()
 FX.isOtherHero=function(c) return c~=character end
 local function valid() return true end
 local ownerAt=workspace:GetServerTimeNow()+FX.groundLead(d)
 local allyA=FX.incoming(nil,d,target,20,1,ownerAt,valid)
 local allyB=FX.incoming(nil,d,target,21,1,ownerAt,valid)
 check(allyA and allyB and not FX.incoming(nil,d,target,22,1,ownerAt,valid),"Ally flight count is bounded")
 check(FX.incoming(character,d,target,20,1,ownerAt,valid)~=nil,"Owner retains an incoming slot")
 check(FX.incoming(character,d,target,21,1,ownerAt,valid)==nil,"Global incoming limit applies")
 check(FX.incoming(character,d,target,21,1,workspace:GetServerTimeNow()+.01,valid)==nil,"A stale event cannot replay full flight")

 FX.clear()
 local bladeTip=origin+Vector3.new(.25,.8,-2)
 for _,id in ipairs({"knight_driving_thrust","knight.steel_knight.vanguard_strike"}) do
  local strike=assert(FX.skill(character,id,origin,target,1,{},bladeTip))
  local beam=assert(strike:FindFirstChild("ThrustEdge",true))
  check((beam.Attachment0.WorldPosition-bladeTip).Magnitude<.001,"Thrust originates at weapon tip "..id)
  check(beam.Attachment1.WorldPosition.Z==target.Z,"Thrust preserves confirmed reach "..id)
  FX.step(workspace:GetServerTimeNow()+.1)
  check((beam.Attachment0.WorldPosition-bladeTip).Magnitude>1,"Trail contracts toward contact "..id)
 end
end,debug.traceback)

character:Destroy()
floor:Destroy()
FX.isOtherHero=originalOther
FX.clear()
camera.CFrame=oldCamera
print("HERO_GROUND_IMPACT_NATIVE "..game.HttpService:JSONEncode({pass=ok,checks=checks,skills=skills,error=err}))
assert(ok,err)
