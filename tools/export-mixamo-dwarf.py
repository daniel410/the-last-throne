"""Fit measured Mixamo rotations to existing server timing and export curves."""
import copy
import json
import math
import pathlib

ROOT=pathlib.Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/animations/mixamo-dwarf-v1'
raw=json.loads((OUT/'retargeted.json').read_text())
old=json.loads((ROOT/'assets/animations/melee-blender-v1/curves.json').read_text())
guard=old['guard']['dwarf'];rest=old['rest']['dwarf']
legacy={c.get('skillId','basic'):c for c in old['clips'] if c['classId']=='dwarf'}
calibration=json.loads((OUT/'grip-calibration.json').read_text()) if (OUT/'grip-calibration.json').exists() else {}

def matrix(v):
    x,y,z=map(math.radians,v);cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
    return [[cy*cz,-cy*sz,sy],[cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy],[sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy]]
def multiply(a,b):return [[sum(a[i][k]*b[k][j]for k in range(3))for j in range(3)]for i in range(3)]
def euler(m):return [math.degrees(math.atan2(-m[1][2],m[2][2])),math.degrees(math.asin(max(-1,min(1,m[0][2])))),math.degrees(math.atan2(-m[0][1],m[0][0]))]

def source_pose(name,t):
    frames=raw['clips'][name]['frames']
    f=min(frames,key=lambda f:abs(f['time']-t))
    a=copy.deepcopy(f['angles'])
    # Short limbs need moderate torso movement and a supported wrist. Keep the
    # source's shoulder/elbow sequence; the rigid axe socket is calibrated in FK.
    original_torso=matrix(a['torso'])
    a['torso']=[max(-28,min(22,a['torso'][0]))*.7,
                max(-40,min(40,a['torso'][1])),max(-20,min(20,a['torso'][2]))*.6]
    adjusted=matrix(a['torso'])
    inverse=[list(row)for row in zip(*adjusted)]
    correction=multiply(inverse,original_torso)
    # Preserve measured world-space arm directions when reducing the source's
    # deep torso hunch. Clamping only the waist would lift a landed axe overhead.
    for ch in ['right','left']:
        a[ch]=euler(multiply(correction,matrix(a[ch])))
    a['neck']=[max(-12,min(12,v)) for v in a['neck']]
    a['wrist']=[max(-30,min(30,v)) for v in a['wrist']]
    return a

def slope(ts,vs,i):
    if i==0 or i==len(ts)-1:return 0
    l,r=ts[i]-ts[i-1],ts[i+1]-ts[i]
    a,b=(vs[i]-vs[i-1])/l,(vs[i+1]-vs[i])/r
    return 3*(l+r)/((2*r+l)/a+(r+2*l)/b) if a*b>0 else 0
def sample(keys,t):
    i=max(0,min(len(keys)-2,next((i-1 for i,k in enumerate(keys)if k[0]>t),len(keys)-2)))
    a,b=keys[i:i+2];h=b[0]-a[0];u=max(0,min(1,(t-a[0])/h))
    return (2*u**3-3*u*u+1)*a[1]+(u**3-2*u*u+u)*h*a[2]+(-2*u**3+3*u*u)*b[1]+(u**3-u*u)*h*b[2]

