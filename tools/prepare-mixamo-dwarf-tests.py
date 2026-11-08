"""Prepare isolated native QA including Blender's independently evaluated samples."""
import json
import pathlib
import subprocess
import sys
root=pathlib.Path(__file__).resolve().parents[1]
out=pathlib.Path(sys.argv[1] if len(sys.argv)>1 else '/tmp/tlt-mixamo-native')
out.mkdir(parents=True,exist_ok=True)
def lua(x):
    if isinstance(x,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(v)for k,v in x.items())+'}'
    if isinstance(x,list):return '{'+','.join(map(lua,x))+'}'
    return json.dumps(x)
golden=json.loads((root/'assets/animations/mixamo-dwarf-v1/blender-golden.json').read_text())
probe=out/'mixamo-parity.luau'
probe.write_text('do\nlocal mixamoGolden='+lua(golden)+'\n'+(root/'tests/mixamo-dwarf-native.luau').read_text()+'\nend\n')
knight=json.loads((root/'assets/animations/mixamo-knight-v1/blender-golden.json').read_text())
knight_probe=out/'knight-parity.luau'
knight_probe.write_text('do\nlocal knightGolden='+lua(knight)+'\n'+(root/'tests/mixamo-knight-native.luau').read_text()+'\nend\n')
elf=json.loads((root/'assets/animations/mixamo-elf-v1/blender-golden.json').read_text())
elf_probe=out/'elf-parity.luau'
elf_probe.write_text('do\nlocal elfGolden='+lua(elf)+'\n'+(root/'tests/mixamo-elf-native.luau').read_text()+'\nend\n')
legacy_bow=out/'legacy-bow.luau'
legacy_bow.write_text('do\n'+(root/'tests/elf-bow-golden.luau').read_text().replace('\nreturn ','\nlocal BowGolden=',1)+'\n'+(root/'tests/k0-elf-bow-native.luau').read_text()+'\nend\n')
# Independent frozen 0.86.1 poses prove that the full old skill became basic.
baseline=json.loads((root/'assets/animations/mixamo-dwarf-v1/basic-overhead-baseline.json').read_text())
def sample_frozen(keys,t):
    i=max(0,min(len(keys)-2,next((i-1 for i,k in enumerate(keys)if k[0]>t),len(keys)-2)))
    a,b=keys[i:i+2];h=b[0]-a[0];u=max(0,min(1,(t-a[0])/h))
    return (2*u**3-3*u*u+1)*a[1]+(u**3-2*u*u+u)*h*a[2]+(-2*u**3+3*u*u)*b[1]+(u**3-u*u)*h*b[2]
anchors=[]
for rig,curves in [('R15',baseline['curves']),('R6',baseline['r6Curves'])]:
    for age,source in zip([0,.12,.22,.284,.42],[0,baseline['entryUntil'],.71,.875,1.13]):
        angles={ch:[(0 if age==.42 else sample_frozen(axis,source))for axis in axes]for ch,axes in curves.items()}
        anchors.append(dict(rig=rig,age=age,angles=angles))
remap_probe=out/'dwarf-remap.luau'
remap_probe.write_text('do\nlocal previousOverheadAnchors='+lua(anchors)+'\nlocal previousOverheadDuration='+str(baseline['duration'])+'\n'+(root/'tests/dwarf-overhead-remap-native.luau').read_text()+'\nend\n')
subprocess.run(['node','tools/prepare-dwarf-swing-review.mjs',str(out),str(probe),str(remap_probe),str(knight_probe),str(elf_probe),str(legacy_bow),
 'tests/k0-dwarf-motion-native.luau','tests/dwarf-natural-grip-native.luau','tests/dwarf-recovery-native.luau',
 'tests/dwarf-axe-throw-native.luau','tests/k0-melee-blender-native.luau',
 'tests/axe-cutting-edge-native.luau','tests/k0-melee-curves-native.luau',
 'tests/shield-bash-leading-native.luau','tests/k0-skill-animation-native.luau',
 'tests/elf-quiver-native.luau'],cwd=root,check=True)
