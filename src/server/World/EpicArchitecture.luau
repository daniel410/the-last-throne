-- Repo-native modular architecture. Constructed outside the encounter footprint.
local K=require(script.Parent.EpicEnvironmentKit)
local Env=require(script.Parent.DeepwoodEnvironment)
local A={}
local V=Vector3.new
local function part(parent,name,size,cf,color,material,shape)return K.part(parent,name,size,cf,color,material,shape)end
local function model(parent,name)
 local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=parent;return m
end
function A.roof(parent,p,width,height,depth,color)
 -- CornerWedge high vertex is +X/+Y/-Z; align all four high vertices at the apex.
 for i=0,3 do
  local cf=CFrame.new(p+V(0,height/2,0))*CFrame.Angles(0,i*math.pi/2,0)*CFrame.new(-width/4,0,width/4)
  part(parent,'PyramidalRoof',V(width/2,height,width/2),cf,color,Enum.Material.Slate,'Corner')
 end
end
function A.gable(parent,p,width,height,depth,pal)
 for _,side in ipairs({-1,1})do
  part(parent,'CarvedGable',V(3,height,width/2),CFrame.new(p+V(side*width/4,height/2,0))*CFrame.Angles(0,-side*math.pi/2,0),pal.rock,Enum.Material.Brick,'Wedge')
  part(parent,'NaveRoof',V(width*.68,3,depth),CFrame.new(p+V(side*width*.24,height*.5,-depth/2))*CFrame.Angles(0,0,-side*.68),pal.wood,Enum.Material.Slate)
  K.beam(parent,'GableRakingCornice',p+V(side*width/2,0,2),p+V(0,height,2),2.3,pal.trim)
 end
 part(parent,'RoofRidge',V(3,3,depth+4),p+V(0,height,-depth/2),pal.trim)
end
function A.rose(parent,p,r,pal)
 local pane=part(parent,'RoseGlass',V(r*1.64,r*1.64,.8),p,Color3.fromRGB(236,186,126),Enum.Material.Neon,'Ball')
 for i=0,15 do
  local a=i*math.pi/8;local b=(i+1)*math.pi/8
  K.beam(parent,'RoseArchivolt',p+V(math.cos(a)*r,math.sin(a)*r,1),p+V(math.cos(b)*r,math.sin(b)*r,1),2.1,pal.trim)
  if i%2==0 then K.beam(parent,'RoseTracery',p+V(0,0,1.5),p+V(math.cos(a)*r*.87,math.sin(a)*r*.87,1.5),.65,pal.rock)end
 end
 return pane
end
function A.arch(parent,p,width,height,pal,depth)
 local spring=height*.52;depth=depth or 5
 for _,side in ipairs({-1,1})do
  for j=0,2 do part(parent,'PierCourse',V(6,spring/3-.2,depth+2),p+V(side*(width/2+3),spring*(j+.5)/3,0),j==0 and pal.trim or pal.rock,Enum.Material.Brick)end
  part(parent,'ArchImpost',V(9,2.2,depth+4),p+V(side*(width/2+3),spring,0),pal.trim)
  local prev=p+V(side*(width/2+3),spring,0)
  for i=1,6 do
   local t=i/6;local q=p+V(side*(width/2+3)*(1-t)^1.2,spring+(height-spring)*math.sin(t*math.pi/2),0)
   local beam=K.beam(parent,'ArchStone',prev,q,4.5,pal.trim);beam.Size=V(4.5,depth,(q-prev).Magnitude+.4);prev=q
  end
 end
 part(parent,'Crownstone',V(6,7,depth+2),p+V(0,height,0),pal.trim)
end
local function window(parent,p,width,height,pal,warm)
 local glass=(warm or pal==K.palette.HauntedGraveyard)and Color3.fromRGB(245,192,125)or pal.accent
 part(parent,'Recess',V(width+3,height+3,.9),p,pal.rock:Lerp(Color3.new(0,0,0),.3))
 part(parent,'Glass',V(width,height,.95),p+V(0,0,.16),glass,Enum.Material.Neon)
 part(parent,'WindowMullion',V(.7,height+1,1.2),p+V(0,0,.7),pal.trim)
 part(parent,'WindowTransom',V(width+2,.8,1.3),p+V(0,-height*.15,.8),pal.trim)
 part(parent,'WindowSill',V(width+5,1.5,3),p+V(0,-height/2-1,1),pal.trim)
 -- A pointed hood makes the facade readable as a temple/citadel at gameplay distance.
 for _,s in ipairs({-1,1})do K.beam(parent,'WindowHood',p+V(s*(width/2+1),height/2,1),p+V(0,height/2+width*.55,1),1.5,pal.trim)end
