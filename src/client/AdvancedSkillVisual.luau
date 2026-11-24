-- Server-confirmed presentation. No target selection, hit tests or damage.
local RS=game:GetService("ReplicatedStorage")
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Config=require(RS.Shared.K0Config)
local Presentation=require(RS.Shared.SkillPresentation)
local Geometry=require(script.Parent.SkillEffectGeometry)
local BowMotion=require(script.Parent.K0BowMotion)
local WindLance=require(script.Parent.WindLanceVisual)
local PixelFX=require(script.Parent.PixelFX)
local HeroVFX=require(script.Parent.HeroVFX)
local Bomb=require(script.Parent.BombVisual)
local Audio=require(script.Parent.K0CombatAudio)
local Players=game:GetService("Players")
local Palette=require(RS.Shared.CombatVFXPalette)
local Visual={}
local byId={};for _,list in pairs(Config.Skills) do for _,d in ipairs(list) do byId[d.id]=d end end
local colors=Palette.colors
local active=0
local slots={}
local confirmed=setmetatable({},{__mode="k"})
local groundCues=setmetatable({},{__mode="k"})
local function release(p)
 if not slots[p] then return end
 slots[p]=nil
 active=active-1
end
local function part(name,color,shape,size,cf,life,transparency)
 if active>=128 then return nil end
 active+=1
 local p=Instance.new("Part");p.Name=name;p.Shape=shape;p.Size=size;p.CFrame=cf
 slots[p]=true
 p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=transparency or .25
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=workspace
 Debris:AddItem(p,life+.05)
 task.delay(life+.05,function() release(p) end)
 Tween:Create(p,TweenInfo.new(life,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1}):Play()
 return p
end
local function segment(first,last,color,life,width,name,transparency)
 local length=(last-first).Magnitude;if length<.02 then return end
 return part(name or "SkillStreak",color,Enum.PartType.Block,Vector3.new(width or .1,width or .1,length),CFrame.lookAt((first+last)/2,last),life,transparency)
end
local function ground(position,character)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=character and {character} or {};params.RespectCanCollide=true
 local hit=workspace:Raycast(position+Vector3.new(0,2,0),Vector3.new(0,-18,0),params)
 return hit and hit.Position+Vector3.new(0,.08,0) or position-Vector3.new(0,2.7,0)
end
local function arc(center,direction,radius,angle,color,life,name,compact,pieces)
 local count=angle>=359 and not compact and 24 or 12
 if pieces and active+count>128 then count=12 end
 if pieces and active+count>128 then return end
 local points=Geometry.sector(center,direction,radius,angle,count)
 local faint=name=="SkillSector" or name=="SkillTelegraph"
 for i=1,#points-1 do
  local p=segment(points[i],points[i+1],color,life,.07,name,faint and .65 or nil)
  if pieces and p then table.insert(pieces,p) end
 end
end
local function impact(center,color,scale)
 local p=part("SkillContact",color,Enum.PartType.Ball,Vector3.one*.25,CFrame.new(center),.18,.1)
 if p then Tween:Create(p,TweenInfo.new(.18),{Size=Vector3.one*math.min(2,scale or 1)}):Play() end
end
local function lightning(first,last,color)
 local points=Geometry.lightning(first,last,6)
 for i=1,#points-1 do segment(points[i],points[i+1],color,.18,.12,"LightningFork") end
 impact(last,color,1)
end
-- Reuse the equipped TD arrow mesh; strip every executable/joint child.
-- A late/missing weapon falls back to a bounded shaft and arrowhead.
local function sourceArrow(character,at,direction)
 local source=character and character:FindFirstChild("NockedArrow",true)
 if not source or not source:IsA("MeshPart") or active>=128 then return false end
 local p=source:Clone()
 for _,child in ipairs(p:GetChildren()) do if not child:IsA("SurfaceAppearance") then child:Destroy() end end
 p.Name="SkillSourceArrow";p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.Transparency=0;p.LocalTransparencyModifier=0
 p.CFrame=CFrame.lookAt(at,at+direction)*CFrame.new(0,0,p.Size.Z*.5);p.Parent=workspace
 active+=1;Debris:AddItem(p,.25);task.delay(.25,function() active=math.max(0,active-1) end)
 Tween:Create(p,TweenInfo.new(.22),{Transparency=1}):Play()
 return true
