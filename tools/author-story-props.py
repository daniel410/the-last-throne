"""Deterministic story prop kit. One geometry description drives Studio and Blender."""
import json, math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/models/story-props-v1'
wood=[105,73,43]; pale=[145,106,64]; dark=[48,44,42]; iron=[68,77,80]; brass=[163,125,63]; stone=[116,128,115]; paper=[216,201,158]; blue=[56,102,138]; light=[236,183,89]; purple=[133,92,172]
models={}; pieces=[]
def box(name,size,p,c=wood,mat='Wood',rot=None,shape='Block'):
 pieces.append(dict(name=name,size=size,position=p,color=c,material=mat,rotation=rot or [0,0,0],shape=shape))
def beam(name,a,b,width=.12,c=iron,mat='Metal'):
 d=[b[i]-a[i] for i in range(3)];length=math.sqrt(sum(x*x for x in d))
 # Roblox lookAt makes local -Z point along the beam.
 pieces.append(dict(name=name,size=[width,width,length],position=[(a[i]+b[i])/2 for i in range(3)],color=c,material=mat,look=b,shape='Block',rotation=[0,0,0]))
def ring(name,p,r,width=.12,c=iron,plane='xy',n=12):
 for i in range(n):
  a=i*2*math.pi/n;b=(i+1)*2*math.pi/n
  if plane=='xy': u=[p[0]+r*math.cos(a),p[1]+r*math.sin(a),p[2]];v=[p[0]+r*math.cos(b),p[1]+r*math.sin(b),p[2]]
  elif plane=='yz': u=[p[0],p[1]+r*math.cos(a),p[2]+r*math.sin(a)];v=[p[0],p[1]+r*math.cos(b),p[2]+r*math.sin(b)]
  else:u=[p[0]+r*math.cos(a),p[1],p[2]+r*math.sin(a)];v=[p[0]+r*math.cos(b),p[1],p[2]+r*math.sin(b)]
  beam(name,u,v,width,c)
def finish(name,purpose):
 global pieces
 models[name]=dict(purpose=purpose,parts=pieces);pieces=[]
def crate(at=(0,0,0),scale=1):
 def q(p):return [at[i]+p[i]*scale for i in range(3)]
 for z in [-1.1,1.1]:
  for j in range(4):box('CargoPlank',[2.7*scale,.47*scale,.16*scale],q([0,.28+j*.5,z]),pale)
  for x in [-1.1,1.1]:box('ForgedCornerStrap',[.18*scale,2.1*scale,.2*scale],q([x,1,z]),iron,'Metal')
  beam('DiagonalCargoBrace',q([-1.15,.2,z*1.12]),q([1.15,1.9,z*1.12]),.18*scale)
 for x in [-1.27,1.27]:box('CargoEnd',[.16*scale,2*scale,2.2*scale],q([x,1,0]),wood)
 for j in range(5):box('CargoLid',[.5*scale,.13*scale,2.3*scale],q([-1.04+j*.52,2.08,0]),pale)
 box('DeliverySeal',[.55*scale,.1*scale,.6*scale],q([.5,2.2,.2]),blue,'Fabric')
crate();finish('SupplyCrate','Recovered village food and medicine; plank lid, diagonal braces and delivery seal.')
# Cut travel rope, loose ends and an overturned fastening peg.
for r in [.55,.75,.95]:ring('CoiledTravelRope',[0,.13,0],r,.12,pale,'xz',12)
beam('CutRopeEnd',[.8,.15,0],[1.7,.15,.65],.12,pale,'Fabric')
beam('LooseRopeEnd',[-.6,.15,-.3],[-1.7,.12,-.1],.12,pale,'Fabric')
box('DiscardedWoodPeg',[.2,.2,1.3],[1.3,.14,-.9],wood,rot=[0,.55,0])
finish('TravelBindings','Untied convoy travel ropes with cut ends and a discarded wooden fastening peg.')
# Desk, binding, curved-looking page stacks, page rules, wax seal, quill and compass.
for x in [-1.65,1.65]:
 for z in [-.9,.9]:box('TrestleLeg',[.3,2.6,.3],[x,1.3,z],wood,rot=[0,0,x*.08])
 box('TrestleFoot',[.5,.22,2.8],[x,.15,0],dark)
