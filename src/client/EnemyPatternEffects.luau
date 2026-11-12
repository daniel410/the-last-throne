-- Server-authored attacks and confirmed outcomes only. All geometry is cosmetic.
local RS=game:GetService('ReplicatedStorage')
local Run=game:GetService('RunService')
local Tween=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local Players=game:GetService('Players')
local Patterns=require(RS.Shared.EnemyPatterns)
local Text=require(RS.Shared.EnemyPatternText)
local Audio=require(RS.Shared.CombatAudioCatalog)
local BossImpact=require(script.Parent.BossHeroImpact)
local Spell=require(script.Parent.EnemySpellVFX)
local Effects={}
local colors={physical=Color3.fromRGB(255,217,150),arcane=Color3.fromRGB(182,115,255),frost=Color3.fromRGB(121,226,255),fire=Color3.fromRGB(255,133,56),web=Color3.fromRGB(223,218,255),venom=Color3.fromRGB(151,230,90),soul=Color3.fromRGB(109,238,197),shadow=Color3.fromRGB(201,128,255)}
local definitions={};for _,profile in pairs(Patterns.profiles)do for _,d in ipairs(profile.attacks)do definitions[d.id]=d end end
local ground
local visualEvents=setmetatable({},{__mode='k'})
local function acceptVisual(m)
 if not m.model or not m.model:IsDescendantOf(workspace)or m.model:GetAttribute('K0AttackSeq')~=m.sequence then return false end
 local h=m.model:FindFirstChildOfClass('Humanoid');if h and h.Health<=0 then return false end
 local row=visualEvents[m.model]
 if not row or row.sequence~=m.sequence then row={sequence=m.sequence,keys={}};visualEvents[m.model]=row end
 if row.cancelled then return false end
 local key=m.kind..':'..tostring(m.pulse)..':'..tostring(m.shot)
 if row.keys[key]then return false end;row.keys[key]=true;return true
end
local soundHolders={}
local attacks=setmetatable({},{__mode='k'});local impacts={};local bursts={};local projectiles={};local soundAt={};local started=false
local function part(parent,name,position,size,color)
 local p=Instance.new('Part');p.Name=name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Size=size;p.Position=position;p.Color=color;p.Parent=parent;return p
end
local function permitted(position)
 local camera=workspace.CurrentCamera
 return not camera or (camera.CFrame.Position-position).Magnitude<=100
end
local function burst(position,element,scale,result)
 if not permitted(position)then return end
 for i=#bursts,1,-1 do if not bursts[i].Parent then table.remove(bursts,i)end end
 if #bursts>=24 then bursts[1]:Destroy();table.remove(bursts,1)end
 local holder=Instance.new('Folder');holder.Name='EnemyContactFX';holder.Parent=workspace;table.insert(bursts,holder)
 local color=colors[element]or colors.physical
 if result=='Blocked' or result=='PerfectBlock' or result=='Absorbed'then
  local defenseColor=result=='Absorbed' and Color3.fromRGB(115,194,255)or result=='PerfectBlock' and Color3.fromRGB(255,248,195)or Color3.fromRGB(255,194,89)
  local ring=part(holder,'DefenseRipple',position,Vector3.new(.1,1.2,1.2)*scale,defenseColor);ring.Shape=Enum.PartType.Cylinder;ring.CFrame=CFrame.new(position)*CFrame.Angles(0,math.pi/2,0)
  Tween:Create(ring,TweenInfo.new(.28),{Size=Vector3.new(.05,2.6,2.6)*scale,Transparency=1}):Play()
 end
 local flash=part(holder,'Contact',position,Vector3.one*.4*scale,color);flash.Shape=Enum.PartType.Ball
 Tween:Create(flash,TweenInfo.new(.22),{Size=Vector3.one*1.4*scale,Transparency=1}):Play()
 for i=1,4 do
  local yaw=i*math.pi*.5;local p=part(holder,'Shard',position,Vector3.new(.1,.35,.12)*scale,color)
  Tween:Create(p,TweenInfo.new(.3),{Position=position+Vector3.new(math.cos(yaw),.5,math.sin(yaw))*scale,Transparency=1}):Play()
 end
 Debris:AddItem(holder,.35)
