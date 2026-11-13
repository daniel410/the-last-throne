-- Cosmetic spell geometry. Never moves a gameplay root or performs a hit test.
local RS=game:GetService('ReplicatedStorage')
local Profiles=require(RS.Shared.EnemySpellProfiles)
local Art=require(script.Parent.EnemySpellArt)
local V={}
local records={};local budget=0
local MAX_PARTS=640;local MAX_RECORDS=64
local function remove(r)
 if r.dead then return end;r.dead=true;budget-=#r.parts;Art.release(r)
 if r.model.Parent then r.model:Destroy()end
end
local function prune()
 for i=#records,1,-1 do if records[i].dead or not records[i].model.Parent then remove(records[i]);table.remove(records,i)end end
end
local function make(d,stage,owner,sequence,now,lifetime)
 local p=Profiles.get(d);if not p then return nil end
 prune()
 -- Preserve traveling attacks when optional impact/ground decorations fill the budget.
 if stage=='projectile'then
  while #records>=MAX_RECORDS or budget>MAX_PARTS-32 do
   local found
   for i,r in ipairs(records)do if r.stage~='projectile'then found=i;break end end
   if not found then break end
   remove(records[found]);table.remove(records,found)
  end
 end
 if #records>=MAX_RECORDS or budget>MAX_PARTS-32 then return nil end
 local model=Instance.new('Model');model.Name=stage=='projectile' and 'EnemyMagicProjectile'or 'EnemySpell'..stage
 model:SetAttribute('SpellId',d.id);model:SetAttribute('SpellMotif',p.motif);model:SetAttribute('SpellOrnament',p.ornament);model:SetAttribute('SpellStage',stage)
 model:SetAttribute('SpellStyle',p.fireStyle or p.motif)
 model.Parent=workspace
 local r={model=model,parts={},profile=p,definition=d,owner=owner,sequence=sequence,at=now,life=lifetime,stage=stage,color=Color3.fromRGB(table.unpack(p.color))}
 records[#records+1]=r;return r
end
local function part(r,name,size,cf,shape,color,alpha)
 if budget>=MAX_PARTS then return end
 local p=Instance.new(shape=='wedge'and 'WedgePart'or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or r.color
 p.Material=Enum.Material.Neon;p.Transparency=alpha or .28;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 if shape=='ball'then p.Shape=Enum.PartType.Ball end
 if name=='CrystalBlade'or name=='IceSpire'or name=='IceFacet'then
  p.Material=Enum.Material.Glass;p.Reflectance=.16;p.Transparency=.25;p.Color=p.Color:Lerp(Color3.fromRGB(220,252,255),.25)
 elseif name=='FlameTongue'then p.Transparency=r.profile.fireStyle and .5 or .96
 elseif name=='MeteorFlame'then p.Transparency=.72
 elseif name:match('^Accent_')then p.Transparency=.84;p.Color=r.color:Lerp(Color3.fromRGB(255,247,218),.4)
 elseif name=='SpiritMask'then p.Transparency=.6
 end
 p.Parent=r.model;r.parts[#r.parts+1]={part=p,cf=cf,size=size,alpha=p.Transparency};budget+=1
 return p
end
local function line(r,a,b,width,name,color)
 local delta=b-a;if delta.Magnitude<.01 then return end
 return part(r,name or 'Filament',Vector3.new(width,width,delta.Magnitude),CFrame.lookAt((a+b)*.5,b),nil,color)
end
local function ring(r,radius,z,count,name)
 local prev
 for i=0,count do
  local a=i*math.pi*2/count;local point=Vector3.new(math.cos(a)*radius,math.sin(a)*radius,z)
  if prev then line(r,prev,point,.065,name or 'RunicOrbit')end;prev=point
 end
end
local function motif(r)
 local m=r.profile.motif;local white=Color3.fromRGB(255,245,215)
 if m=='icespear' or m=='frostfang' or m=='prism' or m=='crystal' or m=='glacier'then
  local count=m=='icespear' and 1 or m=='frostfang' and 2 or m=='prism' and 3 or 5
  for i=1,count do
   local x=(i-(count+1)/2)*.29
   part(r,'CrystalBlade',Vector3.new(.27,.38,1.8-(i%2)*.3),CFrame.new(x,0,0)*CFrame.Angles(0,0,math.pi*.25),'wedge')
  end
 elseif m=='rock' or m=='iceboulder' or m=='meteor' or m=='magma'then
  local stone=m=='rock'or m=='meteor'or m=='magma'
  local core=part(r,'FacetedBoulder',Vector3.one*.85,CFrame.Angles(.4,.5,.3),nil,stone and Color3.fromRGB(109,91,78)or Color3.fromRGB(139,202,225),.05)
  if core then core.Material=Enum.Material.Slate end
  for i=1,3 do part(r,'Fracture',Vector3.new(.15,.65,.9),CFrame.Angles(0,0,i*math.pi/3))end
  if m=='meteor'or m=='magma'then
   for i=1,3 do local a=i*math.pi*2/3;part(r,'MeteorFlame',Vector3.new(.25,.3,1.4),CFrame.new(math.cos(a)*.3,math.sin(a)*.3,.7)*CFrame.Angles(0,0,a),'wedge')end
  end
 elseif m=='web'then
  ring(r,.65,0,6,'SilkHexagon')
  for i=1,3 do local a=i*math.pi/3;line(r,Vector3.new(math.cos(a),math.sin(a),0)*-.65,Vector3.new(math.cos(a),math.sin(a),0)*.65,.045,'SilkCross')end
  part(r,'SilkNeedle',Vector3.new(.09,.09,1.15),CFrame.identity)
 elseif m=='venom' or m=='gel' or m=='brood'then
  part(r,'VenomSac',Vector3.new(.55,.55,1.05),CFrame.identity,'ball')
  for i=1,3 do local a=i*math.pi*2/3;part(r,m=='brood'and 'BroodEgg'or 'AcidDroplet',Vector3.one*.22,CFrame.new(math.cos(a)*.43,math.sin(a)*.43,.2),'ball')end
 elseif m=='bone' or m=='knife' or m=='cleaver' or m=='scythe' or m=='claw'then
  local n=m=='claw'and 3 or 1
  for i=1,n do part(r,'Blade',Vector3.new(m=='cleaver'and .65 or .2,.12,1.4),CFrame.new((i-(n+1)/2)*.32,0,0),'wedge',m=='bone'and white or nil)end
  if m=='bone'then for _,z in ipairs({-.6,.6})do part(r,'BoneJoint',Vector3.new(.5,.2,.2),CFrame.new(0,0,z),'ball',white)end
  elseif m=='knife'then part(r,'KnifeGuard',Vector3.new(.65,.12,.12),CFrame.new(0,0,.4))
  elseif m=='scythe'then line(r,Vector3.new(-.8,0,-.5),Vector3.new(.3,0,.4),.22,'CrescentEdge')end
 elseif m=='ember' or m=='cinder' or m=='lava' or m=='inferno' or m=='volcano'then
  local style=r.profile.fireStyle
  part(r,'EmberHeart',style and Vector3.new(.24,.3,.85)or Vector3.new(.46,.46,.9),CFrame.new(0,0,-.15),style and 'wedge'or 'ball',white,style and .32 or .18)
  part(r,'EmberShell',Vector3.new(.72,.72,1.2),CFrame.new(0,0,.05),'ball',nil,style and .94 or .8)
  if style=='fork'then
   for side=-1,1,2 do part(r,'ForkedFlame',Vector3.new(.24,.65,1.15),CFrame.new(side*.3,0,-.1)*CFrame.Angles(0,side*.24,side*.2),'wedge',nil,.22)end
  elseif style=='cinderfan'then
   for i=-1,1 do part(r,'CinderFanBlade',Vector3.new(.18,.38,1.6),CFrame.new(i*.29,0,0)*CFrame.Angles(0,i*.36,0),'wedge',nil,.24)end
  elseif style=='vent'then
   for i=-1,1 do part(r,'VentFlame',Vector3.new(.24,.9-math.abs(i)*.25,1.2),CFrame.new(i*.32,math.abs(i)*.22,-.05)*CFrame.Angles(0,i*.18,i*.2),'wedge',nil,.2)end
  elseif style=='crownfire'then
   for i=-1,1 do part(r,'InfernoCrown',Vector3.new(.24,i==0 and .7 or 1.25,1.1),CFrame.new(i*.48,math.abs(i)*.18,-.2)*CFrame.Angles(0,i*.16,i*.34),'wedge',nil,.18)end
  end
  local n=m=='ember'and 3 or 5
  for i=1,n do local a=i*math.pi*2/n;part(r,'FlameTongue',Vector3.new(.28,.28,.9+i*.08),CFrame.new(math.cos(a)*.25,math.sin(a)*.25,.2)*CFrame.Angles(0,0,a),'wedge',i%2==0 and white or nil)end
 elseif m=='soul' or m=='seal' or m=='rift' or m=='hex' or m=='totem'then
  ring(r,m=='rift'and .75 or .52,0,m=='hex'and 3 or m=='seal'and 8 or 6,'SpellSeal')
  if m=='soul'then
   part(r,'SpiritMask',Vector3.new(.55,.7,.15),CFrame.identity,'wedge')
   for _,x in ipairs({-.14,.14})do part(r,'SpiritEye',Vector3.new(.1,.1,.12),CFrame.new(x,.1,-.1),nil,white)end
  elseif m=='totem'then part(r,'TotemPillar',Vector3.new(.3,1.1,.3),CFrame.identity)
  elseif m=='rift'then part(r,'VoidSlit',Vector3.new(.14,1.2,.12),CFrame.Angles(0,0,-.3),nil,Color3.fromRGB(80,35,120))
  else part(r,'RuneDiamond',Vector3.new(.32,.32,.09),CFrame.Angles(0,0,math.pi/4))end
 elseif m=='banner'then
  part(r,'SpectralStandard',Vector3.new(.7,1.1,.12),CFrame.identity,'wedge');line(r,Vector3.new(-.4,-.65,0),Vector3.new(-.4,.7,0),.1,'BannerPole')
 elseif m=='root'then
  for i=1,3 do part(r,'ThornRoot',Vector3.new(.2,.25,1.2),CFrame.new((i-2)*.3,0,0)*CFrame.Angles(0,(i-2)*.4,0),'wedge')end
 elseif m=='wing'then
  for _,x in ipairs({-1,1})do part(r,'ShadowWing',Vector3.new(.8,.12,.8),CFrame.new(x*.3,0,0)*CFrame.Angles(0,x*.6,0),'wedge')end
 elseif m=='snow'then
  for i=1,6 do
   local a=i*math.pi/3;local axis=Vector3.new(math.cos(a),math.sin(a),0);local side=Vector3.new(-axis.Y,axis.X,0)
   line(r,Vector3.zero,axis*.6,.075,'SnowRay')
   line(r,axis*.34,axis*.46+side*.16,.06,'SnowBranch')
  end
 elseif m=='sand' or m=='dust'then
  for i=1,5 do
   local a=i*2.39996;local p=part(r,m=='sand'and 'SandGrain'or 'DustGrain',Vector3.new(.19,.12,.26),CFrame.new(math.cos(a)*.46,math.sin(a)*.25,(i%2-.5)*.18)*CFrame.Angles(.2,a,.4),'wedge',nil,.12)
   if p then p.Material=m=='sand'and Enum.Material.Sand or Enum.Material.Ground end
  end
 elseif m=='bomb'then
  part(r,'CrownBomb',Vector3.one*.7,CFrame.Angles(.3,.4,.1));line(r,Vector3.new(0,.35,0),Vector3.new(.2,.7,0),.1,'BombFuse',white)
 end
 -- Species ornament remains distinct even when two creatures share an element.
 local ornament=r.profile.ornament
 local count=ornament=='crown'and 3 or ornament=='rune'and 4 or 2
 for i=1,count do
  local a=i*math.pi*2/count+r.profile.index*.35
  part(r,'Accent_'..ornament,Vector3.new(.09,.28,.12),CFrame.new(math.cos(a)*.85,math.sin(a)*.85,.3)*CFrame.Angles(0,0,a),'wedge',white,.25)
 end
end
function V.destroy(r)if r then remove(r)end end
function V.pose(r,cf,age,scale,fade)
 if not r or r.dead then return end
 for i,v in ipairs(r.parts)do
  local localCF=v.cf;local size=v.size
  if r.stage=='impact'and v.silkAxis then
   local length=v.size.Z*(.6+.4*math.min(1,age/.16));local center=v.silkAxis*(.1+length*.5)
   localCF=CFrame.lookAt(center,center+v.silkAxis);size=Vector3.new(v.size.X,v.size.Y,length)
  elseif r.stage=='impact'and v.velocity then
   local t=math.max(0,age)
   local position=v.cf.Position+v.velocity*t+cf:VectorToObjectSpace(Vector3.yAxis)*(v.gravity or -5)*t*t*.5
   localCF=CFrame.new(position)*v.cf.Rotation*CFrame.Angles(t*i*1.1,t*.7,0)
  elseif r.stage=='pulse'then
   -- Immediate contact, then a quick rise and slower settling; the footprint never grows.
   local u=math.clamp(age/r.life,0,1);local rise=math.sin(math.min(1,u/.2)*math.pi*.5)*(1-u*.55)
   size=Vector3.new(v.size.X,v.size.Y*(.55+rise*.7),v.size.Z)
  elseif r.profile.ornament and v.part.Name:match('^Accent_')then
   local drift=math.sin(age*3+i)*.08
   localCF=CFrame.new(0,drift,0)*localCF
  end
  v.part.CFrame=cf*CFrame.new(localCF.Position*scale)*localCF.Rotation
  v.part.Size=size*scale
  local alpha=fade or 0
  if r.stage=='impact'then alpha=math.clamp((age/r.life-.2)/.8,0,1)end
  v.part.Transparency=v.alpha+(1-v.alpha)*alpha
 end
 r.position=cf.Position
 Art.pose(r,cf,age,scale,fade)
end
function V.roll(d,age)
 local p=Profiles.get(d);if not p then return 0 end
 if p.family=='frost'or p.family=='soul'or p.family=='venom'then return math.sin(age*3)*.08 end
 if p.family=='physical'or p.family=='earth'then return age*2 end
 return age*(p.family=='fire'and .6 or 1.1)
end
function V.projectile(d,owner,sequence,origin,direction,at)
 local r=make(d,'projectile',owner,sequence,at,d.range/d.speed+.2);if not r then return nil end
 motif(r)
 local main=r.parts[1]and r.parts[1].part
 if main then
  local a=Instance.new('Attachment');a.Position=Vector3.new(-.12,0,0);a.Parent=main
  local b=Instance.new('Attachment');b.Position=Vector3.new(.12,0,0);b.Parent=main
  local trail=Instance.new('Trail');trail.Name='SpellWake';trail.Attachment0=a;trail.Attachment1=b;trail.Lifetime=.18;trail.MinLength=.08
  trail.Color=ColorSequence.new(r.color);trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,1)});trail.Parent=main
 end
 Art.attach(r);V.pose(r,CFrame.lookAt(origin,origin+direction),0,1)
 return r
