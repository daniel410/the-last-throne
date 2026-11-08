"""Standing Draw Arrow -> basic attack reload, then existing anchor/release.

Only the R15 basic attack uses this clip. Skill pulses and the R6 fallback keep
the reviewed bow curves. The source is Reloading Bow, not a projectile event.
"""
import json
import math
import pathlib
ROOT=pathlib.Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/animations/mixamo-elf-v1'
raw=json.loads((OUT/'retargeted.json').read_text())['clips']['Standing Draw Arrow']
old=json.loads((ROOT/'assets/animations/elf-bow-v1/clip.json').read_text())['curves']
def sample(keys,t):
    i=max(0,min(len(keys)-2,next((i-1 for i,k in enumerate(keys)if k[0]>t),len(keys)-2)))
    a,b=keys[i:i+2];h=b[0]-a[0];u=max(0,min(1,(t-a[0])/h))
    return (2*u**3-3*u*u+1)*a[1]+(u**3-2*u*u+u)*h*a[2]+(-2*u**3+3*u*u)*b[1]+(u**3-u*u)*h*b[2]
def smooth(u):u=max(0,min(1,u));return u*u*(3-2*u)
def tangent(ts,vs,i):
    if i==0 or i==len(ts)-1:return 0
    l,r=ts[i]-ts[i-1],ts[i+1]-ts[i];a,b=(vs[i]-vs[i-1])/l,(vs[i+1]-vs[i])/r
    return 3*(l+r)/((2*r+l)/a+(r+2*l)/b)if a*b>0 else 0
times=sorted(set([round(i/100,6)for i in range(101)]+[round(k[0],6)for k in old['draw']]+[.50,.60,.70,.8]))
poses=[];draws=[];previous={}
for t in times:
    # Finish reloading before the final draw. Reach full anchor by the existing
    # 87.5%-windup hand/arrow checkpoint and retain the exact .8 release boundary.
    old_time=0 if t<.50 else .8*smooth((t-.50)/.20)if t<.70 else .8 if t<.8 else t
    pose={ch:[sample(axis,old_time)for axis in axes]for ch,axes in old.items()if ch!='draw'}
    source_time=min(raw['duration'],raw['duration']*t/.60)
    frame=min(raw['frames'],key=lambda f:abs(f['time']-source_time))
    envelope=smooth(t/.08)*(1-smooth((t-.45)/.15))
    for ch in ['right','elbow','wrist','left','leftElbow','torso','neck']:
        values=frame['angles'][ch]
        candidates=[values,[values[0]+180,180-values[1],values[2]+180]]
        ref=previous.get(ch,pose[ch])
        candidates=[[v+360*round((r-v)/360)for v,r in zip(c,ref)]for c in candidates]
        values=min(candidates,key=lambda v:sum((x-r)**2 for x,r in zip(v,ref)));previous[ch]=values
        if ch=='torso':values=[max(-20,min(20,v))for v in values]
        if ch=='neck':values=[max(-15,min(15,v))for v in values]
        if ch=='wrist':values=[max(-30,min(30,v))for v in values]
        weight={'right':.85,'elbow':.85,'wrist':.55,'left':.15,'leftElbow':.20,'torso':.45,'neck':.35}[ch]*envelope
        pose[ch]=[a+(b-a)*weight for a,b in zip(pose[ch],values)]
    poses.append(pose)
    draws.append(0 if t<.50 else sample(old['draw'],old_time))
clip={'name':'Mixamo_Elf_StandingDrawArrow','source':'Standing Draw Arrow','duration':1,'nockAt':.50,'ikStart':.50,'ikFull':.60,'curves':{}}
for ch in old:
    if ch=='draw':
        clip['curves'][ch]=[[t,round(v,6),round(tangent(times,draws,i),6)]for i,(t,v)in enumerate(zip(times,draws))]
    else:
        clip['curves'][ch]=[]
        for axis in range(3):
            values=[p[ch][axis]for p in poses]
            clip['curves'][ch].append([[t,round(v,6),round(tangent(times,values,i),6)]for i,(t,v)in enumerate(zip(times,values))])
def lua(x):
    if isinstance(x,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(v)for k,v in x.items())+'}'
    if isinstance(x,list):return '{'+','.join(map(lua,x))+'}'
    return json.dumps(x)
(OUT/'clips.json').write_text(json.dumps({'reload':clip},separators=(',',':'))+'\n')
source='-- Standing Draw Arrow: R15 basic reload only; skills retain ElfBowClip.\nreturn '+lua(clip)+'\n'
assert len(source)<200000
(ROOT/'src/client/K0ElfMixamoReload.luau').write_text(source)
print('Exported Standing Draw Arrow basic reload',len(source),'bytes')