end
local function sound(position,element,result)
 local key=({physical='steel',shadow='arcane',soul='holy',web='nature',venom='nature'})[element]or element
 if result=='Blocked' or result=='PerfectBlock' or result=='Absorbed'then key='shield'end
 local row=Audio.profiles[key]or Audio.profiles.arcane;local clip=result=='Release' and row.release or row.impact
 local t=os.clock();local cell=tostring(key)..':'..math.floor(position.X/10)..':'..math.floor(position.Z/10)
 if t-(soundAt[cell]or -math.huge)<.15 then return end
 soundAt[cell]=t
 for k,v in pairs(soundAt)do if t-v>2 then soundAt[k]=nil end end
 for i=#soundHolders,1,-1 do if not soundHolders[i].Parent then table.remove(soundHolders,i)end end
 if #soundHolders>=8 then soundHolders[1]:Destroy();table.remove(soundHolders,1)end
 local holder=part(workspace,'EnemyImpactSound',position,Vector3.one*.05,colors.physical);holder.Transparency=1
 local s=Instance.new('Sound');s.SoundId=clip.id;s.Volume=math.min(.25,clip.volume);s.PlaybackSpeed=clip.speed;s.RollOffMinDistance=6;s.RollOffMaxDistance=65;s.Parent=holder;s:Play();table.insert(soundHolders,holder);Debris:AddItem(holder,math.min(2,clip.duration))
end
local function label(target,message,color)
 local root=target:FindFirstChild('HumanoidRootPart');if not root then return end
 local b=Instance.new('BillboardGui');b.Name='EnemyImpactLabel';b.Size=UDim2.fromOffset(120,26);b.StudsOffsetWorldSpace=Vector3.new(0,3,0);b.MaxDistance=65;b.Adornee=root;b.Parent=root
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=message;t.TextColor3=color;t.Font=Enum.Font.GothamBold;t.TextSize=13;t.TextStrokeTransparency=.3;t.AutoLocalize=false;t.Parent=b
 Tween:Create(t,TweenInfo.new(.5),{TextTransparency=1,TextStrokeTransparency=1}):Play();Debris:AddItem(b,.55)
end
local function destroyAttack(model)
 local old=attacks[model];if old and old.folder then old.folder:Destroy()end;if old and old.charge then Spell.destroy(old.charge)end;attacks[model]=nil;Spell.cancel(model)
 for i=#projectiles,1,-1 do if projectiles[i].model==model then Spell.destroy(projectiles[i].visual);table.remove(projectiles,i)end end
end
local function begin(message)
 local d=definitions[message.id];if not d or not message.model then return end
 local old=attacks[message.model];if old and old.sequence==message.sequence then return end
 destroyAttack(message.model)
 attacks[message.model]={d=d,sequence=message.sequence,origin=message.origin,direction=message.direction,aim=message.aim,at=message.at}
end
function Effects.observe(model,current)
 local id=model:GetAttribute('K0PatternId');if not id then return end
 local sequence=model:GetAttribute('K0AttackSeq');local old=attacks[model];if old and old.sequence==sequence then return end
 local clock=model:GetAttribute('K0EnemyAttackClock');local at=type(clock)=='string' and tonumber(string.split(clock,'|')[2])
 local origin,dir,aim=model:GetAttribute('K0PatternOrigin'),model:GetAttribute('K0PatternDirection'),model:GetAttribute('K0PatternAim')
 if at and current-at<12 and typeof(origin)=='Vector3' and typeof(dir)=='Vector3' and typeof(aim)=='Vector3' then begin({model=model,id=id,sequence=sequence,origin=origin,direction=dir,aim=aim,at=at})end
