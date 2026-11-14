"""Blender MCP 직접 조형: 별도 장면·지역별 원본·정확한 Roblox 기하를 보존한다."""
import bpy,math,json,random
from mathutils import Vector,Matrix
previous_scene=bpy.context.scene
scene=bpy.data.scenes.get('TLT_Regional_Story_Architecture_20261113')
if scene is None:
 scene=bpy.data.scenes.new('TLT_Regional_Story_Architecture_20261113')
 scene['AuthoringTask']='TLT-062/063/064/065/regional-concept-map'
 scene['PreservedPreviousScene']=previous_scene.name
bpy.context.window.scene=scene
scene.view_settings.view_transform='Standard';scene.view_settings.look='None'
scene.view_settings.exposure=0;scene.view_settings.gamma=1;scene.view_settings.use_curve_mapping=False
scene.display_settings.display_device='sRGB'
try:scene.render.engine='BLENDER_EEVEE'
except TypeError:scene.render.engine='CYCLES';scene.cycles.samples=24
scene.render.resolution_x=1600;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
models=json.loads(scene.get('RegionalKitJSON','{}'));materials={};state={};P={}
S=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
PALETTES={
'GW':dict(stone=(75,88,105),light=(136,150,163),wood=(55,53,58),dark=(30,39,53),trim=(116,106,139),accent=(145,82,196),warm=(235,177,92),cloth=(179,173,157),roof=(44,58,77),soft=(186,202,218)),
'FV':dict(stone=(133,161,182),light=(221,235,239),wood=(108,80,62),dark=(57,79,105),trim=(113,153,186),accent=(115,203,233),warm=(242,177,92),cloth=(56,89,137),roof=(207,226,235),soft=(174,214,233)),
'EC':dict(stone=(71,67,67),light=(146,123,100),wood=(104,72,46),dark=(48,49,53),trim=(183,132,69),accent=(80,181,197),warm=(232,128,55),cloth=(131,64,40),roof=(126,87,59),soft=(126,148,145)),
'HG':dict(stone=(96,106,125),light=(158,165,176),wood=(71,66,75),dark=(44,49,68),trim=(133,118,151),accent=(136,126,202),warm=(230,172,91),cloth=(78,86,123),roof=(65,72,96),soft=(163,177,198))}
def linear(n):
 v=n/255
 return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
def material(color,kind):
 key=(color,kind)
 if key not in materials:
  m=bpy.data.materials.new('REG_'+kind+'_'+str(color));m.use_nodes=True
  shader=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
  rgba=tuple(linear(n)for n in color)+(1,)
  shader.inputs['Base Color'].default_value=rgba;shader.inputs['Roughness'].default_value=.78
  m.diffuse_color=rgba;materials[key]=m
 return materials[key]
def begin(name,index):
 state['name']=name;state['offset']=Vector(((index%5)*65,-(index//5)*75,0))
 collection=bpy.data.collections.new('REG_'+name);scene.collection.children.link(collection)
 state['collection']=collection;models[name]=[]
def part(name,pos,size,key='wood',kind='Wood',shape='Block',rotation=(0,0,0),soft=False,matrix=None):
 color=P[key]if isinstance(key,str)else key
 if shape=='Wedge':
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(-.5,.5,.5),(.5,.5,.5)]
  faces=[(0,1,3,2),(2,3,5,4),(0,2,4),(1,5,3),(0,4,5,1)]
 elif shape=='Cylinder':
  verts=[]
  for x in [-.5,.5]:
   for i in range(24):verts.append((x,math.cos(i*math.tau/24)*.5,math.sin(i*math.tau/24)*.5))
  faces=[tuple(reversed(range(24))),tuple(range(24,48))]+[(i,(i+1)%24,(i+1)%24+24,i+24)for i in range(24)]
 elif shape=='Ball':
  verts=[]
  for j in range(7):
   a=math.pi*j/6
   for i in range(12):verts.append((math.sin(a)*math.cos(i*math.tau/12)*.5,math.cos(a)*.5,math.sin(a)*math.sin(i*math.tau/12)*.5))
  faces=[(j*12+i,j*12+(i+1)%12,(j+1)*12+(i+1)%12,(j+1)*12+i)for j in range(6)for i in range(12)]
 else:
  verts=[(-.5,-.5,-.5),(.5,-.5,-.5),(.5,.5,-.5),(-.5,.5,-.5),(-.5,-.5,.5),(.5,-.5,.5),(.5,.5,.5),(-.5,.5,.5)]
  faces=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5)]
 mesh=bpy.data.meshes.new('REG_'+name);mesh.from_pydata([S@Vector(v)for v in verts],[],faces);mesh.update()
 o=bpy.data.objects.new(state['name']+'_'+name,mesh);state['collection'].objects.link(o)
 rx,ry,rz=rotation
 R=matrix if matrix is not None else Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z')
 o.matrix_world=Matrix.Translation(state['offset']+S@Vector(pos))@(S@R@S.inverted()).to_4x4()
 o.scale=(size[0],size[2],size[1]);o.data.materials.append(material(color,kind))
 row={'name':name,'shape':shape,'material':kind,'size':list(size),'color':list(color),
      'cf':list(pos)+[R[i][j]for i in range(3)for j in range(3)],'solid':not soft}
 o['RegionalPart']=json.dumps(row);models[state['name']].append(row)
 return o
def beam(name,a,b,width,key='wood',soft=False):
 a,b=Vector(a),Vector(b);z=(b-a).normalized();up=Vector((0,1,0))
 if abs(z.dot(up))>.99:up=Vector((1,0,0))
 x=up.cross(z).normalized();y=z.cross(x).normalized();R=Matrix((x,y,z)).transposed()
 return part(name,(a+b)/2,(width,width,(b-a).length),key,soft=soft,matrix=R)
def block(name,x,y,z,w,h,d,key='stone',mat='Slate',soft=False,yaw=0):
 return part(name,(x,y,z),(w,h,d),key,mat,rotation=(0,yaw,0),soft=soft)
def column(x,z,h=14,y=0):
 block('PierFoot',x,y+1,z,5,2,5,'light')
 block('PierShaft',x,y+h/2+2,z,3.5,h,3.5)
 block('PierCapital',x,y+h+2,z,5.1,1.2,5.1,'light')
def arch(x,z,width=14,height=16,y=0):
 spring=height-width/2
 for side in [-1,1]:
  block('ArchPier',x+side*(width/2+1.1),y+spring/2,z,2.4,spring,4)
 for i in range(11):
  a=(i+.5)*math.pi/11
  part('ArchVoussoir',(x+math.cos(a)*(width/2+1),y+spring+math.sin(a)*(width/2+1),z),(2.8,3.6,4.2),'light','Slate',rotation=(0,0,a-math.pi/2))
def wall(x,z,w=18,h=9,broken=False):
 n=math.ceil(w/5);rows=math.ceil(h/3)
 for row in range(rows):
  for i in range(n):
   if broken and row==rows-1 and i%3==1:continue
   block('CoursedMasonry',x+(i+.5)*w/n-w/2,(row+.5)*h/rows,z,w/n-.1,h/rows-.1,2.5,'light'if row==rows-1 else 'stone')
