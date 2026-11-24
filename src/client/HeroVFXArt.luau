-- ART review: readable primary silhouettes, using the existing world-space budgets.
local S=require(script.Parent.HeroVFXSurfaces)
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
function Art.strokes(r,c,line,curve)
 local kind=types[c.id]
 local function stroke(name,a,b,w,color)line(r,name,function()return a,b end,w,color)end
 if kind=='ChallengeVoice'then
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
 elseif kind=='IceShard' or kind=='ShatterDart' or kind=='FrostLance' or kind=='GlacialSpike'then
  local length=kind=='IceShard' and 1.65 or kind=='ShatterDart' and 1.15 or kind=='GlacialSpike' and 5.3 or 3.6
  local width=kind=='IceShard' and .7 or kind=='ShatterDart' and .3 or kind=='GlacialSpike' and .95 or .42
  local waist=c.last-c.dir*length*.62
  for side=-1,1,2 do
   stroke('IconCrystalEdge',waist+c.right*side*width,c.last,.065,r.hot)
   stroke('IconCrystalRear',c.last-c.dir*length,waist+c.right*side*width,.045,r.color)
  end
  r.model:SetAttribute('PrimaryIconCue',true);return true
 elseif kind=='ThunderSpear' or kind=='LightningLine' then
  local first,last=kind=='ThunderSpear' and spearStart(c) or c.first,c.last
  if kind=='LightningLine'then first=Vector3.new(first.X,c.floor.Y+.16,first.Z);last=Vector3.new(last.X,c.floor.Y+.16,last.Z)end
  stroke(kind=='ThunderSpear' and 'IconThunderSpearAxis' or 'IconLightningCorridor',first,last,.17,r.hot)
  for i=1,3 do
   local at=first:Lerp(last,kind=='ThunderSpear' and (.43+i*.12) or i/4)
   local span=kind=='ThunderSpear' and .55 or .85
   for side=-1,1,2 do
    local elbow=at+c.right*span*side-c.dir*(kind=='ThunderSpear' and .65 or .18)
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
 end
 local axis=(to-from).Magnitude>.01 and (to-from).Unit or c.flat
 local reach=c.definition.crosscut and 5 or 2.4
 local approach=returning and -axis*math.min(reach,(to-from).Magnitude) or nil
 return from,to,axis,approach
end
function Art.axe(r,c)
 local _,to,axis,approach=Art.axeFlight(c)
 local returning=approach~=nil
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
  if p then orient(r,p,CFrame.new(to)*source.CFrame.Rotation);cloned=true end
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
 end
 r.model:SetAttribute('ArtSilhouette','ThrownAxe');r.model:SetAttribute('AxeSource',cloned and 'Equipped' or 'Fallback')
