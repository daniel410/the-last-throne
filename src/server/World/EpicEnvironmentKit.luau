-- Script-free, anchored scenery; authoritative walkable surfaces stay in world modules.
local Kit={}
local Env=require(script.Parent.DeepwoodEnvironment)
local Content=require(game.ReplicatedStorage.Shared.CampaignContent)
local Access=require(game.ReplicatedStorage.Shared.CampaignAccess)
local Bounds=require(game.ReplicatedStorage.Shared.CampaignBounds)
local function blocksWalkable(model)
 -- Check the final rotated mesh footprint against every zone, including neighbors.
 local cf,size=model:GetBoundingBox();local low=Vector3.new(math.huge,math.huge,math.huge);local high=-low
 for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do for _,z in ipairs({-1,1})do
  local p=cf:PointToWorldSpace(size*Vector3.new(x,y,z)/2)
  low=Vector3.new(math.min(low.X,p.X),math.min(low.Y,p.Y),math.min(low.Z,p.Z))
  high=Vector3.new(math.max(high.X,p.X),math.max(high.Y,p.Y),math.max(high.Z,p.Z))
 end end end
 for _,zone in pairs(Content.zones)do
  local c,s=zone.center,zone.size
  if low.Y<c[2]+18 and high.Y>c[2]+.5 and low.X<c[1]+s[1]/2+8 and high.X>c[1]-s[1]/2-8 and low.Z<c[3]+s[2]/2+8 and high.Z>c[3]-s[2]/2-8 then return true end
  -- Expanded incident wings live beyond the original zone rectangle. Their
  -- floors and approaches are equally real and cannot be filled by a cliff.
  for _,area in ipairs(zone.expansionAreas or {})do
   for _,rect in ipairs({area,area.connector})do
    local ac,sz=rect.center,rect.size
    local minY,maxY=ac[2],ac[2]
    if rect.rampStart then minY=math.min(rect.rampStart[2],rect.rampEnd[2]);maxY=math.max(rect.rampStart[2],rect.rampEnd[2])end
    if low.Y<maxY+18 and high.Y>minY+.5 and low.X<ac[1]+sz[1]/2+8 and high.X>ac[1]-sz[1]/2-8 and low.Z<ac[3]+sz[2]/2+8 and high.Z>ac[3]-sz[2]/2-8 then return true end
   end
  end
 end
 local center=(low+high)/2;local radius=Vector3.new(high.X-low.X,0,high.Z-low.Z).Magnitude/2
 for _,edge in ipairs(Access.edges)do
  local aa,bb=Bounds.ends(edge);local a,b=Vector3.new(table.unpack(aa)),Vector3.new(table.unpack(bb));local d=Vector3.new(b.X-a.X,0,b.Z-a.Z)
  local t=math.clamp(Vector3.new(center.X-a.X,0,center.Z-a.Z):Dot(d)/math.max(.001,d:Dot(d)),0,1)
  local p=a:Lerp(b,t)
  if low.Y<math.max(a.Y,b.Y)+18 and high.Y>math.min(a.Y,b.Y)+.5 and Vector3.new(center.X-p.X,0,center.Z-p.Z).Magnitude<Bounds.trailHalfWidth+radius+8 then return true end
 end
 return false
end
local C=Color3.fromRGB
Kit.palette={
 Deepwood={rock=C(94,112,91),trim=C(166,175,139),ground=C(95,126,70),leaf=C(97,137,65),wood=C(88,69,43),accent=C(237,187,87)},
 FrozenVale={rock=C(72,100,128),trim=C(172,210,229),ground=C(222,236,242),leaf=C(57,99,103),wood=C(77,74,78),accent=C(255,189,94)},
 EmberCaldera={rock=C(62,55,65),trim=C(116,99,102),ground=C(78,66,70),leaf=C(96,69,70),wood=C(61,56,64),accent=C(246,129,54)},
 Gloamwood={rock=C(66,81,83),trim=C(123,145,136),ground=C(55,77,65),leaf=C(44,76,65),wood=C(66,62,58),accent=C(162,210,187)},
 HauntedGraveyard={rock=C(76,81,99),trim=C(155,160,174),ground=C(89,105,98),leaf=C(69,79,83),wood=C(66,63,75),accent=C(157,223,202)},
}
function Kit.part(parent,name,size,cf,color,material,shape)
 local p=Instance.new(shape=='Wedge' and 'WedgePart' or shape=='Corner' and 'CornerWedgePart' or 'Part');p.Name=name;p.Size=size;p.CFrame=typeof(cf)=='CFrame' and cf or CFrame.new(cf)
 p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Material=material or Enum.Material.Slate;p.Color=color
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute('TLTDecorative',true)
 if shape=='Ball' then p.Shape=Enum.PartType.Ball end
 p.CastShadow=size.Y>2;p.Parent=parent;return p
end
function Kit.beam(parent,name,a,b,width,color,material)
 return Kit.part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,material)
