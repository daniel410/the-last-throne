-- Procedural, client-only embellishment for confirmed combat presentation.
-- Existing geometry retains range information when this optional layer is culled.
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local Catalog=require(RS.Shared.PixelFXCatalog)
local Geometry=require(script.Parent.SkillEffectGeometry)
local Profiles=require(script.Parent.SkillVFXProfiles)
local Surfaces=require(script.Parent.HeroVFXSurfaces)
local FX={}
local active={}
local connection
local beams=0
local chips=0
local glowCount=0
local particleCount=0
local WHITE=Color3.fromRGB(248,248,229)
local palette={steel=Color3.fromRGB(163,210,244),axe=Color3.fromRGB(243,172,89),shield=Color3.fromRGB(102,211,255),holy=Color3.fromRGB(255,189,50),arrow=Color3.fromRGB(192,232,170),nature=Color3.fromRGB(93,219,135),arcane=Color3.fromRGB(181,139,255),gravity=Color3.fromRGB(144,83,226),wind=Color3.fromRGB(173,249,225),water=Color3.fromRGB(81,186,249),fire=Color3.fromRGB(255,112,45),earth=Color3.fromRGB(176,136,91),frost=Color3.fromRGB(142,231,255),lightning=Color3.fromRGB(90,164,255),gun=Color3.fromRGB(255,215,133),bomb=Color3.fromRGB(255,144,66)}
local function finite(n)return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function vector(v)return typeof(v)=="Vector3" and finite(v.X)and finite(v.Y)and finite(v.Z)and math.abs(v.X)<1e7 and math.abs(v.Y)<1e7 and math.abs(v.Z)<1e7 end
local function erase(i)
 local r=table.remove(active,i);beams-=#r.lines;chips-=#r.chips;glowCount-=#r.glows;particleCount-=r.particles;Surfaces.release(r);r.model:Destroy()
end
function FX.clear()
 for i=#active,1,-1 do erase(i)end
 if connection then connection:Disconnect();connection=nil end
end
function FX.count()return #active,beams,chips,glowCount,particleCount,Surfaces.count()end
local function visible(first,last)
 local camera=workspace.CurrentCamera;if not camera then return true end
 local delta=last-first
 local t=delta.Magnitude>.01 and math.clamp((camera.CFrame.Position-first):Dot(delta)/delta:Dot(delta),0,1)or 0
 return(camera.CFrame.Position-(first+delta*t)).Magnitude<=100
end
local function make(first,last,life,key,id)
 if not vector(first)or not vector(last)or not visible(first,last)or #active>=(Input.TouchEnabled and 8 or 12)then return end
 local m=Instance.new("Model");m.Name="HeroVFX";m:SetAttribute("SkillId",id or "");m:SetAttribute("Style",key)
 local carrier=Instance.new("Part");carrier.Name="VFXCarrier";carrier.Size=Vector3.one*.05;carrier.Transparency=1
 carrier.Anchored=true;carrier.CanCollide=false;carrier.CanTouch=false;carrier.CanQuery=false;carrier.CastShadow=false
 carrier.Position=first;carrier.Parent=m;m.Parent=workspace;Debris:AddItem(m,life+.2)
 local r={model=m,carrier=carrier,at=workspace:GetServerTimeNow(),life=life,lines={},chips={},glows={},flares={},faces={},particles=0,color=palette[key]or palette.steel,key=key,hot=key=="holy"and Color3.fromRGB(255,226,128)or WHITE}
 table.insert(active,r)
 if not connection and Run:IsClient()then connection=Run.RenderStepped:Connect(function()FX.step(workspace:GetServerTimeNow())end)end
 return r
end
local function line(r,name,path,width,color,endWidth)
 if beams>=(Input.TouchEnabled and 144 or 240)then return end
 width*=1.15
 endWidth=endWidth and endWidth*1.15 or width*.45
 local a=Instance.new("Attachment");a.Parent=r.carrier
 local b=Instance.new("Attachment");b.Parent=r.carrier
 local beam=Instance.new("Beam");beam.Name=name;beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=1
 beam.Width0=width;beam.Width1=endWidth;beam.Color=ColorSequence.new(r.key=="holy"and(color==WHITE and r.hot or color or r.color)or color or r.color,r.hot)
 beam.LightEmission=1;beam.LightInfluence=0;beam.Transparency=NumberSequence.new(.18);beam.Parent=r.carrier
 local glow
 if glowCount<(Input.TouchEnabled and 48 or 96)and #r.glows<24 and width>=.10 then
  glow=beam:Clone();glow.Name="SoftGlow";glow.Width0=width*3.8;glow.Width1=endWidth*3.8
  glow.Color=ColorSequence.new(r.color);glow.Texture="rbxasset://textures/particles/smoke_main.dds";glow.TextureMode=Enum.TextureMode.Stretch;glow.Transparency=NumberSequence.new(.62);glow.Parent=r.carrier
  table.insert(r.glows,glow);glowCount+=1
 end
 table.insert(r.lines,{a=a,b=b,beam=beam,glow=glow,path=path,width=width,endWidth=endWidth});beams+=1
end
local function curve(r,name,path,count,width,color)
 for i=1,count do
  local from,to=(i-1)/count,i/count
  line(r,name,function(u)return path(from,u),path(to,u)end,width*(.4+.6*math.sin(from*math.pi)),color,width*(.4+.6*math.sin(to*math.pi)))
 end
