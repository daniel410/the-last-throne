-- Art-direction refinements inside the existing renderer's budgets and clock.
local S=require(script.Parent.HeroVFXSurfaces)
local Geometry=require(script.Parent.SkillEffectGeometry)
local P={}
local variants={['knight.paladin.radiant_sweep']='RadiantFan',['knight.paladin.guardian_slash']='GuardianWing',['knight.paladin.oathbound_assault']='OathboundAdvance'}
local function radiantPath(c,t,u)
 local bearing=math.rad(c.angle)*(.92*t-.46)
 local reach=c.radius*(.34+.37*math.sin(t*math.pi)+.13*(1-(1-u)^3))
 return c.first+(c.flat*math.cos(bearing)+c.right*math.sin(bearing))*reach
  +Vector3.yAxis*(-1.05+2.35*t+.54*math.sin(t*math.pi))
end
local function guardianPath(c,t,u)
 local bearing=math.rad(c.angle)*(.46-.92*t)
 local sweep=math.sin(t*math.pi)
 local reach=c.radius*(.28+.30*sweep+.13*(1-(1-u)^2))
 return c.first+(c.flat*math.cos(bearing)+c.right*math.sin(bearing))*reach
  +Vector3.yAxis*(-.9+1.55*t+.68*sweep-.2*u)
end
local function oathboundPath(c,t,emphasis)
 local sign=c.pulse%2==0 and -1 or 1
 local span=emphasis and 3.8 or 2.2
 local height=emphasis and -2.4 or 1.6
 return c.first+c.flat*(c.pulse*1.4)+c.right*((t-.5)*sign*span)+Vector3.yAxis*((t-.5)*height)
end
local function dawnSpiral(r,c,curve)
 local beat=c.pulse-1
 for lane=1,2 do
  curve(r,"DawnSpiralSweep",function(t,u)
   local a=(lane-1)*math.pi+beat*1.8+t*math.rad(123)+u*.74
   local reach=c.radius*(.38+beat*.11+.22*t+.09*u)
   local height=.22+beat*.37+.24*t+beat*.24*math.sin(t*math.pi)
   return c.floor+(c.flat*math.cos(a)+c.right*math.sin(a))*reach+Vector3.yAxis*height
  end,r.compact and 3 or 5,.25+beat*.035,r.hot)
 end
end
local function shatterBlow(r,c,curve)
 for lane=1,3 do
  local angle=(lane-1)*math.pi*2/3+.3
  local radial=c.flat*math.cos(angle)+c.right*math.sin(angle)
  local tangent=radial:Cross(Vector3.yAxis)
  curve(r,"ShatterBlowCrack",function(t,u)
   local reach=c.radius*(.36+.53*math.min(1,u*4))
   return c.floor+radial*(t*reach)+tangent*(math.sin(t*10)*t*.28)+Vector3.yAxis*.09
  end,3,.19,r.hot)
 end
end
local function frostRing(r,c,curve)
 for lane=1,2 do
  curve(r,"FrostRingFront",function(t,u)
   local a=(lane-1)*math.pi+t*math.rad(148)+.18
   local reach=c.radius*(.27+.53*(1-(1-math.min(1,u*3))^3))
   local crest=.12+math.sin(t*math.pi)*.27*(1-u)
   return c.floor+(c.flat*math.cos(a)+c.right*math.sin(a))*reach+Vector3.yAxis*crest
  end,r.compact and 4 or 6,.31,r.color:Lerp(r.hot,.30))
 end
end
local groundStrokes={DawnSpiral=dawnSpiral,ShatterBlow=shatterBlow,FrostRing=frostRing}
local function tremorGuard(r,c,line,curve)
 local strike=c.floor+c.flat*c.radius*.18
 for side=-1,1,2 do
  line(r,"TremorGuardStrike",function(u)
   return strike+c.right*side*.20+Vector3.yAxis*(.10+.22*u),
    strike+c.right*side*(.80+.64*u)+c.flat*.36+Vector3.yAxis*(.85+.34*u)
  end,.23,r.hot,.035,true)
 end
 for bank=0,1 do
  curve(r,"TremorGuardFault",function(t,u)
   local a=bank*math.pi+math.rad(153)*(t-.46)
   local reach=c.radius*(.24+.60*(1-(1-u)^3))*(.88+.12*math.sin(t*math.pi))
   local ripple=.12*math.sin(t*math.pi*5)^2*(1-u)
   return c.floor+(c.flat*math.cos(a)+c.right*math.sin(a))*reach+Vector3.yAxis*(.08+ripple)
  end,3,.30,r.color:Lerp(r.hot,.38),true)
 end