end
function A.tower(parent,p,height,pal,spire)
 local m=model(parent,'DressedTower');local r=15;local width=2*r*math.tan(math.pi/8)
 for i=0,7 do
  local cf=CFrame.new(p)*CFrame.Angles(0,i*math.pi/4,0)
  part(m,'OctagonalWall',V(width,height,3),cf*CFrame.new(0,height/2,r),pal.rock,Enum.Material.Brick)
  for _,tier in ipairs({1,2,3})do
   part(m,'StoneStringcourse',V(width+2,2.1,5),cf*CFrame.new(0,height*tier/4,r),pal.trim)
  end
  part(m,'TowerPlinth',V(width+4,4,6),cf*CFrame.new(0,2,r),pal.trim)
  part(m,'ParapetCoping',V(width+3,3,6),cf*CFrame.new(0,height,r),pal.trim)
  if i%2==0 then
   -- Windows face radially outward, retaining a shallow real recess.
   local pane=model(m,'ArrowSlit');window(pane,V(0,height*.65,0),3,12,pal,false)
   pane:PivotTo(cf*CFrame.new(0,0,r+2)*pane:GetPivot())
  end
 end
 for _,side in ipairs({-1,1})do
  local q=p+V(side*18,0,0)
  part(m,'FlyingButtress',V(6,height*.64,10),q+V(0,height*.32,0),pal.trim,Enum.Material.Slate,'Wedge')
 end
 if spire then A.roof(m,p+V(0,height+1,0),38,35,38,pal.wood);part(m,'SpireFinial',V(1.8,14,1.8),p+V(0,height+41,0),pal.trim,Enum.Material.Metal)
 else for i=0,7 do part(m,'Crenellation',V(6,7,6),CFrame.new(p)*CFrame.Angles(0,i*math.pi/4,0)*CFrame.new(0,height+4,r),pal.rock)end end
 return m
end
local function banner(parent,p,pal)
 part(parent,'BannerRail',V(8,.5,.7),p+V(0,10,0),pal.trim,Enum.Material.Metal)
 part(parent,'RoyalBanner',V(7,16,.3),p,Color3.fromRGB(32,62,99),Enum.Material.Fabric)
 for _,x in ipairs({-1,1})do part(parent,'BannerGoldEdge',V(.35,16,.4),p+V(x*3.2,0,.2),pal.accent)end
 for i=-1,1 do part(parent,'CrownTooth',V(1,2+i%2,1),p+V(i*1.3,1,.4),pal.accent,Enum.Material.Metal)end
 part(parent,'CrownBand',V(5,1,1),p+V(0,-1,.5),pal.accent,Enum.Material.Metal)
end
function A.flame(parent,p,pal,warm)
 local m=model(parent,'Brazier')
 part(m,'FirePedestal',V(4,8,4),p+V(0,4,0),pal.rock)
 part(m,'BronzeBowl',V(7,2,7),p+V(0,9,0),pal.trim,Enum.Material.Metal,'Ball')
 local col=warm and Color3.fromRGB(255,179,80)or pal.accent
 local flame=part(m,'BrazierFlame',V(2.5,5,2.5),CFrame.new(p+V(0,12,0))*CFrame.Angles(0,.6,.1),col,Enum.Material.Neon,'Corner')
 local light=Instance.new('PointLight');light.Name='LocalBrazierLight';light.Range=25;light.Brightness=1.35;light.Color=col;light.Shadows=false;light:SetAttribute('TLTDecorative',true);light.Parent=flame
 return m