end
function Art.surfaces(r,c)
 local kind=types[c.id]
 if c.shape=='axe'then Art.axe(r,c);return true end
 if not kind then return false end
 r.model:SetAttribute('ArtSilhouette',kind)
 if kind=='MoltenLine'then
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
 elseif kind=='ThunderSpear' or kind=='LightningLine'then
  local first,last=kind=='ThunderSpear' and spearStart(c) or c.first,c.last
  if kind=='LightningLine'then first=Vector3.new(first.X,c.floor.Y+.16,first.Z);last=Vector3.new(last.X,c.floor.Y+.16,last.Z)end
  local spine=S.bar(r,'ElectricSpearSpine',first,last,.12,r.hot,.28,Enum.Material.Neon)
  if spine then r.faces[#r.faces].fadeDuration=.16 end
  for lane=1,3 do
   local at=first:Lerp(last,kind=='ThunderSpear' and (.43+lane*.12) or lane/4)
   for side=-1,1,2 do
    local branch=kind=='ThunderSpear' and c.right*side*.55-c.dir*.65 or c.right*side*.85-c.dir*.18
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
  gem(r,'ManaBoltFacet',c.last,c.dir,1.8,.48,r.color,Enum.Material.SmoothPlastic)
 elseif kind=='FrostLance' or kind=='IceShard' or kind=='ShatterDart' or kind=='GlacialSpike'then
  local length=kind=='IceShard' and 1.65 or kind=='ShatterDart' and 1.15 or kind=='GlacialSpike' and 5.3 or 3.6
  local width=kind=='IceShard' and .7 or kind=='ShatterDart' and .3 or kind=='GlacialSpike' and .95 or .42
  r.model:SetAttribute('CrystalLength',length);r.model:SetAttribute('CrystalWidth',width)
  local core=S.volume(r,'IceLanceVolume',c.last-c.dir*length*.5,Vector3.new(width*.75,width*.75,length),r.color,.4,'wedge',Enum.Material.Ice)
  orient(r,core,CFrame.lookAt(c.last-c.dir*length*.5,c.last))
  gem(r,'IceLanceFacet',c.last,c.dir,length,width,r.color,Enum.Material.Ice)
  S.bar(r,'IceLanceLuminousSpine',c.last-c.dir*length*.9,c.last,.075,r.color:Lerp(r.hot,.4),.23,Enum.Material.Neon)
  if kind=='GlacialSpike'then
   for side=-1,1,2 do gem(r,'GlacialSideCrystal',c.last-c.dir*1.6+c.right*side*.65,c.dir,2,.4,r.color,Enum.Material.Ice)end
  end
 elseif kind=='EmberLance' or kind=='FlameDart' or kind=='MagmaSpear'then
  local length=kind=='FlameDart' and 1.5 or kind=='MagmaSpear' and 4.4 or 3.2
  local width=kind=='FlameDart' and .28 or kind=='MagmaSpear' and .65 or .42
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
  if kind=='MagmaSpear'then
   gem(r,'MagmaBasaltCrust',c.last-c.dir*.15,c.dir,length*.85,width,Color3.fromRGB(85,48,37),Enum.Material.Slate)
   S.bar(r,'MagmaMoltenSpine',c.last-c.dir*length,c.last,.2,Color3.fromRGB(255,130,35),.1,Enum.Material.Neon)
  end
 end
 return true
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
 elseif id=='elf.magic_archer.elemental_arrow' or id=='elf.magic_archer.bloom_shot' or id=='elf.magic_archer.warden_arrow' or id=='elf.magic_archer.elemental_pierce'then
  local n=id=='elf.magic_archer.bloom_shot' and 5 or 1
  for i=1,n do
   local angle=i*math.pi*2/n
   local axis=n==5 and(c.right*math.cos(angle)+UP*math.sin(angle))or c.dir
   local at=c.last-c.dir*.5+(n==5 and axis*.28 or Vector3.zero)
   leaf(r,at,axis,n==5 and(c.right*-math.sin(angle)+UP*math.cos(angle))or c.right,n==5 and 1.4 or 1.15,'NatureArrowLeaf')
  end
 elseif c.shape=='vine'then
  local burst=id=='elf.magic_archer.vine_burst'
  if id=='elf.magic_archer.vine_trap'then
   S.ribbon(r,'VineTrapLoop',function(t)
    local a=t*math.pi*1.85
    return c.floor+(c.flat*math.cos(a)+c.right*math.sin(a))*1.4+UP*(.2+t*1.15)
   end,UP,.3,.62,r.color,6,Enum.Material.Neon)
  end
  for lane=1,3 do
   local angle=c.definition.form=='cone' and math.rad(-c.angle*.35+lane*c.angle*.7/4) or lane*math.pi*2/3
   local radial=c.flat*math.cos(angle)+c.right*math.sin(angle)
   local at=c.floor+radial*(id=='elf.magic_archer.vine_trap' and 1.1 or math.min(c.radius*.35,2.4))+UP*.5
   leaf(r,at,UP+radial*(burst and .8 or .4),c.right,burst and 2.2 or 1.2,'RootBroadLeaf')
  end
 elseif id=='elf.marksman.weakpoint_shot' or id=='elf.marksman.precision_volley' or id=='elf_pinning_shot'then
  local gold=Color3.fromRGB(255,189,65)
  for i=1,4 do
   local a=i*math.pi/2;local radial=c.right*math.cos(a)+UP*math.sin(a)
   local pos=c.last+radial*.55
   S.bar(r,'AimTargetNotch',pos,pos+radial*.25,.1,gold,.3,Enum.Material.Neon)
  end
 elseif c.key=='gun'then
  local flash=S.volume(r,'CompactMuzzleFlash',c.first+c.dir*.25,Vector3.new(.22,.22,.55),Color3.fromRGB(255,203,83),.2,'wedge')
  if flash then r.faces[#r.faces].fadeDuration=.07 end
 elseif id=='mage.pyro.searing_ward'then
  S.volume(r,'SearingWardDome',c.first,Vector3.new(3.1,3.7,3.1),Color3.fromRGB(255,180,65),.89,'ball',Enum.Material.Glass)
 elseif id:find('knight.paladin.',1,true) and c.definition.mark=='oath'then
  gem(r,'OathFacet',c.first+c.flat*1.5+UP*.6,UP,.85,.3,r.color,Enum.Material.SmoothPlastic)
 end
end
return Art