def roof(x,z,w=24,d=18,y=14,pitch=.42,snow=False):
 length=(d/2)/math.cos(pitch)
 for side in [-1,1]:
  for i in range(6):
   part('SnowRoofCourse'if snow else'RoofCourse',(x+(i-2.5)*w/6,y+math.sin(pitch)*length/2,z+side*d/4),(w/6-.12,.65,length+.6),'roof','Slate'if snow else'Metal',rotation=(side*pitch,0,0))
 beam('RoofRidge',(x-w/2,y+math.sin(pitch)*length,z),(x+w/2,y+math.sin(pitch)*length,z),.7,'trim')
def shelter(x=0,z=0,w=22,d=16,y=12,snow=False):
 for side in [-1,1]:
  column(x+side*(w/2-2),z-d/2+2,y-3)
  block('LodgeSide',x+side*(w/2-1),y/2,z,2,y,d)
 block('LodgeRear',x,y/2,z-d/2,w,y,2)
 roof(x,z,w+3,d+3,y,snow=snow)
 for side in [-1,1]:
  block('WindowRecess',x+side*6,y*.6,z+d/2-.2,3.2,4,.3,'dark')
  block('WindowWarm',x+side*6,y*.6,z+d/2,2.4,3,.12,'warm','Neon',True)
 arch(x,z+d/2,width=6,height=9)
def lantern(x,z,h=7):
 block('LanternPost',x,h/2,z,.55,h,.55,'dark','Wood')
 block('LanternHousing',x,h,z,1.9,2,1.9,'trim','Metal')
 block('LanternPane',x,h,z,2,1.1,2,'warm','Neon',True)
 block('LanternCap',x,h+1.3,z,2.6,.5,2.6,'roof','Metal')
def roots(x,z,height=19):
 for side in [-1,1]:
  pts=[(x+side*12,0,z+8),(x+side*10,height*.4,z+3),(x+side*5,height*.85,z-1),(x,height,z-3)]
  for i in range(len(pts)-1):beam('TwistedRoot',pts[i],pts[i+1],3.4-i*.6,'wood')
def silk(x,z,w=24,h=20):
 corners=[(x-w/2,h,z),(x+w/2,h+2,z),(x,h*.45,z+5)]
 for a,b in [(0,1),(1,2),(2,0)]:beam('SilkAnchor',corners[a],corners[b],.13,'soft',True)
 for i in range(1,6):
  t=i/6
  beam('SilkRadial',(x-w/2+w*t,h+2*t,z),(x,h*.45,z+5),.09,'soft',True)
 for i in range(1,4):
  t=i/4;beam('SilkCross',(x-w/2*(1-t),h*(1-t)+h*.45*t,z+5*t),(x+w/2*(1-t),(h+2)*(1-t)+h*.45*t,z+5*t),.08,'soft',True)
def wheel(x,y,z,r=3):
 part('GearHub',(x,y,z),(1.4,r*1.55,r*1.55),'trim','Metal','Cylinder',rotation=(0,math.pi/2,0))
 for i in range(10):
  a=i*math.tau/10
  part('GearTooth',(x+math.cos(a)*r,y+math.sin(a)*r,z),(1.7,1.4,1.5),'trim','Metal',rotation=(0,0,a))
def pipe(a,b,width=1.4):
 a,b=Vector(a),Vector(b);axis=(b-a).normalized();up=Vector((0,1,0))
 if abs(axis.dot(up))>.99:up=Vector((0,0,1))
 z=axis.cross(up).normalized();y=z.cross(axis).normalized();R=Matrix((axis,y,z)).transposed()
 part('ServicePipe',(a+b)/2,((b-a).length,width,width),'trim','Metal','Cylinder',matrix=R)
def tower(x,z,h=24):
 for level in range(4):
  block('WatchTowerCourse',x,(level+.5)*h/4,z,8-level*.55,h/4-.14,8-level*.55)
 for i in [-1,0,1]:block('BrokenBattlement',x+i*2.5,h+1,z-3,1.6,2+(i+1)%2,2,'light')
 block('WatchSlit',x,h*.68,z+3.7,1.1,4,.15,'dark',soft=True)
def beacon(x,z):
 column(x,z,8);block('BeaconBowl',x,11,z,5,1.4,5,'trim','Metal');block('SignalLens',x,12.1,z,3,1.5,3,'accent','Neon',True)