end
local function wing(parent,p,width,height,pal,theme)
 local m=model(parent,'ArcadedWing');local bays=math.max(2,math.floor(width/23));local step=width/bays
 part(m,'WingWall',V(width,height,8),p+V(0,height/2,-5),pal.rock,Enum.Material.Brick)
 for i=0,bays do
  local q=p+V(-width/2+i*step,0,0)
  part(m,'ButtressBase',V(8,3,14),q+V(0,1.5,0),pal.trim)
  part(m,'ButtressShaft',V(4,height+5,9),q+V(0,(height+5)/2,0),pal.trim)
  part(m,'ButtressCap',V(6,3,12),q+V(0,height+5,0),pal.rock)
  if i<bays then window(m,q+V(step/2,height*.6,.3),7,height*.43,pal,theme=='Deepwood')end
 end
 for j=0,2 do part(m,'ContinuousCornice',V(width+10,2,12+j*2),p+V(0,height+j*2,0),j==1 and pal.trim or pal.rock)end
 for _,s in ipairs({-1,1})do part(m,'PitchedSlateRoof',V(width+8,3,24),CFrame.new(p+V(0,height+10,s*9-6))*CFrame.Angles(s*.55,0,0),pal.wood,Enum.Material.Slate)end
 return m
end
function A.citadel(parent,c,size,pal,theme,index)
 local m=model(parent,'EpicCitadel');local p=c+V(0,0,-size[2]/2-32)
 local h=theme=='HauntedGraveyard' and 94 or 76
 local w=math.clamp(size[1]*.63,230,350)
 -- Full architectural backdrop, with a central vaulted entry and flanking buildings.
 for _,s in ipairs({-1,1})do
  A.tower(m,p+V(s*(w/2+5),0,-10),h+(s==1 and 13 or 0),pal,theme=='HauntedGraveyard' or theme=='Gloamwood')
  wing(m,p+V(s*(w/4+22),0,0),w/2-46,34+(index%3)*3,pal,theme)
  banner(m,p+V(s*47,22,8),pal)
 end
 A.arch(m,p+V(0,0,4),65,59,pal,11)
 -- Recessed gate is a backdrop, not a second interactable story door.
 -- The final ice palace opens onto the Caldera road; its arch must stay open.
 if not (theme=='FrozenVale' and index==7)then
  part(m,'GateRecess',V(57,49,3),p+V(0,24,-9),pal.rock:Lerp(Color3.new(0,0,0),.62))
  for x=-24,24,8 do part(m,'GateIronwork',V(.7,42,1),p+V(x,21,-6),pal.trim,Enum.Material.Metal)end
 end
 if theme=='HauntedGraveyard'then
  part(m,'CathedralClerestory',V(68,42,18),p+V(0,82,-7),pal.rock,Enum.Material.Brick)
  for _,s in ipairs({-1,1})do part(m,'NaveButtress',V(6,106,22),p+V(s*36,53,-6),pal.trim)end
  A.rose(m,p+V(0,82,3),12,pal);A.gable(m,p+V(0,104,4),78,32,70,pal)
  part(m,'NaveFinial',V(2,14,2),p+V(0,142,5),pal.trim,Enum.Material.Metal)
 else
  -- Tie every merlon to a continuous lintel and grounded side piers.
  for _,side in ipairs({-1,1})do part(m,'GateUpperPier',V(10,64,15),p+V(side*38,32,0),pal.rock,Enum.Material.Brick)end
  part(m,'GateParapetBeam',V(86,8,15),p+V(0,60,0),pal.trim)
  for x=-30,30,10 do part(m,'GateBattlement',V(6,8,8),p+V(x,65,0),pal.rock)end
 end
 for _,s in ipairs({-1,1})do A.flame(m,p+V(s*58,0,27),pal,theme=='FrozenVale')end
 return m
end
function A.cloister(parent,c,size,pal,index)
 local m=model(parent,'LostCloister');local p=c+V(0,0,-size[2]/2-26)
 for i=-2,2 do
  A.arch(m,p+V(i*46,0,0),34,43+((i+index)%2)*3,pal,6)
  for j=0,1 do part(m,'CloisterCornice',V(49,2,10+j*2),p+V(i*46,47+j*2,0),pal.trim)end
 end
 local towerX=index==4 and -133 or 133
 A.tower(m,p+V(towerX,0,-5),82,pal,false)
 banner(m,p+V(towerX,35,20),pal)
 -- A timber ranger lodge occupies the flank rather than an isolated cube in the distance.
 local q=c+V(-size[1]/2-15,0,40)
 A.cabin(m,q,pal,false)
 return m
