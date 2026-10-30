local Specs=require(game.ReplicatedStorage.Shared.LobbyFacilities)
local A=require(script.Parent.LobbyArchitecture)
local C=A.color
local W={}
local function model(parent,name)
 local m=Instance.new('Model');m.Name=name;m:SetAttribute('DawnspireFacility',true);m.Parent=parent;return m
end
local function portal(lobby)
 local spec=Specs.portal;local m=model(lobby.folder,'DawnspireExpeditionPortal');local make=A.builder(m,lobby.origin+spec.offset)
 make('PortalCourt',Vector3.new(31,.25,25),Vector3.new(0,.13,0),C.pale,Enum.Material.Cobblestone,true)
 make('PortalDais',Vector3.new(23,.4,12),Vector3.new(0,.2,-1),C.dark,Enum.Material.Slate,true)
 for _,x in ipairs({-11,11}) do
  make('ArchFoot',Vector3.new(5,1,5),Vector3.new(x,.5,-4),C.pale,Enum.Material.Marble)
  make('ArchPillar',Vector3.new(3.5,11,3),Vector3.new(x,6,-4),C.stone,Enum.Material.Marble)
  make('PillarGoldBand',Vector3.new(3.8,.5,3.3),Vector3.new(x,8.5,-4),C.gold,Enum.Material.Metal)
 end
 for i=0,23 do
  local angle=i*math.pi*2/24;local r=9.1
  make('ArchStone',Vector3.new(2.45,2.4,3.2),Vector3.new(math.cos(angle)*r,10+math.sin(angle)*r,-4),i%2==0 and C.pale or C.stone,Enum.Material.Marble,false,CFrame.Angles(0,0,angle))
  make('PortalRim',Vector3.new(.38,2.2,.5),Vector3.new(math.cos(angle)*7.7,10+math.sin(angle)*7.7,-2.25),C.purple,Enum.Material.Neon,false,CFrame.Angles(0,0,angle))
 end
 local core=make('PortalVeil',Vector3.new(.12,14.8,14.8),Vector3.new(0,10,-3.2),C.purple,Enum.Material.Neon,false,CFrame.Angles(0,math.pi/2,0));core.Shape=Enum.PartType.Cylinder;core.Transparency=.68
 A.light(core,C.purple,24,1.4)
 for i=1,7 do
  local angle=i*math.pi*2/7;local rune=make('OrbitRune',Vector3.new(.4,1.1,.3),Vector3.new(math.cos(angle)*6.8,10+math.sin(angle)*6.8,-1.9),C.cream,Enum.Material.Neon)
  rune:SetAttribute('TLTPortalOrbit',true);rune:SetAttribute('OrbitCenter',lobby.origin+spec.offset+Vector3.new(0,10,-1.9));rune:SetAttribute('OrbitAngle',angle)
 end
 local sign=make('PortalSign',Vector3.new(24,4,.65),Vector3.new(0,22,-3.3),C.blue,Enum.Material.Wood);A.sign(sign,spec)
 make('PortalSignTrim',Vector3.new(24.6,.35,.8),Vector3.new(0,24.1,-3.3),C.gold,Enum.Material.Metal)
 A.crown(make,Vector3.new(0,25.1,-3),.8)
 local anchor=make('PortalInteraction',Vector3.new(2,2,1),Vector3.new(0,2,6),C.gold);anchor.Transparency=1
 return {model=m,prompt=A.prompt(anchor,spec),anchor=anchor}
end
local function training(lobby)
 local spec=Specs.training;local m=model(lobby.folder,'DawnspireTrainingGround');local make=A.builder(m,lobby.origin+spec.offset)
 make('TrainingSand',Vector3.new(32,.22,31),Vector3.new(0,.12,0),Color3.fromRGB(170,143,96),Enum.Material.Sand,true)
 for _,x in ipairs({-16,16}) do
  for z=-14,14,7 do make('FencePost',Vector3.new(.65,3,.65),Vector3.new(x,1.5,z),C.wood,Enum.Material.Wood) end
  for _,y in ipairs({1,2.3}) do make('SideFenceRail',Vector3.new(.4,.4,30),Vector3.new(x,y,0),C.wood,Enum.Material.Wood) end
 end
 make('BackFence',Vector3.new(32,2,.6),Vector3.new(0,1,-15),C.wood,Enum.Material.Wood)
 for _,x in ipairs({-10,0,10}) do
  make('TargetStand',Vector3.new(.8,4,.8),Vector3.new(x,2,-9),C.wood,Enum.Material.Wood)
  for _,s in ipairs({{4.4,C.cream},{3.1,C.blue},{1.6,C.gold}}) do
   local t=make('ArcheryTarget',Vector3.new(.3,s[1],s[1]),Vector3.new(x,4,-8.8+(4.4-s[1])*.05),s[2],Enum.Material.SmoothPlastic,false,CFrame.Angles(0,math.pi/2,0));t.Shape=Enum.PartType.Cylinder
  end
  make('DummyBody',Vector3.new(2,2.4,1.4),Vector3.new(x,2.8,-1),Color3.fromRGB(185,147,88),Enum.Material.Fabric)
  local head=make('DummyHead',Vector3.new(1.5,1.5,1.5),Vector3.new(x,4.6,-1),C.wood,Enum.Material.Wood);head.Shape=Enum.PartType.Ball
  make('DummyArms',Vector3.new(4.6,.55,.6),Vector3.new(x,3.3,-1),C.wood,Enum.Material.Wood)
  make('DummyPole',Vector3.new(.6,2,.6),Vector3.new(x,1,-1),C.wood,Enum.Material.Wood)
 end
 for _,x in ipairs({-8,8}) do make('TrainingGatePost',Vector3.new(.8,10,.8),Vector3.new(x,5,13),C.wood,Enum.Material.Wood) end
 local sign=make('TrainingSign',Vector3.new(19,3.5,.6),Vector3.new(0,9,13),C.blue,Enum.Material.Wood);A.sign(sign,spec)
 make('TrainingSignTrim',Vector3.new(19.5,.3,.7),Vector3.new(0,10.9,13),C.gold,Enum.Material.Metal)
 for _,r in ipairs({-.65,.65}) do make('SwordSignBlade',Vector3.new(.35,3,.25),Vector3.new(0,12.6,13),C.pale,Enum.Material.Metal,false,CFrame.Angles(0,0,r)) end
 local anchor=make('TrainingInteraction',Vector3.new(2,2,1),Vector3.new(0,2,12),C.gold);anchor.Transparency=1
 return {model=m,prompt=A.prompt(anchor,spec),anchor=anchor}
end
function W.create(lobby)
 return {portal=portal(lobby),training=training(lobby)}
end
return W
