assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"Local fixture only")
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local FinalBeat=require(Client.SkillFinalBeat)
local Melee=require(Client.AdvancedSkillMotion)
local Mage=require(Client.K0MageMotion)
local Bow=require(Client.K0BowMotion)
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)
local origin=Vector3.new(0,745,0)
local target=origin-Vector3.zAxis*10
local camera=workspace.CurrentCamera
local oldCamera,oldWeight,oldOther=camera.CFrame,FinalBeat.weight,FX.isOtherHero
local floor=Instance.new("Part")
floor.Size=Vector3.new(110,1,110)
floor.Position=origin-Vector3.yAxis*3
floor.Anchored=true
floor.Parent=workspace
local checks=0
local rigs={}
local function check(condition,message)
 checks+=1
 assert(condition,message)
end
local rows={
 {"knight.steel_knight.blade_storm","leftKnee","BladeRibbon"},
 {"knight.paladin.oathbound_assault","torso","OathboundForwardCut"},
 {"dwarf.iron_axe.mountain_collapse","rightKnee","UltimateGroundFracture"},
 {"dwarf.gunner.siege_barrage","torso","SiegeLandingSpark"},
 {"elf.marksman.grand_volley","right","VolleyDrawCrown"},
 {"elf.magic_archer.spirit_arrowfall","right","SpiritCanopyBranch"},
 {"mage.pyro.ashfall","left","AshLandingEmber"},
 {"mage.cryo.hailfall","left","HailFracture"},
}
local function sample(actor,row,pulse,after,confirm)
 local rig=actor:FindFirstChildOfClass("Humanoid").RigType
 local d,classId=row.definition,row.classId
 local age=d.windup+(d.hitDelay or 0)+(pulse-1)*d.interval+after
 if classId=="elf" then
  if confirm then Bow.confirmPulse(actor,d.id,pulse,1,100+age-after,100,100+age) end
  return Bow.forCharacter(actor,100+age)
 elseif classId=="mage" then
  return Mage.sample(d,Mage.profile(d),age)
 end
 return Melee.sample(classId,d,age,rig)
