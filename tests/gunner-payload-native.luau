assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,"Local fixture only")
-- Let Studio finish entering Run before starting the short flight windows.
if not game.RunService:IsRunning() then game.RunService:Run() end
task.wait(.75)
local Client=game.StarterPlayer.StarterPlayerScripts.Client
local Catalog=require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Bomb=require(Client.BombVisual)
local FX=require(Client.HeroVFX)
local Visual=require(Client.AdvancedSkillVisual)
local Motion=require(Client.AdvancedSkillMotion)
local Appearance=require(game.ServerScriptService.Server.Cosmetics.WeaponAppearance)
local Combat=require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local camera=workspace.CurrentCamera
local originalCamera=camera.CFrame
local origin,target=Vector3.new(0,731,0),Vector3.new(0,731,-16)
camera.CFrame=CFrame.lookAt(origin+Vector3.new(13,10,16),target)
local fixture=Instance.new("Folder",workspace)
local floor=Instance.new("Part",fixture)
floor.Anchored=true
floor.Size=Vector3.new(120,1,120)
floor.Position=origin-Vector3.yAxis*3
local checks,sequence=0,0
local function check(condition,message)
 checks+=1
 assert(condition,message)
end
local function find(name,id,pulse)
 for _,v in workspace:GetChildren() do
  if v.Name==name and v:GetAttribute("SkillId")==id and (not pulse or v:GetAttribute("Pulse")==pulse) then
   return v
  end
 end
end
local function await(deadline,predicate)
 repeat
  local value=predicate()
  if value then return value end
  task.wait()
 until workspace:GetServerTimeNow()>=deadline
end
local function cast(actor,d,started)
 sequence+=1
 actor:SetAttribute("K0State","Attack")
 actor:SetAttribute("K0SkillId",d.id)
 actor:SetAttribute("K0AttackSeq",sequence)
 actor:SetAttribute("K0AttackStartedAt",started)
 Visual.play(actor,d.id,origin,target,0,nil,sequence,started,started)
 return assert(actor:FindFirstChild("BranchSkillProp"),d.id.." prop")
end
local function rig(rigType)
 local desc=Instance.new("HumanoidDescription")
 local actor=game.Players:CreateHumanoidModelFromDescriptionAsync(desc,rigType)
 desc:Destroy()
 actor.Parent=fixture
 actor:PivotTo(CFrame.new(origin))
 actor.HumanoidRootPart.Anchored=true
 actor:SetAttribute("K0ClassId","dwarf")
 local appearance=Instance.new("Model",actor)
 Appearance.attachInto(appearance,actor,"dwarf")
 return actor,assert(appearance:FindFirstChild("Weapon"))
