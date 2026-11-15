"""Author downcut/rising cut/horizontal sweep from owned curves and native grips.
The third strike follows the user's latest broad horizontal slash instruction.
"""
from pathlib import Path
import copy
import hashlib
import json

root = Path(__file__).resolve().parents[1]
folder = root / 'assets/animations/knight-reference-combo-v1'
source = root / 'assets/animations/mixamo-knight-v1/clips.json'
baseline = json.loads((root / 'assets/animations/mixamo-knight-v1/baseline.json').read_text())
owned = json.loads(source.read_text())['overhead']
solved = json.loads((folder / 'sweep-poses.json').read_text())
rest, guard, channels = baseline['rest'], baseline['guard'], baseline['channels']


def smooth(u):
    u = max(0, min(1, u))
    return u*u*(3-2*u)


def slopes(ts, values):
    result = [0.0]*len(ts)
    for i in range(1, len(ts)-1):
        left, right = ts[i]-ts[i-1], ts[i+1]-ts[i]
        a, b = (values[i]-values[i-1])/left, (values[i+1]-values[i])/right
        if a*b > 0:
            result[i] = 3*(left+right)/((2*right+left)/a+(right+2*left)/b)
    return result


def sample(keys, time):
    i = max(0, min(len(keys)-2, next((i-1 for i, k in enumerate(keys) if k[0] > time), len(keys)-2)))
    a, b = keys[i:i+2]
    span = b[0]-a[0]
    u = max(0, min(1, (time-a[0])/span))
    return (2*u**3-3*u*u+1)*a[1]+(u**3-2*u*u+u)*span*a[2]+(-2*u**3+3*u*u)*b[1]+(u**3-u*u)*span*b[2]


def pose(curves, time):
    return {ch: [sample(axis, time) for axis in curves[ch]] for ch in channels}


def sweep_pose(row):
    p = copy.deepcopy(guard)
    x = row['parameters']
    p.update(right=x[:3], elbow=[x[3], 0, 0], wrist=x[4:7], weapon=x[7:10],
             left=[-15, -20, -15], leftElbow=[10, 0, 0])
    p['torso'] = row.get('torso', p['torso'])
    return p


def curves(times, poses):
    result = {}
    for ch in channels:
        result[ch] = []
        for axis in range(3):
            values = [p[ch][axis] for p in poses]
            tangent = slopes(times, values)
            result[ch].append([[round(t, 7), round(v, 6), round(m, 6)] for t, v, m in zip(times, values, tangent)])
    return result