end
function Effects.receive(m)
 if type(m)~='table'then return end
 if m.kind=='begin'then begin(m)
 elseif m.kind=='cancel'then
  Spell.cancel(m.model,m.sequence)
  local row=visualEvents[m.model]
  if not row or row.sequence==m.sequence then visualEvents[m.model]={sequence=m.sequence,keys={},cancelled=true}end
  local a=attacks[m.model];if a and a.sequence==m.sequence then destroyAttack(m.model)end
 elseif m.kind=='impact'then
  if not m.model or not m.target or not m.target.Parent or not permitted(m.position)or workspace:GetServerTimeNow()-m.at>.5 then return end
  local targets=impacts[m.model]or {};impacts[m.model]=targets
  local seen=targets[m.target]or {};targets[m.target]=seen
  local key=m.sequence..':'..m.pulse
  if seen[key]then return end;seen[key]=os.clock()
  for model,byTarget in pairs(impacts)do
   for target,entries in pairs(byTarget)do for k,t in pairs(entries)do if os.clock()-t>2 then entries[k]=nil end end;if not next(entries)then byTarget[target]=nil end end
   if not next(byTarget)then impacts[model]=nil end
  end
  if m.result=='Prevented'then return end
  local result=m.result;local color=colors[m.element]or colors.physical
  if result=='Dodged'then if Players.LocalPlayer and m.target==Players.LocalPlayer.Character then label(m.target,Text.Dodged,Color3.fromRGB(175,218,255))end;return end
  local root=m.target:FindFirstChild('HumanoidRootPart');if not root then return end
  local pos=m.position
  if result=='Blocked' or result=='PerfectBlock'then
   local shield=m.target:FindFirstChild('Shield',true)
   if shield and shield:IsA('BasePart')then pos=shield.Position else pos=root.Position+root.CFrame.LookVector*1.1 end
  end
  local profile=Patterns.get(m.model:GetAttribute('EnemyKind'))
  local boss=profile and profile.boss
  burst(pos,m.element,result=='PerfectBlock' and 1.4 or boss and 1.55 or 1,result)
  if boss and result=='Hit' and m.damage>0 then BossImpact.play(m.target,m.element,color)end
  local d=definitions[m.id]or (attacks[m.model]and attacks[m.model].d)
  if d and d.shape~='projectile' and result=='Hit' and m.damage>0 then Spell.impact(d,pos,workspace:GetServerTimeNow(),m.model,m.sequence)end
  sound(pos,m.element,result)
  if result~='Hit' then label(m.target,Text[result]or Text.Hit,color)end
  if m.damage>0 then
   local old=m.target:FindFirstChild('EnemyElementContact');if old then old:Destroy()end
   local highlight=Instance.new('Highlight');highlight.Name='EnemyElementContact';highlight.Adornee=m.target;highlight.FillColor=color;highlight.OutlineColor=color;highlight.FillTransparency=.92;highlight.OutlineTransparency=.5;highlight.DepthMode=Enum.HighlightDepthMode.Occluded;highlight.Parent=m.target;Debris:AddItem(highlight,.18)
  end
  if m.damage>0 and Players.LocalPlayer and m.target==Players.LocalPlayer.Character then
   if result=='Hit'then label(m.target,'-'..tostring(math.floor(m.damage+.5)),Color3.fromRGB(255,183,160))end
   local source=m.source;local camera=workspace.CurrentCamera
   if camera and source and (source-root.Position).Magnitude>1 then
    local v=camera.CFrame:VectorToObjectSpace(source-root.Position)
    -- Direction shown on the existing light feedback layer, never captures input.
    local angle=math.atan2(v.X,-v.Z)
    local gui=Players.LocalPlayer.PlayerGui:FindFirstChild('K0PlayerHitFeedback')
    if gui then
     local old=gui:FindFirstChild('ImpactDirection');if old then old:Destroy()end
     local arrow=Instance.new('TextLabel');arrow.Name='ImpactDirection';arrow.Size=UDim2.fromOffset(28,28);arrow.AnchorPoint=Vector2.new(.5,.5);arrow.Position=UDim2.fromScale(.5+math.sin(angle)*.35,.5-math.cos(angle)*.32);arrow.BackgroundTransparency=1;arrow.Text='▲';arrow.TextColor3=Color3.fromRGB(255,139,113);arrow.TextSize=23;arrow.Rotation=math.deg(angle);arrow.Active=false;arrow.Parent=gui;Debris:AddItem(arrow,.4)
    end
   end
  end
 elseif m.kind=='pulse'then
  local d=definitions[m.id]
  if d and m.model and m.model.Parent and permitted(m.position)and workspace:GetServerTimeNow()-m.at<=.5 and acceptVisual(m)then
   local floor=ground(m.position)
   if floor then
    local direction=m.model:GetAttribute('K0PatternDirection')or Vector3.new(0,0,-1)
    Spell.pulse(d,floor,direction,workspace:GetServerTimeNow(),m.model,m.sequence)
   end
  end
 elseif m.kind=='projectile'then
  local d=definitions[m.id];if not m.model or not d or not permitted(m.origin)then return end
  if workspace:GetServerTimeNow()-m.at>.5 or workspace:GetServerTimeNow()<m.at-.1 then return end
  if not acceptVisual(m)then return end
  if #projectiles>=48 then Spell.destroy(projectiles[1].visual);table.remove(projectiles,1)end
  if m.shot==1 then sound(m.origin,d.element,'Release')end
  local visual=Spell.projectile(d,m.model,m.sequence,m.origin,m.direction,m.at)
  if visual then table.insert(projectiles,{model=m.model,sequence=m.sequence,pulse=m.pulse,shot=m.shot,visual=visual,origin=m.origin,direction=m.direction,at=m.at,d=d})end
 elseif m.kind=='projectileEnd'then
  for i=#projectiles,1,-1 do
   local p=projectiles[i]
   if p.model==m.model and p.sequence==m.sequence and p.pulse==m.pulse and p.shot==m.shot then
    Spell.destroy(p.visual);table.remove(projectiles,i)
    if typeof(m.position)=='Vector3'and permitted(m.position)then Spell.impact(p.d,m.position,workspace:GetServerTimeNow(),m.model,m.sequence)end
   end
  end
 end
