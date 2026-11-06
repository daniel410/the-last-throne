-- Native volcanic city blockout; lava is off the safe route, not a hidden class gate.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.EmberCalderaContent)
local Bounds=require(Shared.CampaignBounds)
local W={}
local C={rock=Color3.fromRGB(76,68,67),basalt=Color3.fromRGB(48,47,54),iron=Color3.fromRGB(110,106,99),lava=Color3.fromRGB(255,124,43),coolant=Color3.fromRGB(77,189,212),brass=Color3.fromRGB(194,147,83)}
local function v(p)return Vector3.new(table.unpack(p))end
local function part(parent,name,size,cf,color,material,solid)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=typeof(cf)=='CFrame' and cf or CFrame.new(cf);p.Color=color;p.Material=material or Enum.Material.Basalt;p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if not solid then p:SetAttribute('TLTDecorative',true)end
 p.Parent=parent;return p
end
local function lamp(parent,p)
 local model=require(script.Parent.StoryProps).build(parent,'RouteLantern',p,{theme='EmberCaldera'})
 local flame=model:FindFirstChild('SmallFlame')
 local light=Instance.new('PointLight');light.Color=Color3.fromRGB(247,205,131);light.Range=16;light.Brightness=.65;light:SetAttribute('TLTDecorative',true);light.Parent=flame
end

local function gate(parent,p,width,height)
 for _,x in ipairs({-width/2,width/2})do part(parent,'ForgePillar',Vector3.new(7,height,9),p+Vector3.new(x,height/2,0),C.iron,Enum.Material.Metal,true)end
 part(parent,'ForgeGateLintel',Vector3.new(width+7,6,9),p+Vector3.new(0,height,0),C.basalt,Enum.Material.Basalt,true)
end
local function alignEmergencyPipes(world)
 local region=world.terrain:FindFirstChild('EC-07');if not region then return end
 local center=v(Content.zones['EC-07'].center)
 for _,pipe in ipairs(region:GetChildren())do if pipe.Name=='EmergencyCoolantPipe' and pipe:IsA('BasePart')then
  local side=pipe.Position.X<center.X and -1 or 1
  pipe.Position=center+Vector3.new(side*184,4,0)
 end end
