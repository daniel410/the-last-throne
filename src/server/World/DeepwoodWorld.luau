-- Connected, native-part environment derived from approved regional art/layout.
-- Monster art comes exclusively from the pinned TD MeshParts, not replacements.
local Workspace=game:GetService('Workspace')
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local Rig=require(script.Parent.TrainingField)
local Env=require(script.Parent.DeepwoodEnvironment)
local World={}
local C={grass=Color3.fromRGB(78,126,65),leaf=Color3.fromRGB(67,137,63),light=Color3.fromRGB(117,164,67),
 stone=Color3.fromRGB(145,154,126),moss=Color3.fromRGB(93,119,83),path=Color3.fromRGB(180,161,115),
 wood=Color3.fromRGB(102,72,43),blue=Color3.fromRGB(30,72,152),gold=Color3.fromRGB(226,182,74),
 violet=Color3.fromRGB(157,65,225),dark=Color3.fromRGB(47,48,61),water=Color3.fromRGB(94,184,203)}
local function vec(p) return Vector3.new(p[1],p[2],p[3]) end
local function part(parent,name,size,pos,color,material,collide)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=typeof(pos)=='CFrame' and pos or CFrame.new(pos)
 p.Color=color;p.Material=material or Enum.Material.Slate;p.Anchored=true;p.CanCollide=collide==true
 p.CanQuery=collide==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function ball(parent,name,size,pos,color,material)
 local p=part(parent,name,size,pos,color,material,false);p.Shape=Enum.PartType.Ball;return p
end
local function label(parent,text)
 local gui=Instance.new('BillboardGui');gui.Name='LandmarkLabel';gui.Size=UDim2.fromOffset(220,40);gui.StudsOffset=Vector3.new(0,5,0);gui.MaxDistance=95;gui.AlwaysOnTop=false;gui.Parent=parent
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.Font=Enum.Font.GothamBold;t.TextSize=15;t.TextColor3=Color3.fromRGB(255,234,188);t.TextStrokeTransparency=.25;t.Parent=gui
end
local function tree(parent,p,scale,corrupt)
 local trunk=part(parent,'TreeCollision',Vector3.new(3,16,3)*scale,p+Vector3.new(0,8*scale,0),C.wood,Enum.Material.Wood,true)
 trunk.Transparency=1
 local visual=Env.tree(parent,p,(scale>3 and 32 or 27)*scale,scale>3)
 if corrupt then for _,piece in ipairs(visual:GetDescendants()) do if piece:IsA('MeshPart') then piece.Color=piece.Color:Lerp(C.dark,.45) end end end
 return trunk
end

local function lamp(parent,p)
 part(parent,'LanternPost',Vector3.new(.8,7,.8),p+Vector3.new(0,3.5,0),C.wood,Enum.Material.Wood,true)
 local b=ball(parent,'Lantern',Vector3.new(1.5,2,1.5),p+Vector3.new(0,7,0),C.gold,Enum.Material.Neon)
 local light=Instance.new('PointLight');light.Color=Color3.fromRGB(255,211,133);light.Range=15;light.Brightness=.7;light.Parent=b
end
local function banner(parent,p)
 part(parent,'BannerPole',Vector3.new(.7,13,.7),p+Vector3.new(0,6.5,0),C.wood,Enum.Material.Wood,true)
 part(parent,'RoyalCobaltBanner',Vector3.new(4,7,.25),p+Vector3.new(2,9,0),C.blue,Enum.Material.Fabric,false)
 part(parent,'GoldCrest',Vector3.new(1.8,1.8,.3),p+Vector3.new(2,9,.2),C.gold,Enum.Material.Metal,false)
end
local function arch(parent,p)
 for _,x in ipairs({-9,9}) do part(parent,'CarvedStonePillar',Vector3.new(4,19,4),p+Vector3.new(x,9.5,0),C.stone,nil,true) end
 part(parent,'RuinedArchLintel',Vector3.new(22,4,5),p+Vector3.new(0,19,0),C.moss,nil,true)