end
local ok,err=xpcall(function()
 camera.CFrame=CFrame.lookAt(origin+Vector3.new(0,24,32),target)
 for _,rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
  local actor=Instance.new("Model")
  table.insert(rigs,actor)
  Instance.new("Humanoid",actor).RigType=rig
  actor.Parent=workspace
  for _,case in rows do
   local id,joint=case[1],case[2]
   local row=Catalog.byId[id]
   local d=row.definition
   actor:SetAttribute("K0State","Dodge")
   Bow.forCharacter(actor,99)
   actor:SetAttribute("K0State","Attack")
   actor:SetAttribute("K0ClassId",row.classId)
   actor:SetAttribute("K0SkillId",id)
   actor:SetAttribute("K0AttackSeq",1)
   actor:SetAttribute("K0AttackStartedAt",100)
   local first=sample(actor,row,1,.06,true)
   FinalBeat.weight=function()return 0 end
   local firstControl=sample(actor,row,1,.06,false)
   local endControl=sample(actor,row,d.pulses,.06,row.classId~="elf")
   FinalBeat.weight=oldWeight
   check(first.angles[joint]==firstControl.angles[joint],id.." preserves the opening beat")
   if row.classId=="elf" then
    local predicted=sample(actor,row,d.pulses,.06,false)
    check(predicted.angles[joint]==endControl.angles[joint] and predicted.nocked,
     id.." holds the draw until the final server release")
    sample(actor,row,d.pulses,.06,true)
    FinalBeat.weight=function()return 0 end
    endControl=sample(actor,row,d.pulses,.06,false)
    FinalBeat.weight=oldWeight
   end
   local finish=sample(actor,row,d.pulses,.06,false)
   check((finish.angles[joint]-endControl.angles[joint]).Magnitude>5,id.." has a distinct follow-through")
   check(FinalBeat.weight(d,d.pulses,0)==0 and FinalBeat.weight(d,d.pulses,d.active+d.recovery)==0,
    id.." blends in and returns to the regular recovery")
  end
 end

 for _,case in rows do
  local id,name=case[1],case[3]
  local d=Catalog.byId[id].definition
  local opening=assert(FX.skill(nil,id,origin,target,1,{}))
  local openingBeam=opening:FindFirstChild(name,true)
  local openingWidth=openingBeam and openingBeam.Width0
  local openingY=openingBeam and openingBeam.Attachment0.WorldPosition.Y
  FX.clear()
  local finish=assert(FX.skill(nil,id,origin,target,d.pulses,{}))
  local beam=assert(finish:FindFirstChild(name,true))
  check(beam:IsA("Beam"),id.." draws its final silhouette")
  if id=="knight.steel_knight.blade_storm" then
   check(beam.Attachment0.WorldPosition.Y<openingY-.3,"Blade Storm lowers the last sweep")
  elseif id=="elf.magic_archer.spirit_arrowfall" then
   check(beam.Attachment0.WorldPosition.Y>openingY+1,"Spirit Arrowfall raises the last canopy")
  elseif openingBeam then
   check(beam.Width0>openingWidth,id.." puts more emphasis on the final impact")
  else
   check(not finish:FindFirstChild("LandingRipple",true),id.." replaces the generic ripple")
  end
  FX.clear()
  FX.isOtherHero=function()return true end
  local ally=assert(FX.skill(nil,id,origin,target,d.pulses,{}))
  local allyBeam=ally:FindFirstChild(name,true)
  check(not ally:FindFirstChild("SoftGlow",true),id.." keeps the ally glow budget clear")
  check(not allyBeam or (allyBeam.Width0<=beam.Width0 and (openingWidth==nil or allyBeam.Width0<=openingWidth)),
   id.." reserves the stronger stroke for the caster")
  FX.clear()
  FX.isOtherHero=oldOther
 end

 local d=Catalog.byId["dwarf.gunner.siege_barrage"].definition
 for _,compact in {false,true} do
  FX.isOtherHero=function()return compact end
  local now=workspace:GetServerTimeNow()
  local incoming=assert(FX.incoming(nil,d,target,1,d.pulses,now+.24,function()return true end))
  local landed=assert(FX.skill(nil,d.id,origin,target,d.pulses,{}))
  local shells,sparks={},{}
  for _,piece in incoming:GetDescendants() do
   if piece.Name=="MortarShellBody" then table.insert(shells,piece.Position*Vector3.new(1,0,1)) end
  end
  for _,piece in landed:GetDescendants() do
   if piece.Name=="SiegeLandingSpark" then table.insert(sparks,piece.Attachment0.WorldPosition*Vector3.new(1,0,1)) end
  end
  check(#shells>=1 and #sparks==#shells*(compact and 2 or 3) and (not compact or #shells==1),"Each shell has one landing spark group")
  for _,spark in sparks do
   local matched=false
   for _,shell in shells do if math.abs((spark-shell).Magnitude-.2)<.001 then matched=true end end
   check(matched,"Siege sparks start at their incoming shell positions")
  end
  FX.clear()
 end

 local function boundaryCount()
  local count=0
  for _,child in workspace:GetChildren() do if child.Name=="SkillTelegraph" then count+=1 end end
  return count
 end
 local prior=boundaryCount()
 for _,compact in {true,false} do
  FX.isOtherHero=function()return compact end
  Visual.play(nil,d.id,origin,target,0)
  local count=boundaryCount()
  check(count-prior==(compact and 12 or 24),"Cast boundaries keep complete rings with fewer ally segments")
  prior=count
 end
end,debug.traceback)
for _,actor in rigs do actor:Destroy() end
floor:Destroy()
FinalBeat.weight,FX.isOtherHero,camera.CFrame=oldWeight,oldOther,oldCamera
FX.clear()
print("HERO_FINAL_BEAT_NATIVE "..game.HttpService:JSONEncode({pass=ok,checks=checks,skills=#rows,error=err}))
assert(ok,err)
