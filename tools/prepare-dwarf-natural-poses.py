import json,re
from pathlib import Path
root=Path(__file__).resolve().parents[1]
old=json.loads((root/'assets/animations/dwarf-diagonal-v1/clip.json').read_text())
def rows(path):return json.loads(re.search(r'SOLVED_NATURAL (\[.*\])',path.read_text()).group(1))
solved=rows(root/'docs/evidence/dwarf-natural-swing-20261105/solve-baseline-refined-native.log')
solved[0]=rows(root/'docs/evidence/dwarf-natural-swing-20261105/solve-stable-grip-native.log')[1]
def sample(keys,t):
 i=max([i for i in range(len(keys)-1) if t>=keys[i][0]] or [0]);a,b=keys[i:i+2];h=b[0]-a[0];u=max(0,min(1,(t-a[0])/h));return (2*u**3-3*u*u+1)*a[1]+(u**3-2*u*u+u)*h*a[2]+(-2*u**3+3*u*u)*b[1]+(u**3-u*u)*h*b[2]
times=[0,.052]+[x['age'] for x in solved]
poses=[{k:[sample(axis,t) for axis in axes] for k,axes in old['curves'].items()}for t in times]
poses[1].update(right=[95,-20,-40],elbow=[22,0,0],wrist=[-18,-15,15],weapon=[-65,0,0])
for i,x in enumerate(solved,2):
 v=x['parameters'];poses[i].update(right=v[:3],elbow=[v[3],0,0],wrist=v[4:],weapon=[-94,0,0])
# End on the established guard so recovery and the next stroke join exactly.
poses[-1]={k:[axis[-1][1] for axis in axes]for k,axes in old['curves'].items()}
poses[-1]['weapon']=[-94,0,0]
p=root/'assets/animations/dwarf-natural-v2';p.mkdir(exist_ok=True)
(p/'poses.json').write_text(json.dumps({'times':times,'poses':poses},indent=2)+'\n')
