"""Author refreshed undead presentation without altering server clocks or TD assets.

Writes two-species key data and a standalone Blender evaluator in /tmp. Run the
evaluator with Blender, then tools/apply-undead-motion.py to export the result.
"""
from pathlib import Path
import copy
import json
import math

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/animations/haunted-graveyard-v1'
keys = json.loads((BASE / 'authoring-keys.json').read_text())
keys['models'] = {kind: keys['models'][kind] for kind in ['Zombie', 'Ghoul']}

def pose(pitch=0, yaw=0, roll=0, reach=0, weapon=0, off=0, weapon_yaw=0, off_yaw=0):
    return {'body': [0, 0, reach, pitch, yaw, roll, 1, 1, 1],
            'weapon': [weapon, weapon_yaw, 0], 'off': [off, off_yaw, 0],
            'rightLeg': [0, 0, 0], 'leftLeg': [0, 0, 0]}

def gait(t, amplitude):
    t %= 1
    return amplitude*(1-2*t/.6) if t < .6 else -amplitude*math.cos(math.pi*(t-.6)/.4)

for kind, model in keys['models'].items():
    zombie = kind == 'Zombie'
    amplitude = 14 if zombie else 18
    lever = (model['pivots']['LegL'][1] + model['pivots']['LegR'][1])/2
    model.update(rigidArms=False, stride=round(2*lever*math.sin(math.radians(amplitude))/.6, 6),
                 breathSeconds=3.2 if zombie else 2.0,
                 motionRevision='undead-individual-v2', armLimitRadians=.1 if zombie else .08)
    model['clips'] = {}
    for clip in ['Idle', 'Walk', 'Attack', 'AttackAlt', 'Heavy', 'HeavyAlt', 'Stunned']:
        attack = clip.startswith(('Attack', 'Heavy'))
        heavy = clip.startswith('Heavy')
        side = -1 if clip.endswith('Alt') else 1
        phases = [0, .18, .4, .5, .55, .62, .69, .78, .9, 1] if attack else sorted(set([i/16 for i in range(17)]+[.1, .5, .6]))
        rows = []
        for t in phases:
            wave = math.sin(t*math.tau)
            p = pose(weapon=1.5 if zombie else 0, off=.5 if zombie else 0)
            if clip == 'Idle':
                p = pose(pitch=.3*wave, yaw=(.35 if zombie else .6)*wave,
                         roll=.15*wave, weapon=(1.5 if zombie else 0)+.35*wave,
                         off=(.5 if zombie else 0)-.3*wave)
            elif clip == 'Walk':
                right, left = gait(t, amplitude), gait(t+.5, amplitude)
                p = pose(pitch=(.7 if zombie else .5)*math.cos(t*math.tau*2),
                         yaw=(1.2 if zombie else 1.8)*wave, roll=(.55 if zombie else .35)*wave,
                         weapon=(1.5 if zombie else 0)+right*(.13 if zombie else .16),
                         off=(.5 if zombie else 0)+left*(.13 if zombie else .16))
                p['rightLeg'] = [right, 0, 0]
                p['leftLeg'] = [left, 0, 0]
            elif clip == 'Stunned':
                p = pose(pitch=2+.4*wave, yaw=.6*wave, roll=.5*wave,
                         weapon=2+.4*wave, off=1-.4*wave)
            else:
                # Preparation grows before the contact at .62, with a distinct
                # settle and recovery. Endpoints match the resting guard.
                weight = {0:0, .18:.25, .4:1, .5:1, .55:.94, .62:-1, .69:-1.05, .78:-.65, .9:-.12, 1:0}[t]
                prep = max(0, weight)
                hit = max(0, -weight)
                if zombie:
                    p = pose(pitch=(3.4 if heavy else 2.4)*prep-(5.0 if heavy else 3.5)*hit,
                             yaw=side*(1.2 if heavy else 3.0)*weight,
                             roll=side*.35*weight,
                             reach=(.026 if heavy else .014)*prep-(.065 if heavy else .038)*hit,
                             weapon=1.5-5.4*prep+3.7*hit,
                             off=.5-3.5*prep+3.5*hit,
                             weapon_yaw=side*.65*weight, off_yaw=-side*.45*weight)
                elif heavy:
                    p = pose(pitch=4.0*prep+.9*hit, yaw=side*1.0*weight,
                             reach=.024*prep-.065*hit,
                             weapon=-3.3*prep+3.1*hit, off=-3.3*prep+3.1*hit,
                             weapon_yaw=side*.35*weight, off_yaw=-side*.35*weight)
                else:
                    p = pose(pitch=3.0*prep+.25*hit, yaw=side*7.5*weight,
                             roll=side*.5*weight, reach=.012*prep-.032*hit,
                             weapon=-3.8*prep+3.6*hit, off=2.8*prep-2.4*hit,
                             weapon_yaw=side*.65*weight, off_yaw=-side*.6*weight)
                    if side < 0:
                        p['weapon'], p['off'] = p['off'], p['weapon']
            rows.append([t, p])
        model['clips'][clip] = rows

out = Path('/tmp/tlt-undead-motion-keys.json')
out.write_text(json.dumps(keys, separators=(',', ':'))+'\n')
author = (ROOT / 'tools/author-haunted-motion-blender.py').read_text()
script = 'import json\nMOTION_KEYS=json.loads('+repr(out.read_text())+')\n'+author
script += "\nfrom pathlib import Path\nPath('/tmp/tlt-undead-motion-evaluated.json').write_text(json.dumps(result,separators=(',',':'))+'\\n')\n"
Path('/tmp/tlt-undead-author-blender.py').write_text(script)
print('Prepared two species / seven individual clips; evaluate with Blender.')