box('DeskStretcher',[3.6,.25,.25],[0,.8,0],wood)
for i in range(5):box('UnevenTablePlank',[4.3,.22,.44],[0,2.7,-.92+i*.46],pale if i%2 else wood)
box('LeatherBookBinding',[2.45,.13,1.65],[-.35,2.89,0],dark)
for side in [-1,1]:
 box('BoundPageStack',[1.05,.15,1.45],[-.35+side*.56,3.01,0],paper, 'SmoothPlastic',rot=[0,0,side*.07])
 for j in range(5):box('HandwrittenLedgerRule',[.72,.015,.022],[-.35+side*.56,3.105,-.48+j*.22],[112,99,72],'SmoothPlastic')
box('BookSpine',[.12,.15,1.5],[-.35,3.03,0],brass,'Metal')
box('InkWell',[.3,.33,.3],[1.6,2.99,-.65],dark,'Metal');beam('Quill',[1.6,3.1,-.65],[1.9,3.95,-.45],.045,paper,'SmoothPlastic')
box('QuillFeather',[.16,.6,.04],[1.82,3.7,-.48],paper,'SmoothPlastic',rot=[0,0,-.35])
ring('CompassRim',[1.45,2.88,.55],.27,.055,brass,'xz',8);beam('CompassNeedle',[1.25,2.9,.55],[1.64,2.9,.55],.05,blue)
finish('LedgerDesk','Convoy manifests, northern orders and Eryn rescue maps; readable book, ink and compass.')
box('BadgeDisplayCloth',[2,.07,1.7],[0,.06,0],blue,'Fabric',rot=[0,.2,0])
box('CaptainBadge',[.9,.12,1.1],[0,.18,0],brass,'Metal',rot=[0,.2,0])
for x in [-.26,0,.26]:box('CrownPoint',[.12,.12,.48],[x,.31,-.14],light,'Metal',rot=[0,x*.6,0])
box('BadgePin',[.08,.1,.7],[.7,.17,.4],iron,'Metal',rot=[0,.6,0]);finish('ConvoyBadge','A captain badge on the convoy blue cloth; distinct from paperwork.')
# Weathered transport wreck: separated floorboards, actual axles, spoked rim wheels and cargo.
for i in range(7):box('CartBedPlank',[1.1,.3,5.6],[-3.6+i*1.2,2.5,0],pale if i%2 else wood)
for z in [-2.2,2.2]:box('CartAxle',[10,.3,.3],[0,1.8,z],iron,'Metal')
for x in [-4.1,4.1]:
 for j in range(3):box('CartSideBoard',[.18,.48,5.7],[x,3+j*.56,0],wood)
 for z in [-2.35,2.35]:box('SideBoardUpright',[.28,2.3,.25],[x,3.25,z],dark)
for x,z in [(-4.8,-2.2),(-4.8,2.2),(4.8,-2.2)]:
 ring('ForgedWheelTyre',[x,1.85,z],1.75,.21,iron,'yz',12)
 for j in range(8):
  a=j*math.pi/4;beam('WoodWheelSpoke',[x,1.85,z],[x,1.85+1.62*math.cos(a),z+1.62*math.sin(a)],.14,wood,'Wood')
 box('WheelHub',[.65,.55,.55],[x,1.85,z],brass,'Metal',shape='Cylinder')
ring('DetachedWheelTyre',[5.9,.23,3.5],1.7,.2,iron,'xz',12)
for j in range(6):
 a=j*math.pi/3;beam('DetachedSpoke',[5.9,.23,3.5],[5.9+1.6*math.cos(a),.23,3.5+1.6*math.sin(a)],.14,wood,'Wood')
