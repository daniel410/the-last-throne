"""Verify the Selene upload candidate against the pinned, intact TD surface."""
from pathlib import Path
from collections import Counter
import hashlib, json, math, struct

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / 'assets/animations/selene-repair-v1'

def read(path):
    raw = path.read_bytes()
    assert raw[:4] == b'glTF'
    size = struct.unpack_from('<I', raw, 12)[0]
    return json.loads(raw[20:20+size]), raw[28+size:]

def accessor(document, binary, index):
    a = document['accessors'][index]
    v = document['bufferViews'][a['bufferView']]
    fmt = {5126:'f', 5121:'B', 5123:'H', 5125:'I'}[a['componentType']]
    width = {'SCALAR':1,'VEC2':2,'VEC3':3,'VEC4':4,'MAT4':16}[a['type']]
    size = struct.calcsize(fmt) * width
    return [struct.unpack_from('<'+fmt*width, binary,
        v.get('byteOffset',0)+a.get('byteOffset',0)+i*v.get('byteStride',size))
        for i in range(a['count'])]

def surfaces(document, binary):
    result = Counter()
    for mesh_index,mesh in enumerate(document['meshes']):
        node = next(n for n in document['nodes'] if n.get('mesh') == mesh_index)
        assert not node.get('rotation') and not node.get('matrix') and not node.get('scale')
        offset = node.get('translation',[0,0,0])
        for p in mesh['primitives']:
            pos = accessor(document,binary,p['attributes']['POSITION'])
            uv = accessor(document,binary,p['attributes']['TEXCOORD_0'])
            indices = accessor(document,binary,p['indices'])
            for start in range(0,len(indices),3):
                face = [tuple(round(x,4) for x in tuple(p+o for p,o in zip(pos[indices[i][0]],offset))+uv[indices[i][0]]) for i in range(start,start+3)]
                # Vertex/index order may change on a Blender round trip.
                result[tuple(sorted(face))] += 1
    return result

def textures(document, binary):
    hashes = []
    for image in document['images']:
        v = document['bufferViews'][image['bufferView']]
        start = v.get('byteOffset',0)
        hashes.append(hashlib.sha256(binary[start:start+v['byteLength']]).hexdigest())
    return sorted(hashes)

source = FOLDER/'source-rest.glb'
candidate = FOLDER/'Selene-repaired.glb'
assert hashlib.sha256(source.read_bytes()).hexdigest() == '343aa570e5cc459a3b3896ca1c5c6c31103b4b82a5305dc9459883a0f31cce9e'
sd,sb = read(source)
d,b = read(candidate)
assert len(d['meshes']) == 3 and len(d['skins']) == 1
assert len(d['skins'][0]['joints']) == 15
assert not d.get('animations'), 'Runtime motion is procedural; do not upload imported animation tracks'
before,after = surfaces(sd,sb),surfaces(d,b)
assert before == after, ('Rest surface/UV changed',sum((before-after).values()),sum((after-before).values()))
assert sum(after.values()) == 2989
assert textures(sd,sb) == textures(d,b), 'Embedded TD texture changed'
vertices = 0
for mesh in d['meshes']:
    for p in mesh['primitives']:
        a = p['attributes']
        weights = accessor(d,b,a['WEIGHTS_0'])
        joints = accessor(d,b,a['JOINTS_0'])
        for w,j in zip(weights,joints):
            assert all(math.isfinite(x) and 0 <= x <= 1 for x in w)
            assert abs(sum(w)-1) < 1e-5
            assert all(0 <= x < 15 for x in j)
        vertices += len(weights)
report = dict(workId='TLT-016/057/061/072/084', stage='GLB authoring validation; runtime status is recorded separately',
    sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    candidateSha256=hashlib.sha256(candidate.read_bytes()).hexdigest(),
    bytes=candidate.stat().st_size,meshes=3,bones=15,triangles=sum(after.values()),vertices=vertices,
    restSurfaceAndUVPreserved=True,surfaceComparisonDecimalPlaces=4,normalizedWeights=True,animationTracks=0,
    sourceTextureSha256=textures(sd,sb),candidateTextureSha256=textures(d,b))
(FOLDER/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
