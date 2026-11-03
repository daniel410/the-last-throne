"""Individual Frozen Vale/Ember Caldera review directions; Blender evaluates export curves."""
import json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
# guard / preparation / impact / follow-through, degrees; anatomical leg amplitude.
styles={
'IceWolf':(0,0,0,0,24),'IceBear':(0,0,0,0,18),'KingIceBear':(0,0,0,0,17),
'IceTroll':(0,72,-38,-52,22),'IceGolem':(0,55,-32,-45,20),'IceElf':(-3,12,-15,-21,18),
'IceTrollKing':(0,68,-34,-48,21),'KingIceGolem':(0,57,-34,-48,19),'QueenIceElf':(0,0,0,0,0),'AncientGlacierKing':(0,60,-35,-49,18),
'Imp':(0,28,-20,-28,24),'LavaSlime':(0,0,0,0,0),'Golem':(0,53,-31,-44,20),'MagmaWorm':(0,0,0,0,0),
'VolcanoShaman':(0,0,0,0,0),'MagmaImp':(0,30,-22,-31,23),'MagmaGolem':(0,56,-33,-47,19),
'InfernoOverlord':(0,48,-31,-42,18),'CalderaTitan':(0,59,-35,-49,18),'KingVolcanoShaman':(0,0,0,0,0)}
def sample(m,c,t):
 f=t*200;i=min(200,int(f));a=f-i
 return {ch:[v+(rows[min(i+1,200)][j]-v)*a for j,v in enumerate(rows[i])]for ch,rows in m['clips'][c].items()}
def gait(t,a):
 t%=1;return a*(1-2*t/.6)if t<.6 else -a*math.cos(math.pi*(t-.6)/.4)