for x in [-1.9,1.9]:beam('BrokenTowShaft',[x,2,-2.5],[x,1,-6.6],.25,wood,'Wood')
crate((0,2.7,0),.85);finish('CartWreck','Ambushed relief convoy; detached fourth wheel, wooden spokes, broken tow shafts and recoverable cargo.')
# Rescue cage, without adding collision or inventing a captive sphere.
for i in range(9):box('CageFloorboard',[.95,.22,8.2],[-3.9+i*.975,.15,0],wood)
for x in [-4.1,4.1]:
 for z in [-4.1,4.1]:box('CageCornerPost',[.45,8.6,.45],[x,4.3,z],dark,'Metal')
 for y in [.7,7.6]:box('SideIronRail',[.22,.26,8.3],[x,y,0],iron,'Metal')
 for z in [-3,-1.5,0,1.5,3]:box('SidePrisonBar',[.15,7,.15],[x,4.1,z],iron,'Metal')
for z in [-4.1,4.1]:
 for y in [.7,7.6]:box('FrontIronRail',[8.3,.26,.22],[0,y,z],iron,'Metal')
 for x in [-3,-1.5,0,1.5,3]:box('DoorPrisonBar',[.15,7,.15],[x,4.1,z],iron,'Metal')
for i in range(5):box('RoofPlank',[8.6,.25,1.65],[0,8.55,-3.3+i*1.65],wood)
for y in [1.8,6.5]:box('ForgedDoorHinge',[.65,.42,.38],[-3.8,y,4.23],brass,'Metal')
box('DoorHasp',[1.2,.3,.17],[.6,3.7,4.27],brass,'Metal');ring('LockShackle',[.9,3.65,4.4],.28,.09,iron,n=8)
box('CaptiveDoorLock',[.65,.65,.3],[.9,3.2,4.4],dark,'Metal');box('LockKeyhole',[.08,.16,.02],[.9,3.2,4.56],brass,'Metal')
finish('PrisonCage','Raider prison enclosure: bars on every side, hinged gate and padlock; captive NPC remains independent.')
# Winch with cable drum, toothed gear, crank, pawl and rope leading to guide pulley.
for x in [-1.4,1.4]:box('WinchTimberFoot',[.65,.45,4],[x,.23,0],wood);box('WinchCheek',[.35,3.8,2.2],[x,2.1,0],iron,'Metal')
box('WindingDrum',[2.7,1.5,1.5],[0,2.7,0],wood,shape='Cylinder')
for x in [-1,-.6,-.2,.2,.6,1]:ring('WoundHempCable',[x,2.7,0],.82,.13,pale,'yz',10)
ring('RatchetGear',[-1.7,2.7,0],1.05,.16,iron,'yz',12)
for j in range(8):
 a=j*math.pi/4;box('RatchetTooth',[.25,.28,.28],[-1.7,2.7+1.13*math.cos(a),1.13*math.sin(a)],brass,'Metal',rot=[a,0,0])
beam('WinchCrank',[1.8,2.7,0],[1.8,3.7,0],.18,brass);box('CrankGrip',[.9,.25,.25],[2.15,3.7,0],wood,shape='Cylinder')
beam('GearPawl',[-1.8,3.55,-.5],[-1.8,3.5,.35],.18,brass)
beam('TensionedRope',[0,3.4,0],[0,3.4,-2.1],.12,pale,'Fabric');ring('GuidePulley',[0,3.1,-2.1],.35,.11,iron,'yz',8)
finish('GateWinch','Return gate/lift mechanism; rope drum, ratchet teeth, safety pawl and hand crank.')
# Dwarven coolant valve: flanged pipe, handwheel, ribs, gauge and visible bolted joints.
for x in [-1.6,1.6]:box('ValveMount',[.6,.5,3],[x,.25,0],dark,'Metal')
box('CoolantPipe',[4.7,1.45,1.45],[0,1.35,0],iron,'Metal',shape='Cylinder')
for x in [-2.2,2.2]:
 ring('BoltedFlange',[x,1.35,0],.92,.22,brass,'yz',12)
 for j in range(6):
  a=j*math.pi/3;box('FlangeBolt',[.3,.16,.16],[x,1.35+.9*math.cos(a),.9*math.sin(a)],dark,'Metal',shape='Cylinder')
