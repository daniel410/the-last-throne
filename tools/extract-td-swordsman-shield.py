"""Preserve exact Swordsman shield islands as a local, unuploaded candidate.

Requires NumPy/Pillow already available in the bundled workspace Python.
Imports reviewed read-only geometry helpers from the sibling TD checkout and pins
the input source. No Studio/API call, upload, build, or commit occurs.
"""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
SOURCE_PINS = {
    "assets/models/meshy-factions-refresh-v1/runtime.rbxmx": "8402a11b665bdbe61240e76df62b2a0ca4fd4400ee8e322643f151c00fa6726f",
    "assets/models/meshy-factions-refresh-v1/derived/swordsman/rest.glb": "cee73ede7abe099b5b1f5cbd63753765e500a37942cbe61a5beccf632172d0fa",
    "assets/models/meshy-factions-refresh-v1/review/swordsman/source-inspection.json": "dd2fe01d220570eb89b526d49349963ec45ee1b13d07c423025c5c333edcf64a",
    "assets/models/meshy-factions-refresh-v1/derived/swordsman/ColorMap.png": "fe40c700491df87c77ed881fa58e9cf631cb04357a917d918f9f71e4c85c4a91",
}
ISLAND_IDS = [49, 1195]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def main():
    import numpy as np
    from PIL import Image

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--td-root", type=Path, default=ROOT.parent / "throne-defense")
    parser.add_argument("--output", type=Path, default=ROOT / "assets/shared/td-player-weapons/shield")
    args = parser.parse_args()
    td, output = args.td_root.resolve(), args.output.resolve()
    for path, digest in SOURCE_PINS.items():
        assert sha((td / path).read_bytes()) == digest, "Source changed: " + path
    helper = td / "tools/prepare-hero-weapons.py"
    spec = importlib.util.spec_from_file_location("td_shield_readonly", helper)
    core = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(core)
    faces, metadata = core.current("swordsman")
    groups = json.loads((td / "assets/models/meshy-factions-refresh-v1/review/swordsman/source-inspection.json").read_text())["islands"]
    source_ids = {face_id for group in groups if group["id"] in ISLAND_IDS for face_id in group["sourceFaces"]}
    selected = [face for face in faces if face[1] in source_ids]
    assert len(source_ids) == len(selected) == 550
    # Each original source face occurs once; no cap, body/hand, or invented face.
    assert len({face[1] for face in selected}) == 550
    source = core.arrays(selected)
    plate_ids = set(next(g["sourceFaces"] for g in groups if g["id"] == 49))
    emblem_ids = set(next(g["sourceFaces"] for g in groups if g["id"] == 1195))
    plate = np.unique(core.arrays([face for face in selected if face[1] in plate_ids])["positions"], axis=0)
    emblem = np.unique(core.arrays([face for face in selected if face[1] in emblem_ids])["positions"], axis=0)
    # A proper rigid rotation gives a Y-up shield with its authored front +Z.
    center = plate.mean(0)
    _, eigvec = np.linalg.eigh(np.cov((plate - center).T))
    front = eigvec[:, 0]
    if np.dot(front, emblem.mean(0) - center) < 0:
        front = -front
    up = np.array([0., 1., 0.])
    up -= front * np.dot(front, up)
    up /= np.linalg.norm(up)
    right = np.cross(up, front)
    basis = np.array([right, up, front]).T
    assert abs(np.linalg.det(basis) - 1) < 1e-10
    projected = (source["positions"] - center) @ basis
    lo, hi = projected.min(0), projected.max(0)
    # The socket is the geometric back-center, not a newly invented handle.
    contact_in_basis = np.array([(lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2, lo[2]])
    grip = center + basis @ contact_in_basis
    scale = metadata["targetHeight"]
    position = (source["positions"] - grip) @ basis * scale
    normal = source["normals"] @ basis
    transformed = {"positions": position, "normals": normal, "uvs": source["uvs"], "faces": source["faces"]}
    result_faces = [([(position[j], normal[j], source["uvs"][j]) for j in triangle], origin)
                    for triangle, (_, origin) in zip(source["faces"], selected)]
    output.mkdir(parents=True, exist_ok=True)
    texture_path = td / "assets/models/meshy-factions-refresh-v1/derived/swordsman/ColorMap.png"
    texture = texture_path.read_bytes()
    records, mesh_sha = core.core.geometry.write_glb(output / "shield-mesh-only.glb", {"Shield": result_faces})
    core.core.geometry.write_glb(output / "shield-textured-review.glb", {"Shield": result_faces}, texture)
    (output / "ColorMap.png").write_bytes(texture)
    serialized = core.arrays(core.read(output / "shield-textured-review.glb")["Shield"]["faces"])
    assert np.array_equal(serialized["uvs"].astype(np.float32), source["uvs"].astype(np.float32))
    assert np.array_equal(serialized["normals"].astype(np.float32), normal.astype(np.float32))
    serialized_position_error = float(np.max(np.abs(serialized["positions"] - position)))
    inverse_error = float(np.max(np.abs(position / scale @ basis.T + grip - source["positions"])))
    assert inverse_error < 1e-12 and serialized_position_error < 2e-7
    rgb = np.array(Image.open(texture_path).convert("RGB"))
    for view, direction in [("front", (0, .01, 1)), ("three-quarter", (2, .5, 4)), ("back", (0, .01, -1)), ("side", (1, .01, 0))]:
        core.raster.raster_arrays(transformed, rgb, output / (view + ".png"), direction, size=900)
    helper_files = ["tools/prepare-hero-weapons.py", "tools/prepare-meshy-factions-refresh.py", "tools/blockify-meshy-factions.py"]
    manifest = {
        "schemaVersion": 1, "date": "2026-10-28", "assetKey": "td.tower.swordsman.shield",
        "sourceProject": "../throne-defense", "sourceTowerKind": "swordsman",
        "sourceRuntimePart": "TowerModels.swordsman.Body (shield surfaces merged into body mesh)",
        "sourcePins": SOURCE_PINS, "helperPins": {path: sha((td / path).read_bytes()) for path in helper_files},
        "reuseMode": "exact source-surface extraction; proper rigid rotation plus uniform original body scale; no remodeling",
        "sourceIslandIds": ISLAND_IDS, "sourceFaceIds": [face[1] for face in selected],
        "sourceOriginalModel": "assets/models/meshy-factions-refresh-v1/source/01a1759f-3784-71c6-b0ab-559c2c729b7a.glb",
        "sourceOriginalSha256": "6bfa887b002278f8a8603f5aa0e7c46d6ad01dca491336dab33a0d5c6bde8b47",
        "triangles": 550, "newFaces": 0, "sourceGrip": grip.tolist(),
        "sourceToShieldBasisColumns": basis.tolist(), "uniformScale": scale,
        "coordinateContract": "Y up; +Z authored shield front; socket at local0,0,0 geometric back-center; geometry in studs",
        "gripPolicy": "Back-center contact plane inferred from exact shield surface bounds. No separate authored handle is present in the selected source islands. Native left-hand/forearm contact acceptance pending.",
        "parts": records, "boundsMin": position.min(0).tolist(), "boundsMax": position.max(0).tolist(),
        "textureId": "rbxassetid://97596525220590", "textureSha256": sha(texture), "textureDimensions": [1024, 1024],
        "meshId": None, "modelId": None, "status": "LOCAL SOURCE-PRESERVING CANDIDATE; NOT UPLOADED; NOT INTEGRATED",
        "requiredNativeStep": "Import shield-mesh-only.glb as a new user-owned Restricted mesh; record actual MeshId/MeshSize/CFrame and permissions. Reuse existing ColorMap97596525220590. Never reuse the merged Body MeshId as if it were shield-only.",
        "permissionEvidence": "../provenance.json (historical original image/source TD records; no new Mesh permission exists yet)",
        "validation": {"sourceFacesExactlyOnce": True, "noBodyOrHandIslands": True, "sourceUVFloat32Exact": True,
                       "rotatedNormalFloat32Exact": True, "properRotationDeterminant": float(np.linalg.det(basis)),
                       "inversePositionMaxError": inverse_error, "serializedPositionMaxError": serialized_position_error,
                       "cpuRenderOnly": True, "studioOrDeviceValidation": False},
    }
    files = ["shield-mesh-only.glb", "shield-textured-review.glb", "ColorMap.png", "front.png", "three-quarter.png", "back.png", "side.png"]
    manifest["files"] = {filename: {"sha256": sha((output / filename).read_bytes()), "bytes": (output / filename).stat().st_size} for filename in files}
    assert manifest["files"]["shield-mesh-only.glb"]["sha256"] == mesh_sha
    # Keep source reproduction separate from later native upload/adoption records.
    (output / "source-extraction-manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"triangles": 550, "meshOnlySha256": mesh_sha, "parts": records, "inversePositionMaxError": inverse_error, "serializedPositionMaxError": serialized_position_error, "newUploads": 0}))


if __name__ == "__main__":
    main()