end
local function arrow(first,last,color,character,hasWake)
 if not hasWake then segment(first,last,color,.14,.06,"ArrowWake") end
 local delta=last-first;if delta.Magnitude<.01 then return end
 if sourceArrow(character,last,delta) then return end
 local tip=last;local cf=CFrame.lookAt(tip,tip+delta)
 segment(tip-delta.Unit*1.4,tip,Color3.fromRGB(205,175,121),.18,.07,"ArrowShaft")
 segment(tip,cf:PointToWorldSpace(Vector3.new(.18,0,.4)),color,.18,.07,"ArrowHead")
 segment(tip,cf:PointToWorldSpace(Vector3.new(-.18,0,.4)),color,.18,.07,"ArrowHead")
end
local function source(character,origin,d)
 if not character then return origin end
 local prop=character:FindFirstChild("BranchSkillProp")
 local tip=prop and prop:FindFirstChild("SkillMuzzle",true)
 if not tip then
  local grip=character:FindFirstChild("WeaponGrip",true) or character:FindFirstChild("SwordGrip",true)
  tip=grip and grip:FindFirstChild("WeaponTip")
 end
 if tip and tip:IsA("Attachment") then return tip.WorldPosition end
 return origin
end
local function windupSocket(character,motion)
 if motion=="shield" or motion=="counter" then
  local shield=character:FindFirstChild("ShieldGrip",true)
  if shield and shield:IsA("BasePart") then return shield end
 elseif motion=="draw" or motion=="rain" then
  local arrow=character:FindFirstChild("NockedArrow",true)
  if arrow and arrow:IsA("BasePart") then return arrow end
 end
 local prop=character:FindFirstChild("BranchSkillProp")
 local tip=prop and (prop:FindFirstChild("BombFuseEmber") or prop:FindFirstChild("SkillMuzzle",true))
  or character:FindFirstChild("WeaponTip",true)
 return tip and (tip:IsA("Attachment") or tip:IsA("BasePart")) and tip or nil
end
local props=setmetatable({},{__mode="k"})
local function clearProp(character)
 local record=props[character];if not record then return end
 props[character]=nil
 for _,connection in ipairs(record.connections) do connection:Disconnect() end
 if record.model.Parent then record.model:Destroy() end
end
local function branchProp(character,d,seq)
 if d.branch~="gunner" then return end
 clearProp(character)
 local arm=character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
 if not arm then return end
 local model=Instance.new("Model");model.Name="BranchSkillProp";model.Parent=character
 local record={model=model,connections={},seq=seq,id=d.id};props[character]=record
 local function piece(name,size,offset,color,shape)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Shape=shape or Enum.PartType.Block;p.Color=color;p.Material=Enum.Material.Metal
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CFrame=arm.CFrame*CFrame.new(0,-.25,0)*CFrame.Angles(-math.pi/2,0,0)*offset;p.Parent=model
  local weld=Instance.new("WeldConstraint");weld.Part0=arm;weld.Part1=p;weld.Parent=p;return p
 end
 local bomb=Bomb.get(d.id)
 if bomb then
  Bomb.mount(model,Bomb.handFrame(arm),arm)
 else
  local heavy=d.element=="shell";local length=heavy and 2.3 or 1.7
  local diameter=heavy and .6 or .28
  local barrel=piece("Barrel",Vector3.new(length,diameter,diameter),CFrame.new(0,-.35,-.7)*CFrame.Angles(0,math.pi/2,0),Color3.fromRGB(68,83,99),Enum.PartType.Cylinder)
  piece("Breech",Vector3.new(.45,.42,.4),CFrame.new(0,-.35,.05),Color3.fromRGB(48,58,68))
  piece("Foregrip",Vector3.new(.38,.22,.65),CFrame.new(0,-.58,-.6),Color3.fromRGB(111,68,39))
  piece("Sight",Vector3.new(.08,.15,.14),CFrame.new(0,-.1,-1.1),colors.gun)
  piece("Grip",Vector3.new(.23,.5,.25),CFrame.new(0,-.68,.1)*CFrame.Angles(math.rad(-15),0,0),Color3.fromRGB(85,53,34))
  piece("Stock",Vector3.new(.45,.4,.7),CFrame.new(0,-.35,.35),Color3.fromRGB(111,68,39))
  local muzzle=Instance.new("Attachment");muzzle.Name="SkillMuzzle";muzzle.Position=Vector3.new(length/2,0,0);muzzle.Parent=barrel
 end
 local function matches()
  return character:GetAttribute("K0State")=="Attack" and character:GetAttribute("K0AttackSeq")==seq
   and character:GetAttribute("K0SkillId")==d.id
 end
 local seenAction=matches()
 local function cancelled()
  local current=character:GetAttribute("K0AttackSeq")
  local active=matches()
  if not character.Parent or character:GetAttribute("TLTDeathFalling")
   or type(current)=="number" and type(seq)=="number" and current>seq
   or seenAction and not active then clearProp(character) end
  seenAction=seenAction or active
 end
 for _,attribute in ipairs({"K0State","K0AttackSeq","K0SkillId","TLTDeathFalling"}) do table.insert(record.connections,character:GetAttributeChangedSignal(attribute):Connect(cancelled)) end
 table.insert(record.connections,character.AncestryChanged:Connect(cancelled))
 task.delay(d.windup+d.active+d.recovery+.1,function() if props[character]==record then clearProp(character) end end)
