-- Regional story spaces and saved mechanical stages; never changes shared collision.
local K=require(script.Parent.EpicEnvironmentKit)
local Actors=require(script.Parent.NPCVisual)
local S={};local V=Vector3.new
local themes={DW='Deepwood',GW='Gloamwood',FV='FrozenVale',EC='EmberCaldera',HG='HauntedGraveyard'}
function S.create(scene,c,g,area)
 local pal=K.palette[themes[c.id:sub(1,2)]];local center=V(table.unpack(area.center))
 local width,depth=area.size[1],area.size[2]
 local function part(parent,name,size,at,color,material)
  local p=K.part(parent,name,size,at,color or pal.wood,material or Enum.Material.Wood)
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;return p
 end
 local function beam(parent,name,a,b,size,color,material)
  local p=K.beam(parent,name,a,b,size,color or pal.wood,material or Enum.Material.Wood)
  p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;return p
 end
 local function tag(m,first,last,key)
  m:SetAttribute('ExpansionEvent',key or c.id..':'..g.id);m:SetAttribute('ExpansionChapter',c.id)
  m:SetAttribute('ExpansionMin',first);m:SetAttribute('ExpansionMax',last or 3)
  for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then
   p:SetAttribute('ExpansionTransparency',p.Transparency)
   p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
   if first>0 then p.Transparency=1 end
  elseif p:IsA('Decal')or p:IsA('Texture')then
   p:SetAttribute('ExpansionTransparency',p.Transparency)
   if first>0 then p.Transparency=1 end
  elseif p:IsA('BillboardGui')or p:IsA('PointLight')then p.Enabled=first==0 end end
  return m
 end
 local function model(name,first,last,build,key)
  local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
  build(m);tag(m,first,last,key);m.Parent=scene;return m
 end
 local function moving(name,at,build,poses,key)
  local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
  build(m);m.WorldPivot=CFrame.new(at)
  for n=0,3 do m:SetAttribute('ExpansionPose'..n,poses[n]or CFrame.new(at))end
  tag(m,0,3,key);m:PivotTo(poses[0]or CFrame.new(at));m.Parent=scene;return m
 end
 local function actor(name,at,finish,first,last,key)
  return model(name..'StoryAction',first or 0,last or 3,function(m)
   local npc=Actors.actor(m,name,at,name=='Lumi');m.WorldPivot=CFrame.new(at)
   for n=0,3 do m:SetAttribute('ExpansionPose'..n,CFrame.new(at:Lerp(finish,n/3)))end
   npc:SetAttribute('StorySceneActor',true)
  end,key)
 end
 local function lantern(parent,at,name)
  part(parent,name or 'SignalPost',V(.5,4,.5),at+V(0,2,0))
  part(parent,'WarmSignal',V(1,1.3,1),at+V(0,4,0),pal.accent,Enum.Material.Neon)
 end
 -- Thin walking lines connect the actual authored steps, instead of a center dot.
 local previous=V(table.unpack(area.entry))
 for _,step in ipairs(g.activity.steps)do
  local at=V(table.unpack(step.position));beam(scene,'AuthoredIncidentWalk',previous+V(0,.07,0),at+V(0,.07,0),.12,pal.trim,Enum.Material.Ground);previous=at
 end
 local last=V(table.unpack(g.activity.steps[#g.activity.steps].position))
 -- Put the payoff in view of the last action, with room for its small cast.
 local result=center+V(math.clamp(last.X-center.X,-width/2+30,width/2-30),0,math.clamp(last.Z-center.Z,-depth/2+22,depth/2-22))
 model('UnresolvedIncident',0,2,function(m)
  part(m,'UnfinishedWork',V(3,1.6,2),result+V(0,.8,0))
  part(m,'WorkPlan',V(2,.08,1.4),result+V(0,1.7,0),pal.trim)
 end)
 model('RestoredIncident',3,3,function(m)lantern(m,result,'ConfirmedRouteSignal')end)
 local function stationFrame(index,from)
  local steps=g.activity.steps
  local at=V(table.unpack(steps[index].position))
  local previous=V(table.unpack(steps[from].position))
  local approach=V(previous.X-at.X,0,previous.Z-at.Z).Unit
  local face=CFrame.lookAlong(at,approach)
  return face*CFrame.new(6,0,-1.8)
 end
 local prefix=c.id:sub(1,2)
 if prefix=='DW'then
  -- Creek timber, shelters, watchtower galleries and prison yards frame different lanes.
  if area.layout=='creek'then
   local water=beam(scene,'CreekWater',center+V(-width*.43,-.02,-depth*.35),center+V(width*.4,-.02,depth*.35),8,Color3.fromRGB(103,160,169),Enum.Material.Glass)
   -- Beam thickness also sets height; a creek needs only a shallow surface.
   water.Size=V(water.Size.X,.12,water.Size.Z)
   for i=-1,1 do part(scene,'CreekCrossingStone',V(7,.25,5),center+V(i*6,.12,i*3),pal.rock,Enum.Material.Slate)end
  elseif area.layout=='tower'then
   for _,x in ipairs({-width*.4,width*.4})do part(scene,'TowerFrame',V(3,18,3),center+V(x,9,-depth*.4))end
   beam(scene,'SignalGallery',center+V(-width*.4,16,-depth*.4),center+V(width*.4,16,-depth*.4),2)
  elseif area.layout=='prison'then
   for i=-2,2 do part(scene,'EmptyPrisonFence',V(.5,8,.5),center+V(i*8,4,-depth*.43),pal.rock,Enum.Material.Metal)end
  else
  end
  if c.id=='DW-Q1'and g.id=='exp_1'then
   local frame=stationFrame(2,1)
   model('MarshDryPackShelf',0,3,function(m)
    local stone=pal.rock:Lerp(pal.trim,.32)
    for _,x in ipairs({-2.65,2.65})do
     part(m,'MudEmbeddedFoot',V(2.8,1.15,4.2),frame*CFrame.new(x,.35,0),stone,Enum.Material.Slate)
     part(m,'RaisedDryShelfPier',V(1.4,1.55,2.85),frame*CFrame.new(x,1.38,0),pal.rock,Enum.Material.Cobblestone)
    end
    part(m,'DryPackDeck',V(7.2,.46,3.45),frame*CFrame.new(0,2.28,0),pal.wood,Enum.Material.WoodPlanks)
    part(m,'DryPackBackRail',V(7.2,.65,.38),frame*CFrame.new(0,2.77,1.48),pal.wood)
    m.WorldPivot=m:GetPivot()
    local waxedCanvas=Color3.fromRGB(151,133,92)
    local pack=frame*CFrame.new(1.42,3.18,.12)*CFrame.Angles(0,.12,0)
    part(m,'WaxedConvoyPack',V(2.78,1.34,2.14),pack,waxedCanvas,Enum.Material.Fabric)
    for _,x in ipairs({-.82,.82})do
     part(m,'PackLashing',V(.27,1.41,2.22),pack*CFrame.new(x,0,0),pal.wood,Enum.Material.Fabric)
    end
   end)
  elseif c.id=='DW-02'and g.id=='exp_1'then
   actor('Selene',result+V(-5,0,-8),result+V(-5,0,-8),0,3)
   actor('Convoy Survivor',result+V(-12,0,-8),result+V(-12,0,-8),0,3)
   model('PreparedMedicine',1,3,function(m)part(m,'MedicineCase',V(2.5,1.5,2),result+V(-16,.75,-4),pal.trim)end)
  elseif c.id=='DW-03'and g.id=='exp_1'then
   actor('Eryn',result+V(-10,0,0),result+V(-3,0,0),0,3)
   model('ReturnedConvoy',3,3,function(m)
    for i=1,3 do part(m,'DeliveredMedicine',V(2,1.5,2),result+V(-i*3,.75,-5),pal.trim)end
   end)
  end
 elseif prefix=='GW'then
  -- A low lantern corridor contrasts with the broad open Deepwood relief spaces.
  for _,x in ipairs({-width*.48,width*.48})do
   local ranges=area.axis=='x'and {{-depth*.42,-20},{20,depth*.42}}or {{-depth*.42,depth*.42}}
   for _,r in ipairs(ranges)do beam(scene,'RootGallery',center+V(x,1,r[1]),center+V(x,5,r[2]),2.5,pal.rock)end
  end
  model('UnreadableWebs',0,1,function(m)
   for i=-1,1 do beam(m,'HangingWeb',center+V(-width*.4,7+i*2,-depth*.42),center+V(width*.4,4-i,-depth*.4),.15,Color3.fromRGB(199,207,190),Enum.Material.Fabric)end
  end)
  model('SafeLanternTrail',2,3,function(m)
   for _,step in ipairs(g.activity.steps)do lantern(m,V(table.unpack(step.position))+V(5,0,0))end
  end)
  if c.id=='GW-03'and g.id=='exp_1'then
   local frame=stationFrame(2,1)
   model('RefugeScoutShelter',0,3,function(m)
    local roof=Color3.fromRGB(132,146,102)
    for _,x in ipairs({-3.25,3.25})do
     part(m,'RefugeFieldstoneFoot',V(2.4,1.45,4.7),frame*CFrame.new(x,.46,0),pal.rock,Enum.Material.Slate)
     beam(m,'RefugeForkPost',frame*V(x,1,1.4),frame*V(x,7.3,1.4),.75)
     beam(m,'RefugeRoofBrace',frame*V(x,3.8,1.4),frame*V(x,6.2,-2.15),.62)
    end
    part(m,'RefugeCanopy',V(8.4,.38,5.7),frame*CFrame.new(0,6.55,0)*CFrame.Angles(-.34,0,0),roof,Enum.Material.Fabric)
    part(m,'RefugeMapBench',V(6.1,.58,2.45),frame*CFrame.new(0,2.07,.75),pal.wood,Enum.Material.WoodPlanks)
    for _,x in ipairs({-2.3,2.3})do
     part(m,'RefugeBenchLeg',V(.7,1.82,1.65),frame*CFrame.new(x,.91,.75),pal.wood)
    end
    m.WorldPivot=m:GetPivot()
    local rawTimber=Color3.fromRGB(147,125,83)
    part(m,'RefugeCanopyHem',V(8.1,.36,.22),
     frame*CFrame.new(0,6.55,0)*CFrame.Angles(-.34,0,0)*CFrame.new(0,-.12,-2.84),rawTimber,Enum.Material.Fabric)
    local board=frame*CFrame.new(0,2.67,.55)*CFrame.Angles(-.20,0,0)
    part(m,'RefugeRaisedMapBoard',V(3.7,.32,1.65),board,rawTimber,Enum.Material.WoodPlanks)
    part(m,'RefugeScoutMap',V(2.97,.05,1.26),board*CFrame.new(0,.18,0),Color3.fromRGB(173,153,108),Enum.Material.Fabric)
   end)
  elseif c.id=='GW-06'and g.id=='exp_2'then
   for i,name in ipairs({'Tali','Freed Scout','Scout Lantern Keeper'})do
    local start=V(table.unpack(g.activity.steps[1].position))+V(i*3,0,7)
    local finish=V(table.unpack(g.activity.steps[3].position))+V(i*3,0,7)
    actor(name,start,finish,0,3)
   end
  end
 elseif prefix=='FV'then
  for _,x in ipairs({-width*.48,width*.48})do
   local ranges=area.axis=='x'and {{-depth*.4,-20},{20,depth*.4}}or {{-depth*.4,depth*.4}}
   for _,r in ipairs(ranges)do part(scene,'IceGalleryWall',V(4,10,r[2]-r[1]),center+V(x,5,(r[1]+r[2])/2),pal.rock,Enum.Material.Ice)end
  end
  if c.id=='FV-03'and g.id=='exp_2'then
   -- Shared safe footing remains; the bridge/lift assembly deploys personally.
   part(scene,'RavineWatercourse',V(width*.78,.1,22),center+V(0,.08,0),Color3.fromRGB(76,120,156),Enum.Material.Glass)
   model('TemporaryRescueBoards',0,2,function(m)
    for i=-3,3 do part(m,'TemporaryPlank',V(10,.18,2),center+V(0,.2,i*3.5),pal.wood)end
   end)
   local pivot=center+V(0,.3,0)
   moving('DeployingRavineBridge',pivot,function(m)
    for i=-6,6 do part(m,'BridgeDeck',V(18,.3,3),pivot+V(0,0,i*3.5),pal.wood)end
    for _,x in ipairs({-9,9})do beam(m,'BridgeHandrail',pivot+V(x,3,-23),pivot+V(x,3,23),.4,pal.trim)end
   end,{[0]=CFrame.new(pivot+V(0,16,0))*CFrame.Angles(.6,0,0),[1]=CFrame.new(pivot+V(0,8,0))*CFrame.Angles(.3,0,0),[2]=CFrame.new(pivot),[3]=CFrame.new(pivot)})
   local lift=center+V(width*.3,0,depth*.34)
   moving('RavineLiftPlatform',lift,function(m)
    part(m,'LiftDeck',V(12,.3,12),lift+V(0,.2,0));for _,x in ipairs({-5,5})do beam(m,'LiftCable',lift+V(x,0,0),lift+V(x,15,0),.18,pal.trim,Enum.Material.Metal)end
   end,{[0]=CFrame.new(lift+V(0,-8,0)),[1]=CFrame.new(lift+V(0,-4,0)),[2]=CFrame.new(lift),[3]=CFrame.new(lift)})
  elseif area.layout=='archive'or area.layout=='tunnel'then
   for _,z in ipairs({-depth*.38,depth*.38})do
    for _,x in ipairs({-width*.4,width*.4})do part(scene,'ArchivePillar',V(3,12,3),center+V(x,6,z),pal.rock,Enum.Material.Slate)end
    beam(scene,'ArchiveRoof',center+V(-width*.4,12,z),center+V(width*.4,12,z),2,pal.trim,Enum.Material.Slate)
   end
  end
  if c.id=='FV-07'and g.id=='exp_2'then
   model('ReunitedVillageLights',3,3,function(m)
    for _,x in ipairs({-width*.36,width*.36})do
     part(m,'VillageRoof',V(14,1,10),center+V(x,8,-depth*.4),pal.trim)
     lantern(m,center+V(x,0,-depth*.36),'VillageBeacon')
    end
   end)
   actor('Freya',result+V(-14,0,-6),result+V(-4,0,-6),1,3)
   actor('Ivo',result+V(-18,0,-3),result+V(-8,0,-3),2,3)
  end
 elseif prefix=='EC'then
  -- Actual inlet/return pipes connect each control; saved steps light each leg.
  local points={};for i,step in ipairs(g.activity.steps)do points[i]=V(table.unpack(step.position))end
  for i=1,2 do beam(scene,'ColdServicePipe',points[i]+V(0,.4,0),points[i+1]+V(0,.4,0),.7,pal.rock,Enum.Material.Metal)end
  beam(scene,'ReturnServicePipe',points[3]+V(0,.4,3),points[1]+V(0,.4,3),.7,pal.rock,Enum.Material.Metal)
  for i=1,3 do model('ConfirmedCircuitLeg'..i,i,3,function(m)
   local nextPoint=points[i%3+1];beam(m,'BlueCoolant',points[i]+V(0,.85,0),nextPoint+V(0,.85,0),.3,Color3.fromRGB(86,210,224),Enum.Material.Neon)
  end)end
  if c.id=='EC-06'and g.id=='exp_2'then
   local frame=stationFrame(2,1)
   model('HeatworksProtectionManifold',0,3,function(m)
    local cold=Color3.fromRGB(97,143,146)
    local returned=Color3.fromRGB(153,105,76)
    local basalt=pal.rock:Lerp(pal.trim,.24)
    for _,x in ipairs({-3.25,3.25})do
     part(m,'ManifoldBasaltFoot',V(2.9,1.4,5.15),frame*CFrame.new(x,.48,0),basalt,Enum.Material.Basalt)
     part(m,'ManifoldCastSaddle',V(1.44,1.85,4.6),frame*CFrame.new(x,1.79,0),pal.wood,Enum.Material.Metal)
    end
    for _,pipe in ipairs({{z=-1.15,y=2.7,diameter=1.05,color=cold},{z=1.15,y=3.08,diameter=1.78,color=returned}})do
     part(m,'ProtectionPipe',V(8.7,pipe.diameter,pipe.diameter),frame*CFrame.new(0,pipe.y,pipe.z),pipe.color,Enum.Material.Metal).Shape=Enum.PartType.Cylinder
     for _,x in ipairs({-3.25,3.25})do
      local diameter=pipe.diameter+.6
      part(m,'ProtectionFlange',V(.62,diameter,diameter),frame*CFrame.new(x,pipe.y,pipe.z),pal.trim,Enum.Material.Metal).Shape=Enum.PartType.Cylinder
     end
    end
    part(m,'ProtectionGaugeCase',V(2.45,2.3,3.8),frame*CFrame.new(0,3.7,0),pal.wood,Enum.Material.Metal)
    m.WorldPivot=m:GetPivot()
    local dial=frame*CFrame.new(0,3.78,-2.04)
    local cylinderAxis=CFrame.Angles(0,math.pi/2,0)
    part(m,'PressureDialRim',V(.38,2.06,2.06),dial*cylinderAxis,
     Color3.fromRGB(171,110,64),Enum.Material.CorrodedMetal).Shape=Enum.PartType.Cylinder
    part(m,'PressureDialFace',V(.08,1.73,1.73),dial*CFrame.new(0,0,-.205)*cylinderAxis,
     Color3.fromRGB(177,158,111),Enum.Material.SmoothPlastic).Shape=Enum.PartType.Cylinder
    part(m,'PressureDialNeedle',V(.13,.73,.09),
     dial*CFrame.new(.2,.22,-.275)*CFrame.Angles(0,0,-.69),basalt,Enum.Material.Metal)
   end)
  elseif c.id=='EC-05'and g.id=='exp_2'then
   for i,step in ipairs(g.activity.steps)do
    local at=V(table.unpack(step.position))
    moving('CircuitControl'..i,at,function(m)
     part(m,'ControlWheel',V(3,.3,.4),at+V(0,2.8,0),pal.trim,Enum.Material.Metal)
     part(m,'ControlCross',V(.4,.3,3),at+V(0,2.8,0),pal.trim,Enum.Material.Metal)
    end,{[0]=CFrame.new(at),[1]=CFrame.new(at)*CFrame.Angles(0,i==1 and math.pi/2 or 0,0),[2]=CFrame.new(at)*CFrame.Angles(0,i<=2 and math.pi/2 or 0,0),[3]=CFrame.new(at)*CFrame.Angles(0,math.pi/2,0)})
   end
   actor('Brann',result+V(-12,0,-5),result+V(-5,0,-5),0,3)
  elseif c.id=='EC-07'and g.id=='exp_2'then
   model('RestartedWorkshop',3,3,function(m)
    for i=-1,1 do
     local at=center+V(i*12,0,-depth*.4);part(m,'WorkshopChimney',V(4,14,4),at+V(0,7,0),pal.rock,Enum.Material.Basalt)
     part(m,'WorkingForge',V(5,2,2),at+V(0,2,3),Color3.fromRGB(249,174,74),Enum.Material.Neon)
    end
   end)
   actor('Orik',result+V(-14,0,-5),result+V(-5,0,-5),2,3)
  end
 elseif prefix=='HG'then
  -- Covered crypt aisles lead to the winch, split conduits and final throne.
  for _,x in ipairs({-width*.43,width*.43})do
   for _,z in ipairs({-depth*.35,depth*.35})do part(scene,'CryptPier',V(4,14,4),center+V(x,7,z),pal.rock,Enum.Material.Slate)end
   beam(scene,'CryptCornice',center+V(x,14,-depth*.35),center+V(x,14,depth*.35),2,pal.trim,Enum.Material.Slate)
  end
  if c.id=='HG-04'then
   local key=c.id..':'..(g.id=='exp_1'and 'winch'or g.id)
   actor('Brann',result+V(-14,0,-4),result+V(-4,0,-4),0,3,key)
   actor('Scout Signal Keeper',result+V(-22,0,0),result+V(-8,0,0),0,3,key)
   local winch=result+V(-3,0,-1)
   moving('WorkingDwarvenWinch',winch,function(m)
    part(m,'WinchAxle',V(6,.5,.5),winch+V(0,3,0),pal.trim,Enum.Material.Metal)
    part(m,'WinchGrip',V(.5,3,.5),winch+V(2,3,0),pal.wood)
   end,{[0]=CFrame.new(winch),[1]=CFrame.new(winch)*CFrame.Angles(0,math.pi/3,0),[2]=CFrame.new(winch)*CFrame.Angles(0,math.pi*2/3,0),[3]=CFrame.new(winch)*CFrame.Angles(0,math.pi,0)},key)
   local gate=center+V(0,0,-depth*.4)
   moving('AllianceSideGate',gate,function(m)
    for i=-3,3 do part(m,'RaisedGateBar',V(.5,12,.5),gate+V(i*2,6,0),pal.rock,Enum.Material.Metal)end
   end,{[0]=CFrame.new(gate),[1]=CFrame.new(gate+V(0,4,0)),[2]=CFrame.new(gate+V(0,8,0)),[3]=CFrame.new(gate+V(0,13,0))},key)
  elseif c.id=='HG-05'then
   model('ActiveThroneConduit',0,2,function(m)
    beam(m,'ShieldBeam',center+V(-width*.35,4,0),center+V(width*.35,4,0),.6,Color3.fromRGB(174,105,211),Enum.Material.Neon)
   end,c.id..':'..g.before)
   model('BrokenThroneConduit',3,3,function(m)
    part(m,'QuietShieldRelay',V(3,3,3),result+V(0,1.5,0),pal.rock,Enum.Material.Slate)
   end,c.id..':'..g.before)
  elseif c.id=='HG-03'then
   actor('Lumi',result+V(-18,0,0),result+V(-4,0,0),0,3)
   if g.id=='exp_2' then
    local frame=stationFrame(1,2)
    local stone=pal.rock:Lerp(pal.trim,.43)
    local coping=pal.rock:Lerp(Color3.fromRGB(161,149,126),.62)
    local iron=Color3.fromRGB(78,74,69)
    model('PassageDrainInspectionBox',0,3,function(m)
     m.WorldPivot=frame
     part(m,'InspectionBoxFooting',V(4.8,.52,6.1),frame*CFrame.new(0,.1,0),stone,Enum.Material.Cobblestone)
     part(m,'RecessedChannelBack',V(2.64,2.6,.85),frame*CFrame.new(0,1.62,.92),pal.rock,Enum.Material.Slate)
     for _,x in ipairs({-1.7,1.7}) do
      part(m,'InspectionBoxQuoin',V(1,3.25,4.8),frame*CFrame.new(x,1.91,0),stone,Enum.Material.Cobblestone)
     end
     part(m,'FixedInspectionPlate',V(2.5,.4,3.9),frame*CFrame.new(0,2.87,-.2),iron,Enum.Material.CorrodedMetal)
     part(m,'RunoffLip',V(2.42,.5,2.2),frame*CFrame.new(0,.47,-2.1),stone,Enum.Material.Slate)
     part(m,'WeatheredDrainLintel',V(4.92,.8,1.32),frame*CFrame.new(0,3.84,-1.89),coping,Enum.Material.Slate)
     for _,x in ipairs({-.54,.54}) do
      part(m,'InspectionGrateBar',V(.2,1.7,.25),frame*CFrame.new(x,1.56,-1.57),iron,Enum.Material.CorrodedMetal)
     end
    end)
   end
  elseif c.id=='HG-07'and g.id=='exp_2'then
   actor('Elven Route Guide',result+V(-20,0,-5),result+V(-7,0,-5),0,3)
   model('ProtectedCrownheart',3,3,function(m)
    part(m,'CrownheartCradle',V(5,1,5),result+V(-7,.5,-8),pal.trim,Enum.Material.Slate)
    part(m,'RecoveredHeartLight',V(1.5,2,1.5),result+V(-7,2,-8),pal.accent,Enum.Material.Neon)
   end)
  end
 end
 require(script.Parent.CampaignNarrativeScenes).create(scene,c,g,area,{center=center,result=result,pal=pal,part=part,beam=beam,model=model,moving=moving,actor=actor})
 if c.id=='DW-Q2'or c.id=='FV-Q1'or c.id=='EC-Q1'then require(script.Parent.CampaignReturnScenes).create(scene,result,c.id)end
 scene:SetAttribute('IncidentLayout',area.layout)
end
return S