end
function V.charge(d,owner,sequence,at)
 local r=make(d,'charge',owner,sequence,at,d.windup+.2);if not r then return nil end
 motif(r);Art.attach(r);return r
end
function V.impact(d,position,now,owner,sequence,normal)
 local r=make(d,'impact',owner,sequence,now,.68);if not r then return end
 local family=r.profile.family
 local count=family=='frost'and 9 or family=='web'and 6 or 7
 for i=1,count do
  local a=i*2.39996;local ice=family=='frost';local stone=family=='earth'
  local name=ice and 'CrystalBlade'or stone and 'StoneDebris'or family=='venom'and 'AcidDroplet'or family=='arcane'and 'RunicImpactShard'or family=='soul'and 'SoulWisp'or family=='shadow'and 'RiftFragment'or family=='web'and 'ImpactSilk'or 'ImpactFragment'
  local size=ice and Vector3.new(.12,.55,.18)or stone and Vector3.one*.2 or family=='web'and Vector3.new(.035,.035,.85)or family=='soul'and Vector3.new(.09,.42,.09)or family=='arcane'and Vector3.new(.14,.3,.1)or family=='shadow'and Vector3.new(.16,.32,.08)or Vector3.new(.08,.2,.08)
  local p=part(r,name,size,CFrame.Angles(a,.3,a),(ice or family=='arcane'or family=='shadow')and 'wedge'or family=='soul'and 'ball'or nil)
  if stone then p.Material=Enum.Material.Slate;p.Color=Color3.fromRGB(132,112,90)end
  local v=r.parts[#r.parts]
  v.velocity=Vector3.new(math.cos(a),.5+(i%3)*.22,math.sin(a))*(ice and 3.2 or 2.4)
  v.gravity=family=='soul'and 1 or -5
  if family=='soul'then
   v.velocity=Vector3.new(math.cos(a)*.6,1.9+i%3*.25,math.sin(a)*.6)
  elseif family=='shadow'then
   local offset=Vector3.new(math.cos(a),math.sin(a),0)*.9;v.cf=CFrame.new(offset)*v.cf.Rotation
   v.velocity=-offset*2;v.gravity=0
  elseif family=='web'then
   v.silkAxis=Vector3.new(math.cos(i*math.pi/3),math.sin(i*math.pi/3),0)
  end
 end
 local surface=position
 if normal and normal.Magnitude>.001 then normal=normal.Unit;surface+=normal*.8 else normal=nil end
 r.cf=normal and CFrame.lookAt(surface,surface+normal)or CFrame.new(surface);r.burst=true
 Art.attach(r);V.pose(r,r.cf,0,1)
 return r
end
local function crest(r,cf,height)
 local e=r.profile.element;local m=r.profile.motif
 if m=='web'then
  for _,angle in ipairs({-.55,.55})do part(r,'SilkLattice',Vector3.new(1.1,.045,.045),cf*CFrame.Angles(0,angle,0),nil,nil,.2)end
 elseif e=='frost'then
  part(r,'IceSpire',Vector3.new(.35,height,.4),cf*CFrame.new(0,height*.5,0),'wedge')
  part(r,'IceFacet',Vector3.new(.18,height*.6,.3),cf*CFrame.new(.2,height*.3,0)*CFrame.Angles(0,0,-.35),'wedge',Color3.fromRGB(220,250,255),.35)
 elseif e=='fire'then
  part(r,'FlameJet',Vector3.new(.45,height,.4),cf*CFrame.new(0,height*.5,0),'wedge')
  part(r,'HotCore',Vector3.new(.18,height*.55,.2),cf*CFrame.new(0,height*.3,0),'wedge',Color3.fromRGB(255,228,108),.25)
 elseif e=='venom'then
  part(r,'AcidSplash',Vector3.new(.65,.18,.65),cf*CFrame.new(0,.1,0),'ball',nil,.35)
  part(r,'AcidFang',Vector3.new(.16,height*.6,.2),cf*CFrame.new(0,height*.3,0),'wedge')
 elseif e=='soul' or e=='arcane' or e=='shadow'then
  for _,angle in ipairs({-.65,.65})do part(r,'RunicBrand',Vector3.new(.13,height,.08),cf*CFrame.new(0,height*.5,0)*CFrame.Angles(0,0,angle))end
 elseif m=='root'then
  part(r,'RootThorn',Vector3.new(.3,height,.5),cf*CFrame.new(0,height*.5,0)*CFrame.Angles(.2,0,.35),'wedge',Color3.fromRGB(161,201,101))
 else
  local p=part(r,'StoneDebris',Vector3.new(.45,height*.45,.45),cf*CFrame.new(0,height*.25,0)*CFrame.Angles(.2,.4,.2),nil,Color3.fromRGB(158,135,105))
  if p then p.Material=Enum.Material.Slate end
 end
end
function V.pulse(d,position,direction,now,owner,sequence)
 local r=make(d,'pulse',owner,sequence,now,.65);if not r then return end
 local cf=CFrame.lookAt(position,position+direction)
 -- Shape ornaments stay on the authoritative footprint, including the safe ring center.
 if d.shape=='ring'then
  for i=1,8 do local a=i*math.pi/4;crest(r,CFrame.new(math.cos(a)*d.radius*.94,0,math.sin(a)*d.radius*.94)*CFrame.Angles(0,a,0),1.1)end
  -- Short radial cracks occupy the real hazardous band, never its safe center.
  local band=d.radius-d.innerRadius
  if band>1 then
   local middle=(d.radius+d.innerRadius)*.5;local length=math.min(band*.5,2)
   for i=1,8 do
    local a=(i-.5)*math.pi/4;local axis=Vector3.new(math.cos(a),0,math.sin(a));local at=axis*middle+Vector3.yAxis*.08
    part(r,'HazardBandCrack',Vector3.new(.09,.045,length),CFrame.lookAt(at,at+axis),nil,nil,.32)
   end
  end
 elseif d.shape=='circle'or d.shape=='trail'then
  for i=1,7 do local a=i*math.pi*2/7;crest(r,CFrame.new(math.cos(a)*d.radius*.65,0,math.sin(a)*d.radius*.65)*CFrame.Angles(0,a,0),1.6)end
 elseif d.shape=='line'then
  for i=1,7 do crest(r,CFrame.new(0,0,-d.range*i/8),1.2)end
 else
  for i=1,7 do local a=math.rad(-d.angle/2+d.angle*i/8);crest(r,CFrame.new(math.sin(a)*d.range*.75,0,-math.cos(a)*d.range*.75)*CFrame.Angles(0,-a,0),.7)end
 end
 -- Motif above the footprint; never fill a safe ring hole with a center explosion.
 if d.shape~='ring'then
  local first=#r.parts;motif(r)
  for i=first+1,#r.parts do local v=r.parts[i];v.cf=CFrame.new(0,.65,0)*v.cf end
 end
 r.cf=cf;r.pulse=true;Art.attach(r);V.pose(r,cf,0,1)
 return r
end
function V.step(now)
 for i=#records,1,-1 do
  local r=records[i];local age=now-r.at
  local h=r.owner and r.owner:FindFirstChildOfClass('Humanoid')
  local invalid=r.owner and (not r.owner:IsDescendantOf(workspace)or h and h.Health<=0 or r.sequence and r.owner:GetAttribute('K0AttackSeq')~=r.sequence)
  if r.dead or not r.model.Parent or age>r.life or invalid then remove(r);table.remove(records,i)
  elseif r.cf then
   local u=math.clamp(age/r.life,0,1)
   V.pose(r,r.cf,age,1,u*u)
  end
 end
end
function V.cancel(owner,sequence)
 for i=#records,1,-1 do local r=records[i];if r.owner==owner and (not sequence or r.sequence==sequence)then remove(r);table.remove(records,i)end end
end
function V.clear()for _,r in ipairs(records)do remove(r)end;table.clear(records)end
function V.count()prune();return #records,budget end
return V
