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
local Palette=require(RS.Shared.CombatVFXPalette)
local Visual={}
local byId={};for _,list in pairs(Config.Skills) do for _,d in ipairs(list) do byId[d.id]=d end end
local colors=Palette.colors
local active=0
local confirmed=setmetatable({},{__mode="k"})
local function part(name,color,shape,size,cf,life,transparency)
 if active>=128 then return nil end
 active+=1
 local p=Instance.new("Part");p.Name=name;p.Shape=shape;p.Size=size;p.CFrame=cf
 p.Material=Enum.Material.Neon;p.Color=color;p.Transparency=transparency or .25
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=workspace
 Debris:AddItem(p,life+.05)
 task.delay(life+.05,function() active=math.max(0,active-1) end)
 Tween:Create(p,TweenInfo.new(life,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1}):Play()
 return p
end
local function segment(first,last,color,life,width,name)
 local length=(last-first).Magnitude;if length<.02 then return end
 return part(name or "SkillStreak",color,Enum.PartType.Block,Vector3.new(width or .1,width or .1,length),CFrame.lookAt((first+last)/2,last),life)
end
local function ground(position,character)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=character and {character} or {};params.RespectCanCollide=true
 local hit=workspace:Raycast(position+Vector3.new(0,2,0),Vector3.new(0,-18,0),params)
 return hit and hit.Position+Vector3.new(0,.08,0) or position-Vector3.new(0,2.7,0)
end
local function arc(center,direction,radius,angle,color,life,name)
 local points=Geometry.sector(center,direction,radius,angle,angle>=359 and 24 or 12)
 for i=1,#points-1 do
  local p=segment(points[i],points[i+1],color,life,.07,name)
  if p and(name=="SkillSector"or name=="SkillTelegraph")then p.Transparency=.65 end
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
local function arrow(first,last,color,character)
 segment(first,last,color,.14,.06,"ArrowWake")
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
local props=setmetatable({},{__mode="k"})
local function clearProp(character)
 local record=props[character];if not record then return end
 props[character]=nil
 for _,connection in ipairs(record.connections) do connection:Disconnect() end
 for p,value in pairs(record.hidden) do if p.Parent then p.LocalTransparencyModifier=value end end
 if record.model.Parent then record.model:Destroy() end