clips = []
for combo, (w, a, r) in enumerate([(0.16, .10, .16), (.18, .10, .18), (.26, .12, .24)], 1):
    duration, opening = w+a+r, w*.45
    late = w+a+r*.15
    clip = dict(name=['Knight_Downcut', 'Knight_RisingCut', 'Knight_HorizontalSweep'][combo-1],
                classId='knight', combo=combo, windup=w, active=a, recovery=r,
                hitDelay=0, duration=duration, entryUntil=opening)
    for rig in ['R15', 'R6']:
        original = owned['curves'] if rig == 'R15' else owned['r6Curves']
        if combo < 3:
            ts = [0, opening, w, late, duration]
            old = [0, .117, .26, .416, .62] if combo == 1 else [.62, .416, .26, .117, 0]
            clock = [[t, v, m] for t, v, m in zip(ts, old, slopes(ts, old))]
            times = sorted(set([duration*i/64 for i in range(65)]+ts+[w-.003, w+.003]))
            poses = []
            # Like the dwarf, load the whole body and carry the cut past impact.
            # Corrections vanish around contact, keeping the owned hit unchanged.
            accent_times = [0, opening, w-.02, w+.02, late, duration]
            accents = {
                'torso': [[0, 0, 0], [8, -26, -4], [0, 0, 0], [0, 0, 0], [-8, 28, 4], [0, 8, 0]],
                'right': [[0, 0, 0], [28, -8, -8], [0, 0, 0], [0, 0, 0], [-20, 8, 8], [0, 0, 0]],
            }
            if combo == 2:
                accents = {
                    'torso': [[0, 0, 0], [-8, 26, 4], [0, 0, 0], [0, 0, 0], [8, -28, -4], [0, -8, 0]],
                    'right': [[0, 0, 0], [-20, 8, 8], [0, 0, 0], [0, 0, 0], [28, -8, -8], [0, 0, 0]],
                }
            accent_curves = {ch: [[[t, v[axis], m] for t, v, m in
                zip(accent_times, values, slopes(accent_times, [v[axis] for v in values]))]
                for axis in range(3)] for ch, values in accents.items()}
            times = sorted(set(times+accent_times))
            for t in times:
                p = pose(original, sample(clock, t))
                if combo == 2:
                    start = smooth(t/opening)
                    finish = smooth((t-late)/(duration-late))
                    for ch in channels:
                        p[ch] = [s+(v-s)*start for s, v in zip(rest[ch], p[ch])]
                        p[ch] = [v+(g-v)*finish for v, g in zip(p[ch], guard[ch])]
                # Keep the blade near the next action instead of resetting to guard.
                bridge = pose(original, .416) if combo == 1 else sweep_pose(solved[rig][0])
                for ch in channels:
                    p[ch] = [v+(b-g)*.35*smooth((t-late)/(duration-late)) for v, b, g in zip(p[ch], bridge[ch], guard[ch])]
                for ch, axes in accent_curves.items():
                    weight = .45 if combo == 1 else .7
                    p[ch] = [v+sample(keys, t)*weight for v, keys in zip(p[ch], axes)]
                poses.append(p)
        else:
            rows = solved[rig]
            # A 160-degree horizontal arc with torso rotation crosses contact.
            times = [0, opening, .18, .205, .23, w, .29, .315, .34, late, duration]
            poses = [copy.deepcopy(rest), sweep_pose(rows[0])]+[sweep_pose(row) for row in rows]+[copy.deepcopy(guard), copy.deepcopy(guard)]
        authored = curves(times, poses)
        if combo == 3:
            # Keep angular velocity locally linear through the server contact.
            # The solved arc keys otherwise change acceleration sharply at the
            # impact knot, especially on the rigid R6 arm.
            dense = sorted(set([duration*i/64 for i in range(65)]+times+
                               [w+x for x in [-.024, -.012, -.006, 0, .006, .012, .024]]))
            refined = []
            for t in dense:
                p = {}
                for ch in channels:
                    p[ch] = []
                    for keys in authored[ch]:
                        center = next(k for k in keys if abs(k[0]-w)<1e-7)
                        straight = center[1]+center[2]*(t-w)
                        blend = smooth((abs(t-w)-.006)/.018)
                        p[ch].append(straight+(sample(keys,t)-straight)*blend)
                refined.append(p)
            authored = curves(dense, refined)
        clip['curves' if rig == 'R15' else 'r6Curves'] = authored
    clips.append(clip)


def lua(x):
    if isinstance(x, dict): return '{'+','.join('['+json.dumps(k)+']='+lua(v) for k, v in x.items())+'}'
    if isinstance(x, list): return '{'+','.join(map(lua, x))+'}'
    return json.dumps(x)


names = ['K0KnightReferenceDowncut', 'K0KnightReferenceRisingCut', 'K0KnightReferenceSweep']
outputs = {}
for name, clip in zip(names, clips):
    out = root / 'src/client' / (name+'.luau')
    text = '-- Generated by tools/author-knight-reference-combo.py; owned curves and native FK grips.\nreturn '+lua(clip)+'\n'
    assert len(text.encode()) < 200000
    out.write_text(text)
    outputs[str(out.relative_to(root))] = hashlib.sha256(out.read_bytes()).hexdigest()
index = root / 'src/client/K0KnightReferenceCombo.luau'
index.write_text('-- Basic attacks only; skill variants keep their original clips.\nreturn {'+','.join('require(script.Parent.'+n+')' for n in names)+'}\n')
outputs[str(index.relative_to(root))] = hashlib.sha256(index.read_bytes()).hexdigest()
(folder/'manifest.json').write_text(json.dumps(dict(reference='https://www.youtube.com/watch?v=xUhOca48eLQ&t=145s',
    intervalSeconds=[145, 147], source=str(source.relative_to(root)), sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    outputs=outputs, sequences=['Downcut', 'Rising Cut', 'Horizontal Sweep'], solver='tools/solve-knight-sweep-native.luau',
    finisherInstruction='Broad horizontal slash; supersedes the reference thrust',
    swingInstruction='Dwarf-inspired full-body load and follow-through; 160-degree finisher',
    posesSha256=hashlib.sha256((folder/'sweep-poses.json').read_bytes()).hexdigest()), indent=2)+'\n')
print(index)
