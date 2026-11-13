-- Client-only derivatives of Yuruzuu and ParticleFX; source/terms in assets/effects/curated-vfx-v1.
-- Shares the PixelFX record/distance/cancellation budget. No combat or example scripts.
local Input=game:GetService('UserInputService')
local C={}
local reserved=0
local blocked={}
local textures={
 shard='rbxassetid://8030734851',plus='rbxassetid://9937082969',spec='rbxassetid://9997556038',
 gradient='rbxassetid://8196169974',blast='rbxassetid://125374985892345',
}
local skills={['elf.magic_archer.spirit_rain']='spiritRain',['mage.cryo.frost_ring']='frost',['dwarf.gunner.bomb_toss']='blast'}
local lifetimes={heal=1.25,spiritRain=.45,frost=.6,blast=.85}
local costs={heal=12,spiritRain=15,frost=8,blast=1}
function C.keyFor(id)return skills[id]end
function C.duration(key)return lifetimes[key]end
local function sequence(points)
 local keys={};for _,p in ipairs(points)do table.insert(keys,NumberSequenceKeypoint.new(p[1],p[2],p[3]or 0))end
 return NumberSequence.new(keys)
end
local function attachment(holder,name,offset)
 local a=Instance.new('Attachment');a.Name=name;a.Position=offset;a.Parent=holder;return a
end
local function emitter(parent,name,texture,color,life,speed,size,count)
 local e=Instance.new('ParticleEmitter');e.Name=name;e.Texture=texture
 e.Enabled=false;e.Rate=0;e.Color=ColorSequence.new(color);e.LightInfluence=0;e.LightEmission=.65
 e.Lifetime=NumberRange.new(life[1],life[2]);e.Speed=NumberRange.new(speed[1],speed[2]);e.Size=sequence(size)
 e.Transparency=sequence({{0,.12},{.7,.12},{1,1}});e.EmissionDirection=Enum.NormalId.Top
 e.Orientation=Enum.ParticleOrientation.FacingCamera;e.ZOffset=0;e.LockedToPart=false
 e:SetAttribute('ReviewBurstCount',count);e.Parent=parent
 return e