box('ValveBonnet',[1,1.8,1],[0,2.4,0],brass,'Metal');box('ValveStem',[.19,1.3,.19],[0,3.45,0],iron,'Metal')
ring('ValveHandwheel',[0,4.05,0],1.4,.18,brass,'xz',12)
for j in range(4):
 a=j*math.pi/2;beam('HandwheelSpoke',[0,4.05,0],[1.3*math.cos(a),4.05,1.3*math.sin(a)],.14,brass)
box('PressureGauge',[.9,.9,.22],[1.05,2.75,.65],paper,'SmoothPlastic');ring('GaugeBezel',[1.05,2.75,.8],.48,.08,iron,n=10)
beam('PressureNeedle',[1.05,2.75,.83],[1.29,3.02,.83],.045,dark);box('CoolantDirection',[.9,.08,.23],[-.8,2.1,0],blue,'Metal')
finish('CoolantValve','Dagna coolant circuits: bolted pipe flanges, brass handwheel and pressure gauge.')
box('LanternFoot',[1.7,.35,1.7],[0,.18,0],stone,'Slate');box('LanternPost',[.38,5.6,.38],[0,3,0],wood)
beam('HangingBracket',[0,5.9,0],[1.4,5.9,0],.17,iron);beam('BracketBrace',[0,5.1,0],[1.2,5.9,0],.13,iron)
ring('LanternHanger',[1.3,5.62,0],.22,.07,iron,n=8)
for y in [3.8,5.3]:box('LanternFrame',[1.3,.16,1.1],[1.3,y,0],iron,'Metal')
for x in [.72,1.88]:
 for z in [-.48,.48]:box('LanternFrameUpright',[.09,1.5,.09],[x,4.55,z],iron,'Metal')
box('FrostedLanternPane',[.94,1.25,.72],[1.3,4.55,0],light,'Glass')
box('LanternCandle',[.22,.67,.22],[1.3,4.2,0],paper,'SmoothPlastic');box('SmallFlame',[.12,.25,.12],[1.3,4.67,0],light,'Neon')
for s in [-1,1]:box('SlopedLanternHood',[.88,.12,1.3],[1.3+s*.34,5.55,0],iron,'Metal',rot=[0,0,-s*.38])
finish('RouteLantern','Survivor route lantern: iron bracket, hood, glass enclosure and candle; no floating glowing sphere.')
# Carved marker/portal socket; cut stone joints, inset glyphs, metal collars, restrained emission.
for i in range(3):box('SteppedStonePlinth',[4.8-i*.7,.4,4.3-i*.6],[0,.2+i*.4,0],stone,'Slate')
box('CarvedMarkerBody',[2.3,3.2,1.45],[0,2.8,0],stone,'Slate')
box('InsetGlyphPanel',[1.6,2.4,.08],[0,2.8,.77],dark,'Slate')
for a,b in [([-.5,2,.84],[0,3.6,.84]),([0,3.6,.84],[.5,2,.84]),([-.4,2.5,.84],[.4,2.5,.84])]:beam('InlaidRouteGlyph',a,b,.085,blue)
box('MarkerCap',[2.6,.35,1.8],[0,4.55,0],stone,'Slate');box('MarkerCrest',[.55,.18,.65],[0,4.8,0],brass,'Metal')
finish('SealWaystone','Safe-route signs and rune switches; a carved stone sign with an inlaid geometric route glyph.')
for i in range(3):box('AltarFoundation',[6.4-i*.7,.35,5.8-i*.6],[0,.18+i*.35,0],stone,'Slate')
for j in range(6):
 a=j*math.pi/3;box('SocketStone',[1,.8,1],[1.8*math.cos(a),1.45,1.8*math.sin(a)],stone,'Slate',rot=[0,-a,0])