end
local ok,err=xpcall(function()
 local actor,axe=rig(Enum.HumanoidRigType.R15)
 local hand=actor.LeftHand
 local bombs={bomb_toss="lob",shrapnel_toss="scatter",skipping_charge="bounce",rolling_charge="roll"}
 for suffix,path in pairs(bombs) do
  local id="dwarf.gunner."..suffix
  local d=Catalog.byId[id].definition
  local profile=Bomb.get(id)
  local started=workspace:GetServerTimeNow()
  local prop=cast(actor,d,started)
  local body=prop.BombBody
  check(body.WeldConstraint.Part0==hand and prop:FindFirstChild("BombFuseEmber"),id.." left-hand bomb with visible fuse")
  check(not prop:FindFirstChild("Barrel") and axe.LocalTransparencyModifier==0,id.." has a visible right-hand axe")
  local launchAge=d.windup-profile.flight
  local loaded,release=Motion.sample("dwarf",d,launchAge*.61),Motion.sample("dwarf",d,launchAge)
  check(release.angles.left.X-loaded.angles.left.X>90,id.." left arm performs the throw")
  check(math.abs(release.angles.right.X-loaded.angles.right.X)<40,id.." right arm holds the axe low")
  for pulse=1,d.pulses do
   local landingAt=started+d.windup+(pulse-1)*d.interval
   local aim=d.scatter and target+Vector3.new((pulse%2==0 and 1 or -1)*3,0,(pulse-2)*2) or target
   local flight=assert(await(landingAt-.04,function()return find("HeroSkillIncoming",id,pulse)end),
    id.." releases a physical bomb before landing")
   local thrown=flight.ThrownBomb.BombBody
   check(flight:GetAttribute("PayloadPath")==path and thrown.Shape==Enum.PartType.Ball,id.." uses its authored trajectory")
   check(not flight:FindFirstChildWhichIsA("Beam",true),id.." no full-length shot line during flight")
   if pulse==1 then check(body.LocalTransparencyModifier==1,id.." leaves the casting hand") end
   local floorY=Bomb.floor(aim,actor).Y+Bomb.radius
   local function height(fraction)
    FX.step(landingAt-profile.flight*(1-fraction))
    return thrown.Position.Y
   end
   if path=="roll" then
    check(math.abs(height(.45)-floorY)<.2 and math.abs(height(.8)-floorY)<.2,id.." rolls on the floor")
   elseif path=="bounce" then
    -- Studio can start a late frame partway into the intended flight window.
    local bounceHeight=math.huge
    for sample=0,16 do bounceHeight=math.min(bounceHeight,height(.54+sample*.01)) end
    check(height(.31)>floorY+.7 and math.abs(bounceHeight-floorY)<.22 and height(.83)>floorY+.45,
     id.." lands and lifts for a second skip")
   else
    check(height(.5)>floorY+1.45,id.." visible airborne arc")
   end
   height(.988)
   check((thrown.Position-Vector3.new(aim.X,floorY,aim.Z)).Magnitude<.75,id.." arrives at the correct pulse destination")
   check(not find("HeroVFX",id,pulse),id.." never detonates from the flight timer")
   Visual.play(actor,id,origin,aim,pulse,{},sequence,workspace:GetServerTimeNow(),started)
   check(not flight.Parent,id.." server pulse consumes the flight")
   local impact=assert(find("HeroVFX",id,pulse))
   check(impact:FindFirstChild("BombCasingFragment",true) and impact:FindFirstChild("BombContactFlash",true),id.." throws casing outward")
   check(not impact:FindFirstChild("IconBallisticEcho",true) and not impact:FindFirstChild("RifleTracer",true),id.." no post-impact shot line")
   check(math.abs(impact:FindFirstChild("BombContactFlash",true).Position.Y-floorY)<.01,id.." blast stays at terrain height")
   FX.clear()
  end
  actor:SetAttribute("K0State","Dodge")
  task.wait()
  check(not prop.Parent and axe.LocalTransparencyModifier==0,id.." cancel removes the left prop only")
 end

 for _,rigType in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
  local shooter,heldAxe=rig(rigType)
  local left=shooter:FindFirstChild("LeftHand") or shooter["Left Arm"]
  local count=0
  for id,row in pairs(Catalog.byId) do
   local d=row.definition
   if d.branch~="gunner" then continue end
   local started=workspace:GetServerTimeNow()
   local prop=cast(shooter,d,started)
   local piece=Bomb.get(id) and prop.BombBody or prop.Barrel
   check(piece.WeldConstraint.Part0==left and heldAxe.LocalTransparencyModifier==0,id.." "..rigType.Name.." dual wield")
   count+=1
   if FX.groundLead(d) then
    local flight=assert(FX.incoming(shooter,d,target,sequence,1,started+.24,function()return true end))
    local shell=assert(flight:FindFirstChild("MortarShellBody",true))
    local before=shell.Position
    check(shell.Size.Y>shell.Size.X*2 and not flight:FindFirstChild("BombBody",true),id.." reads as a metal shell")
    FX.step(started+.22)
    check(shell.Position.Y<before.Y-4,id.." shell descends before the confirmed blast")
    Visual.play(shooter,id,origin,target,1,{},sequence,workspace:GetServerTimeNow(),started)
    check(not flight.Parent,id.." confirmation clears falling shell")
    local effect=assert(find("HeroVFX",id,1))
    check(effect:FindFirstChild("BlastShockwave",true) or effect:FindFirstChild("SiegeLandingSpark",true),id.." grounded cannon impact")
   elseif id=="dwarf.gunner.blast_step" then
    local effect=assert(FX.skill(shooter,id,origin,target,1,{}))
    check(effect:FindFirstChild("BlastForwardPressure",true),id.." keeps its directed discharge")
   end
   shooter:SetAttribute("K0State","Dodge")
   task.wait()
   check(not prop.Parent,id.." interruption clears temporary weapon")
   FX.clear()
  end
  check(count==13,"Every Gunner skill verified on "..rigType.Name)
  shooter:Destroy()
 end

 local caught=Catalog.byId["dwarf.gunner.bomb_toss"].definition
 local began=workspace:GetServerTimeNow()
 local prop=cast(actor,caught,began)
 local flight=assert(await(began+caught.windup-.04,function()return find("HeroSkillIncoming",caught.id,1)end))
 actor:SetAttribute("TLTDeathFalling",true)
 task.wait()
 FX.step(workspace:GetServerTimeNow())
 check(not prop.Parent and not flight.Parent,"Death clears the held and airborne bombs")
 check(not find("HeroVFX",caught.id,1),"Cancelled flight cannot fabricate an explosion")

 local rolling=Catalog.byId["dwarf.gunner.rolling_charge"].definition
 local function enemy(id,position)
  local model=Instance.new("Model",fixture)
  local root=Instance.new("Part",model)
  root.Anchored=true;root.CanCollide=false;root.Position=position
  return {id=id,model=model,root=root,humanoid=Instance.new("Humanoid",model)}
 end
 local near=enemy(1,origin-Vector3.zAxis*8)
 local far=enemy(2,origin-Vector3.zAxis*15)
 local offAxis=enemy(3,origin+Vector3.new(3,0,-25))
 local enemies={[near.model]=near,[far.model]=far,[offAxis.model]=offAxis}
 local state={root=actor.HumanoidRootPart,character=actor}
 local direction=-Vector3.zAxis
 local clear=function()return true end
 local snapshot=Combat.snapshot(state,rolling,direction,nil,enemies,clear)
 check(snapshot.visualCenter==far.root.Position and (snapshot.center-origin).Magnitude==rolling.range,
  "Rolling Charge previews the server line target and retains the original combat center")
 far.root.Position+=Vector3.xAxis*15
 local damage={}
 Combat.resolve(state,{definition=rolling,advancedCast=snapshot,direction=direction},0,
  {enemies=enemies,clear=clear,damage=function(_,hit)table.insert(damage,hit.id)end,
   visual=function(_,_,_,center)check(center==near.root.Position,"Detonation uses live target, not forecast")end},1)
 check(#damage==1 and damage[1]==near.id,"Forecast never authorizes damage")
end,debug.traceback)
fixture:Destroy()
camera.CFrame=originalCamera
FX.clear()
print("GUNNER_PAYLOAD_NATIVE "..game.HttpService:JSONEncode({checks=checks,pass=ok,error=err}))
assert(ok,err)
