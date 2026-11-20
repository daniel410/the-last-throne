assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"isolated Studio fixture required")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Config=require(game.ReplicatedStorage.Shared.K0Config)
local Presentation=require(game.ReplicatedStorage.Shared.SkillPresentation)
local Visual=require(Client.AdvancedSkillVisual)
local FX=require(Client.HeroVFX)
local Motion=require(Client.AdvancedSkillMotion)
local report={checks=0,skills=0,styles={}}
local function check(value,label)
 report.checks+=1
 assert(value,label)
end

local character=Instance.new("Model")
local root=Instance.new("Part")
root.Name="HumanoidRootPart"
root.Anchored=true
root.Position=Vector3.new(0,4,0)
root.Parent=character
local socket=Instance.new("Attachment")
socket.Name="WeaponTip"
socket.Parent=root
character.Parent=workspace
workspace.CurrentCamera.CFrame=CFrame.new(4,6,10)
local seq=0
local function begin(d)
 seq+=1
 character:SetAttribute("K0AttackSeq",seq)
 character:SetAttribute("K0SkillId",d.id)
 character:SetAttribute("K0State","Attack")
 local now=workspace:GetServerTimeNow()
 return now-d.windup*.45
end

for _,classId in ipairs({"knight","dwarf","elf","mage"}) do
 for _,d in ipairs(Config.Skills[classId]) do
  if d.advanced and d.id~="mage_wind_lance" then
   local started=begin(d)
   local profile=Presentation.get(d)
   local cue=assert(FX.windup(character,d,profile.motion,profile.effect,root.Position,seq,started,socket),d.id)
   local style=cue:GetAttribute("Style")
   report.styles[style]=(report.styles[style] or 0)+1
   report.skills+=1
   local beams=0
   for _,instance in ipairs(cue:GetDescendants()) do
    if instance:IsA("Beam") then
     check((instance.Attachment0.WorldPosition-instance.Attachment1.WorldPosition).Magnitude>.02,d.id.." stroke length")
     check((instance.Attachment0.WorldPosition-socket.WorldPosition).Magnitude<3,d.id.." stays at socket")
     beams+=1
    elseif instance:IsA("BasePart") then
     check(not instance.CanQuery and not instance.CanCollide and not instance.CanTouch,d.id.." visual only")
    end
   end
   check(beams>=2 and beams<=6,d.id.." beam budget")
   local beam=cue:FindFirstChildWhichIsA("Beam",true)
   local point=beam.Attachment0.WorldPosition
   local sample=started+d.windup*.6
   FX.step(sample)
   local beforeMove=beam.Attachment0.WorldPosition
   check((beforeMove-point).Magnitude>.01,d.id.." animates")
   socket.Position+=Vector3.yAxis*.5
   FX.step(sample)
   check((beam.Attachment0.WorldPosition-beforeMove-Vector3.yAxis*.5).Magnitude<.01,d.id.." follows socket")
   socket.Position=Vector3.zero
   character:SetAttribute("K0State","Dodge")
   FX.step(sample)
   check(cue.Parent==nil,d.id.." clears on cancel")
  end
 end
end

local d
for _,definition in ipairs(Config.Skills.elf) do
 if definition.id=="elf.marksman.heavy_draw" then d=definition;break end
end
assert(d)
local started=begin(d)
local now=workspace:GetServerTimeNow()
local origin=root.Position
local target=origin+Vector3.zAxis*-8
Visual.play(character,d.id,origin,target,0,nil,seq,now,started-d.windup)
check(workspace:FindFirstChild("HeroSkillWindup")==nil,"expired preparation is dropped")
Visual.play(character,d.id,origin,target,0,nil,seq,now,started)
Visual.play(character,d.id,origin,target,0,nil,seq,now,started)
local cue=assert(workspace:FindFirstChild("HeroSkillWindup"))
check(FX.count()==1,"duplicate preparation is ignored")
Visual.play(character,d.id,origin,target,1,{target},seq,now,started)
check(cue.Parent==nil,"release clears preparation")
check(workspace:FindFirstChild("HeroVFX")~=nil,"confirmed release is visible")
Visual.play(character,d.id,origin,target,0,nil,seq,now,started)
check(workspace:FindFirstChild("HeroSkillWindup")==nil,"delayed packet cannot restart preparation")
FX.clear()

started=begin(d)
local profile=Presentation.get(d)
character:SetAttribute("K0AttackSeq",seq-1)
local unreplicated=assert(FX.windup(character,d,profile.motion,profile.effect,origin,seq,started,socket))
check(unreplicated.Parent~=nil,"preparation tolerates attribute replication after the event")
character:SetAttribute("K0AttackSeq",seq)
FX.step(started+d.windup*.55)
check(unreplicated.Parent~=nil,"matching attributes retain the effect")
character:SetAttribute("K0AttackSeq",seq+1)
FX.step(started+d.windup*.6)
check(unreplicated.Parent==nil,"a newer action clears the effect")

local hand=Instance.new("Part")
hand.Name="RightHand"
hand.Anchored=true
hand.Position=origin+Vector3.xAxis
hand.Parent=character
local axe=assert(FX.skill(character,"dwarf.iron_axe.returning_echo",origin,target,2))
local handle=assert(axe:FindFirstChild("ThrownAxeHandle",true))
local approach=handle.Position
FX.step(workspace:GetServerTimeNow()+.08)
check((handle.Position-approach).Magnitude>1,"returning axe travels before the catch")
check((handle.Position-hand.Position).Magnitude<.25,"returning axe settles into the catch hand")
FX.clear()

for _,def in ipairs(Config.Skills.knight) do
 if def.id=="knight.steel_knight.twin_cyclone" then
  local during=Motion.sample("knight",def,def.windup+def.interval*.5,Enum.HumanoidRigType.R15)
  local contact=Motion.sample("knight",def,def.windup+def.interval,Enum.HumanoidRigType.R15)
  check(during.root.LookVector.Z>.9 and contact.root.LookVector.Z<-.99,"spin re-centers on the second beat")
 end
end
character:Destroy()
report.pass=true
print("HERO_SKILL_WINDUP_NATIVE "..game.HttpService:JSONEncode(report))