end
local function showProp(record,visible)
 for _,piece in record.model:GetChildren() do piece.LocalTransparencyModifier=visible and 0 or 1 end
end
local function spikes(center,direction,radius,angle,color,kind)
 local points=Geometry.sector(center,direction,radius*.7,angle,4)
 for i,point in ipairs(points) do
  local h=(i%2==0 and 3 or 2)
  local p=part(kind=="frost" and "IceCrystal" or "EarthRupture",color,Enum.PartType.Block,Vector3.new(.7,.15,.7),CFrame.new(point),.45,.15)
  if p then
   p.Material=kind=="frost" and Enum.Material.Ice or Enum.Material.Slate
   Tween:Create(p,TweenInfo.new(.12),{Size=Vector3.new(.7,h,.7),CFrame=CFrame.new(point+Vector3.new(0,h/2,0))*CFrame.Angles(0,i*.8,.18)}):Play()
  end
 end
end
local function scatterOffset(pulse)
 return Vector3.new((pulse%2==0 and 1 or -1)*3,0,(pulse-2)*2)
end
local function groundTarget(d,center,pulse)
 return d.scatter and center+scatterOffset(pulse) or center
end
local function clearGroundCue(character,record)
 if groundCues[character]~=record then return end
 groundCues[character]=nil
 for _,connection in ipairs(record.connections) do connection:Disconnect() end
 for _,piece in ipairs(record.pieces) do
  piece:Destroy()
  release(piece)
 end
end
local function groundCue(character,d,seq,point,direction,color,life,compact,findFloor)
 if life~=life or life<=0 then return end
 if not character or type(seq)~="number" then
  arc(findFloor(point,character),direction,d.radius,360,color,life,"SkillTelegraph",compact)
  return
 end
 local record={seq=seq,connections={},pieces={}}
 local function isLive()
  if not character.Parent or character:GetAttribute("TLTDeathFalling") then return false end
  local current=character:GetAttribute("K0AttackSeq")
  local mode=character:GetAttribute("K0State")
  if type(current)=="number" and current>=seq then
   return current==seq and mode=="Attack" and character:GetAttribute("K0SkillId")==d.id
  end
  return mode~="Dead"
 end
 if not isLive() then return end
 arc(findFloor(point,character),direction,d.radius,360,color,life,"SkillTelegraph",compact,record.pieces)
 if #record.pieces==0 then return end
 groundCues[character]=record
 local function refresh()
  if not isLive() then clearGroundCue(character,record) end
 end
 for _,attribute in ipairs({"K0State","K0AttackSeq","K0SkillId","TLTDeathFalling"}) do
  table.insert(record.connections,character:GetAttributeChangedSignal(attribute):Connect(refresh))
 end
 table.insert(record.connections,character.AncestryChanged:Connect(refresh))
 task.delay(life,function() clearGroundCue(character,record) end)