end
function A.cabin(parent,p,pal,snow)
 local m=model(parent,'TimberRefuge')
 for _,s in ipairs({-1,1})do
  part(m,'LodgeWall',V(3,23,37),p+V(s*23,12,0),pal.wood,Enum.Material.WoodPlanks)
  for j=0,2 do part(m,'LodgeTimberBand',V(4,1.3,39),p+V(s*23,4+j*8,0),pal.trim,Enum.Material.Wood)end
  part(m,'ShelterRoof',V(29,2,46),CFrame.new(p+V(s*12,30,0))*CFrame.Angles(0,0,s*-.55),snow and pal.ground or pal.wood,Enum.Material.Slate)
  part(m,'PorchPost',V(2,21,2),p+V(s*23,10.5,26),pal.trim,Enum.Material.Wood)
  window(m,p+V(s*15,13,-18),5,8,pal,true)
 end
 part(m,'LodgeBack',V(45,23,3),p+V(0,12,-18),pal.wood,Enum.Material.WoodPlanks)
 part(m,'LodgeHeader',V(47,6,3),p+V(0,22,19),pal.trim,Enum.Material.Wood)
 part(m,'PorchAwning',V(51,2,14),CFrame.new(p+V(0,23,24))*CFrame.Angles(-.15,0,0),pal.wood,Enum.Material.WoodPlanks)
 A.flame(m,p+V(0,0,26),pal,true)
 return m
end
function A.foundry(parent,c,size,pal,index)
 -- Leave the eastern exit from the final furnace clear of the facade/chimneys.
 local m=model(parent,'GreatFoundry');local p=c+V(index==7 and -200 or 0,0,-size[2]/2-38)
 for _,s in ipairs({-1,1})do
  wing(m,p+V(s*94,0,0),100,40,pal,'EmberCaldera')
  for i=0,1 do
   local q=p+V(s*(84+i*47),0,-27);local h=92+index*3+i*11
   part(m,'FurnaceChimney',V(19,h,21),q+V(0,h/2,0),pal.rock,Enum.Material.Brick)
   for j=1,4 do part(m,'ChimneyBand',V(24,3,26),q+V(0,h*j/4,0),pal.trim,Enum.Material.Metal)end
   part(m,'StackEmber',V(12,1,14),q+V(0,h+1,0),pal.accent,Enum.Material.Neon)
   for j=1,3 do part(m,'HeatSlit',V(2,15,1),q+V(j*4-8,15,11),pal.accent,Enum.Material.Neon)end
  end
 end
 A.arch(m,p+V(0,0,0),72,56,pal,15)
 part(m,'FurnaceInterior',V(64,44,3),p+V(0,22,-12),Color3.fromRGB(67,31,26))
 for i=-2,2 do part(m,'FurnaceGlow',V(5,30,1),p+V(i*10,17,-9),pal.accent,Enum.Material.Neon)end
 for _,s in ipairs({-1,1})do
  local q=c+V(s*(size[1]/2+18),0,25)
  for i=0,4 do
   local z=130-i*65
   part(m,'PipeSupport',V(5,28,6),q+V(0,14,z),pal.trim,Enum.Material.Metal)
   K.beam(m,'PipeBrace',q+V(-13,0,z),q+V(0,25,z),2,pal.trim,Enum.Material.Metal)
  end
  local pipe=K.beam(m,'CoolantMain',q+V(0,29,-145),q+V(0,29,145),7,pal.trim,Enum.Material.Metal)
  for i=0,5 do
   part(m,'PipeJoint',V(10,10,3),q+V(0,29,120-i*48),pal.rock,Enum.Material.Metal)
  end
  A.flame(m,c+V(s*116,0,120),pal,true)
 end
 return m