end
function Kit.rock(parent,p,size,col,seed)
 if size.Y>25 then
  local node=parent;local theme
  while node and not theme do theme=node:GetAttribute('Theme');node=node.Parent end
  local name=theme=='FrozenVale' and 'SnowCliff' or theme=='EmberCaldera' and 'VolcanoCliff' or theme=='HauntedGraveyard' and 'CemeteryCliff' or 'CliffRock'
  local m=Env.asset(parent,name,p-Vector3.new(0,size.Y*.5,0),size.Y)
  local bounds=m:GetBoundingBox();m:PivotTo(CFrame.new(p)*CFrame.Angles(math.pi,seed*.71,.08*math.sin(seed))*bounds:ToObjectSpace(m:GetPivot()))
  if blocksWalkable(m)then m:Destroy();return nil end
  m:SetAttribute('WalkableSceneryChecked',true)
  -- TD geometry is shared; baked grassy cliff textures are inappropriate for ice/ash/graves.
  for _,part in ipairs(m:GetDescendants())do if part:IsA('MeshPart')then
   part:SetAttribute('TDOriginalTexture',part.TextureID);part.TextureID='';part.Material=theme=='FrozenVale' and Enum.Material.Glacier or Enum.Material.Slate
   part.Color=col;part:SetAttribute('TLTMaterialVariant',theme or 'Deepwood')
  end end
  return m
 end
 local cf=CFrame.new(p)*CFrame.Angles(.09*math.sin(seed),seed*.71,.12*math.cos(seed))
 return Kit.part(parent,'FacetedOutcrop',size,cf,col,Enum.Material.Slate,'Wedge')
end
function Kit.pine(parent,p,h,pal,snow)
 Kit.part(parent,'PineTrunk',Vector3.new(h*.08,h*.75,h*.08),p+Vector3.new(0,h*.375,0),pal.wood,Enum.Material.Wood)
 for tier=1,3 do
  local width=h*(.68-tier*.13);local height=h*.33;local y=h*(.2+tier*.18)
  for k=0,3 do
   local angle=k*math.pi/2
   local cf=CFrame.new(p+Vector3.new(0,y,0))*CFrame.Angles(0,angle,0)*CFrame.new(-width/4,0,width/4)
   Kit.part(parent,'PineBough',Vector3.new(width/2,height,width/2),cf,pal.leaf,Enum.Material.Grass,'Corner')
   if snow then Kit.part(parent,'BoughSnow',Vector3.new(width*.43,height*.7,width*.43),cf*CFrame.new(width*.035,height*.18,-width*.035),pal.ground,Enum.Material.Snow,'Corner')end
  end
 end
end
function Kit.tree(parent,p,h,pal,dead)
 local trunk={p,p+Vector3.new(2,h*.24,-1),p+Vector3.new(-2,h*.51,2),p+Vector3.new(1,h*.77,0)}
 for i=1,3 do Kit.beam(parent,'WeatheredTrunk',trunk[i],trunk[i+1],h*(.13-i*.018),pal.wood,Enum.Material.Wood)end
 for j=1,3 do
  local angle=j*2.18;local d=Vector3.new(math.cos(angle),0,math.sin(angle))
  local a=trunk[3];local b=a+d*h*.18+Vector3.new(0,h*.08,0);local c=p+d*h*.32+Vector3.new(0,h*(.76+j*.055),0)
  Kit.beam(parent,'CrookedBough',a,b,h*.052,pal.wood,Enum.Material.Wood)
  Kit.beam(parent,'TaperedBough',b,c,h*.029,pal.wood,Enum.Material.Wood)
  Kit.beam(parent,'BrokenTwig',b,b+Vector3.new(-d.Z*h*.1,h*.18,d.X*h*.1),h*.018,pal.wood,Enum.Material.Wood)
  local knee=p+d*h*.12+Vector3.new(0,3,0)
  Kit.beam(parent,'ExposedRoot',p+Vector3.new(0,6,0),knee,h*.06,pal.wood,Enum.Material.Wood)
  Kit.beam(parent,'RootTip',knee,p+d*h*.26,h*.035,pal.wood,Enum.Material.Wood)
  if not dead then Kit.part(parent,'ShadeCanopy',Vector3.new(h*.5,h*.2,h*.43),CFrame.new(c)*CFrame.Angles(.12,angle,.1),pal.leaf,Enum.Material.Grass,'Ball')end
 end
end
function Kit.lantern(parent,p,pal)
 Kit.part(parent,'LampPlinth',Vector3.new(3,1,3),p+Vector3.new(0,.5,0),pal.rock)
 Kit.part(parent,'LampPost',Vector3.new(.65,8,.65),p+Vector3.new(0,4,0),pal.wood,Enum.Material.Wood)
 Kit.part(parent,'LanternHousing',Vector3.new(2.6,3,2.6),p+Vector3.new(0,8,0),pal.rock,Enum.Material.Metal)
 Kit.part(parent,'LanternWindow',Vector3.new(2.7,1.8,2.7),p+Vector3.new(0,8,0),pal.accent,Enum.Material.Neon)
 Kit.part(parent,'LanternCap',Vector3.new(3.5,.7,3.5),p+Vector3.new(0,10,0),pal.trim)
 -- No per-lamp point light or particle emitter: luminous navigation at low graphics levels.
