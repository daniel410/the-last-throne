-- Authored evidence, responding beacons and freight machinery, projected from
-- existing saved goals. No new progression, inventory, collision or remotes.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local Bounds=require(Shared.CampaignBounds)
local Route=require(Shared.CampaignIncidentRoute)
local Kit=require(script.Parent.EpicEnvironmentKit)
local Props=require(script.Parent.StoryProps)
local M={version=2};local V=Vector3.new
local function position(t)return V(table.unpack(t))end
local function goal(chapter,id)
 for _,g in ipairs(Content.byId[chapter].goals)do if g.id==id then return g end end
 error('Missing setpiece goal '..chapter..':'..id)
end
local function part(parent,name,size,at,color,material)
 return Kit.part(parent,name,size,at,color,material)
end
local function model(parent,name)
 local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m.Parent=parent;return m
end
local function saved(m,chapter,id,first,last,requires)
 m:SetAttribute('ExpansionEvent',chapter..':'..id);m:SetAttribute('ExpansionChapter',chapter)
 m:SetAttribute('ExpansionMin',first);m:SetAttribute('ExpansionMax',last or 3)
 m:SetAttribute('ExpansionRequires',requires)
 for _,p in ipairs(m:GetDescendants())do
  if p:IsA('BasePart')then
   p:SetAttribute('ExpansionTransparency',p.Transparency)
   if first>0 then p.Transparency=1 end
  elseif p:IsA('PointLight')then p.Enabled=first==0 end
 end
end
local function light(parent,at)
 local flame=Kit.part(parent,'BeaconFlame',V(2.8,2.8,2.8),at,Color3.fromRGB(255,171,66),Enum.Material.Neon,'Ball')
 for i=-1,1 do
  Kit.part(parent,'BeaconFlameTongue',V(1.1,2.4+(.5*(i%2)),1.2),CFrame.new(at+V(i*.7,1.6,0))*CFrame.Angles(0,i*.8,i*.15),Color3.fromRGB(255,216,133),Enum.Material.Neon,'Wedge')
 end
 local glow=Instance.new('PointLight');glow.Name='BeaconGlow';glow.Color=flame.Color
 glow.Range=22;glow.Brightness=1.5;glow.Shadows=false;glow.Parent=flame
end
local function trail(parent,from,to,wheels)
 local points=Route.route(from,to)
 for i=2,#points do
  local a,b=position(points[i-1]),position(points[i]);local delta=V(b.X-a.X,0,b.Z-a.Z)
  if delta.Magnitude>1 then
   local forward=delta.Unit;local side=V(-forward.Z,0,forward.X)
   local n=math.max(1,math.ceil(delta.Magnitude/7))
   for j=0,n-1 do
    local at=a:Lerp(b,(j+.5+.14*math.sin(j*2.3))/n)
    for _,offset in ipairs(wheels and {-2.2,2.2}or {j%2==0 and -.65 or .65})do
     local q=at+side*(offset+.12*math.sin(j*1.7));local y=Bounds.surface(q.X,q.Z)
     if y then
      q=V(q.X,y+.08,q.Z)
      local cf=CFrame.lookAt(q,q+forward)*CFrame.Angles(0,.04*math.sin(j*2.1),0)
      part(parent,wheels and 'LoadedWheelRut'or 'TravelerFootprint',wheels and V(.3+.07*(j%3),.08,5.4+.6*(j%3))or V(.65,.08,1.3),cf,Color3.fromRGB(79,68,49),Enum.Material.Ground)
     end
    end
   end
  end
 end