end
function A.grave(parent,p,pal,kind)
 local m=model(parent,kind==1 and 'Sarcophagus' or 'CarvedHeadstone')
 if kind==1 then
  part(m,'TombPlinth',V(10,1,18),p+V(0,.5,0),pal.trim)
  part(m,'SarcophagusChest',V(8,4,15),p+V(0,3,0),pal.rock,Enum.Material.Brick)
  part(m,'TombLid',V(10,2,17),p+V(0,6,0),pal.trim)
  for _,s in ipairs({-1,1})do part(m,'LidBevel',V(2,2,17),CFrame.new(p+V(s*4.5,6,0))*CFrame.Angles(0,0,s*.3),pal.trim)end
 else
  part(m,'GraveKerb',V(9,.5,16),p+V(0,.25,3),pal.trim)
  part(m,'GraveSoil',V(7,.1,13),p+V(0,.55,3),pal.ground,Enum.Material.Ground)
  part(m,'StoneBase',V(8,1.8,4),p+V(0,.9,-4),pal.rock)
  part(m,'Headstone',V(6,9,2.5),p+V(0,5.5,-4),pal.trim)
  A.roof(m,p+V(0,10,-4),7,3,7,pal.rock)
  part(m,'NamePlaque',V(3.5,2,.2),p+V(0,6,-2.65),pal.rock)
 end
 return m
end
function A.ruin(parent,c,size,pal,index)
 local m=model(parent,'RootboundMonastery');local p=c+V(0,0,-size[2]/2-22)
 for i=-2,2 do
  if i~=1 or index==7 then A.arch(m,p+V(i*48,0,0),36,42+(i%2)*5,pal,8)
  else part(m,'BrokenArchStump',V(10,24,12),p+V(i*48-20,12,0),pal.rock)end
 end
 A.tower(m,p+V(140,0,-7),68,pal,true)
 for _,s in ipairs({-1,1})do
  local q=c+V(s*(size[1]/2+15),0,-55)
  local tree=Env.asset(m,'ForestLandmark',q,105)
  for i=1,3 do local angle=i*2.1;Env.crown(m,q+V(math.cos(angle)*21,67+i*3,math.sin(angle)*21),63,pal.leaf)end
  for _,v in ipairs(tree:GetDescendants())do if v:IsA('MeshPart')and (v.Name:find('foliage')or v.Name:find('canopy'))then v.TextureID='';v.Color=pal.leaf;v.Material=Enum.Material.Grass end end
  local a=q+V(0,63,0);local b=p+V(s*90,35,0);local cc=q+V(-s*27,10,88)
  K.web(m,a,b,cc,pal)
 end
 return m
end
function A.entry(parent,c,size,pal)
 local p=c+V(0,0,size[2]/2-10);local m=model(parent,'ProcessionalGate')
 A.arch(m,p,94,44,pal,9)
 for _,side in ipairs({-1,1})do
  local q=p+V(side*57,0,0)
  part(m,'GatePier',V(13,42,15),q+V(0,21,0),pal.rock,Enum.Material.Brick)
  for j=1,3 do part(m,'PierMoulding',V(17,2,19),q+V(0,j*13,0),pal.trim)end
  A.roof(m,q+V(0,43,0),20,14,20,pal.wood)
  banner(m,q+V(0,24,8.3),pal)
 end
 return m
end
function A.mausoleum(parent,p,pal)
 local m=model(parent,'RoyalMausoleum')
 part(m,'CryptPlinth',V(34,4,32),p+V(0,2,0),pal.trim)
 part(m,'CryptRearWall',V(28,22,4),p+V(0,15,-12),pal.rock,Enum.Material.Brick)
 for _,side in ipairs({-1,1})do
  part(m,'CryptSideWall',V(4,22,28),p+V(side*12,15,0),pal.rock,Enum.Material.Brick)
  for j=0,1 do
   local q=p+V(side*14,0,j*19-7)
   part(m,'CryptColumnFoot',V(7,2,7),q+V(0,4,0),pal.trim)
   part(m,'CryptColumn',V(3,23,4),q+V(0,16,0),pal.trim)
   part(m,'CryptCapital',V(6,3,7),q+V(0,27,0),pal.trim)
  end
 end
 part(m,'CryptEntablature',V(37,3,34),p+V(0,29,0),pal.trim)
 A.gable(m,p+V(0,31,17),38,18,34,pal)
 A.arch(m,p+V(0,4,15),16,23,pal,4)
 part(m,'CryptDoorRecess',V(14,19,1),p+V(0,13,12),pal.rock:Lerp(Color3.new(0,0,0),.4))
 window(m,p+V(0,16,-9.5),6,8,pal,true)
 return m
