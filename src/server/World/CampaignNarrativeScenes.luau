-- Readable character causes and payoffs, projected from existing journal flags.
local N={};local V=Vector3.new
local Lantern=require(script.Parent.ScoutLantern)
local Guide=require(game.ReplicatedStorage.Shared.CampaignStoryGuide)
local function label(part,text)
 local gui=Instance.new('BillboardGui');gui.Name='NarrativeClue';gui.Size=UDim2.fromOffset(260,64);gui.StudsOffset=V(0,4,0);gui.MaxDistance=45;gui.Parent=part
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.TextWrapped=true;t.Font=Enum.Font.GothamBold;t.TextSize=13;t.TextColor3=Color3.fromRGB(247,227,169);t.TextStrokeTransparency=.2;t.Text=text;t.AutoLocalize=false;t.Parent=gui
end
function N.create(scene,c,g,area,k)
 local center,result,pal=k.center,k.result,k.pal
 local function board(parent,name,at,text)
  local p=k.part(parent,name,V(5,2.5,.3),at+V(0,2,0),pal.wood);label(p,text);return p
 end
 local function motif(parent,at)
  k.part(parent,'BrokenCrownSeal',V(3,.25,2),at+V(0,.25,0),pal.rock,Enum.Material.Slate)
  for i=-1,1 do k.part(parent,'CrownMarkStroke',V(.35,i==0 and .7 or 1,.2),at+V(i*.7,.7,0),Color3.fromRGB(170,111,205),Enum.Material.Neon)end
 end
 if c.id=='DW-02'and g.id=='exp_1'then
  k.model('MedicineReachesSurvivor',1,3,function(m)
   k.part(m,'PreparedReliefBench',V(10,.5,4),result+V(-9,1,-7),pal.wood)
   board(m,'BlueClothClue',result+V(-8,0,0),'MEDICINE DELIVERED\nBlue cloth leads to the missing driver.')
   for i=1,3 do k.part(m,'ClothTrail',V(1.3,1.8,.15),V(table.unpack(g.activity.steps[i].position))+V(4,2,0),Color3.fromRGB(108,166,203),Enum.Material.Fabric)end
  end)
 elseif c.id=='GW-01'and g.id=='exp_1'then
  local a=V(table.unpack(g.activity.steps[1].position));local b=V(table.unpack(g.activity.steps[2].position))
  board(scene,'TwoDifferentTrails',a+V(7,0,0),'Heavy wheels: north\nScout lights: toward the webs')
  Lantern.create(scene,CFrame.new(b+V(4,2,0)))
 elseif c.id=='GW-02'and g.id=='exp_1'then
  k.actor('Finn',result+V(-14,0,-3),result+V(-7,0,-3),0,2)
  k.moving('FinnFindsHisCourage',result,function(m)
   Lantern.create(m,CFrame.new(result+V(-10,2.2,-2)))
   board(m,'FinnFirstPromise',result+V(-6,0,2),'Tali needs a light.\nOne step. I can do one step.')
  end,{[0]=CFrame.new(result)*CFrame.Angles(0,0,-.14),[1]=CFrame.new(result)*CFrame.Angles(0,0,.08),[2]=CFrame.new(result),[3]=CFrame.new(result+V(0,1,0))})
 elseif c.id=='GW-06'and g.id=='exp_2'then
  k.model('FinnsPromiseKept',3,3,function(m)
   Lantern.create(m,CFrame.new(result+V(0,3,0)))
   board(m,'RescuedScoutsPromise',result+V(-6,0,0),'Every scout is through.\nWe will keep the road safe for you.')
  end)
 elseif c.id=='FV-04'then
  -- A noncombat witness uses the approved IceGolem visual, without an enemy rig/AI.
  local at=center+V(0,0,-area.size[2]*.12)
  local source=assert(game.ServerStorage.FrozenValeModels:FindFirstChild('ice_golem'),'Missing approved signal guardian visual')
  local key='FV-04:exp_2'
  local witness=k.moving('SignalGuardianWitness',at,function(m)
   local visual=source:Clone();visual.Name='NoncombatSignalGuardian'
   for _,v in ipairs(visual:GetDescendants())do
    if v:IsA('LuaSourceContainer')or v:IsA('Humanoid')then v:Destroy()
    elseif v:IsA('BasePart')then v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end
   end
   visual:SetAttribute('EnemyKind',nil);visual:SetAttribute('StoryWitness',true)
   local _,size=visual:GetBoundingBox();visual:ScaleTo(visual:GetScale()*10/math.max(1,size.Y))
   local box,bounds=visual:GetBoundingBox();visual:PivotTo(CFrame.new(at+V(0,bounds.Y/2,0))*box:Inverse()*visual:GetPivot());visual.Parent=m
  end,{[0]=CFrame.new(at),[1]=CFrame.new(at)*CFrame.Angles(0,math.pi/4,0),[2]=CFrame.new(at)*CFrame.Angles(0,math.pi/2,0),[3]=CFrame.new(at)*CFrame.Angles(0,math.pi,0)},key)
  witness:SetAttribute('NarrativeRole','AlarmRespondingWitness')
  k.model('FalseAlarmAimedAtRefuge',0,2,function(m)
   k.beam(m,'WrongAlarmBeam',at+V(0,6,0),center+V(area.size[1]*.36,6,0),.4,Color3.fromRGB(177,108,211),Enum.Material.Neon)
   board(m,'WarningRoadSign',at+V(-12,0,4),'WARNING → REFUGE ROAD\nWatch where the guardian turns.')
  end,key)
  k.model('ShelterSignalProtectsTravelers',3,3,function(m)
   k.beam(m,'PeacefulShelterBeam',at+V(0,6,0),center+V(-area.size[1]*.36,6,0),.4,Color3.fromRGB(111,211,194),Enum.Material.Neon)
   board(m,'RestoredRoadSign',at+V(-12,0,4),'SHELTER → TRAVELERS\nThe guardian protects their road again.')
   k.actor('Freya',result+V(-18,0,-4),result+V(-6,0,-4),3,3,key)
  end,key)
 elseif c.id=='FV-07'and g.id=='exp_2'then
  k.model('ShelterSignalsRemembered',3,3,function(m)
   board(m,'GuardianResolution',result+V(6,0,-5),'SHELTER SIGNAL RESTORED\nThe guardians protect the travelers again.')
   k.beam(m,'ShelterArrow',result+V(6,.2,-1),result+V(6,.2,9),.3,pal.accent,Enum.Material.Neon)
   for _,side in ipairs({-1,1})do k.beam(m,'ShelterArrowHead',result+V(6,.2,9),result+V(6+side*2,.2,6),.3,pal.accent,Enum.Material.Neon)end
  end)
  for i,name in ipairs({'West Village Traveler','East Village Traveler'})do
   local start=center+V((i==1 and -1 or 1)*area.size[1]*.3,0,-area.size[2]*.3)
   local finish=result+V(i==1 and -14 or -20,0,5)
   local arriving=k.actor(name,start,finish,3,3)
   for n=0,2 do arriving:SetAttribute('ExpansionPose'..n,CFrame.new(start))end
   arriving:SetAttribute('ExpansionTransitionSeconds',8)
  end
 elseif c.id=='EC-05'and g.id=='exp_2'then
  local inlet=V(table.unpack(g.activity.steps[1].position));local back=V(table.unpack(g.activity.steps[2].position))
  k.actor('Dagna',inlet+V(0,0,10),inlet+V(0,0,5),0,3)
  k.actor('Orik',back+V(0,0,10),back+V(0,0,5),0,3)
  for i,step in ipairs(g.activity.steps)do
   local at=V(table.unpack(step.position))
   local captions={'DAGNA: TRIANGLE → TANK','ORIK: TANK → RING RETURN','BRANN: SHIELD → CITY'}
   board(scene,'CrewCircuitDrawing'..i,at+V(0,0,7),captions[i])
   local arrow=k.part(scene,'FlowDirection',V(1,.1,3),at+V(0,.15,5),pal.accent,Enum.Material.Neon)
   arrow.CFrame*=CFrame.Angles(0,i==2 and math.pi or 0,0)
   for _,side in ipairs({-1,1})do
    local tip=arrow.CFrame:PointToWorldSpace(V(0,0,-1.5))
    local tail=arrow.CFrame:PointToWorldSpace(V(side*.9,0,-.5))
    k.beam(scene,'FlowArrowHead',tip,tail,.16,pal.accent,Enum.Material.Neon)
   end
  end
  k.model('CrewStartsItsWork',3,3,function(m)
   board(m,'SharedWorkPlan',result+V(-5,0,4),'Dagna: inlet ready\nOrik: return ready\nBrann: city shield ready')
  end)
 elseif c.id=='HG-01'and g.id=='exp_1'or c.id=='HG-04'and g.id=='exp_2'then
  local signal=k.model('FinnsReturningLantern',0,3,function(m)
   Lantern.create(m,CFrame.new(result+V(-12,3,4)))
   board(m,'FamiliarThreeBarSignal',result+V(-5,0,4),'THREE GOLD BARS\nFinn and Tali have secured the approach.')
  end)
  signal:SetAttribute('ExpansionRequires','GW-06:rear_guard')
  if c.id=='HG-04'then
   k.actor('Finn',result+V(-23,0,8),result+V(-10,0,8),1,3)
   k.actor('Tali',result+V(-26,0,11),result+V(-14,0,11),2,3)
  end
 end
 if not c.side and c.number%7==0 and g.id=='exp_2'then
  local resultScene=k.model('ConfirmedRegionalResult',3,3,function(m)
   board(m,'SavedRegionSummary',result+V(9,0,5),Guide.regions[c.epic].result)
  end)
  -- The final incident alone is not the region clear or the reward receipt.
  resultScene:SetAttribute('ExpansionRequires',c.id)
 end
 if c.id=='DW-07'and g.id=='exp_2'or c.id=='FV-04'and g.id=='exp_1'or c.id=='EC-07'and g.id=='exp_2'or c.id=='HG-06'and g.id=='exp_1'then
  motif(scene,result+V(7,0,0))
  board(scene,'RecurringConvoyEvidence',result+V(7,0,4),'BROKEN-CROWN CARGO MARK\nFollow the same delivery trail.')
 end
end
return N