end
local function deepwood(root)
 local chapter='DW-01';local scene=model(root,'DW-01_ConvoyEvidence')
 local supplies=goal(chapter,'supplies');local tracks=goal(chapter,'tracks');local crossing=goal(chapter,'exp_2')
 local marks=model(scene,'ConvoyWheelTrail')
 -- Follow the same connector-aware route as server travel, on supported ground.
 local previous=supplies.activity.steps[1].position
 for i=2,#supplies.activity.steps do
  local nextPoint=supplies.activity.steps[i].position;trail(marks,previous,nextPoint,true);previous=nextPoint
 end
 previous=tracks.activity.steps[1].position
 for i=2,#tracks.activity.steps do
  local nextPoint=tracks.activity.steps[i].position;trail(marks,previous,nextPoint,false);previous=nextPoint
 end
 previous=Content.zones[chapter].center
 for _,a in ipairs(Content.zones[chapter].expansionAreas)do if a.id==crossing.area then previous=a.entry end end
 for _,step in ipairs(crossing.activity.steps)do trail(marks,previous,step.position,true);previous=step.position end
 local wheelAt=position(crossing.activity.steps[2].position)+V(6,0,0)
 local wreck=model(scene,'BrokenConvoyAxle')
 Props.build(wreck,'FallenWheel',wheelAt,{theme='Deepwood',scale=2})
 part(wreck,'SnappedAxle',V(7,.7,.7),wheelAt+V(-3,1,0),Color3.fromRGB(105,73,43),Enum.Material.Wood)
 local signalAt=position(crossing.activity.steps[3].position)+V(5,0,0)
 local signal=model(scene,'SurvivorSignalRaised')
 Props.build(signal,'ClothSignal',signalAt,{theme='Deepwood',scale=2})
 -- The distant survivor signal is visible before arrival; the confirmed route
 -- markers appear only after reaching every saved trail step.
 local found=model(scene,'ConfirmedSurvivorRoute')
 for _,step in ipairs(crossing.activity.steps)do
  Props.build(found,'ClothSignal',position(step.position)+V(-6,0,0),{theme='Deepwood'})
 end
 saved(found,chapter,'exp_2',3)
 scene:SetAttribute('QuestExperience','FollowPhysicalEvidence')
end
local function frozen(root,world)
 local chapter='FV-03';local scene=model(root,'FV-03_AnsweringBeacons')
 local west=position(goal(chapter,'west_beacon').position)
 local east=position(goal(chapter,'east_beacon').position)
 local tips={}
 for i,id in ipairs({'west_beacon','east_beacon'})do
  local at=i==1 and west or east;local target=i==1 and east or west
  -- Reuse the existing authored brazier rather than leave two competing props.
  local brazier=world.folder.AdventureActivities:FindFirstChild(chapter..'_'..id..'_Art')
  assert(brazier,'Missing authored village beacon '..id)
  -- Tall, open signal legs distinguish village beacons from waist-high road
  -- lamps while leaving the original ground-level interaction within reach.
  local stand=model(scene,i==1 and 'WesternSignalStand'or 'EasternSignalStand')
  for _,x in ipairs({-2.4,2.4})do for _,z in ipairs({-1.4,1.4})do
   part(stand,'SignalTowerLeg',V(.45,4,.45),at+V(x,2,z),Color3.fromRGB(94,102,117),Enum.Material.Metal)
  end end
  part(stand,'SignalTowerPlatform',V(6,.3,4),at+V(0,4,0),Color3.fromRGB(117,141,158),Enum.Material.Slate)
  local cf=CFrame.lookAt(at+V(0,4,0),V(target.X,at.Y+4,target.Z))
  brazier:ScaleTo(2);brazier:PivotTo(cf)
  tips[i]=cf:PointToWorldSpace(V(0,3.6*2,0))
  local burning=model(scene,i==1 and 'WesternBeaconLit'or 'EasternBeaconLit')
  light(burning,tips[i]);saved(burning,chapter,id,3)
  local node=world.nodes[chapter..':'..id];node.prompt.ActionText='Light beacon'
 end
 local response=model(scene,'BeaconsAnswerAcrossRavine')
 -- A thin, elevated sightline is an answer between landmarks, never a barrier.
 Kit.beam(response,'VillageSignalSightline',tips[1]+V(0,1,0),tips[2]+V(0,1,0),.16,Color3.fromRGB(255,211,134),Enum.Material.Neon)
 saved(response,chapter,'east_beacon',3,3,chapter..':west_beacon')
 scene:SetAttribute('QuestExperience','ReconnectDistantSignals')