end
function A.aqueduct(parent,c,size,pal,theme)
 local m=model(parent,'AncientAqueduct');local p=c+V(0,0,-size[2]/2-26)
 for i=-3,3 do
  A.arch(m,p+V(i*43,0,0),32,42+(i%2)*2,pal,12)
  part(m,'AqueductCrown',V(46,8,19),p+V(i*43,47,0),pal.trim)
  part(m,'AqueductChannel',V(46,2,9),p+V(i*43,51,0),theme=='FrozenVale'and pal.trim or Color3.fromRGB(100,156,160),Enum.Material.Glacier)
 end
 for _,side in ipairs({-1,1})do A.tower(m,p+V(side*177,0,-5),67,pal,false)end
 return m
end
function A.belfry(parent,c,size,pal)
 local m=model(parent,'FallenBelfry');local p=c+V(0,0,-size[2]/2-26)
 A.tower(m,p+V(0,0,-17),82,pal,false)
 for _,side in ipairs({-1,1})do
  part(m,'BelfryPillar',V(6,27,7),p+V(side*13,96,-17),pal.trim)
  K.beam(m,'BellRoofBrace',p+V(side*15,108,-17),p+V(0,125,-17),4,pal.wood,Enum.Material.Wood)
 end
 A.roof(m,p+V(0,111,-17),42,28,42,pal.wood)
 local bell=part(m,'OldBell',V(14,13,14),p+V(0,98,-17),pal.accent,Enum.Material.Metal,'Ball')
 part(m,'BellLip',V(17,3,17),p+V(0,93,-17),pal.trim,Enum.Material.Metal,'Ball')
 K.beam(m,'BellClapper',p+V(0,98,-17),p+V(0,88,-17),1.5,pal.wood,Enum.Material.Metal)
 for _,side in ipairs({-1,1})do wing(m,p+V(side*89,0,0),110,29,pal,'HauntedGraveyard')end
 return m
end
function A.mine(parent,c,size,pal)
 local m=model(parent,'BracedMineEntrance');local p=c+V(0,0,-size[2]/2-20)
 for _,side in ipairs({-1,1})do
  K.rock(m,p+V(side*72,25,-20),V(100,100,85),pal.rock,side)
  for i=0,2 do
   local z=-i*19
   part(m,'MineTimber',V(7,36,8),p+V(side*32,18,z),pal.wood,Enum.Material.Wood)
   K.beam(m,'MineBrace',p+V(side*32,21,z),p+V(side*17,37,z),5,pal.trim,Enum.Material.Metal)
  end
 end
 for i=0,2 do part(m,'MineLintel',V(72,7,8),p+V(0,38,-i*19),pal.wood,Enum.Material.Wood)end
 part(m,'MineShadow',V(55,33,2),p+V(0,17,-54),Color3.fromRGB(24,26,33))
 for _,side in ipairs({-1,1})do part(m,'OldRail',V(1.2,.7,115),p+V(side*8,.6,0),pal.trim,Enum.Material.Metal)end
 for i=0,9 do part(m,'RailSleeper',V(23,.7,2),p+V(0,.35,48-i*10),pal.wood,Enum.Material.Wood)end
 for _,side in ipairs({-1,1})do A.flame(m,p+V(side*45,0,19),pal,true)end
 return m
end
function A.camp(parent,c,size,pal,snow,leftShiftZ,rightShiftZ)
 local m=model(parent,'ShelteredQuarter')
 for _,side in ipairs({-1,1})do
  local p=c+V(side*(size[1]/2-24),0,-65+(side==-1 and (leftShiftZ or 0)or (rightShiftZ or 0)))
  A.cabin(m,p,pal,snow)
  A.cabin(m,p+V(0,0,-88),pal,snow)
 end
 A.arch(m,c+V(0,0,-size[2]/2-20),70,41,pal,9)
 return m
end
return A
