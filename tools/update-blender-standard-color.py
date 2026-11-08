"""Run with Blender --background --python this_file -- manifest.json.

Manifest entries contain source and output. Only color-management properties change;
source/output may differ to preserve dirty files and shared TD originals.
"""
import bpy
import hashlib
import json
import sys
from pathlib import Path


def settings(scene):
    return dict(display=scene.display_settings.display_device,
                view=scene.view_settings.view_transform, look=scene.view_settings.look,
                exposure=scene.view_settings.exposure, gamma=scene.view_settings.gamma,
                curves=scene.view_settings.use_curve_mapping)


def standard(scene):
    scene.display_settings.display_device = 'sRGB'
    scene.view_settings.view_transform = 'Standard'
    scene.view_settings.look = 'None'
    scene.view_settings.exposure = 0
    scene.view_settings.gamma = 1
    scene.view_settings.use_curve_mapping = False


def fingerprint():
    # Core content is compared in memory before/after. View settings are excluded.
    h = hashlib.sha256()
    def add(value):
        h.update(repr(value).encode())
    for mesh in bpy.data.meshes:
        add((mesh.name, len(mesh.vertices), len(mesh.polygons)))
        for v in mesh.vertices:
            add(tuple(v.co))
        for p in mesh.polygons:
            add(tuple(p.vertices))
    for obj in bpy.data.objects:
        add((obj.name, obj.type, tuple(tuple(r) for r in obj.matrix_local)))
    for mat in bpy.data.materials:
        add((mat.name, tuple(mat.diffuse_color), mat.use_nodes))
        if mat.use_nodes:
            for n in mat.node_tree.nodes:
                add((n.name, n.type))
                for socket in n.inputs:
                    if hasattr(socket, 'default_value'):
                        value = socket.default_value
                        add(tuple(value) if hasattr(value, '__len__') and not isinstance(value, str) else value)
    for action in bpy.data.actions:
        add((action.name, tuple(action.frame_range)))
    return h.hexdigest()


def main():
    manifest_path = Path(sys.argv[sys.argv.index('--') + 1])
    spec = json.loads(manifest_path.read_text())
    results = []
    for item in spec['files']:
        source, output = Path(item['source']), Path(item['output'])
        source_sha = hashlib.sha256(source.read_bytes()).hexdigest()
        bpy.ops.wm.open_mainfile(filepath=str(source))
        before = {s.name: settings(s) for s in bpy.data.scenes}
        core = fingerprint()
        for scene in bpy.data.scenes:
            standard(scene)
        assert core == fingerprint(), 'Content changed outside display settings'
        after = {s.name: settings(s) for s in bpy.data.scenes}
        changed = before != after or source != output
        if changed:
            output.parent.mkdir(parents=True, exist_ok=True)
            # Preserve any existing .blend1 backups; no preference file is saved.
            bpy.context.preferences.filepaths.save_version = 0
            bpy.ops.wm.save_as_mainfile(filepath=str(output))
            bpy.ops.wm.open_mainfile(filepath=str(output))
            assert after == {s.name: settings(s) for s in bpy.data.scenes}
            # Blender may drop unreferenced datablocks on save; record this separately.
        results.append(dict(source=str(source), output=str(output), sourceSha256=source_sha,
                            outputSha256=hashlib.sha256(output.read_bytes()).hexdigest(),
                            changed=changed, before=before, after=after,
                            contentFingerprint=core, savedContentFingerprint=fingerprint(),
                            inMemoryContentPreserved=True, roundTripSettingsPassed=True))
        Path(spec['report']).write_text(json.dumps(results, indent=2) + '\n')
        print('STANDARD_COLOR', output.name, len(before), 'scenes; content preserved', flush=True)


if __name__ == '__main__':
    main()