end
-- Match authored walkable floors, never character bodies, props or warning FX.
local floorNames={Ground=true,ForestGround=true,SnowGround=true,BasaltGround=true,ForestBedrock=true,TrailEmbankment=true,WalkableTerrace=true,WalkableRamp=true,TerraceLanding=true}
local floorParams=RaycastParams.new();floorParams.FilterType=Enum.RaycastFilterType.Include;floorParams.RespectCanCollide=true
local floorDirty=true
local function walkable(p)
 if not p:IsA('BasePart')then return false end
 local world=p:FindFirstAncestor('DeepwoodCampaign')or p:FindFirstAncestor('DeepwoodK0')
 return world~=nil and (floorNames[p.Name] or p.Name:match('^Support_')or p.Name:match('^TrailSupport_')or p.Name:match('^ConnectedPath_')or p.Name:match('^SnowTrail_')or p.Name:match('^CalderaTrail_'))
end
local function floorChanged(p)
 if not walkable(p)then return end
 floorDirty=true
 for _,a in pairs(attacks)do if a.folder then a.folder:Destroy();a.folder=nil;a.lines=nil end end
end
workspace.DescendantAdded:Connect(floorChanged)
workspace.DescendantRemoving:Connect(floorChanged)
ground=function(v)
 if floorDirty then
  local floors={workspace.Terrain}
  for _,name in ipairs({'DeepwoodCampaign','DeepwoodK0'})do
   local world=workspace:FindFirstChild(name)
   if world then for _,p in ipairs(world:GetDescendants())do if walkable(p)then table.insert(floors,p)end end end
  end
  floorParams.FilterDescendantsInstances=floors;floorDirty=false
 end
 local hit=workspace:Raycast(v+Vector3.new(0,2,0),Vector3.new(0,-96,0),floorParams)
 return hit and hit.Normal.Y>.4 and hit.Position+Vector3.new(0,.12,0)or nil