end
local function queueIncoming(character,d,center,seq,firstContact,now)
 local bomb=Bomb.get(d.id)
 local lead=bomb and bomb.flight or HeroVFX.groundLead(d)
 if not lead or not character or type(seq)~="number" then return end
 for pulse=1,d.pulses do
  local landingAt=firstContact+(pulse-1)*d.interval
  local target=groundTarget(d,center,pulse)
  local function valid()
   local latest=confirmed[character]
   if not character.Parent or character:GetAttribute("TLTDeathFalling") or not latest
    or latest.seq~=seq or latest.id~=d.id or latest.pulse>=pulse then return false end
   local current=character:GetAttribute("K0AttackSeq")
   return type(current)~="number" or current<seq
    or current==seq and character:GetAttribute("K0State")=="Attack" and character:GetAttribute("K0SkillId")==d.id
  end
  local waitTime=landingAt-lead-now
  if bomb then
   if pulse>1 then
    task.delay(math.max(0,waitTime-.11),function()
     local prop=props[character]
     if valid() and prop and prop.seq==seq and prop.id==d.id and (prop.releasedPulse or 0)==pulse-1 then
      showProp(prop,true)
     end
    end)
   end
   task.delay(math.max(0,waitTime),function()
    if not valid() then return end
    local prop=props[character]
    if not prop or prop.seq~=seq or prop.id~=d.id or not prop.model.PrimaryPart then return end
    local launch=prop.model.PrimaryPart.CFrame
    prop.releasedPulse=pulse
    showProp(prop,false)
    HeroVFX.bombFlight(character,d,bomb,launch,target,seq,pulse,landingAt,valid)
   end)
  else
   task.delay(math.max(0,waitTime),HeroVFX.incoming,character,d,target,seq,pulse,landingAt,valid)
  end
 end
end
local function showShieldRecipients(id,recipients)
 local player=Players.LocalPlayer
 local own=player and player.Character
 if own then
  for _,recipient in pairs(recipients) do
   if recipient==own then HeroVFX.shieldGrant(own,id);break end
  end
 end
 for _,recipient in pairs(recipients) do
  if recipient~=own then HeroVFX.shieldGrant(recipient,id) end
 end
