-- Authored native quest assets. Numeric geometry is shared by runtime and offline QA.
-- Local origins sit on the ground; no desks, floating books, or quest-state effects.
local models,parts={},{}
local wood={122,88,52};local pale={175,139,86};local iron={83,96,101};local brass={185,147,74}
local paper={225,210,167};local blue={79,153,180};local cloth={110,142,104};local stone={117,130,121};local ink={58,65,67}
local function box(name,size,at,color,material,rotation,shape)
 parts[#parts+1]={name=name,size=size,position=at,color=color or wood,material=material or 'Wood',rotation=rotation or {0,0,0},shape=shape or 'Block'}
end
local function beam(name,a,b,width,color,material)
 local d={b[1]-a[1],b[2]-a[2],b[3]-a[3]}
 parts[#parts+1]={name=name,size={width,width,math.sqrt(d[1]^2+d[2]^2+d[3]^2)},position={(a[1]+b[1])/2,(a[2]+b[2])/2,(a[3]+b[3])/2},look=b,color=color or iron,material=material or 'Metal',shape='Block',rotation={0,0,0}}
end
local function ring(name,at,r,width,color,plane)
 for i=0,7 do
  local function point(a)
   if plane=='xz'then return {at[1]+r*math.cos(a),at[2],at[3]+r*math.sin(a)}end
   return {at[1]+r*math.cos(a),at[2]+r*math.sin(a),at[3]}
  end
  beam(name,point(i*math.pi/4),point((i+1)*math.pi/4),width,color)
 end
end
local function finish(key,purpose)models[key]={purpose=purpose,parts=parts};parts={}end
local function bag(color)
 box('LeatherSatchel',{2.4,1.6,1.3},{0,.9,0},color,'Fabric')
 box('FoldedFlap',{2.5,.18,1.5},{0,1.8,0},color,'Fabric',{0,0,.12})
 for _,x in ipairs({-.75,.75})do box('LeatherStrap',{.18,1.8,1.4},{x,.95,0},pale,'Fabric');box('Buckle',{.32,.32,.12},{x,1.25,.78},brass,'Metal')end
 beam('SatchelHandle',{-.8,1.8,0},{0,2.35,0},.16,pale,'Fabric');beam('SatchelHandle',{0,2.35,0},{.8,1.8,0},.16,pale,'Fabric')
end
local function sheet(at,color)
 box('FoldedDocument',{2.1,.055,1.6},at,color or paper,'Fabric',{0,.12,0})
 for i=1,3 do box('DocumentInk',{1.35,.014,.055},{at[1]-.1,at[2]+.04,at[3]-.55+i*.28},ink,'Fabric')end
end
local function stake(color)
 box('TrailStake',{.35,3.2,.35},{0,1.6,0})
 box('DirectionBlade',{2.4,.65,.15},{.65,2.5,0},color or cloth,'Wood')
 box('DirectionTip',{.7,.65,.15},{2.1,2.5,0},color or cloth,'Wood',{0,0,0},'Wedge')
 box('TiedTrailCloth',{.55,1.2,.08},{-.15,2.1,.26},paper,'Fabric',{0,0,.18})
end
local function sled()
 for _,x in ipairs({-1.3,1.3})do box('SledRunner',{.3,.4,4.8},{x,.2,0},iron,'Metal');beam('RaisedSledNose',{x,.2,-2.3},{x,.8,-2.9},.25,iron)end
 for i=1,4 do box('SledDeck',{2.8,.18,.7},{0,.6,(i-2.5)*.85})end
end
bag(cloth)
for i=1,3 do box('MedicineVial',{.28,.7,.28},{-.55+i*.38,1.55,-.65},blue,'Glass');box('VialStopper',{.32,.12,.32},{-.55+i*.38,1.96,-.65},pale)end
box('RolledBandage',{.6,.5,.65},{1.5,.3,0},paper,'Fabric')
finish('MedicineSatchel','Weatherproof convoy medicine satchel with stoppered vials and rolled bandages.')
bag({112,86,65});box('Bedroll',{2.8,.7,.9},{0,.4,1.1},cloth,'Fabric')
finish('TravelPack','Recovered scout or traveler pack with bedroll, buckles and carrying loop.')
bag({92,72,55});sheet({1.8,.08,.1});box('DispatchWaxSeal',{.4,.08,.4},{1.8,.16,.2},{151,67,55},'SmoothPlastic')
finish('SealedDispatch','A courier satchel and sealed folded orders recovered from the roadside, not office furniture.')
box('BrokenCrateBoard',{3,.18,1.5},{0,.1,0},wood);box('CargoSealPlate',{1.5,.13,1},{0,.26,0},brass,'Metal')
for _,x in ipairs({-.4,.4})do beam('BrokenCrownSeal',{x,.36,-.2},{x*.6,.36,.35},.12,ink)end
finish('CargoSeal','Torn shipping seal still attached to a broken freight board; no Crownheart is inside.')
box('FallenTimber',{3.7,1,1.5},{0,.5,0});sheet({0,1.05,0});box('MapWeight',{.35,.18,.4},{.7,1.16,.5},stone,'Slate')
for i=1,3 do box('RouteOnMap',{.09,.025,1},{-.7+i*.35,1.1,0},blue,'Fabric',{0,i*.3,0})end
finish('FieldMap','Folded route sketch weighted on fallen timber for field use; no freestanding desk or ink bottle.')
for _,x in ipairs({-1,1})do box('NoticeStake',{.25,2.6,.25},{x,1.3,0})end
box('RosterBacking',{2.6,1.5,.2},{0,2,0});box('PinnedRoster',{2.2,1.2,.04},{0,2,.14},paper,'Fabric')
for i=1,4 do box('RosterEntry',{1.6,.06,.025},{0,1.45+i*.23,.18},ink,'Fabric')end
finish('PinnedRoster','Camp arrivals or missing-person roster pinned to a portable notice frame.')
box('BrokenAxle',{3,.35,.35},{0,.35,0});ring('FallenWheelRim',{0,1.25,.15},1.2,.2,wood)
for i=0,3 do local a=i*math.pi/2;beam('WheelSpoke',{0,1.25,.15},{math.cos(a)*1.1,1.25+math.sin(a)*1.1,.15},.13,pale,'Wood')end
finish('FallenWheel','Detached convoy wheel and snapped axle, physical evidence of a failed crossing.')
box('SignalStaff',{.25,4,.25},{0,2,0});box('RaisedCloth',{2.5,1.3,.1},{1.2,3.35,0},paper,'Fabric',{0,0,.08})
box('SignalKnot',{.5,.25,.4},{0,3.9,0},cloth,'Fabric')
finish('ClothSignal','A survivor cloth tied high to a branch staff, visible above a sheltered bend.')
stake();finish('ScoutMark','A scout direction stake with tied cloth, placed on the ground rather than wheel ruts at every waypoint.')
for i=1,3 do beam('SnappedBranch',{i-2,.15,-1},{i-1,.15,.6},.18,wood,'Wood');beam('BrokenTwig',{i-1,.15,.6},{i-.6,.2,1},.09,pale,'Wood')end
finish('BrokenBranches','Freshly snapped branches along the convoy pursuit trail.')
for i=1,4 do box('BootPrint',{.55,.045,.9},{i%2==0 and .5 or -.5,.03,(i-2.5)*.9},ink,'Ground',{0,.15*(i%2),0})end
finish('Footprints','Alternating light boot prints, distinct from the cargo wheel ruts.')
for _,x in ipairs({-1.2,1.2})do for i=1,4 do box('WheelRut',{.2,.035,.9},{x,.025,(i-2.5)*1},ink,'Ground')end end
finish('WheelRuts','Parallel heavy cargo wheel ruts pressed into the trail.')
box('SplitBark',{1.4,1.9,.25},{0,.98,0});for _,x in ipairs({-.4,.4})do beam('RaiderCut',{x,.3,.2},{-x,1.7,.2},.12,{150,73,107})end
finish('RaiderSigil','Raider portal sign cut into a discarded strip of bark, not a magical convoy residue.')
for i=1,4 do local a=i*math.pi/2;beam('BindingRoot',{math.cos(a)*2,.15,math.sin(a)*2},{math.cos(a)*.5,1.7,math.sin(a)*.5},.42,wood,'Wood')end
box('RootSealSocket',{1.8,.5,1.8},{0,.3,0},stone,'Slate');ring('SealCollar',{0,1.4,0},.8,.14,brass,'xz')
box('RootSealPlate',{1.2,1.5,.18},{0,1.4,.55},iron,'Metal');beam('SealInlay',{-.4,1,.68},{.4,1.9,.68},.1,blue)
finish('RootSeal','A portal cutoff socket bound into black roots, with a metal locking collar and local seal inlay.')
box('RootMarkerBase',{2,.4,1.6},{0,.2,0},stone,'Slate');box('CarvedRootSlab',{1.5,1.8,.5},{0,1.3,0},stone,'Slate')
for i=1,3 do beam('BranchGlyph',{0,.65,.3},{(i-2)*.5,1.8,.3},.085,cloth)end
finish('RootRouteMarker','A low carved rootway route marker; branch glyphs differ from portal cutoff hardware.')
for _,x in ipairs({-1.1,1.1})do box('ShutterPost',{.3,3,.4},{x,1.5,0})end
for i=1,3 do box('SignalSlat',{2.1,.5,.18},{0,.7+i*.65,0},paper,'Wood',{.25,0,0})end
box('ShutterPull',{.12,2,.12},{1.5,1.2,0},pale,'Fabric')
finish('SignalShutter','Watchtower signal shutter with three movable slats and pull cord, not a gate winch.')
for _,x in ipairs({-1,1})do box('AnchorStake',{.35,2.6,.35},{x,1.3,0},wood,'Wood',{0,0,-x*.15})end
for y=.9,1.5,.3 do beam('TensionedSafetyRope',{-1,y,0},{1,y,0},.13,pale,'Fabric')end
finish('RopeAnchor','Tensioned walking rail tied between driven stakes, with no phantom captive.')
for _,x in ipairs({-1.5,1.5})do box('WebAnchorBranch',{.35,3.6,.35},{x,1.8,0})end
for i=0,4 do beam('SilkBinding',{-1.5,.4+i*.6,0},{1.5,3.2-i*.55,0},.07,paper,'Fabric')end
beam('LooseSilkEnd',{-1.5,.5,0},{-.3,.15,1},.08,paper,'Fabric')
finish('WebBindings','Silk strands stretched across anchor branches; scout bindings remain visibly different from travel rope.')
box('ScoutLanternFoot',{1.5,.2,1.4},{0,.1,0},iron,'Metal');box('ScoutLanternPane',{1,1.5,.8},{0,1,0},blue,'Glass')
for _,x in ipairs({-.6,.6})do box('ScoutLanternFrame',{.12,1.9,1},{x,1.1,0},iron,'Metal')end
box('ScoutLanternHood',{1.6,.3,1.5},{0,2.1,0},iron,'Metal')
for i=1,3 do box('ThreeBarScoutCode',{.7,.12,.09},{0,.45+i*.36,.48},paper,'SmoothPlastic')end
ring('CarryLoop',{0,2.6,0},.35,.09,iron)
finish('ScoutLantern','Portable blue-pane scout lantern with the three-bar recognition code carried by Finn and Tali.')
for i=1,5 do box('ShedCarapaceSegment',{1.8,.7,1},{0,.4,(i-3)*.85},{133,109,73},'Slate',{0,(i-3)*.1,0},'Wedge')end
finish('ShedCarapace','Hollow segmented centipede shell marks the hunting ground before the crossing.')
for i=1,3 do box('OldRoadStone',{1.2,.35,1.8},{(i-2)*1.1,.2,(i%2)*.6},stone,'Slate',{0,i*.3,0})end
finish('RoadRubble','Weathered road paving and sheltered stepping stones, without fabricated wheel tracks.')
sled();box('TravelBlanket',{2.5,.5,2.4},{0,.95,.4},cloth,'Fabric');box('SnowCrust',{2,.14,.8},{0,1.3,1},paper,'Snow')
finish('SnowSled','Snowbound travelers sled with covered luggage and snow on the rear deck.')
for _,x in ipairs({-1,1})do box('BeaconLeg',{.35,3,.35},{x,1.5,0},iron,'Metal')end
box('BeaconBrazier',{2.8,.6,2.6},{0,3,0},iron,'Metal');for i=1,3 do box('BeaconFuel',{2,.25,.3},{0,3.4,(i-2)*.5},wood,'Wood',{0,i*.5,0})end
box('BeaconReflector',{2.8,1.8,.2},{0,4,1.2},brass,'Metal',{-.2,0,0})
finish('SnowBeacon','Village rescue beacon with fuel tray and wind reflector; distinct from a small route lantern.')
box('SignalPlateStand',{2.6,.5,1.6},{0,.25,0},stone,'Slate');box('AlarmPlate',{2.2,2.1,.18},{0,1.6,0},iron,'Metal')
for i=1,3 do box('SignalNotch',{1.5,.12,.08},{0,.8+i*.4,.15},blue,'SmoothPlastic')end
box('DisplacedPlateClip',{.25,2.2,.25},{1.2,1.6,.1},brass,'Metal',{0,0,.12})
finish('SignalPlate','A slotted alarm plate showing the replaced signal pattern, not a generic rune obelisk.')
for _,x in ipairs({-1,1})do box('RelayFoot',{.4,2.3,1.6},{x,1.15,0},iron,'Metal')end
box('OpticalRelayHousing',{2.8,.45,1.8},{0,2.5,0},brass,'Metal');box('RelayLens',{1.5,1.2,.18},{0,3.2,0},blue,'Glass')
ring('RelayLensRim',{0,3.2,0},.8,.13,brass)
finish('RelayInstrument','Archive optical relay with lens, housing and alignment feet; carries a local signal only.')
box('IceLockFoundation',{3,.4,2},{0,.2,0},stone,'Slate');box('SlidingIceLock',{2.8,1,.6},{0,1,.2},iron,'Metal')
box('LockKeySocket',{.7,.8,.3},{0,1.2,.65},brass,'Metal');for _,x in ipairs({-1.3,1.3})do box('IcedLockBracket',{.4,2,1},{x,1,0},{175,211,224},'Ice')end
finish('IceGateLock','Frost citadel sliding bolt locked into iced brackets, with a visible release socket.')
for _,x in ipairs({-1,1})do box('CrewBoardPost',{.35,3.2,.4},{x,1.6,0})end
box('CrewBoard',{3,1.9,.3},{0,2.4,0},wood)
for i=1,4 do box('WorkerNumberTag',{.5,.7,.08},{(i-2.5)*.6,2.4,.21},brass,'Metal');box('WorkerNumberSlot',{.2,.12,.03},{(i-2.5)*.6,2.4,.27},ink,'Metal')end
finish('CrewBoard','Miner sign-in board with numbered brass tags and empty crew slots.')
box('RolledPlanBacking',{2.8,.2,2},{0,.15,0},wood);sheet({0,.29,0},blue)
for _,x in ipairs({-.7,.7})do box('DrawnPipeLine',{.1,.02,1.3},{x,.35,0},paper,'Fabric')end
box('ReturnLine',{1.5,.02,.12},{0,.35,.6},paper,'Fabric')
finish('CoolingDiagram','A rolled blue cooling plan secured to its wooden carrying board; inlet and return paths are visible.')
box('ToolRollCloth',{3,.12,2},{0,.1,0},cloth,'Fabric')
for i=1,3 do box('ToolHandle',{.18,.2,1.7},{(i-2)*.8,.26,0},pale);box('ToolHead',{.65,.28,.35},{(i-2)*.8,.3,-.65},iron,'Metal')end
box('ToolRollTie',{3,.15,.12},{0,.43,.6},pale,'Fabric')
finish('ToolRoll','Repair crews opened tool roll, with individual wrench, hammer and chisel silhouettes.')
ring('LiftGearRim',{0,1.4,0},1.15,.23,iron)
for i=0,7 do local a=i*math.pi/4;box('LiftGearTooth',{.45,.4,.4},{math.cos(a)*1.4,1.4+math.sin(a)*1.4,0},brass,'Metal',{0,0,a})end
for i=0,3 do local a=i*math.pi/2;beam('GearSpoke',{0,1.4,0},{math.cos(a),1.4+math.sin(a),0},.18,iron)end
finish('LiftGear','Recovered freight lift gear with toothed rim and spokes, not a sealed wooden case.')
for _,x in ipairs({-1.5,1.5})do box('MineBraceFoot',{.7,.35,2},{x,.18,0});beam('MineBraceStrut',{x,.3,0},{x*.6,3.4,0},.4,wood,'Wood')end
box('MineBraceCap',{4,.5,1},{0,3.5,0});box('BraceScrew',{.3,1,.3},{0,2.6,0},iron,'Metal');box('BraceHandle',{1.4,.16,.2},{0,2.6,0},brass,'Metal')
finish('MineBrace','A compact screw brace propping up a cracked mine beam; no unrelated gate mechanism.')
sled();box('OreHopper',{2.6,1.2,2.5},{0,1.3,0},iron,'Metal')
for _,x in ipairs({-1.5,1.5})do ring('CarrierWheel',{x,.65,0},.55,.15,iron)end
finish('OreCarrier','Empty low ore carrier on runners with a metal hopper and hauling wheels.')
box('PipeSaddle',{2.5,.3,1.8},{0,.15,0},stone,'Basalt');box('CoolingPipe',{3.3,.9,.9},{0,1.1,0},iron,'Metal',nil,'Cylinder')
for _,x in ipairs({-1.3,1.3})do box('PipeFlange',{.22,1.4,1.4},{x,1.1,0},brass,'Metal',nil,'Cylinder')end
box('ReturnElbow',{.8,1.5,.8},{1.7,1.5,0},iron,'Metal');box('FlowArrow',{1.1,.08,.35},{0,1.6,0},blue,'SmoothPlastic')
finish('CoolantPipe','Supported inlet or return pipe with bolted flanges, elbow and flow-direction strip.')
box('GaugeFoot',{1.8,.35,1.4},{0,.18,0},iron,'Metal');box('GaugeStem',{.3,1.8,.3},{0,1.1,0},brass,'Metal')
ring('PressureGaugeRim',{0,2.3,0},.9,.18,brass);box('PressureGaugeFace',{1.5,1.5,.12},{0,2.3,0},paper,'SmoothPlastic')
beam('PressureNeedle',{0,2.3,.15},{.4,2.8,.15},.08,ink);for _,x in ipairs({-.5,0,.5})do box('GaugeTick',{.08,.2,.05},{x,2.8,.15},ink,'Metal')end
finish('PressureGauge','Upright return-pressure gauge with dial, needle and pipe stem.')
box('CircuitModelBase',{4.6,.3,3},{0,.15,0},wood)
for _,x in ipairs({-1.5,1.5})do box('ModelTank',{1,1.8,1.1},{x,1.2,0},iron,'Metal');box('TankCap',{1.2,.2,1.3},{x,2.2,0},brass,'Metal')end
beam('ModelInlet',{-1.5,1.2,.5},{1.5,1.2,.5},.18,blue);beam('ModelReturn',{-1.5,.5,-.5},{1.5,.5,-.5},.18,brass)
finish('TankModel','Portable furnace safety demonstrator with separate inlet and return tanks and visible paired loops.')
box('ProtectionRelayBase',{2.8,.3,2},{0,.15,0},iron,'Metal')
for _,x in ipairs({-.9,.9})do box('RelayTerminal',{.3,1.4,.5},{x,1,0},brass,'Metal')end
box('ShieldRelayPlate',{1.4,1.5,.15},{0,1.4,0},blue,'Metal',nil,'Wedge');beam('RelayBridge',{-.9,1.6,0},{.9,1.6,0},.15,brass)
finish('ProtectionRelay','Dwarven city protection relay with shield plate and two isolated terminals; no Crownheart replica.')
sled();for _,x in ipairs({-.9,.9})do beam('EmptyCarrierClamp',{x,.8,0},{x*.5,2.4,0},.22,brass)end
box('EmptyCarrierSocket',{1.8,.35,1.5},{0,1.3,0},ink,'Metal')
finish('EmptyKeyCarrier','An empty outbound carrier with open clamps and vacant socket; the stolen Crownheart has already left.')
box('WorkerTag',{1.3,.15,1.9},{0,.1,0},brass,'Metal');ring('TagCord',{0,.18,-.7},.5,.06,pale,'xz')
for i=1,3 do box('StampedWorkNumber',{.12,.03,.5},{-.5+i*.25,.2,.25},ink,'Metal')end
finish('WorkerTag','Numbered workers brass identification tag on a short cord, distinct from a convoy captains badge.')
sled();for i=1,3 do box('OldOreBlock',{.8,.8,.9},{(i-2)*.8,1.1,0},stone,'Slate',nil,'Wedge')end
finish('OreSled','Old ore hauling sled with exposed runners and a few unworked mineral blocks.')
box('KeeperNicheBase',{2.4,.3,1.6},{0,.15,0},stone,'Slate')
for _,x in ipairs({-.9,.9})do box('KeeperNicheSide',{.35,2.8,1},{x,1.7,0},stone,'Slate')end
box('KeeperNicheCap',{2.5,.4,1.5},{0,3.3,0},stone,'Slate');box('KeeperLamp',{.8,1.2,.7},{0,1.2,0},{164,186,162},'Glass')
box('KeeperCandle',{.2,.6,.2},{0,.8,0},paper,'SmoothPlastic')
finish('KeeperLantern','Stone keeper niche and sheltered candle lantern, matching Lumi and the tomb caretakers.')
box('CryptLatchBase',{2.5,.35,1.5},{0,.18,0},stone,'Slate');box('ServiceCatch',{2.4,.45,.35},{0,1.4,0},iron,'Metal')
for _,x in ipairs({-.9,.9})do box('CatchBracket',{.3,1.8,.8},{x,1,0},iron,'Metal')end
ring('CatchPullRing',{0,1.4,.35},.4,.09,brass)
finish('CryptLatch','Low crypt service-door catch with sliding bar and pull ring; not the allied main gate winch.')
for _,x in ipairs({-1.4,1.4})do box('ThroneConduitFoot',{.6,1,1.5},{x,.5,0},stone,'Slate')end
box('ThroneConduit',{3.5,.5,.6},{0,1.1,0},iron,'Metal');for i=1,3 do box('ConduitBinding',{.25,1.1,1},{(i-2)*1.1,1.1,0},{133,92,172},'Glass')end
finish('ThroneConduit','Metal conduit and violet binding collars powering the outer throne defenses, not the Crownheart itself.')
box('TombSealBase',{3,.4,2.4},{0,.2,0},stone,'Slate');ring('TombSealRing',{0,1.65,0},1.2,.24,brass)
for _,x in ipairs({-.65,.65})do box('TombLockBar',{.25,2,.5},{x,1.6,0},iron,'Metal')end
box('TombSealWedge',{1.3,1.3,.3},{0,1.65,.3},stone,'Slate',nil,'Wedge')
finish('TombSeal','Royal tomb interlocking seal ring and stone key wedge, separate from the final invasion portal.')
for _,x in ipairs({-1.3,1.3})do box('EmptyFrameFoot',{.7,.3,2},{x,.15,0},iron,'Metal');beam('EmptyBindingArm',{x,.3,0},{x*.6,2.5,0},.25,iron)end
box('EmptyBindingCrossbar',{3.4,.25,.4},{0,2.6,0},brass,'Metal');ring('VacantBindingCollar',{0,1.5,0},.7,.15,brass)
finish('BindingFrame','Empty released binding frame with a vacant collar; never duplicates the recovered Crownheart.')
for i=1,3 do box('FoodSack',{1.1,1.4,1.4},{(i-2)*1.2,.7,(i%2)*.4},pale,'Fabric');box('SackTie',{.7,.15,.5},{(i-2)*1.2,1.45,(i%2)*.4},cloth,'Fabric')end
finish('FoodSacks','Dry tied sacks of stolen grain and camp food for Lioras shared meal.')
for i=1,3 do beam('QuarryToolShaft',{(i-2)*.8,.15,-1},{(i-2)*.8,.15,1.2},.16,pale,'Wood');box('QuarryPickHead',{1,.25,.3},{(i-2)*.8,.2,-.8},iron,'Metal',{0,.3,0})end
finish('QuarryTools','Abandoned picks and wedges laid at the hauling route, distinct from medical supplies.')
box('WorkSlate',{2.5,.2,1.8},{0,.13,0},stone,'Slate');for i=1,4 do box('ChalkShiftMark',{1.7,.025,.06},{0,.25,-.8+i*.3},paper,'SmoothPlastic')end
finish('ShiftSlate','Weatherproof shift or safety slate with chalk marks; no open bound book left on a trail.')
-- The four portal controls and route signs have different silhouettes in their inlays.
local glyphs={
 Spring={{{-.5,1.2,.7},{0,1.8,.7}},{{0,1.8,.7},{.5,1.2,.7}},{{-.45,.9,.7},{.45,.9,.7}}},
 Water={{{-.5,1.1,.7},{.5,1.1,.7}},{{-.5,1.5,.7},{.5,1.5,.7}}},
 Roots={{{0,.8,.7},{0,1.9,.7}},{{0,1.2,.7},{-.5,.8,.7}},{{0,1.2,.7},{.5,.8,.7}}},
 Shelter={{{-.55,1.4,.7},{0,1.9,.7}},{{0,1.9,.7},{.55,1.4,.7}},{{-.4,1.4,.7},{-.4,.8,.7}},{{.4,1.4,.7},{.4,.8,.7}}},
 Return={{{-.5,1.3,.7},{.5,1.3,.7}},{{-.5,1.3,.7},{-.1,1.7,.7}},{{-.5,1.3,.7},{-.1,.9,.7}}},
 Star={{{-.5,.9,.7},{.5,1.8,.7}},{{-.5,1.8,.7},{.5,.9,.7}},{{0,.8,.7},{0,1.9,.7}}},
}
for _,base in ipairs({'RootSeal','RootRouteMarker'})do for symbol,lines in pairs(glyphs)do
 if (base=='RootSeal'and symbol~='Water'and symbol~='Star')or(base=='RootRouteMarker'and symbol~='Spring'and symbol~='Return')then
 for _,p in ipairs(models[base].parts)do if p.name~='SealInlay'and p.name~='BranchGlyph'then parts[#parts+1]=p end end
 for _,line in ipairs(lines)do
  local a,b=line[1],line[2];local z=base=='RootRouteMarker'and .31 or .7
  beam('StorySymbol'..symbol,{a[1],a[2],z},{b[1],b[2],z},.11,blue)
 end
 finish(base..symbol,models[base].purpose..' Recognizable '..symbol:lower()..' symbol.')
end end end
return models