def body(y=0,p=0,yaw=0,z=0):return [0,y,z,p,yaw,0,1,1,1]
def pose(b=None,w=None,o=None,r=None,l=None):return dict(body=b or body(),weapon=w or [0,0,0],off=o or [0,0,0],rightLeg=r or [0,0,0],leftLeg=l or [0,0,0])
for region in ['frozen-vale','ember-caldera']:
 base=json.loads((ROOT/f'assets/animations/{region}-v1/clips.json').read_text());out={k:v for k,v in base.items()if k!='models'};out.update(version=2,models={})
 for kind,m in base['models'].items():
  g,prep,hit,end,amp=styles[kind];quad=m['quadruped'];caster=kind in ['IceElf','QueenIceElf','VolcanoShaman','KingVolcanoShaman'];rigidCaster=caster and not m['hasLegs'];imp=kind in ['Imp','MagmaImp']
  meta={k:v for k,v in m.items()if k!='clips'};meta.update(reviewedGait=True,stanceDuty=.6,clips={})
  if kind=='IceTrollKing':meta.update(weaponArm='ArmL',reverseWeaponSwing=True)
  if imp:
   # Existing pivots use wing bounds. Rotate around the actual upper-arm roots.
   meta['pivots']['ArmR']=[.29,.66,.02];meta['pivots']['ArmL']=[-.29,.66,.02]
  if m['hasLegs']:
   names=['LegBL','LegBR']if quad else ['LegL','LegR'];lever=sum(meta['pivots'][n][1]for n in names)/len(names)
   meta['stride']=round(2*lever*math.sin(math.radians(amp))/.6,5)
  out['models'][kind]=meta
  for clip in m['clips']:
   attack=clip.startswith('Attack')or clip.startswith('Heavy');heavy=clip.startswith('Heavy');side=-1 if clip.endswith('Alt')else 1
   phases=[0,.18,.4,.5,.55,.62,.69,.78,.9,1]if attack else sorted(set([i/16 for i in range(17)]+([.1,.6]if clip=='Walk'else[])))
   keys=[]
   for t in phases:
    p=sample(m,clip,t);b=p['body'];sn=math.sin(t*math.tau)
    if kind=='LavaSlime':
     sy=1+(b[7]-1)*.65;b[6]=b[8]=1/math.sqrt(sy);b[7]=sy;b[1]*=.55;b[2]*=.65;b[3]*=.5;b[5]*=.5
    elif kind=='MagmaWorm':
     # Single-piece source: keep the buried base close to the ground, avoid airborne plank lunges.
     b[1]*=.12;b[2]*=.55;b[3]*=.40;b[4]*=.4;b[5]*=.35
    elif attack:
     strength=1.12 if heavy else 1
     if quad:
      # Small body thrust for a bite; short front-paw reach for bears. Rear feet support the weight.
      ready=pose(body(-.012,-3,side*2,z=.012));contact=pose(body(-.008,4*strength,-side*3,z=-.035));follow=pose(body(-.01,5*strength,-side*4,z=-.04))
      if kind!='IceWolf':
       contact['weapon']=[12*strength,0,-side*3];follow['weapon']=[17*strength,0,-side*4]
       if side<0:
        contact['off'],contact['weapon']=contact['weapon'],contact['off'];follow['off'],follow['weapon']=follow['weapon'],follow['off']
      ready['rightLeg']=[2,0,0];ready['leftLeg']=[2,0,0]
      track={0:pose(),.18:pose(body(-.004,-1)),.4:ready,.5:ready,.55:ready,.62:contact,.69:follow,.78:follow,.9:pose(body(-.003,1)),1:pose()};p=track[t]
     else:
      b[0]*=.35;b[1]*=.45;b[2]*=.6;b[3]*=.4;b[4]*=.4;b[5]*=.3
      values={0:g,.18:g+(prep-g)*.22,.4:prep,.5:prep+1,.55:prep+1,.62:hit,.69:end,.78:end,.9:end*.25,1:g}
      angle=values[t]*strength
      p['weapon']=[angle,side*(0 if rigidCaster else 5 if caster or imp else 9)*(0 if t in[0,1]else 1),0 if rigidCaster else -3 if t<.6 else 3]
      p['off']=[0,0,0]if caster else [p['off'][0]*(.12 if imp else .3),p['off'][1]*.3,p['off'][2]*.25]
      p['rightLeg']=p['leftLeg']=[0,0,0]
      if rigidCaster:p['weapon']=[0,0,0]
    elif clip=='Walk':
     b[0]*=.4;b[1]*=.35;b[3]*=.4;b[4]*=.4;b[5]*=.3
     if m['hasLegs']:
      r,l=gait(t,amp),gait(t+.5,amp);p['rightLeg']=[r,0,0];p['leftLeg']=[l,0,0]
      if quad:p['weapon']=[r,0,0];p['off']=[l,0,0]
      else:
       wleg,oleg=(l,r)if kind=='IceTrollKing'else(r,l)
       p['weapon']=[g+wleg*(.13 if caster or imp else .25),0,0];p['off']=[oleg*(.18 if imp else .4),0,0]
     else:p['weapon']=p['off']=[0,0,0]
    elif clip=='Idle':
     b[3]*=.4;b[4]*=.4;b[5]*=.4;p['weapon']=[0,0,0]if rigidCaster else [g+sn*.6,0,0];p['off']=[0,0,0]if caster else [-sn*.6,0,0]
    elif clip=='Stunned':
     b[3]*=.45;b[4]*=.5;b[5]*=.4;p['weapon']=[0,0,0]if rigidCaster else [5+sn,0,-3];p['off']=[0,0,0]if caster else [3-sn,0,3];p['rightLeg']=p['leftLeg']=[0,0,0]
    if rigidCaster:p['weapon']=p['off']=[0,0,0] # Staff/cloth straddle source mesh seams: preserve their common anchor until a complete replacement is imported.
    keys.append([t,p])
   meta['clips'][clip]=keys
  folder=ROOT/f'assets/animations/{region}-v2';folder.mkdir(exist_ok=True);(folder/'authoring-keys.json').write_text(json.dumps(out,separators=(',',':'))+'\n')
 print(region,'10 individually directed profiles')
