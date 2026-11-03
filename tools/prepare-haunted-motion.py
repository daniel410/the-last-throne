"""Per-model HG directions from native/Blender review; existing TD meshes stay immutable."""
from pathlib import Path
import json,math,hashlib,importlib.util
ROOT=Path(__file__).resolve().parents[1];folder=ROOT/'assets/animations/haunted-graveyard-v1';folder.mkdir(parents=True,exist_ok=True)
source=json.loads((ROOT/'assets/shared/td-haunted-graveyard/manifest.json').read_text())
# Anatomical shoulder corrections: source upper bounds include blades/shield rims.
shoulders={'Zombie':{'ArmL':[-.36,.71,.03],'ArmR':[.36,.71,.03]},'Skeleton':{'ArmL':[-.32,.73,.03],'ArmR':[.32,.73,.03]},'SkeletonKnight':{'ArmL':[-.27,.73,.02],'ArmR':[.27,.73,.02]},'Mummy':{'ArmL':[-.32,.67,.04],'ArmR':[.32,.67,.04]}}
# guard, preparation, contact, follow-through, leg amplitude (degrees).
styles={'Zombie':(5,-20,22,28,16),'Skeleton':(0,55,-25,-34,20),'Ghoul':(0,0,0,0,0),'Mummy':(3,-14,16,21,0),'Hellhound':(0,0,0,0,20),'SkeletonKnight':(0,52,-28,-38,18),'DeathKnight':(0,0,0,0,18),'Lich':(0,0,0,0,0),'LichSovereign':(0,0,0,0,0),'DreadCommander':(0,0,0,0,0),'Veyr':(0,0,0,0,0)}
clips=['Idle','Walk','Attack','AttackAlt','Heavy','HeavyAlt','Stunned'];channels=['body','weapon','off','rightLeg','leftLeg']
def body(y=0,p=0,yaw=0,roll=0,z=0):return [0,y,z,p,yaw,roll,1,1,1]
def pose(b=None,w=None,o=None,r=None,l=None):return dict(body=b or body(),weapon=w or [0,0,0],off=o or [0,0,0],rightLeg=r or [0,0,0],leftLeg=l or [0,0,0])
def gait(t,amp):
 t%=1;return amp*(1-2*t/.6)if t<.6 else -amp*math.cos(math.pi*(t-.6)/.4)
