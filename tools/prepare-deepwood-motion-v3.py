"""Per-species motion direction from individual native/Blender review; feeds actual Blender F-curves."""
import json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];base=json.loads((ROOT/'assets/animations/deepwood-monsters-v2/clips.json').read_text())
# Guard / anticipation / impact / follow-through, degrees. Server impact remains .62.
styles={
'Goblin':([8,-4,-6],[86,-20,-22],[4,20,17],[-19,28,20],26,.32),
'Orc':([3,0,-4],[96,-12,-13],[-35,13,8],[-51,17,12],22,.275),
'Ogre':([0,0,-2],[75,-7,-11],[-45,8,6],[-61,11,10],20,.25),
'Shaman':([-2,0,-3],[12,-13,-7],[-17,7,3],[-23,10,4],12,.30),
'Warlord':([5,-4,-6],[88,-20,-17],[-44,19,13],[-60,25,18],22,.275),
'GoblinKing':([0,-2,-3],[34,-16,-10],[-28,16,8],[-40,20,11],12,.31),
'KingOgre':([0,-1,-3],[77,-10,-12],[-46,10,8],[-62,14,13],12,.38),
'EnragedWarlord':([0,0,0],[0,0,0],[0,0,0],[0,0,0],0,.45),
'KingShaman':([-3,-2,-3],[17,-15,-10],[-21,9,5],[-29,12,6],12,.30),
'Slime':([0,0,0],[0,0,0],[0,0,0],[0,0,0],0,.33),
}
def sample(model,clip,t):
 f=t*200;i=min(200,int(f));a=f-i
 return {ch:[v+(model['clips'][clip][ch][min(i+1,200)][j]-v)*a for j,v in enumerate(values[i])]for ch,values in model['clips'][clip].items()}
def gait(t,amp):
 t=t%1
 return amp*(1-2*t/.6)if t<.6 else -amp*math.cos(math.pi*(t-.6)/.4)
out={'version':3,'samples':201,'fps':120,'impactPhase':.62,'channels':base['channels'],'models':{}}
for kind,model in base['models'].items():
 guard,wind,contact,follow,amp,stride=styles[kind];caster=kind in ['Shaman','KingShaman'];mono=kind=='EnragedWarlord'
 meta={k:v for k,v in model.items()if k not in ['clips','controllers']};meta.update(stride=stride,reviewedGait=True,stanceDuty=.6,clips={});out['models'][kind]=meta
 for clip in model['clips']:
  attack=clip.startswith('Attack')or clip.startswith('Heavy');heavy=clip.startswith('Heavy');alt=clip.endswith('Alt')
  phases=[0,.18,.4,.5,.55,.62,.69,.78,.9,1]if attack else sorted(set([i/16 for i in range(17)]+([.1,.5,.6]if clip=='Walk'else[])))
  keys=[]
  for t in phases:
   p=sample(model,clip,t);b=p['body']
   if kind=='Slime':
    sy=1+(b[7]-1)*.7;b[6]=b[8]=1/math.sqrt(sy);b[7]=sy;b[1]*=.8;b[3]*=.6;b[5]*=.6
   elif attack:
    b[0]*=.55;b[1]*=.7;b[2]*=.8;b[3]*=.55 if not model['hasLegs']else .72;b[4]*=.7;b[5]*=.5
    w=list(wind);hit=list(contact);end=list(follow)
    if heavy:w[0]+=10;hit[0]-=8;end[0]-=8
    if alt:
     for q in [w,hit,end]:q[1]*=-.8;q[2]*=-.7
    if t in [0,1]:arm=guard
    elif t==.18:arm=[g+(v-g)*.22 for g,v in zip(guard,w)]
    elif t==.4:arm=w
    elif t in [.5,.55]:arm=[w[0]+2,w[1],w[2]]
    elif t==.62:arm=hit
    elif t in [.69,.78]:arm=end
    else:arm=[v*.35+g*.65 for v,g in zip(end,guard)]
    p['weapon']=arm
    if caster:
     p['off']={0:[7,1,5],.18:[17,0,7],.4:[36,-5,12],.5:[40,-5,12],.55:[40,-5,12],.62:[50,5,8],.69:[43,7,6],.78:[43,7,6],.9:[12,3,5],1:[7,1,5]}[t]
    else:p['off']=[p['off'][0]*.7,p['off'][1]*.8,p['off'][2]*.8]
    if mono:
     # One-piece source: avoid a whole-body tilt that makes its feet jump.
     b[3]*=.65;b[4]*=.7;b[5]*=.5
   elif clip=='Walk':
    sn=math.sin(t*math.tau);b[0]*=.5;b[1]*=.6;b[3]*=.7;b[4]*=.6;b[5]*=.45
    if model['hasLegs']:
     right,left=gait(t,amp),gait(t+.5,amp)
     p['rightLeg']=[right,0,0];p['leftLeg']=[left,0,0]
     # The TD +Z template swaps R6 sides. Counter-swing opposite the anatomical leg.
     weaponLeg,offLeg=(left,right)if kind=='Warlord'else(right,left)
     p['weapon']=[guard[0]+weaponLeg*.22,guard[1],guard[2]]
     p['off']=[7+offLeg*.45,0,5]
    else:
     p['weapon']=[guard[0]-sn*2.0,guard[1],guard[2]];p['off']=[7+sn*3,0,5]
    if mono:b[3]*=.5;b[4]*=.5;b[5]*=.5
   elif clip=='Idle':
    b[3]*=.7;b[4]*=.7;b[5]*=.7
    p['weapon']=[guard[0]+math.sin(t*math.tau)*1.2,guard[1],guard[2]]
   if kind in ['Shaman','GoblinKing','KingShaman']:
    # The source off-arm is only a hand/cloth sliver. Keep its original seam closed.
    # Casting remains in the staff arm and torso until a complete elbow rig is authored.
    p['off']=[0,0,0]
   keys.append([t,p])
  meta['clips'][clip]=keys
(ROOT/'assets/animations/deepwood-monsters-v3/authoring-keys.json').write_text(json.dumps(out,separators=(',',':'))+'\n')
print('10 per-model profiles prepared; Blender authoring required')
