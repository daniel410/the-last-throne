-- Local air ribbons for server-confirmed Wind Lance. No damage, physics or remotes.
local Run=game:GetService('RunService')
local Debris=game:GetService('Debris')
local Surfaces=require(script.Parent.HeroVFXSurfaces)
local Wind={}
local active={};local seen=setmetatable({},{__mode='k'});local connection
local WHITE=Color3.fromRGB(230,255,247)
local MINT=Color3.fromRGB(142,244,210)
local LIFE=.48
local function finite(n)return type(n)=='number' and n==n and math.abs(n)<math.huge end
local function vector(v)return typeof(v)=='Vector3' and finite(v.X)and finite(v.Y)and finite(v.Z)and math.abs(v.X)<1e7 and math.abs(v.Y)<1e7 and math.abs(v.Z)<1e7 end
local function tip(character,fallback)
 if character then
  for _,model in character:GetChildren()do
   if model:IsA('Model') and model:GetAttribute('WeaponClassId')=='mage' then
    local grip=model:FindFirstChild('WeaponGrip');local a=grip and grip:FindFirstChild('WeaponTip')
    if a and a:IsA('Attachment') and (a.WorldPosition-fallback).Magnitude<=8 then return a.WorldPosition end
   end
  end
 end
 return fallback
end
local function ribbon(s,name,count,width,color)
 width*=1.35
 local r={points={},beams={},width=width};table.insert(s.ribbons,r)
 for i=1,count+1 do
  local a=Instance.new('Attachment');a.Name=name..i;a.Parent=s.carrier;table.insert(r.points,a)
  if i>1 then
   local b=Instance.new('Beam');b.Name=name;b.Attachment0=r.points[i-1];b.Attachment1=a;b.FaceCamera=true
   b.Color=ColorSequence.new(color);b.LightEmission=1;b.LightInfluence=0;b.Segments=1
   b.Width0=width;b.Width1=width;b.Transparency=NumberSequence.new(.2);b.Parent=s.carrier;table.insert(r.beams,b)
  end
 end
 return r