end
local function ring(r,name,center,radius,width,vertical,inward,color,basis)
 curve(r,name,function(t,u)
  local angle=t*math.pi*2+u*.7;local size=radius*(inward and(1-u*.8)or(.22+.78*(1-(1-u)^3)))
  local offset=vertical and Vector3.new(math.cos(angle)*size,math.sin(angle)*size,0)or Vector3.new(math.cos(angle)*size,0,math.sin(angle)*size)
  return center+(basis and basis:VectorToWorldSpace(offset)or offset)
 end,12,width,color)
end
local function debris(r,center,count,kind,scale)
 for i=1,count do
  if chips>=48 then break end
  local p=Instance.new((kind=="IceShard"or kind=="RockChip")and"WedgePart"or"Part");p.Name=kind;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  p.Material=kind=="IceShard" and Enum.Material.Ice or kind=="RockChip" and Enum.Material.Slate or Enum.Material.Neon
  if kind=="WaterSpray"then p.Shape=Enum.PartType.Ball;p.Material=Enum.Material.Glass;p.Transparency=.18 end
  p.Color=r.color;p.Size=(kind=="WaterSpray"and Vector3.new(.22,.42,.22)or kind=="IceShard" and Vector3.new(.18,.7,.18)or Vector3.one*.18)*scale
  p.CFrame=CFrame.new(center);p.Parent=r.model
  local angle=i*2.39996;local offset=Vector3.new(math.cos(angle),.5+i%3*.2,math.sin(angle))*scale
  table.insert(r.chips,{part=p,center=center,offset=offset,size=p.Size,spin=angle});chips+=1
 end
end
-- Engine-bundled textures avoid a new asset upload/permission dependency.
local function flourish(r,position,scale,key,strong)
 local a=Instance.new("Attachment");a.Name="FlourishOrigin";a.Parent=r.carrier;a.WorldPosition=position
 local gui=Instance.new("BillboardGui");gui.Name="ImpactFlare";gui.Adornee=a;gui.AlwaysOnTop=false
 gui.LightInfluence=0;gui.MaxDistance=100;gui.Size=UDim2.fromScale(scale,scale);gui.Parent=r.carrier
 local halo=Instance.new("ImageLabel");halo.Name="ElementalFlare";halo.BackgroundTransparency=1;halo.Size=UDim2.fromScale(1,1)
 halo.Image="rbxasset://textures/particles/sparkles_main.dds";halo.ImageColor3=r.color;halo.ImageTransparency=.25;halo.Parent=gui
 local aura=halo:Clone();aura.Name="SoftFlare";aura.Image="rbxasset://textures/particles/smoke_main.dds";aura.Size=UDim2.fromScale(1.5,1.5);aura.Position=UDim2.fromScale(-.25,-.25);aura.ImageTransparency=.55;aura.ZIndex=1;aura.Parent=gui
 halo.ZIndex=2
 local core=halo:Clone();core.Name="WhiteHotCore";core.Size=UDim2.fromScale(.38,.38);core.Position=UDim2.fromScale(.31,.31);core.ImageColor3=r.hot;core.ZIndex=3;core.Parent=gui
 table.insert(r.flares,{gui=gui,halo=halo,core=core,aura=aura,size=scale})
 local function burst(name,texture,count,size,speed,smoke)
  local available=(Input.TouchEnabled and 96 or 192)-particleCount
  count=math.min(count,available);if count<=0 then return end
  local e=Instance.new("ParticleEmitter");e.Name=name;e.Texture=texture;e.Rate=0;e.Enabled=false
  e.Lifetime=NumberRange.new(math.min(r.life*.55,.28),math.min(r.life*.85,.5))
  e.Speed=NumberRange.new(speed*.5,speed);e.Drag=smoke and 3 or 5;e.SpreadAngle=Vector2.new(180,180)
  e.LightEmission=1;e.LightInfluence=0;e.Color=ColorSequence.new(r.color,r.hot)
  e.Rotation=NumberRange.new(0,360);e.RotSpeed=NumberRange.new(-100,100)
  e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,size*.3),NumberSequenceKeypoint.new(.18,size),NumberSequenceKeypoint.new(1,0)})
  e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.25,smoke and .65 or .25),NumberSequenceKeypoint.new(1,1)})
  e.Acceleration=Vector3.yAxis*(key=="fire"and 8 or key=="holy"and 3 or key=="water"and -10 or key=="gravity"and -2 or smoke and 3 or -4)
  if key=="fire"or key=="holy"then e.EmissionDirection=Enum.NormalId.Top;e.SpreadAngle=Vector2.new(25,25)end
  if key=="fire"then e.Color=ColorSequence.new(Color3.fromRGB(255,199,64),Color3.fromRGB(207,46,18))end
  if key=="lightning"then e.Lifetime=NumberRange.new(.05,.11);e.Size=NumberSequence.new(size*.5)end
  e:SetAttribute("ReviewBurstCount",count);e.Parent=a;e:Emit(count)
  r.particles+=count;particleCount+=count
 end
 burst("ElementalSparks","rbxasset://textures/particles/sparkles_main.dds",strong and 16 or 8,scale*.13,scale*2.2,false)
 if key=="fire"or key=="bomb"or key=="earth"then
  burst("ElementalPlume",key=="earth"and"rbxasset://textures/particles/smoke_main.dds"or"rbxasset://textures/particles/fire_main.dds",strong and 7 or 4,scale*.65,scale*.8,true)
 end