end
local function wardenArrow(r,c,line)
 local start=Geometry.fanLaunch(c.first,c.muzzle,c.last)
 local span=c.last-start
 if span.Magnitude<=.05 then return end
 local wake=line(r,"WardenArrowStem",function(u)
  return start:Lerp(c.last,.92*(1-(1-u)^3)),c.last
 end,.12,r.color:Lerp(r.hot,.22),.08,true)
 if wake then r.model:SetAttribute("ReleaseTrace",true) end
 local axis=span.Unit
 local basis=CFrame.lookAt(start,c.last)
 local length=math.min(span.Magnitude*.76,1.8)
 for side=-1,1,2 do
  line(r,"WardenArrowVein",function(u)
   local base=c.last-axis*length*(1-.40*u)
   return base+basis.RightVector*side*length*(.18+.11*u)+basis.UpVector*length*.10,
    c.last-axis*length*.12
  end,.14,r.hot,.055,true)
 end
end
local function searingWard(r,c,_,curve)
 for side=0,1 do
  curve(r,"SearingWardFront",function(t,u)
   local a=side*math.pi+math.rad(143)*(t-.5)+.45*u
   local reach=c.radius*(.30+.53*(1-(1-u)^4))
   local crest=math.sin(t*math.pi)*(.52+.20*math.sin(t*math.pi*4)^2)*(1-.65*u)
   return c.floor+(c.right*math.cos(a)+c.flat*math.sin(a))*reach+Vector3.yAxis*(.16+crest)
  end,r.compact and 3 or 4,.34,r.color:Lerp(r.hot,.30),true)
 end
end
local releases={
 ["dwarf.iron_axe.tremor_guard"]=tremorGuard,
 ["elf.magic_archer.warden_arrow"]=wardenArrow,
 ["mage.pyro.searing_ward"]=searingWard,
}
function P.strokes(r,c,line,curve)
 local release=releases[c.id]
 if release then
  release(r,c,line,curve)
  r.model:SetAttribute("PrimaryIconCue",true)
  return true
 end
 local groundStroke=groundStrokes[c.groundShape]
 if groundStroke then
  groundStroke(r,c,curve)
  r.model:SetAttribute("PrimaryIconCue",true)
  return true
 end
 if c.id=='mage.cryo.froststorm'then
  for layer=1,r.compact and 1 or 2 do
   curve(r,'FroststormFlow',function(t,u)
    local a=t*math.pi*1.48+layer*math.pi+u*.88
    local collapse=1-.57*(1-(1-u)^3)
    local radius=math.min(c.radius*.44,5.6)*(1-.34*t)*collapse
    local height=.22+(1-t)*(1.5+layer*.65)*(1-u*.8)
    return c.floor+(c.flat*math.cos(a)+c.right*math.sin(a))*radius+Vector3.yAxis*height
   end,r.compact and 5 or 6,.29,r.color:Lerp(r.hot,.25))
  end
  r.model:SetAttribute('PrimaryIconCue',true)
  return true
 end
 local kind=variants[c.id];if not kind then return false end
 r.model:SetAttribute('HolyMotion',kind)
 if kind=='RadiantFan'then
  curve(r,"RadiantOpeningFan",function(t,u)return radiantPath(c,t,u)end,
   r.compact and 5 or 7,.42,r.hot,true)
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif kind=='GuardianWing'then
  curve(r,'GuardianShelteringWing',function(t,u)return guardianPath(c,t,u)end,
   r.compact and 5 or 8,.36,r.hot,true)
  r.model:SetAttribute('PrimaryIconCue',true)
 else
  local emphasis=c.final and not r.compact
  curve(r,'OathboundForwardCut',function(t,u)
   return oathboundPath(c,t,emphasis)+c.flat*(u*1.2)
  end,5,emphasis and .24 or .17,r.color)
 end
 return true
