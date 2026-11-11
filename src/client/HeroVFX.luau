-- Procedural, client-only embellishment for confirmed combat presentation.
-- Existing geometry retains range information when this optional layer is culled.
local RS=game:GetService("ReplicatedStorage")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local Catalog=require(RS.Shared.PixelFXCatalog)
local Geometry=require(script.Parent.SkillEffectGeometry)
local Presentation=require(RS.Shared.SkillPresentation)
local FX={}
local active={}
local connection
local beams=0
local chips=0
local WHITE=Color3.fromRGB(248,248,229)
local palette={steel=Color3.fromRGB(163,210,244),axe=Color3.fromRGB(243,172,89),shield=Color3.fromRGB(102,211,255),holy=Color3.fromRGB(255,220,116),arrow=Color3.fromRGB(192,232,170),nature=Color3.fromRGB(93,219,135),arcane=Color3.fromRGB(181,139,255),gravity=Color3.fromRGB(144,83,226),wind=Color3.fromRGB(173,249,225),water=Color3.fromRGB(81,186,249),fire=Color3.fromRGB(255,112,45),earth=Color3.fromRGB(176,136,91),frost=Color3.fromRGB(142,231,255),lightning=Color3.fromRGB(214,197,255),gun=Color3.fromRGB(255,215,133),bomb=Color3.fromRGB(255,144,66)}
local function finite(n)return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function vector(v)return typeof(v)=="Vector3" and finite(v.X)and finite(v.Y)and finite(v.Z)and math.abs(v.X)<1e7 and math.abs(v.Y)<1e7 and math.abs(v.Z)<1e7 end
local function erase(i)
 local r=table.remove(active,i);beams-=#r.lines;chips-=#r.chips;r.model:Destroy()
end
function FX.clear()
 for i=#active,1,-1 do erase(i)end
 if connection then connection:Disconnect();connection=nil end
end
function FX.count()return #active,beams,chips end
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
 local r={model=m,carrier=carrier,at=workspace:GetServerTimeNow(),life=life,lines={},chips={},color=palette[key]or palette.steel}
 table.insert(active,r)
 if not connection and Run:IsClient()then connection=Run.RenderStepped:Connect(function()FX.step(workspace:GetServerTimeNow())end)end
 return r
end
local function line(r,name,path,width,color)
 if beams>=(Input.TouchEnabled and 144 or 240)then return end
 local a=Instance.new("Attachment");a.Parent=r.carrier
 local b=Instance.new("Attachment");b.Parent=r.carrier
 local beam=Instance.new("Beam");beam.Name=name;beam.Attachment0=a;beam.Attachment1=b;beam.FaceCamera=true;beam.Segments=1
 beam.Width0=width;beam.Width1=width*.45;beam.Color=ColorSequence.new(color or r.color,WHITE)
 beam.LightEmission=.65;beam.LightInfluence=.2;beam.Transparency=NumberSequence.new(.18);beam.Parent=r.carrier
 table.insert(r.lines,{a=a,b=b,beam=beam,path=path,width=width});beams+=1
end
local function curve(r,name,path,count,width,color)
 for i=1,count do
  local from,to=(i-1)/count,i/count
  line(r,name,function(u)return path(from,u),path(to,u)end,width*(.4+.6*math.sin((i-.5)/count*math.pi)),color)
 end
end
local function ring(r,name,center,radius,width,vertical,inward,color)
 curve(r,name,function(t,u)
  local angle=t*math.pi*2+u*.7;local size=radius*(inward and(1-u*.8)or(.22+.78*(1-(1-u)^3)))
  local offset=vertical and Vector3.new(math.cos(angle)*size,math.sin(angle)*size,0)or Vector3.new(math.cos(angle)*size,0,math.sin(angle)*size)
  return center+offset
 end,12,width,color)
end
local function debris(r,center,count,kind,scale)
 for i=1,count do
  if chips>=48 then break end
  local p=Instance.new("Part");p.Name=kind;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
  p.Material=kind=="IceShard" and Enum.Material.Ice or kind=="RockChip" and Enum.Material.Slate or Enum.Material.Neon
  p.Color=r.color;p.Size=(kind=="IceShard" and Vector3.new(.18,.7,.18)or Vector3.one*.18)*scale
  p.CFrame=CFrame.new(center);p.Parent=r.model
  local angle=i*2.39996;local offset=Vector3.new(math.cos(angle),.5+i%3*.2,math.sin(angle))*scale
  table.insert(r.chips,{part=p,center=center,offset=offset,size=p.Size,spin=angle});chips+=1
 end