end
function Kit.arch(parent,p,width,height,pal)
 for _,s in ipairs({-1,1})do
  local base=p+Vector3.new(s*(width/2+4),0,0)
  Kit.part(parent,'ArchFoot',Vector3.new(13,3,14),base+Vector3.new(0,1.5,0),pal.trim)
  Kit.part(parent,'ArchPier',Vector3.new(8,height*.7,10),base+Vector3.new(0,height*.35,0),pal.rock)
  Kit.part(parent,'ArchCapital',Vector3.new(12,3,13),base+Vector3.new(0,height*.7,0),pal.trim)
  Kit.beam(parent,'ArchVoussoir',base+Vector3.new(0,height*.71,0),p+Vector3.new(s*width*.2,height*.96,0),7,pal.trim)
  Kit.part(parent,'CrownFinial',Vector3.new(4,12,5),base+Vector3.new(0,height*.82,0),pal.rock,Enum.Material.Slate,'Wedge')
 end
 Kit.part(parent,'ArchKeystone',Vector3.new(width*.44,6,10),p+Vector3.new(0,height,0),pal.trim)
end
function Kit.tower(parent,p,h,pal,style)
 Kit.part(parent,'TowerFoot',Vector3.new(32,4,32),p+Vector3.new(0,2,0),pal.trim)
 Kit.part(parent,'TowerShaft',Vector3.new(23,h,23),p+Vector3.new(0,h/2,0),pal.rock,Enum.Material.Brick)
 for _,s in ipairs({-1,1})do
  Kit.part(parent,'TowerButtress',Vector3.new(5,h*.7,7),p+Vector3.new(s*15,h*.35,0),pal.trim)
  Kit.part(parent,'TowerWindow',Vector3.new(4,h*.24,.3),p+Vector3.new(s*6,h*.65,11.7),pal.accent,Enum.Material.Neon)
 end
 Kit.part(parent,'TowerCornice',Vector3.new(29,4,29),p+Vector3.new(0,h,0),pal.trim)
 if style=='spire' then
  for s=0,1 do Kit.part(parent,'SpireRoof',Vector3.new(30,25,30),CFrame.new(p+Vector3.new(0,h+14,0))*CFrame.Angles(0,s*math.pi,0),pal.wood,Enum.Material.Slate,'Wedge')end
 else
  for x=-1,1 do for _,z in ipairs({-1,1})do Kit.part(parent,'Battlement',Vector3.new(5,7,5),p+Vector3.new(x*10,h+5,z*12),pal.rock)end end
 end
end
function Kit.hall(parent,p,pal,style)
 Kit.part(parent,'HallPlinth',Vector3.new(65,3,49),p+Vector3.new(0,1.5,0),pal.trim)
 -- A fully open facade leaves the interior readable from the route.
 Kit.part(parent,'HallBack',Vector3.new(56,28,5),p+Vector3.new(0,17,-19),pal.rock,Enum.Material.Brick)
 for _,s in ipairs({-1,1})do
  Kit.part(parent,'HallSide',Vector3.new(5,28,39),p+Vector3.new(s*27,17,0),pal.rock,Enum.Material.Brick)
  Kit.part(parent,'HallButtress',Vector3.new(8,20,11),p+Vector3.new(s*33,10,7),pal.trim)
  Kit.part(parent,'HallRoof',Vector3.new(35,3,54),CFrame.new(p+Vector3.new(s*14,37,0))*CFrame.Angles(0,0,s*-.48),pal.wood,Enum.Material.Slate)
  Kit.part(parent,'HallWindow',Vector3.new(6,12,.3),p+Vector3.new(s*13,20,-16.3),pal.accent,Enum.Material.Neon)
 end
 Kit.arch(parent,p+Vector3.new(0,3,21),25,27,pal)
 if style=='chapel' then Kit.tower(parent,p+Vector3.new(-24,0,-13),54,pal,'spire')end
end
function Kit.web(parent,a,b,c,pal)
 local center=(a+b+c)/3;local perimeter={}
 for _,edge in ipairs({{a,b},{b,c},{c,a}})do for i=0,3 do table.insert(perimeter,edge[1]:Lerp(edge[2],i/4))end end
 local color=pal.trim:Lerp(Color3.new(1,1,1),.65)
 local function thread(name,from,to,width)
  local p=Kit.beam(parent,name,from,to,width,color,Enum.Material.Fabric);p.Transparency=.15;p.CastShadow=false
 end
 for _,p in ipairs(perimeter)do thread('WebRadial',center,p,.28)end
 for _,t in ipairs({.2,.4,.62,.82,1})do
  for i,p in ipairs(perimeter)do
   local q=perimeter[i%#perimeter+1]
   thread('WebSilkRing',center:Lerp(p,t),center:Lerp(q,t),.18)
  end
 end
end
return Kit