ring('FocusMetalCollar',[0,1.9,0],1.75,.22,brass,'xz',12)
for x in [-1.15,1.15]:
 beam('FocusClamp',[x,1.6,0],[x*.5,2.85,0],.22,iron);box('FocusClampJaw',[.6,.22,.5],[x*.5,2.85,0],brass,'Metal')
box('FacetedPortalFocus',[.85,1.65,.85],[0,2.7,0],purple,'Glass',rot=[0,.785,0],shape='Wedge')
box('InsetSealFace',[2.4,.8,.08],[0,.7,2.93],dark,'Slate')
for x in [-.7,0,.7]:box('SealFaceInlay',[.1,.5,.1],[x,.7,3],purple,'Neon',rot=[0,0,.35])
finish('PortalAnchor','King Shaman portal power socket; stepped altar, six stone blocks, brass collar and clamped crystal.')
# Trail has physical evidence: broken branch, scored wheel ruts and mud prints.
for x in [-1.1,1.1]:
 for j in range(4):box('ScoredWheelRut',[.13,.035,.85],[x,.025,j*.75-1],dark,'Ground',rot=[0,.08*j,0])
for j in range(3):
 x=(-1)**j*.4;box('BootSole',[.43,.055,.72],[x,.04,j*.85],dark,'Ground',rot=[0,.2*(-1)**j,0])
 box('BootHeel',[.35,.07,.2],[x,.05,j*.85+.5],dark,'Ground')
beam('SnappedBranch',[-1.8,.13,1.5],[-.7,.13,2.1],.17,wood,'Wood');beam('BrokenTwig',[-1.2,.15,1.8],[-1.45,.2,2.3],.08,pale,'Wood')
finish('TrailEvidence','Convoy wheel ruts, boot heels and broken branches, grounded in the trail rather than luminous residue.')
# Stone ruin gateway, authored blocks and voussoirs rather than a flat lintel.
for side in [-1,1]:
 for j in range(5):box('WeatheredPierBlock',[4,3.15,4.4],[side*9,1.6+j*3.2,0],stone,'Slate',rot=[0,side*.025*(j%2),0])
 box('PierFoot',[5.2,.6,5.5],[side*9,.3,0],dark,'Slate');box('PierCapital',[5,1.1,5.2],[side*9,16.3,0],stone,'Slate')
for j in range(9):
 a=j*math.pi/8;box('ArchVoussoir',[3.65,3.2,4.6],[9*math.cos(a),16.5+9*math.sin(a),0],stone,'Slate',rot=[0,0,a-math.pi/2])
box('ArchKeystone',[2,3.7,4.9],[0,25.5,0],brass,'Slate')
for side in [-1,1]:box('MossInMortar',[3.7,.1,4.5],[side*9,6.4,0],[79,103,67],'Grass')
finish('RuinedArch','Occupied cloister gateway built from staggered stone courses, voussoirs, capitals and a keystone.')
OUT.mkdir(parents=True,exist_ok=True)
(OUT/'geometry.json').write_text(json.dumps(dict(version=1,models=models),indent=2)+'\n')
# JSON syntax is valid Luau only after explicit table conversion.
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(lua(x) for x in v)+'}'
 if isinstance(v,str):return json.dumps(v)
 return str(v)
(ROOT/'src/server/World/StoryPropGeometry.luau').write_text('-- Generated by tools/author-story-props.py; edit its source, not this table.\nreturn '+lua(models)+'\n')
print(json.dumps({k:len(v['parts']) for k,v in models.items()},indent=2))
