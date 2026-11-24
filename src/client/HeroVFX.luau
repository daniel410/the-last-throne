-- Procedural, client-only embellishment for confirmed combat presentation.
-- Existing geometry retains range information when this optional layer is culled.
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local Catalog=require(RS.Shared.PixelFXCatalog)
local Presentation=require(RS.Shared.SkillPresentation)
local Geometry=require(script.Parent.SkillEffectGeometry)
local Profiles=require(script.Parent.SkillVFXProfiles)
local IconVFX=require(script.Parent.SkillIconVFX)
local Art=require(script.Parent.HeroVFXArt)
local Polish=require(script.Parent.HeroVFXPolish)
local Surfaces=require(script.Parent.HeroVFXSurfaces)
local Style=require(script.Parent.CombatVFXStyle)
local Palette=require(RS.Shared.CombatVFXPalette)
local Windup=require(script.Parent.SkillWindupStrokes)
local FinalBeat=require(script.Parent.SkillFinalBeat)
local Bomb=require(script.Parent.BombVisual)
local FX={}
local active={}
local connection
local beams=0
local chips=0
local glowCount=0
local particleCount=0
local lightCount=0
local WHITE=Color3.fromRGB(248,248,229)
local GLOW_WIDTH=1.8
local palette=Palette.colors
local SHIELD_BREAKER="knight.steel_knight.shield_breaker"
local SHIELD_VERDICT="knight.paladin.shield_verdict"
local ARMOR_SPLITTER="dwarf.iron_axe.armor_splitter"
local function finite(n)return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function vector(v)return typeof(v)=="Vector3" and finite(v.X)and finite(v.Y)and finite(v.Z)and math.abs(v.X)<1e7 and math.abs(v.Y)<1e7 and math.abs(v.Z)<1e7 end
local function erase(i)
 local r=table.remove(active,i);if r.light then lightCount-=1 end;beams-=#r.lines;chips-=#r.chips;glowCount-=#r.glows;particleCount-=r.particles;Surfaces.release(r);r.model:Destroy()
end
local function atmosphere(r,name,at,flame,count,scale)
 if r.compact then return end
 count=math.min(count,(Input.TouchEnabled and 96 or 192)-particleCount);if count<=0 then return end
 local a=Instance.new('Attachment');a.Name=name..'Origin';a.Parent=r.carrier;a.WorldPosition=at
 local e=Instance.new('ParticleEmitter');e.Name=name;e.Texture=flame and'rbxasset://textures/particles/fire_main.dds'or'rbxasset://textures/particles/smoke_main.dds'
 e.Enabled=false;e.Rate=0;e.EmissionDirection=Enum.NormalId.Top;e.SpreadAngle=Vector2.new(22,22)
 e.Lifetime=NumberRange.new(.18,math.min(.32,r.life));e.Speed=NumberRange.new(1.8,3.5);e.Drag=2;e.Acceleration=Vector3.yAxis*(flame and 6 or 2)
 e.Color=flame and ColorSequence.new(Color3.fromRGB(255,171,47),Color3.fromRGB(206,55,22))or ColorSequence.new(Color3.fromRGB(206,230,237))
 e.LightEmission=flame and .7 or .08;e.LightInfluence=flame and 0 or .5
 e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.15*scale),NumberSequenceKeypoint.new(.4,.65*scale),NumberSequenceKeypoint.new(1,scale)})
 e.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,flame and .3 or .68),NumberSequenceKeypoint.new(.5,flame and .55 or .8),NumberSequenceKeypoint.new(1,1)})
 e.Rotation=NumberRange.new(-35,35);e.RotSpeed=NumberRange.new(-35,35);e:SetAttribute('ReviewBurstCount',count);e.Parent=a;e:Emit(count)
 r.particles+=count;particleCount+=count
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
function FX.isOtherHero(character)
 local player=Players.LocalPlayer
 return player~=nil and character~=nil and character~=player.Character
end
local function make(first,last,life,key,id,compact,contact,minBeams)
 if not vector(first)or not vector(last)or not visible(first,last)then return end
 local limit=(Input.TouchEnabled and 8 or 12)-(compact and 2 or 0)
 local beamLimit=(Input.TouchEnabled and 144 or 240)-(minBeams or 0)
 local now=workspace:GetServerTimeNow()
 if #active>=limit or beams>beamLimit then
  for i=#active,1,-1 do
   local r=active[i]
   if not r.model.Parent or now>=r.at+r.life then erase(i) end
  end
  if not contact then
   -- A release or an incoming attack communicates its path once. Reuse
   -- slots from the oldest ally hit accents before dropping that path.
   local i=1
   while i<=#active and (#active>=limit or beams>beamLimit) do
    local r=active[i]
    if r.contact and r.compact then erase(i) else i+=1 end
   end
  end
 end
 if #active>=limit or beams>beamLimit then return end
 local m=Instance.new("Model");m.Name="HeroVFX";m:SetAttribute("SkillId",id or "");m:SetAttribute("Style",key)
 local carrier=Instance.new("Part");carrier.Name="VFXCarrier";carrier.Size=Vector3.one*.05;carrier.Transparency=1
 carrier.Anchored=true;carrier.CanCollide=false;carrier.CanTouch=false;carrier.CanQuery=false;carrier.CastShadow=false
 carrier.Position=first;carrier.Parent=m;m.Parent=workspace;Debris:AddItem(m,life+.2)
 local r={model=m,carrier=carrier,at=now,life=life,lines={},chips={},glows={},flares={},faces={},particles=0,color=palette[key]or palette.steel,key=key,hot=key=="holy"and Color3.fromRGB(255,226,128)or WHITE,compact=compact,contact=contact}
 table.insert(active,r)
 if not connection and Run:IsClient()then connection=Run.RenderStepped:Connect(function()FX.step(workspace:GetServerTimeNow())end)end
 return r
end
local function line(r,name,path,width,color,endWidth,noGlow)
 if beams>=(Input.TouchEnabled and 144 or 240)then return end
 width*=1.15
 endWidth=endWidth and endWidth*1.15 or width*.45
 local a=Instance.new("Attachment");a.Parent=r.carrier
 local b=Instance.new("Attachment");b.Parent=r.carrier
 local beam=Instance.new("Beam");beam.Name=name;beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=1
 local primary=color==WHITE and r.color:Lerp(r.hot,.34)or color or r.color
 beam.Width0=width;beam.Width1=endWidth;beam.Color=ColorSequence.new(primary,r.color:Lerp(r.hot,r.key=='lightning'and .45 or .18))
 beam.LightEmission=.62;beam.LightInfluence=0;beam.Transparency=NumberSequence.new(.18);beam.Parent=r.carrier
 local glow
 if not noGlow and not r.compact and not r.incoming and glowCount<(Input.TouchEnabled and 48 or 96)and #r.glows<24 and width>=.10 then
  glow=beam:Clone();glow.Name="SoftGlow";glow.Width0=width*GLOW_WIDTH;glow.Width1=endWidth*GLOW_WIDTH
  glow.LightEmission=1;glow.Color=ColorSequence.new(r.color);glow.Texture="rbxasset://textures/particles/smoke_main.dds";glow.TextureMode=Enum.TextureMode.Stretch;glow.Transparency=NumberSequence.new(.74);glow.Parent=r.carrier
  table.insert(r.glows,glow);glowCount+=1
 end
 local stroke={a=a,b=b,beam=beam,glow=glow,path=path,width=width,endWidth=endWidth}
 table.insert(r.lines,stroke);beams+=1;return stroke
end
local cuttingStrokes={BladeRibbon=true, DescendingCleave=true, LowSweep=true, SunwardCross=true, OathbladeEdge=true, RadiantOpeningFan=true, IconCounterSlashEdge=true, CrescentCutEdge=true, RallyingSlashEdge=true, SteelSweepEdge=true, CragCleaveEdge=true}
local function curve(r,name,path,count,width,color)
 for i=1,count do
  local from,to=(i-1)/count,i/count
  local stroke=line(r,name,function(u)return path(from,u),path(to,u)end,width*(.4+.6*math.sin(from*math.pi)),color,width*(.4+.6*math.sin(to*math.pi)))
  if stroke then
   if cuttingStrokes[name] then stroke.cutStart=from;stroke.cutEnd=to end
   stroke.span=function(u)return Style.span(path,from,to,u)end
   stroke.beam.Segments=3;if stroke.glow then stroke.glow.Segments=3 end
  end
 end
end
local function ring(r,name,center,radius,width,vertical,inward,color,basis,segments)
 curve(r,name,function(t,u)
  local angle=t*math.pi*2+u*.7;local size=radius*(inward and(1-u*.8)or(.22+.78*(1-(1-u)^3)))
  local offset=vertical and Vector3.new(math.cos(angle)*size,math.sin(angle)*size,0)or Vector3.new(math.cos(angle)*size,0,math.sin(angle)*size)
  return center+(basis and basis:VectorToWorldSpace(offset)or offset)
 end,segments or 12,width,color)
end
local function debris(r,center,count,kind,scale)
 count=r.compact and math.min(count,2) or count
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
 if r.compact then return end
 local a=Instance.new("Attachment");a.Name="FlourishOrigin";a.Parent=r.carrier;a.WorldPosition=position
 local gui=Instance.new("BillboardGui");gui.Name="ImpactFlare";gui.Adornee=a;gui.AlwaysOnTop=false
 gui.LightInfluence=0;gui.MaxDistance=100;gui.Size=UDim2.fromScale(scale,scale);gui.Parent=r.carrier
 local halo=Instance.new("ImageLabel");halo.Name="ElementalFlare";halo.BackgroundTransparency=1;halo.Size=UDim2.fromScale(1,1)
 halo.Image="rbxasset://textures/glow.png";halo.ImageColor3=r.color;halo.ImageTransparency=.25;halo.Parent=gui
 local aura=halo:Clone();aura.Name="SoftFlare";aura.Image="rbxasset://textures/particles/smoke_main.dds";aura.Size=UDim2.fromScale(1.5,1.5);aura.Position=UDim2.fromScale(-.25,-.25);aura.ImageTransparency=.55;aura.ZIndex=1;aura.Parent=gui
 halo.ZIndex=2
 local core=halo:Clone();core.Name="WhiteHotCore";core.Size=UDim2.fromScale(.38,.38);core.Position=UDim2.fromScale(.31,.31);core.ImageColor3=r.hot;core.ZIndex=3;core.Parent=gui
 table.insert(r.flares,{gui=gui,halo=halo,core=core,aura=aura,size=scale})
 -- Bounce the flash off nearby armour and terrain. Only luminous materials
 -- receive a light, and simultaneous party casts share the same small cap.
 local emissive=key=="fire" or key=="bomb" or key=="lightning" or key=="holy" or key=="arcane"
 if emissive and not r.light and lightCount<(Input.TouchEnabled and 1 or 3)then
  local light=Instance.new("PointLight")
  light.Name="ReflectedFlash";light.Shadows=false;light.Color=r.color;light.Range=math.min(13,4+scale*1.6)
  r.lightPeak=strong and 2.4 or 1.25
  light.Brightness=r.lightPeak;light.Parent=a;r.light=light;lightCount+=1
 end
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
  Style.particles(e,key,smoke)
  e:SetAttribute("ReviewBurstCount",count);e.Parent=a;e:Emit(count)
  r.particles+=count;particleCount+=count
 end
 burst("ElementalSparks","rbxasset://textures/particles/sparkles_main.dds",strong and 16 or 8,scale*.13,scale*2.2,false)
 if key=="fire"or key=="bomb"or key=="earth"then
  burst("ElementalPlume",key=="earth"and"rbxasset://textures/particles/smoke_main.dds"or"rbxasset://textures/particles/fire_main.dds",strong and 7 or 4,scale*.65,scale*.8,true)
 end
end
local function edgePressure(t,front)
 local distance=(t-front)/.29
 return .18+1.12*math.exp(-distance*distance)
end
function FX.step(now)
 if not finite(now)then return end
 for i=#active,1,-1 do
  local r=active[i];local u=math.clamp((now-r.at)/r.life,0,1)
  if not r.model.Parent or now>=r.at+r.life or (r.recipientRoot and not r.recipientRoot:IsDescendantOf(workspace))
   or (r.windup and not r.windup()) or (r.incoming and not r.incoming()) then erase(i)
  else
   local fade=r.key=="lightning"and math.clamp((now-r.at)/.16,0,1)or math.clamp((u-.12)/.88,0,1)
   if r.windup then fade=.14+.73*(1-u)^2 end
   if r.incoming then fade=.16*(1-u) end
   local bucket=math.floor(fade*24)
   local changed=r.fadeBucket~=bucket
   if changed then r.fadeBucket=bucket;r.alpha=NumberSequence.new(.18+fade*.82);r.glowAlpha=NumberSequence.new(.74+math.min(1,fade*1.55)^.7*.26)end
   local cutFront=.18+.82*(1-(1-math.min(1,u/.76))^2)
   for _,s in ipairs(r.lines)do
    if s.span then
     local a,b,ta,tb,c0,c1=s.span(u);Style.pose(s.a,s.b,s.beam,a,b,ta,tb,c0,c1)
     if s.glow then s.glow.CurveSize0=c0;s.glow.CurveSize1=c1 end
    else local a,b=s.path(u);s.a.WorldPosition=a;s.b.WorldPosition=b end
    local pressure=1-fade*.7
    local startWidth,endWidth=s.width*pressure,s.endWidth*pressure
    if s.cutStart then
     startWidth*=edgePressure(s.cutStart,cutFront);endWidth*=edgePressure(s.cutEnd,cutFront)
    end
    s.beam.Width0=startWidth;s.beam.Width1=endWidth
    if s.fadeDuration then
     local t=math.clamp((now-r.at)/s.fadeDuration,0,1)
     local step=math.floor(t*24)
     if s.fadeStep~=step then
      s.fadeStep=step
      s.beam.Transparency=NumberSequence.new(.12+.88*(step/24)^1.5)
     end
    elseif changed then s.beam.Transparency=r.alpha end
    if s.glow then
     s.glow.Width0=s.beam.Width0*GLOW_WIDTH;s.glow.Width1=s.beam.Width1*GLOW_WIDTH
     if changed then s.glow.Transparency=r.glowAlpha end
    end
   end
   if r.light then
    local remaining=1-math.clamp((now-r.at)/.18,0,1)
    r.light.Brightness=r.lightPeak*remaining^2
    r.light.Enabled=remaining>0
   end
   Surfaces.step(r,u,fade)
   if r.payload then r.payload(u) end
   for _,s in ipairs(r.flares)do
    local age=now-r.at;local burstFade=math.clamp(age/.14,0,1)
    local coreFade=math.clamp(age/.075,0,1)
    local size=s.size*(.65+math.sin(math.min(u*4,1)*math.pi/2)*.35)
    s.gui.Size=UDim2.fromScale(size,size);s.halo.ImageTransparency=.25+burstFade*.75;s.core.ImageTransparency=coreFade;s.aura.ImageTransparency=.78+math.clamp(age/.20,0,1)*.22
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
-- Each shield opens around the recipient in two strokes. The planar frame
-- is fixed on grant so movement follows the hero without camera-driven spin.
local shieldShapes={
 shield={"SteelGuardClasp",Vector2.new(.20,-.83),Vector2.new(1.75,-.47),Vector2.new(1.42,.62)},
 holy={"OathGuardWings",Vector2.new(.38,-.75),Vector2.new(.96,.48),Vector2.new(1.78,.92)},
 earth={"StoneGuardBraces",Vector2.new(.66,-1.28),Vector2.new(1.65,-.97),Vector2.new(1.30,-.20)},
 arrow={"HunterGuardFletching",Vector2.new(.48,-.52),Vector2.new(1.36,-.45),Vector2.new(1.73,.42)},
 nature={"WardenGuardLeaves",Vector2.new(.59,-.68),Vector2.new(1.65,-.40),Vector2.new(1.07,.79)},
 frost={"IceGuardFacets",Vector2.new(.22,.96),Vector2.new(1.56,.70),Vector2.new(1.47,-.60)},
 fire={"SearingGuardFlames",Vector2.new(.82,-.78),Vector2.new(1.77,-.12),Vector2.new(1.09,.76)},
 arcane={"ArcaneGuardWeave",Vector2.new(.38,-.70),Vector2.new(1.72,.02),Vector2.new(.89,1.04)},
}
function FX.shieldGrant(recipient,id)
 if typeof(recipient)~="Instance" or not recipient:IsA("Model") or not recipient:IsDescendantOf(workspace) then return end
 local root=recipient:FindFirstChild("HumanoidRootPart")
 if not root or not root:IsA("BasePart") then return end
 local color,hot,key,row=Palette.resolve(id:match("^(%a+)"),id)
 if not row or not row.definition.shield then return end
 if row.classId=="dwarf" then key="earth";color,hot=Palette.get(key,row.classId) end
 local shape=shieldShapes[key] or shieldShapes.shield
 local compact=FX.isOtherHero(recipient)
 local at=root.Position
 for i=#active,1,-1 do
  if active[i].recipientRoot==root then erase(i);break end
 end
 local r=make(at,at,compact and .30 or .40,key,id,compact,true,2)
 if not r then return end
 r.model.Name="HeroShieldGrant";r.model:SetAttribute("GuardStyle",shape[1])
 r.recipientRoot=root;r.color=color;r.hot=hot
 local camera=workspace.CurrentCamera
 local sight=camera and camera.CFrame.Position-at or root.CFrame.LookVector
 local flat=Vector3.new(sight.X,0,sight.Z)
 local front=flat.Magnitude>.01 and flat.Unit or -Vector3.zAxis
 local right=front:Cross(Vector3.yAxis)
 local scale=math.clamp(root.Size.Y*.5,.72,1.4)
 for side=-1,1,2 do
  local function path(t,u)
   local start,bend,finish=shape[2],shape[3],shape[4]
   local p=start:Lerp(bend,t):Lerp(bend:Lerp(finish,t),t)
   local open=.76+.40*(1-(1-u)^3)
   return root.Position+(right*(p.X*side*open)+Vector3.yAxis*(p.Y+.20*u)+front*.78)*scale
  end
  local stroke=line(r,shape[1],function(u)return path(0,u),path(1,u)end,compact and .12 or .18,side==1 and hot or color,.085,true)
  if stroke then
   stroke.span=function(u)return Style.span(path,0,1,u)end
   stroke.beam.Segments=5
   local a,b,ta,tb,c0,c1=stroke.span(0)
   Style.pose(stroke.a,stroke.b,stroke.beam,a,b,ta,tb,c0,c1)
  end
 end
 return r.model
