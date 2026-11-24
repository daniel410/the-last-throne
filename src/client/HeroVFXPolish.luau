-- Art-direction refinements inside the existing renderer's budgets and clock.
local S=require(script.Parent.HeroVFXSurfaces)
local P={}
local variants={['knight.paladin.radiant_sweep']='RadiantFan',['knight.paladin.guardian_slash']='GuardianWing',['knight.paladin.oathbound_assault']='OathboundAdvance'}
local function oathboundPath(c,t,emphasis)
 local sign=c.pulse%2==0 and -1 or 1
 local span=emphasis and 3.8 or 2.2
 local height=emphasis and -2.4 or 1.6
 return c.first+c.flat*(c.pulse*1.4)+c.right*((t-.5)*sign*span)+Vector3.yAxis*((t-.5)*height)
end
function P.strokes(r,c,line,curve)
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
  for lane=3,3 do curve(r,'RadiantOpeningFan',function(t,u)
   local a=math.rad(-c.angle*.48+c.angle*.96*t)
   local radius=math.min(c.radius,8)*(.35+lane*.18)*(.7+u*.3)
   return c.first+(c.flat*math.cos(a)+c.right*math.sin(a))*radius+Vector3.yAxis*(lane*.13)
  end,6,.34,r.color)end
 elseif kind=='GuardianWing'then
  for side=-1,1,2 do curve(r,'GuardianShelteringWing',function(t,u)
   local a=t*math.pi*.85
   return c.first+c.flat*(1.6+math.sin(a)*1.6)+c.right*side*math.sin(a)*2.3+Vector3.yAxis*(math.cos(a)*1.9+.2+u*.2)
  end,8,.17,r.color)end
 else
  local emphasis=c.final and not r.compact
  curve(r,'OathboundForwardCut',function(t,u)
   return oathboundPath(c,t,emphasis)+c.flat*(u*1.2)
  end,5,emphasis and .24 or .17,r.color)
 end
 return true
end
function P.surfaces(r,c)
 local kind=variants[c.id];if not kind then return false end
 if kind=='GuardianWing'then
  for side=-1,1,2 do
  local at=c.first+c.flat*1.7+c.right*side*.95
  local top=at+Vector3.yAxis*1.3;local bottom=at-Vector3.yAxis*1.1
  S.triangle(r,'GuardianShieldVeil',top,at+c.right*.7,bottom,r.color,.64)
  S.triangle(r,'GuardianShieldVeil',top,bottom,at-c.right*.7,r.color,.64)
  end
 elseif kind=='OathboundAdvance'then
  local start=#r.faces
  local emphasis=c.final and not r.compact
  S.ribbon(r,'OathboundAdvancingVeil',function(t)return oathboundPath(c,t,emphasis)end,
   c.flat,emphasis and .58 or .45,.58,r.color,3)
  for i=start+1,#r.faces do r.faces[i].drift=c.flat*1.2;r.faces[i].fadeDuration=r.life*(.6+c.pulse*.12)end
 else
  S.ribbon(r,'RadiantFanVeil',function(t)
   local a=math.rad(-c.angle*.48+c.angle*.96*t)
   return c.first+(c.flat*math.cos(a)+c.right*math.sin(a))*math.min(c.radius*.7,5)
  end,Vector3.yAxis,.8,.44,r.color,10)
 end
 return true
end
function P.finish(r,c)
 for _,v in ipairs(r.lines)do
  local name=v.beam.Name
  if name=='BladeRibbon'or name=='RadiantOpeningFan'or name=='FroststormFlow'then
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