end
function Visual.play(character,id,origin,center,pulse,points,attackSeq,firedAt,startedAt,castDirection,shieldRecipients,stepFrom,fanEndpoints)
 local d=byId[id];if not d or not d.advanced or typeof(origin)~="Vector3" or typeof(center)~="Vector3" then return end
 local bomb=Bomb.get(id)
 local profile=Presentation.get(d);if not profile then return end
 local fanLanes=profile.fanLanes
 local rallyingSlash=id=="knight.steel_knight.rallying_slash"
 local steamBurst=id=="mage.pyro.steam_burst"
 local cyclone=id=="knight.steel_knight.twin_cyclone"
 local steelSweep=id=="knight.steel_knight.steel_sweep"
 local cragCleave=id=="dwarf.iron_axe.crag_cleave"
 local groundBurst=id=="elf.magic_archer.vine_burst" or id=="mage.pyro.lava_eruption"
 local authoredRelease=fanLanes or rallyingSlash or steamBurst or id=="mage.pyro.cinder_ring"
  or cyclone or id=="dwarf.iron_axe.returning_echo" or id=="elf.magic_archer.echo_arrows"
  or steelSweep or cragCleave or groundBurst
 if type(pulse)~="number" or pulse~=pulse or pulse<0 or pulse>d.pulses or pulse%1~=0 then return end
 local now=workspace:GetServerTimeNow()
 if type(firedAt)=="number" and (firedAt~=firedAt or now-firedAt>.6 or firedAt-now>.5) then return end
 local opening=pulse==0 and (type(startedAt)=="number" and startedAt or now)
 if opening and (opening~=opening or opening>now+.1) then return end
 local grant=opening and d.shield and type(shieldRecipients)=="table"
 local expired=opening and now>=opening+d.windup+(d.hitDelay or 0)
 if expired and (not grant or now-opening>.42) then return end
 if character and type(attackSeq)=="number" then
  local current=character:GetAttribute("K0AttackSeq")
  if pulse==0 and type(current)=="number" and current>attackSeq then return end
  local old=confirmed[character]
  if old and (attackSeq<old.seq or attackSeq==old.seq and old.id==id and pulse<=old.pulse) then return end
  confirmed[character]={seq=attackSeq,id=id,pulse=pulse}
  if not expired then
   local cue=groundCues[character]
   if cue and cue.seq<=attackSeq then clearGroundCue(character,cue) end
   HeroVFX.endWindup(character,attackSeq)
   HeroVFX.endIncoming(character,attackSeq,pulse)
  end
 end
 if grant then showShieldRecipients(id,shieldRecipients) end
 if expired then return end
 if pulse~=0 then BowMotion.confirmPulse(character,id,pulse,attackSeq,firedAt,startedAt,workspace:GetServerTimeNow()) end
 local compact=HeroVFX.isOtherHero(character)
 local color=Palette.resolve(id:match('^(%a+)'),id)or colors.steel
 local findFloor=bomb and Bomb.floor or ground
 local direction=center-origin
 if (d.form=="cone" or d.form=="melee" or cyclone) and typeof(castDirection)=="Vector3"
  and castDirection.Magnitude>.01 and castDirection.Magnitude<math.huge then
  direction=castDirection.Unit
 end
 if direction.Magnitude<.01 then
  local root=character and character:FindFirstChild("HumanoidRootPart")
  direction=root and root.CFrame.LookVector or Vector3.new(0,0,-1)
 end
 if pulse~=0 and not compact and not bomb and d.form~="chain" and id~="elf.marksman.crossfire"
  and id~="dwarf.gunner.quickfire" and not authoredRelease then
  PixelFX.skill(character,id,origin,center,pulse,points,attackSeq,firedAt,direction)
 end
 if id=="mage_wind_lance" then WindLance.play(character,origin,center,pulse,points,attackSeq,firedAt,startedAt,d.windup);return end
 if pulse==0 then
  if character then
   branchProp(character,d,attackSeq)
   HeroVFX.windup(character,d,profile.motion,profile.effect,origin,attackSeq,opening,windupSocket(character,profile.motion))
   if typeof(stepFrom)=="Vector3" then HeroVFX.stepWake(character,d,stepFrom,origin,opening) end
  end
  local firstContact=opening+d.windup+(d.hitDelay or 0)
  if d.form=="ground" then
   groundCue(character,d,attackSeq,groundTarget(d,center,1),direction,color,firstContact-now,compact,findFloor)
  end
  if d.form=="ground" or bomb then queueIncoming(character,d,center,attackSeq,firstContact,now) end
  return
 end
 local first=source(character,origin,d)
 local prop=props[character]
 if bomb and prop and prop.seq==attackSeq and prop.id==id and (prop.releasedPulse or 0)<pulse then
  prop.releasedPulse=pulse
  showProp(prop,false)
 end
 local floor=ground(d.form=="area" and center or origin,character)
 local targetFloor=findFloor(center,character)
 local effect=profile.effect
 if fanLanes and type(fanEndpoints)~="table" then
  fanEndpoints=Geometry.sector(origin,direction,d.range,d.angle,fanLanes-1)
 end
 local primary=HeroVFX.skill(character,id,origin,center,pulse,points,first,direction,fanEndpoints)
 local ultimateSignature=primary and primary:GetAttribute("UltimateSignature")
 -- Compact casts keep the authored shape and radius markers. Confirmed hits
 -- already have their own target feedback in K0HitEffects.
 local decorate=not compact or not primary
 -- Core geometry is rendered before optional impact decoration.
 if d.form=="chain" then
  if not (primary and primary:GetAttribute("ChainCore")) then
   local from=first
   for i=1,math.min(type(points)=="table" and #points or 0,d.maxTargets) do
    local target=points[i]
    if typeof(target)=="Vector3" then
     segment(from,target,color,.15,.1,"ChainFallback")
     from=target
    end
   end
  end
 elseif d.form=="self" then
  local root=character and character:FindFirstChild("HumanoidRootPart")
  local life=d.shieldDuration or 4
  local p=part("PersonalWard",color,Enum.PartType.Ball,Vector3.new(5,6,5),CFrame.new(root and root.Position or origin),life,.88)
  if p and root then
   p.Anchored=false;p.Massless=true
   local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=p;weld.Parent=p
   local connections={}
   local function clear()
    for _,connection in ipairs(connections) do connection:Disconnect() end
    if p.Parent then p:Destroy() end
   end
   connections[1]=character:GetAttributeChangedSignal("K0Shield"):Connect(function()
    if (character:GetAttribute("K0Shield") or 0)<=0 then clear() end
   end)
   connections[2]=character.AncestryChanged:Connect(function() if not character.Parent then clear() end end)
   task.delay(life,clear)
  end
 elseif d.form=="ground" or d.detonate then
  arc(targetFloor,direction,d.radius,360,color,.4,"ImpactBoundary",compact)
  if d.scatter and pulse<d.pulses and character and type(attackSeq)=="number" and type(startedAt)=="number" then
   local nextAt=startedAt+d.windup+(d.hitDelay or 0)+pulse*d.interval
   -- Recover the locked center from this confirmed scatter position.
   local nextPoint=center-scatterOffset(pulse)+scatterOffset(pulse+1)
   groundCue(character,d,attackSeq,nextPoint,direction,color,math.min(nextAt-now,d.interval),compact,findFloor)
  end
  if effect=="lightning" then lightning(center+Vector3.new(0,12,0),center,color)
  elseif effect=="vine" then
   -- HeroVFX owns ground-planted roots; no duplicate upright helix.
  elseif effect=="earth" or effect=="lava" or effect=="frost" then
   if not primary then spikes(targetFloor,direction,d.radius,360,color,effect)end
   if effect=="lava" and decorate and not ultimateSignature and not (groundBurst and primary) then arc(targetFloor+Vector3.new(0,.1,0),direction,d.radius*.6,360,colors.fire,.4,"LavaFissure") end
  elseif effect=="steam" then
   -- HeroVFX owns short translucent rising vapor.
  end
  if bomb then
   local burst=targetFloor+Vector3.yAxis*Bomb.radius
   if not primary then impact(burst,color,.75) end
   Audio.play("impact",burst,"dwarf",id,character,Players.LocalPlayer~=nil and Players.LocalPlayer.Character==character)
  elseif decorate and not ultimateSignature and not ((steamBurst or groundBurst) and primary) then
   impact(center,color,2)
  end
 elseif effect=="vine" then
  -- Keep the actual cone boundary if optional roots are culled.
  if d.form=='cone'then arc(floor,direction,d.range,d.angle,color,.3,'SkillSector')end
 elseif fanLanes then
  if not (primary and primary:GetAttribute("FanRelease")) then
   for lane=1,fanLanes do
    local target=fanEndpoints[lane]
    if typeof(target)=="Vector3" and (target-origin).Magnitude>.15 and (target-origin).Magnitude<=d.range+.01 then
     local launch=Geometry.fanLaunch(origin,first,target)
     if effect=="arrow" then arrow(launch,target,color,character)
     else segment(launch,target,color,.12,.07,"ShotPellet") end
    end
   end
  end
 elseif effect=="arrow" then
  if d.form=="cone" and ultimateSignature~="VolleyCrown" then
   for _,target in ipairs(Geometry.sector(first,direction,d.range,d.angle,4)) do arrow(first,target,color,character) end
  elseif d.form~="cone" and not (primary and primary:GetAttribute("CrossfireTrace")) then
   local hasWake=primary and (primary:GetAttribute("RetreatingShotWake") or primary:GetAttribute("GlidingShotWake")
    or primary:GetAttribute("ReleaseTrace"))
   arrow(first,center,color,character,hasWake)
  end
 elseif effect=="axe" then
  if not primary then
  local from,to=origin,center;if d.returning and pulse==2 then from,to=center,origin end
  segment(from,to,color,.2,.08,"AxeWake")
  local axis=to-from
  if axis.Magnitude>.01 then
   local cf=CFrame.lookAt(to,to+axis)
   segment(cf:PointToWorldSpace(Vector3.new(0,-.6,0)),cf:PointToWorldSpace(Vector3.new(0,.7,0)),colors.earth,.2,.12,"ThrownAxeHandle")
   segment(cf:PointToWorldSpace(Vector3.new(-.45,.45,0)),cf:PointToWorldSpace(Vector3.new(.45,.45,0)),color,.2,.3,"ThrownAxeBlade")
  end
  end
 elseif effect=="bullet" then
  if d.form=="cone" then
   for _,target in ipairs(Geometry.sector(first,direction,d.range,d.angle,4)) do segment(first,target,color,.12,.07,"ShotPellet") end
  elseif not (primary and primary:GetAttribute("ReleaseTrace")) then
   segment(first,center,color,.12,.08,"RifleTracer")
  end
  if decorate then impact(first,color,.8) end
 elseif d.form=="area" or d.form=="cone" or d.form=="melee" then
  local angle=Presentation.sector(d);local radius=Presentation.radius(d)
  arc(floor,direction,radius,angle,color,.3,"SkillSector",compact)
  if effect=="earth" or effect=="frost" then if not primary then spikes(floor,direction,radius,angle,color,effect)end
  elseif effect=="slash" and ((cragCleave and not primary) or (profile.motion~="spin" and profile.motion~="chop"
   and profile.motion~="cross" and profile.motion~="thrust" and profile.motion~="counter" and id~="dwarf_low_sweep"
   and not (primary and (steelSweep or primary:GetAttribute("CrescentCutEdge") or primary:GetAttribute("RallyingSlashEdge"))))) then
   arc(origin,direction,radius*.75,angle,color,.16,"BladeCrescent")
  elseif effect=="shield" then
   local chargeEdge=id=="knight.steel_knight.breaker_charge" and primary and primary:GetAttribute("PrimaryIconCue")
   if not primary or (not ultimateSignature and not chargeEdge and id~="dwarf.iron_axe.iron_shoulder") then
   local flat=Vector3.new(direction.X,0,direction.Z)
   local delta=flat.Magnitude>.001 and flat.Unit or Vector3.new(0,0,-1)
   local at=origin+delta*2
   part("ShieldContact",color,Enum.PartType.Block,Vector3.new(2.2,2.6,.12),CFrame.lookAt(at,at+delta),.18,.65)
   end
  elseif effect=="fire"then
   -- HeroVFX owns the cinder circle, ember wake and searing crown. A second
   -- full ring would erase their silhouettes; the SkillSector above remains.
  elseif (effect=="holy" or effect=="water") and not ultimateSignature then arc(floor+Vector3.new(0,.55,0),direction,radius*.65,angle,color,.35,"ElementalWave") end
 else
  if effect=="lightning" then
   if not primary or(id~="mage.cryo.thunder_spear" and id~="mage.cryo.lightning_line")then lightning(first,center,color)end
  elseif primary and primary:GetAttribute("ArtSilhouette")then
   -- The primary owns its length/shape; a full legacy ray would hide the new silhouette.
  else
   segment(first,center,color,.2,effect=="frost" and .2 or .16,"ElementalTrail")
   if not primary and(effect=="earth" or effect=="frost")then spikes(targetFloor,direction,1,100,color,effect)end
   impact(center,color,1.2)
  end
 end
 if not compact and not bomb and d.form~="chain" and id~="elf.marksman.crossfire" and not authoredRelease and type(points)=="table" then
  for i=1,math.min(#points,4) do impact(points[i],color,.7) end
 end
end
local started=false
function Visual.start()
 if started then return end;started=true
 RS:WaitForChild("Remotes"):WaitForChild("K0AdvancedEffect").OnClientEvent:Connect(Visual.play)
end
return Visual