end
function C.mount(holder,key,size)
 local cost=costs[key];if not cost then return nil end
 local limit=Input.TouchEnabled and 96 or 192
 if reserved+cost>limit then return nil end
 local required=key=='heal'and{'shard','plus','spec'}or key=='spiritRain'and{'shard','gradient'}or key=='frost'and{'shard'}or{key}
 for _,name in ipairs(required)do if blocked[textures[name]]then return nil end end
 local emitters={}
 local function add(e)table.insert(emitters,e);return e end
 if key=='heal'then
  local mint=Color3.fromRGB(145,255,200)
  local rows={
   {'Shards','shard',-.7,3,{.55,.8},{3,4.5},{{0,0},{.35,.45},{1,0}},2.5},
   {'Plus','plus',.65,2,{.85,1.25},{1.5,2.4},{{0,0},{.25,.2},{1,0}},3},
   {'ShardsBigger','shard',.4,2,{.5,.75},{3.5,5},{{0,0},{.35,.55},{1,0}},5},
   {'Specs','spec',-.4,5,{.85,1.25},{3,4.5},{{0,0},{.25,.18,.06},{1,0}},3},
  }
  for _,r in ipairs(rows)do
   local a=attachment(holder,r[1]..'Origin',Vector3.new(r[3],-.4,0))
   local e=add(emitter(a,r[1],textures[r[2]],mint,r[5],r[6],r[7],r[4]));e.Drag=r[8]
   e.LockedToPart=true;e.SpreadAngle=Vector2.new(12,12);e.LightEmission=.25
   if r[1]=='Specs'then e.Rotation=NumberRange.new(-180,180);e.RotSpeed=NumberRange.new(-300,300)end
  end
 elseif key=='frost'then
  -- Small world-positioned ice glints; no baked ground perspective or floating card.
  for i=1,8 do
   local angle=i*math.pi/4;local radius=math.min(size*.3,1.4)
   local a=attachment(holder,'FrostShardOrigin',Vector3.new(math.cos(angle)*radius,.1,math.sin(angle)*radius))
   local e=add(emitter(a,'FrostGlint',textures.shard,Color3.fromRGB(175,237,255),{.3,.55},{.8,1.8},{{0,0},{.25,.38},{1,0}},1))
   e.Orientation=Enum.ParticleOrientation.VelocityParallel;e.Drag=2;e.LightEmission=.35
  end
 elseif key=='spiritRain'then
  local color=Color3.fromRGB(125,233,184)
  for i=1,5 do
   local angle=i*2.39996;local radius=math.sqrt(i/6)*math.min(size*.4,1.8)
   local offset=Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
   local top=attachment(holder,'ArrowFallOrigin',offset+Vector3.new(0,4,0))
   local falling=add(emitter(top,'MainProjectile',textures.shard,color,{.2,.24},{18,20},{{0,0},{.298,1.2,.15},{1,0}},1))
   falling.EmissionDirection=Enum.NormalId.Bottom;falling.Orientation=Enum.ParticleOrientation.VelocityParallel
   falling.Rotation=NumberRange.new(-90);falling.SpreadAngle=Vector2.zero
   local floor=attachment(holder,'ArrowContactOrigin',offset)
   local glow=add(emitter(floor,'Gradient',textures.gradient,color,{.2,.3},{.00135,.00135},{{0,0},{.199,.65},{1,1.2}},1))
   glow.Orientation=Enum.ParticleOrientation.VelocityPerpendicular;glow.Transparency=sequence({{0,1},{.497,.35},{1,1}})
   local shard=add(emitter(floor,'Shards',textures.shard,color,{.2,.3},{3,5},{{0,0},{.214,.7,.15},{1,0}},1))
   shard.Orientation=Enum.ParticleOrientation.VelocityParallel;shard.Drag=4;shard.Rotation=NumberRange.new(-90)
  end
 else
  -- These uploads have baseline images but no particle-flipbook representation.
  -- Use the existing occluded world-atlas approach without a second frame loop.
  local gui=Instance.new('BillboardGui');gui.Name='CuratedSprite';gui.Adornee=holder
  gui.Size=UDim2.fromScale(size,size);gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.MaxDistance=80;gui.Parent=holder
  local image=Instance.new('ImageLabel');image.Name='Frame';image.BackgroundTransparency=1;image.Size=UDim2.fromScale(1,1)
  image.Image=textures[key];image.ImageRectSize=Vector2.new(128,128);image.ImageRectOffset=Vector2.zero
  image.ResampleMode=Enum.ResamplerMode.Default;image.ImageTransparency=.18;image.Parent=gui
 end
 reserved+=cost
 holder:SetAttribute('CuratedVFXKey',key)
 return {cost=cost,released=false,emitters=emitters,sprite=holder:FindFirstChild('CuratedSprite'),duration=lifetimes[key]}
end
function C.step(record,age)
 if not record or not record.sprite then return end
 local image=record.sprite.Frame
 local phase=math.clamp(age/record.duration,0,1)
 local index=math.min(63,math.floor(phase*64))
 image.ImageRectOffset=Vector2.new(index%8*128,math.floor(index/8)*128)
 image.ImageTransparency=.18+math.clamp((phase-.55)/.45,0,1)*.82
end
function C.play(record)
 if record then for _,e in ipairs(record.emitters)do e:Emit(e:GetAttribute('ReviewBurstCount'))end end
end
function C.release(record)
 if record and not record.released then reserved=math.max(0,reserved-record.cost);record.released=true end
end
function C.count()return reserved end
function C.preload()
 local instances={};local statuses={}
 for key,id in pairs(textures)do
  local object=Instance.new((key=='frost'or key=='blast')and'ImageLabel'or'ParticleEmitter')
  if object:IsA('ImageLabel')then object.Image=id else object.Texture=id end
  table.insert(instances,object)
 end
 local ok,err=pcall(function()
  game:GetService('ContentProvider'):PreloadAsync(instances,function(id,status)
   blocked[id]=status~=Enum.AssetFetchStatus.Success;statuses[id]=status.Name
  end)
 end)
 for _,object in ipairs(instances)do object:Destroy()end
 if not ok then error(err)end
 return statuses
end
return C