end
function FX.step(now)
 if not finite(now)then return end
 for i=#active,1,-1 do
  local r=active[i];local u=math.clamp((now-r.at)/r.life,0,1)
  if not r.model.Parent or now-r.at>=r.life then erase(i)
  else
   local fade=r.key=="lightning"and math.clamp((now-r.at)/.16,0,1)or math.clamp((u-.12)/.88,0,1)
   local bucket=math.floor(fade*24)
   local changed=r.fadeBucket~=bucket
   if changed then r.fadeBucket=bucket;r.alpha=NumberSequence.new(.18+fade*.82);r.glowAlpha=NumberSequence.new(.62+fade*.38)end
   for _,s in ipairs(r.lines)do
    local a,b=s.path(u);s.a.WorldPosition=a;s.b.WorldPosition=b
    s.beam.Width0=s.width*(1-fade*.7);s.beam.Width1=s.endWidth*(1-fade*.7)
    if changed then s.beam.Transparency=r.alpha end
    if s.glow then
     s.glow.Width0=s.beam.Width0*3.8;s.glow.Width1=s.beam.Width1*3.8
     if changed then s.glow.Transparency=r.glowAlpha end
    end
   end
   Surfaces.step(r,u,fade)
   for _,s in ipairs(r.flares)do
    local burstFade=math.clamp(u/.65,0,1)
    local size=s.size*(.6+math.sin(math.min(u*4,1)*math.pi/2)*.6)
    s.gui.Size=UDim2.fromScale(size,size);s.halo.ImageTransparency=.25+burstFade*.75;s.core.ImageTransparency=burstFade;s.aura.ImageTransparency=.55+burstFade*.45
   end
   for _,s in ipairs(r.chips)do
    local p=s.part
    p.CFrame=CFrame.new(s.center+s.offset*(u*2.5)+Vector3.yAxis*(math.sin(u*math.pi)*1.2-u*u))*CFrame.Angles(u*5,s.spin+u*3,u*2)
    p.Size=s.size*(1-u*.7);p.Transparency=fade
   end
  end
 end
 if #active==0 and connection then connection:Disconnect();connection=nil end
end
local function floorAt(at,character)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=character and{character}or{};params.RespectCanCollide=true
 local hit=workspace:Raycast(at+Vector3.yAxis*2,-Vector3.yAxis*18,params)
 return hit and hit.Position+Vector3.yAxis*.12 or at-Vector3.yAxis*2.6
end
local function forward(first,last)
 local d=last-first;return d.Magnitude>.01 and d.Unit or Vector3.new(0,0,-1)
