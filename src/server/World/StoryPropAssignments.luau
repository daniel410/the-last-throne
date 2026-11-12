-- Explicit visual contracts keyed by stable story IDs. Activity kind is not an asset.
-- Each row lists the existing steps in authored order; no title/keyword guessing.
local A={version=2,steps={},goals={}}
local function row(chapter,goal,ids,keys)
 assert(#ids==#keys,chapter..':'..goal)
 for i,id in ipairs(ids)do local key=chapter..':'..goal..':'..id;assert(not A.steps[key],key);A.steps[key]=keys[i]end
end
local function incident(chapter,first,second)
 row(chapter,'exp_1',{'step1','step2','step3'},first)
 if second then row(chapter,'exp_2',{'step1','step2','step3'},second)end
end
incident('DW-01',{'CargoSeal','MedicineSatchel','WheelRuts'},{'RoadRubble','FallenWheel','ClothSignal'})
incident('DW-02',{'MedicineSatchel','TravelPack','ClothSignal'},{'BrokenBranches','ClothSignal','ScoutMark'})
incident('DW-03',{'MedicineSatchel','PinnedRoster','FieldMap'},{'ScoutMark','SignalShutter','TravelPack'})
incident('DW-04',{'RootSeal','ScoutMark','RopeAnchor'},{'SignalShutter','RopeAnchor','RouteLantern'})
incident('DW-05',{'OreCarrier','RopeAnchor','ClothSignal'},{'PinnedRoster','FallenWheel','SealedDispatch'})
incident('DW-06',{'RootRouteMarker','ScoutMark','ClothSignal'},{'RootRouteMarker','SignalShutter','RootSeal'})
incident('DW-07',{'RoadRubble','BrokenBranches','ClothSignal'},{'CargoSeal','FieldMap','SealedDispatch'})
incident('DW-Q1',{'CargoSeal','TravelPack','ClothSignal'})
incident('DW-Q2',{'OreCarrier','FoodSacks','ClothSignal'})
incident('DW-Q3',{'OreSled','ShiftSlate','ScoutMark'})
incident('DW-Q4',{'ConvoyBadge','RoadRubble','ClothSignal'})
incident('GW-01',{'WheelRuts','ScoutLantern','ScoutMark'},{'BrokenBranches','ScoutMark','TravelPack'})
incident('GW-02',{'ScoutMark','WebBindings','ScoutLantern'},{'TravelPack','ScoutLantern','ScoutMark'})
incident('GW-03',{'ScoutLantern','FieldMap','SignalShutter'},{'RootRouteMarker','ScoutMark','RoadRubble'})
incident('GW-04',{'ScoutLantern','BrokenBranches','RootRouteMarker'},{'RopeAnchor','ScoutMark','ScoutLantern'})
incident('GW-05',{'ShedCarapace','RoadRubble','ScoutMark'},{'RopeAnchor','TravelBindings','ScoutLantern'})
incident('GW-06',{'RootRouteMarker','ScoutMark','TravelPack'},{'ScoutLantern','RopeAnchor','SignalShutter'})
incident('GW-07',{'ClothSignal','RoadRubble','ScoutMark'},{'WebBindings','RoadRubble','CargoSeal'})
incident('FV-01',{'FallenWheel','SnowSled','ClothSignal'},{'SnowSled','RouteLantern','ScoutMark'})
incident('FV-02',{'MedicineSatchel','CargoSeal','FieldMap'},{'RoadRubble','SnowBeacon','ScoutMark'})
incident('FV-03',{'SnowSled','ScoutMark','SnowBeacon'},{'GateWinch','RopeAnchor','RouteLantern'})
incident('FV-04',{'SignalPlate','SignalPlate','CargoSeal'},{'RelayInstrument','SignalPlate','RelayInstrument'})
incident('FV-05',{'CargoSeal','RootRouteMarker','RoadRubble'},{'GateWinch','RopeAnchor','RouteLantern'})
incident('FV-06',{'RoadRubble','IceGateLock','ScoutMark'},{'RelayInstrument','SignalPlate','RelayInstrument'})
incident('FV-07',{'SignalMirror','SealedDispatch','ScoutMark'},{'SignalMirror','SnowBeacon','FieldMap'})
incident('FV-Q1',{'ConvoyBadge','PinnedRoster','RouteLantern'})
incident('FV-Q2',{'GateWinch','RopeAnchor','RouteLantern'})
incident('FV-Q3',{'RoadRubble','ScoutMark','RouteLantern'})
incident('FV-Q4',{'ShiftSlate','SignalPlate','RouteLantern'})
incident('EC-01',{'LiftGear','CoolantPipe','OreCarrier'},{'OreCarrier','RopeAnchor','ClothSignal'})
incident('EC-02',{'CrewBoard','CoolingDiagram','ToolRoll'},{'CoolantPipe','OreCarrier','ScoutMark'})
incident('EC-03',{'OreCarrier','RopeAnchor','RouteLantern'},{'TravelPack','WorkerTag','ScoutMark'})
incident('EC-04',{'CoolantPipe','CoolantPipe','CoolantValve'},{'CoolantValve','CoolantPipe','PressureGauge'})
incident('EC-05',{'CoolingDiagram','CoolingDiagram','ProtectionRelay'},{'TankModel','TankModel','ProtectionRelay'})
incident('EC-06',{'CoolantPipe','MineBrace','PressureGauge'},{'CoolantPipe','PressureGauge','ProtectionRelay'})
incident('EC-07',{'CoolantPipe','RopeAnchor','ClothSignal'},{'EmptyKeyCarrier','SealedDispatch','FieldMap'})
incident('EC-Q1',{'WorkerTag','CrewBoard','RouteLantern'})
incident('EC-Q2',{'OreCarrier','SupplyCrate','ClothSignal'})
incident('EC-Q3',{'RoadRubble','ToolRoll','ScoutMark'})
incident('EC-Q4',{'OreSled','LiftGear','RouteLantern'})
incident('HG-01',{'ScoutMark','RootRouteMarker','KeeperLantern'},{'KeeperLantern','ScoutMark','RopeAnchor'})
incident('HG-02',{'FieldMap','ScoutMark','GateWinch'},{'KeeperLantern','SignalShutter','ScoutMark'})
incident('HG-03',{'KeeperLantern','TombSeal','ScoutMark'},{'CryptLatch','RopeAnchor','KeeperLantern'})
incident('HG-04',{'RopeAnchor','SealedDispatch','RoadRubble'},{'CryptLatch','ScoutLantern','ScoutMark'})
incident('HG-05',{'ThroneConduit','ThroneConduit','KeeperLantern'},{'ThroneConduit','RoadRubble','TombSeal'})
incident('HG-06',{'SealedDispatch','TombSeal','SealedDispatch'},{'KeeperLantern','RopeAnchor','SignalShutter'})
incident('HG-07',{'ScoutMark','ThroneConduit','RoadRubble'},{'BindingFrame','TombSeal','ScoutLantern'})
row('DW-01','supplies',{'manifest','bindings','resin'},{'ConvoySupplyCrate','TravelBindings','WheelRuts'})
row('DW-01','tracks',{'drag_marks','heavy_prints','scout_sign'},{'BrokenBranches','Footprints','ScoutMark'})
row('DW-01','trail_exit',{'approach'},{'ScoutMark'})
row('DW-02','testimony',{'crest','ritual'},{'ConvoyBadge','RaiderSigil'})
row('DW-02','clearing_exit',{'road','outpost'},{'RouteLantern','ScoutMark'})
row('DW-03','watchtower_order',{'map','ward'},{'FieldMap','TravelPack'})
row('DW-04','link_record',{'leaf','rain','root'},{'FieldMap','PinnedRoster','ScoutMark'})
row('DW-04','shortcut',{'counterweight','lantern'},{'GateWinch','RouteLantern'})
row('DW-05','transfer',{'names','orders','route'},{'PinnedRoster','SealedDispatch','ScoutMark'})
row('DW-06','ancient_network',{'shelter','water','roots','star'},{'RootRouteMarkerShelter','RootRouteMarkerWater','RootRouteMarkerRoots','RootRouteMarkerStar'})
row('DW-06','altar_path',{'safe_root','overlook','approach'},{'ScoutMark','RootRouteMarker','RootSeal'})
row('DW-07','core_record',{'purpose','cost','replacement'},{'CargoSeal','SealedDispatch','FieldMap'})
row('DW-07','stabilize',{'spring','roots','shelter','return'},{'RootSealSpring','RootSealRoots','RootSealShelter','RootSealReturn'})
row('DW-07','separate',{'clamp','isolate','secure'},{'ConvoySupplyCrate','MedicineSatchel','SealedDispatch'})
row('GW-01','marks',{'confirmed'},{'ScoutMark'})
row('GW-01','lantern',{'confirmed'},{'ScoutLantern'})
row('GW-02','bindings',{'confirmed'},{'WebBindings'})
row('GW-04','lantern',{'confirmed'},{'ScoutLantern'})
row('GW-05','rope',{'confirmed'},{'RopeAnchor'})
row('GW-06','webs',{'confirmed'},{'WebBindings'})
row('GW-07','exit',{'confirmed'},{'WebBindings'})
row('FV-06','palace_road',{'confirmed'},{'ScoutMark'})
row('EC-01','lift',{'operate'},{'GateWinch'})
row('EC-02','plan',{'confirmed'},{'ScoutMark'})
row('EC-03','supports',{'operate'},{'MineBrace'})
row('EC-04','west_valve',{'operate'},{'CoolantValve'})
row('EC-04','east_valve',{'operate'},{'CoolantValve'})
row('EC-06','intake',{'operate'},{'CoolantValve'})
row('EC-06','trial',{'operate'},{'ProtectionRelay'})
row('EC-07','coolant_west',{'operate'},{'CoolantValve'})
row('EC-07','coolant_east',{'operate'},{'CoolantValve'})
row('EC-07','restart',{'operate'},{'ProtectionRelay'})
row('HG-01','shelter',{'confirmed'},{'KeeperLantern'})
row('HG-03','passage',{'confirmed'},{'CryptLatch'})
row('HG-04','winch',{'confirmed'},{'GateWinch'})
row('HG-04','allies',{'confirmed'},{'ScoutLantern'})
row('HG-05','west',{'confirmed'},{'ThroneConduit'})
row('HG-05','east',{'confirmed'},{'ThroneConduit'})
row('HG-06','seal',{'confirmed'},{'TombSeal'})
-- The Crownheart has its own personal scene; never spawn a second static one.
row('HG-07','crownheart',{'confirmed'},{false})
row('HG-07','portal',{'confirmed'},{'PortalAnchor'})
local goals={
 ['DW-Q1:waterproof_log']='SealedDispatch',['DW-Q2:food_clue']='FoodSacks',['DW-Q2:food_store']='FoodSacks',
 ['DW-Q3:quarry_tools']='QuarryTools',['DW-Q3:quarry_record']='GateWinch',
 ['DW-Q4:scout_trace']='TravelPack',['DW-Q4:safe_return']='ScoutMark',
 ['FV-01:lanterns']='RouteLantern',['FV-02:route']='FieldMap',
 ['FV-03:west_beacon']='SnowBeacon',['FV-03:east_beacon']='SnowBeacon',
 ['FV-04:relay_west']='RelayInstrument',['FV-04:relay_east']='RelayInstrument',
 ['FV-05:marker_west']='CargoSeal',['FV-06:west_lock']='IceGateLock',['FV-06:east_lock']='IceGateLock',
 ['FV-07:mirror_west']='SignalMirror',['FV-07:mirror_east']='SignalMirror',['FV-07:mirror_crown']='SignalMirror',
 ['FV-Q1:name_tag']='ConvoyBadge',['FV-Q1:luggage']='TravelPack',
 ['FV-Q2:inspect']='SnowSled',['FV-Q3:inspect']='RopeAnchor',['FV-Q4:inspect']='SignalPlate',
 ['EC-03:cooling_map']='CoolingDiagram',['EC-04:plans']='CoolingDiagram',
 ['EC-05:blueprint']='CoolingDiagram',['EC-05:crew']='TankModel',['EC-05:test_order']='ToolRoll',
 ['EC-Q1:tool_tag']='WorkerTag',['EC-Q1:safety_record']='ShiftSlate',
 ['EC-Q2:inspect']='SupplyCrate',['EC-Q2:secure']='OreCarrier',
 ['EC-Q3:inspect']='ToolRoll',['EC-Q3:secure']='CoolantPipe',
 ['EC-Q4:inspect']='OreSled',['EC-Q4:secure']='QuarryTools',
}
A.goals=goals
A.actions={
 ['DW-04:link_record']='Read map',['DW-06:ancient_network']='Mark route',
 ['DW-06:exp_2']='Align marker',['DW-07:stabilize']='Shut down',
 ['FV-04:exp_2']='Align signal',['FV-06:exp_2']='Send signal',
}
function A.forStep(chapter,goal,step)return A.steps[chapter..':'..goal..':'..step.id]end
return A
