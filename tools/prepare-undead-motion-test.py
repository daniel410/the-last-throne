"""Inject immutable refreshed mesh vertices into a local-only engine probe."""
from pathlib import Path
import hashlib
import importlib.util
import json
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('mesh', ROOT/'tools/repair-deepwood-weapons.py')
mesh=importlib.util.module_from_spec(spec);spec.loader.exec_module(mesh)
sources=json.loads((ROOT/'assets/animations/haunted-graveyard-v1/source-models.json').read_text())
data={}
for kind in ['Zombie','Ghoul']:
    path=ROOT.parent/'throne-defense'/sources[kind]['tdPath']
    assert hashlib.sha256(path.read_bytes()).hexdigest()==sources[kind]['sha256']
    data[kind]={}
    for name,faces in mesh.read(path).items():
        points=set(tuple(v[0]) for face in faces for v in face)
        lo=[min(p[i] for p in points) for i in range(3)]
        hi=[max(p[i] for p in points) for i in range(3)]
        data[kind][name.split('.')[0].split('__')[-1]]=[[(p[i]-(lo[i]+hi[i])/2)/(hi[i]-lo[i])*(-1 if i!=1 else 1) for i in range(3)] for p in sorted(points)]
prefix="game.ServerScriptService.Server.Disabled=true\ngame.StarterPlayer.StarterPlayerScripts.Client.Disabled=true\n"
prefix+="_G.TLTUndeadSurfacePoints=game.HttpService:JSONDecode([==["+json.dumps(data,separators=(',',':'))+"]==])\n"
probe=prefix+(ROOT/'tests/undead-motion-native.luau').read_text()
Path('/tmp/tlt-undead-motion-surface-probe.luau').write_text(probe)
print('Injected pinned source vertices; probe /tmp/tlt-undead-motion-surface-probe.luau')