end
local function cart(parent,p)
 part(parent,'SupplyCartBed',Vector3.new(10,1.5,6),p+Vector3.new(0,3,0),C.wood,Enum.Material.Wood,true)
 for _,x in ipairs({-4,4}) do for _,z in ipairs({-4,4}) do
  local wheel=part(parent,'BrokenCartWheel',Vector3.new(1,4,4),p+Vector3.new(x,2,z),C.wood,Enum.Material.Wood,true);wheel.Shape=Enum.PartType.Cylinder
 end end
 for i=1,3 do part(parent,'SupplyCrate',Vector3.new(3,3,3),p+Vector3.new(i*3-6,5,0),C.wood,Enum.Material.Wood,true) end
end
local function cage(parent,p)
 part(parent,'CageRoof',Vector3.new(9,1,9),p+Vector3.new(0,9,0),C.wood,nil,false)
 for _,x in ipairs({-4,4}) do for _,z in ipairs({-4,4}) do part(parent,'CageBar',Vector3.new(.6,9,.6),p+Vector3.new(x,4.5,z),C.wood,Enum.Material.Wood,true) end end
 ball(parent,'CaptiveSpirit',Vector3.new(3,4,3),p+Vector3.new(0,4,0),Color3.fromRGB(112,230,194),Enum.Material.Neon)
end
local function npc(parent,p,name,goblin)
 local m=Instance.new('Model');m.Name=name;m.Parent=parent
 if goblin then
  m=Rig.makeEnemy(parent,'Goblin',p.X,p.Z,1,1.2);m.Name=name;m:PivotTo(m:GetPivot()+Vector3.new(0,p.Y,0));m:SetAttribute('EnemyKind',nil)
  for _,d in ipairs(m:GetDescendants()) do if d:IsA('BasePart') then d.Anchored=true;d.CanCollide=false;d.CanQuery=false end end
  m:FindFirstChildOfClass('Humanoid').DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
  label(m.PrimaryPart,name..' · FRIENDLY');return
 end
 local body=part(m,'Body',Vector3.new(2.5,3,1.4),p+Vector3.new(0,2.5,0),goblin and C.leaf or C.blue,Enum.Material.Fabric,false)
 ball(m,'Head',Vector3.new(1.6,1.6,1.6),p+Vector3.new(0,5,0),Color3.fromRGB(230,203,145));label(body,name)