end
local function floorAt(at,character)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=character and{character}or{};params.RespectCanCollide=true
 local hit=workspace:Raycast(at+Vector3.yAxis*2,-Vector3.yAxis*18,params)
 return hit and hit.Position+Vector3.yAxis*.12 or at-Vector3.yAxis*2.6
end
-- Lateral spread and lift distinguish the footwork without filling the floor.
local stepWakes={
 ["knight.paladin.valiant_advance"]={name="ValiantBootWake",from=.62,to=.38,arch=.13,width=.16},
 ["dwarf.gunner.blast_step"]={name="BlastRecoilSkid",from=.31,to=.85,arch=.12,width=.20},
 ["elf.marksman.retreating_fire"]={name="RetreatFletchedWake",from=.56,to=.19,arch=.34,width=.095},
 ["mage.pyro.ember_step"]={name="EmberStepWake",from=.72,to=.13,arch=.57,width=.14},
}
function FX.stepWake(character,d,first,last,startedAt)
 local shape=stepWakes[d.id]
 if not shape or not vector(first) or not vector(last) or not finite(startedAt) then return end
 local delta=last-first
 local horizontal=Vector3.new(delta.X,0,delta.Z)
 if horizontal.Magnitude<.25 or horizontal.Magnitude>math.abs(d.move)+.05 or math.abs(delta.Y)>.25 then return end
 local now=workspace:GetServerTimeNow()
 local life=.22
 if now>=startedAt+life or startedAt>now+.1 then return end
 local a,b=floorAt(first,character),floorAt(last,character)
 if math.abs(a.Y-b.Y)>1.8 then return end
 local _,_,key=Palette.resolve(d.id:match("^(%a+)"),d.id)
 local r=make(first,last,startedAt+life-now,key,d.id,FX.isOtherHero(character),true,2)
 if not r then return end
 r.at=startedAt;r.life=life
 r.model.Name="HeroStepWake"
 r.model:SetAttribute("Style",shape.name)
 local right=horizontal.Unit:Cross(Vector3.yAxis)
 for side=-1,1,2 do
  local function path(t,u)
   local progress=.46*u+(1-.46*u)*t
   local spread=shape.from+(shape.to-shape.from)*progress
   local lift=math.sin(progress*math.pi)*shape.arch+.045
   return a:Lerp(b,progress)+right*(side*spread)+Vector3.yAxis*lift
  end
  local stroke=line(r,shape.name,function(u)return path(0,u),path(1,u)end,
   shape.width,side==1 and r.hot or r.color,.045,true)
  if stroke then
   stroke.span=function(u)return Style.span(path,0,1,u)end
   stroke.beam.Segments=4
  end
 end
 FX.step(now)
 return r.model
end
local function forward(first,last)
 local d=last-first;return d.Magnitude>.01 and d.Unit or Vector3.new(0,0,-1)
end
function FX.endWindup(character,seq)
 for i=#active,1,-1 do
  local r=active[i]
  if r.windup and r.character==character and r.seq<=seq then erase(i) end
 end
end
function FX.windup(character,d,motion,effect,origin,seq,startedAt,socket)
 if not character or not finite(seq) or not finite(startedAt) then return end
 local now=workspace:GetServerTimeNow()
 local duration=d.windup+(d.hitDelay or 0)
 local remaining=startedAt+duration-now
 if remaining<.045 or startedAt>now+.1 then return end
 local compact=FX.isOtherHero(character)
 local pending=0
 for _,r in ipairs(active) do if r.windup then pending+=1 end end
 if pending>=(Input.TouchEnabled and 2 or 3)-(compact and 1 or 0) then return end
 local root=character:FindFirstChild("HumanoidRootPart")
 if not root or not root:IsA("BasePart") then return end
 local color,hot,key,row=Palette.resolve(d.id:match("^(%a+)"),d.id)
 if not row then return end
 local style,count=Windup.style(row.classId,d,motion,effect)
 local consumed=false
 local function refresh()
  if not character.Parent or not root.Parent or character:GetAttribute("TLTDeathFalling") then return false end
  local current=character:GetAttribute("K0AttackSeq")
  if type(current)=="number" and current>seq then return false end
  local matches=current==seq and character:GetAttribute("K0SkillId")==d.id and character:GetAttribute("K0State")=="Attack"
  if consumed and not matches then return false end
  consumed=consumed or matches
  local anchor=socket and socket.Parent and (socket:IsA("Attachment") and socket.WorldPosition or socket.Position)
  return true,root.CFrame.Rotation+ (anchor or root.CFrame:PointToWorldSpace(Vector3.new(.65,.45,-1)))
 end
 local alive,frame=refresh()
 if not alive then return end
 local r=make(origin,origin,remaining,key,d.id,compact,false,count)
 if not r then return end
 r.at=startedAt;r.life=duration;r.color=color;r.hot=hot
 r.model.Name="HeroSkillWindup"
 r.character=character;r.seq=seq
 r.windup=function()
  local ok,currentFrame=refresh()
  frame=currentFrame
  return ok
 end
 r.model:SetAttribute("Style",style)
 local scale=d.ultimate and 1.4 or d.windup>=.55 and 1.15 or .88
 for i=1,count do
  line(r,style,function(u)
   local a,b=Windup.stroke(style,i,u,scale)
   return frame:PointToWorldSpace(a),frame:PointToWorldSpace(b)
  end,.073,i%2==0 and hot or color,.035)
 end
 FX.step(now)
 return r.model
end
local function tongue(r,name,at,height,width,heading,color)
 local radial=Vector3.new(math.cos(heading),0,math.sin(heading));local normal=Vector3.new(-radial.Z,0,radial.X)
 local start=#r.faces
 Surfaces.ribbon(r,name,function(t)
  return at+Vector3.yAxis*(height*t)+radial*(math.sin(t*math.pi)*width*.35+t*t*.25)
 end,normal,width,.48,color or palette.fire,4)
 Surfaces.animate(r,start,at,Vector3.yAxis,.35,false,r.life*.85)