end
local function fade(r,alpha,scale)
 for i,b in r.beams do
  local taper=math.sin((i-.5)/#r.beams*math.pi)
  b.Width0=r.width*scale*(.2+.8*taper);b.Width1=b.Width0
  b.Transparency=NumberSequence.new(math.clamp(alpha,0,1))
 end
end
local function remove(i)if active[i].surface then Surfaces.release(active[i].surface)end;active[i].folder:Destroy();table.remove(active,i)end
function Wind.clear()
 for i=#active,1,-1 do remove(i)end
 if connection then connection:Disconnect();connection=nil end
end
function Wind.step(now)
 for i=#active,1,-1 do
  local s=active[i];local age=now-s.at
  local missing=s.character and (not s.character.Parent or s.character:GetAttribute('TLTDeathFalling') or s.character:GetAttribute('TLTEquippedWeapon')=='')
  local casting=s.character and s.character:GetAttribute('K0State')=='Attack' and s.character:GetAttribute('K0SkillId')=='mage_wind_lance'
  if casting then s.observedCast=true end
  -- A confirmed RemoteEvent can arrive before replicated action attributes.
  local interrupted=s.stage=='Charge' and s.character and (s.observedCast or age>.08) and not casting
  if not s.folder.Parent or age>s.life or missing or interrupted then remove(i)
  else
   local u=math.clamp(age/s.life,0,1)
   if s.surface then Surfaces.step(s.surface,u,u)end
   if s.stage=='Charge'then
    s.carrier.CFrame=CFrame.lookAt(tip(s.character,s.origin),s.center)
    for lane,r in s.spirals do
     for j,a in r.points do
      local t=(j-1)/(#r.points-1);local angle=t*math.pi*1.6+lane*math.pi*2/3+u*7
      local radius=(.75-u*.5)*(1-t*.4)
      a.Position=Vector3.new(math.cos(angle)*radius,math.sin(angle)*radius,-t*.7)
     end
     fade(r,.25+u*.15,.7+u*.6)
    end
   else
    local length=s.length;local fadeOut=math.clamp((u-.25)/.75,0,1)
    for lane,r in s.spirals do
     for j,a in r.points do
      local t=(j-1)/(#r.points-1);local angle=t*math.pi*4+lane*math.pi*2/3-age*19
      local radius=(.22+.65*math.sin(t*math.pi))*(1-u*.45)
      a.Position=Vector3.new(math.cos(angle)*radius,math.sin(angle)*radius,-length*t)
     end
     fade(r,.22+fadeOut*.78,1-fadeOut*.65)
    end
    s.core.points[1].Position=Vector3.zero;s.core.points[2].Position=Vector3.new(0,0,-length)
    fade(s.core,.25+math.clamp(age/.14,0,1)*.75,1)
    for lane,r in s.head do
     r.points[1].Position=Vector3.new((lane==1 and -1 or 1)*.65,0,-math.max(0,length-2.2))
     r.points[2].Position=Vector3.new(0,0,-length)
     fade(r,.12+fadeOut*.88,1-fadeOut*.7)
    end
    for _,impact in s.impacts do
     local r=impact.ribbon;local radius=.35+u*1.5
     for j,a in r.points do
      local angle=(j-1)/(#r.points-1)*math.pi*1.65+age*11
      a.Position=impact.localPoint+Vector3.new(math.cos(angle)*radius,math.sin(angle)*radius,0)
     end
     fade(r,.2+u*.8,1-u*.65)
    end
   end
  end
 end
 if #active==0 and connection then connection:Disconnect();connection=nil end
end
function Wind.play(character,origin,center,pulse,points,sequence,firedAt,startedAt,windup,now)
 now=now or workspace:GetServerTimeNow()
 windup=finite(windup) and math.clamp(windup,.05,2) or .25
 if not vector(origin)or not vector(center)or (center-origin).Magnitude<.1 or not finite(now)then return end
 if pulse~=0 and pulse~=1 then return end
 local at=pulse==0 and (startedAt or character and character:GetAttribute('K0AttackStartedAt') or now)or firedAt or now
 if not finite(at)or at>now+.5 or now-at>(pulse==0 and windup or LIFE)then return end
 local camera=workspace.CurrentCamera;if camera and(camera.CFrame.Position-origin).Magnitude>110 then return end
 if character and sequence~=nil then
  local old=seen[character]
  if old and old.sequence==sequence and old[pulse] then return end
  if old and finite(sequence)and finite(old.sequence)and sequence<old.sequence then return end
  if not old or old.sequence~=sequence then old={sequence=sequence};seen[character]=old end
  old[pulse]=true
 end
 for i=#active,1,-1 do if active[i].character==character and active[i].stage=='Charge'then remove(i)end end
 if #active>=4 then return end
 local folder=Instance.new('Folder');folder.Name='WindLanceVFX';folder:SetAttribute('Stage',pulse==0 and 'Charge'or'Lance')
 local p=Instance.new('Part');p.Name='WindCarrier';p.Size=Vector3.new(.1,.1,.1);p.Transparency=1;p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=folder
 local first=tip(character,origin);if (center-first).Magnitude<.1 then first=origin end
 p.CFrame=CFrame.lookAt(first,center)
 local s={folder=folder,carrier=p,origin=origin,center=center,length=math.min(38,(center-first).Magnitude),character=character,sequence=sequence,stage=pulse==0 and 'Charge'or'Lance',at=at,life=pulse==0 and windup or LIFE,ribbons={},spirals={},head={},impacts={}}
 for lane=1,3 do table.insert(s.spirals,ribbon(s,'AirSpiral',pulse==0 and 8 or 20,.14,lane==1 and WHITE or MINT))end
 if pulse~=0 then
  s.core=ribbon(s,'WindLanceCore',1,.18,WHITE)
  for _=1,2 do table.insert(s.head,ribbon(s,'LanceEdge',1,.22,WHITE))end
  if type(points)=='table'then
   for i=1,math.min(#points,3)do
    if vector(points[i])and(points[i]-origin).Magnitude<=38 then table.insert(s.impacts,{ribbon=ribbon(s,'HitGust',8,.16,WHITE),localPoint=p.CFrame:PointToObjectSpace(points[i])})end
   end
  end
 end
 if pulse~=0 then
  s.surface={model=folder,faces={},color=MINT}
  local frame=CFrame.lookAt(first,center)
  Surfaces.ribbon(s.surface,"WindSurface",function(t)
   return first+(center-first)*t+frame.RightVector*math.sin(t*math.pi*2)*.3
  end,frame.UpVector,1.25,.62)
 end
 folder.Parent=workspace;Debris:AddItem(folder,s.life+.1);table.insert(active,s)
 Wind.step(now)
 if #active>0 and not connection then connection=Run.Heartbeat:Connect(function()Wind.step(workspace:GetServerTimeNow())end)end
 return folder
end
return Wind