end
local function ember(root,world)
 local chapter='EC-01';local scene=model(root,'EC-01_FreightMachinery')
 local control=position(goal(chapter,'lift').position)
 local deck
 for _,p in ipairs(world.terrain:GetDescendants())do
  if p:IsA('BasePart')and p.Name=='FreightLiftDeck'and (p.Position-control).Magnitude<100 then deck=p;break end
 end
 assert(deck,'Missing freight landing')
 -- This is a cargo carrier beside the fixed walkable landing. The shared deck
 -- never moves underneath a player whose personal progress differs.
 local base=V(deck.Position.X,control.Y,deck.Position.Z-21)
 local steel=Color3.fromRGB(77,80,86);local brass=Color3.fromRGB(179,132,65)
 for _,x in ipairs({-6,6})do
  part(scene,'CarrierGuide',V(.7,25,.7),base+V(x,12.5,0),steel,Enum.Material.Metal)
 end
 part(scene,'CarrierCrosshead',V(14,1,2),base+V(0,25,0),steel,Enum.Material.Metal)
 local carrier=model(scene,'FreightCarrier')
 part(carrier,'CarrierBed',V(10,.4,8),base+V(0,.6,0),steel,Enum.Material.DiamondPlate)
 for _,x in ipairs({-5,5})do part(carrier,'CarrierSafetyRail',V(.3,2,8),base+V(x,1.8,0),brass,Enum.Material.Metal)end
 Props.build(carrier,'OreCarrier',base+V(0,.8,0),{theme='EmberCaldera'})
 carrier.WorldPivot=CFrame.new(base)
 carrier:SetAttribute('ExpansionPose0',CFrame.new(base))
 carrier:SetAttribute('ExpansionPose3',CFrame.new(base+V(0,12,0)))
 carrier:SetAttribute('ExpansionTransitionSeconds',4)
 saved(carrier,chapter,'lift',0)
 -- Keep a fixed cable over the entire carrier travel; moving geometry has no
 -- collision and cannot grant access, damage, items or progression.
 Kit.beam(scene,'HoistCable',base+V(0,2,0),base+V(0,24,0),.2,brass,Enum.Material.Metal)
 local socket=control+V(5,2,0)
 part(scene,'EmptyGearSpindle',V(.5,.5,2),socket,steel,Enum.Material.Metal)
 Kit.beam(scene,'FreightDriveShaft',socket+V(0,0,-1),base+V(-6,2,0),.4,steel,Enum.Material.Metal)
 local installed=model(scene,'InstalledRecoveredGear')
 Props.build(installed,'LiftGear',socket-V(0,2.8,0),{theme='EmberCaldera',scale=2})
 installed.WorldPivot=CFrame.new(socket)
 installed:SetAttribute('ExpansionPose0',CFrame.new(socket))
 installed:SetAttribute('ExpansionPose3',CFrame.new(socket)*CFrame.Angles(0,0,math.pi))
 installed:SetAttribute('ExpansionTransitionSeconds',2)
 saved(installed,chapter,'lift',3,3,chapter..':gear')
 local ready=model(scene,'FreightLandingReady')
 for _,x in ipairs({-4,4})do
  part(ready,'LandingLamp',V(1,1.8,1),base+V(x,2,6),Color3.fromRGB(123,218,191),Enum.Material.Neon)
 end
 saved(ready,chapter,'lift',3,3,chapter..':gear')
 local node=world.activityNodes[chapter..':lift:operate']
 assert(node and node.prompt,'Missing freight control')
 node.prompt.ActionText='Fit gear and start lift'
 scene:SetAttribute('QuestExperience','InstallAndOperateMachinery')
end
function M.create(world,epic)
 if epic~=1 and epic~=3 and epic~=4 then return end
 local root=world.folder:FindFirstChild('QuestSetpieces')
 if not root then root=Instance.new('Folder');root.Name='QuestSetpieces';root.Parent=world.folder end
 if root:FindFirstChild('Epic'..epic)then return end
 -- Construct before parenting so streamed models arrive with their state tags.
 local group=Instance.new('Model');group.Name='Epic'..epic;group.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 group:SetAttribute('QuestSetpieceVersion',M.version)
 if epic==1 then deepwood(group)elseif epic==3 then frozen(group,world)else ember(group,world)end
 group.Parent=root
end
return M