end
function FX.step(now)
 if not finite(now)then return end
 for i=#active,1,-1 do
  local r=active[i];local u=math.clamp((now-r.at)/r.life,0,1)
  if not r.model.Parent or now-r.at>=r.life then erase(i)
  else
   local fade=math.clamp((u-.12)/.88,0,1)
   local bucket=math.floor(fade*24)
   local changed=r.fadeBucket~=bucket
   if changed then r.fadeBucket=bucket;r.alpha=NumberSequence.new(.18+fade*.82)end
   for _,s in ipairs(r.lines)do
    local a,b=s.path(u);s.a.WorldPosition=a;s.b.WorldPosition=b
    s.beam.Width0=s.width*(1-fade*.7);s.beam.Width1=s.beam.Width0*.45
    if changed then s.beam.Transparency=r.alpha end
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
function FX.skill(character,id,first,last,pulse)
 local row=Catalog.byId[id]
 if not row or not vector(first)or not vector(last)or not finite(pulse)or pulse<1 then return end
 local d=row.definition;local key=row.key;local effect=row.effect
 local motion=Presentation.get(d).motion
 local r=make(first,last,d.ultimate and .8 or .52,key,id);if not r then return end
 local dir=forward(first,last);local flat=Vector3.new(dir.X,0,dir.Z)
 flat=flat.Magnitude>.01 and flat.Unit or Vector3.new(0,0,-1)
 local right=Vector3.new(-flat.Z,0,flat.X)
 local area=d.form=="ground"or d.form=="area"or d.detonate or d.areaRadius~=nil
 local center=d.form=="area" and first or last
 local floor=floorAt(area and center or first,character)
 local radius=math.min(d.areaRadius or(d.form=="ground"or d.detonate)and d.radius or d.range or 5,20)
 local angle=d.angle or 80
 local strength=d.ultimate and 1.5 or d.stage and(1+d.stage*.08)or 1
 if effect=="slash" and motion=="thrust"then
  line(r,"ThrustEdge",function(u)return first+dir*u*math.min(2,(last-first).Magnitude),last end,.2,WHITE)
  for side=-1,1,2 do
   line(r,"ThrustPressure",function(u)return first+right*side*.5+dir*u,last+right*side*.12 end,.07)
  end
 elseif effect=="slash" and motion=="chop"then
  curve(r,"DescendingCleave",function(t,u)
   local a=t*math.pi*.8
   return first+flat*(math.sin(a)*math.min(radius,5)) + Vector3.yAxis*(math.cos(a)*2.6-u*.6)
  end,12,.27*strength)
 elseif effect=="slash"then
  local path=Geometry.sector(first,flat,math.min(radius,8)*.8,angle,12)
  for i=1,#path-1 do
   local a,b=path[i],path[i+1]
   line(r,"BladeRibbon",function(u)
    local rise=Vector3.yAxis*(math.sin((i/12)*math.pi)*.55+u*.25)
    return a+rise,b+rise
   end,.24*strength*(.3+.7*math.sin(i/13*math.pi)))
  end
  if d.form=="line"then line(r,"ThrustEdge",function(u)return first+dir*u*2,last end,.18,WHITE)end
 elseif effect=="shield"or effect=="taunt"then
  local at=effect=="taunt" and floor or first+flat*2
  ring(r,effect=="taunt"and"WarcryWave"or"GuardHalo",at,math.min(radius,6),.18,effect~="taunt",false)
  if effect=="shield"then
   for side=-1,1,2 do line(r,"GuardChevron",function(u)return at+right*side*(1+u),at+Vector3.yAxis*1.7+flat*u end,.16,WHITE)end
  end
 elseif effect=="arrow"or effect=="rain"or effect=="axe"or effect=="bullet"then
  if effect=="rain"then
   for i=1,5 do
    local a=i*2.39996;local target=floor+Vector3.new(math.cos(a),0,math.sin(a))*radius*math.sqrt(i/6)
    line(r,"RainFeather",function(u)local p=target+Vector3.yAxis*(8*(1-u));return p+Vector3.yAxis*1.2,p end,.09)
   end
  elseif effect=="axe"then
   ring(r,"AxeAirCut",last,1.2,.12,true,false)
  else
   -- Double taper and fletching distinguish precision shots from thick magic beams.
   line(r,effect=="bullet"and"MuzzleStreak"or"PiercingWake",function(u)return first+dir*math.min((last-first).Magnitude,u*5),last end,effect=="bullet"and .055 or .10)
   if d.form=="line"then ring(r,"PressureHalo",first+dir*2,.55,.08,true,false)end
  end
 elseif effect=="earth"or effect=="lava"or effect=="bomb"or effect=="shell"then
  ring(r,"GroundPressure",floor,radius,.15,false,false)
  debris(r,floor,6,effect=="earth"and"RockChip"or"Ember",strength*1.6)
  if effect=="earth"or effect=="lava"then
   for i=1,3 do
    local heading=CFrame.Angles(0,math.rad((i-2)*30),0):VectorToWorldSpace(flat)
    curve(r,"GroundFissure",function(t,u)return floor+heading*radius*t+right*(math.sin(t*19+i)*.25)+Vector3.yAxis*.03*u end,5,.12,effect=="lava"and palette.fire or palette.axe)
   end
  else
   ring(r,"BlastFront",center,math.min(radius,5),.22,true,false,WHITE)
  end
 elseif effect=="frost"or effect=="hail"then
  if area then ring(r,"FrostBloom",floor,radius,.12,false,false)end
  debris(r,area and floor or last,7,"IceShard",strength*1.7)
  if not area then line(r,"IceNeedle",function(u)return first+dir*u*2,last end,.20,WHITE)end
 elseif effect=="lightning"then
  local points=Geometry.lightning(area and center+Vector3.yAxis*10 or first,last,7)
  for i=1,#points-1 do
   local a,b=points[i],points[i+1]
   line(r,"ElectricCore",function()return a,b end,.12,WHITE)
   if i%2==0 then line(r,"ElectricBranch",function(u)return a,a+(b-a)*.4+right*(1-u)*1.5+Vector3.yAxis*.6 end,.06)end
  end
 elseif effect=="vine"then
  for lane=1,3 do
   curve(r,"RootHelix",function(t,u)
    local a=t*math.pi*2+lane*math.pi*2/3+u
    return floor+Vector3.new(math.cos(a)*radius*.5,t*3*(1-u*.4),math.sin(a)*radius*.5)
   end,7,.15)
  end
 elseif effect=="gravity"then
  for lane=1,2 do
   curve(r,"GravityInfall",function(t,u)
    local a=t*math.pi*3+lane*math.pi+u*3;local rad=radius*(1-t)*(.8-u*.6)
    return floor+Vector3.new(math.cos(a)*rad,.3+t*1.6,math.sin(a)*rad)
   end,10,.14)
  end
 elseif effect=="water"or effect=="steam"then
  ring(r,"TidalLip",area and floor or last,area and radius or 1.8,.25,false,false)
  debris(r,area and floor or last,6,"WaterSpray",strength)
  if effect=="steam"then
   for lane=1,2 do curve(r,"SteamCurl",function(t,u)local a=t*5+lane*math.pi;return floor+Vector3.new(math.cos(a)*(.4+u),t*3+u,math.sin(a)*(.4+u))end,6,.2,WHITE)end
  end
 elseif effect=="fire"or effect=="ash"or effect=="holy"or effect=="arcane"then
  if area or d.form=="self"then
   ring(r,effect=="holy"and"DawnSeal"or"ElementalCrown",floor,math.min(radius,8),.17,false,false)
  end
  for lane=1,2 do
   curve(r,effect=="fire"and"FlameTongue"or effect=="holy"and"SunRay"or"ArcaneHelix",function(t,u)
    local a=t*math.pi*3+lane*math.pi+u*4
    if area or d.form=="self"then return floor+Vector3.new(math.cos(a)*radius*.4,t*3+u*.6,math.sin(a)*radius*.4)end
    local axis=forward(first,last);local cf=CFrame.lookAt(first,first+axis)
    return first+(last-first)*t+cf.RightVector*math.cos(a)*.35+cf.UpVector*math.sin(a)*.35
   end,9,.15*strength)
  end
  if effect=="fire"or effect=="ash"then debris(r,center,4,"Ember",strength)end
 end
 if effect=="arrow" and key~="arrow" then
  local cf=CFrame.lookAt(first,first+dir)
  curve(r,"EnchantedArrowFilament",function(t,u)
   local a=t*math.pi*5+u*8
   return first+(last-first)*t+cf.RightVector*math.cos(a)*.22+cf.UpVector*math.sin(a)*.22
  end,8,.065)
 end
 FX.step(r.at)
 return r.model
end
function FX.contact(at,classId,id,direction,scale)
 local row=Catalog.get(classId,id);if not row or not vector(at)then return end
 local r=make(at,at,.3,row.key,id);if not r then return end
 local dir=vector(direction)and forward(Vector3.zero,direction)or Vector3.new(0,0,-1)
 local cf=CFrame.lookAt(at,at+dir);local size=math.clamp(scale or 1,.4,2)
 if row.key=="water"or row.key=="gravity"then
  ring(r,row.key=="water"and"WaterContact"or"GravityContact",at,1.3*size,.12,true,row.key=="gravity")
 else
  for i=1,5 do
   local angle=i*2.39996;local offset=(cf.RightVector*math.cos(angle)+cf.UpVector*math.sin(angle))*size
   line(r,"ContactSplinter",function(u)return at+offset*(.15+u*.7),at+offset*(.4+u*1.5)end,classId=="dwarf"and .12 or .065,i%2==0 and WHITE or r.color)
  end
 end
 if row.key=="frost"or row.key=="earth"or row.key=="fire"or row.key=="bomb"then
  debris(r,at,3,row.key=="frost"and"IceShard"or row.key=="earth"and"RockChip"or"Ember",size)
 end
 FX.step(r.at);return r.model
end
return FX