end
-- Every authored skill resolves through the same stable server skill catalog.
function FX.skill(character,id,first,last,pulse,points,muzzle)
 local row=Catalog.byId[id];local profile=Profiles.get(id)
 if not row or not profile or not vector(first)or not vector(last)or not finite(pulse)or pulse<1 then return end
 local d=row.definition
 -- The dedicated Wind Lance renderer owns its release; no empty duplicate model.
 if profile.shape=="wind"then return end
 local r=make(first,last,profile.life,row.key,id);if not r then return end
 if row.classId=="dwarf"and row.key=="steel"then r.color=palette.axe end
 r.model:SetAttribute("Silhouette",profile.shape);r.model:SetAttribute("Pulse",pulse)
 local dir=forward(first,last)
 if(first-last).Magnitude<.01 then
  local root=character and character:FindFirstChild("HumanoidRootPart")
  dir=root and root.CFrame.LookVector or Vector3.new(0,0,-1)
 end
 local flat=Vector3.new(dir.X,0,dir.Z);flat=flat.Magnitude>.01 and flat.Unit or Vector3.new(0,0,-1)
 local right=Vector3.new(-flat.Z,0,flat.X)
 local area=d.form=="ground"or d.form=="area"or d.detonate or d.areaRadius~=nil
 -- For originArea, the server's center is the departure point, not current origin.
 local center=area and last or first
 local floor=floorAt(center,character)
 local radius=d.areaRadius or((d.form=="ground"or d.detonate)and d.radius)or d.range or 5
 local angle=d.form=="area"and 360 or d.angle or 80
 local width,count,shape=profile.width,profile.lanes,profile.shape
 local phase=(pulse-1)*1.3
 local function stroke(name,a,b,w,color)line(r,name,function()return a,b end,w or width,color)end
 local function sector(name,at,rad,arc,lane,low)
  curve(r,name,function(t,u)
   local a=math.rad(-arc/2+arc*t)+(arc>=359 and phase+u*.8 or (1-(1-u)^3-.5)*.6)
   local v=flat*math.cos(a)+right*math.sin(a)
   return at+v*rad+Vector3.yAxis*(low and .12 or math.sin(t*math.pi)*.35+(lane-1)*.22)
  end,12,width*(1-(lane-1)*.12))
 end
 if shape=="thrust"then
  stroke("ThrustEdge",first,last,width,WHITE)
  for lane=1,count do local side=lane%2==0 and -1 or 1
   stroke("ThrustPressure",first+right*side*.45,last+right*side*.08,width*.4)
  end
 elseif shape=="cleave"then
  for lane=1,count do curve(r,"DescendingCleave",function(t,u)
   local a=t*math.pi*.8
   return first+flat*math.sin(a)*math.min(radius,5)+Vector3.yAxis*(math.cos(a)*2.8-u*.5)+right*(lane-(count+1)/2)*.3
  end,12,width)end
 elseif shape=="slash"or shape=="crescent"or shape=="areslash"or shape=="spin"or shape=="low"or shape=="counter"then
  local at=shape=="low"and floor or first
  local arc=shape=="spin"and 360 or angle
  for lane=1,count do sector(shape=="low"and"LowSweep"or"BladeRibbon",at,math.min(radius,8)*(.72+lane*.08),arc,lane,shape=="low")end
  if shape=="counter"then sector("CounterGuard",floor,2.4,110,1,true)end
 elseif shape=="cross"then
  for side=-1,1,2 do
   stroke("SunwardCross",first+flat*.5+right*side*1.6+Vector3.yAxis*1.2,first+flat*math.min(radius,6)-right*side*1.6-Vector3.yAxis*.6,width,WHITE)
  end
 elseif shape=="guard"or shape=="warcry"or shape=="holy"or shape=="ward"then
  if shape=="guard"and d.form~="area"then
   local at=first+flat*2;local basis=CFrame.lookAt(at,at+flat)
   ring(r,"GuardHalo",at,1.8,width,true,false,nil,basis)
   for side=-1,1,2 do stroke("GuardChevron",at+right*side*1.2,at+Vector3.yAxis*1.7,width*.6,WHITE)end
  elseif shape=="warcry"then
   for lane=1,count do sector("WarcryWave",floor,radius*lane/count,angle,lane,true)end
  else
   for lane=1,(shape=="holy"and 1 or shape=="ward"and 2 or count)do
    if shape=="ward"then
     local basis=CFrame.Angles(0,lane*math.pi/3+phase,0)
     ring(r,"WardOrbit",first,2.2,width,true,false,nil,basis)
    else ring(r,"DawnSeal",floor,radius*(shape=="holy"and .87 or(.55+lane*.12)),width,false,false)end
   end
  end
 elseif shape=="axe"then
  local from,to=first,last;if d.returning and pulse%2==0 then from,to=last,first end
  r.model:SetAttribute("Returning",d.returning and pulse%2==0 or false)
  stroke("AxeWake",from,to,width*.45)
  local axis=forward(from,to);local basis=CFrame.lookAt(to,to+axis)
  curve(r,"AxeRotation",function(t,u)
   local a=t*math.pi*1.6+u*7+phase
   return to+basis.RightVector*math.cos(a)*.7+basis.UpVector*math.sin(a)*.7
  end,8,width)
 elseif shape=="arrow"or shape=="fan"or shape=="bullet"then
  local targets={last}
  if shape=="fan"then
   targets=Geometry.sector(first,flat,math.min(radius,50),angle,count-1)
   if id=="elf.common.multi"and type(points)=="table"and #points>0 then
    targets={};for i=1,math.min(#points,5)do if vector(points[i])then table.insert(targets,points[i])end end
   end
  end
  for lane,target in ipairs(targets)do
   for wake=1,(shape=="fan"and 1 or count)do
    local offset=right*(wake-((shape=="fan"and 1 or count)+1)/2)*.08
    stroke(shape=="bullet"and"RifleTracer"or"ArrowPressure",first+offset,target+offset,width/wake^.3)
   end
   local axis=forward(first,target);local cf=CFrame.lookAt(target,target+axis)
   if shape~="bullet"then
    for side=-1,1,2 do stroke("ArrowEdge",target-axis*.7+cf.RightVector*side*.18,target,width*.6,WHITE)end
   end
  end
  if row.key~="arrow"and shape~="bullet"and shape~="fan"then
   local basis=CFrame.lookAt(first,first+dir)
   curve(r,row.key=="lightning"and"ArrowSpark"or"EnchantedArrow",function(t,u)
    local a=t*math.pi*4+phase+u*6
    return first+(last-first)*t+basis.RightVector*math.cos(a)*.22+basis.UpVector*math.sin(a)*.22
   end,8,width*.6)
  end
 elseif shape=="rain"or shape=="ash"or shape=="hail"or shape=="mortar"then
  local at=floorAt(last,character)
  for lane=1,count do
   local a=lane*2.39996+phase;local rad=shape=="mortar"and .3 or radius*math.sqrt(lane/(count+1))*.85
   local target=at+Vector3.new(math.cos(a)*rad,0,math.sin(a)*rad)
   line(r,shape=="hail"and"HailDescent"or shape=="ash"and"AshDescent"or shape=="mortar"and"MortarDescent"or"ArrowRain",function(u)
    local height=(1-u)*8
    return target+Vector3.yAxis*(height+1.1),target+Vector3.yAxis*height
   end,width)
  end
  ring(r,"LandingRipple",at,math.min(radius,4),width*.5,false,false)
 elseif shape=="blast"or shape=="earth"or shape=="lava"then
  local at=area and floorAt(last,character)or floor
  if area or angle>=359 then ring(r,"GroundPressure",at,radius,width*.6,false,false)
  else sector("GroundSector",at,radius,angle,1,true)end
  if shape=="blast"then
   debris(r,at,math.min(count,7),"Ember",1.4)
   if not area and angle<359 then sector("BlastCone",at+Vector3.yAxis*.7,radius*.7,angle,1,false)end
  else
   for lane=1,count do
    local a=(area or angle>=359)and(lane/count*math.pi*2)or math.rad(-angle/2+angle*(lane-.5)/count)
    local heading=flat*math.cos(a)+right*math.sin(a)
    curve(r,shape=="lava"and"LavaFissure"or"EarthFissure",function(t,u)
     return at+heading*radius*t+right*math.sin(t*17+lane)*.18+Vector3.yAxis*.03
    end,4,width,shape=="lava"and palette.fire or palette.earth)
   end
   debris(r,at,4,shape=="lava"and"Ember"or"RockChip",1.4)
  end
 elseif shape=="stone"or shape=="frost"and not area then
  stroke(shape=="stone"and"StoneLanceAxis"or"FrostLanceAxis",first,last,width,WHITE)
  local basis=CFrame.lookAt(last,last+dir)
  for lane=1,math.min(count,3)do
   local side=lane%2==0 and -1 or 1
   stroke("CrystalFacet",last-dir*2+basis.RightVector*side*.5,last,width*.65)
  end
  debris(r,last,3,shape=="stone"and"RockChip"or"IceShard",1)
 elseif shape=="frost"then
  ring(r,"FrostBloom",floorAt(last,character),radius,width*.6,false,false)
  debris(r,floorAt(last,character),math.min(count,7),"IceShard",1.7)
 elseif shape=="lightning"then
  local path={}
  if d.form=="chain"then
   local from=first
   for i=1,math.min(type(points)=="table"and #points or 0,d.maxTargets or 4)do
    if vector(points[i])then table.insert(path,{from,points[i]});from=points[i]end
   end
  else table.insert(path,{d.form=="ground"and last+Vector3.yAxis*10 or first,last})end
  for _,link in ipairs(path)do
   local bolts=Geometry.lightning(link[1],link[2],6)
   for i=1,#bolts-1 do stroke("ElectricCore",bolts[i],bolts[i+1],width,WHITE)end
  end
 elseif shape=="vine"then
  for lane=1,count do
   local at=floor
   if d.form=="cone"then
    local a=math.rad(-angle/2+angle*(lane-.5)/count)
    at=floor+(flat*math.cos(a)+right*math.sin(a))*radius*.7
   else local a=lane/count*math.pi*2;at=floorAt(last,character)+Vector3.new(math.cos(a),0,math.sin(a))*radius*.55 end
   curve(r,"RootingVine",function(t,u)local a=t*5+phase;return at+Vector3.new(math.cos(a)*.35,t*2.8,math.sin(a)*.35)end,6,width)
  end
 elseif shape=="gravity"then
  local at=floorAt(last,character)
  for lane=1,count do curve(r,"GravityInfall",function(t,u)
   local a=t*math.pi*3+lane*math.pi+u*3;local rad=radius*(1-t)*(.8-u*.6)
   return at+Vector3.new(math.cos(a)*rad,.3+t*1.6,math.sin(a)*rad)
  end,10,width)end
 elseif shape=="water"or shape=="steam"then
  local at=area and floorAt(last,character)or last
  ring(r,"TidalLip",at,area and radius or 1.8,width,false,false)
  debris(r,at,math.min(count,6),"WaterSpray",1)
  if shape=="steam"then
   for lane=1,count do curve(r,"SteamCurl",function(t,u)local a=t*5+lane*math.pi;return at+Vector3.new(math.cos(a)*(.4+u),t*3+u,math.sin(a)*(.4+u))end,6,width,WHITE)end
  end
 elseif shape=="fire"or shape=="arcane"then
  local at=area and floorAt(last,character)or first
  if area then ring(r,"CinderRing",at,radius,width*.6,false,false)end
  local basis=CFrame.lookAt(first,first+dir)
  for lane=1,count do curve(r,shape=="fire"and"FlameTongue"or"ArcaneHelix",function(t,u)
   local a=t*math.pi*3+lane*math.pi*2/count+u*4+phase
   if area then
    local heading=lane*math.pi*2/count+phase+math.sin(t*math.pi)*.18+u*.25
    local rad=radius*(.65+t*.12)
    return at+Vector3.new(math.cos(heading)*rad,t*2.2,math.sin(heading)*rad)
   end
   return first+(last-first)*t+basis.RightVector*math.cos(a)*.32+basis.UpVector*math.sin(a)*.32
  end,8,width)end
 end
 -- Filled silhouettes carry the effect; narrow beams remain as edge highlights.
 local surfaceOrigin=shape=="low"and floor or first
 if shape=="slash"or shape=="crescent"or shape=="areslash"or shape=="spin"or shape=="low"or shape=="counter"then
  local sweep=shape=="spin"and 360 or angle
  local start=#r.faces
  Surfaces.ribbon(r,"BladeSurface",function(t)
   local a=math.rad(-sweep/2+sweep*t)+(shape=="spin"and phase or 0)
   return surfaceOrigin+(flat*math.cos(a)+right*math.sin(a))*math.min(radius,8)*.8
  end,Vector3.yAxis,shape=="spin"and 1.6 or 2.1,.28)
  Surfaces.animate(r,start,surfaceOrigin,Vector3.yAxis,shape=="spin"and 1.8 or .6,false,r.life)
 elseif shape=="cleave"then
  local start=#r.faces
  Surfaces.ribbon(r,"CleaveSurface",function(t)local a=t*math.pi*.8;return first+flat*math.sin(a)*math.min(radius,5)+Vector3.yAxis*math.cos(a)*2.8 end,right,1.5,.25)
  Surfaces.animate(r,start,first,right,.65,false,r.life)
 elseif shape=="cross"then
  for side=-1,1,2 do
   local a=first+flat*.5+right*side*1.6+Vector3.yAxis*1.2
   local b=first+flat*math.min(radius,6)-right*side*1.6-Vector3.yAxis*.6
   Surfaces.ribbon(r,"CrossSurface",function(t)return a+(b-a)*t end,flat,1.15,.28)
  end
 elseif shape=="thrust"then
  Surfaces.triangle(r,"ThrustSurface",first-right*.65,last,first+right*.65,nil,.27)
 elseif shape=="ward"then
  -- Open magical facets surround the caster; the martial guard stays frontal.
  for i=1,6 do
   local a=i*math.pi/3;local radial=Vector3.new(math.cos(a),0,math.sin(a))
   local tangent=Vector3.new(-radial.Z,0,radial.X)
   local at=first+radial*2.1
   local top,bottom=at+Vector3.yAxis*.95,at-Vector3.yAxis*.95
   Surfaces.triangle(r,"ArcaneWardFacet",top,at-tangent*.52,bottom,nil,.62)
   Surfaces.triangle(r,"ArcaneWardFacet",top,bottom,at+tangent*.52,nil,.62)
  end
 elseif shape=="guard"then
  local at=first+flat*1.8;local verts={Vector2.new(-1.3,1.3),Vector2.new(1.3,1.3),Vector2.new(1,-.4),Vector2.new(0,-1.5),Vector2.new(-1,-.4)}
  for i=1,#verts do
   local a,b=verts[i],verts[i%#verts+1]
   Surfaces.triangle(r,"GuardSurface",at,at+right*a.X+Vector3.yAxis*a.Y,at+right*b.X+Vector3.yAxis*b.Y,nil,.62)
  end
 elseif shape=="fire"or shape=="arcane"or shape=="stone"or(shape=="frost"and not area)then
  if area then
   local start=#r.faces
   Surfaces.arc(r,"CinderShockwave",floor,radius*.78,math.min(radius*.13,.8),nil,.48)
   Surfaces.animate(r,start,floor,Vector3.yAxis,.3,true,r.life)
   for i=1,4 do
    local a=i*math.pi/2+phase;local at=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*.6+Vector3.yAxis
    Surfaces.volume(r,"FlameVolume",at,Vector3.new(1.1,2.8,1.1),nil,.42,shape=="fire"and'wedge'or'ball',nil,false,.8)
   end
  else
   local length=math.min((last-first).Magnitude,10)
   if length>.1 then
    if shape=="fire"then
     local basis=CFrame.lookAt(last,last+dir)
     for side=-1,1,2 do
      local start=#r.faces
      Surfaces.ribbon(r,"FlameWake",function(t)
       local tail=last-dir*math.min(length,5)*(1-t)
       return tail+basis.RightVector*side*math.sin(t*math.pi)*.65+basis.UpVector*math.sin(t*math.pi*2)*.28
      end,basis.UpVector,.8,.4,side==1 and Color3.fromRGB(255,171,41)or r.color)
      Surfaces.animate(r,start,last,dir,side*.7,false,r.life*.85)
     end
     for i=1,3 do
      local at=last-dir*(i-.5)*.85
      local p=Surfaces.volume(r,"FlameJet",at,Vector3.new(.55,.85-i*.12,1.3),i==1 and Color3.fromRGB(255,183,47)or nil,.3+i*.05,'wedge',nil,false,.5)
      if p then local face=r.faces[#r.faces];face.cf=CFrame.lookAt(at,at+dir);p.CFrame=face.cf end
     end
    else
     local solid=shape=="frost"or shape=="stone"
     local p=Surfaces.volume(r,shape=="frost"and"IceLanceVolume"or shape=="stone"and"StoneLanceVolume"or"SpellVolume",last-dir*length*.5,Vector3.new(.85,.85,length),nil,.35,solid and'wedge'or'ball',shape=="stone"and Enum.Material.Slate or shape=="frost"and Enum.Material.Ice or nil)
     if p then local entry=r.faces[#r.faces];entry.cf=CFrame.lookAt(p.Position,p.Position+dir);p.CFrame=entry.cf end
    end
   end
  end
 elseif shape=="earth"or shape=="lava"or shape=="blast"or shape=="mortar"then
  if shape=="blast"or shape=="mortar"then
   local at=area and floorAt(last,character)+Vector3.yAxis or first+flat*2
   if id=='dwarf.gunner.bomb_toss'then
    local flash=Surfaces.volume(r,'BombContactFlash',at,Vector3.one*.6,WHITE,.18,'ball')
    if flash then r.faces[#r.faces].fadeDuration=.09 end
    for i=1,5 do
     local a=i*math.pi*2/5;local direction=Vector3.new(math.cos(a),.2,math.sin(a))
     local fragment=Surfaces.volume(r,'BombCasingFragment',at+direction*.25,Vector3.new(.15,.3,.6),Color3.fromRGB(95,75,58),.15,'wedge',Enum.Material.Slate)
     if fragment then
      local face=r.faces[#r.faces];face.cf=CFrame.lookAt(fragment.Position,fragment.Position+direction);fragment.CFrame=face.cf
      face.drift=direction*2.4
     end
    end
   else
   local flash=Surfaces.volume(r,"BlastCore",at,Vector3.one*.9,r.hot,.2,'ball')
   if flash then r.faces[#r.faces].fadeDuration=.09 end
   local start=#r.faces
   Surfaces.arc(r,"BlastShockwave",at-Vector3.yAxis*.7,math.min(radius,4),.55,nil,.38)
   Surfaces.animate(r,start,at-Vector3.yAxis*.7,Vector3.yAxis,.4,true,math.min(r.life,.32))
   end
  else
   if area then
    local start=#r.faces
    Surfaces.arc(r,"RuptureShockwave",floor,radius*.72,math.min(radius*.12,.8),shape=="lava"and palette.fire or r.color,.55)
    Surfaces.animate(r,start,floor,Vector3.yAxis,0,true,r.life)
   end
   for i=1,4 do
    local a=(area or angle>=359)and(i*math.pi/2)or math.rad(-angle/2+angle*(i-.5)/4)
    local at=floor+(flat*math.cos(a)+right*math.sin(a))*radius*.6+Vector3.yAxis*.6
    Surfaces.volume(r,"RisingCrag",at,Vector3.new(1.1,1.8,1.2),nil,.32,'wedge',shape=="earth"and Enum.Material.Slate or nil,false,.5)
   end
  end
 elseif shape=="holy"then
  -- An open sun seal and ascending light distinguish holy magic from water pools.
  for i=1,6 do
   local a=i*math.pi/3;local radial=Vector3.new(math.cos(a),0,math.sin(a))
   local tangent=Vector3.new(-radial.Z,0,radial.X)
   local at=floor+radial*radius*.67+Vector3.yAxis*.05
   Surfaces.triangle(r,"DawnSealRay",at-tangent*.2,at+radial*math.min(radius*.18,1.4),at+tangent*.2,nil,.42)
   local height=1.2+(i%2)*.65
   Surfaces.volume(r,"DawnAscendingLight",at+Vector3.yAxis*height*.5,Vector3.new(.14,height,.14),nil,.48,'ball',nil,false,1.4)
  end
 elseif shape=="water"or shape=="steam"or(shape=="frost"and area)or shape=="gravity"then
  if shape=="frost"then
   local at=floorAt(last,character)
   for i=1,8 do
    local a=i*math.pi/4;local radial=Vector3.new(math.cos(a),0,math.sin(a))
    local facet=Surfaces.volume(r,'FrostRimFacet',at+radial*radius*.83+Vector3.yAxis*.18,Vector3.new(math.min(radius*.55,2.5),.35,.42),nil,.3,'wedge',Enum.Material.Ice)
    if facet then local face=r.faces[#r.faces];face.cf=CFrame.lookAt(facet.Position,facet.Position+radial);facet.CFrame=face.cf end
   end
  else
  local at=area and floorAt(last,character)or last
  local start=#r.faces
  Surfaces.arc(r,"ElementalSurface",at,area and radius*.78 or 1.7,shape=="gravity"and .4 or .65,nil,.55)
  Surfaces.animate(r,start,at,Vector3.yAxis,shape=="gravity"and -1.2 or .35,true,r.life)
  end
  if shape=="water"or shape=="steam"then
   Surfaces.volume(r,"WaterVolume",area and floor+Vector3.yAxis*.35 or last,Vector3.new(2.2,.8,2.2),nil,.62,'ball',nil,true)
   for i=1,4 do
    local a=i*math.pi/2;local radial=Vector3.new(math.cos(a),0,math.sin(a))
    local at=(area and floor or last)+radial*(area and math.min(radius*.55,3)or 1.2)+Vector3.yAxis*.35
    local crest=Surfaces.volume(r,"WaterCrest",at,Vector3.new(1.3,.18,.7),nil,.3,'ball',Enum.Material.Glass,false,.35)
    if crest then local face=r.faces[#r.faces];face.cf=CFrame.lookAt(at,at+radial)*CFrame.Angles(-.45,0,0);crest.CFrame=face.cf;face.drift=radial*.7 end
    Surfaces.volume(r,"WaterFoam",at+Vector3.yAxis*.18,Vector3.new(.8,.08,.12),Color3.fromRGB(192,235,255),.35,'ball',nil,false,.35)
   end
  end
 elseif shape=="arrow"or shape=="fan"or shape=="bullet"or shape=="axe"then
  local targets={last}
  if shape=="fan"then
   targets=Geometry.sector(first,flat,math.min(radius,50),angle,count-1)
   if id=="elf.common.multi"and type(points)=="table"and #points>0 then targets=points end
  end
  local departure=first
  if shape=="axe"and d.returning and pulse%2==0 then departure=last;targets={first}end
  for i=1,math.min(#targets,7)do
   local target=targets[i]
   if vector(target)then
    local axis=forward(departure,target);local side=axis:Cross(Vector3.yAxis);side=side.Magnitude>.01 and side.Unit or right
    local back=target-axis*math.min(5,(target-departure).Magnitude*.5)
    local w=shape=="bullet"and .12 or row.key=="arrow"and .28 or .45
    Surfaces.triangle(r,"ProjectileSurface",back-side*w,target,back+side*w,nil,.42)
   end
  end
 elseif shape=="lightning"then
  local from=d.form=="ground"and last+Vector3.yAxis*10 or first;local targets=d.form=="chain"and(type(points)=="table"and points or{})or{last}
  for i=1,math.min(#targets,4)do
   if vector(targets[i])then
    local bolt=Geometry.lightning(from,targets[i],6)
    for j=1,#bolt-1 do
     local a,b=bolt[j],bolt[j+1]
     Surfaces.triangle(r,"LightningSurface",a-right*.22,b,a+right*.22,WHITE,.38)
    end
    for side=-1,1,2 do
     local at=from+(targets[i]-from)*.6
     local tip=at+right*side*.9+forward(from,targets[i])*.6
     Surfaces.triangle(r,"LightningBranch",at-Vector3.yAxis*.08,tip,at+Vector3.yAxis*.08,nil,.25)
    end
    from=targets[i]
   end
  end
 elseif shape=="rain"or shape=="hail"or shape=="ash"then
  local at=floorAt(last,character)
  for lane=1,math.min(count,6)do
   local a=lane*2.39996+phase;local target=at+Vector3.new(math.cos(a),0,math.sin(a))*radius*math.sqrt(lane/(count+1))*.85
   Surfaces.volume(r,"FallingShardVolume",target+Vector3.yAxis*(2+lane%3),Vector3.new(.38,1.4,.45),nil,.38,'wedge',shape=="hail"and Enum.Material.Ice or nil)
  end
 elseif shape=="warcry"then
  Surfaces.disc(r,"WarcrySurface",floor,radius*.7,nil,.85)
 elseif shape=="vine"then
  local at=area and floorAt(last,character)or floor
  for lane=1,2 do Surfaces.ribbon(r,"VineSurface",function(t)local a=t*math.pi*1.4+lane*math.pi;return at+Vector3.new(math.cos(a)*radius*.45,t*2.5,math.sin(a)*radius*.45)end,Vector3.yAxis,.65,.35)end
 end
 if row.key=="lightning"then for _,face in ipairs(r.faces)do face.fadeDuration=.16 end end
 if d.form~="chain"or type(points)=="table"and #points>0 then
  local at=area and floorAt(last,character)+Vector3.yAxis*.35 or row.key=="fire"and last or (vector(muzzle)and(muzzle-first).Magnitude>.35 and(muzzle-first).Magnitude<=8 and muzzle or first+dir*1.6)
  flourish(r,at,d.ultimate and 4.5 or area and 3.2 or 2.2,row.key,d.ultimate)
 end
 FX.step(r.at);return r.model
end
function FX.contact(at,classId,id,direction,scale)
 local row=Catalog.get(classId,id);if not row or not vector(at)then return end
 local r=make(at,at,.3,row.key,id);if not r then return end
 local dir=vector(direction)and forward(Vector3.zero,direction)or Vector3.new(0,0,-1)
 local cf=CFrame.lookAt(at,at+dir);local size=math.clamp(scale or 1,.4,2)
 local profile=Profiles.get(id)
 if profile then size*=math.clamp(profile.width/.18,.65,1.6)end
 if row.key=="water"or row.key=="gravity"then
  ring(r,row.key=="water"and"WaterContact"or"GravityContact",at,1.3*size,.12,true,row.key=="gravity",nil,cf)
 else
  for i=1,5 do
   local angle=i*2.39996;local offset=(cf.RightVector*math.cos(angle)+cf.UpVector*math.sin(angle))*size
   line(r,"ContactSplinter",function(u)return at+offset*(.15+u*.7),at+offset*(.4+u*1.5)end,classId=="dwarf"and .12 or .065,i%2==0 and WHITE or r.color)
  end
 end
 if row.key=="frost"or row.key=="earth"or row.key=="fire"or row.key=="bomb"then
  debris(r,at,3,row.key=="frost"and"IceShard"or row.key=="earth"and"RockChip"or"Ember",size)
 end
 local flash=Surfaces.volume(r,"ContactVolume",at,Vector3.one*.65*size,r.hot,.25,"ball")
 if flash then r.faces[#r.faces].fadeDuration=.08 end
 -- Only confirmed hit events reach this entry point. A short open pressure
 -- crown replaces a lingering generic sphere; water retains its own ripple.
 if row.key~="water"and row.key~="gravity"and row.key~="frost"and row.key~="earth"then
  local start=#r.faces
  local basis=CFrame.lookAt(at,at+dir)*CFrame.Angles(math.pi/2,0,0)
  Surfaces.arc(r,"ContactPressure",at,1.35*size,.28*size,r.color,.32,basis,280)
  Surfaces.animate(r,start,at,dir,.35,true,.23)
 end
 flourish(r,at,1.5*size,row.key,false)
 FX.step(r.at);return r.model
end
return FX