end
function W.create(world)
 if world.emberReady then alignEmergencyPipes(world);return world end
 local terrain=world.terrain;local foundation=Instance.new('Model');foundation.Name='EmberCalderaFoundation';foundation.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;foundation.Parent=terrain
 local props=Instance.new('Folder');props.Name='EmberStoryProps';props.Parent=world.folder
 for id,z in pairs(Content.zones)do
  local center=v(z.center);world.positions[id]=center
  local region=Instance.new('Model');region.Name=id;region:SetAttribute('EpicId','EmberCaldera');region.Parent=terrain
  part(foundation,'Support_'..id,Vector3.new(z.size[1],110,z.size[2]),center-Vector3.new(0,55,0),C.basalt,nil,true)
  part(region,'BasaltGround',Vector3.new(z.size[1],.4,z.size[2]),center-Vector3.new(0,.2,0),C.rock,Enum.Material.Basalt,true)
  local sp=Instance.new('SpawnLocation');sp.Name=id..'_SP';sp.Position=center+Vector3.new(-140,.1,110);sp.Size=Vector3.new(12,.2,12);sp.Anchored=true;sp.CanCollide=false;sp.CanQuery=false;sp.CanTouch=false;sp.Neutral=true;sp.Enabled=true;sp.Duration=0;sp.Color=C.brass;sp.Parent=world.folder;world.spawns[id]=sp;lamp(region,sp.Position+Vector3.new(-12,0,0))
  for i=1,12 do
   local angle=i*math.pi/6;local p=center+Vector3.new(math.cos(angle)*(z.size[1]/2+35),-12,math.sin(angle)*(z.size[2]/2+35))
   local cliff=part(region,'CalderaRim',Vector3.new(65,50+i%4*10,60),CFrame.new(p)*CFrame.Angles(.1,i*.4,.1),C.basalt);cliff.Shape=Enum.PartType.Ball
   local lava=part(region,'DistantLavaFissure',Vector3.new(6,1,40),p+Vector3.new(0,15,0),C.lava,Enum.Material.Neon);lava.Transparency=.15
  end
  if id=='EC-01' then
   gate(region,center+Vector3.new(0,0,125),80,28)
   part(region,'FreightLiftDeck',Vector3.new(35,.6,28),center+Vector3.new(105,.3,-70),C.iron,Enum.Material.DiamondPlate,true)
   for _,x in ipairs({85,125})do part(region,'FreightLiftGuide',Vector3.new(2,27,2),center+Vector3.new(x,13,-85),C.iron,Enum.Material.Metal,true)end
  elseif id=='EC-02' then
   local call=Instance.new('Model');call.Name='ForgeCompanionCamp';call.Parent=region;call.PrimaryPart=part(call,'CampBoard',Vector3.new(5,4,1),center+Vector3.new(0,3,85),C.brass,Enum.Material.Wood,true);world.emberCompanionCamp=call
   for _,x in ipairs({-90,90})do
    part(region,'WorkshopRoof',Vector3.new(62,3,50),center+Vector3.new(x,20,100),C.iron,Enum.Material.Metal)
    for _,dx in ipairs({-25,25})do part(region,'WorkshopColumn',Vector3.new(3,20,3),center+Vector3.new(x+dx,10,110),C.basalt,nil,true)end
    part(region,'ForgeAnvil',Vector3.new(7,4,4),center+Vector3.new(x,2,90),C.iron,Enum.Material.Metal,true)
   end
  elseif id=='EC-03' then
   gate(region,center+Vector3.new(0,0,125),95,25)
   for _,x in ipairs({-145,145})do for _,zz in ipairs({-90,90})do part(region,'BracedMineSupport',Vector3.new(6,25,6),center+Vector3.new(x,12.5,zz),C.iron,Enum.Material.Wood,true)end end
  elseif id=='EC-04' then
   for _,x in ipairs({-150,150})do part(region,'CoolantChannel',Vector3.new(20,.3,260),center+Vector3.new(x,.05,0),C.coolant,Enum.Material.Glass);part(region,'CoolantPipe',Vector3.new(6,6,260),center+Vector3.new(x+20,3,0),C.iron,Enum.Material.Metal,true)end
  elseif id=='EC-05' then gate(region,center+Vector3.new(0,0,125),95,26)
   for i=1,3 do part(region,'BlueprintTable',Vector3.new(16,3,8),center+Vector3.new((i-2)*65,1.5,105),C.brass,Enum.Material.Wood,true)end
  elseif id=='EC-06' then
   gate(region,center+Vector3.new(0,0,125),100,30)
   for _,x in ipairs({-160,160})do part(region,'TestworksHeatTower',Vector3.new(18,36,18),center+Vector3.new(x,18,0),C.iron,Enum.Material.Metal,true)end
  elseif id=='EC-07' then
   gate(region,center+Vector3.new(0,0,125),115,36)
   part(region,'GreatFurnaceWall',Vector3.new(130,42,10),center+Vector3.new(0,21,-175),C.basalt,nil,true)
   local glow=part(props,'FurnaceCore',Vector3.new(48,26,3),center+Vector3.new(0,18,-168),C.lava,Enum.Material.Neon);glow:SetAttribute('StoryVisualKey','EC-07:restart')
   for _,x in ipairs({-184,184})do part(region,'EmergencyCoolantPipe',Vector3.new(8,8,270),center+Vector3.new(x,4,0),C.coolant,Enum.Material.Metal,true)end
  end
  if id:match('EC%-S')then gate(region,center+Vector3.new(0,0,95),65,24)end
  task.wait()
 end
 for _,edge in ipairs(Content.edges)do if world.spawns[edge[1]]and world.spawns[edge[2]]then local a,b=Bounds.ends(edge);a,b=v(a),v(b)
  part(foundation,'CalderaTrail_'..edge[1]..'_'..edge[2],Vector3.new(96,4,(b-a).Magnitude+6),CFrame.lookAt((a+b)/2,b)-Vector3.new(0,2,0),C.rock,Enum.Material.Basalt,true)
  for i=0,math.floor((b-a).Magnitude/110)do lamp(terrain,a:Lerp(b,math.min(1,i*110/math.max(1,(b-a).Magnitude)))+Vector3.new(38,0,0))end
 end end
 for _,c in ipairs(Content.chapters)do for _,g in ipairs(c.goals)do
  local p=part(world.folder.Objectives,c.id..'_'..g.id,Vector3.new(3,2,3),v(g.position)+Vector3.new(0,1,0),C.brass);p.Transparency=1;p:SetAttribute('ChapterId',c.id);p:SetAttribute('GoalId',g.id)
  local prompt=Instance.new('ProximityPrompt');prompt.Name='StoryInteract';prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText=#g.enemies>0 and 'Begin encounter' or 'Interact';prompt.ObjectText=g.title;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=p
  world.nodes[c.id..':'..g.id]={part=p,prompt=prompt,chapter=c,goal=g}
  if g.activity and g.activity.mode=='mechanism'then
   local wheel=part(props,'CoolingControl',Vector3.new(3,3,1),v(g.position)+Vector3.new(5,2,0),C.brass,Enum.Material.Metal);wheel.Shape=Enum.PartType.Cylinder;wheel:SetAttribute('StoryVisualKey',c.id..':'..g.id);wheel.Transparency=1;wheel:SetAttribute('StoryBlockoutProxy',true)
  end
 end end
 world.emberReady=true;world.folder:SetAttribute('EmberCalderaReady',true);return world
end
return W