end
function P.surfaces(r,c)
 if releases[c.id] then return true end
 if c.groundShape=="DawnSpiral" then return true end
 if c.groundShape=="ShatterBlow" then
  for lane=1,r.compact and 2 or 3 do
   local angle=(lane-1)*math.pi*2/3+.3
   local radial=c.flat*math.cos(angle)+c.right*math.sin(angle)
   local height=lane==1 and 1.75 or 1.25
   local at=c.floor+radial*c.radius*(.31+lane*.11)+Vector3.yAxis*height*.5
   local rock=S.volume(r,"ShatterBlowSlab",at,Vector3.new(.68,height,1.05),
    Color3.fromRGB(174,139,103),.13,"wedge",Enum.Material.Slate)
   if rock then
    local face=r.faces[#r.faces]
    face.cf=CFrame.lookAt(at,at+radial)*CFrame.Angles(-.14,0,lane%2==0 and .28 or -.22)
    rock.CFrame=face.cf
    face.emerge={duration=.13,delay=.025+lane*.014}
   end
  end
  return true
 end
 local kind=variants[c.id];if not kind then return false end
 if kind=='GuardianWing'then
  if not r.compact then
   local firstFace=#r.faces+1
   S.ribbon(r,'GuardianCutRibbon',function(t)return guardianPath(c,t,.20)end,
    c.flat,.62,.54,r.color,5)
   for i=firstFace,#r.faces do r.faces[i].fadeDuration=.17 end
  end
 elseif kind=='OathboundAdvance'then
  local start=#r.faces
  local emphasis=c.final and not r.compact
  S.ribbon(r,'OathboundAdvancingVeil',function(t)return oathboundPath(c,t,emphasis)end,
   c.flat,emphasis and .58 or .45,.58,r.color,3)
  for i=start+1,#r.faces do r.faces[i].drift=c.flat*1.2;r.faces[i].fadeDuration=r.life*(.6+c.pulse*.12)end
 end
 return true
end
function P.finish(r,c)
 for _,v in ipairs(r.lines)do
  local name=v.beam.Name
  if name=='BladeRibbon'or name=='FroststormFlow'then
   if v.glow then v.glow.Texture='rbxassetid://8196169974';v.glow.TextureMode=Enum.TextureMode.Wrap;v.glow.TextureLength=4;v.glow.TextureSpeed=.8 end
  elseif name=='TidalLip'or name=='TempestSpiral'or name=='CalderaLivingJet'then
   v.beam.Texture=name=='CalderaLivingJet'and'rbxasset://textures/particles/fire_main.dds'or name=='TempestSpiral'and'rbxasset://textures/particles/smoke_main.dds'or'rbxassetid://8196169974'
   v.beam.TextureMode=Enum.TextureMode.Wrap;v.beam.TextureLength=name=='CalderaLivingJet'and 2 or 4
   v.beam.TextureSpeed=name=='TidalLip'and .55 or name=='CalderaLivingJet'and -1.8 or .8
   local gain=name=='TempestSpiral'and 6 or 1.3
   if name=='TempestSpiral'then
    v.beam.TextureMode=Enum.TextureMode.Wrap;v.beam.TextureLength=3.8;v.beam.TextureSpeed=.65
    v.beam.Color=ColorSequence.new(Color3.fromRGB(58,138,186),Color3.fromRGB(168,228,241))
   end
   v.width*=gain;v.endWidth*=gain
  end
 end
 for _,v in ipairs(r.faces)do
  if v.part.Name=='CalderaEruptionTongue'then v.alpha=1;v.part.Transparency=v.alpha
  elseif c.shape=='spin'and v.part.Name=='BladeSurface'or v.part.Name=='ElementalSurface'and c.shape=='water'or v.part.Name=='TempestEyeBand'or v.part.Name=='FroststormBand'then
   v.alpha=math.max(v.alpha,.79);v.part.Transparency=v.alpha
  end
 end
end
return P