clips={}
specs={
 'overhead':('Standing Melee Combo Attack Ver. 1',legacy['dwarf.common.overhead'],[0,.75,2.00,2.50,4.666666667]),
 'ground':('Standing Melee Run Jump Attack',legacy['dwarf.common.ground'],[.72,1.25,1.80,2.05,2.80]),
 'grounded':('Standing Melee Attack Downward',legacy['dwarf.common.ground'],[0,.50,.93,1.10,1.60]),
 'backhand':('Standing Melee Attack Backhand',legacy['dwarf.common.overhead'],[0,.65,.98,1.23,1.80]),
 'sweep':('Standing Melee Attack 360 Low',legacy['dwarf.common.overhead'],[0,.57,.98,1.20,1.65]),
}
for key,(name,base,anchors) in specs.items():
    c={k:copy.deepcopy(v) for k,v in base.items() if k not in ['curves','golden','skillId']}
    c['name']='Mixamo_Dwarf_'+key;c['source']=name
    c['baseSkillIndex']=3 if key=='grounded' else 1
    # Five semantic anchors, plus uniform samples between them: no phase holds.
    ts=[0,c['entryUntil'],c['windup']+c['hitDelay'],c['windup']+c['active']+c['recovery']*.15,c['duration']]
    times=sorted(set(round(ts[i]+(ts[i+1]-ts[i])*n/8,9) for i in range(4) for n in range(9)))
    poses=[];lifts=[]
    prev={}
    for t in times:
        i=min(3,next((j for j in range(4) if t<=ts[j+1]+1e-8),3))
        u=max(0,min(1,(t-ts[i])/(ts[i+1]-ts[i])))
        source_time=anchors[i]+(anchors[i+1]-anchors[i])*u
        a=source_pose(name,source_time)
        # Resolve Euler equivalences before blending to/from the accepted stance.
        for channel,values in a.items():
            ref=prev.get(channel,rest[channel])
            equivalents=[values,[values[0]+180,180-values[1],values[2]+180]]
            candidates=[]
            for values in equivalents:
                v=[x+360*round((r-x)/360) for x,r in zip(values,ref)]
                candidates.append(v)
            a[channel]=min(candidates,key=lambda v:sum((x-r)**2 for x,r in zip(v,ref)))
        prev=copy.deepcopy(a)
        if t<ts[1]:
            blend=t/ts[1];blend=blend*blend*(3-2*blend)
            a={ch:[rest[ch][j]+(v-rest[ch][j])*blend for j,v in enumerate(values)] for ch,values in a.items()}
        if t>ts[3]:
            blend=(t-ts[3])/(ts[4]-ts[3]);blend=blend*blend*(3-2*blend)
            a={ch:[v+(guard[ch][j]-v)*blend for j,v in enumerate(values)] for ch,values in a.items()}
        # Existing small planted-leg weight shifts, never source root locomotion.
        for ch in ['rightHip','leftHip','rightKnee','leftKnee']:
            load=math.sin(math.pi*min(1,t/c['duration']))
            if key=='ground':
                a[ch]=[max(-65,min(65,v)) for v in a[ch]]
            else:
                a[ch]=[(-6 if ch=='rightHip' else 6 if ch=='leftHip' else 6)*load,0,0]
        lift=0
        if key=='ground' and t<ts[2]:
            frames=raw['clips'][name]['frames']
            def height(time):return min(frames,key=lambda f:abs(f['time']-time))['hips'][1]
            baseline=height(anchors[0])+(height(anchors[2])-height(anchors[0]))*t/ts[2]
            lift=max(0,min(1.4,(height(source_time)-baseline)*3))
        lifts.append(lift)
        socket=calibration.get(key,[-94,0,0])
        blend=min(1,t/ts[1]);blend=blend*blend*(3-2*blend)
        options=[socket,[socket[0]+180,180-socket[1],socket[2]+180]]
        options=[[x-360*round(x/360)for x in v]for v in options]
        socket=min(options,key=lambda v:sum(x*x for x in v))
        a['weapon']=[x*blend for x in socket]
        release=ts[3]
        if t>release:
            fade=(t-release)/(ts[4]-release);fade=fade*fade*(3-2*fade)
            a['weapon']=[v+(guard['weapon'][j]-v)*fade for j,v in enumerate(a['weapon'])]
        poses.append(a)
    c['curves']={}
    if key=='ground': c['rootLift']=[[t,v,slope(times,lifts,i)]for i,(t,v)in enumerate(zip(times,lifts))]
    for ch in old['channels']:
        c['curves'][ch]=[]
        for axis in range(3):
            vs=[p[ch][axis] for p in poses]
            c['curves'][ch].append([[t,round(v,7),round(slope(times,vs,i),7)] for i,(t,v) in enumerate(zip(times,vs))])
    # R6 cannot reproduce the measured elbow/wrist. Preserve its established
    # contact path explicitly rather than claim the R15 retarget supports it.
    c['r6Curves']=copy.deepcopy(base['curves'])
    clips[key]=c

# User-selected replacement: the complete previous Overhead Smash becomes the
# basic strike. There is no blend with the superseded diagonal/basic animation.
adopted=json.loads((OUT/'basic-overhead-baseline.json').read_text())
def fit_curves(source,source_times,target_times,extra=()):
    def remap(t,old_times,new_times):
        # Smooth time warp through the semantic anchors. A piecewise linear
        # warp changes angular speed abruptly exactly at the damage sample.
        keys=[[x,y,slope(old_times,new_times,i)]for i,(x,y)in enumerate(zip(old_times,new_times))]
        keys[0][2]=(new_times[1]-new_times[0])/(old_times[1]-old_times[0])
        keys[-1][2]=(new_times[-1]-new_times[-2])/(old_times[-1]-old_times[-2])
        return sample(keys,t)
    # Keep an evenly spaced C1 fit; nearly coincident mapped keys create a
    # sub-millisecond acceleration spike when the full skill is compressed.
    uniform=[round(target_times[-1]*i/80,6)for i in range(81)]
    times=sorted(set([t for t in uniform if min(abs(t-a)for a in target_times)>.004]+target_times+list(extra)))
    result={}
    for ch,axes in source.items():
        result[ch]=[]
        for axis in axes:
            values=[sample(axis,remap(t,target_times,source_times))for t in times]
            result[ch].append([[t,v,slope(times,values,i)]for i,(t,v)in enumerate(zip(times,values))])
    return result
