-- World-space motifs taken from the authored skill icons. Shares HeroVFX budgets.
local Profiles=require(script.Parent.SkillIconVFXProfiles)
local Geometry=require(script.Parent.SkillEffectGeometry)
local Motifs={}
local UP=Vector3.yAxis
function Motifs.draw(r,id,c,line,curve)
 local p=Profiles[id];if not p then return end
 local cue,n,s=p.cue,p.count,p.scale
 -- Core silhouettes get priority. Motifs fit within the existing per-cast ceiling.
 local compact=id=='knight.paladin.dawn_burst' or id=='knight.paladin.dawn_spiral' or id=='knight.paladin.oath_of_dawn' or id=='mage_arcane_ward'
 local limit=compact and 24 or 48
 local function boundedLine(...)
  if #r.lines<limit then line(...)end
 end
 local function boundedCurve(record,name,fn,segments,width,color)
  local remaining=limit-#r.lines
  if remaining<2 then return end
  curve(record,name,fn,math.min(segments,remaining),width,color)
 end
 r.model:SetAttribute('IconCue',cue)
 -- Empty chain packets must never fabricate targets or a discharge.
 if c.definition.form=='chain' and #c.points==0 then return end
 local first,last,flat,right,floor=c.first,c.last,c.flat,c.right,c.floor
 local at=c.area and floor+UP*.15 or last
 local radius=math.min(c.radius*.55,4.5)*s
 local width=.065*s
 local function stroke(name,a,b,w,color)
  boundedLine(r,'Icon'..name,function(u)
   local travel=(cue=='infall' and -1 or 1)*u*.18
   return a+flat*travel,b+flat*travel
  end,w or width,color)
 end
 local function path(name,fn,segments,w,color)boundedCurve(r,'Icon'..name,fn,segments or 6,w or width,color)end
 local function diamond(name,center,side,up,size,color)
  local points={center+up*size,center+side*size*.45,center-up*size,center-side*size*.45}
  for i=1,4 do stroke(name,points[i],points[i%4+1],nil,color)end
 end
 local function shield(center,size,name)
  local pts={center+UP*size,center+right*size*.7+UP*size*.55,center+right*size*.55-UP*size*.4,center-UP*size,center-right*size*.55-UP*size*.4,center-right*size*.7+UP*size*.55}
  for i=1,6 do stroke(name,pts[i],pts[i%6+1])end
  stroke(name..'Spine',center-UP*size*.6,center+UP*size*.6,width*.7,r.hot)
 end
 local function leaf(center,axis,size,name)
  for side=-1,1,2 do path(name,function(t,u)
   return center+axis*(t*size)+right*(side*math.sin(t*math.pi)*size*.28)*(1-u*.3)
  end,4)end
  stroke(name..'Vein',center,center+axis*size,width*.6)
 end
 if cue=='kite' or cue=='guard' or cue=='front' or cue=='counter' or cue=='leafguard' then
  local center=first+flat*1.6
  if cue=='leafguard'then leaf(center-UP,UP,2*s,'LeafAegis')
  else shield(center,s,'KiteShield')end
  if cue=='front'then for side=-1,1,2 do shield(center+right*side*1.8,.65,'AlliedShield')end end
 elseif cue=='oath' or cue=='challenge' or cue=='dawn' or cue=='rally' or cue=='shout' then
  local center=first+flat*1.8+UP*.6
  if cue=='oath' or cue=='dawn'then diamond('OathDiamond',center,right,UP,.75*s)end
  if cue=='dawn'then
   shield(center-UP*1.1,s,'DawnAegis')
   for side=-1,1,2 do shield(center+right*side*1.9-UP*1.1,.55*s,'DawnAllies')end
  end
  for lane=1,n do
   path('ChallengeRay',function(t,u)
    local a=(-.65+lane*.33)+t*.45
    return center+(right*math.sin(a)+UP*math.cos(a))*(1+lane*.3+u*.6)*s
   end,4)
  end
 elseif cue=='orbit' or cue=='sweep' or cue=='hook' or cue=='dust' or cue=='tremor' or cue=='rings' or cue=='frostbreak' then
  local ground=cue=='dust' or cue=='tremor' or cue=='rings' or cue=='frostbreak'
  for lane=1,n do path(ground and 'OpenRim' or 'CutEcho',function(t,u)
   local a=t*(cue=='hook' and 2.6 or cue=='sweep' and 2.1 or 4.7)+lane*.5+u*.8
   local rad=(ground and radius or math.min(c.radius,5)*.65)*(.65+lane*.14)
   return (ground and floor+UP*.15 or first)+(flat*math.cos(a)+right*math.sin(a))*rad+UP*(ground and 0 or math.sin(t*math.pi)*.5)
  end,6)end
 elseif cue=='fracture' or cue=='shatter' or cue=='ridge' or cue=='blast' or cue=='shrapnel' or cue=='vents' then
  local center=c.area and floor+flat*(c.definition.form=='cone' and radius*.5 or 0) or last
  for lane=1,n do
   local a=lane*math.pi*2/n
   local dir=flat*math.cos(a)+right*math.sin(a)
   if cue=='vents'then
    path('LavaJet',function(t,u)return center+dir*(.6+t*t)*s+UP*(math.sin(t*math.pi*.8)*2.6*(1-u*.3))*s end,5,.11)
   elseif cue=='ridge' or cue=='fracture'then
    path('SplitFracture',function(t,u)return center+dir*(.2+t*1.8)*s+right*math.sin(t*9+lane)*.15*s+UP*(cue=='ridge' and math.sin(t*math.pi)*(1+lane*.3)*(1-u*.3) or .06)end,4)
   else
    path('SplitShard',function(t,u)
     local off=dir*(.25+u*.7+t*.8)*s+UP*(cue=='shrapnel' and t*1.4 or math.sin(t*math.pi)*.3)
     return center+off
    end,2,.1)
   end
  end
 elseif cue=='leaf' or cue=='bloom' or cue=='roots' then
  local center=cue=='leaf' and last-flat*1.4 or at
  for lane=1,n do
   local a=lane*math.pi*2/n;local axis=(right*math.cos(a)+UP*math.sin(a)).Unit
   if cue=='roots'then axis=(UP+right*math.cos(a)*.5).Unit;center=floor+flat*math.sin(a)*.7 end
   leaf(center,axis,(cue=='bloom' and 1.3 or 1)*s,'NatureLeaf')
  end
 elseif cue=='facet' or cue=='crystal' or cue=='shard' or cue=='lance' or cue=='dart' or cue=='stone' then
  local axis=(last-first).Magnitude>.01 and (last-first).Unit or flat
  local length=(cue=='dart' and 1.1 or cue=='crystal' and 2.5 or 1.7)*s
  local center=last-axis*length*.5
  diamond('ProjectileFacet',center,right,axis,length*.5)
  stroke('FacetSpine',last-axis*length,last,.09*s,r.hot)
  if cue~='dart'then stroke('FacetRidge',center+right*length*.22,last,.045,r.hot)end
 elseif cue=='molten'then
  local base=Vector3.new(first.X,floor.Y,first.Z)
  local delta=Vector3.new(last.X-first.X,0,last.Z-first.Z)
  path('MoltenSeam',function(t,u)return base+delta*t+UP*.08+right*math.sin(t*14)*.08 end,8,.09)
  for lane=1,n do
   local pos=base+delta*(lane/(n+1))+UP*.12
   stroke('MoltenPulse',pos-UP*.07,pos+UP*.3,.09,r.hot)
  end
 elseif cue=='ward'then
  diamond('WardGem',first+UP*1.5,right,UP,.45*s)
  for side=-1,1,2 do
   path('WardCrestArc',function(t,u)return first+right*side*(.3+t*.6)+UP*(1.5-t*.4+u*.15)end,2)
  end
 elseif cue=='drops' or cue=='vapor' or cue=='infall' or cue=='storm' then
  for lane=1,n do
   local a=lane*math.pi*2/n
   if cue=='drops'then
    local center=at+(right*math.cos(a)+UP*math.sin(a))*.9*s
    path('LiquidDrop',function(t,u)
     local theta=t*math.pi*2;return center+right*math.sin(theta)*.18+UP*(math.cos(theta)*.3+u*.45)
    end,6)
   elseif cue=='vapor'then
    path('VaporCurl',function(t,u)return floor+right*(lane-2)*.65+UP*(t*2+u*.65)+flat*math.sin(t*5+lane)*.35 end,5,.1,Color3.fromRGB(195,219,229))
   else
    path(cue=='infall' and 'GravityAccretion' or 'StormBand',function(t,u)
     local angle=t*math.pi*1.5+a+(cue=='infall' and -u*2 or u*.8)
     local rad=radius*.55*(cue=='infall' and (1-u*.75) or 1)
     return at+right*math.cos(angle)*rad+flat*math.sin(angle)*rad+UP*(cue=='storm' and lane*.7 or .45+math.sin(t*math.pi)*.8)
    end,6)
   end
  end
 elseif cue=='fan' then
  local targets=c.definition.form=='cone' and Geometry.sector(first,flat,c.radius,c.definition.angle or 60,n-1) or {last}
  if id=='elf.common.multi' and #c.points>0 then targets=c.points end
  for lane=1,math.min(#targets,7)do
   local target=targets[lane]
   if typeof(target)=='Vector3'then
    local axis=(target-first).Magnitude>.01 and (target-first).Unit or flat
    for side=-1,1,2 do stroke('FanFletch',target-axis*.9+right*side*.2,target-axis*.3,.055)end
   end
  end
 elseif cue=='echo' then
  for lane=1,n do
   local center=last-flat*(lane*.8)
   diamond('SpiritEcho',center,right,flat,.35)
  end
 elseif cue=='mark' or cue=='pin' then
  for lane=1,n do
   local a=lane*math.pi*2/n
   local radial=right*math.cos(a)+UP*math.sin(a)
   stroke(cue=='pin' and 'PinNotch' or 'AimNotch',last+radial*.45*s,last+radial*.8*s)
  end
 elseif cue=='electric'then
  -- Branches attach to confirmed chain nodes. Preserve the contracted blue lightning palette.
  local nodes=c.definition.form=='chain' and c.points or {last}
  for index=1,math.min(#nodes,3)do
   local center=nodes[index]
   if typeof(center)=='Vector3' then for side=-1,1,2 do
    local elbow=center+right*side*.4+UP*.35
    stroke('LightningProng',center,elbow,.065)
    stroke('LightningProng',elbow,elbow+right*side*.4-UP*.12,.04)
   end end
  end
 elseif cue=='rain' or cue=='ash' or cue=='hail'then
  -- Falling accents do not introduce extra damage pulses or hit markers.
  for lane=1,n do
   local a=lane*2.39996;local pos=floor+(flat*math.cos(a)+right*math.sin(a))*math.min(radius,3)*math.sqrt(lane/n)
   path('FallingFeather',function(t,u)
    local height=3.5*(1-u*u)+t*.7
    return pos+UP*height+right*math.sin(t*math.pi)*.12
   end,2)
  end
 else
  -- Directional feathers, chevrons, projectile echoes and explosive flight cues.
  local from,to=first,last
  if cue=='returning' and c.definition.returning and c.pulse%2==0 then from,to=last,first end
  local axis=(to-from).Magnitude>.01 and (to-from).Unit or flat
  if cue=='lob' or cue=='bounce' or cue=='roll' or cue=='barrage'then
   for lane=1,n do path('BallisticEcho',function(t,u)
    local height=cue=='roll' and .12 or math.abs(math.sin(t*math.pi*(cue=='bounce' and 2 or 1)))*(cue=='barrage' and 3 or 1.6)
    return from+(to-from)*t+UP*height+right*(lane-(n+1)/2)*.18
   end,6)end
  elseif cue=='cross' or cue=='pair'then
   for side=-1,1,2 do
    local offset=right*side*.6
    stroke('PairedPath',from+offset,to+(cue=='cross' and -offset or offset),.075)
   end
  else
   local moving=cue=='drive' or cue=='glide' or cue=='retreat' or cue=='recoil' or cue=='step' or cue=='leap'
   local center=moving and first or to-axis*.7
   local direction=(cue=='retreat' or cue=='recoil') and -axis or axis
   for lane=1,n do
    local offset=right*(lane-(n+1)/2)*.5
    for side=-1,1,2 do
     path(cue=='pierce' and 'PiercingFletch' or cue=='muzzle' and 'MuzzleRay' or 'SpeedFeather',function(t,u)
      return center+offset-direction*(1-t)*1.1*s+right*side*(1-t)*.24*s+direction*u*.35
     end,2)
    end
   end
  end
 end
end
return Motifs