end
local function firearm(character,d,seq)
 if d.branch~="gunner" then return end
 clearProp(character)
 local arm=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
 if not arm then return end
 local model=Instance.new("Model");model.Name="BranchSkillProp";model.Parent=character
 local record={model=model,hidden={},connections={}};props[character]=record
 -- The temporary skill prop replaces the axe visually, never in inventory.
 local grip=character:FindFirstChild("WeaponGrip",true) or character:FindFirstChild("SwordGrip",true)
 local appearance=grip and grip.Parent
 if appearance then for _,p in ipairs(appearance:GetDescendants()) do
  if p:IsA("BasePart") then record.hidden[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end
 end end
 local function piece(name,size,offset,color,shape)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Shape=shape or Enum.PartType.Block;p.Color=color;p.Material=Enum.Material.Metal
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.CFrame=arm.CFrame*CFrame.new(0,-.25,0)*CFrame.Angles(-math.pi/2,0,0)*offset;p.Parent=model
  local weld=Instance.new("WeldConstraint");weld.Part0=arm;weld.Part1=p;weld.Parent=p;return p
 end
 if d.element=="bomb" then
  piece("Bomb",Vector3.one*.65,CFrame.new(0,-.35,-.25),Color3.fromRGB(65,66,72),Enum.PartType.Ball)
  piece("Fuse",Vector3.new(.08,.25,.08),CFrame.new(0,.05,-.25),colors.bomb)
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
 local function cancelled()
  if not character.Parent or character:GetAttribute("K0State")~="Attack" or character:GetAttribute("K0AttackSeq")~=seq then clearProp(character) end
 end
 for _,attribute in ipairs({"K0State","K0AttackSeq"}) do table.insert(record.connections,character:GetAttributeChangedSignal(attribute):Connect(cancelled)) end
 table.insert(record.connections,character.AncestryChanged:Connect(cancelled))
 task.delay(d.windup+d.active+d.recovery+.1,function() if props[character]==record then clearProp(character) end end)
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
local function rain(center,radius,color,effect,character)
 for i=1,5 do
  local a=i*2.39996;local r=radius*math.sqrt(i/6)
  local target=center+Vector3.new(math.cos(a)*r,0,math.sin(a)*r)
  local from=target+Vector3.new(-1.5,7+i%3,0)
  if effect=="rain" then arrow(from,target,color,character)
  else segment(from,target,color,.2,effect=="hail" and .18 or .35,effect=="hail" and "HailShard" or "AshfallEmber") end
 end
end
function Visual.play(character,id,origin,center,pulse,points,attackSeq,firedAt,startedAt)
 local d=byId[id];if not d or not d.advanced or typeof(origin)~="Vector3" or typeof(center)~="Vector3" then return end
 local profile=Presentation.get(d);if not profile then return end
 if type(pulse)~="number" or pulse~=pulse or pulse<0 or pulse%1~=0 then return end
 if type(firedAt)=="number" and (firedAt~=firedAt or workspace:GetServerTimeNow()-firedAt>.6 or firedAt-workspace:GetServerTimeNow()>.5) then return end
 if character and type(attackSeq)=="number" and pulse>0 then
  local old=confirmed[character]
  if old and (attackSeq<old.seq or attackSeq==old.seq and old.id==id and pulse<=old.pulse) then return end
  confirmed[character]={seq=attackSeq,id=id,pulse=pulse}
 end
 if pulse~=0 then BowMotion.confirmPulse(character,id,pulse,attackSeq,firedAt,startedAt,workspace:GetServerTimeNow()) end
 if pulse~=0 then PixelFX.skill(character,id,origin,center,pulse,points,attackSeq,firedAt) end
 if id=="mage_wind_lance" then WindLance.play(character,origin,center,pulse,points,attackSeq,firedAt,startedAt,d.windup);return end
 local color=Palette.resolve(id:match('^(%a+)'),id)or colors.steel
 local direction=center-origin
 if direction.Magnitude<.01 then
  local root=character and character:FindFirstChild("HumanoidRootPart")
  direction=root and root.CFrame.LookVector or Vector3.new(0,0,-1)
 end
 if pulse==0 then
  if character then firearm(character,d,attackSeq) end
  if d.form=="ground" then
   for i=1,d.scatter and d.pulses or 1 do
    local target=center+(d.scatter and Vector3.new((i%2==0 and 1 or -1)*3,0,(i-2)*2) or Vector3.zero)
    arc(ground(target,character),direction,d.radius,360,color,d.windup+(i-1)*(d.interval or .3),"SkillTelegraph")
   end
  end
  return
 end
 -- The server rotates its line hit direction but retains cast.center in the
 -- visual event. Project the same single 18-degree rotation for the even beat.
 if d.crosscut and d.form=="line" and pulse%2==0 then
  direction=CFrame.Angles(0,math.rad(18),0):VectorToWorldSpace(direction)
  center=origin+direction
 end
 local first=source(character,origin,d)
 local floor=ground(d.form=="area" and center or origin,character)
 local targetFloor=ground(center,character)
 local effect=profile.effect
 HeroVFX.skill(character,id,origin,center,pulse,points,first)
 -- Core geometry is rendered before optional impact decoration.
 if d.form=="chain" then
  local from=first
  for i=1,math.min(type(points)=="table" and #points or 0,8) do lightning(from,points[i],color);from=points[i] end
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
  arc(targetFloor,direction,d.radius,360,color,.4,"ImpactBoundary")
  if effect=="rain" or effect=="hail" or effect=="ash" then rain(targetFloor,d.radius,color,effect,character)
  elseif effect=="lightning" then lightning(center+Vector3.new(0,12,0),center,color)
  elseif effect=="vine" then
   -- HeroVFX owns ground-planted roots; no duplicate upright helix.
  elseif effect=="earth" or effect=="lava" or effect=="frost" then
   spikes(targetFloor,direction,d.radius,360,color,effect)
   if effect=="lava" then arc(targetFloor+Vector3.new(0,.1,0),direction,d.radius*.6,360,colors.fire,.4,"LavaFissure") end
  elseif effect=="shell" then
   -- HeroVFX owns the falling metal shell and short wake.
  elseif effect=="bomb" then
   local p=part("BlastSmoke",Color3.fromRGB(105,99,93),Enum.PartType.Ball,Vector3.one,CFrame.new(center),.4,.7)
   if p then Tween:Create(p,TweenInfo.new(.4),{Size=Vector3.one*3}):Play() end
  elseif effect=="steam" then
   -- HeroVFX owns short translucent rising vapor.
  end
  impact(center,color,2)
 elseif effect=="vine" then
  -- Keep the actual cone boundary if optional roots are culled.
  if d.form=='cone'then arc(floor,direction,d.range,d.angle,color,.3,'SkillSector')end
 elseif effect=="arrow" then
  if d.form=="cone" then
   for _,target in ipairs(Geometry.sector(first,direction,d.range,d.angle,4)) do arrow(first,target,color,character) end
  else arrow(first,center,color,character) end
 elseif effect=="axe" then
  local from,to=origin,center;if d.returning and pulse==2 then from,to=center,origin end
  segment(from,to,color,.2,.08,"AxeWake")
  local axis=to-from
  if axis.Magnitude>.01 then
   local cf=CFrame.lookAt(to,to+axis)
   segment(cf:PointToWorldSpace(Vector3.new(0,-.6,0)),cf:PointToWorldSpace(Vector3.new(0,.7,0)),colors.earth,.2,.12,"ThrownAxeHandle")
   segment(cf:PointToWorldSpace(Vector3.new(-.45,.45,0)),cf:PointToWorldSpace(Vector3.new(.45,.45,0)),color,.2,.3,"ThrownAxeBlade")
  end
 elseif effect=="bullet" then
  if d.form=="cone" then
   for _,target in ipairs(Geometry.sector(first,direction,d.range,d.angle,4)) do segment(first,target,color,.12,.07,"ShotPellet") end
  else segment(first,center,color,.12,.08,"RifleTracer") end
  impact(first,color,.8)
 elseif d.form=="area" or d.form=="cone" or d.form=="melee" then
  local angle=Presentation.sector(d);local radius=Presentation.radius(d)
  arc(floor,direction,radius,angle,color,.3,"SkillSector")
  if effect=="earth" or effect=="frost" then spikes(floor,direction,radius,angle,color,effect)
  elseif effect=="slash" and profile.motion~="chop"and profile.motion~="cross"and profile.motion~="thrust"and profile.motion~="counter"and id~="dwarf_low_sweep"then arc(origin,direction,radius*.75,angle,color,.16,"BladeCrescent")
  elseif effect=="shield" then
   local flat=Vector3.new(direction.X,0,direction.Z)
   local delta=flat.Magnitude>.001 and flat.Unit or Vector3.new(0,0,-1)
   local at=origin+delta*2
   part("ShieldContact",color,Enum.PartType.Block,Vector3.new(2.2,2.6,.12),CFrame.lookAt(at,at+delta),.18,.65)
  elseif effect=="fire" or effect=="holy" or effect=="water" then arc(floor+Vector3.new(0,.55,0),direction,radius*.65,angle,color,.35,"ElementalWave") end
 else
  if effect=="lightning" then lightning(first,center,color)
  else
   segment(first,center,color,.2,effect=="frost" and .2 or .16,"ElementalTrail")
   if effect=="earth" or effect=="frost" then spikes(targetFloor,direction,1,100,color,effect) end
   impact(center,color,1.2)
  end
 end
 if d.shield and d.form~="self" then arc(floor,direction,2.7,360,color,.5,"GuardGranted") end
 if type(points)=="table" then for i=1,math.min(#points,4) do impact(points[i],color,.7) end end
end
local started=false
function Visual.start()
 if started then return end;started=true
 RS:WaitForChild("Remotes"):WaitForChild("K0AdvancedEffect").OnClientEvent:Connect(Visual.play)
end
return Visual