def build(prefix):
 P.clear();P.update(PALETTES[prefix])
 rows=json.loads("[\n  {\n    \"id\": \"GW-01\",\n    \"zone\": \"GW-01\",\n    \"epic\": 2,\n    \"title\": \"Lantern Trail\",\n    \"brief\": \"Help Maeve separate the Crownheart cargo trail from the missing scouts' rescue marks.\",\n    \"outcome\": \"The cargo wheels continue north, but the scout marks turn into the webs. Finn is waiting near the trapped Tali.\",\n    \"goals\": \"Meet Maeve at the forest entrance; Clear the lantern trail; Separate the convoy trail from the scouts trail; Read the missing scout trail marks; Secure the lantern fork; Reconnect the broken lantern trail; Light the trail lantern\",\n    \"kind\": \"SilkWatchApproach\",\n    \"scene\": \"The lower approach to a root-invaded ruined woodland watchfort. A small amber canvas scout shelter at one side, a broken cargo cart suspended high in thick silver silk, large dark stone gate remnants and a pale moonlit forked trail separate cargo wheels from scout rescue marks. No village houses.\"\n  },\n  {\n    \"id\": \"GW-02\",\n    \"zone\": \"GW-02\",\n    \"epic\": 2,\n    \"title\": \"A Light in the Webs\",\n    \"brief\": \"Help Finn hold a light for Tali, cut her bindings, and prepare her safe return.\",\n    \"outcome\": \"Tali is free and confirms the cargo passed ahead of the scouts. Escort her to Maeve at Lantern Refuge.\",\n    \"goals\": \"Speak with Finn; Drive the spiders away from Tali; Find a safe approach to Tali; Cut the web bindings; Clear the scouts return path; Help Tali prepare to leave the webs; Meet Tali beside the cleared path\",\n    \"kind\": \"WebRescueCourt\",\n    \"scene\": \"A roofless broken-stone watch court engulfed by massive blue-black roots. Thick silver-white silk bridges the high trunks and fractured stone piers, with sealed intact rescue cocoons and a hanging broken cart above the clearing. Tiny Finn holds a warm lantern near the trapped Tali; open ground escape lanes remain readable. No wooden lodge.\"\n  },\n  {\n    \"id\": \"GW-03\",\n    \"zone\": \"GW-03\",\n    \"epic\": 2,\n    \"title\": \"Lantern Refuge\",\n    \"brief\": \"Bring Tali to the refuge and use her map to plan a way in and a safe way out for the remaining scouts.\",\n    \"outcome\": \"Maeve will hold the refuge. The Wispkeeper points to the rootway, the hunting ground, and the old road beyond.\",\n    \"goals\": \"Guide Tali to Lantern Refuge; Turn the rescued scouts clues into a rescue plan; Report the rescue to Maeve; See the old northern road from the refuge; Ask the Wispkeeper for the northern route\",\n    \"kind\": \"LanternRootRefuge\",\n    \"scene\": \"A small protected warm amber canvas refuge nested below immense tangled roots beside a broken watchfort wall. Scout map awning, recovered baggage and a modest stone lookout toward the dark northern forest; the safe pocket is small against overwhelming moonlit canopy and white silk. No treehouse village, timber longhouse or sunny meadow.\"\n  },\n  {\n    \"id\": \"GW-04\",\n    \"zone\": \"GW-04\",\n    \"epic\": 2,\n    \"title\": \"The Ancient Rootway\",\n    \"brief\": \"Defeat Ancient Hollowbark and reconnect the inner rootway to the refuge.\",\n    \"outcome\": \"The rootway is open. Its ropes and lanterns give the missing scouts a return route through the forest.\",\n    \"goals\": \"Clear the rootway hunters; Find why the ancient roots block the rescue route; Defeat Ancient Hollowbark; Restore the inner rescue trail; Secure the far side of the rootway; Relight the scout lantern\",\n    \"kind\": \"HollowbarkRootBastion\",\n    \"scene\": \"An ancient root bastion where huge twisted blue-black tree roots pierce ruined angular watchfort masonry. A broad pale stone-and-root combat floor, silver silk high overhead and a looped amber rescue lantern route. Ancient Hollowbark is one distant rooted guardian silhouette, not a row of ordinary trees. No village huts.\"\n  },\n  {\n    \"id\": \"GW-05\",\n    \"zone\": \"GW-05\",\n    \"epic\": 2,\n    \"title\": \"Venomcoil Crossing\",\n    \"brief\": \"Defeat Venomcoil King and mark a crossing that keeps the scouts out of the hunting ground.\",\n    \"outcome\": \"The crossing is secure. The last scout signals come from the edge of the queen's territory.\",\n    \"goals\": \"Clear the centipede crossing; Read the hunting ground before crossing it; Defeat Venomcoil King; Build a walking route around the hunting ground; Protect the crossing rope; Secure the scout crossing rope\",\n    \"kind\": \"SilkenBankAnchors\",\n    \"scene\": \"An eroded watchfort bank crossed by giant dark roots, broken grey stone rope-anchor piers, a short timber walking span and a broad exposed centipede hunting ground. White silk blankets the high canopy and side burrows while pale moonlight reveals the clear crossing and a lantern-marked bypass. No sunny riverside settlement.\"\n  },\n  {\n    \"id\": \"GW-06\",\n    \"zone\": \"GW-06\",\n    \"epic\": 2,\n    \"title\": \"One Brave Step\",\n    \"brief\": \"Free the last scouts, follow Finn's light, and hold off Hollowbark Sovereign while the group reaches safety.\",\n    \"outcome\": \"The scouts reach the refuge route while you hold the rearguard. Finn keeps the group together; the northern exit still lies beyond the queen.\",\n    \"goals\": \"Clear the nest approach; Cut the last scout web bindings; Bring the final scout out of the queens reach; Encourage Finn; Clear Finn's escape route; Follow Finn as he guides the scouts home; Defeat Hollowbark Sovereign and protect the scouts\",\n    \"kind\": \"ScoutExtractionWall\",\n    \"scene\": \"A shattered watchfort extraction wall and narrow side arch, immense roots, hanging intact silk cocoons, fallen siege timber and broken battlements. A tiny amber rescue awning marks the safe exit while Finn leads the scouts along the unobstructed moonlit perimeter path around a broad rearguard clearing. No new houses.\"\n  },\n  {\n    \"id\": \"GW-07\",\n    \"zone\": \"GW-07\",\n    \"epic\": 2,\n    \"title\": \"The Queen of the Webs\",\n    \"brief\": \"Defeat the Widow Queen, open the webbed northern exit, and check Tali's cargo marker.\",\n    \"outcome\": \"The scouts are safe and the northern road is open. Tali confirms the Crownheart cargo went toward Frozen Vale.\",\n    \"goals\": \"Clear the queen nest; Find the northern exit before entering the nest; Defeat the Widow Queen; Drive the hunters from the northern ridge; Cut the web sealing the northern exit; Meet the rescued scouts on the open northern road; Ask Tali where the convoy went\",\n    \"kind\": \"WidowWatchfortGate\",\n    \"scene\": \"The existing Gloamwood queen-lair identity transformed into a complete high aerial layout: a collapsed root-invaded watchfort with two irregular ruined towers, a huge broken arched entrance, dense silver silk between black-blue trunks and stone walls, sealed cocoons and a broad pale stone boss floor. A distant black-purple eight-legged queen silhouette is inside the far arch. The cleared northern walking exit leads toward snowy pines. No village lodges or new travel portal.\"\n  },\n  {\n    \"id\": \"FV-01\",\n    \"zone\": \"FV-01\",\n    \"epic\": 3,\n    \"title\": \"Blizzard Gate\",\n    \"brief\": \"Follow Tali's lead into the valley. Help Freya rescue the stormbound travelers and relight the refuge trail.\",\n    \"outcome\": \"The travelers can reach Ember Refuge. Their relief supplies and broken village links need attention.\",\n    \"goals\": \"Meet Freya at the snow trail; Drive the wolves away from the travelers; Find the travelers below the wind ridge; Help the stranded travelers; Clear the lantern crossing; Bring a stranded traveler to the refuge route; Relight the shelter lanterns\",\n    \"kind\": \"StormRescueHut\",\n    \"scene\": \"A stout windbreak rescue hut with steep snow roof and warm amber windows, paired stone lantern posts in a snowbound mountain pass. A sheltered lower hollow for stranded travelers, wolf encounter clearing and broad trail through the blizzard toward the refuge.\"\n  },\n  {\n    \"id\": \"FV-02\",\n    \"zone\": \"FV-02\",\n    \"epic\": 3,\n    \"title\": \"Ember Refuge\",\n    \"brief\": \"Deliver relief supplies and help Haldor, Nessa, and Freya plan a crossing between the two village beacons.\",\n    \"outcome\": \"The refuge has medicine and a rescue plan. Restore the ravine crossing so the beacon teams can reach both sides.\",\n    \"goals\": \"Meet Haldor at the warm refuge; Help Nessa sort the recovered relief supplies; Deliver medicine to the shelter; Find the break between the two village beacons; Plan the ravine crossing with Freya\",\n    \"kind\": \"HearthLonghouse\",\n    \"scene\": \"A warm alpine stone-and-timber refuge longhouse, steep snow roofs, brick chimney, medicine awning, relief stores and an arrivals board with no legible writing. Open warm-lit courtyard where tiny travelers and Haldor gather; a lookout shows two distant village beacons.\"\n  },\n  {\n    \"id\": \"FV-03\",\n    \"zone\": \"FV-03\",\n    \"epic\": 3,\n    \"title\": \"Wolf Ravine\",\n    \"brief\": \"Rescue the ravine keeper, restore the crossing, and relight both village beacons.\",\n    \"outcome\": \"The ravine crossing is safe, but the fortress alarm still drives the storm. Follow the signal line into the archive.\",\n    \"goals\": \"Secure the ravine entrance; Guide a caravan keeper out of the lower ravine; Relight the western beacon; Make room for the trapped caravan; Restore the link across the ravine; Relight the eastern beacon\",\n    \"kind\": \"TwinBeaconBridgehead\",\n    \"scene\": \"Two low square beacon bridgeheads on opposing snow banks of a shallow ravine, a repaired wide timber-and-stone crossing and a lower sheltered caravan rescue ramp. Broad wolf encounter approach; both beacon bowls signal across the valley.\"\n  },\n  {\n    \"id\": \"FV-04\",\n    \"zone\": \"FV-04\",\n    \"epic\": 3,\n    \"title\": \"Subglacial Archive\",\n    \"brief\": \"Compare the false warning with the guardian's behavior. Help Ylva restore the archive's shelter signal.\",\n    \"outcome\": \"The archive signal protects the refuge road again. The palace still repeats the false alarm; follow the cargo markers toward its fortress.\",\n    \"goals\": \"Clear the frozen relay hall; Compare the false alarm with the old signal record; Repair the western relay; Stop the alarm at the archive; Repair the eastern relay; Restore the archive signal in its original order; Ask Ylva how to help the guardians\",\n    \"kind\": \"SubglacialRelayHall\",\n    \"scene\": \"A partly exposed ice-bound archive relay hall with buttressed stone walls and a cutaway open roof, blue signal lenses and two relay alcoves. Icy record shelves and a modest signal console, wide readable hall floor, a sheltered walking loop to the refuge road.\"\n  },\n  {\n    \"id\": \"FV-05\",\n    \"zone\": \"FV-05\",\n    \"epic\": 3,\n    \"title\": \"Silent Battlefield\",\n    \"brief\": \"Identify the Crownheart sled marks and reopen the sheltered tunnel so Ivo can confirm their route.\",\n    \"outcome\": \"Ivo recognizes the cargo sleds. The tunnel gives travelers a way home while you approach the citadel locks.\",\n    \"goals\": \"Clear the snowbound crossing; Connect the buried convoy to the citadel road; Recover the first caravan marker; Clear the fortress approach; Reopen the travelers sheltered return route; Show the route marks to Ivo\",\n    \"kind\": \"BuriedSledDepot\",\n    \"scene\": \"A snow-buried caravan sled depot beside a broken low stone barricade, leaning cargo sleds and freight marker stones, a supported tunnel mouth and an open snowbound battlefield clearing. Cargo traces lead toward a distant frozen citadel; no recovered heart.\"\n  },\n  {\n    \"id\": \"FV-06\",\n    \"zone\": \"FV-06\",\n    \"epic\": 3,\n    \"title\": \"Frost Citadel Gate\",\n    \"brief\": \"Open both ice locks, carry the restored signal to King Ice Golem, and calm its remaining storm magic.\",\n    \"outcome\": \"King Ice Golem is resting. The palace road is open, but its final signal mirror still feeds the valley alarm.\",\n    \"goals\": \"Secure the citadel courtyard; Find both courts that protect the citadel entrance; Release the western ice lock; Release the eastern ice lock; Carry the restored rest signal to the guardian; Calm King Ice Golem; Reach the palace road\",\n    \"kind\": \"TwinLockGatehouse\",\n    \"scene\": \"An imposing but human-scale ice citadel gatehouse with two distinct ice-lock courts, squat blue-white buttresses and a central open walking arch. A broad guardian-rest courtyard for King Ice Golem and a continuous palace approach; the guardian is calmed, not slain.\"\n  },\n  {\n    \"id\": \"FV-07\",\n    \"zone\": \"FV-07\",\n    \"epic\": 3,\n    \"title\": \"Ice Mirror Palace\",\n    \"brief\": \"Restore the palace mirrors, calm Queen Ice Elf, and end the false alarm across the valley.\",\n    \"outcome\": \"The storm eases and the villages reunite. Ivo's records lead to Ember Caldera, where the Crownheart was sent to be fitted into a portal-key frame.\",\n    \"goals\": \"Clear the mirror hall; Find where the palace alarm is being repeated; Restore the first signal mirror; Restore the second signal mirror; Calm Queen Ice Elf; Restore the final signal mirror; See the reopened villages from the palace terrace; Bring the good news to Ivo\",\n    \"kind\": \"MirrorPavilion\",\n    \"scene\": \"An elegant pale-stone mirror palace pavilion with a shallow faceted icy dome, three signal mirror pedestals and a broad peaceful terrace overlooking reconnected villages. A clear nonlethal queen encounter court, tiny Ivo at records and a walkable onward mountain road toward the caldera.\"\n  },\n  {\n    \"id\": \"FV-Q1\",\n    \"zone\": \"FV-01\",\n    \"epic\": 3,\n    \"title\": \"A Name in the Snow\",\n    \"brief\": \"Return the lost badge and luggage so Nessa can reunite Nell with their waiting friends.\",\n    \"outcome\": \"Nessa returns Nell's belongings. The arrivals board and the badge help the traveler find their waiting friends.\",\n    \"goals\": \"Find the name tag in the snow; Recover the traveler's luggage; Find who should receive the recovered badge; Return the luggage to Nessa\",\n    \"kind\": \"StormRescueHut\",\n    \"scene\": \"A small story pocket within the Blizzard Gate rescue area: a lost travel badge and luggage beside a sheltered snow trail, an arrivals-board canopy and the warm refuge return road in the distance. No new dungeon or separate giant city.\"\n  },\n  {\n    \"id\": \"FV-Q2\",\n    \"zone\": \"FV-S1\",\n    \"epic\": 3,\n    \"title\": \"Frostfang Supply Cave\",\n    \"brief\": \"Recover the stores from Frostfang Cave and calm the guardian blocking the hauling route.\",\n    \"outcome\": \"Freya can bring the recovered cave supplies to the refuge along a safe hauling route.\",\n    \"goals\": \"Inspect the abandoned supplies; Calm the guardian; Reopen the cave supply return route; Secure the supplies and report to Freya\",\n    \"kind\": \"CaveSupplyStore\",\n    \"scene\": \"A low cave supply store built into blue ice rock, timber bracing, a sledge hauling platform, covered medicine chests and a broad cave-mouth guardian clearing. A safe hauling path loops back to the refuge.\"\n  },\n  {\n    \"id\": \"FV-Q3\",\n    \"zone\": \"FV-S2\",\n    \"epic\": 3,\n    \"title\": \"Blue Lake Return Route\",\n    \"brief\": \"Check the abandoned lake-side stores and calm the guardian so Haldor can reopen the sheltered shore route.\",\n    \"outcome\": \"The shore markers connect Blue Lake to the refuge. Haldor has another safe return route for travelers.\",\n    \"goals\": \"Inspect the sheltered shore handrail; Calm the guardian; Connect the lake route to the refuge trail; Secure the supplies and report to Haldor\",\n    \"kind\": \"ShoreReturnJetty\",\n    \"scene\": \"A sheltered blue frozen lake shore with a low stone handrail, short timber stores jetty, supply shelter and a warm lantern chain marking a walking return route along the bank; broad guardian clearing stays on land.\"\n  },\n  {\n    \"id\": \"FV-Q4\",\n    \"zone\": \"FV-S3\",\n    \"epic\": 3,\n    \"title\": \"Ancient Glacier Watch\",\n    \"brief\": \"After the valley storm ends, calm the glacier watch guardian and inspect its old signal route for Ylva.\",\n    \"outcome\": \"Ylva has the peaceful watch record. The old glacier signal can guide travelers without restarting the false alarm.\",\n    \"goals\": \"Inspect the watch relay plate; Calm the guardian; Understand the old watch signal after calming the guardian; Secure the supplies and report to Ylva\",\n    \"kind\": \"GlacierWatchSpire\",\n    \"scene\": \"An ancient short glacier watch spire with a sloped icy cap, a ring of quiet signal stones and a small archive alcove on a broad accessible snowy shelf. The valley storm has ended; the guardian is calm and the old signal route is peaceful.\"\n  },\n  {\n    \"id\": \"EC-01\",\n    \"zone\": \"EC-01\",\n    \"epic\": 4,\n    \"title\": \"Ash Gate\",\n    \"brief\": \"Recover the freight-lift gear and help the stranded workers reach Forge City.\",\n    \"outcome\": \"The freight lift is working and the city road is open. Brann needs help bringing the trapped mine crew home.\",\n    \"goals\": \"Clear the ash-covered approach; Find why the city freight lift has stopped; Help the workers behind the broken cart; Recover the lift gear; Prepare the freight lift for the rescued workers; Repair the freight lift\",\n    \"kind\": \"FreightLiftHead\",\n    \"scene\": \"A basalt freight-lift headframe with twin timber-and-iron supports, an exposed gear housing, suspended empty cargo platform and broken worker cart. Broad ash-covered rescue apron, protected service ramp and a clear city road. Lava remains off the walking route.\"\n  },\n  {\n    \"id\": \"EC-02\",\n    \"zone\": \"EC-02\",\n    \"epic\": 4,\n    \"title\": \"Forge City\",\n    \"brief\": \"Meet Brann and Ketta. Find the missing crew and prepare the tools needed to repair the city together.\",\n    \"outcome\": \"Orik knows the mine, Dagna knows the cooling flow, and Brann knows the protection relay. Rescue Orik and the miners first.\",\n    \"goals\": \"Meet Brann at the workshop; Find the people who can help Brann repair the city; Collect spare tools from Ketta; See how the mine and cooling channels connect; Find the marked mine entrance\",\n    \"kind\": \"CrewWorkshop\",\n    \"scene\": \"A welcoming dwarven crew workshop with sawtooth metal roofs, stout stone chimneys, separate repair benches, tool racks and workers rest awnings. Broad open city repair court, visible mine road and cooling pipe route establish how the crew works together.\"\n  },\n  {\n    \"id\": \"EC-03\",\n    \"zone\": \"EC-03\",\n    \"epic\": 4,\n    \"title\": \"Collapsed Resonance Mine\",\n    \"brief\": \"Brace the mine, stop the magma worm, and guide Orik and the miners to the safe exit.\",\n    \"outcome\": \"The miners can return to the city. Orik's map shows Dagna where the cooling channels have failed.\",\n    \"goals\": \"Clear the mine entrance; Brace the cracked mine supports; Stop the magma worm at the rescue tunnel; Prepare the miners safe evacuation route; Bring the missing miners out of the tunnel; Recover the crews map of the cooling channels; Find the cooling-channel map\",\n    \"kind\": \"BracedMineHead\",\n    \"scene\": \"A rugged collapsed resonance-mine head with diagonal timber bracing, separated rescue tunnel opening, an ore cart bay and rope hauling drum. Broad magma-worm encounter apron, intact safe miner evacuation lane and a salvaged channel map shelter.\"\n  },\n  {\n    \"id\": \"EC-04\",\n    \"zone\": \"EC-04\",\n    \"epic\": 4,\n    \"title\": \"Split Coolant Canals\",\n    \"brief\": \"Help Dagna restore the supply and return channels, then recover the complete safety-circuit plan.\",\n    \"outcome\": \"Coolant circulates again. The ancestral design vault holds the protection circuit needed for a safe restart.\",\n    \"goals\": \"Meet Dagna by the cooling channel; Clear the broken pumping station; Follow the cooling pipe to the first blockage; Open the western coolant valve; Secure the eastern valve; Open the eastern coolant valve; Connect the restored channels to the workshop circuit; Recover the repair-crew plans\",\n    \"kind\": \"TwinPumpHouse\",\n    \"scene\": \"A twin coolant pumping station built from dark basalt and brass, two large side pipes, two valve wheels, separate supply and return stone channels and short grate bridges. Cool blue coolant accents contrast with distant orange lava; protected wide dry walking lanes stay clear.\"\n  },\n  {\n    \"id\": \"EC-05\",\n    \"zone\": \"EC-05\",\n    \"epic\": 4,\n    \"title\": \"Ancestral Design Vault\",\n    \"brief\": \"Combine Dagna's inlet, Orik's return, and Brann's protection clues. Test their complete loop on the model.\",\n    \"outcome\": \"The model works because the whole crew helped. Take the repair kit to the testworks before restarting the great furnace.\",\n    \"goals\": \"Clear the workshop vault; Recover the safe heat-circuit blueprint; Understand the old furnace safety design; Bring the plans to the repair table; Secure the design vault departure; Test the safety route on the workshop model; Prepare the testworks repair kit\",\n    \"kind\": \"CircuitArchive\",\n    \"scene\": \"A low ancestral design vault with a stepped basalt roof, deep bronze-framed entry, blueprint archive alcoves and an open workshop model of a complete supply-return-protection loop. Three distinct component stations frame a broad readable courtyard.\"\n  },\n  {\n    \"id\": \"EC-06\",\n    \"zone\": \"EC-06\",\n    \"epic\": 4,\n    \"title\": \"Geothermal Heart Testworks\",\n    \"brief\": \"Clear Magma Golem from the testworks and check that the repaired cooling circuit protects the city.\",\n    \"outcome\": \"The protected test succeeds. The crew can help you reclaim and restart the great furnace safely.\",\n    \"goals\": \"Secure the testworks entrance; Connect the coolant intake; Find the protected route through the testworks; Defeat Magma Golem; Verify the repaired circuit before the full test; Run the protected heat-circuit test\",\n    \"kind\": \"HeatTestFrame\",\n    \"scene\": \"A geothermal testworks frame with low iron cooling fins, a shielded central heat-test chamber, intake and return pipe loops and a protected observation balcony. Broad Magma Golem arena, clear service lane, safe heat-test apparatus; do not put lava across the playable path.\"\n  },\n  {\n    \"id\": \"EC-07\",\n    \"zone\": \"EC-07\",\n    \"epic\": 4,\n    \"title\": \"Great Furnace\",\n    \"brief\": \"Use the repaired coolers, defeat Inferno Overlord, and reclaim the furnace. Check where the Crownheart cargo was sent.\",\n    \"outcome\": \"The city is safe. The Crownheart left before your arrival, but Veyr's dispatch reveals the royal tomb. Brann's route and Maeve's scouts open the approach to Haunted Graveyard.\",\n    \"goals\": \"Clear the furnace approach; Reach the furnace through the protected service route; Connect the western emergency cooler; Connect the eastern emergency cooler; Defeat Inferno Overlord; Restart the protected city furnace; Uncover the destination of the finished portal key; Meet Suri with the enemy delivery orders\",\n    \"kind\": \"GreatFurnaceCrown\",\n    \"scene\": \"A great city furnace with a massive low round basalt hearth, tapered copper exhaust crown, twin emergency cooler towers and a broad protected furnace arena. Empty outbound cargo cradle and dispatch shelter reveal the heart has already left. A walkable ash road leads toward misty graveyard hills.\"\n  },\n  {\n    \"id\": \"EC-Q1\",\n    \"zone\": \"EC-01\",\n    \"epic\": 4,\n    \"title\": \"A Worker's Lost Mark\",\n    \"brief\": \"Return the lost work mark and safety record so Ketta can welcome Jori back to the crew.\",\n    \"outcome\": \"Ketta returns Jori's work mark. The rescued worker has their place on the crew board again.\",\n    \"goals\": \"Find the lost worker tool tag; Recover the mine safety record; Find the crew behind the lost workers mark; Return the record to Ketta\",\n    \"kind\": \"FreightLiftHead\",\n    \"scene\": \"A small lost-worker story pocket at the Ash Gate freight landing: a dropped tool tag, safety ledger shelter and a crew noticeboard without legible text. Warm workshop return road, grounded cargo tools, no new combat dungeon.\"\n  },\n  {\n    \"id\": \"EC-Q2\",\n    \"zone\": \"EC-S1\",\n    \"epic\": 4,\n    \"title\": \"Ember Raider Nest\",\n    \"brief\": \"Recover the stolen freight from the raider nest and secure Ketta's collection route.\",\n    \"outcome\": \"Ketta can collect the stolen freight. The repair crew has its materials and a safe road back.\",\n    \"goals\": \"Inspect the abandoned crew supplies; Defeat the enemy blocking the repair crew; Secure the repair route; Prepare the stolen freight for the city crew; Report to Ketta in Forge City\",\n    \"kind\": \"RaiderFreightShed\",\n    \"scene\": \"A rough basalt raider freight shed, stolen crew cargo stacks, broken handcart and a recoverable collection landing. Wide combat clearing with clear hauling return road to the city; no burning loot clutter across the road.\"\n  },\n  {\n    \"id\": \"EC-Q3\",\n    \"zone\": \"EC-S2\",\n    \"epic\": 4,\n    \"title\": \"Volcano Shaman Altar\",\n    \"brief\": \"Stop the shaman blocking the heat-altar service path and recover the crew stores left there.\",\n    \"outcome\": \"The heat-altar path is clear. Ketta's crews can reach the recovered stores without entering the old ritual ground.\",\n    \"goals\": \"Inspect the abandoned service tools; Defeat the enemy blocking the repair crew; Secure the repair route; Trace the safe path around the abandoned heat altar; Report to Ketta in Forge City\",\n    \"kind\": \"HeatAltarService\",\n    \"scene\": \"An abandoned circular heat altar with low carved basalt fins, old shaman ritual stones and a protected service-tool canopy outside the circle. Broad shaman clearing, distinct safe walking path around the ritual ground and recovered crew stores.\"\n  },\n  {\n    \"id\": \"EC-Q4\",\n    \"zone\": \"EC-S3\",\n    \"epic\": 4,\n    \"title\": \"Caldera Titan Basin\",\n    \"brief\": \"After the furnace is safe, investigate the titan basin and secure the old ore-hauling route for Ketta.\",\n    \"outcome\": \"The titan basin's hauling route is recorded. The city can use its old freight landing again without delaying the royal-tomb mission.\",\n    \"goals\": \"Inspect the old ore sleds; Defeat the enemy blocking the repair crew; Secure the repair route; Recover the old hauling route beyond the titan ground; Report to Ketta in Forge City\",\n    \"kind\": \"CalderaOreDerrick\",\n    \"scene\": \"An old caldera ore-hauling derrick on a basalt basin shelf, heavy ore sleds, a stout loading crane and a safe freight landing. Titan encounter space is broad and on solid ground; the city furnace is already safe, lava is beyond the walking boundary.\"\n  },\n  {\n    \"id\": \"HG-01\",\n    \"zone\": \"HG-01\",\n    \"epic\": 5,\n    \"title\": \"Mist Gate\",\n    \"brief\": \"Follow the route secured by the rescued scouts and meet Rook at the graveyard entrance.\",\n    \"outcome\": \"The scouts' lanterns connect Brann's approach to the keeper shelter. Gather with the allies preparing the assault.\",\n    \"goals\": \"Meet Rook at the hidden entrance; Clear the mist gate; Follow the approach secured by the rescued scouts; Secure the keeper lantern path; Reconnect the shelter lantern line; Clear the last approach to the shelter; Reach the keeper shelter\",\n    \"kind\": \"KeeperGate\",\n    \"scene\": \"A modest keeper gate with low weathered stone pillars and a broken sloped lintel, amber scout lanterns across violet mist, a graveyard entrance trail and a small gatekeepers supply lean-to. Quiet memorial stones frame a broad guardian clearing; a continuous return road points back to the caldera.\"\n  },\n  {\n    \"id\": \"HG-02\",\n    \"zone\": \"HG-02\",\n    \"epic\": 5,\n    \"title\": \"Friends at the Old Shelter\",\n    \"brief\": \"Learn the assault plan from Garrick, Eryn, Brann, and Elowen. Find out how Lumi can reach the inner gate.\",\n    \"outcome\": \"The scouts hold the approach, the elves guide the return path, and the dwarves ready the gate rig. Take Lumi's service passage to the winch.\",\n    \"goals\": \"Ask Garrick about the fortress; Meet Eryn and the elf scouts; Connect the allies preparations to the assault route; Meet Brann and the dwarf crew; See where your friends will help in the final assault; Ask Elowen how to restore the Crownheart\",\n    \"kind\": \"AlliedShelter\",\n    \"scene\": \"A repaired old cemetery keeper shelter with layered slate roof, covered ally planning veranda, distinct elven scout awning and dwarven gate-tool staging bay. Broad warm-lit alliance courtyard; a small service path and the large fortress approach are both visible.\"\n  },\n  {\n    \"id\": \"HG-03\",\n    \"zone\": \"HG-03\",\n    \"epic\": 5,\n    \"title\": \"Lumi Secret Passage\",\n    \"brief\": \"Help Lumi reopen the keeper passage so you can reach the fortress-side gate machinery.\",\n    \"outcome\": \"The small passage reaches the winch, not the whole allied route. Secure Brann's gate so the crew can bring everyone through.\",\n    \"goals\": \"Meet Lumi at the lantern arch; Clear the passage guardians; Find the route that Lumi remembers through the crypt; Open the sealed crypt route; Prepare the hidden exit for the allies; Secure the hidden passage exit; Open Lumi hidden passage\",\n    \"kind\": \"KeeperCryptStair\",\n    \"scene\": \"A low weathered keeper crypt stair house with a curved slate roof, shallow accessible stone steps and a side maintenance passage lit by amber lanterns. Small Lumi leads the route to the inner winch. The passage is distinct from the broad allied gate road.\"\n  },\n  {\n    \"id\": \"HG-04\",\n    \"zone\": \"HG-04\",\n    \"epic\": 5,\n    \"title\": \"The Alliance Opens the Gate\",\n    \"brief\": \"Secure the winch, stop Dread Commander, and answer Finn's signal to bring the allies through Brann's gate.\",\n    \"outcome\": \"Brann's gate is secured. The people you rescued hold your way home while you advance to the throne devices.\",\n    \"goals\": \"Clear the fortress wall; Find what Brann needs to turn the gate winch; Operate the gate winch with Brann crew; Defeat Dread Commander; Connect the opened gate to the allies route; Protect the allies at the opened gate; Signal the allied scouts\",\n    \"kind\": \"SiegeWinchGate\",\n    \"scene\": \"A fortified inner gate with squat flanking towers, exposed geared winch house, chain drum and a wide open arch for the allies. Broad Dread Commander encounter court, warm scout signal balcony, dwarven repair rig and a continuous safe return lane.\"\n  },\n  {\n    \"id\": \"HG-05\",\n    \"zone\": \"HG-05\",\n    \"epic\": 5,\n    \"title\": \"The Black Throne Devices\",\n    \"brief\": \"Break the two outer shield links that block the route to Veyr's royal tomb.\",\n    \"outcome\": \"Both outer links are broken. The tomb approach is exposed, but Veyr still holds the Crownheart inside.\",\n    \"goals\": \"Clear the throne approach; Find the first connection protecting the black throne; Break the western throne device; Defeat the device keeper; Reach the second throne connection; Clear the eastern device approach; Break the eastern throne device\",\n    \"kind\": \"TwinShieldPylons\",\n    \"scene\": \"Two asymmetrical black-throne shield pylon shrines on opposite sides of an open court, carved dark stone fins, broken cyan-violet conduit inlays and low protective retaining walls. Clear keeper encounter clearing and a broad onward road to the royal tomb, no recovered heart yet.\"\n  },\n  {\n    \"id\": \"HG-06\",\n    \"zone\": \"HG-06\",\n    \"epic\": 5,\n    \"title\": \"The Royal Tomb\",\n    \"brief\": \"Clear the tomb guards and learn how Veyr's binding frame forces the Crownheart to power his invasion gate.\",\n    \"outcome\": \"The tomb seal is open and your retreat is secured. Defeat Veyr, release the Crownheart from his frame, then close the portal.\",\n    \"goals\": \"Clear the royal tomb guard; Learn what the Crownheart must be brought home to do; Defeat Lich Sovereign; Prepare a safe final approach to Veyr; Secure the royal tomb seal; Open the royal tomb seal\",\n    \"kind\": \"RoyalSealMausoleum\",\n    \"scene\": \"A regal royal-seal mausoleum with a stepped slate roof, tall pointed entrance arch, weathered crown relief and separate record alcove showing an empty binding-frame diagram without readable writing. Broad Lich Sovereign court and a secured retreat path lead to the final throne.\"\n  },\n  {\n    \"id\": \"HG-07\",\n    \"zone\": \"HG-07\",\n    \"epic\": 5,\n    \"title\": \"Together We Bring Back the Light\",\n    \"brief\": \"Defeat Veyr, recover the bound Crownheart, and close the invasion portal before returning to Dawnspire.\",\n    \"outcome\": \"Veyr is defeated, the Crownheart is free, and the invasion portal is closed. Return to Dawnspire to restore the throne and meet your friends.\",\n    \"goals\": \"Defeat Veyr final guard; Use the opening your friends created; Break through the last throne approach; Defeat Veyr at the black throne; Recover the Crownheart from the black throne; Secure the recovered Crownheart before closing the portal; Close the invasion portal\",\n    \"kind\": \"BindingThroneDais\",\n    \"scene\": \"The final black-throne court: a broad grounded stepped dark-stone dais with a distinct small binding cradle holding the intact luminous Crownheart, broken outer shield links, a distant invasion rift anchored to low stone piers and warm allied lanterns marking the safe return route. Final Veyr encounter arena is open. The royal crystal heart is the rescue objective, not a giant chair; do not add an extra second throne or portal anywhere else.\"\n  }\n]\n")
 rows=[r for r in rows if r['id'].startswith(prefix)and(r['id']==r['zone']or r['zone'].find('-S')>=0)]
 for index,row in enumerate(rows):
  kind=row['kind']
  if kind in models:continue
  begin(kind,index)
  state['offset']+=Vector(({'GW':0,'FV':1,'EC':2,'HG':3}[prefix]*1000,0,0))
  i=int(row['id'][-2:])if '-Q'not in row['id']else 7+int(row['id'][-1:])-1
  if prefix=='GW':
   if i==3:
    wall(0,-7,22,8,True);roots(0,-8,22)
    for x in [-9,9]:beam('CanvasPole',(x,0,6),(x,11,6),.7)
    for side in [-1,1]:part('RefugeCanvas',(side*5,12,0),(11,.18,18),'cloth','Fabric',rotation=(0,0,side*.21),soft=True)
   elif i==5:
    for side in [-1,1]:column(side*11,0,8);wheel(side*11,8,2,2)
    for j in range(9):block('BrokenCrossingPlank',0,.5,j*1.5-6,15,.6,1.35,'wood','WoodPlanks')
    for side in [-1,1]:beam('CrossingRope',(side*7,3,-7),(side*7,3,7),.16,'cloth',True)
   elif i==4:
    arch(0,0,14,17);roots(0,-1,25);wall(-12,-3,12,7,True)
   else:
    arch(0,0,16 if i==7 else 12,22 if i==7 else 17)
    tower(-13,-2,29 if i==7 else 19);wall(13,-3,12,10,True)
    if i in [2,6,7]:tower(14,-4,22 if i==7 else 14)
    roots(-4,-6,25 if i==7 else 20)
   silk(0,-3,31,28 if i==7 else 23)
   lantern(-12,9);lantern(13,8)
  elif prefix=='FV':
   if i in [1,2]:
    shelter(w=28 if i==2 else 21,d=19,y=14,snow=True)
    block('StoneChimney',-8,19,-3,4,15,4)
    for x in [-13,13]:lantern(x,12)
   elif i==3:
    for x in [-12,12]:beacon(x,-1)
    for j in range(8):block('BridgeheadCoping',0,1,j*1.7-5,16,2,1.5)
   elif i==4:
    for x in [-11,11]:column(x,-4,15)
    roof(0,-2,30,20,18,snow=True);arch(0,8,15,17)
    for x in [-8,8]:block('RelayAlcove',x,6,-7,5,10,3);block('RelayLens',x,7,-5.3,2,3,.25,'accent','Neon',True)
   elif i==5:
    wall(0,-9,27,9,True);roof(-5,-5,22,12,11,snow=True)
    for x in [-8,4]:
     for side in [-1,1]:beam('SledRunner',(x+side*3,.6,0),(x+side*3,.6,11),.8,'wood')
     block('AbandonedSled',x,1.4,5,7,1,10,'wood','WoodPlanks')
   elif i==6:
    arch(0,0,17,20)
    for side in [-1,1]:tower(side*15,-2,25);block('IceLockInlay',side*15,12,2.5,3,6,.3,'accent','Neon',True)
   elif i==7:
    for j in range(8):
     a=j*math.tau/8;column(math.cos(a)*12,math.sin(a)*12,15)
     beam('PavilionRoofRib',(math.cos(a)*14,19,math.sin(a)*14),(0,27,0),1.6,'light')
     slope=math.atan(8/14);zz=Vector((math.cos(a)*math.cos(slope),-math.sin(slope),math.sin(a)*math.cos(slope)));xx=Vector((math.sin(a),0,-math.cos(a)));yy=zz.cross(xx)
     part('FacetedMirrorRoofPanel',(math.cos(a)*7,23,math.sin(a)*7),(11,.65,16),'roof','Slate',matrix=Matrix((xx,yy,zz)).transposed())
    for x in [-8,0,8]:column(x,17,4);block('SignalMirror',x,7,17,4,.35,4,'accent','Glass',True)
   elif i==8:
    for x in [-10,10]:column(x,-2,12)
    roof(0,-3,28,18,15,snow=True)
    for x in [-8,0,8]:block('CaveSupplyChest',x,2,2,5,4,4,'wood','WoodPlanks')
   elif i==9:
    for j in range(8):block('JettyPlank',0,1,j*1.8-5,18,.65,1.6,'wood','WoodPlanks')
    for side in [-1,1]:beam('ShoreHandrail',(side*9,4,-7),(side*9,4,10),.65,'light')
    shelter(-4,-8,16,10,9,True)
   else:
    tower(0,0,28);beacon(0,0)
    for side in [-1,1]:block('GlacierButtress',side*6,7,0,4,14,9,'light')
  elif prefix=='EC':
   if i==1:
    for side in [-1,1]:
     beam('LiftLeg',(side*11,0,-5),(side*9,25,-3),2,'dark')
     beam('LiftBrace',(side*11,0,7),(side*9,25,-3),1.4,'trim')
    beam('LiftHead',(-12,25,-3),(12,25,-3),2,'dark');wheel(0,23,-2,4)
    block('FreightPlatform',0,2,4,18,1.5,15,'wood','WoodPlanks')
    for side in [-1,1]:beam('LiftCable',(side*7,3,4),(side*7,24,-3),.16,'trim',True)
   elif i==2:
    shelter(w=30,d=21,y=13);block('WorkshopStack',-9,21,-5,5,18,5,'dark','Metal')
    for x in [-8,8]:block('ToolBench',x,3,14,9,1,5,'wood','WoodPlanks');wheel(x,5,14,2)
   elif i==3:
    for side in [-1,1]:beam('MineBrace',(side*12,0,0),(side*8,17,-2),2,'wood')
    beam('MineLintel',(-12,17,-2),(12,17,-2),2.4,'wood');wall(0,-8,25,10,True)
    for x in [-6,6]:beam('OreRail',(x,.3,3),(x,.3,13),.4,'dark')
    wheel(-10,7,4,3)
   elif i==4:
    shelter(w=25,d=16,y=11)
    for side in [-1,1]:
     pipe((side*16,2,-10),(side*16,10,-10),2.6);pipe((side*16,10,-10),(side*16,10,12),2.6)
     wheel(side*16,10,7,3.5);block('DryChannelBank',side*19,1,0,2,2,28)
   elif i==5:
    arch(0,7,16,15);wall(0,-10,28,13);roof(0,-2,31,21,17,pitch=.25)
    for x in [-9,0,9]:block('CircuitModelStation',x,3,12,6,1,5,'trim','Metal');pipe((x-2,4,12),(x+2,4,12),.7)
   elif i==6:
    for x in [-12,12]:column(x,-5,18);pipe((x,3,-6),(x,16,-6),2)
    beam('TestworksHeader',(-14,21,-5),(14,21,-5),2,'dark')
    for j in range(6):block('CoolingFin',(j-2.5)*3,8,-4,1.3,14,9,'trim','Metal')
    for side in [-1,1]:pipe((side*13,3,-5),(side*13,3,13),2)
   elif i==7:
    part('FurnaceHearth',(0,5,0),(10,27,27),'dark','Basalt','Cylinder',rotation=(0,0,math.pi/2))
    for j in range(10):
     a=j*math.tau/10;beam('FurnaceCrown',(math.cos(a)*12,9,math.sin(a)*12),(math.cos(a)*7,28,math.sin(a)*7),2.4,'roof')
    for side in [-1,1]:column(side*17,2,14);pipe((side*17,14,2),(side*10,14,0),2.5)
   elif i==8:
    shelter(w=23,d=15,y=10)
    for x in [-8,0,8]:block('RecoveredFreight',x,2.5,12,6,5,5,'wood','WoodPlanks')
   elif i==9:
    for j in range(7):
     a=j*math.tau/7;block('OldHeatFin',math.cos(a)*12,4,math.sin(a)*12,3,8,4,'stone','Basalt',yaw=-a)
    block('AbandonedHeatAltar',0,2,0,12,4,10,'dark','Basalt');shelter(-12,-8,14,9,8)
   else:
    for side in [-1,1]:beam('DerrickLeg',(side*11,0,0),(side*6,24,0),2,'dark')
    beam('OreCraneArm',(-10,24,0),(15,24,0),1.8,'trim');wheel(0,23,1,3.5)
    beam('OreCraneCable',(13,23,0),(13,5,0),.18,'trim',True);block('OreLanding',0,1,8,22,2,13,'wood','WoodPlanks')
  else:
   if i==1:
    arch(0,0,16,15);wall(-13,-3,10,7,True);tower(12,-3,16)
   elif i==2:
    shelter(w=29,d=20,y=13);roof(-17,2,12,16,9,pitch=.2)
    block('AlliedPlanningTable',0,3,15,13,1,6,'wood','WoodPlanks')
   elif i==3:
    arch(0,2,11,15);wall(0,-8,22,11);roof(0,-3,26,16,16,pitch=.3)
    for j in range(4):block('KeeperStair',0,(j+.5)*.65,10-j*2.2,12,.65,2.2)
   elif i==4:
    arch(0,0,18,22)
    for side in [-1,1]:tower(side*16,-2,26)
    wheel(-15,16,3,4.5);beam('GateDrum',(-17,15,0),(-10,15,0),3,'trim')
   elif i==5:
    for side in [-1,1]:
     column(side*11,0,16)
     for j in [-1,0,1]:block('ShieldPylonFin',side*11+j*2,18+abs(j)*-3,0,1.3,8,5,'dark')
     block('BrokenShieldInlay',side*11,13,2.5,.8,8,.15,'accent','Neon',True)
   elif i==6:
    arch(0,7,16,23);wall(0,-10,30,18)
    for side in [-1,1]:column(side*13,-4,20)
    roof(0,-2,33,22,24,pitch=.25)
    block('RoyalCrownBand',0,24,7,8,1,1,'trim','Metal')
    for j in [-1,0,1]:block('RoyalCrownPoint',j*2.5,26,7,1.5,3,1,'trim','Metal')
   else:
    for j in range(3):block('BindingDais',0,(j+.5)*1.2,0,30-j*5,1.2,25-j*4,'dark')
    for side in [-1,1]:column(side*9,-5,15);beam('EmptyBindingBrace',(side*7,5,-3),(side*5,13,-3),1.2,'trim')
    block('EmptyBindingCradle',0,6,-3,6,1.2,6,'trim','Metal')
   lantern(-13,12);lantern(13,12)
  if prefix=='GW'and i==1:
   for j in range(5):block('SilkSuspendedCartPlank',0,13+j*.15,3+(j-2)*1.2,8,.3,1,'wood','WoodPlanks')
   for side in [-1,1]:
    block('SuspendedCartSide',side*4,15,3,.6,3,7,'wood','WoodPlanks')
    for z in [1,5]:part('SuspendedCartWheel',(side*4.3,12,z),(.8,3.8,3.8),'wood','Wood','Cylinder')
    beam('CartSilkSuspension',(side*11,24,-4),(side*4,14,3),.15,'soft',True)
  if prefix=='GW'and i==2:
   for x in [-9,9]:
    beam('EmptySilkHanger',(x,24,-3),(x,17,-3),.12,'soft',True)
    part('EmptySilkBundle',(x,14,-3),(2.5,6,2.5),'soft','Fabric','Ball',soft=True)
  for obj in state['collection'].objects:obj['ConceptStory']=row['id'];obj['ConceptSource']=row['id']+'.png'
 scene['RegionalKitJSON']=json.dumps(models)
 scene['ColorManagement']='Standard/sRGB/None/Exposure0/Gamma1/CurvesOff'
 bpy.context.window.scene=previous_scene
 print(json.dumps({'scene':scene.name,'preserved':previous_scene.name,'prefix':prefix,'models':len(models),'parts':sum(map(len,models.values()))}))