end
local function shell(r,at,strong)
 local height=strong and 10 or 8
 local size=strong and Vector3.new(1.05,2.35,1.05)or Vector3.new(.54,1.38,.54)
 local p=Surfaces.volume(r,'MortarShellBody',at+Vector3.yAxis*size.Y*.5,size,strong and Color3.fromRGB(144,151,157)or Color3.fromRGB(74,83,94),.08,'ball',Enum.Material.Metal)
 if p then r.faces[#r.faces].fall={height=height,duration=r.life,delay=0,landing=true}end
 local nose=Surfaces.volume(r,'MortarShellNose',at+Vector3.yAxis*.12,strong and Vector3.new(.82,.55,.82)or Vector3.new(.42,.30,.42),palette.bomb,.18,'wedge')
 if nose then r.faces[#r.faces].fall={height=height,duration=r.life,delay=0,landing=true}end
 line(r,'MortarShortWake',function(u)
  local y=height*(1-u*u)
  return at+Vector3.yAxis*(y+size.Y+.56),at+Vector3.yAxis*(y+size.Y-.08)
 end,strong and .16 or .09,palette.bomb)
end
local groundLead={mortar=.24,rain=.21,hail=.19,ash=.25}
local rainNames={rain="ArrowRain",hail="HailDescent",ash="AshDescent"}

local function siegeCount(compact)
 return compact and 1 or Input.TouchEnabled and 2 or 3
end
local function siegeTarget(center,radius,pulse,lane,count)
 local angle=(lane-1)*2.39996+(pulse-1)*1.3
 local spread=count>1 and math.min(radius*.17,2.2) or 0
 return center+Vector3.new(math.cos(angle)*spread,0,math.sin(angle)*spread)
end

function FX.groundLead(d)
 local profile=Profiles.get(d.id)
 return d.form=="ground" and profile and groundLead[profile.shape] or nil
end

function FX.endIncoming(character,seq,pulse)
 for i=#active,1,-1 do
  local r=active[i]
  if r.incoming and r.character==character and (r.seq<seq or r.seq==seq and r.pulse<=pulse) then erase(i) end
 end
end

local function makeIncoming(character,d,first,center,seq,pulse,landingAt,valid,lead)
 local now=workspace:GetServerTimeNow()
 if not lead or landingAt-now<.025 or not valid() or not vector(center) then return end
 local row=Catalog.byId[d.id]
 local compact=FX.isOtherHero(character)
 local pending=0
 for _,effect in ipairs(active) do if effect.incoming then pending+=1 end end
 if pending>=(compact and 2 or 3) then return end
 local r=make(first,center,landingAt-now,row.key,d.id,compact,false,2)
 if not r then return end
 r.at=landingAt-lead;r.life=lead;r.incoming=valid
 r.character=character;r.seq=seq;r.pulse=pulse
 r.color,r.hot=Palette.get(row.key,row.classId)
 r.model.Name="HeroSkillIncoming"
 r.model:SetAttribute("Pulse",pulse)
 return r,now
end

function FX.bombFlight(character,d,profile,launch,target,seq,pulse,landingAt,valid)
 local now=workspace:GetServerTimeNow()
 local lead=math.min(profile.flight,landingAt-now)
 local r=makeIncoming(character,d,launch.Position,target,seq,pulse,landingAt,valid,lead)
 if not r then return end
 local model=Instance.new("Model")
 model.Name="ThrownBomb"
 Bomb.mount(model,launch)
 model.Parent=r.model
 local landing=Bomb.floor(target,character)+Vector3.yAxis*Bomb.radius
 local groundPoint
 if profile.path=="bounce" or profile.path=="roll" then
  local progress=profile.path=="bounce" and .56 or .18
  groundPoint=Bomb.floor(launch.Position:Lerp(target,progress),character)+Vector3.yAxis*Bomb.radius
 end
 r.payload=function(u)
  model:PivotTo(Bomb.flightFrame(profile.path,launch,landing,groundPoint,u))
 end
 r.model:SetAttribute("PayloadPath",profile.path)
 FX.step(now)
 return r.model
end

function FX.incoming(character,d,center,seq,pulse,landingAt,valid)
 local lead=FX.groundLead(d)
 local r,now=makeIncoming(character,d,center,center,seq,pulse,landingAt,valid,lead)
 if not r then return end
 local profile=Profiles.get(d.id)
 local shape=profile.shape
 local siege=profile.signature=="SiegeShells"
 local spirit=profile.signature=="SpiritCanopy"
 local count=shape=="mortar" and (siege and siegeCount(r.compact) or 1)
  or math.min(profile.lanes,(r.compact or Input.TouchEnabled) and 3 or 5)
 for lane=1,count do
  local angle=(lane-1)*2.39996+(pulse-1)*1.3
  local rad=d.radius*math.sqrt(lane/(count+1))*.78
  local target=shape=="mortar" and (siege and siegeTarget(center,d.radius,pulse,lane,count) or center)
   or center+Vector3.new(math.cos(angle)*rad,0,math.sin(angle)*rad)
  local at=floorAt(target,character)
  if shape=="mortar" then
   shell(r,at,siege)
  else
   local size=shape=="rain" and Vector3.new(.16,spirit and 2.8 or 1.65,.22)
    or shape=="hail" and Vector3.new(.48,1.45,.55) or Vector3.new(.31,.95,.36)
   local height=shape=="hail" and 9 or shape=="ash" and 6 or 8
   local tip=at+Vector3.yAxis*size.Y*.5
   local shard=Surfaces.volume(r,spirit and "SpiritCanopyLeaf" or "FallingShardVolume",tip,
    size,nil,.14,"wedge",shape=="hail" and Enum.Material.Ice or nil)
   if shard then
    local face=r.faces[#r.faces]
    face.cf=CFrame.new(tip)*CFrame.Angles(math.pi,0,.12)
    face.fall={height=height,duration=lead,delay=0,landing=true}
   end
   line(r,rainNames[shape],function(u)
    local head=tip+Vector3.yAxis*height*(1-u*u)
    return head+Vector3.yAxis*size.Y*.5,head-Vector3.yAxis*size.Y*.5
   end,profile.width*.75)
  end
 end
 FX.step(now)
 return r.model
end
local function rootBranch(r,first,last,width,delay)
 local p=Surfaces.bar(r,'GroundRootBody',first,last,width,Color3.fromRGB(130,163,96),.08,Enum.Material.Wood)
 if p then Surfaces.growLine(r,first,last,math.min(.14,r.life*.3),delay)end
 line(r,'RootingVine',function(u)
  local growth=math.clamp((u*r.life-delay)/math.min(.14,r.life*.3),0,1)
  return first,first+(last-first)*math.max(.01,growth)
 end,width*.65,palette.nature:Lerp(r.hot,.22))
end
local function roots(r,at,flat,right,radius,angle,count,burst)
 for lane=1,math.min(count,5)do
  local a=angle<359 and math.rad(-angle/2+angle*(lane-.5)/count)or lane/count*math.pi*2
  local radial=flat*math.cos(a)+right*math.sin(a)
  local from=at+radial*math.min(radius*.1,.6)+Vector3.yAxis*.12
  local bend=at+radial*radius*.38+right*math.sin(lane*2.4)*.18+Vector3.yAxis*.3
  local tip=at+radial*radius*(burst and .8 or .7)+Vector3.yAxis*.4
  rootBranch(r,from,bend,.38,0);rootBranch(r,bend,tip,.28,.025)
  local side=Vector3.new(-radial.Z,0,radial.X)*(lane%2==0 and -1 or 1)
  local fork=bend+radial*radius*.13+side*math.min(radius*.18,1.2)
  rootBranch(r,bend,fork,.22,.045)
  local upTip=tip+radial*.2+Vector3.yAxis*(burst and (1.55+lane%2*.55) or (.7+lane%2*.25))
  local stem=Surfaces.bar(r,'RootAscendingTip',tip,upTip,.24,palette.nature:Lerp(r.hot,.28),.2,Enum.Material.Neon)
  if stem then Surfaces.growLine(r,tip,upTip,.12,burst and .075 or .02)end
  for n=1,2 do
   local pos=bend+(tip-bend)*(n*.25)
   local thorn=Surfaces.volume(r,'RootThorn',pos+Vector3.yAxis*.35,Vector3.new(.24,.85,.25),palette.nature:Lerp(r.hot,.2),.2,'wedge',Enum.Material.SmoothPlastic)
   if thorn then r.faces[#r.faces].emerge={duration=.12,delay=.02+n*.012}end
  end
 end
end
local function signature(r,key,c)
 local first,floor,flat,right,radius,angle=c.first,c.floor,c.flat,c.right,c.radius,c.angle
 local emphasis=c.final and not r.compact
 local compact=r.compact
 r.model:SetAttribute('UltimateSignature',key)
 if compact then r.model:SetAttribute('PrimaryIconCue',true) end
 local function stroke(name,a,b,width,color,drift)
  line(r,name,function(u)
   local offset=drift and drift*u or Vector3.zero
   return a+offset,b+offset
  end,width or .14,color)
 end
 if key=='FrontWall'then
  local wings=compact and 0 or 1
  local drift=flat*(c.final and 2.8 or .35)
  local firstFace=#r.faces+1
  for lane=-wings,wings do
   local at=first+flat*2.2+right*lane*2.35
   local points={at-right*.8+Vector3.yAxis*1.6,at+right*.8+Vector3.yAxis*1.6,at+right*.65-Vector3.yAxis*.6,at-Vector3.yAxis*1.3,at-right*.65-Vector3.yAxis*.6}
   for i=2,#points-1 do
    Surfaces.triangle(r,'UltimateFrontPanel',points[1],points[i],points[i+1],nil,.56,Enum.Material.SmoothPlastic)
   end
   stroke('FrontWallCrest',points[1],points[2],.13,nil,drift)
   for side=-1,1,2 do
    stroke('FrontWallChevron',at+right*side*.55,at+Vector3.yAxis*.8,.12,nil,drift)
   end
  end
  for i=firstFace,#r.faces do r.faces[i].drift=drift end
 elseif key=='DawnAegis'then
  local focus=first+flat*2.4
  local wings=compact and 0 or 1
  for lane=-wings,wings do
   local size=lane==0 and 1.15 or .7
   local at=focus+right*lane*2.1
   local pts={at+Vector3.yAxis*size,at+right*size*.75+Vector3.yAxis*size*.5,at+right*size*.55-Vector3.yAxis*size*.4,at-Vector3.yAxis*size,at-right*size*.55-Vector3.yAxis*size*.4,at-right*size*.75+Vector3.yAxis*size*.5}
   for i=1,#pts do
    stroke('IconDawnAegis',pts[i],pts[i%#pts+1],.1)
   end
   Surfaces.triangle(r,'DawnAegisPanel',pts[1],pts[2],pts[4],r.color,.52,Enum.Material.SmoothPlastic)
   Surfaces.triangle(r,'DawnAegisPanel',pts[1],pts[4],pts[6],r.color,.52,Enum.Material.SmoothPlastic)
  end
  local crest=focus+Vector3.yAxis*1.4
  local rays=compact and 3 or 6
  local rise=Vector3.yAxis*(c.final and 4.8 or .4)
  for i=1,rays do
   local a=(i-1)/(rays-1)*2-1;local axis=right*math.sin(a)+Vector3.yAxis*math.cos(a)
   stroke('IconDawnCrest',crest+axis*.2,crest+axis*(c.final and 1.65 or 1.3),.12,r.hot,rise)
   if emphasis then
    Surfaces.volume(r,'DawnAscendingLight',crest+axis*.8,Vector3.new(.12,.8,.12),nil,.62,'ball',nil,false,4.8)
   end
  end
 elseif key=='MountainRidge'then
  local ridges=compact and 3 or 5
  for i=1,ridges do
   local a=math.rad(-angle*.42+angle*.84*(i-.5)/ridges);local radial=flat*math.cos(a)+right*math.sin(a)
   local at=floor+radial*radius*(.38+(i%2)*.22);local height=(emphasis and 2.7 or 1.8)+(i%3)*.65
   local p=Surfaces.volume(r,'UltimateMountainRidge',at+Vector3.yAxis*height*.5,Vector3.new(1.4,height,1.6),palette.earth,.18,'wedge',Enum.Material.Slate)
   if p then local face=r.faces[#r.faces];face.cf=CFrame.lookAt(p.Position,p.Position+radial)*CFrame.Angles(.22,0,0);face.emerge={duration=.2,delay=(i%2)*.035}end
   curve(r,'UltimateGroundFracture',function(t,u)
    local reach=emphasis and math.min(1,.48+u*2.7) or .68
    return floor+radial*radius*.85*t*reach+right*(math.sin(t*9+i)*.18)+Vector3.yAxis*.04
   end,compact and 2 or 3,emphasis and .22 or .14,palette.earth)
  end
  local focus=floor+flat*radius*.45
  local height=emphasis and 5.2 or 3.6
  local ridge=Surfaces.volume(r,'MountainRidgeFocus',focus+Vector3.yAxis*height*.5,Vector3.new(2.6,height,2.5),Color3.fromRGB(158,126,82),.08,'wedge',Enum.Material.Slate)
  if ridge then r.faces[#r.faces].emerge={duration=.16,delay=0}end
  debris(r,floor+flat*radius*.35,5,'RockChip',1.8)
 elseif key=='SiegeShells'then
  local count=siegeCount(r.compact)
  for lane=1,count do
   local at=floorAt(siegeTarget(c.last,radius,c.pulse,lane,count),c.character)
   local sparks=compact and 2 or 3
   for n=1,sparks do
    local angle=n*math.pi*2/sparks
    local radial=Vector3.new(math.cos(angle),0,math.sin(angle))
    line(r,'SiegeLandingSpark',function(u)
     local spread=emphasis and u*1.7 or u*.65
     return at+radial*(.2+spread)+Vector3.yAxis*.1,
      at+radial*(.7+spread)+Vector3.yAxis*(emphasis and (.45-u*.32) or .16)
    end,emphasis and .11 or .07,palette.bomb)
   end
  end
 elseif key=='VolleyCrown'then
  local launch=c.muzzle or first
  for lane,target in ipairs(Geometry.sector(first,flat,radius,angle,compact and 2 or emphasis and 6 or 4))do
   local axis=forward(launch,target);local side=axis:Cross(Vector3.yAxis);side=side.Magnitude>.01 and side.Unit or right
   stroke('UltimateArrowWake',launch,target,.12)
   if not compact then
    for sign=-1,1,2 do stroke('UltimateArrowCrest',target-axis*2+side*sign*.4,target,.18,r.hot)end
    if lane%2==0 then Surfaces.triangle(r,'UltimateArrowHead',target-axis*3-side*.45,target,target-axis*3+side*.45,nil,.3,Enum.Material.SmoothPlastic)end
   end
  end
  -- A bow-shaped crown close to the caster stays readable when the long fan
  -- occupies most of the frame. It replaces the small, distant decorative arc.
  local crown=first+flat*math.min(radius*.13,5)
  local span=math.min(radius*.16,emphasis and 6 or 3.8)
  local function crownPath(t)
   return crown+right*((t-.5)*span*2)+flat*(math.sin(t*math.pi)*1.3)
    +Vector3.yAxis*(.5+math.sin(t*math.pi)*(emphasis and 5.6 or 2.2))
  end
  curve(r,'VolleyDrawCrown',crownPath,compact and 3 or 6,emphasis and .26 or .16)
  if not compact then Surfaces.ribbon(r,'VolleyCrownLimb',crownPath,flat,emphasis and .6 or .38,.34,r.color,6,Enum.Material.SmoothPlastic) end
 elseif key=='SpiritCanopy'then
  local height=emphasis and 1 or .62
  for i=1,3 do local a=i*math.pi*2/3;local radial=Vector3.new(math.cos(a),0,math.sin(a))
   local function path(t)return floor+Vector3.yAxis*(3.4+math.sin(t*math.pi*.8)*3.8)*height+radial*radius*.48*t end
   curve(r,'SpiritCanopyBranch',path,compact and 3 or 5,.26,palette.nature:Lerp(r.hot,.25))
   if not compact then
    for n=1,3 do Surfaces.bar(r,'SpiritCanopyBough',path((n-1)/3),path(n/3),.38,palette.nature:Lerp(r.hot,.3),.2,Enum.Material.SmoothPlastic)end
   end
   local tip=path(.8);local tangent=Vector3.new(-radial.Z,0,radial.X)
   local mid=tip+radial*1.2-Vector3.yAxis*.6*height;local endLeaf=tip+radial*2.7-Vector3.yAxis*1.8*height
   Surfaces.triangle(r,'SpiritCanopyCrownLeaf',tip,mid+tangent*1.1,endLeaf,palette.nature,.36,Enum.Material.SmoothPlastic)
   if not compact then
    Surfaces.triangle(r,'SpiritCanopyCrownLeaf',tip,endLeaf,mid-tangent*1.1,palette.nature:Lerp(r.hot,.2),.4,Enum.Material.SmoothPlastic)
    Surfaces.bar(r,'SpiritCanopyLeafVein',tip,endLeaf,.075,palette.nature:Lerp(r.hot,.35),.25,Enum.Material.Neon)
   end
  end
 elseif key=='CalderaVents'then
  Surfaces.volume(r,'CalderaCentralVent',floor+Vector3.yAxis*.15,Vector3.new(2.8,.6,2.6),Color3.fromRGB(68,43,29),.12,'wedge',Enum.Material.Slate)
  local spine=c.final and 8.5 or 4
  curve(r,'CalderaMagmaSpine',function(t,u)
   return floor+Vector3.yAxis*(.2+t*(spine+u*2))+right*math.sin(t*5+u*3)*.35
  end,3,c.final and .65 or .38,palette.fire)
  if emphasis then
   Surfaces.plume(r,'CalderaCentralPlume',floor+Vector3.yAxis*4.6,6,10,Color3.fromRGB(255,163,61),'rbxassetid://125374985892345',.18)
  end
  local vents=compact and 2 or 3
  for i=1,vents do
   local a=i*math.pi*2/vents+(c.pulse-1)*.45
   local at=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*.22
   if not compact then
    tongue(r,'CalderaEruptionTongue',at,8.2+(i%2)*1.8,1.9,a,palette.fire)
    if emphasis then atmosphere(r,'CalderaFire',at,true,4,2) end
    Surfaces.plume(r,'CalderaVentPlume',at+Vector3.yAxis*(1.8+i*.45),3.2+i*.4,5+i*.8,Color3.fromRGB(255,145,40),'rbxassetid://125374985892345',.26)
   end
   curve(r,'CalderaLivingJet',function(t,u)
    local height=(compact and 3.5 or 5.5)+u*2;local drift=Vector3.new(math.cos(a+t*4),0,math.sin(a+t*4))
    return at+Vector3.yAxis*(t*height+.3)+drift*math.sin(t*math.pi)*1.25
   end,compact and 2 or 3,compact and .4 or .8,palette.fire)
  end
  local cracks=compact and 3 or 5
  for i=1,cracks do local a=i*math.pi*2/cracks;local radial=Vector3.new(math.cos(a),0,math.sin(a))
   curve(r,'CalderaHotFissure',function(t)return floor+radial*radius*.78*t+right*math.sin(t*9+i)*.2+Vector3.yAxis*.05 end,compact and 1 or 3,.16,palette.fire)
   Surfaces.volume(r,'CalderaRockCollar',floor+radial*radius*.3+Vector3.yAxis*.4,Vector3.new(2.3,1.1,1.8),Color3.fromRGB(70,51,41),.16,'wedge',Enum.Material.Slate)
  end
 elseif key=='FrostFunnel'then
  for layer=1,compact and 0 or 2 do
   Surfaces.plume(r,'TempestVaporLayer',floor+Vector3.yAxis*(layer*2.1),2.4+layer*1.7,3.6,palette.frost,'rbxasset://textures/particles/smoke_main.dds',.62)
  end
  local lanes=compact and 2 or 3
  for lane=1,lanes do
   curve(r,'TempestSpiral',function(t,u)
    local angle=t*math.pi*1.65+lane*math.pi*2/lanes+u*(c.final and 4.4 or 2.8)
    local collapse=c.final and 1-.65*math.min(1,u*2.8) or 1
    local rad=math.min(radius*.31,5.8)*(.14+.86*t^1.3)*collapse
    local lean=right*(t*t*1.25*collapse)
    return floor+lean+Vector3.new(math.cos(angle)*rad,.35+t*((compact and 5.2 or 8.1)+lane*.48),math.sin(angle)*rad)
   end,compact and 4 or 7,compact and .12 or .26,palette.frost:Lerp(r.hot,.12))
  end
  for layer=1,compact and 0 or 2 do
   local start=#r.faces
   Surfaces.ribbon(r,'TempestEyeBand',function(t)
    local a=t*math.pi*1.7+layer*.9
    local rad=math.min(radius*.32,6)*(1-layer*.1)
    return floor+Vector3.new(math.cos(a)*rad,layer*2+math.sin(t*math.pi)*.7,math.sin(a)*rad)
   end,Vector3.yAxis,.55,.58,palette.frost,4,Enum.Material.SmoothPlastic)
   Surfaces.animate(r,start,floor,Vector3.yAxis,1.5,false,r.life)
  end
  local crystals=compact and 3 or 6
  for i=1,crystals do local a=i*math.pi*2/crystals;local radial=Vector3.new(math.cos(a),0,math.sin(a))
   local p=Surfaces.volume(r,'TempestSuspendedCrystal',floor+radial*radius*.28+Vector3.yAxis*(1.8+i%3*.8),Vector3.new(.55,2,.6),palette.frost:Lerp(r.hot,.25),.2,'wedge',Enum.Material.Ice)
   if p then r.faces[#r.faces].drift=radial*(c.final and -radius*.2 or .5)+Vector3.yAxis*.7 end
  end
  for i=1,3 do local a=i*math.pi*2/3;local at=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*.5
   local p=Surfaces.volume(r,'FrostRimFacet',at+Vector3.yAxis*.6,Vector3.new(.45,1.2,.5),palette.frost,.35,'wedge',Enum.Material.Ice)
   if p then r.faces[#r.faces].emerge={duration=.18,delay=0}end
  end
  debris(r,floor,5,'IceShard',1.5)
 end
end
local function drawFan(r,d,profile,first,flat,muzzle,endpoints)
 local lanes=profile.fanLanes
 if type(endpoints)~="table" then endpoints=Geometry.sector(first,flat,d.range,d.angle,lanes-1) end
 local pellet=r.key=="gun"
 local narrow=d.id=="elf.marksman.piercing_volley"
 local name=pellet and "ScatterPelletTrace" or narrow and "PiercingVolleyShaft" or "FanBreakShaft"
 local hold=pellet and .045 or .060
 local traceColor=pellet and r.color:Lerp(r.hot,.25) or r.color
 for i=1,lanes do
  local target=endpoints[i]
  if vector(target) and (target-first).Magnitude>.15 and (target-first).Magnitude<=d.range+.01 then
   local start=Geometry.fanLaunch(first,muzzle,target)
   local delta=target-start
   if delta.Magnitude>.1 then
    local tip=target
    local width=pellet and .135 or narrow and .075 or .09
    line(r,name,function(u)
     local falloff=math.clamp((u*r.life-hold)/(r.life-hold),0,1)
     return start+delta*(1-(1-falloff)^(pellet and 3.8 or 2.4)),tip
    end,width,traceColor,pellet and .04 or width*.8,true)
    if pellet and not r.compact then
     Surfaces.bar(r,"ShotPelletBody",tip-delta.Unit*math.min(.5,delta.Magnitude*.5),tip,
      .1,Color3.fromRGB(200,207,214),.15,Enum.Material.Metal)
    elseif not pellet then
     local axis=delta.Unit
     local cross=axis:Cross(Vector3.yAxis)
     local lateral=cross.Magnitude>.001 and cross.Unit or Vector3.xAxis
     local length=math.min(delta.Magnitude*.5,narrow and 1.25 or .74)
     for side=-1,1,2 do
      line(r,"VolleyArrowhead",function(u)
       local tail=tip-axis*(length*(1-.35*u))+lateral*(side*length*(narrow and .15 or .32))
       return tail,tip
      end,narrow and .085 or .10,r.hot,.038,true)
     end
    end
   end
  end
 end
 r.model:SetAttribute("FanRelease",true)
 r.model:SetAttribute("PrimaryIconCue",true)
end
-- Every authored skill resolves through the same stable server skill catalog.
function FX.skill(character,id,first,last,pulse,points,muzzle,castDirection,fanEndpoints)
 local row=Catalog.byId[id];local profile=Profiles.get(id)
 if not row or not profile or not vector(first)or not vector(last)or not finite(pulse)or pulse<1 then return end
 local d=row.definition
 local bomb=Bomb.get(id)
 -- The dedicated Wind Lance renderer owns its release; no empty duplicate model.
 if profile.shape=="wind"then return end
 local fanProfile=Presentation.get(d)
 local fanLanes=fanProfile.fanLanes
 local rallyingSlash=id=="knight.steel_knight.rallying_slash"
 local cyclone=id=="knight.steel_knight.twin_cyclone"
 local returningEcho=id=="dwarf.iron_axe.returning_echo"
 local cinderRing=id=="mage.pyro.cinder_ring"
 local steelSweep=id=="knight.steel_knight.steel_sweep"
 local cragCleave=id=="dwarf.iron_axe.crag_cleave"
 local vineBurst=id=="elf.magic_archer.vine_burst"
 local lavaEruption=id=="mage.pyro.lava_eruption"
 local compact=FX.isOtherHero(character)
 local final=FinalBeat.isFinal(d,pulse)
 local life=profile.signature and not final and math.min(profile.life,d.interval) or profile.life
 local minBeams=fanLanes and fanLanes*(row.key=="gun" and 1 or 3)
  or (cyclone or cinderRing) and (compact and 8 or 12)
  or (steelSweep or cragCleave) and (compact and 6 or 9)
  or vineBurst and (compact and 9 or 12)
  or lavaEruption and (compact and 2 or 3)
  or returningEcho and (compact and 5 or 7) or 2
 if returningEcho and pulse==2 and character then
  -- The same axe comes back even when both release events arrive together.
  for i=#active,1,-1 do
   local previous=active[i]
   if previous.outgoingEcho==character then erase(i) end
  end
 end
 local r=make(first,last,life,row.key,id,compact,false,minBeams);if not r then return end
 if returningEcho and pulse==1 then r.outgoingEcho=character end
 r.color,r.hot=Palette.get(row.key,row.classId)
 r.model:SetAttribute("Silhouette",profile.shape);r.model:SetAttribute("Pulse",pulse)
 local dir=forward(first,last)
 if(first-last).Magnitude<.01 then
  local root=character and character:FindFirstChild("HumanoidRootPart")
  dir=root and root.CFrame.LookVector or Vector3.new(0,0,-1)
 end
 if (d.form=="cone" or d.form=="melee" or cyclone) and vector(castDirection) and castDirection.Magnitude>.01 then
  dir=castDirection.Unit
 end
 local flat=Vector3.new(dir.X,0,dir.Z);flat=flat.Magnitude>.01 and flat.Unit or Vector3.new(0,0,-1)
 local right=Vector3.new(-flat.Z,0,flat.X)
 local area=d.form=="ground"or d.form=="area"or d.detonate or d.areaRadius~=nil
 -- For originArea, the server's center is the departure point, not current origin.
 local center=area and last or first
 local floor=bomb and Bomb.floor(center,character) or floorAt(center,character)
 local radius=d.areaRadius or((d.form=="ground"or d.detonate)and d.radius)or d.range or 5
 local angle=d.form=="area"and 360 or d.angle or 80
 local width,count,shape=profile.width,profile.lanes,profile.shape
 local emphasis=final and not r.compact
 local thrustBase,thrustTip=first,last
 if shape=="thrust" and vector(muzzle) and (muzzle-first).Magnitude<=6 then
  local reach=(last-first).Magnitude
  local projection=(muzzle-first):Dot(dir)
  if projection>0 and projection<reach-.2 then
   local height=math.clamp(muzzle.Y-first.Y,-.8,1)
   thrustBase=muzzle
   thrustTip=last+Vector3.yAxis*height
  end
 end
 local shieldStrike=id==SHIELD_BREAKER or id==SHIELD_VERDICT
 local verdict=id==SHIELD_VERDICT
 local shieldCharge=id=="knight.steel_knight.breaker_charge"
 local frostStep=id=="mage.cryo.frost_step"
 local phase=(pulse-1)*1.3
 local electricLinks={}
 local counterSlash=id=="knight.steel_knight.counter_slash"
 local crossfire=id=="elf.marksman.crossfire"
 local oathblade=id=="knight.paladin.oathblade"
 local quickfire=id=="dwarf.gunner.quickfire"
 local echoArrows=id=="elf.magic_archer.echo_arrows"
 local crosscutReturn=shape=="axe" and d.crosscut and pulse%2==0
 local spinStyle=cyclone and 'CrossingCyclones'
  or id=='knight.steel_knight.blade_storm'and 'BrokenBladeStorm' or 'WaistWhirlwind'
 local cycloneBank=pulse==2 and -1 or 1
 local spinLanes=spinStyle=='BrokenBladeStorm' and count or 1
 local spinBank=cyclone and CFrame.fromAxisAngle(flat,cycloneBank*.40) or CFrame.identity
 local function spinPath(lane,t,u)
  local storm=spinStyle=='BrokenBladeStorm'
  local finalSweep=storm and emphasis
  local sign=cyclone and cycloneBank or 1
  local turn=u and (1-(1-u)^3-.5)*sign*2.4 or 0
  local a=t*math.rad(finalSweep and 116 or storm and 78 or cyclone and 266 or 246)+phase+(lane-1)*math.pi*2/spinLanes+turn
  local offset=(flat*math.cos(a)+right*math.sin(a))*math.min(radius,8)*(finalSweep and .91 or storm and .78 or .8)
  if cyclone then offset=spinBank:VectorToWorldSpace(offset) end
  return first+offset+Vector3.yAxis*(finalSweep and (-.65+(lane-2)*.14) or storm and (lane-2)*.3 or 0)
 end
 local function stroke(name,a,b,w,color)line(r,name,function()return a,b end,w or width,color)end
 local function sector(name,at,rad,arc,lane,low)
  curve(r,name,function(t,u)
   local a=math.rad(-arc/2+arc*t)+(arc>=359 and phase+u*.8 or (1-(1-u)^3-.5)*.6)
   local v=flat*math.cos(a)+right*math.sin(a)
   return at+v*rad+Vector3.yAxis*(low and .12 or math.sin(t*math.pi)*.35+(lane-1)*.22)
  end,12,width*(1-(lane-1)*.12))
 end
 local function crossPath(t)
  local side=pulse%2==0 and -1 or 1
  local arc=math.rad(angle*.46)*(2*t-1)
  -- Oathblade returns across the body; the two cuts travel in opposite directions.
  if oathblade then arc*=side end
  local offset=(flat*math.cos(arc)+right*math.sin(arc))*math.min(radius,6)*(.65+.18*math.sin(t*math.pi)+(oathblade and pulse==2 and .09 or 0))
  local height=oathblade and (pulse==1 and .9-1.6*t or -.3+.9*t) or (.85-1.65*t)*side
  return first+offset+Vector3.yAxis*height
 end
 local function counterPath(t)
  local arc=math.rad(angle*.58)*(2*t-1)
  local reach=math.min(radius,6)*(.79+.15*math.sin(t*math.pi))
  return first+(flat*math.cos(arc)+right*math.sin(arc))*reach+Vector3.yAxis*(-.8+2.15*t)
 end
 local function steelSweepPath(t,u)
  local bearing=math.rad(angle)*(.46-.92*t)
  local reach=radius*(.73+.15*math.sin(t*math.pi)+.09*u)
  return first+(flat*math.cos(bearing)+right*math.sin(bearing))*reach+Vector3.yAxis*(.05-.46*t)
 end
 local function cleavePath(t)
  local a=t*math.pi*.8
  if id==ARMOR_SPLITTER then
   -- A full overhead-to-low stroke gives the narrow edge room to read.
   return first+flat*(.65+math.sin(a)*math.min(radius*.72,3.6))
    +Vector3.yAxis*(math.cos(a)*2.65)+right*(.28-.56*t)
  end
  if cragCleave then
   local bearing=math.rad(angle)*(.36-.72*t)
   local reach=math.min(radius,7)*(.38+.49*math.sin(t*math.pi*.66))
   return first+(flat*math.cos(bearing)+right*math.sin(bearing))*reach+Vector3.yAxis*(2.35-4.2*t)
  end
  local lateral=id=="dwarf_hooking_chop" and -.85 or 0
  return first+flat*math.sin(a)*math.min(radius,5)+Vector3.yAxis*math.cos(a)*2.8+right*(t-.5)*lateral
 end
 local shieldCenter=first+flat*1.7
 local shieldTravel=verdict and .65 or 1.55
 local function shieldPath(t)
  local side=2*t-1
  if verdict then
   return shieldCenter+right*side*1.05+Vector3.yAxis*(1.6-2.8*math.abs(side))
  end
  return shieldCenter+right*side*1.45+flat*(.55*(1-side*side))
   +Vector3.yAxis*(.42-.55*math.abs(side))
 end
 local function chargePath(t,u)
  local side=2*t-1
  local width=pulse==1 and .94 or 1.28
  local height=pulse==1 and -.32 or .28
  return first+flat*(1.35+.70*u-.37*math.abs(side))+right*side*width
   +Vector3.yAxis*(height+(1-math.abs(side))*.48)
 end
 local launch=vector(muzzle) and (muzzle-first).Magnitude<=6 and muzzle or nil
 local artContext={id=id,shape=shape,key=row.key,first=first,last=last,dir=dir,flat=flat,right=right,floor=floor,radius=radius,angle=angle,area=area,definition=d,character=character,pulse=pulse,final=final,muzzle=launch}
 if Polish.strokes(r,artContext,line,curve)then
 elseif Art.strokes(r,artContext,line,curve)then
  -- A distinct primary path replaces the generic elemental helix.
 elseif profile.signature then
  signature(r,profile.signature,artContext)
 elseif shape=="thrust"then
  line(r,"ThrustEdge",function(u)
   return thrustBase:Lerp(thrustTip,math.min(u*1.5,.86)),thrustTip
  end,width,WHITE)
  for lane=1,count do local side=lane%2==0 and -1 or 1
   stroke("ThrustPressure",thrustBase+right*side*.27,thrustTip+right*side*.08,width*.4)
  end
 elseif cragCleave then
  curve(r,"CragCleaveEdge",function(t,u)return cleavePath(t)-Vector3.yAxis*u*.35 end,compact and 6 or 9,.34,WHITE)
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif shape=="cleave"then
  for lane=1,count do curve(r,"DescendingCleave",function(t,u)
   return cleavePath(t)-Vector3.yAxis*u*.5+right*(lane-(count+1)/2)*.3
  end,12,width)end
 elseif shape=='spin'then
  r.model:SetAttribute('SpinStyle',spinStyle)
  if cyclone then r.model:SetAttribute("PrimaryIconCue",true) end
  for lane=1,spinLanes do
   curve(r,'BladeRibbon',function(t,u)return spinPath(lane,t,u)end,cyclone and r.compact and 8 or spinStyle=='BrokenBladeStorm'and 10 or 12,width)
  end
 elseif counterSlash then
  curve(r,"IconCounterSlashEdge",function(t)return counterPath(t)end,r.compact and 6 or 10,width,WHITE)
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif steelSweep then
  curve(r,"SteelSweepEdge",steelSweepPath,compact and 6 or 9,.28,WHITE)
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif rallyingSlash then
  curve(r,"RallyingSlashEdge",function(t,u)
   local bearing=math.rad(angle)*(.5-t)
   local reach=math.min(radius,7)*(.60+.28*math.sin(t*math.pi)+.10*u)
   return first+(flat*math.cos(bearing)+right*math.sin(bearing))*reach+Vector3.yAxis*(-1.10+2.42*t)
  end,r.compact and 6 or 9,.24,r.hot)
  r.model:SetAttribute("RallyingSlashEdge",true)
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif id=="knight_crescent_cut" then
  local segments=r.compact and 6 or 10
  local before=#r.lines
  curve(r,"CrescentCutEdge",function(t,u)
   local a=math.rad(angle)*(t-.5)+.16*math.sin(t*math.pi)*u
   local reach=radius*(.72+.19*math.sin(t*math.pi))
   return first+(flat*math.cos(a)+right*math.sin(a))*reach+Vector3.yAxis*(.75-1.08*t)
  end,segments,width,WHITE)
  if #r.lines-before==segments then r.model:SetAttribute("CrescentCutEdge",true) end
 elseif shape=="slash"or shape=="crescent"or shape=="areslash"or shape=="low"or shape=="counter"then
  local at=shape=="low"and floor or first
  local arc=shape=="spin"and 360 or angle
  for lane=1,count do sector(shape=="low"and"LowSweep"or"BladeRibbon",at,math.min(radius,8)*(.72+lane*.08),arc,lane,shape=="low")end
  if shape=="counter"then sector("CounterGuard",floor,2.4,110,1,true)end
 elseif shape=="cross"then
  curve(r,oathblade and "OathbladeEdge" or "SunwardCross",crossPath,r.compact and oathblade and 5 or 8,width,WHITE)
  if oathblade then r.model:SetAttribute("PrimaryIconCue",true) end
 elseif shieldStrike then
  curve(r,verdict and "VerdictCrest" or "ShieldBreakerWave",function(t,u)
   return shieldPath(t)+flat*(shieldTravel*u)
  end,verdict and 4 or 6,width,WHITE)
 elseif shieldCharge then
  for side=0,1 do
   line(r,"BreakerChargeEdge",function(u)return chargePath(side*.5,u),chargePath((side+1)*.5,u)end,width,WHITE,.08)
  end
  if #r.lines==2 then r.model:SetAttribute("PrimaryIconCue",true) end
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
     ring(r,"WardOrbit",first,2.2,width,true,false,nil,basis,8)
    else ring(r,"DawnSeal",floor,radius*(shape=="holy"and .87 or(.55+lane*.12)),width,false,false)end
   end
  end
 elseif shape=="axe"then
  local from,to=first,last;if d.returning and pulse%2==0 then from,to=last,first end
  r.model:SetAttribute("Returning",d.returning and pulse%2==0 or false)
  local axis,approach
  if crosscutReturn or returningEcho then from,to,axis,approach=Art.axeFlight(artContext) end
  if returningEcho then
   r.model:SetAttribute("PrimaryIconCue",true)
   line(r,"ReturningEchoWake",function(u)
    local remaining=approach and (1-math.clamp(u*r.life/Art.axeCatchSeconds,0,1))^2 or 0
    local tip=to+(approach or Vector3.zero)*remaining
    return tip-axis*math.min((tip-from).Magnitude,1.65)*(1-u),tip
   end,width*.55,r.hot,width*.92,true)
  elseif d.braced then
   local length=(to-from).Magnitude
   local launch=vector(muzzle) and (muzzle-from):Dot(dir)<length-.2 and (muzzle-from).Magnitude<=6 and muzzle or from
   line(r,"BracedThrowWake",function(u)
    local head=math.min(1,.3+u*5)
    return launch:Lerp(to,math.max(0,head-.36*(1-u))),launch:Lerp(to,head)
   end,width*.52,WHITE,width*.84)
  else
   stroke(d.crosscut and "IconCrosscutWake" or "AxeWake",from,to,width*.45)
  end
  if d.crosscut then r.model:SetAttribute("PrimaryIconCue",true) end
  axis=axis or forward(from,to)
  local basis=CFrame.lookAt(to,to+axis)
  curve(r,crosscutReturn and "CrosscutCatchEdge" or "AxeRotation",function(t,u)
   local arrival=approach and math.clamp(u*r.life/Art.axeCatchSeconds,0,1)
   local turn=arrival and (1-arrival)^2 or u
   local a=t*math.pi*1.6+turn*(approach and math.pi or 7)+phase
   local pivot=approach and to+approach*turn or to
   return pivot+basis.RightVector*math.cos(a)*.7+basis.UpVector*math.sin(a)*.7
  end,returningEcho and (r.compact and 4 or 6) or 8,width)
 elseif crossfire then
  local length=(last-first).Magnitude
  if length>.1 then
   local rise=Vector3.yAxis*(pulse==2 and .55 or .25)
   local start=first+flat*math.min(length*.22,1.05)+rise
   local tip=last+rise
   local trace=line(r,"IconCrossfireTrace",function()return start,tip end,width*.72,WHITE,width*1.32)
   if trace then
    r.model:SetAttribute("CrossfireTrace",true)
    r.model:SetAttribute("PrimaryIconCue",true)
   end
   if not r.compact then
    line(r,"CrossfireFletching",function(u)
     local side=right*(pulse==2 and .34 or -.23)*(1-u*.6)
     return tip-flat*math.min(length*.5,7)*(1-u)^2+side,tip
    end,width*.46,r.color,width*.62)
   end
  end
 elseif id=="elf_retreating_shot" then
  local start=launch and (last-launch):Dot(dir)>.1 and launch or first
  local trace=line(r,"RetreatingShotWake",function(u)
   return start:Lerp(last,.7*(1-(1-u)^2)),last
  end,.052,r.hot,.10)
  if trace then r.model:SetAttribute("RetreatingShotWake",true) end
 elseif id=="elf.magic_archer.gliding_shot" then
  local start=launch and (last-launch):Dot(dir)>.1 and launch or first
  local length=(last-start).Magnitude
  if length>.1 then
   local trace=line(r,"GlidingShotWake",function(u)
    return start:Lerp(last,.86*u),last
   end,.058,r.hot,.035)
   if trace then r.model:SetAttribute("GlidingShotWake",true) end
   if not r.compact then
    line(r,"GlidingShotFletching",function(u)
     local tail=start:Lerp(last,math.min(1.4/length,.3))
     return start+right*(.25*(1-u)),tail
    end,.045,r.color,.018)
   end
  end
 elseif quickfire or echoArrows then
  local start=launch and (last-launch):Dot(dir)>.1 and launch or first
  local length=(last-start).Magnitude
  if length>.1 then
   local trace=line(r,quickfire and "QuickfireTracer" or "EchoArrowWake",function(u)
    return start:Lerp(last,(quickfire and .88 or .75)*u),last
   end,width*(quickfire and .58 or .45+.13*pulse),quickfire and WHITE or r.hot,width*.34)
   if trace then
    if echoArrows then
     local bank=(pulse-2)*.42
     local function echoPath(t,u)
      local base=start:Lerp(last,.75*u)
      local waviness=math.min(length*.045,.62)*(1-u)*math.sin(t*math.pi)
      return base:Lerp(last,t)+(right*bank+Vector3.yAxis*.5)*waviness
     end
     trace.span=function(u)return Style.span(echoPath,0,1,u)end
     trace.beam.Segments=4
    end
    r.model:SetAttribute("PrimaryIconCue",true)
    r.model:SetAttribute("ReleaseTrace",true)
   end
  end
 elseif fanLanes then
  drawFan(r,d,fanProfile,first,flat,launch,fanEndpoints)
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
    local start=first
    if row.key=='gun'then start=target-forward(first,target)*math.min(2.5,(target-first).Magnitude)end
    local axis=forward(start,target)
    local length=(target-start).Magnitude
    line(r,shape=="bullet"and"RifleTracer"or"ArrowPressure",function(u)
     local tail=math.min(length,row.key=="gun" and 2.5 or 8)*(1-u)^1.6
     return target-axis*tail+offset,target+offset
    end,width*.25/wake^.3,r.color,width*.95/wake^.3)
   end
   local axis=forward(first,target);local cf=CFrame.lookAt(target,target+axis)
   if shape~="bullet"and row.key~='gun'then
    for side=-1,1,2 do stroke("ArrowEdge",target-axis*.7+cf.RightVector*side*.18,target,width*.6,WHITE)end
   end
  end
  if id=='elf.marksman.weakpoint_shot'then
   local axis=forward(first,last);local side=axis:Cross(Vector3.yAxis);side=side.Magnitude>.01 and side.Unit or right
   for sign=-1,1,2 do
    stroke('WeakpointBracket',last+side*sign*.65-Vector3.yAxis*.35,last+side*sign*.65+Vector3.yAxis*.35,.075)
   end
  elseif id=='elf.marksman.heavy_draw'then
   local axis=forward(first,last);local basis=CFrame.lookAt(last,last+axis)
   for sign=-1,1,2 do
    stroke('HeavyDrawFletching',last-axis*3+basis.RightVector*sign*.55,last-axis*.8,.13,r.hot)
   end
  end
  if row.key~="arrow"and shape~="bullet"and shape~="fan"then
   local basis=CFrame.lookAt(first,first+dir)
   curve(r,row.key=="lightning"and"ArrowSpark"or"EnchantedArrow",function(t,u)
    local a=t*math.pi*4+phase+u*6
    return first+(last-first)*t+basis.RightVector*math.cos(a)*.22+basis.UpVector*math.sin(a)*.22
   end,8,width*.6)
  end
 elseif shape=="rain"or shape=="hail"or shape=="ash"then
  if emphasis and (shape=="hail"or shape=="ash") then
   local ice=shape=="hail"
   for i=1,6 do
    local angle=i*math.pi/3
    local radial=flat*math.cos(angle)+right*math.sin(angle)
    local side=Vector3.yAxis:Cross(radial)
    local at=floor+radial*math.min(radius*.19,2)
    line(r,ice and "HailFracture" or "AshLandingEmber",function(u)
     if ice then
      local joint=at+radial*(.5+.5*u)+side*.24+Vector3.yAxis*.055
      return at+Vector3.yAxis*.065,joint
     end
     local lift=math.sin(u*math.pi)*.8
     return at+radial*u*.7+Vector3.yAxis*lift,
      at+radial*(.65+u*1.2)+Vector3.yAxis*(lift+.22)
    end,ice and .12 or .085)
    if ice then
     line(r,"HailFracture",function(u)
      return at+radial*(.5+.5*u)+side*.24+Vector3.yAxis*.055,
       at+radial*(1.05+1.15*u)+Vector3.yAxis*.065
     end,.075,r.hot)
    end
   end
  else
   ring(r,"LandingRipple",floor,math.min(radius,4),width*.5,false,false,nil,nil,r.compact and 8 or nil)
  end
  if shape=="hail" then debris(r,floor,4,"IceShard",.82)
  elseif shape=="ash" then debris(r,floor,4,"Ember",.76) end
 elseif lavaEruption then
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif shape=="blast"or shape=="earth"or shape=="lava"then
  local at=floor
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
  ring(r,"FrostBloom",floor,radius*(frostStep and .48 or 1),width*.6,false,false,nil,nil,frostStep and 8 or nil)
  debris(r,floor,math.min(count,frostStep and 2 or 7),"IceShard",frostStep and .8 or 1.7)
  if frostStep then
   -- Packet origin is the landing and center is the departure. No movement cue when blocked.
   local travel=first-last
   local horizontal=Vector3.new(travel.X,0,travel.Z)
   if horizontal.Magnitude>.35 and horizontal.Magnitude<=d.move+.5 then
    local destination=floorAt(first,character)
    if math.abs(destination.Y-floor.Y)<=1.8 then
     local side=horizontal.Unit:Cross(Vector3.yAxis)*.28
     for lane=-1,1,2 do
      local from=floor+side*lane+Vector3.yAxis*.08
      local to=destination+side*lane+Vector3.yAxis*.08
      line(r,"FrostStepHeelTrace",function(u)return from:Lerp(to,u*.18),from:Lerp(to,.72+.22*u)end,.075,r.hot,.035)
     end
    end
   end
   r.model:SetAttribute("PrimaryIconCue",true)
  end
 elseif shape=="lightning"then
  local path={}
  if d.form=="chain"then
   local from=vector(muzzle) and (muzzle-first).Magnitude<=8 and muzzle or first
   for i=1,math.min(type(points)=="table"and #points or 0,d.maxTargets or 4)do
    if vector(points[i])then
     if (points[i]-from).Magnitude>.02 then table.insert(path,{from,points[i]}) end
     from=points[i]
    end
   end
  else table.insert(path,{d.form=="ground"and last+Vector3.yAxis*10 or first,last})end
  local segments=d.form=="chain" and r.compact and 4 or 6
  if d.form=="chain" and #path>0 then
   local limit=Input.TouchEnabled and 144 or 240
   if beams+#path*segments<=limit then r.model:SetAttribute("ChainCore",true)
   else table.clear(path) end
  end
  for hop,link in ipairs(path)do
   local bolts=Geometry.lightning(link[1],link[2],segments)
   local forks={};local axis=forward(link[1],link[2]);local side=axis:Cross(Vector3.yAxis)
   side=side.Magnitude>.01 and side.Unit or Vector3.xAxis
   local extent=math.min(1.6,(link[2]-link[1]).Magnitude*.18)
   for fork=1,(r.compact and segments==4 and 1 or #path>3 and 1 or 3)do
    local at=bolts[fork*2];local sign=fork%2==0 and -1 or 1
    local tip=at+side*sign*extent+axis*extent*.45
    local kink=at+(tip-at)*.5+Vector3.yAxis*extent*.25
    table.insert(forks,{at,kink,tip})
   end
   local coreWidth=d.form=="chain" and width*(1-.12*(hop-1)) or width
   table.insert(electricLinks,{bolts=bolts,forks=forks,side=side,width=coreWidth})
   for i=1,#bolts-1 do stroke("ElectricCore",bolts[i],bolts[i+1],coreWidth,WHITE)end
  end
  for _,link in ipairs(electricLinks)do
   for _,fork in ipairs(link.forks)do
    for i=1,2 do stroke("ElectricFork",fork[i],fork[i+1],link.width*.42,r.color)end
   end
  end
 elseif shape=="vine"then
  local rootRadius=id=='elf.magic_archer.vine_trap' and math.min(radius,3.2)or vineBurst and math.min(radius,5)or radius
  roots(r,floor,flat,right,rootRadius,d.form=='cone'and angle or 360,vineBurst and (compact and 3 or 4) or count,vineBurst)
  if vineBurst then r.model:SetAttribute("PrimaryIconCue",true) end
 elseif shape=="gravity"then
  local at=floorAt(last,character)
  local gravityRadius=math.min(radius*.45,2.4)
  for lane=1,count do curve(r,"GravityInfall",function(t,u)
   local a=t*math.pi*3+lane*math.pi+u*3;local rad=gravityRadius*(1-t)*(.8-u*.6)
   return at+Vector3.new(math.cos(a)*rad,.3+t*1.6,math.sin(a)*rad)
  end,10,width)end
 elseif shape=="steam"then
  local at=floor
  local span=math.min(radius*.63,4.2)
  for side=-1,1,2 do
   curve(r,"SteamFlashLip",function(t,u)
    local angle=math.pi*((t-.5)*.86+(side>0 and 1 or 0))
    local radial=flat*math.cos(angle)+right*math.sin(angle)
    local reach=span*(.34+.66*(1-(1-u)^4))
    return at+radial*reach+Vector3.yAxis*(.16+math.sin(t*math.pi)*.22)
   end,3,.17,r.hot)
   local pos=at+right*side*.75
   atmosphere(r,"SteamVapor",pos,false,3,1.1)
   curve(r,"SteamWisp",function(t,u)
    return pos+right*side*(t*.77+u*.37)+flat*math.sin(t*math.pi)*.37
     +Vector3.yAxis*(.2+t*1.65+u*.92)
   end,3,.095,Color3.fromRGB(195,219,229))
  end
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif shape=="water"then
  local at=area and floorAt(last,character)or last
  if Art.kind(id)=='WaterBall'then
   curve(r,'WaterBallHighlight',function(t,u)
    local a=t*math.pi*1.25+u*.5
    return last+right*math.cos(a)*.94+Vector3.yAxis*math.sin(a)*.94
   end,6,.09,r.hot)
   curve(r,'WaterBallFoam',function(t,u)
    local a=t*math.pi*.65+math.pi+u*.35
    return last+right*math.cos(a)*.95+Vector3.yAxis*math.sin(a)*.95+dir*.12
   end,5,.07,r.hot)
  else ring(r,"TidalLip",at,area and radius or 1.8,width,false,false)end
  debris(r,at,math.min(count,6),"WaterSpray",1)
 elseif cinderRing then
  local beat=math.clamp(pulse-1,0,2)
  local height=.08+.14*beat^2
  local crest=.07+.18*beat^2
  curve(r,"CinderRing",function(t,u)
   local a=t*math.pi*2
   local reach=radius*(.30+.70*(1-(1-u)^5))
   local rise=height+crest*(.35+.65*math.sin(a*3)^2)*math.sin(u*math.pi*.85)
   return floor+(flat*math.cos(a)+right*math.sin(a))*reach+Vector3.yAxis*rise
  end,r.compact and 8 or 12,width*(.60+.18*beat),r.hot)
  r.model:SetAttribute("PrimaryIconCue",true)
 elseif shape=="fire"or shape=="arcane"then
  local at=area and floorAt(last,character)or first
  local emberStep=id=='mage.pyro.ember_step'
  if area then ring(r,"CinderRing",at,radius,width*(id=='mage.pyro.cinder_ring'and .6 or .28),false,false)end
  local basis=CFrame.lookAt(first,first+dir)
  for lane=1,emberStep and 1 or count do curve(r,shape=="fire"and"FlameTongue"or"ArcaneHelix",function(t,u)
   local a=t*math.pi*3+lane*math.pi*2/count+u*4+phase
   if area then
    if emberStep then
     return at+right*((t-.5)*radius*.65)-flat*radius*.18+Vector3.yAxis*(.15+math.sin(t*math.pi)*.8+u*.6)
    end
    local heading=lane*math.pi*2/count+phase+math.sin(t*math.pi)*.18+u*.25
    local ward=id=='mage.pyro.searing_ward'
    local rad=radius*(ward and(.35-t*.12)or(.65+t*.12))
    return at+Vector3.new(math.cos(heading)*rad,t*(ward and 3.2 or 2.2),math.sin(heading)*rad)
   end
   return first+(last-first)*t+basis.RightVector*math.cos(a)*.32+basis.UpVector*math.sin(a)*.32
  end,8,width)end
 end
 if stepWakes[id] and id~="knight.paladin.valiant_advance" then r.model:SetAttribute("PrimaryIconCue",true) end
 IconVFX.draw(r,id,{first=first,last=last,flat=flat,right=right,floor=floor,radius=radius,area=area,definition=d,points=type(points)=='table' and points or {},pulse=pulse},line,curve)
 -- Filled silhouettes carry the effect; narrow beams remain as edge highlights.
 local surfaceOrigin=shape=="low"and floor or first
 if Polish.surfaces(r,artContext)then
 elseif Art.surfaces(r,artContext)then
  -- ART owns this primary silhouette. Existing range geometry remains separate.
 elseif profile.signature then
  -- The authored signature above already owns its filled silhouettes.
 elseif shape=='spin'then
  for lane=1,spinLanes do
   local start=#r.faces
   local normal=spinBank.UpVector
   local segments=spinStyle=='BrokenBladeStorm'and 4 or cyclone and (r.compact or Input.TouchEnabled) and 8 or 12
   Surfaces.ribbon(r,'BladeSurface',function(t)return spinPath(lane,t)end,normal,spinStyle=='BrokenBladeStorm'and .65 or .85,.46,r.color:Lerp(r.hot,.18),segments,Enum.Material.SmoothPlastic)
   local sign=cyclone and cycloneBank or 1
   Surfaces.animate(r,start,first,normal,-sign*2.4,false,r.life)
  end
 elseif counterSlash then
  Surfaces.ribbon(r,"CounterSlashSteel",counterPath,Vector3.yAxis,.62,.46,r.color:Lerp(r.hot,.18),r.compact and 5 or 9,Enum.Material.SmoothPlastic)
 elseif crossfire then
  -- The narrow beam and paired fletching carry this shot across the arena.
 elseif steelSweep then
  local start=#r.faces
  Surfaces.ribbon(r,"SteelSweepRibbon",function(t)return steelSweepPath(t,0)end,Vector3.yAxis,.68,.52,r.color,compact and 4 or 6)
  for i=start+1,#r.faces do r.faces[i].drift=flat*radius*.09;r.faces[i].fadeDuration=.17 end
 elseif cragCleave then
  local start=#r.faces
  Surfaces.ribbon(r,"CragCleaveRibbon",cleavePath,right,.94,.42,r.color,compact and 4 or 7)
  for i=start+1,#r.faces do r.faces[i].fadeDuration=.19 end
 elseif rallyingSlash or fanLanes then
  -- The open cutting edge and narrow projectile traces carry the release.
 elseif shape=="slash"or shape=="crescent"or shape=="areslash"or shape=="low"or shape=="counter"then
  local sweep=angle
  local start=#r.faces
  Surfaces.ribbon(r,"BladeSurface",function(t)
   local a=math.rad(-sweep/2+sweep*t)
   return surfaceOrigin+(flat*math.cos(a)+right*math.sin(a))*math.min(radius,8)*.8
  end,Vector3.yAxis,1.05,.44,r.color:Lerp(r.hot,.18),12,Enum.Material.SmoothPlastic)
  Surfaces.ribbon(r,"BladeCuttingEdge",function(t)
   local a=math.rad(-sweep/2+sweep*t)
   return surfaceOrigin+Vector3.yAxis*.025+(flat*math.cos(a)+right*math.sin(a))*math.min(radius,8)*.84
  end,Vector3.yAxis,.18,.12,r.hot,6,Enum.Material.Neon)
  Surfaces.animate(r,start,surfaceOrigin,Vector3.yAxis,.6,false,r.life)
  for i=start+1,#r.faces do r.faces[i].motion.duration=math.min(r.life,.22)end
 elseif shape=="cleave"then
  local start=#r.faces
  Surfaces.ribbon(r,"CleaveSurface",cleavePath,right,id==ARMOR_SPLITTER and .75 or 1.2,.36,r.color:Lerp(r.hot,.18),12,Enum.Material.SmoothPlastic)
  Surfaces.ribbon(r,"CleaveCuttingEdge",function(t)return cleavePath(t)+flat*.04 end,right,.2,.12,r.hot,6,Enum.Material.Neon)
  Surfaces.animate(r,start,first,right,.65,false,math.min(r.life,.22))
 elseif shape=="cross"then
  if not oathblade or not r.compact then
   Surfaces.ribbon(r,"CrossSurface",crossPath,flat,.65,.55,r.color:Lerp(r.hot,.18),8,Enum.Material.SmoothPlastic)
  end
 elseif shape=="thrust"then
  local start=#r.faces
  Surfaces.triangle(r,"ThrustSurface",thrustBase-right*.4,thrustTip,thrustBase+right*.4,nil,.32)
  for i=start+1,#r.faces do r.faces[i].fadeDuration=.13 end
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
 elseif shieldStrike then
  local start=#r.faces
  Surfaces.ribbon(r,verdict and "VerdictCrestFace" or "ShieldBreakerFace",shieldPath,
   flat,verdict and .42 or .66,.49,r.color,verdict and 4 or 6,Enum.Material.SmoothPlastic)
  for i=start+1,#r.faces do r.faces[i].drift=flat*shieldTravel end
 elseif shieldCharge then
  if not r.compact then
   local up=Vector3.yAxis*.34
   local middle=chargePath(.5,0)
   local start=#r.faces
   Surfaces.triangle(r,"BreakerChargeFace",chargePath(0,0),middle+up, middle-up,r.color,.5)
   Surfaces.triangle(r,"BreakerChargeFace",chargePath(1,0),middle-up,middle+up,r.color,.5)
   for i=start+1,#r.faces do r.faces[i].drift=flat*.7 end
  end
 elseif shape=="guard"then
  local at=first+flat*1.8;local verts={Vector2.new(-1.3,1.3),Vector2.new(1.3,1.3),Vector2.new(1,-.4),Vector2.new(0,-1.5),Vector2.new(-1,-.4)}
  for i=1,#verts do
   local a,b=verts[i],verts[i%#verts+1]
   Surfaces.triangle(r,"GuardSurface",at,at+right*a.X+Vector3.yAxis*a.Y,at+right*b.X+Vector3.yAxis*b.Y,nil,.62)
  end
 elseif cinderRing then
  -- Keep the outer hazard outline clear of the rising flame tongues.
  if not r.compact then
   for i=1,3 do
    local a=(i-.5)*math.pi*2/3+phase
    local at=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*(.40+.08*pulse)
    tongue(r,"AreaFlameTongue",at,.35+pulse*.62,.40+pulse*.08,a,r.color)
   end
  end
 elseif shape=="fire"or shape=="arcane"or shape=="stone"or(shape=="frost"and not area)then
  if area then
   local fireStyle=id=='mage.pyro.ember_step'and 'EmberWake'or id=='mage.pyro.searing_ward'and 'SearingCrown'or 'RisingCinders'
   r.model:SetAttribute('FireAreaStyle',fireStyle)
   local start=#r.faces
   Surfaces.arc(r,"CinderShockwave",floor,radius*(fireStyle=='SearingCrown'and .42 or .78),math.min(radius*.1,.65),nil,.6,nil,fireStyle=='EmberWake'and 220 or 360)
   Surfaces.animate(r,start,floor,Vector3.yAxis,.3,true,r.life)
   for i=1,3 do
    local a=i*math.pi*2/3+phase;local at=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*.56
    local height=1.8+(i%2)*.6
    if fireStyle=='EmberWake'then at=floor+right*(i-2)*radius*.34-flat*radius*.18;height=1.1+i*.3
    elseif fireStyle=='SearingCrown'then at=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*.34;height=2.8+(i%2)*.35 end
    tongue(r,'AreaFlameTongue',at,height,fireStyle=='EmberWake'and .55 or .8,a,r.color)
    if shape=='fire'then atmosphere(r,'AreaFire',at,true,2,.8)end
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
     if shape=="frost"then
      local basis=CFrame.lookAt(last,last+dir)
      for side=-1,1,2 do
       local at=last-dir*length*.4+basis.RightVector*side*.42
       local shard=Surfaces.volume(r,"IceLanceFacet",at,Vector3.new(.24,.5,length*.65),Color3.fromRGB(198,244,255),.22,'wedge',Enum.Material.Ice)
       if shard then local face=r.faces[#r.faces];face.cf=CFrame.lookAt(at,at+dir)*CFrame.Angles(0,side*.13,0);shard.CFrame=face.cf end
      end
     end
    end
   end
  end
 elseif lavaEruption then
  local hot=Color3.fromRGB(255,174,47)
  for lane=1,(compact and 2 or 3) do
   local heading=(lane-1)*math.pi*2/3
   local radial=flat*math.cos(heading)+right*math.sin(heading)
   local base=floor+radial*radius*.23+Vector3.yAxis*.07
   local tip=base+radial*.48+Vector3.yAxis*(lane==1 and 4.9 or 3.35)
   local vent=Surfaces.bar(r,"LavaVent",base,tip,lane==1 and .44 or .32,hot,.14,Enum.Material.Neon)
   if vent then Surfaces.growLine(r,base,tip,.14,(lane-1)*.027) end
   local seamStart=floor+radial*radius*.10+Vector3.yAxis*.06
   local seamEnd=floor+radial*radius*.59+Vector3.yAxis*.06
   local seam=Surfaces.bar(r,"MoltenSeam",seamStart,seamEnd,.20,hot,.16,Enum.Material.Neon)
   if seam then Surfaces.growLine(r,seamStart,seamEnd,.11,0) end
   line(r,"EruptionJet",function(u)
    local rise=math.clamp((u*r.life-(lane-1)*.027)/.14,0,1)
    return base:Lerp(tip,rise*.37),base:Lerp(tip,math.max(.01,rise))
   end,.33,palette.fire,.54,true)
   if not compact then
    local crust=Surfaces.volume(r,"EruptionBasalt",base+Vector3.yAxis*.38,Vector3.new(1.28,1.15,1.42),Color3.fromRGB(79,53,43),.12,"wedge",Enum.Material.Slate)
    if crust then r.faces[#r.faces].emerge={duration=.13,delay=(lane-1)*.027} end
   end
  end
 elseif shape=="earth"or shape=="lava"or shape=="blast"or shape=="mortar"then
  if shape=="blast"or shape=="mortar"then
   local at=area and floor+Vector3.yAxis*(bomb and Bomb.radius or 1) or first+flat*2
   if bomb then
    local flash=Surfaces.volume(r,'BombContactFlash',at,Vector3.one*.6,WHITE,.18,'ball')
    if flash then r.faces[#r.faces].fadeDuration=.09 end
    local fragments=r.compact and 3 or bomb.path=="scatter" and 7 or 5
    for i=1,fragments do
     local a=i*math.pi*2/fragments
     local direction=Vector3.new(math.cos(a),bomb.path=="scatter" and .48 or .2,math.sin(a))
     local fragment=Surfaces.volume(r,'BombCasingFragment',at+direction*.25,Vector3.new(.15,.3,.6),Color3.fromRGB(95,75,58),.15,'wedge',Enum.Material.Slate)
     if fragment then
      local face=r.faces[#r.faces];face.cf=CFrame.lookAt(fragment.Position,fragment.Position+direction);fragment.CFrame=face.cf
      face.drift=direction*2.4
     end
    end
    atmosphere(r,"BombGroundSmoke",at,false,6,1.4)
   else
   local flash=Surfaces.volume(r,"BlastCore",at,Vector3.one*.9,r.hot,.2,'ball')
   if flash then r.faces[#r.faces].fadeDuration=.09 end
   local start=#r.faces
   local waveAt=area and at-Vector3.yAxis*.7 or floor
   if d.form=='cone'then
    Surfaces.ribbon(r,'BlastForwardPressure',function(t)local a=math.rad(-angle*.5+angle*t);return waveAt+(flat*math.cos(a)+right*math.sin(a))*math.min(radius*.55,4)end,Vector3.yAxis,.4,.55,nil,6)
   else Surfaces.arc(r,"BlastShockwave",waveAt,math.min(radius,emphasis and 5.5 or 4),emphasis and .8 or .55,nil,.48)end
   Surfaces.animate(r,start,waveAt,Vector3.yAxis,.4,true,math.min(r.life,.32))
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
    Surfaces.volume(r,"RisingCrag",at,Vector3.new(1.1,shape=='lava'and 1.1 or 1.8,1.2),palette.earth,.26,'wedge',Enum.Material.Slate,false,.5)
   end
   if shape=='lava'then
    for i=1,3 do local a=i*math.pi*2/3;local radial=Vector3.new(math.cos(a),0,math.sin(a));local at=floor+radial*radius*.28
     tongue(r,'LavaVent',at,1.8+i*.2,.65,a,palette.fire);atmosphere(r,'LavaFire',at,true,2,.8)
     Surfaces.bar(r,'MoltenSeam',floor+radial*.4+Vector3.yAxis*.05,floor+radial*radius*.72+Vector3.yAxis*.05,.12,palette.fire,.28,Enum.Material.Neon)
    end
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
 elseif shape=="water"or(shape=="frost"and area)or shape=="gravity"then
  if shape=="frost"then
   local facets=frostStep and 4 or 8
   for i=1,facets do
    local a=i*math.pi*2/facets;local radial=Vector3.new(math.cos(a),0,math.sin(a))
    local height=(frostStep and .56 or math.min(2.6,1+radius*.1))*(i%2==0 and 1 or .65)
    local facet=Surfaces.volume(r,'FrostRimFacet',floor+radial*radius*(frostStep and .42 or .8)+Vector3.yAxis*height*.5,Vector3.new(.5,height,.65),i%2==0 and r.color or Color3.fromRGB(198,244,255),.24,'wedge',Enum.Material.Ice)
    if facet then
     local face=r.faces[#r.faces];face.cf=CFrame.lookAt(facet.Position,facet.Position+radial)*CFrame.Angles(.18,0,(i%2==0 and 1 or -1)*.12)
     facet.CFrame=face.cf;face.emerge={duration=.18,delay=(i%3)*.012}
    end
   end
  else
  local at=area and floorAt(last,character)or last
  local start=#r.faces
  Surfaces.arc(r,"ElementalSurface",at,area and radius*.78 or 1.7,shape=="gravity"and .4 or .65,nil,.55,nil,nil,shape=='water'and(Input.TouchEnabled and 10 or 14)or nil)
  Surfaces.animate(r,start,at,Vector3.yAxis,shape=="gravity"and -1.2 or .35,true,r.life)
  end
  if shape=="water"then
   Surfaces.volume(r,"WaterVolume",area and floor+Vector3.yAxis*.35 or last,Vector3.new(2.2,.8,2.2),nil,.62,'ball',nil,true)
   for i=1,4 do
    local a=i*math.pi/2;local radial=Vector3.new(math.cos(a),0,math.sin(a))
    local at=(area and floor or last)+radial*(area and math.min(radius*.55,3)or 1.2)+Vector3.yAxis*.35
    local crest=Surfaces.volume(r,"WaterCrest",at,Vector3.new(1.3,.18,.7),nil,.3,'ball',Enum.Material.Glass,false,.35)
    if crest then local face=r.faces[#r.faces];face.cf=CFrame.lookAt(at,at+radial)*CFrame.Angles(-.45,0,0);crest.CFrame=face.cf;face.drift=radial*.7 end
    Surfaces.volume(r,"WaterFoam",at+Vector3.yAxis*.18,Vector3.new(.8,.08,.12),Color3.fromRGB(192,235,255),.35,'ball',nil,false,.35)
   end
  end
 elseif quickfire or echoArrows then
  -- The trace and equipped arrow already carry these releases.
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
    if row.key=='gun'then
     Surfaces.bar(r,'ShotPelletBody',target-axis*.55,target,.1,Color3.fromRGB(200,207,214),.15,Enum.Material.Metal)
    else
     local w=shape=="bullet"and .12 or row.key=="arrow"and .13 or .31
     Surfaces.triangle(r,"ProjectileSurface",back-side*w,target,back+side*w,nil,.42)
    end
   end
  end
 elseif shape=="lightning" and (d.form~="chain" or not r.compact) then
  for _,link in ipairs(electricLinks)do
    local bolt=link.bolts;local side=link.side
    for j=1,#bolt-1 do
     local a,b=bolt[j],bolt[j+1]
     local span=d.form=="chain" and link.width*2 or .3
     Surfaces.triangle(r,"LightningSurface",a-side*span,b,a+side*span,nil,.24)
    end
    for _,fork in ipairs(link.forks)do for j=1,2 do
     Surfaces.triangle(r,"LightningBranch",fork[j]-Vector3.yAxis*.075,fork[j+1],fork[j]+Vector3.yAxis*.075,nil,.25)
    end
    end
  end
 elseif shape=="warcry"then
  if d.form=='cone'then
   r.model:SetAttribute('ForwardOnly',true)
   Surfaces.ribbon(r,'WarcryForwardPressure',function(t)local a=math.rad(-angle*.5+angle*t);return floor+(flat*math.cos(a)+right*math.sin(a))*radius*.65 end,Vector3.yAxis,.4,.76,nil,6)
  else
   Surfaces.arc(r,'WarcryOpenPressure',floor,radius*.65,.28,nil,.76)
  end
 elseif shape=="vine"then
  if d.form=='cone'then r.model:SetAttribute('ForwardOnly',true)end
 end
 Art.accents(r,artContext)
 Polish.finish(r,artContext)
 if row.key=="lightning"then for _,face in ipairs(r.faces)do face.fadeDuration=.16 end end
 if not bomb and not cinderRing and shape~="steam" and not rallyingSlash and not steelSweep and not cragCleave
  and not vineBurst and not lavaEruption and (d.damage or 1)>0 and(d.form~="chain"or type(points)=="table"and #points>0)then
  local at=Art.kind(id)=="MoltenLine" and floorAt(last,character)+Vector3.yAxis*.2 or area and floorAt(last,character)+Vector3.yAxis*.35 or row.key=="fire"and last or (vector(muzzle)and(muzzle-first).Magnitude>.35 and(muzzle-first).Magnitude<=8 and muzzle or first+dir*1.6)
  local scale=quickfire and .85 or echoArrows and .72 or (fanLanes and row.key=="gun") and 1.25
   or id=="knight.paladin.oathbound_assault" and .55
   or d.ultimate and (final and 4.5 or 2.6) or area and 3.2 or 2.2
  flourish(r,at,scale,row.key,d.ultimate and final)
 end
 FX.step(r.at);return r.model
end
-- Angles, lengths and half-widths of the filled rays in the contact plane.
local cutRays={{.32,1.38,.19},{1.49,.61,.14},{3.44,1.06,.16},{5.11,.74,.13}}
local chopRays={{.6,.81,.19},{1.54,1.38,.22},{2.53,.91,.24},{4.64,1.08,.18}}
local pierceRays={{.08,1.53,.15},{2.54,.77,.11},{3.27,.99,.13},{3.84,.74,.10}}

-- The rays and the flash are world-depth geometry and share the normal face budget.
local function impactStar(r,at,dir,size,classId,pierce)
 local camera=workspace.CurrentCamera
 local normal=camera and camera.CFrame.Position-at or -dir
 if normal.Magnitude<.01 then normal=-dir end
 normal=normal.Unit
 local right=camera and camera.CFrame.RightVector or Vector3.xAxis
 local up=normal:Cross(right)
 if up.Magnitude<.01 then up=normal:Cross(math.abs(normal.Y)<.95 and Vector3.yAxis or Vector3.zAxis)end
 up=up.Unit;right=up:Cross(normal).Unit
 local projected=dir-normal*dir:Dot(normal)
 if projected.Magnitude>.15 then right=projected.Unit;up=normal:Cross(right).Unit end
 local start=#r.faces
 local rays=pierce and pierceRays or classId=='dwarf' and chopRays or cutRays
 for i,ray in ipairs(rays) do
  local angle,length,width=unpack(ray)
  local radial=right*math.cos(angle)+up*math.sin(angle)
  local side=normal:Cross(radial)*width*size
  local base=at+radial*.22*size
  local color=i%2==1 and r.color:Lerp(r.hot,.28) or r.color
  Surfaces.triangle(r,'ArcadeImpactStar',base-side,at+radial*length*size,base+side,color,.08)
 end
 Surfaces.animate(r,start,at,normal,pierce and 0 or .16,true,.13)
 local center=at+normal*.025
 local span=right*size*(pierce and .57 or .31)
 local height=up*size*(pierce and .17 or .42)
 local core=#r.faces
 Surfaces.triangle(r,'ArcadeImpactCore',center+height,center-span,center-height,r.hot,.04)
 Surfaces.triangle(r,'ArcadeImpactCore',center+height,center-height,center+span,r.hot,.04)
 for i=core+1,#r.faces do r.faces[i].fadeDuration=.065 end
 if #r.faces==start then return false end
 r.model:SetAttribute('ContactStyle',pierce and 'ArcadePierce'or classId=='dwarf'and'ArcadeChop'or'ArcadeCut')
 return true
end
local function descendingContact(r,at,cf,size,shape)
 local shell=shape=="mortar"
 local ash=shape=="ash"
 local span=shell and 1.05 or shape=="hail" and .8 or ash and .6 or .45
 local name=shell and "ShellContactBurst" or shape=="hail" and "HailContactShards"
  or ash and "AshContactCinders" or "ArrowfallContactFletches"
 local count=r.compact and 1 or 3
 for i=1,count do
  local side=i-(count+1)*.5
  local spread=(cf.RightVector*side+cf.LookVector*(shell and .65 or .24))*span*size
  line(r,name,function(u)
   local tip=at+spread*(.18+u*.85)+Vector3.yAxis*((ash and .65 or -.5)*u*size)
   local tail=tip-spread*.3+Vector3.yAxis*((ash and -.48 or shell and .35 or .78)*size)
   return tail,tip
  end,shell and .14 or .08,i==math.ceil(count/2) and r.hot or r.color,.035)
 end
 if #r.lines>0 then r.model:SetAttribute("ContactStyle",name) end
end
local function skillContact(r,at,cf,size,style)
 local right,up,dir=cf.RightVector,cf.UpVector,cf.LookVector
 for side=-1,1,2 do
  local lateral=right*side
  if style=="ShieldBreakerShear" then
   line(r,style,function(u)
    local seam=at+dir*(.48*u*size)
    return seam+lateral*(.12+u*.38)*size+up*.28*size,
     seam+(lateral*(.55+u*.82)-up*.32)*size
   end,.14,r.hot,.045)
  elseif style=="MountainStrikeFault" then
   line(r,style,function(u)
    local seam=at+dir*.4*u*size-up*(.28+.56*u)*size
    return seam+up*.82*size,seam+(lateral*(.65+u*.75)-up*.42)*size
   end,.15,r.color,.055)
  elseif style=="PinningBarb" then
   line(r,style,function(u)
    local tip=at+dir*.22*u*size
    return tip+(-dir*.86+lateral*.48+up*.25)*size,tip
   end,.075,r.hot,.04)
  else
   line(r,style,function(u)
    local split=lateral*(.28+u*.85)+up*(.36+.42*u)+dir*.24
    return at+split*.38*size,at+split*size
   end,.15,r.color,.035)
  end
 end
 if #r.lines==0 then return false end
 r.model:SetAttribute("ContactStyle",style)
 return true
end
local contactStyles={
 [SHIELD_BREAKER]="ShieldBreakerShear",
 ["dwarf.iron_axe.mountain_strike"]="MountainStrikeFault",
 ["elf_pinning_shot"]="PinningBarb",
 ["mage.cryo.shatter_dart"]="ShatterDartSplinters",
}
-- Each edge is expressed as lateral, vertical and forward offsets from the
-- confirmed contact. A pair stays readable when party effects are compact.
local forceContacts={
 ["knight.steel_knight.steel_sweep"]={"SteelSweepContact",Vector3.new(.15,-.37,-.64),Vector3.new(1.24,-.05,-.45),.48,.14,.06,Vector3.new(.66,-.44,-.92)},
 ["dwarf.iron_axe.crag_cleave"]={"CragCleaveContact",Vector3.new(.13,.65,-.47),Vector3.new(.81,-.63,-.69),.16,.16,-.12,Vector3.new(.43,.08,-.83)},
 ["elf.magic_archer.vine_burst"]={"VineBurstContact",Vector3.new(.11,-.73,-.62),Vector3.new(.65,.57,-.75),.12,.12,.17,Vector3.new(.56,-.27,-.81)},
 ["mage.pyro.lava_eruption"]={"LavaEruptionContact",Vector3.new(.16,-.62,-.52),Vector3.new(.42,1.16,-.47),.08,.13,.32,Vector3.new(.43,.36,-.60),key="fire"},
 ["knight.steel_knight.rallying_slash"]={"RallyingSlashContact",Vector3.new(.14,-.38,-.52),Vector3.new(1.15,.64,-.64),.28,.16,.13,Vector3.new(.68,-.12,-.88)},
 ["dwarf.gunner.scatter_shot"]={"ScatterPelletContact",Vector3.new(.12,.02,-.63),Vector3.new(.76,.43,-.46),.17,.10,.04},
 ["elf.marksman.piercing_volley"]={"PiercingVolleyContact",Vector3.new(.26,.12,-1.15),Vector3.new(.11,.02,.48),.42,.082},
 ["mage.pyro.steam_burst"]={"SteamContactJets",Vector3.new(.11,-.50,-.72),Vector3.new(.71,.91,-.62),.09,.16,.24,Vector3.new(.63,.12,-.91)},
 ["knight.steel_knight.challenging_strike"]={"ChallengingStrikeContact",Vector3.new(.17,-.54,-.65),Vector3.new(.98,.30,-.51),.21,.13,.09,Vector3.new(.60,-.06,-.91)},
 ["dwarf.iron_axe.mountain_sweep"]={"MountainSweepContact",Vector3.new(.23,-.68,-.73),Vector3.new(1.43,-.53,-.66),.25,.14,-.05,Vector3.new(.87,-.95,-1.07),key="earth"},
 ["elf.marksman.precision_volley"]={"PrecisionVolleyContact",Vector3.new(.32,.14,-1.42),Vector3.new(.07,.11,.25),.33,.075},
 ["mage.pyro.flame_dart"]={"FlameDartContact",Vector3.new(.11,-.27,-.62),Vector3.new(.55,.77,-.80),.22,.12,.26,Vector3.new(.60,.03,-.77)},
 ["knight.steel_knight.vanguard_strike"]={"VanguardContactFins",Vector3.new(.63,.41,-1.53),Vector3.new(.10,.02,.27),.26,.085,0,Vector3.new(.34,.26,-.39)},
 ["dwarf_braced_throw"]={"BracedThrowContactHooks",Vector3.new(.81,.79,-.95),Vector3.new(.28,-.63,.31),.23,.085,-.20,Vector3.new(1.24,.31,-.65)},
 ["elf.marksman.piercing_line"]={"PiercingLineContactBarbs",Vector3.new(.49,.04,-1.65),Vector3.new(.08,.08,.44),.34,.066,.03,Vector3.new(.19,.04,-.29)},
 ["mage.cryo.lightning_line"]={"LightningLineContactFork",Vector3.new(.14,-.24,-.16),Vector3.new(1.36,1.35,-1.57),.15,.155,.19,Vector3.new(.16,1.29,-.98),
  angular=true,lowerTip=Vector3.new(.94,.10,-1.58),lowerBend=Vector3.new(1.03,-.46,-.80)},
 ["dwarf.iron_axe.stonebound_leap"]={"StoneboundContactRupture",Vector3.new(.14,-.62,.04),Vector3.new(.76,.35,.30),.22},
 ["elf.marksman.fan_break"]={"FanBreakContactSpread",Vector3.new(.16,-.28,-.91),Vector3.new(1.14,.20,.18),.15},
 ["mage.pyro.stone_lance"]={"StoneLanceContactSplinters",Vector3.new(.14,.38,-.97),Vector3.new(.76,-.42,.30),.18},
 ["knight.paladin.oathbreaker_strike"]={"OathbreakerContactCleft",Vector3.new(.09,.77,-.20),Vector3.new(.62,-.57,.26),.13,.085,-.18},
 ["dwarf.gunner.piercing_round"]={"RifleContactWake",Vector3.new(.20,.04,-1.55),Vector3.new(.055,.015,.73),.62,.055},
 ["elf.magic_archer.elemental_pierce"]={"ElementalContactRibbons",Vector3.new(.49,-.28,-1.1),Vector3.new(-.32,.34,.82),.35,.085},
 ["mage.cryo.glacial_spike"]={"GlacialContactShards",Vector3.new(.10,-.39,-.40),Vector3.new(.55,.83,.26),.12,.086,.18},
 ["knight.steel_knight.breaker_charge"]={"BreakerChargeContact",Vector3.new(.24,.27,-.28),Vector3.new(.86,-.12,.36),.46,.085},
 ["dwarf.iron_axe.iron_shoulder"]={"IronShoulderContact",Vector3.new(.12,-.08,-.24),Vector3.new(.48,-.63,.68),.43,.085,-.10},
 ["elf.magic_archer.gliding_shot"]={"GlidingShotContact",Vector3.new(.31,.19,-.83),Vector3.new(.07,.02,.64),.33,.060},
 ["mage.cryo.frost_step"]={"FrostStepContact",Vector3.new(.07,-.43,-.36),Vector3.new(.48,.21,.38),.19,.076,.10},
 ["knight.steel_knight.guardian_counter"]={"GuardianCounterContact",Vector3.new(.12,-.57,-.88),Vector3.new(1.11,.65,-.69),.26,.16,.18,Vector3.new(.91,-.20,-1.13)},
 ["dwarf.iron_axe.tremor_guard"]={"TremorGuardContact",Vector3.new(.12,-.75,-.83),Vector3.new(1.56,-.38,-.62),.23,.15,-.17,Vector3.new(.93,-1.12,-1.02)},
 ["elf.magic_archer.warden_arrow"]={"WardenArrowContact",Vector3.new(1.05,-.58,-1.16),Vector3.new(.08,.49,-.77),.26,.13,.09,Vector3.new(1.12,.07,-1.02)},
 ["mage.cryo.ice_ward"]={"IceWardContact",Vector3.new(.22,-.72,-.92),Vector3.new(.91,.95,-.68),.15,.15,.20,Vector3.new(.89,.08,-1.15)},
 ["knight_guarded_strike"]={"GuardedStrikeContact",Vector3.new(.59,-.44,-.60),Vector3.new(.37,.70,-.54),.24,.13,.08,Vector3.new(.98,.28,-.82)},
 ["dwarf_low_sweep"]={"LowSweepContact",Vector3.new(.13,-.75,-.50),Vector3.new(1.49,-.71,-.34),.31,.12,-.12,Vector3.new(.89,-.93,-.72)},
 ["elf.magic_archer.rooting_fan"]={"RootingFanContact",Vector3.new(1.15,-.82,-.52),Vector3.new(.48,.55,-.73),.13,.12,.16,Vector3.new(.43,-.24,-.91)},
 ["mage.cryo.frost_ring"]={"FrostRingContact",Vector3.new(.21,-.74,-.63),Vector3.new(1.22,.09,-.40),.21,.13,-.06,Vector3.new(.50,-.61,-.74)},
}
-- A cancelled windup scatters two short edges across the incoming face.
-- Class silhouettes retain the difference between blade, axe, arrow and spell.
local interruptContacts={
 knight={"SwordWindupCut",Vector3.new(.14,.56,-.22),Vector3.new(1.17,-.23,-.77),-.27,.23,.16,Vector3.new(.91,.63,-.64)},
 dwarf={"AxeWindupBreak",Vector3.new(.13,.52,-.14),Vector3.new(1.15,-.62,-.64),-.28,.24,-.22,Vector3.new(.46,-.26,-.49),key="earth"},
 elf={"ArrowWindupSplit",Vector3.new(.12,.10,.02),Vector3.new(1.02,.29,-1.42),-.41,.145,.11,Vector3.new(.61,.13,-.77)},
 mage={"SpellWindupDispel",Vector3.new(.13,-.44,-.15),Vector3.new(.86,.67,-.82),-.26,.19,.29,Vector3.new(1.10,-.01,-.48)},
}
local function forceContact(r,at,cf,size,shape,interrupted)
 local name,base,tip,travel,width,lift,bend=unpack(shape)
 local dir,right,up=cf.LookVector,cf.RightVector,cf.UpVector
 local drift=(dir*travel+up*(lift or 0))*size
 for side=-1,1,2 do
  local motion=interrupted and drift+right*(side*.72*size) or drift
  local edgeTip=side==1 and shape.lowerTip or tip
  local edgeBend=side==1 and shape.lowerBend or bend
  local a=at+(right*(base.X*side)+up*base.Y+dir*base.Z)*size
  local b=at+(right*(edgeTip.X*side)+up*edgeTip.Y+dir*edgeTip.Z)*size
  local middle=edgeBend and at+(right*(edgeBend.X*side)+up*edgeBend.Y+dir*edgeBend.Z)*size
  local function path(t,u)
   local progress=u*.20+(1-u*.20)*t
   local point=middle and a:Lerp(middle,progress):Lerp(middle:Lerp(b,progress),progress) or a:Lerp(b,progress)
   return point+motion*(interrupted and 1-(1-u)^3 or u)
  end
  local stroke=line(r,name,function(u)
   return path(0,u),path(1,u)
  end,width or .085,(shape.angular or width and side==-1) and r.color or r.hot,
   shape.angular and .075 or interrupted and .06 or .035,interrupted or shape.angular)
  if stroke and middle then
   stroke.span=function(u)return Style.span(path,0,1,u)end
   local segments=shape.angular and 2 or 4
   stroke.beam.Segments=segments
   if stroke.glow then stroke.glow.Segments=segments end
  end
  if stroke and not r.compact and name=="GlacialContactShards" then
   local start=#r.faces
   local baseWidth=right*.17*size
   Surfaces.triangle(r,"GlacialContactFacet",a-baseWidth,a+baseWidth,b,r.color,.27,Enum.Material.Ice)
   Surfaces.animate(r,start,a,dir,0,true,.14)
  end
 end
 if #r.lines==0 then return false end
 r.model:SetAttribute("ContactStyle",name)
 return true
end
local function contactStroke(r,name,path,width,color,duration)
 local stroke=line(r,name,function(u)return path(math.min(1,u*r.life/duration))end,width,color,width*.27,true)
 if stroke then stroke.fadeDuration=duration end
 return stroke
end

local function curvedContactStroke(r,name,path,width,color,duration)
 local stroke=contactStroke(r,name,function(t)return path(0,t),path(1,t)end,width,color,duration)
 if stroke then
  stroke.span=function(u)return Style.span(path,0,1,math.min(1,u*r.life/duration))end
  stroke.beam.Segments=4
  stroke.beam.LightEmission=.65
 end
end

local function fluidContact(r,at,cf,size)
 local water=r.key=="water"
 local right,up,dir=cf.RightVector,cf.UpVector,cf.LookVector
 local start=#r.lines
 for side=-1,1,2 do
  local lateral=right*side
  if water then
   curvedContactStroke(r,"WaterContact",function(along,t)
    local push=1-(1-t)^3
    local root=lateral*(.09+.31*push)-dir*.12
    local tip=lateral*(1.04+.65*push)+up*(.21+push*.62-t*t*.52)+dir*.22
    return at+(root:Lerp(tip,along)+up*(math.sin(along*math.pi)*(.35+push*.27)))*size
   end,.36*size,side==1 and r.color:Lerp(r.hot,.35) or r.color,.17)
  else
   curvedContactStroke(r,"GravityContact",function(along,t)
    local pull=1-t*t
    local outside=lateral*(.16+pull*1.06)-up*.46*side*pull-dir*.28
    local center=lateral*(.02+pull*.15)+up*.21*side*pull-dir*.14
    local turn=(lateral*.38+up*.57*side)*math.sin(along*math.pi)*pull
    return at+(outside:Lerp(center,along)+turn)*size
   end,.31*size,r.color,.15)
  end
 end
 if water and not r.compact then
  for i,offset in ipairs({-1,0,1})do
   local drift=(right*offset*1.42+dir*.34+up*(offset==0 and 1.6 or .85))*size
   local atBase=at-dir*.20*size+drift*.40
   local p=Surfaces.volume(r,"WaterContactDrop",atBase,Vector3.new(.22,.43,.22)*size,r.color:Lerp(r.hot,i==2 and .65 or .36),.10,"ball",Enum.Material.Neon)
   if p then
    local face=r.faces[#r.faces]
    face.cf=CFrame.lookAt(atBase,atBase+drift)*CFrame.Angles(math.pi/2,0,0)
    face.drift=drift*1.4;face.fadeDuration=.22
   end
  end
 end
 return #r.lines>start
end

local function elementalContact(r,at,cf,size)
 local up,right,dir=cf.UpVector,cf.RightVector,cf.LookVector
 local key=r.key
 if key=="lightning" then
  local function fork(t,u)
   local side=(math.floor(t*4+.5)%2==1 and .38 or -.2)*math.sin(t*math.pi)
   return at+(right*side+up*(t-.2)+dir*(t*.55+u*.8))*size
  end
  for i=0,2 do
   line(r,"LightningContactFork",function(u)return fork(i/3,u),fork((i+1)/3,u)end,.08,r.hot)
  end
  return
 end
 local count=r.compact and 2 or 4
 for i=1,count do
  local side=(i-(count+1)*.5)
  local offset=right*side*.43
  local bright=i==math.ceil(count/2) and r.hot or r.color
  if key=="fire"or key=="bomb"then
   local lift=up*(1.26-.31*math.abs(side))+dir*.46+offset
   contactStroke(r,"HeatContactRise",function(t)
    local push=1-(1-t)^2
    return at+lift*(.09+push*.42)*size,at+(lift*(.65+push*.73)+up*t*.31)*size
   end,.18*size,bright,.19)
  elseif key=="frost"or key=="earth"then
   local frost=key=="frost"
   local spread=offset*1.6+up*(frost and .95-.34*math.abs(side) or -.29-.17*math.abs(side))+dir*.45
   contactStroke(r,frost and "FrostContactFacet" or "EarthContactFracture",function(t)
    local push=1-(1-t)^2
    return at+spread*(.08+.63*push)*size,at+spread*(.68+.58*push)*size
   end,(frost and .16 or .23)*size,bright,frost and .15 or .18)
  else
   local spread=offset+(up*.24+dir*.68)*(i%2==0 and 1 or -1)
   line(r,"ContactSplinter",function(u)return at+spread*u*.6*size,at+spread*(.62+u)*size end,.065,r.hot)
  end
 end
end
-- Mark strokes work in the confirmed hit's right/up/forward frame.
-- Two strokes replace the generic contact, including on compact clients.
local markContacts={
 oath={name="OathSealBreak",key="holy",from=Vector3.new(.11,.70,-.13),bend=Vector3.new(1.32,.54,0),to=Vector3.new(.48,-.54,-.05),drift=Vector3.new(.76,.25,-.22)},
 fracture={name="ArmorFaultBreak",key="earth",from=Vector3.new(.13,-.54,-.02),bend=Vector3.new(.47,.37,-.31),to=Vector3.new(.96,.27,.13),drift=Vector3.new(.83,-.22,-.17)},
 weakpoint={name="WeakpointBracketBreak",key="arrow",from=Vector3.new(.44,-.57,-.19),bend=Vector3.new(1.15,.01,-.34),to=Vector3.new(.44,.57,-.19),drift=Vector3.new(.88,0,-.16)},
 nature={name="NatureBudBreak",key="nature",from=Vector3.new(.06,-.53,-.01),bend=Vector3.new(.18,.48,-.44),to=Vector3.new(.89,.56,-.23),drift=Vector3.new(.51,.45,-.23)},
 ember={name="EmberVentBreak",key="fire",from=Vector3.new(.28,-.42,-.11),bend=Vector3.new(.89,.25,-.40),to=Vector3.new(.22,1.09,-.18),drift=Vector3.new(.52,.75,-.20)},
 frost={name="FrostSealBreak",key="frost",from=Vector3.new(.05,.43,-.08),bend=Vector3.new(.72,.42,-.31),to=Vector3.new(.98,-.55,-.12),drift=Vector3.new(.88,-.47,-.19)},
}
local markGrants={
 oath={name="OathSealSet",from=Vector3.new(.08,.81,0),bend=Vector3.new(.98,.10,-.13),to=Vector3.new(.06,-.72,0),drift=Vector3.new(.52,.12,-.25)},
 fracture={name="ArmorFaultSet",from=Vector3.new(.12,.82,0),bend=Vector3.new(.05,-.40,-.09),to=Vector3.new(.63,-.37,0),drift=Vector3.new(.33,.31,-.22)},
 weakpoint={name="WeakpointBracketSet",from=Vector3.new(.20,-.52,0),bend=Vector3.new(.96,0,-.10),to=Vector3.new(.20,.52,0),drift=Vector3.new(.78,0,-.18)},
 nature={name="NatureBudSet",from=Vector3.new(.08,-.58,0),bend=Vector3.new(.91,-.28,-.17),to=Vector3.new(.44,.59,0),drift=Vector3.new(.57,.19,-.22)},
 ember={name="EmberSealSet",from=Vector3.new(.06,-.53,0),bend=Vector3.new(.91,-.05,-.13),to=Vector3.new(.19,.91,0),drift=Vector3.new(.49,-.22,-.24)},
 frost={name="FrostSealSet",from=Vector3.new(.07,-.38,0),bend=Vector3.new(.99,-.38,-.12),to=Vector3.new(.33,.61,0),drift=Vector3.new(.63,.23,-.18)},
}
local function markContact(r,at,cf,size,mark,grant)
 local function offset(point,side)
  return (cf.RightVector*(point.X*side)+cf.UpVector*point.Y+cf.LookVector*point.Z)*size
 end
 for side=-1,1,2 do
  local a=at+offset(mark.from,side)
  local bend=at+offset(mark.bend,side)
  local b=at+offset(mark.to,side)
  local drift=offset(mark.drift,side)
  local function path(t,u)
   local trim=grant and 0 or u*.22
   local progress=trim+(1-trim)*t
   local travel=grant and (1-u)^3 or 1-(1-u)^3
   return a:Lerp(bend,progress):Lerp(bend:Lerp(b,progress),progress)+drift*travel
  end
  local stroke=line(r,mark.name,function(u)return path(0,u),path(1,u)end,
   r.compact and .128 or .19,side==1 and r.hot or r.color,.055,true)
  if stroke then
   stroke.span=function(u)return Style.span(path,0,1,u)end
   stroke.beam.Segments=5
  end
 end
 if #r.lines==0 then return false end
 r.model:SetAttribute("ContactStyle",mark.name)
 return true
end
-- Both halves open from the contact plane. The angle of the break follows
-- the weapon, while the outward movement identifies the posture transition.
local postureCuts={
 knight={Vector3.new(.11,.60,0),Vector3.new(.78,.64,0),Vector3.new(.80,-.56,.06),.58},
 dwarf={Vector3.new(.08,.81,0),Vector3.new(.28,-.06,0),Vector3.new(1.00,-.62,.12),.79},
 elf={Vector3.new(.08,.19,.18),Vector3.new(.57,.31,-.42),Vector3.new(1.24,.02,-.92),.62},
 mage={Vector3.new(.15,-.62,0),Vector3.new(.87,-.33,-.20),Vector3.new(.95,.78,.02),.66},
}
local function postureContact(r,at,cf,size,classId)
 local cut=postureCuts[classId]
 local right=cf.RightVector
 local camera=workspace.CurrentCamera
 if camera then
  local view=camera.CFrame.Position-at
  local horizontal=Vector3.new(view.X,0,view.Z)
  if horizontal.Magnitude>.01 then
   local normal=horizontal.Unit
   right=Vector3.yAxis:Cross(normal)
   at+=normal*.40
  end
 end
 at+=Vector3.yAxis*.32
 for side=-1,1,2 do
  local function world(point)
   return (right*(side*point.X)+cf.UpVector*point.Y+cf.LookVector*point.Z)*size
  end
  local a,b,c=world(cut[1]),world(cut[2]),world(cut[3])
  local drift=world(Vector3.new(cut[4],-.20,-.25))
  local function path(t,u)
   local point=a:Lerp(b,t):Lerp(b:Lerp(c,t),t)
   return at+point+drift*(1-(1-u)^3)
  end
  local stroke=line(r,"PostureBreakEdge",function(u)return path(0,u),path(1,u)end,
   r.compact and .155 or .22,r.color:Lerp(r.hot,.56),.055,true)
  if stroke then
   stroke.span=function(u)return Style.span(path,0,1,u)end
   stroke.beam.Segments=5
  end
 end
 r.model:SetAttribute("PostureBroken",true)
 r.model:SetAttribute("ContactStyle","PostureBreak")
end
function FX.contact(at,classId,id,direction,scale,compact,consumedMark,appliedMark,postureBroken,windupInterrupted)
 local row=Catalog.get(classId,id);if not row or not vector(at)then return end
 local d=row.definition
 local mark=d and consumedMark and consumedMark==d.consume and markContacts[consumedMark]
 local grant=d and appliedMark and appliedMark==d.mark and markGrants[appliedMark]
 local seal=mark or grant
 local interrupt=d and windupInterrupted and not postureBroken and not seal and interruptContacts[classId]
 local force=interrupt or forceContacts[id]
 local key=mark and mark.key or grant and markContacts[appliedMark].key or force and force.key or row.key
 local life=postureBroken and (compact and .20 or .26) or seal and (compact and .16 or .22)
  or interrupt and .19 or (compact and .16 or .3)
 local fluid=row.key=="water" or row.key=="gravity"
 local reserve=postureBroken and (seal and 4 or 2) or (seal or force or fluid) and 2
 local r=make(at,at,life,key,id,compact,true,reserve)
 if not r and postureBroken and seal then
  r=make(at,at,life,key,id,compact,true,2)
  seal=nil
 end
 if not r then return end
 r.color,r.hot=Palette.get(key,row.classId)
 local dir=vector(direction)and forward(Vector3.zero,direction)or Vector3.new(0,0,-1)
 local cf=CFrame.lookAt(at,at+dir);local size=math.clamp(scale or 1,.4,2)
 if postureBroken then
  local breakSize=math.clamp(size,.7,1.35)
  postureContact(r,at-dir*.36,cf,breakSize,classId)
  if seal then markContact(r,at-dir*.37+Vector3.yAxis*.16,cf,breakSize*.78,seal,not mark) end
  FX.step(r.at)
  return r.model,true
 end
 if seal then
  local drawn=markContact(r,at-dir*.37,cf,math.clamp(size,.7,1.35),seal,not mark)
  FX.step(r.at)
  return r.model,drawn
 end
 if interrupt then
  local height=classId=="knight" and .62 or .29
  local drawn=forceContact(r,at-dir*.25+Vector3.yAxis*height,cf,math.clamp(size,.8,1.35),interrupt,true)
  FX.step(r.at)
  return r.model,drawn
 end
 local profile=Profiles.get(id)
 if profile then size*=math.clamp(profile.width/.18,.65,1.6)end
 local physical=row.key=='steel'or row.key=='axe'or row.key=='arrow'or row.key=='gun'or row.key=='shield'
 local piercing=row.key=='arrow' or row.key=='gun' or d and Presentation.get(d).motion=='thrust'
 local descending=d and FX.groundLead(d)
 local authored=contactStyles[id]
 local distinctContact
 local weaponStar
 local verdict=id==SHIELD_VERDICT
 if descending then
  descendingContact(r,at,cf,size,profile.shape)
 elseif authored then
  distinctContact=skillContact(r,at,cf,size,authored)
 elseif force then
  distinctContact=forceContact(r,at,cf,size,force)
 elseif verdict then
  for side=-1,1,2 do
   local lateral=cf.RightVector*side
   local outward=(lateral*.85+cf.UpVector*.72)*size
   line(r,"VerdictContactRay",function(u)
    local center=at+dir*(u*.75)
    return center+outward*(.15+u*.5),center+outward*(.78+u*.95)
   end,.14,r.hot)
  end
 elseif physical and compact then
  local axis=piercing and dir or classId=="dwarf" and cf.UpVector or cf.RightVector+cf.UpVector*.35
  for side=-1,1,2 do
   line(r,"AllyWeaponContact",function(u)
    local shift=cf.RightVector*side*.14*size+dir*u*.5
    return at+shift-axis*.4*size,at+shift+axis*(.35+u*.6)*size
   end,.085,r.hot)
  end
 elseif physical then
  weaponStar=impactStar(r,at,dir,size,classId,piercing)
  if classId=='knight' and not piercing then
   for side=-1,1,2 do line(r,'PhysicalCutContact',function(u)local shift=dir*u*.35;return at+shift-cf.RightVector*side*.75*size-cf.UpVector*.25*size,at+shift+cf.RightVector*side*.5*size+cf.UpVector*.35*size end,.08,r.color)end
  elseif classId=='dwarf'and(row.key=='steel'or row.key=='axe')then
   line(r,'AxeCutContact',function(u)return at+cf.UpVector*(.9-u*.5)*size,at-cf.UpVector*(.6+u*.4)*size+dir*u*.3 end,.15,r.color)
   if id==ARMOR_SPLITTER then
    for side=-1,1,2 do
     line(r,"ArmorSplitFracture",function(u)
      local seam=at-cf.UpVector*(.12+u*.31)*size
      return seam,seam+(cf.RightVector*side*(.32+u*.6)-cf.UpVector*.33)*size
     end,.11,r.hot)
    end
   end
   debris(r,at,3,'RockChip',size*.65)
  else
   for side=-1,1,2 do line(r,'PiercingContactWake',function(u)local offset=cf.RightVector*side*.12*size;return at-dir*(.8-u*.3)*size+offset,at+dir*(.25+u*.65)*size+offset end,.055,r.color)end
  end
 elseif fluid then
  distinctContact=fluidContact(r,at,cf,size)
  if distinctContact then r.model:SetAttribute("ContactStyle",row.key=="water" and "WaterSplash" or "GravityCollapse") end
 elseif row.key=='arcane'then
  for i=1,4 do local a=i*math.pi*.5;local offset=(cf.RightVector*math.cos(a)+cf.UpVector*math.sin(a))*size
   line(r,'ArcaneContactRay',function(u)return at+offset*(.12+u*.35),at+offset*(.45+u*.6)end,.055,r.color)
  end
 else
  elementalContact(r,at,cf,size)
 end
 if not compact and not force and (row.key=="frost"or row.key=="earth"or row.key=="fire"or row.key=="bomb")then
  debris(r,at,3,row.key=="frost"and"IceShard"or row.key=="earth"and"RockChip"or"Ember",size)
 end
 if not weaponStar and (not force or not distinctContact) then
  local flash=Surfaces.volume(r,"ContactVolume",at,Vector3.one*(distinctContact and .38 or .65)*size,r.hot,.25,"ball")
  if flash then r.faces[#r.faces].fadeDuration=.08 end
 end
 -- Only confirmed hit events reach this entry point. A short open pressure
 -- crown replaces a lingering generic sphere; water retains its own ripple.
 if not compact and not descending and not physical and not authored and not force and not verdict and not fluid and row.key~='arcane'and row.key~="frost"and row.key~="earth"then
  local start=#r.faces
  local basis=CFrame.lookAt(at,at+dir)*CFrame.Angles(math.pi/2,0,0)
  Surfaces.arc(r,"ContactPressure",at,1.35*size,.28*size,r.color,.32,basis,280)
  Surfaces.animate(r,start,at,dir,.35,true,.23)
 end
 -- Physical hits use the sharp star as their focal point. Repeating the
 -- soft elemental halo here washed out the silhouette during rapid combos.
 if not physical and not descending and not authored and not force and not distinctContact then flourish(r,at,1.5*size,row.key,false)end
 FX.step(r.at);return r.model,distinctContact
end
return FX