end
local function draw(a,model,now)
 local d=a.d;local age=now-a.at
 if age<d.windup and d.element~='physical' and permitted(a.origin)then
  local socket=model:FindFirstChild('EnemyCastSocket',true)
  if socket then
   if not a.charge or a.charge.dead then a.charge=Spell.charge(d,model,a.sequence,a.at)end
   if a.charge then
    local progress=math.clamp(age/d.windup,0,1)
    Spell.pose(a.charge,CFrame.new(socket.WorldPosition)*CFrame.Angles(0,age*1.7,0),age,.3+progress*.65)
   end
  end
 elseif a.charge then Spell.destroy(a.charge);a.charge=nil end
 local warning=age<d.windup+(d.pulses-1)*d.interval+.22
 if not warning or not permitted(a.origin)then if a.folder then a.folder:Destroy();a.folder=nil end;return end
 if a.lines and #a.lines>0 and a.folder then
  for _,p in ipairs(a.lines)do if p.Parent then p.Transparency=.08+(.18*(1-math.clamp(age/d.windup,0,1)))end end;return
 end
 if not a.folder then a.lines=nil;a.folder=Instance.new('Folder');a.folder.Name='EnemyPatternWarning';a.folder.Parent=workspace end
 local vertices={};local right=Vector3.new(-a.direction.Z,0,a.direction.X)
 local function line(x,y)
  -- Short edges follow slopes; missing floors and cliffs leave a gap instead of an airborne beam.
  local steps=math.max(1,math.ceil((y-x).Magnitude/3));local previous=ground(x)
  for i=1,steps do
   local nextPoint=ground(x:Lerp(y,i/steps))
   if previous and nextPoint and math.abs(previous.Y-nextPoint.Y)<=1.5 then table.insert(vertices,{previous,nextPoint})end
   previous=nextPoint
  end
 end
 local function circle(center,r)
  for i=1,20 do local x,y=(i-1)*math.pi/10,i*math.pi/10;line(center+Vector3.new(math.cos(x)*r,0,math.sin(x)*r),center+Vector3.new(math.cos(y)*r,0,math.sin(y)*r))end
 end
 if d.shape=='circle'then circle(a.aim,d.radius)
 elseif d.shape=='trail'then for pulse=1,d.pulses do circle(a.aim+right*((pulse-(d.pulses+1)/2)*d.radius*2.5),d.radius)end
 elseif d.shape=='ring'then circle(a.origin,d.radius);circle(a.origin,d.innerRadius)
 elseif d.shape=='cone'then
  local prev=a.origin
  for i=0,16 do local angle=math.rad(-d.angle/2+i*d.angle/16);local v=a.origin+(a.direction*math.cos(angle)+right*math.sin(angle))*d.range;line(prev,v);prev=v end;line(prev,a.origin)
 else
  local width=d.shape=='projectile' and 1.4 or d.width;local length=d.motion=='dash' and d.dashDistance or d.range
  local left,rt=a.origin-right*width,a.origin+right*width;local far=a.direction*length
  line(left,rt);line(rt,rt+far);line(rt+far,left+far);line(left+far,left)
  if d.shape=='projectile' and d.fan>1 then
   for i=1,d.fan do local yaw=math.rad((i-(d.fan+1)/2)*d.spread/(d.fan-1));line(a.origin,a.origin+CFrame.Angles(0,yaw,0):VectorToWorldSpace(a.direction)*length)end
  end
 end
 local color=d.blockable and Color3.fromRGB(255,190,52)or Color3.fromRGB(255,73,58)
 a.lines=a.lines or {}
 for i,v in ipairs(vertices)do
  local p=a.lines[i];if not p or not p.Parent then p=part(a.folder,'WarningEdge',v[1],Vector3.one*.1,color);a.lines[i]=p end
  p.Color=color;p.Size=Vector3.new(.13,.08,math.max(.01,(v[2]-v[1]).Magnitude));p.CFrame=CFrame.lookAt((v[1]+v[2])*.5,v[2]);p.Transparency=.08+(.18*(1-math.clamp(age/d.windup,0,1)))
 end
end
function Effects.start()
 if started then return end;started=true
 task.spawn(function()RS:WaitForChild('Remotes'):WaitForChild('EnemyPatternEvent').OnClientEvent:Connect(Effects.receive)end)
 Run.RenderStepped:Connect(function()Effects.render(workspace:GetServerTimeNow())end)
end
function Effects.render(now)
  Spell.step(now)
  for model,a in pairs(attacks)do
   local h=model:FindFirstChildOfClass('Humanoid')
   if not model:IsDescendantOf(workspace)or not h or h.Health<=0 or model:GetAttribute('K0AttackSeq')~=a.sequence or not model:GetAttribute('K0PatternId')then destroyAttack(model)
   elseif now-(a.drawAt or 0)>.05 then a.drawAt=now;draw(a,model,now)end
  end
  for i=#projectiles,1,-1 do local p=projectiles[i];local age=now-p.at
   local h=p.model:FindFirstChildOfClass('Humanoid')
   if age<0 or age*p.d.speed>p.d.range or not p.model:IsDescendantOf(workspace)or h and h.Health<=0 or p.model:GetAttribute('K0AttackSeq')~=p.sequence or p.visual.dead then Spell.destroy(p.visual);table.remove(projectiles,i)
   else
    local position=p.origin+p.direction*age*p.d.speed
    Spell.pose(p.visual,CFrame.lookAt(position,position+p.direction)*CFrame.Angles(0,0,age*(p.d.heavy and 3 or 5)),age,1)
   end
  end
end
return Effects
