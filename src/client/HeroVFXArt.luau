-- ART review: readable primary silhouettes, using the existing world-space budgets.
local S=require(script.Parent.HeroVFXSurfaces)
local Geometry=require(script.Parent.SkillEffectGeometry)
local Art={axeCatchSeconds=.075}
local UP=Vector3.yAxis
local types={
 ['mage.pyro.ember_lance']='EmberLance',['mage.pyro.flame_dart']='FlameDart',
 ['mage.pyro.magma_spear']='MagmaSpear',['mage.pyro.molten_line']='MoltenLine',
 ['mage.common.mana_bolt']='ManaCrystal',['mage.common.water_ball']='WaterBall',
 ['mage.common.gravity']='GravityCore',['mage.pyro.steam_burst']='SteamPuffs',
 ['mage.pyro.stone_lance']='StoneLance',['dwarf.iron_axe.iron_shoulder']='IronShoulder',
 ['mage.pyro.earth_rise']='EarthPillars',['knight.common.provoke']='ChallengeVoice',
 ['mage.cryo.frost_lance']='FrostLance',['mage.cryo.ice_shard']='IceShard',
 ['mage.cryo.shatter_dart']='ShatterDart',['mage.cryo.glacial_spike']='GlacialSpike',
 ['mage.cryo.thunder_spear']='ThunderSpear',['mage.cryo.lightning_line']='LightningLine',
 ['mage.cryo.ice_ward']='IceWard',['mage.cryo.froststorm']='Froststorm',
 ['knight.paladin.oath_challenge']='OathChallenge',
 ['dwarf.iron_axe.breaker_throw']='BreakerThrow',['elf.marksman.mark_breaker']='MarkBreaker',
 ['knight.paladin.dawn_burst']='DawnBurst',['dwarf.gunner.shell_burst']='ShellBurst',
 ['elf.magic_archer.bloom_shot']='BloomShot',
 ['knight.steel_knight.guardian_counter']='GuardianCounter',
 ['dwarf.gunner.piercing_round']='PiercingRound',
 ['knight.paladin.oathbreaker_strike']='OathbreakerStrike',
 ['dwarf.gunner.gunner_shot']='GunnerShot',['elf.magic_archer.spark_volley']='SparkVolley',
}
function Art.kind(id)return types[id]end
local function orient(r,p,cf)
 if p then local face=r.faces[#r.faces];face.cf=cf;p.CFrame=cf end
end
local function gem(r,name,tip,axis,length,width,color,material)
 local frame=CFrame.lookAt(tip,tip+axis)
 local waist=tip-axis*length*.62
 local offsets={frame.RightVector*width,frame.UpVector*width,-frame.RightVector*width,-frame.UpVector*width}
 for i=1,4 do
  local shade=i%2==0 and color:Lerp(r.hot,.28) or color:Lerp(Color3.new(0,0,0),.18)
  local faceMaterial=material==Enum.Material.Ice and i==1 and Enum.Material.Neon or material
  S.triangle(r,name,tip,waist+offsets[i],waist+offsets[i%4+1],shade,.22,faceMaterial)
  S.triangle(r,name,tip-axis*length,waist+offsets[i%4+1],waist+offsets[i],shade,.3,material)
 end
end
local function leaf(r,at,axis,side,size,name)
 local tip=at+axis*size;local mid=at+axis*size*.48
 S.triangle(r,name,at,mid+side*size*.32,tip,r.color,.24,Enum.Material.SmoothPlastic)
 S.triangle(r,name,at,tip,mid-side*size*.32,r.color:Lerp(r.hot,.38),.22,Enum.Material.SmoothPlastic)
 S.bar(r,'LeafMidrib',at+axis*size*.18,tip,.045,r.color:Lerp(r.hot,.55),.2,Enum.Material.Neon)
end
local function spearStart(c)
 local socket=c.muzzle
 if socket and (c.last-socket):Dot(c.dir)>.1 then return socket end
 return c.first
end
local function releaseWake(r,c,line,name,width,hold,duration)
 local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
 if (c.last-start).Magnitude<=.05 then return end
 local wake=line(r,name,function(u)
  local retract=math.clamp((u*r.life-hold)/duration,0,1)
  return start:Lerp(c.last,1-(1-retract)^2),c.last
 end,width,r.color,width*.55,true)
 if wake then wake.fadeDuration=hold+duration end
 return wake
end
function Art.strokes(r,c,line,curve)
 local kind=types[c.id]
 local function stroke(name,a,b,w,color)line(r,name,function()return a,b end,w,color)end
 if kind=='OathbreakerStrike'then
  curve(r,'OathbreakerEdge',function(t,u)
   local bearing=math.rad(c.angle)*(.46-.91*t)
   local reach=c.radius*(.50+.24*math.sin(t*math.pi)+.08*u)
   return c.first+(c.flat*math.cos(bearing)+c.right*math.sin(bearing))*reach
    +UP*(3.6-4.9*t-.40*u)
  end,r.compact and 4 or 6,r.compact and .48 or .76,r.hot,true)
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='GunnerShot'then
  local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
  local delta=c.last-start
  if delta.Magnitude>.05 then
   local tracer=line(r,'GunnerShotTracer',function(u)
    local retract=math.clamp((u*r.life-.039)/.08,0,1)
    return start:Lerp(c.last,.97*(1-(1-retract)^2)),c.last
   end,.13,r.color,.053,true)
   if tracer then tracer.fadeDuration=.13;r.model:SetAttribute('ReleaseTrace',true) end
   if not r.compact then
    local flash=line(r,'GunnerShotMuzzle',function(u)
     return start,start+delta.Unit*math.min(delta.Magnitude,.94)*(1-.5*u)
    end,.64,Color3.fromRGB(255,174,58),.092,true)
    if flash then flash.fadeDuration=.072 end
   end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='SparkVolley'then
  local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
  local delta=c.last-start
  if delta.Magnitude>.05 then
   local side=c.pulse==2 and -1 or 1
   local rise=math.min(delta.Magnitude*.12,c.pulse==3 and .47 or .32)
   local wake=releaseWake(r,c,line,'SparkVolleyWake',.115,.03,.105)
   if wake then r.model:SetAttribute('ReleaseTrace',true) end
   curve(r,'SparkVolleyFork',function(t,u)
    local age=math.clamp(u*r.life/.13,0,1)
    local head=.45+.55*age
    local along=head-t*math.min(.36,2.9/delta.Magnitude)
    local corner=1-math.abs(2*t-1)
    return start+delta*along+(c.right*side+UP*.58)*rise*corner*(1-.55*age)
   end,2,c.pulse==3 and .22 or .16,r.hot,true)
   if not r.compact and c.pulse==3 then
    local fork=line(r,'SparkVolleyTip',function(u)
     return c.last-delta.Unit*math.min(delta.Magnitude*.23,1.25)+UP*rise*(1+u),c.last
    end,.22,r.hot,.063,true)
    if fork then fork.fadeDuration=.18 end
   end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='ManaCrystal'then
  local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
  local span=c.last-start
  local terminal=span.Magnitude<=.05
  if not terminal then
   local wake=releaseWake(r,c,line,'ManaBoltWake',.11,.036,.084)
   if wake then r.model:SetAttribute('ReleaseTrace',true) end
  end
  local length=terminal and 1.25 or math.min(span.Magnitude,2.4)
  local axis=terminal and c.dir or span.Unit
  local frame=CFrame.lookAt(c.last,c.last+axis)
  for side=-1,1,2 do
   curve(r,'ManaBoltEdge',function(t,u)
    local spread=math.sin(t*math.pi)*math.min(length*.47,.86)*(.72+.55*u)
    return c.last-axis*length*(1-t+.33*u)+(frame.RightVector*side+frame.UpVector*.5)*spread
   end,1,.29,side==1 and r.hot or r.color,true)
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='DawnBurst'then
  local count=r.compact and 4 or 6
  local at=c.floor+UP*.16
  for i=1,count do
   local a=(i-1)*math.pi*2/count
   local radial=c.flat*math.cos(a)+c.right*math.sin(a)
   local reach=c.radius*(i%2==0 and .71 or .88)
   local ray=line(r,'DawnBurstRay',function(u)
    local t=1-(1-math.min(u*r.life/.155,1))^2
    return at+radial*reach*(.10+.57*t),
     at+radial*reach*(.25+.75*t)+UP*(.45+.62*t)
   end,.28,i%2==0 and r.color or r.hot,.11,true)
   if ray then ray.fadeDuration=.25 end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='ShellBurst'then
  local at=c.floor+UP*.16
  local camera=workspace.CurrentCamera
  local side=camera and camera.CFrame.RightVector or c.right
  side=Vector3.new(side.X,0,side.Z)
  side=side.Magnitude>.01 and side.Unit or c.right
  local jet=line(r,'ShellBurstJet',function(u)
   local swell=1-(1-math.min(u*r.life/.095,1))^3
   -- Leave the base on the impact and show the top alongside the target.
   return at+UP*(.16+swell*.58),
    at+UP*(.92+swell*3.62)+(side*1.85-c.flat*.65)*swell
  end,.64,r.hot,.15,true)
  if jet then jet.fadeDuration=.17 end
  for wing=-1,1,2 do
   local heading=c.right*wing*.88+c.flat*.35
   local blast=line(r,'ShellBurstPressure',function(u)
    local t=1-(1-math.min(u*r.life/.12,1))^3
    return at+heading*c.radius*(.1+.24*t),
     at+heading*c.radius*(.30+.55*t)+UP*(.31+.44*t)
   end,.37,r.color,.07,true)
   if blast then blast.fadeDuration=.21 end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='BloomShot' or kind=='IceShard'then
  local bloom=kind=='BloomShot'
  local wake=releaseWake(r,c,line,bloom and 'BloomShotWake' or 'IceShardWake',
   bloom and .115 or .15,.039,.105)
  if wake then r.model:SetAttribute('ReleaseTrace',true) end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='GuardianCounter'then
  curve(r,'GuardianCounterEdge',function(t,u)
   local bearing=math.rad(c.angle)*(.49-.98*t)
   local reach=c.radius*(.40+.23*math.sin(t*math.pi)+.09*u)
   return c.first+(c.flat*math.cos(bearing)+c.right*math.sin(bearing))*reach
    +UP*(-1.03+3.36*t+.26*math.sin(t*math.pi))
  end,r.compact and 4 or 6,.49,r.hot,true)
  local guard=c.first+c.flat*1.45-c.right*1.02
  for side=-1,1,2 do
   local beat=line(r,'GuardianCounterGuard',function(u)
    local at=guard+c.flat*(.42*math.min(u*4,1))
    return at+UP*.45,at+c.right*side*.70-UP*.49
   end,.19,r.color,.08,true)
   if beat then beat.fadeDuration=.087 end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='PiercingRound'then
  local wake=releaseWake(r,c,line,'PiercingRoundTracer',.18,.044,.095)
  if wake then
   r.model:SetAttribute('ReleaseTrace',true)
   if not r.compact then
    local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
    local delta=c.last-start
    local flash=line(r,'PiercingRoundMuzzle',function(u)
     return start,start+delta.Unit*math.min(delta.Magnitude,.84)*(1-.36*u)
    end,.38,r.hot,.07,true)
    if flash then flash.fadeDuration=.065 end
   end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='OathChallenge'then
  curve(r,'OathChallengeCrown',function(t,u)
   local bearing=math.rad(c.angle)*(.45-.90*t)
   local range=c.radius*(.48+.40*(1-(1-u)^3)-.12*math.abs(2*t-1))
   local height=.68+2.10*math.sin(t*math.pi)^1.4-.34*u
   return c.floor+(c.flat*math.cos(bearing)+c.right*math.sin(bearing))*range+UP*height
  end,r.compact and 4 or 6,.34,r.hot,true)
  r.model:SetAttribute('ForwardOnly',true)
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='BreakerThrow' or kind=='MarkBreaker' or kind=='MagmaSpear'then
  local name=kind=='BreakerThrow' and 'BreakerThrowWake' or kind=='MarkBreaker' and 'MarkBreakerWake' or 'MagmaSpearWake'
  local wake=releaseWake(r,c,line,name,kind=='MagmaSpear' and .24 or kind=='BreakerThrow' and .15 or .085,.045,.12)
  if wake then r.model:SetAttribute('ReleaseTrace',true) end
  if kind=='MagmaSpear'then
   local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
   local span=c.last-start
   local length=math.min(span.Magnitude,4.2)
   if span.Magnitude>.05 then
    local axis=span.Unit
    local basis=CFrame.lookAt(c.last,c.last+axis)
    for side=-1,1,2 do
     curve(r,'MagmaSpearLip',function(t,u)
      local distance=length*(1-.65*u)*(1-t)
      local lift=math.sin(t*math.pi)*(.68+.20*u)
      return c.last-axis*distance+(basis.RightVector*side+basis.UpVector*.38)*lift
     end,1,.32,side==1 and r.hot or r.color,true)
    end
   end
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='ChallengeVoice'then
  for lane=1,3 do curve(r,'IconChallengeVoice',function(t,u)
   local a=t*math.pi
   local radius=.7+lane*.3+u*.45
   return c.first+c.flat*.3+UP*1.1+c.right*math.cos(a)*radius+UP*math.sin(a)*radius
  end,6,.075,r.color)end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='MoltenLine' then
  local first=Vector3.new(c.first.X,c.floor.Y+.08,c.first.Z)
  local delta=Vector3.new(c.last.X-c.first.X,0,c.last.Z-c.first.Z)
  if delta.Magnitude>.1 then
   line(r,'MoltenPulseFront',function(u)
    local head=math.min(1,.04+u*r.life/.09)
    local tail=math.max(0,head-.24*(1-u))
    return first+delta*tail,first+delta*head
   end,.08,Color3.fromRGB(255,149,42),.22)
  end
  r.model:SetAttribute('ArtSilhouette',kind);r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='IceWard'then
  for lane=1,3 do
   local a=(lane-2)*math.pi*2/3
   local radial=c.flat*math.cos(a)+c.right*math.sin(a)
   stroke('IconIceWardCrest',c.first+radial*1.75+UP*.9,c.first+radial*1.75+UP*1.35,.075,r.hot)
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='IronShoulder'then
  local shoulder=c.first-c.right*.68-UP*.28
  local edge=shoulder+c.flat*1.65-UP*.32
  for i=-1,1,2 do
   line(r,'IconShoulderDrive',function(u)
    local advance=c.flat*u*.62
    return shoulder+UP*i*.34+advance,edge+UP*i*.11+advance
   end,.095,Color3.fromRGB(243,172,89),.04)
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='ShatterDart' or kind=='FrostLance' or kind=='GlacialSpike'then
  local length=kind=='ShatterDart' and 1.15 or kind=='GlacialSpike' and 5.3 or 3.6
  local width=kind=='ShatterDart' and .3 or kind=='GlacialSpike' and .95 or .42
  local waist=c.last-c.dir*length*.62
  if kind=='GlacialSpike'then
   local start=spearStart(c)
   if (c.last-start).Magnitude>.1 then
    local wake=line(r,'GlacialSpikeWake',function(u)
     local falloff=math.clamp((u*r.life-.045)/.12,0,1)
     return start:Lerp(c.last,1-(1-falloff)^2),c.last
    end,.19,r.color,.065,true)
    if wake then wake.fadeDuration=.18 end
   end
  elseif kind=='ShatterDart'then
   local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
   local distance=(c.last-start).Magnitude
   if distance>.05 then
    local wake=line(r,'ShatterDartWake',function(u)
     local retract=math.clamp((u*r.life-.027)/.105,0,1)
     return start:Lerp(c.last,.94*(1-(1-retract)^2)),c.last
    end,.145,r.hot,.06,true)
    if wake then wake.fadeDuration=.16 end
   end
  end
  for side=-1,1,2 do
   stroke('IconCrystalEdge',waist+c.right*side*width,c.last,.065,r.hot)
   stroke('IconCrystalRear',c.last-c.dir*length,waist+c.right*side*width,.045,r.color)
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='LightningLine' then
  local first=Vector3.new(c.first.X,c.floor.Y+.18,c.first.Z)
  local last=Vector3.new(c.last.X,c.floor.Y+.18,c.last.Z)
  local span=(last-first).Magnitude
  if span>.05 then
   local travel=.104
   local function front(u)
    local elapsed=u*r.life
    return .10+.90*(1-(1-math.min(1,elapsed/travel))^2)
   end
   local spine=line(r,'IconLightningCorridor',function(u)
    local head=front(u)
    local tail=math.max(0,head-.46+math.max(0,u*r.life-travel)*2.9)
    return first:Lerp(last,tail),first:Lerp(last,head)
   end,.24,r.hot,.36,true)
   if spine then spine.fadeDuration=.20 end
   local count=r.compact and 2 or 3
   for i=1,count do
    local distance=i/(count+1)
    local side=i%2==1 and -1 or 1
    local at=first:Lerp(last,distance)
    -- The fork trails the advancing head. Its centerline projection stays inside the cast.
    local reach=math.min(1.35,span*.22)
    local elbow=at+c.right*side*reach*.53+UP*.56-c.flat*reach*.24
    local tip=at+c.right*side*reach+UP*.87-c.flat*reach*.58
    local function forkGrowth(u) return math.clamp((front(u)-distance)*7,0,1) end
    local base=line(r,'LightningLineFork',function(u)return at,at:Lerp(elbow,forkGrowth(u))end,
     .16,r.color,.10,true)
    if base then base.fadeDuration=.21 end
    if not r.compact then
     local prong=line(r,'LightningLineForkTip',function(u)
      local growth=forkGrowth(u)
      return at:Lerp(elbow,growth),at:Lerp(elbow,growth):Lerp(tip,growth)
     end,.10,r.hot,.045,true)
     if prong then prong.fadeDuration=.21 end
    end
   end
  end
  r.model:SetAttribute('ArtSilhouette',kind);r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='ThunderSpear' then
  local first,last=spearStart(c),c.last
  stroke('IconThunderSpearAxis',first,last,.17,r.hot)
  for i=1,3 do
   local at=first:Lerp(last,.43+i*.12)
   for side=-1,1,2 do
    local elbow=at+c.right*.55*side-c.dir*.65
    stroke('ElectricSpearProng',at,elbow,.08,r.color)
   end
  end
  r.model:SetAttribute('ArtSilhouette',kind);r.model:SetAttribute('PrimaryIconCue',true);return true
 end
 return false
end
function Art.axeFlight(c)
 local from,to=c.first,c.last
 local returning=c.definition.returning and c.pulse%2==0
 if returning then
  from,to=to,from
  local hand=c.character and (c.character:FindFirstChild("RightHand") or c.character:FindFirstChild("Right Arm"))
  if hand and hand:IsA("BasePart") and (hand.Position-to).Magnitude<6 then to=hand.Position end
 elseif types[c.id]=='BreakerThrow'then
  from=Geometry.fanLaunch(from,c.muzzle,to)
 end
 local axis=(to-from).Magnitude>.01 and (to-from).Unit or c.flat
 local reach=c.definition.crosscut and 5 or 2.4
 local approach=returning and -axis*math.min(reach,(to-from).Magnitude) or nil
 return from,to,axis,approach
end
function Art.axe(r,c)
 local from,to,axis,approach=Art.axeFlight(c)
 local returning=approach~=nil
 local breaker=types[c.id]=='BreakerThrow'
 local breakerApproach=breaker and -axis*math.min((to-from).Magnitude*.78,3.5)
 local frame=CFrame.lookAt(to,to+axis)
 local source
 if c.character then for _,model in ipairs(c.character:GetChildren())do
  if model:IsA('Model') and model:GetAttribute('WeaponClassId')=='dwarf'then
   local weapon=model:FindFirstChild('Weapon');if weapon and weapon:IsA('BasePart')then source=weapon;break end
  end
 end end
 local start=#r.faces
 local cloned
 if source then
  local p=S.clone(r,'ThrownAxeSource',source,to)
  if p then
   orient(r,p,CFrame.new(to)*source.CFrame.Rotation)
   cloned=true
   if (c.id=='dwarf.iron_axe.crosscut_axe' or breaker)
    and source.LocalTransparencyModifier<1 and (c.last-c.first).Magnitude>.15 then
    r.heldAxe,r.heldAxeAlpha=source,source.LocalTransparencyModifier
    source.LocalTransparencyModifier=1
    if returning then r.catchAxe=p end
    if breaker then r.heldAxeUntil=r.at+.15 end
   end
  end
 end
 if not cloned then
  -- Late/missing source: a bounded steel axe and walnut handle, never an arrowhead.
  local handle=S.bar(r,'ThrownAxeHandle',to-frame.UpVector*1.05,to+frame.UpVector*.85,.19,Color3.fromRGB(111,69,39),.08,Enum.Material.Wood)
  if handle then handle.Color=Color3.fromRGB(111,69,39)end
  local center=to+frame.UpVector*.35
  local corners={center-frame.RightVector*.06+frame.UpVector*.45,center+frame.RightVector*1.1+frame.UpVector*.7,center+frame.RightVector*1.25-frame.UpVector*.5,center+frame.RightVector*.15-frame.UpVector*.15}
  S.triangle(r,'ThrownAxeBlade',corners[1],corners[2],corners[3],Color3.fromRGB(205,218,230),.12,Enum.Material.Metal)
  S.triangle(r,'ThrownAxeBlade',corners[1],corners[3],corners[4],Color3.fromRGB(143,167,187),.12,Enum.Material.Metal)
  S.bar(r,'ThrownAxeCuttingEdge',corners[2],corners[3],.1,Color3.fromRGB(235,242,247),.14,Enum.Material.Neon)
  local hub=S.volume(r,'ThrownAxeBronzeHub',center,Vector3.one*.24,Color3.fromRGB(205,147,67),.1,'ball',Enum.Material.Metal)
 end
 local twin=c.id=='dwarf.iron_axe.twin_axe_path'
 for i=start+1,#r.faces do
  local face=r.faces[i]
  face.spin={pivot=to,axis=returning and frame.RightVector or axis,turn=returning and math.pi or math.pi*2.2,
   approach=approach,duration=Art.axeCatchSeconds}
  if twin then
   face.spin.axis=c.pulse==1 and (axis+frame.UpVector*.62).Unit or (axis-frame.UpVector*.46).Unit
   face.spin.turn=c.pulse==1 and math.pi*1.8 or -math.pi*2.4
  end
  if returning then face.fadeDuration=.16 end
  if breaker then
   face.spin.axis=(frame.RightVector*.87+axis*.50).Unit
   face.spin.turn=math.pi*1.25
   face.spin.approach=breakerApproach
   face.spin.duration=.085
   face.fadeDuration=.15
  end
 end
 r.model:SetAttribute('ArtSilhouette','ThrownAxe');r.model:SetAttribute('AxeSource',cloned and 'Equipped' or 'Fallback')
end
function Art.surfaces(r,c)
 local kind=types[c.id]
 if c.shape=='axe'then Art.axe(r,c);return true end
 if not kind then return false end
 r.model:SetAttribute('ArtSilhouette',kind)
 if kind=='OathChallenge' or kind=='MarkBreaker' or kind=='DawnBurst' or kind=='BloomShot'
  or kind=='GuardianCounter' or kind=='PiercingRound' or kind=='OathbreakerStrike'
  or kind=='GunnerShot' or kind=='SparkVolley'then
  -- The authored strokes and equipped arrow carry the silhouette.
 elseif kind=='ShellBurst'then
  if not r.compact then
   for side=-1,1,2 do
    local heading=c.right*side+c.flat*.32
    local at=c.floor+UP*.42+heading*.45
    local fragment=S.volume(r,'ShellBurstCasing',at,Vector3.new(.26,.17,.52),
     Color3.fromRGB(117,102,86),.16,'wedge',Enum.Material.Metal)
    if fragment then
     orient(r,fragment,CFrame.lookAt(at,at+heading+UP*.42))
     local face=r.faces[#r.faces]
     face.drift=heading*4+UP*2.6;face.fadeDuration=.20
    end
   end
  end
 elseif kind=='IceShard'then
  local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
  local span=c.last-start
  local length=math.min(2.08,span.Magnitude)
  if length>.05 then
   local axis=span.Unit
   local width=math.min(.53,length*.5)
   local before=#r.faces+1
   gem(r,'IceShardFacet',c.last,axis,length,width,r.color,Enum.Material.Ice)
   for i=before,#r.faces do r.faces[i].fadeDuration=.17 end
   r.model:SetAttribute('CrystalLength',length);r.model:SetAttribute('CrystalWidth',width)
  end
 elseif kind=='MagmaSpear'then
  local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
  local span=c.last-start
  if span.Magnitude>.15 then
   local axis=span.Unit
   local length=math.min(span.Magnitude,3.9)
   local center=c.last-axis*length*.53
   local crust=S.volume(r,'MagmaBasaltCrust',center,Vector3.new(.65,.58,length*.94),
    Color3.fromRGB(119,63,41),.14,'wedge',Enum.Material.Slate)
   orient(r,crust,CFrame.lookAt(center,center+axis))
   if crust then r.faces[#r.faces].fadeDuration=.15 end
   if not r.compact then
    local lateral=CFrame.lookAt(center,center+axis).RightVector
    local tail=c.last-axis*length*.89
    local waist=c.last-axis*length*.44
    local firstFace=#r.faces+1
    for side=-1,1,2 do
     S.triangle(r,'MagmaMoltenEdge',tail,waist+lateral*side*.48,c.last,
      side==1 and Color3.fromRGB(255,170,64) or r.color,.24,Enum.Material.Neon)
    end
    for i=firstFace,#r.faces do r.faces[i].fadeDuration=.13 end
   end
  end
 elseif kind=='MoltenLine'then
  local first=Vector3.new(c.first.X,c.floor.Y+.11,c.first.Z)
  local delta=Vector3.new(c.last.X-c.first.X,0,c.last.Z-c.first.Z)
  if delta.Magnitude<=.1 then return true end
  local segments=r.compact and 3 or 6
  local span=.09/segments
  for i=1,segments do
   local startT,endT=(i-1)/segments,i/segments
   local a=first+delta*startT+c.right*math.sin(startT*math.pi*4)*.12
   local b=first+delta*endT+c.right*math.sin(endT*math.pi*4)*.12
   local mid=(a+b)*.5;local length=(b-a).Magnitude
   if not r.compact then
    local crust=S.volume(r,'MoltenBasaltSeam',mid,Vector3.new(.8,.12,length),Color3.fromRGB(58,42,37),.26,'block',Enum.Material.Slate)
    orient(r,crust,CFrame.lookAt(mid,b))
   end
   local surface=UP*.085
   local width=.33+.045*c.pulse
   local hot=S.volume(r,'MoltenFlowCore',mid+surface,Vector3.new(width,.06,length),Color3.fromRGB(255,113,30),.12,'block',Enum.Material.Neon)
   orient(r,hot,CFrame.lookAt(mid+surface,b+surface))
   if hot then
    S.growLine(r,a+surface,b+surface,span,span*(i-1))
    r.faces[#r.faces].fadeDuration=.22
   end
  end
 elseif kind=='LightningLine'then
  -- The traveling beam and its branches show the corridor without a static duplicate.
 elseif kind=='ThunderSpear'then
  local first,last=spearStart(c),c.last
  local spine=S.bar(r,'ElectricSpearSpine',first,last,.12,r.hot,.28,Enum.Material.Neon)
  if spine then r.faces[#r.faces].fadeDuration=.16 end
  for lane=1,3 do
   local at=first:Lerp(last,.43+lane*.12)
   for side=-1,1,2 do
    local branch=c.right*side*.55-c.dir*.65
    S.triangle(r,'LightningBranch',at-UP*.06,at+branch,at+UP*.06,r.color,.25)
    for i=math.max(1,#r.faces-1),#r.faces do r.faces[i].fadeDuration=.16 end
   end
  end
 elseif kind=='IronShoulder'then
  if not r.compact then
   local at=c.first+c.flat*1.2-c.right*.68-UP*.40
   local plate=S.volume(r,'IronShoulderPlate',at,Vector3.new(1.28,.65,.55),Color3.fromRGB(161,179,190),.25,'wedge',Enum.Material.Metal)
   orient(r,plate,CFrame.lookAt(at,at+c.flat)*CFrame.Angles(-.18,0,.3))
   if plate then r.faces[#r.faces].drift=c.flat*.62 end
  end
 elseif kind=='GravityCore'then
  local at=c.floor+UP*1.1
  S.volume(r,'GravityCore',at,Vector3.one*1.25,Color3.fromRGB(62,25,102),.18,'ball',Enum.Material.SmoothPlastic)
  gem(r,'GravityAmethyst',at+UP*.35,UP,.6,.25,r.color,Enum.Material.Neon)
  for i=1,3 do
   local a=i*math.pi*2/3;local radial=c.right*math.cos(a)+c.flat*math.sin(a)
   local fragment=S.volume(r,'GravityInwardStone',at+radial*2.1,Vector3.new(.3,.4,.3),Color3.fromRGB(115,100,120),.24,'wedge',Enum.Material.Slate)
   if fragment then r.faces[#r.faces].drift=-radial*1.7 end
  end
 elseif kind=='SteamPuffs'then
  if not r.compact then
   for side=-1,1,2 do
    local at=c.floor+c.right*side*.85+UP*.65
    local puff=S.volume(r,'SteamRoundedPuff',at,Vector3.new(.85,.68,.80),Color3.fromRGB(204,226,232),.86,'ball',Enum.Material.SmoothPlastic,false,.8)
    if puff then r.faces[#r.faces].drift=UP*1.25+c.right*side*.65 end
   end
  end
 elseif kind=='EarthPillars'then
  for i=1,3 do
   local at=c.floor+c.right*(i-2)*1.4+c.flat*(i%2)*.7
   local height=i==2 and 3.7 or 2.2+i*.2
   local crag=S.volume(r,'RisingCrag',at+UP*height*.5,Vector3.new(1.05,height,1.15),Color3.fromRGB(148,110,72),.16,'wedge',Enum.Material.Slate,false,.4)
   if crag then r.faces[#r.faces].emerge={duration=.18,delay=(i-1)*.014}end
  end
  local start=#r.faces
  S.arc(r,'RuptureShockwave',c.floor,math.min(c.radius*.5,3),.24,r.color,.72)
  S.animate(r,start,c.floor,UP,0,true,r.life)
 elseif kind=='StoneLance'then
  local length=3.8
  local core=S.volume(r,'StoneLanceVolume',c.last-c.dir*length*.5,Vector3.new(.65,.65,length),r.color,.25,'wedge',Enum.Material.Slate)
  orient(r,core,CFrame.lookAt(c.last-c.dir*length*.5,c.last))
  gem(r,'StoneLanceFacet',c.last,c.dir,length,.65,r.color,Enum.Material.Slate)
 elseif kind=='IceWard'then
  for lane=1,3 do
   local angle=(lane-2)*math.pi*2/3
   local radial=c.flat*math.cos(angle)+c.right*math.sin(angle)
   local side=UP:Cross(radial)
   local at=c.first+radial*1.75-UP*.65
   local top=at+UP*2
   S.triangle(r,'IceWardPanel',at-side*.95,top,at+side*.95,r.color,.7,Enum.Material.Ice)
   S.bar(r,'IceWardPanelEdge',at-side*.95,top,.11,r.color:Lerp(r.hot,.55),.12,Enum.Material.Neon)
   S.bar(r,'IceWardPanelEdge',top,at+side*.95,.11,r.color:Lerp(r.hot,.55),.12,Enum.Material.Neon)
  end
  gem(r,'IceWardCrest',c.first+UP*1.4,UP,.9,.4,r.color,Enum.Material.Ice)
  S.bar(r,'IceWardCrestLight',c.first+UP*.65,c.first+UP*1.4,.11,r.hot,.15,Enum.Material.Neon)
  -- A few low teeth retain the cold rim; the standing shield owns the focus.
  for lane=1,3 do
   local angle=lane*math.pi*2/3;local radial=c.flat*math.cos(angle)+c.right*math.sin(angle)
   local p=S.volume(r,'FrostRimFacet',c.floor+radial*1.8+UP*.32,Vector3.new(.3,.65,.4),r.color,.48,'wedge',Enum.Material.Ice)
   if p then r.faces[#r.faces].emerge={duration=.18,delay=0}end
  end
 elseif kind=='Froststorm'then
  if not r.compact then
   local start=#r.faces
   S.ribbon(r,'FroststormBand',function(t)
    local angle=t*math.pi*1.55
    local radius=math.min(c.radius*.32,4.1)*(1-.22*t)
    return c.floor+(c.flat*math.cos(angle)+c.right*math.sin(angle))*radius+UP*(.18+.28*t)
   end,UP,.55,.64,r.color:Lerp(r.hot,.19),4,Enum.Material.SmoothPlastic)
   S.animate(r,start,c.floor,UP,1.15,false,r.life)
  end
  local count=r.compact and 2 or 3
  for lane=1,count do
   local a=lane*math.pi*2/count
   local radial=c.flat*math.cos(a)+c.right*math.sin(a)
   local pos=c.floor+radial*math.min(c.radius*.29,4)
   local p=S.volume(r,'FrostRimFacet',pos+UP*.5,Vector3.new(.55,1,.6),r.color,.3,'wedge',Enum.Material.Ice)
   if p then r.faces[#r.faces].emerge={duration=.18,delay=0}end
   local shard=S.volume(r,'FroststormFallingCrystal',pos+UP*.65,Vector3.new(.55,1.6,.55),r.color:Lerp(r.hot,.45),.22,'wedge',Enum.Material.Ice)
   if shard then
    orient(r,shard,CFrame.lookAt(shard.Position,shard.Position-radial)*CFrame.Angles(-.27,0,.18))
    r.faces[#r.faces].fall={height=2.9+lane*.35,duration=.23,delay=(lane-1)*.025}
   end
  end
 elseif kind=='WaterBall'then
  local shell=S.volume(r,'WaterVolume',c.last,Vector3.one*1.78,Color3.fromRGB(33,107,153),.28,'ball',Enum.Material.Glass)
  if shell then shell.Reflectance=.23 end
  S.volume(r,'WaterInnerGlow',c.last-c.dir*.14,Vector3.one*1.15,Color3.fromRGB(28,106,157),.64,'ball',Enum.Material.Neon)
  local glint=c.last+UP*.52+c.right*.42+c.dir*.31
  S.volume(r,'WaterSurfaceGlow',glint,Vector3.new(.56,.15,.30),Color3.fromRGB(131,219,249),.22,'ball',Enum.Material.Neon)
  for lane=1,5 do
   local a=lane*2.39996
   local radial=c.right*math.cos(a)+UP*math.sin(a)
   local at=c.last-c.dir*(.6+lane*.24)+radial*(.36+lane*.08)
   local drop=S.volume(r,'StrippedDroplet',at,Vector3.new(.15,.18,.36)*(1.3-lane*.11),r.color,.22,'ball',Enum.Material.Glass)
   if drop then
    orient(r,drop,CFrame.lookAt(at,at+c.dir))
    r.faces[#r.faces].drift=-c.dir*.72+radial*.28
   end
  end
  for i=1,3 do
   local angle=i*math.pi*2/3;local radial=c.right*math.cos(angle)+UP*math.sin(angle)
   local at=c.last+radial*.8
   local crest=S.volume(r,'WaterCrest',at,Vector3.new(.6,.14,.28),r.color:Lerp(r.hot,.35),.28,'ball',Enum.Material.Glass,false,.15)
   if crest then r.faces[#r.faces].drift=radial*.35 end
   S.volume(r,'WaterFoam',at,Vector3.new(.3,.09,.13),r.hot,.45,'ball')
  end
 elseif kind=='ManaCrystal'then
  local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
  local span=c.last-start
  local terminal=span.Magnitude<=.05
  local length=terminal and .98 or math.min(span.Magnitude,1.65)
  if length>.05 then
   gem(r,'ManaBoltFacet',c.last,terminal and c.dir or span.Unit,length,length*.29,r.color,Enum.Material.Neon)
  end
 elseif kind=='FrostLance' or kind=='ShatterDart' or kind=='GlacialSpike'then
  local length=kind=='ShatterDart' and 1.15 or kind=='GlacialSpike' and 5.3 or 3.6
  local width=kind=='ShatterDart' and .3 or kind=='GlacialSpike' and .95 or .42
  r.model:SetAttribute('CrystalLength',length);r.model:SetAttribute('CrystalWidth',width)
  local core=S.volume(r,'IceLanceVolume',c.last-c.dir*length*.5,Vector3.new(width*.75,width*.75,length),r.color,.4,'wedge',Enum.Material.Ice)
  orient(r,core,CFrame.lookAt(c.last-c.dir*length*.5,c.last))
  gem(r,'IceLanceFacet',c.last,c.dir,length,width,r.color,Enum.Material.Ice)
  S.bar(r,'IceLanceLuminousSpine',c.last-c.dir*length*.9,c.last,.075,r.color:Lerp(r.hot,.4),.23,Enum.Material.Neon)
  if kind=='GlacialSpike'then
   -- Leave a solid core and let the splinters peel from its shoulders.
   if not r.compact then
    for side=-1,1,2 do
     local at=c.last-c.dir*1.45+c.right*side*.82+UP*.35
     local axis=(c.dir+c.right*side*.28+UP*.22).Unit
     local first=#r.faces+1
     gem(r,'GlacialSideCrystal',at,axis,1.85,.37,r.color,Enum.Material.Ice)
     for i=first,#r.faces do
      r.faces[i].drift=c.right*side*2.25+UP*1.15+c.dir*.35
      r.faces[i].fadeDuration=.25
     end
    end
   end
  end
 elseif kind=='EmberLance' or kind=='FlameDart'then
  local length=kind=='FlameDart' and 1.5 or 3.2
  local width=kind=='FlameDart' and .28 or .42
  local basis=CFrame.lookAt(c.last,c.last+c.dir)
  for side=-1,1,2 do
   local start=#r.faces
   S.ribbon(r,'FlameWake',function(t)
    local at=c.last-c.dir*length*(1-t)
    return at+basis.RightVector*side*math.sin(t*math.pi)*width+basis.UpVector*math.sin(t*math.pi*2)*width*.4
   end,basis.UpVector,width*1.5,.4,side==1 and Color3.fromRGB(255,171,41)or r.color,4)
   S.animate(r,start,c.last,c.dir,side*.7,false,r.life*.85)
  end
  local jet=S.volume(r,'FlameJet',c.last-c.dir*.45,Vector3.new(width,width,.9),Color3.fromRGB(255,167,39),.25,'wedge')
  orient(r,jet,CFrame.lookAt(c.last-c.dir*.45,c.last))
 end
 return true
end
function Art.bloomContact(r,at,cf,size)
 local count=r.compact and 1 or 5
 for i=1,count do
  local angle=(i-1)*math.pi*2/count
  local axis=cf.UpVector*math.cos(angle)+cf.RightVector*math.sin(angle)
  local side=cf.RightVector*math.cos(angle)-cf.UpVector*math.sin(angle)
  local first=#r.faces+1
  leaf(r,at+axis*.20*size,axis,side,(i==1 and 1.07 or .77)*size,'BloomShotPetal')
  for j=first,#r.faces do
   r.faces[j].drift=(axis*2.4-cf.LookVector*.5)*size
   r.faces[j].fadeDuration=.19
  end
 end
end
function Art.accents(r,c)
 -- Nature magic is a filled leaf, not a hair-thin line or a plain triangle.
 local id=c.id
 if id=='dwarf.iron_axe.mountain_collapse' and not r.compact then
  local at=c.floor+c.flat*c.radius*.4+UP*3.3
  Art.axe(r,{first=at-UP,last=at,flat=c.flat,character=c.character,definition={},pulse=1})
 elseif id=='elf.magic_archer.echo_arrows'then
  if not r.compact then
   local length=math.min(.65+.22*c.pulse,(c.last-c.first).Magnitude*.5)
   if length>.15 then
    local side=CFrame.fromAxisAngle(c.dir,math.rad((c.pulse-2)*32)):VectorToWorldSpace(c.right)
    local tip=c.last-c.dir*.14
    leaf(r,tip-c.dir*length,c.dir,side,length,'EchoArrowLeaf')
   end
  end
 elseif id=='elf.magic_archer.elemental_arrow' or id=='elf.magic_archer.elemental_pierce'then
  leaf(r,c.last-c.dir*.5,c.dir,c.right,1.15,'NatureArrowLeaf')
 elseif c.shape=='vine'then
  local burst=id=='elf.magic_archer.vine_burst'
  if c.groundShape=="VineTrap" or id=='elf.magic_archer.rooting_fan' then return end
  for lane=1,3 do
   local angle=c.definition.form=='cone' and math.rad(-c.angle*.35+lane*c.angle*.7/4) or lane*math.pi*2/3
   local radial=c.flat*math.cos(angle)+c.right*math.sin(angle)
   local at=c.floor+radial*math.min(c.radius*.35,2.4)+UP*.5
   leaf(r,at,UP+radial*(burst and .8 or .4),c.right,burst and 2.2 or 1.2,'RootBroadLeaf')
  end
 elseif id=='elf.marksman.weakpoint_shot' or id=='elf.marksman.precision_volley' or id=='elf_pinning_shot'then
  local gold=Color3.fromRGB(255,189,65)
  for i=1,4 do
   local a=i*math.pi/2;local radial=c.right*math.cos(a)+UP*math.sin(a)
   local pos=c.last+radial*.55
   S.bar(r,'AimTargetNotch',pos,pos+radial*.25,.1,gold,.3,Enum.Material.Neon)
  end
 elseif c.key=='gun' and types[id]~='PiercingRound' and types[id]~='GunnerShot'then
  local flash=S.volume(r,'CompactMuzzleFlash',c.first+c.dir*.25,Vector3.new(.22,.22,.55),Color3.fromRGB(255,203,83),.2,'wedge')
  if flash then r.faces[#r.faces].fadeDuration=.07 end
 elseif id~='knight.paladin.radiant_sweep' and id:find('knight.paladin.',1,true) and c.definition.mark=='oath'then
  gem(r,'OathFacet',c.first+c.flat*1.5+UP*.6,UP,.85,.3,r.color,Enum.Material.SmoothPlastic)
 end
end
return Art