basic={k:copy.deepcopy(v)for k,v in legacy['basic'].items()if k not in ['curves','golden']}
basic.update(name='Mixamo_Dwarf_PreviousOverhead_AsBasic_v2',source=adopted['source'],adoptedFrom='0.86.1/dwarf.common.overhead',entryUntil=.12,entryFraction=.75,disableR6FollowAcross=True)
source_times=[0,adopted['entryUntil'],adopted['windup']+adopted['hitDelay'],adopted['windup']+adopted['active']+adopted['recovery']*.15,adopted['duration']]
target_times=[0,.12,.22,.284,.42]
basic['curves']=fit_curves(adopted['curves'],source_times,target_times)
basic['r6Curves']=fit_curves(adopted['r6Curves'],source_times,target_times)
clips['basic']=basic
# R6 cannot reproduce the Mixamo elbow chain, so adapt the reviewed overhead
# path into the same two visible beats, retaining the second authoritative hit.
r6_anchors=[0,.12,.2925,.36,.46,.563,.71,.7681,.858,1.13]
r6_source=[0,.2925,.71,.875,1.13,.2925,.71,.875,1.13,1.13]
r6_times=sorted(set([round(1.13*i/100,6)for i in range(101)]+r6_anchors))
def r6_time(t):
    i=min(len(r6_anchors)-2,next((j for j in range(len(r6_anchors)-1)if t<=r6_anchors[j+1]),len(r6_anchors)-2))
    u=(t-r6_anchors[i])/(r6_anchors[i+1]-r6_anchors[i])
    return r6_source[i]+(r6_source[i+1]-r6_source[i])*u
r6={}
for ch,axes in adopted['r6Curves'].items():
    r6[ch]=[]
    for axis in axes:
        values=[sample(axis,r6_time(t))for t in r6_times]
        r6[ch].append([[t,v,slope(r6_times,values,i)]for i,(t,v)in enumerate(zip(r6_times,values))])
clips['overhead']['r6Curves']=r6
clips['overhead']['sourceBeats']=[.2925,.71]

def lua(x):
    if isinstance(x,dict): return '{'+','.join('['+json.dumps(k)+']='+lua(v) for k,v in x.items())+'}'
    if isinstance(x,list):return '{'+','.join(map(lua,x))+'}'
    return json.dumps(x)
def quantize(x):
    if isinstance(x,dict):return {k:quantize(v)for k,v in x.items()}
    if isinstance(x,list):return [quantize(v)for v in x]
    if isinstance(x,float):return round(x,6)
    return x
clips=quantize(clips)
runtime={'basic':clips['basic'],'skills':{'dwarf.common.overhead':clips['overhead'],'dwarf.common.ground':clips['ground']},
         'variants':{'dwarf.mixamo.backhand':clips['backhand'],'dwarf.mixamo.sweep':clips['sweep'],'dwarf.mixamo.grounded':clips['grounded']}}
(OUT/'clips.json').write_text(json.dumps(clips,separators=(',',':'))+'\n')
overhead=runtime['skills'].pop('dwarf.common.overhead')
for name,value in [('K0DwarfMixamoBasic',runtime['basic']),('K0DwarfMixamoOverhead',overhead),('K0DwarfMixamoSkills',{'skills':runtime['skills'],'variants':runtime['variants']})]:
    source='-- Generated by tools/export-mixamo-dwarf.py from measured FBX rotations.\nreturn '+lua(value)+'\n'
    assert len(source)<200000,(name,len(source))
    (ROOT/'src/client'/f'{name}.luau').write_text(source)
(ROOT/'src/client/K0DwarfMixamoClips.luau').write_text('-- Generated Mixamo dwarf packs; split for Studio source limits.\nlocal skills=require(script.Parent.K0DwarfMixamoSkills)\nskills.skills["dwarf.common.overhead"]=require(script.Parent.K0DwarfMixamoOverhead)\nreturn {basic=require(script.Parent.K0DwarfMixamoBasic),skills=skills.skills,variants=skills.variants}\n')
print('Exported Mixamo dwarf clips:',', '.join(clips))
