-- Layered spell art: soft light, animated ribbons, bounded particles and impact timing.
-- All assets are engine-bundled. No scene-wide lighting or camera effects are changed.
local Input=game:GetService('UserInputService')
local A={}
local used={beams=0,particles=0,lights=0,flares=0}
local limits={beams=Input.TouchEnabled and 96 or 192,particles=Input.TouchEnabled and 240 or 480,lights=6,flares=32}
local WHITE=Color3.fromRGB(255,247,218)
local SMOKE='rbxasset://textures/particles/smoke_main.dds'
local SPARK='rbxasset://textures/particles/sparkles_main.dds'
local FIRE='rbxasset://textures/particles/fire_main.dds'
local function clamp(x)return math.clamp(x,0,1)end
local function smooth(x)x=clamp(x);return x*x*(3-2*x)end
local function color(r)
 local f=r.profile.family
 if f=='frost'then return Color3.fromRGB(221,252,255)
 elseif f=='soul'then return Color3.fromRGB(204,255,241)
 elseif f=='shadow'then return Color3.fromRGB(224,187,255)
 elseif f=='venom'then return Color3.fromRGB(223,255,151)
 end
 return WHITE
end
local function beam(r,name,path,width,soft,texture)
 if used.beams>=limits.beams then return end
 local art=r.art
 local a=Instance.new('Attachment');a.Parent=art.carrier
 local b=Instance.new('Attachment');b.Parent=art.carrier
 local v=Instance.new('Beam');v.Name=name;v.Attachment0=a;v.Attachment1=b;v.FaceCamera=true;v.Segments=12
 v.Texture=texture or (soft and SMOKE or '');v.TextureMode=Enum.TextureMode.Stretch
 v.LightEmission=1;v.LightInfluence=0;v.Width0=width;v.Width1=width*.3
 v.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,r.color),ColorSequenceKeypoint.new(.7,r.color:Lerp(color(r),.65)),ColorSequenceKeypoint.new(1,color(r))})
 v.Transparency=NumberSequence.new(soft and .7 or .22);v.Parent=art.carrier
 art.lines[#art.lines+1]={a=a,b=b,beam=v,path=path,width=width,soft=soft};used.beams+=1
end
local function ribbon(r,name,path,width,texture)
 beam(r,name..'Glow',path,width*3.2,true,SMOKE)
 beam(r,name,path,width,false,texture)
end
local function frame(p,tangent)
 if tangent.Magnitude<.001 then tangent=Vector3.xAxis end
 local x=tangent.Unit;local up=math.abs(x.Y)>.95 and Vector3.zAxis or Vector3.yAxis
 local z=x:Cross(up).Unit;return CFrame.fromMatrix(p,x,z:Cross(x),z)
end
local function orbit(r,name,radius,z,tilt,phase,width)
 -- Two curved halves form a continuous luminous orbit rather than a polygon outline.
 for half=0,1 do
  ribbon(r,name,function(t)
   local a=phase+t*(r.stage=='charge' and 2.8 or 1.6)+half*math.pi
   local spin=CFrame.Angles(tilt,0,0)
   local p=spin:PointToWorldSpace(Vector3.new(math.cos(a)*radius,math.sin(a)*radius,z))
   local q=spin:PointToWorldSpace(Vector3.new(-math.cos(a)*radius,-math.sin(a)*radius,z))
   local tangent=spin:VectorToWorldSpace(Vector3.new(-math.sin(a),math.cos(a),0))
   return p,q,tangent,-tangent,radius*1.32,radius*1.32
  end,width)
 end
end
local function flare(r,size)
 if used.flares>=limits.flares then return end
 local art=r.art
 local at=Instance.new('Attachment');at.Name='RadianceOrigin';at.Parent=art.carrier
 local gui=Instance.new('BillboardGui');gui.Name='SpellRadiance';gui.Adornee=at;gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.MaxDistance=100;gui.Size=UDim2.fromScale(size,size);gui.Parent=art.carrier
 local images={}
 for i,row in ipairs({{SMOKE,r.color,.72,1.4},{SPARK,r.color,.48,.8},{SMOKE,color(r),.15,.24}})do
  local image=Instance.new('ImageLabel');image.Name=i==3 and 'LuminousCore'or 'SoftRadiance';image.BackgroundTransparency=1
  image.AnchorPoint=Vector2.new(.5,.5);image.Position=UDim2.fromScale(.5,.5);image.Size=UDim2.fromScale(row[4],row[4]);image.Image=row[1];image.ImageColor3=row[2];image.ImageTransparency=row[3];image.ZIndex=i;image.Parent=gui
  images[#images+1]={image=image,alpha=row[3]}
 end
 art.flare={at=at,gui=gui,images=images,size=size};used.flares+=1
end
local function particles(r,name,texture,n,size,speed,life,rate,smoke,offset)
 local reserve=rate and math.ceil(rate*life)or n
 if used.particles+reserve>limits.particles then return end
 local art=r.art
 local at=Instance.new('Attachment');at.Name=name..'Origin';at.Parent=art.carrier
 local e=Instance.new('ParticleEmitter');e.Name=name;e.Texture=texture;e.Enabled=rate~=nil;e.Rate=rate or 0
 e.Lifetime=NumberRange.new(life*.65,life);e.Speed=NumberRange.new(speed*.4,speed);e.SpreadAngle=Vector2.new(35,35)
 e.EmissionDirection=Enum.NormalId.Back;e.Rotation=NumberRange.new(-180,180);e.RotSpeed=NumberRange.new(-65,65)
 e.Drag=smoke and 2 or 4;e.LightEmission=smoke and .35 or .9;e.LightInfluence=smoke and .4 or 0
 e.Color=ColorSequence.new(color(r),r.color)
 e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,size*.25),NumberSequenceKeypoint.new(.14,size),NumberSequenceKeypoint.new(1,smoke and size*1.8 or 0)})
 e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.25),NumberSequenceKeypoint.new(.25,smoke and .8 or .4),NumberSequenceKeypoint.new(1,1)})
 e.Acceleration=Vector3.yAxis*(smoke and 1.5 or -2)
 e:SetAttribute('ReviewBurstCount',rate and 0 or n);e.Parent=at
 if not rate then e.SpreadAngle=Vector2.new(180,180)end
 art.emitters[#art.emitters+1]={at=at,e=e,offset=offset or Vector3.zero,reserve=reserve,burst=not rate and n or nil};used.particles+=reserve
end
local function wake(r,lanes,width,length)
 for i=1,lanes do
  local phase=i*math.pi*2/lanes
  ribbon(r,'FlowingWake',function(t)
   local a=t*6+phase
   local p=Vector3.new(math.cos(a)*.16,math.sin(a)*.16,.1)
   local q=Vector3.new(math.cos(a-1)*.38,math.sin(a-1)*.38,length)
   return p,q,Vector3.new(.1,0,1),Vector3.new(-.2,.1,1),length*.35,length*.25
  end,width,r.profile.family=='fire'and FIRE or SMOKE)
 end
end
local function shockwave(r,radius,ground)
 for half=0,3 do
  local start=half*math.pi*.5
  ribbon(r,'ExpandingShockwave',function(t)
   local u=smooth(t/r.life);local rad=radius*(.18+u*.82)
   if r.definition.shape=='ring'and ground then
    -- Keep the safe hole completely empty, even during the expansion.
    rad=r.definition.innerRadius+(radius-r.definition.innerRadius)*(.8+u*.2)
   end
   local a,b=start,start+math.pi*.5
   local p=Vector3.new(math.cos(a)*rad,math.sin(a)*rad,0)
   local q=Vector3.new(math.cos(b)*rad,math.sin(b)*rad,0)
   local ta=Vector3.new(-math.sin(a),math.cos(a),0);local tb=Vector3.new(-math.sin(b),math.cos(b),0)
   if ground then local rotate=CFrame.Angles(math.pi*.5,0,0);p=rotate*p+Vector3.yAxis*.08;q=rotate*q+Vector3.yAxis*.08;ta=rotate*ta;tb=rotate*tb end
   return p,q,ta,tb,rad*.55,rad*.55
  end,ground and .12 or .09)
 end
end
function A.attach(r)
 local carrier=r.parts[1]and r.parts[1].part;if not carrier then return end
 r.art={carrier=carrier,lines={},emitters={}}
 local family=r.profile.family;local magic=family~='physical'and family~='earth'and family~='web'
 if r.stage=='charge'then
  if magic then
   flare(r,1.7)
   for i=1,2 do
    ribbon(r,'GatheringSpiral',function(t)
     local progress=clamp(t/r.definition.windup);local a=t*4+i*math.pi;local radius=.85*(1-progress*.65)
     local p=Vector3.new(math.cos(a)*radius,math.sin(a)*radius,.15)
     return p,Vector3.zero,Vector3.new(-math.sin(a),math.cos(a),0),Vector3.new(0,0,-1),.7,.2
    end,.05)
   end
   particles(r,'GatheringMotes',SPARK,0,.15,.3,.35,9,false)
  elseif family=='web'then orbit(r,'SilkGather',.6,0,.4,0,.025)end
 elseif r.stage=='projectile'then
  if magic then flare(r,family=='fire'and 2.2 or family=='shadow'and 1.65 or 1.45)end
  if family=='fire'then
   wake(r,3,.34,3.2)
   particles(r,'TurbulentFlame',FIRE,0,.65,.6,.28,22,false,Vector3.new(0,0,.3))
   particles(r,'CoolingSmoke',SMOKE,0,.45,.5,.38,7,true,Vector3.new(0,0,.8))
  elseif family=='frost'then
   wake(r,2,.075,2.2);particles(r,'IceDust',SPARK,0,.12,.4,.3,12,false)
   particles(r,'ColdVapor',SMOKE,0,.55,.25,.28,6,true)
  elseif family=='arcane'then orbit(r,'RunicHelix',.65,0,.4,.5,.06);wake(r,1,.13,2)
  elseif family=='soul'then wake(r,3,.14,2.5);particles(r,'SoulMotes',SMOKE,0,.24,.6,.4,8,false)
  elseif family=='shadow'then orbit(r,'RiftCorona',.7,0,.4,0,.06);wake(r,2,.12,2.3)
  elseif family=='venom'then wake(r,1,.18,1.6);particles(r,'AcidMist',SMOKE,0,.3,.4,.3,9,true)
  elseif family=='web'then wake(r,2,.028,1.4)
  else particles(r,'DustWake',SMOKE,0,.25,.5,.25,6,true)end
 elseif r.stage=='impact'then
  if magic then flare(r,r.profile.heavy and 3.8 or 2.8)end
  if magic or family=='web'then shockwave(r,family=='fire'and 1.6 or 1.25,false)end
  particles(r,'ImpactSparks',SPARK,magic and 12 or 5,.13,3,.32,nil,false)
  if family=='fire'then particles(r,'ImpactFlame',FIRE,8,1.2,1.6,.4,nil,false);particles(r,'AfterSmoke',SMOKE,4,.8,.5,.55,nil,true)
  elseif family=='frost'then particles(r,'FrostMist',SMOKE,5,.75,.7,.38,nil,true)
  elseif family=='venom'then particles(r,'AcidSpray',SMOKE,6,.45,2,.38,nil,false)
  elseif family=='soul'or family=='shadow'then particles(r,'SpiritRelease',SMOKE,5,.5,1,.45,nil,false)
  elseif family=='earth'then particles(r,'StoneDust',SMOKE,5,.65,.7,.4,nil,true)end
 elseif r.stage=='pulse'then
  local d=r.definition
  if d.shape=='circle'or d.shape=='trail'or d.shape=='ring'then shockwave(r,d.radius*.96,true)
  elseif d.shape=='line'then
   for i=1,2 do
    ribbon(r,'GroundFissure',function(t)
     local side=(i==1 and -1 or 1)*d.width*.35
     return Vector3.new(side,.08,0),Vector3.new(side,.08,-d.range),Vector3.new(0,0,-1),Vector3.new(0,0,-1),d.range*.22,-d.range*.22
    end,.12)
   end
  else
   local radius=d.range*.76
   ribbon(r,'SweepingCrescent',function(t)
    local a=math.rad(-d.angle*.4);local b=math.rad(d.angle*.4)
    return Vector3.new(math.sin(a)*radius,.1,-math.cos(a)*radius),Vector3.new(math.sin(b)*radius,.1,-math.cos(b)*radius),Vector3.new(math.cos(a),0,math.sin(a)),Vector3.new(math.cos(b),0,math.sin(b)),radius*.5,radius*.5
   end,.22)
  end
  if d.shape~='ring'and magic then flare(r,2.1);particles(r,'GroundPlume',family=='fire'and FIRE or SMOKE,5,.6,.8,.35,nil,family~='fire')end
  if d.shape=='ring'and magic then
   -- Upward plumes stay in the hazardous band; never place a flare in its safe center.
   for i=1,6 do
    local a=i*math.pi/3;local offset=Vector3.new(math.cos(a)*d.radius*.9,.15,math.sin(a)*d.radius*.9)
    local before=#r.art.emitters
    particles(r,'PerimeterSurge',family=='fire'and FIRE or family=='frost'and SMOKE or SPARK,3,family=='fire'and .9 or .55,1.8,.4,nil,false,offset)
    if #r.art.emitters>before then
     local e=r.art.emitters[#r.art.emitters].e;e.EmissionDirection=Enum.NormalId.Top;e.SpreadAngle=Vector2.new(16,16);e.Acceleration=Vector3.yAxis*2
    end
   end
  end
 end
 if (r.stage=='impact'or r.stage=='projectile')and magic and used.lights<limits.lights then
  local light=Instance.new('PointLight');light.Name='SpellLocalLight';light.Color=r.color;light.Brightness=.6;light.Range=r.stage=='impact'and 5 or 3;light.Shadows=false;light.Parent=carrier;r.art.light=light;used.lights+=1
 end
end
function A.pose(r,cf,age,scale,fade)
 local art=r.art;if not art then return end
 local u=clamp(age/r.life);local transient=r.stage=='impact'or r.stage=='pulse'
 local dissolve=transient and smooth((u-.08)/.92)or fade or 0
 local gain=r.stage=='charge'and .4+.6*smooth(age/r.definition.windup)or 1
 for _,v in ipairs(art.lines)do
  local p,q,ta,tb,c0,c1=v.path(math.max(0,age))
  v.a.WorldCFrame=cf*frame(p*scale,ta);v.b.WorldCFrame=cf*frame(q*scale,tb)
  local width=v.width*scale*gain*(1-dissolve*.7)
  v.beam.Width0=width;v.beam.Width1=width*(r.stage=='charge'and .2 or .7)
  v.beam.CurveSize0=(c0 or 0)*scale;v.beam.CurveSize1=(c1 or 0)*scale
  local base=v.soft and .65 or .12
  local bucket=math.floor(dissolve*30)
  if v.bucket~=bucket then v.bucket=bucket;v.beam.Transparency=NumberSequence.new(base+(1-base)*dissolve)end
 end
 for _,v in ipairs(art.emitters)do
  v.at.WorldCFrame=cf*CFrame.new(v.offset*scale)
  if v.burst then v.e:Emit(v.burst);v.burst=nil end
 end
 if art.flare then
  local f=art.flare;f.at.WorldPosition=cf.Position
  local flash=transient and (1-smooth(u/.5))or (.88+.12*math.sin(age*8))
  local extent=f.size*scale*(transient and .7+smooth(u)*.6 or 1)
  f.gui.Size=UDim2.fromScale(extent,extent)
  for _,v in ipairs(f.images)do v.image.ImageTransparency=1-(1-v.alpha)*flash*gain end
 end
 if art.light then art.light.Brightness=.6*(transient and 1-smooth(u/.4)or gain)end
end
function A.release(r)
 local art=r.art;if not art then return end
 used.beams-=#art.lines
 for _,e in ipairs(art.emitters)do used.particles-=e.reserve end
 if art.flare then used.flares-=1 end;if art.light then used.lights-=1 end
 r.art=nil
end
function A.count()return used.beams,used.particles,used.lights,used.flares end
return A