keys={'version':1,'samples':201,'fps':120,'impactPhase':.62,'channels':channels,'models':{}};rigs={};provenance={}
loader=importlib.util.spec_from_file_location('mesh',ROOT/'tools/repair-deepwood-weapons.py');mesh=importlib.util.module_from_spec(loader);loader.loader.exec_module(mesh)
for kind,spec in source['models'].items():
 quad=kind=='Hellhound';caster=kind in ['Lich','LichSovereign'];mono=kind in ['Ghoul','DreadCommander','Veyr'];hasLegs='LegL'in spec['parts']or quad
 guard,prep,hit,follow,amp=styles[kind];pivots={k:list(v)for k,v in spec['pivots'].items()};pivots.update(shoulders.get(kind,{}))
 sourcePath=ROOT.parent/'throne-defense/assets/models/meshy-blocky-monsters-v1/runtime'/spec['template']/'textured-review.glb'
 geometryPath=sourcePath.with_name('geometry.json');assert hashlib.sha256(geometryPath.read_bytes()).hexdigest()==spec['geometrySha256']
 provenance[kind]={'tdPath':str(sourcePath.relative_to(ROOT.parent/'throne-defense')),'sha256':hashlib.sha256(sourcePath.read_bytes()).hexdigest()}
 meta={'hasLegs':hasLegs,'quadruped':quad,'stride':.4,'breathSeconds':2.8 if kind=='Zombie'else 2.5 if mono else 2.2,'reviewedGait':True,'stanceDuty':.6,'pivots':pivots,'rigidArms':caster or mono or kind=='DeathKnight','clips':{}}
 if hasLegs:
  legs=['LegBL','LegBR']if quad else ['LegL','LegR'];lever=sum(pivots[x][1]for x in legs)/2;meta['stride']=round(2*lever*math.sin(math.radians(amp))/.6,6)
 rig={k:spec[k]for k in ['template','parts']};rig.update(folder='HauntedGraveyardModels',pivots=pivots)
 if kind in ['Skeleton','SkeletonKnight']or caster:
  rig['weaponArm']='ArmL';rig['reverseWeaponSwing']=False
  faces=mesh.read(sourcePath)['ArmL'];pts=[v[0]for f in faces for v in f];lo=[min(v[i]for v in pts)for i in range(3)];hi=[max(v[i]for v in pts)for i in range(3)];center=[(a+b)/2 for a,b in zip(lo,hi)];size=[b-a for a,b in zip(lo,hi)]
  top=sorted(pts,key=lambda v:v[1],reverse=True)[:max(6,len(pts)//80)];tip=[sum(v[i]for v in top)/len(top)for i in range(3)];normal=[-(tip[0]-center[0])/size[0],(tip[1]-center[1])/size[1],-(tip[2]-center[2])/size[2]]
  rig['socket']={'tip':normal,'base':[normal[0],normal[1]-.18,normal[2]],'caster':caster,'element':'spirit'if caster else 'steel'}
  meta['weaponArm']='ArmL'
 # Native bbox corners overestimate ground contact on fused robes/weapons.
 # Keep a bounded lower-surface sample set from the unchanged TD Body vertices.
 if not hasLegs:
  faces=mesh.read(sourcePath)['Body'];points=[v[0]for f in faces for v in f]
  lo=[min(v[i]for v in points)for i in range(3)];hi=[max(v[i]for v in points)for i in range(3)];sz=[b-a for a,b in zip(lo,hi)];center=[(a+b)/2 for a,b in zip(lo,hi)];cells={}
  for point in points:
   if point[1]>lo[1]+sz[1]*.22:continue
   cell=(min(7,int((point[0]-lo[0])/sz[0]*8)),min(7,int((point[2]-lo[2])/sz[2]*8)))
   if cell not in cells or point[1]<cells[cell][1]:cells[cell]=point
  meta['groundPoints']=[[round(-(v[0]-center[0])/sz[0],7),round((v[1]-center[1])/sz[1],7),round(-(v[2]-center[2])/sz[2],7)]for _,v in sorted(cells.items())]
  assert 3<=len(meta['groundPoints'])<=64
 rigs[kind]=rig
 for clip in clips:
  attack=clip.startswith('Attack')or clip.startswith('Heavy');heavy=clip.startswith('Heavy');side=-1 if clip.endswith('Alt')else 1
  phases=[0,.18,.4,.5,.55,.62,.69,.78,.9,1]if attack else sorted(set([i/16 for i in range(17)]+([.1,.5,.6]if clip=='Walk'else[])))
  result=[]
  for t in phases:
   sn=math.sin(t*math.tau);strength=1.12 if heavy else 1
   p=pose()
   if clip=='Idle':
    p['body']=body(p=.35*sn,yaw=.4*sn,roll=.18*sn);p['weapon']=[guard+sn*.5,0,0];p['off']=[-.4*sn,0,0]
   elif clip=='Walk':
    p['body']=body(p=.6*math.cos(t*math.tau*2),yaw=.8*sn,roll=.35*sn)
    if hasLegs:
     r,l=gait(t,amp),gait(t+.5,amp);p['rightLeg']=[r,0,0];p['leftLeg']=[l,0,0]
     if quad:p['weapon']=[r,0,0];p['off']=[l,0,0]
     else:
      # Swapped weapon/off channels continue to counter-swing their anatomical legs.
      w,o=(l,r)if kind in ['Skeleton','SkeletonKnight']else(r,l)
      p['weapon']=[guard+w*.18,0,0];p['off']=[o*.18,0,0]
    else:
     p['body']=body(p=.9*sn,yaw=1.4*sn,roll=.45*sn,z=.002*math.cos(t*math.tau*2))
     if kind=='Mummy':p['weapon']=[guard+2*sn,0,0];p['off']=[-1.5*sn,0,0]
   elif clip=='Stunned':
    p['body']=body(p=2+.45*sn,yaw=.6*sn,roll=.6*sn)
    p['weapon']=[guard+3+.5*sn,0,0];p['off']=[2-.5*sn,0,0]
   elif attack:
    envelope={0:0,.18:.2,.4:1,.5:1,.55:1,.62:-1,.69:-1.15,.78:-1.05,.9:-.2,1:0}[t]
    if kind in ['Skeleton','SkeletonKnight','Zombie','Mummy']:
     values={0:guard,.18:guard+(prep-guard)*.2,.4:prep,.5:prep,.55:prep,.62:hit,.69:follow,.78:follow,.9:guard+(follow-guard)*.2,1:guard}
     angle=guard+(values[t]-guard)*strength
     p['weapon']=[angle,side*(4 if kind in ['Zombie','Mummy']else 7)*(abs(envelope)),0]
     p['off']=[(5 if kind=='Zombie'else 3 if kind=='Mummy'else -2)*(-envelope),0,0]
     p['body']=body(p=-envelope*(1.5 if kind=='Mummy'else 2)*strength,yaw=-side*envelope*2.5*strength,z=envelope*.007)
    else:
     # Fused bodies/caster garments share their anchor. Telegraph with modest whole-body movement.
     pitch=2.5 if caster else 3 if quad else 4 if kind=='DeathKnight'else 5
     yaw=2.5 if quad else 3 if caster else 7 if kind=='Veyr'else 5
     reach=.026 if caster else .035 if quad else .04 if kind=='Ghoul'else .025
     p['body']=body(p=-pitch*envelope*strength,yaw=-side*yaw*envelope*strength,z=reach*envelope*strength,roll=0 if caster or quad else side*envelope*.7)
   if meta['rigidArms']:p['weapon']=p['off']=[0,0,0]
   result.append([t,p])
  meta['clips'][clip]=result
 keys['models'][kind]=meta
(folder/'authoring-keys.json').write_text(json.dumps(keys,separators=(',',':'))+'\n')
(folder/'rigs.json').write_text(json.dumps(rigs,indent=2)+'\n')
(folder/'source-models.json').write_text(json.dumps(provenance,indent=2)+'\n')
print('Prepared 11 individually directed profiles; 10 unchanged TD source models')