end
function World.create()
 local existing=Workspace:FindFirstChild('DeepwoodCampaign')
 if existing then
  if World.current then return World.current end
  local result={folder=existing,terrain=existing:FindFirstChild('TerrainBlockout'),nodes={},spawns={},positions={}}
  for id,z in pairs(Content.zones) do result.spawns[id]=existing:FindFirstChild(id..'_SP');result.positions[id]=vec(z.center) end
  for _,p in ipairs(existing:WaitForChild('Objectives'):GetChildren()) do
   local c=Content.byId[p:GetAttribute('ChapterId')];local goalId=p:GetAttribute('GoalId')
   if c then for _,g in ipairs(c.goals) do if g.id==goalId then result.nodes[c.id..':'..(p.Name:match('_request$') and 'request' or g.id)]={part=p,prompt=p:FindFirstChildOfClass('ProximityPrompt'),chapter=c,goal=g} end end end
  end
  World.current=result;return result
 end
 local root=Instance.new('Model');root.Name='DeepwoodCampaign';root.Parent=Workspace
 local terrain=Instance.new('Folder');terrain.Name='TerrainBlockout';terrain.Parent=root
 local nodes=Instance.new('Folder');nodes.Name='Objectives';nodes.Parent=root
 local spawns,positions={},{}
 local titles={} for _,c in ipairs(Content.chapters) do if not c.side or not titles[c.zone] then titles[c.zone]=c.title end end
 for id,z in pairs(Content.zones) do
  local region=Instance.new('Model');region.Name=id;region.Parent=terrain
  local center=vec(z.center);local sx,sz=z.size[1],z.size[2]
  part(region,'MossyLimestoneCliff',Vector3.new(sx,34,sz),center-Vector3.new(0,17,0),id=='DW-07' and C.dark or C.stone,nil,true)
  for i=0,5 do local angle=i*math.pi/3;Env.cliff(region,center+Vector3.new(math.cos(angle)*(sx/2-22),-38,math.sin(angle)*(sz/2-22)),34) end
  part(region,'ForestGround',Vector3.new(sx,.4,sz),center-Vector3.new(0,.2,0),id=='DW-07' and C.dark or C.grass,Enum.Material.Grass,true)
  part(region,'BroadStoneTrail',Vector3.new(sx*.78,.12,16),center+Vector3.new(0,.06,0),C.path,Enum.Material.Cobblestone,false)
  for i=0,13 do
   local a=i*math.pi*2/14;tree(region,center+Vector3.new(math.cos(a)*(sx/2-12),0,math.sin(a)*(sz/2-12)),1+(i%3)*.15,id=='DW-06' or id=='DW-07')
  end
  for _,x in ipairs({-sx*.34,sx*.34}) do lamp(region,center+Vector3.new(x,0,40)) end
  local spawn=Instance.new('SpawnLocation');spawn.Name=id..'_SP';spawn.Size=Vector3.new(12,.3,12);spawn.Position=center+Vector3.new(-sx*.37,.15,sz*.34)
  spawn.Material=Enum.Material.Slate;spawn.TopSurface=Enum.SurfaceType.Smooth;spawn.BottomSurface=Enum.SurfaceType.Smooth;spawn.Anchored=true;spawn.CanCollide=false;spawn.CanQuery=false;spawn.CanTouch=false;spawn.Neutral=true;spawn.Duration=0;spawn.Color=C.blue;spawn.Enabled=true;spawn.Parent=root;spawns[id]=spawn
  label(spawn,(titles[id] or id)..' · CHECKPOINT')
  positions[id]=center
  if id=='DW-01' then
   Env.portal(region,spawn.Position+Vector3.new(0,-.15,16))
   part(region,'OptionalMarsh',Vector3.new(34,.2,30),center+Vector3.new(-80,.1,85),C.water,Enum.Material.Glass,false)
   cart(region,center+Vector3.new(-15,0,12))
  elseif id=='DW-02' then cart(region,center);npc(region,center+Vector3.new(-25,0,10),'Supply Survivor',false);npc(region,center+Vector3.new(-30,0,10),'Wounded Scout',false)
  elseif id=='DW-03' then
   tree(region,center+Vector3.new(0,0,-45),3.4,false);banner(region,center+Vector3.new(-12,0,-22));banner(region,center+Vector3.new(12,0,-22))
   part(region,'OutpostDeck',Vector3.new(35,1,24),center+Vector3.new(0,.5,-28),C.wood,Enum.Material.Wood,true)
   npc(region,center+Vector3.new(0,0,-5),'Erin',false);npc(region,center+Vector3.new(-45,0,50),'Quartermaster',false)
  elseif id=='DW-04' then
   for _,x in ipairs({-15,15}) do for _,zz in ipairs({-18,18}) do part(region,'WatchtowerPillar',Vector3.new(5,42,5),center+Vector3.new(x,21,zz),C.stone,nil,true) end end
   part(region,'WatchtowerCrown',Vector3.new(38,5,44),center+Vector3.new(0,43,0),C.moss,nil,false);cage(region,center+Vector3.new(0,0,-25));banner(region,center+Vector3.new(20,0,20))
  elseif id=='DW-05' then
   arch(region,center+Vector3.new(-85,0,45));cage(region,center+Vector3.new(-65,0,-15))
   for i=1,4 do part(region,'OccupiedRuins',Vector3.new(5,13,5),center+Vector3.new(i*23-60,6.5,-100),C.stone,nil,true) end
  elseif id=='DW-06' then
   npc(region,center+Vector3.new(-75,0,48),'Goblin Refugee',true)
   for i=1,4 do local p=part(region,'CorruptedRoot',Vector3.new(8,5,50),center+Vector3.new(i*35-85,2.5,-35),C.dark,Enum.Material.Wood,false);p.CFrame=p.CFrame*CFrame.Angles(0,i*.7,.2) end
  elseif id=='DW-07' then
   part(region,'BlackRootDais',Vector3.new(42,1,40),center+Vector3.new(0,.5,-40),C.dark,nil,true)
   for _,x in ipairs({-24,24}) do local p=part(region,'AltarObelisk',Vector3.new(5,25,5),center+Vector3.new(x,12.5,-65),C.dark,nil,true);ball(region,'VioletSeal',Vector3.new(4,6,4),p.Position+Vector3.new(0,14,0),C.violet,Enum.Material.Neon) end
  end
  if id=='DW-S2' then
   local falls=part(region,'Waterfall',Vector3.new(22,65,2),center+Vector3.new(-65,-16,-40),C.water,Enum.Material.Glass,false);falls.Transparency=.35
  end
 end
 local function bridge(a,b)
  local first,second=positions[a],positions[b];local delta=second-first;local midpoint=(first+second)/2
  local cf=CFrame.lookAt(midpoint,second);part(terrain,'ConnectedPath_'..a..'_'..b,Vector3.new(24,2,delta.Magnitude+10),cf-Vector3.new(0,1.2,0),C.path,Enum.Material.Cobblestone,true)
  for _,x in ipairs({-12,12}) do part(terrain,'BridgeParapet',Vector3.new(1.5,3,delta.Magnitude),cf*CFrame.new(x,1.5,0),C.moss,nil,true) end
 end
 for i=1,6 do bridge(string.format('DW-%02d',i),string.format('DW-%02d',i+1)) end
 bridge('DW-03','DW-S1');bridge('DW-03','DW-S2');bridge('DW-05','DW-S3')
 -- Local paths follow story investigation points as well as the regional bridges.
 for _,c in ipairs(Content.chapters) do if not c.side then
  local previous=spawns[c.zone].Position
  for _,g in ipairs(c.goals) do if not g.zone and not g.optional then
   local p=vec(g.position)+Vector3.new(0,.07,0);local start=Vector3.new(previous.X,p.Y,previous.Z);local delta=p-start
   if delta.Magnitude>1 then part(terrain,'InvestigationPath',Vector3.new(12,.1,delta.Magnitude+2),CFrame.lookAt((start+p)/2,p),C.path,Enum.Material.Cobblestone,false) end
   previous=p
  end end
 end end
 local interactions={}
 for _,c in ipairs(Content.chapters) do for _,g in ipairs(c.goals) do
  local p=part(nodes,c.id..'_'..g.id,Vector3.new(3,2,3),vec(g.position)+Vector3.new(0,1,0),#g.enemies>0 and C.gold or C.violet,Enum.Material.Slate,false)
  p:SetAttribute('ChapterId',c.id);p:SetAttribute('GoalId',g.id)
  ball(p,'ObjectiveGem',Vector3.new(1.4,2,1.4),p.Position+Vector3.new(0,2,0),#g.enemies>0 and C.gold or C.violet,Enum.Material.Neon)
  local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.Name='StoryInteract';prompt.ActionText=#g.enemies>0 and 'Begin encounter' or 'Interact';prompt.ObjectText=g.title;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=p
  interactions[c.id..':'..g.id]={part=p,prompt=prompt,chapter=c,goal=g}
 end end
 -- Resident and field starts share the exact same first-goal receipt.
 for index,c in ipairs(Content.chapters) do if c.side and c.id~='DW-Q1' then
  local g=c.goals[1];local p=part(nodes,c.id..'_request',Vector3.new(3,2,3),positions['DW-03']+Vector3.new((index-9)*18,1,72),C.blue,Enum.Material.Slate,false)
  p:SetAttribute('ChapterId',c.id);p:SetAttribute('GoalId',g.id)
  label(p,c.id=='DW-Q4' and 'Outpost Scout' or 'Outpost Resident')
  local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText='Hear request';prompt.ObjectText=c.title;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=p
  interactions[c.id..':request']={part=p,prompt=prompt,chapter=c,goal=g}
 end end
 root:SetAttribute("DeepwoodReady",true)
 World.current={folder=root,terrain=terrain,nodes=interactions,spawns=spawns,positions=positions};return World.current
end
return World
