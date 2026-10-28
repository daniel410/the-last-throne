"""Package the approved exact Swordsman shield mesh without uploading/building.

python3 tools/build-td-shield-runtime.py
python3 tools/build-td-shield-runtime.py --check

Inputs are the preserved source-extraction-manifest.json and native-upload.json.
The native -Z front is an observed importer result, not the GLB +Z contract.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "assets/shared/td-player-weapons/shield"
EXPECTED_SOURCE_SHA = "151ad5b6075705e2e7b6f9bb7877e0c6aa1c21627b9eeaff4ccfd7eeadf7dce3"
IDENTITY = [1, 0, 0, 0, 1, 0, 0, 0, 1]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def prop(item, tag, name, text=None):
    properties = item.find("Properties")
    if properties is None:
        properties = ET.SubElement(item, "Properties")
    node = ET.SubElement(properties, tag, name=name)
    if text is not None:
        node.text = str(text)
    return node


def vector(item, name, values):
    node = prop(item, "Vector3", name)
    for axis, value in zip("XYZ", values):
        ET.SubElement(node, axis).text = repr(float(value))


def cframe(item, values):
    node = prop(item, "CoordinateFrame", "CFrame")
    for key, value in zip(["X", "Y", "Z"] + [f"R{i}{j}" for i in range(3) for j in range(3)], values):
        ET.SubElement(node, key).text = repr(float(value))


def marker(model, kind, name, value):
    child = ET.SubElement(model, "Item", {"class": kind})
    prop(child, "string", "Name", name)
    if kind == "Vector3Value":
        vector(child, "Value", value)
    else:
        prop(child, "string", "Value", value)


def outputs(base):
    source_bytes = (base / "source-extraction-manifest.json").read_bytes()
    source = json.loads(source_bytes)
    native_bytes = (base / "native-upload.json").read_bytes()
    native = json.loads(native_bytes)
    assert sha((base / "shield-mesh-only.glb").read_bytes()) == EXPECTED_SOURCE_SHA
    assert source["files"]["shield-mesh-only.glb"]["sha256"] == EXPECTED_SOURCE_SHA
    assert source["triangles"] == 550 and source["sourceIslandIds"] == [49, 1195]
    assert native["meshId"] == "rbxassetid://86935256146675"
    assert native["textureId"] == source["textureId"] == "rbxassetid://97596525220590"
    assert native["sourceMeshSha256"] == EXPECTED_SOURCE_SHA
    assert native["assetTypeId"] == 4 and native["reportedFaces"] == 550
    assert native["nativeContract"]["front"] == [0, 0, -1]
    assert native["nativeContract"]["rotationRowMajor"] == IDENTITY
    assert native["authorization"]["scope"] == "one exact Swordsman shield mesh; Restricted; current user account"
    assert native["verification"]["restricted"] is True
    assert native["uploaderAccount"]["exactCreatorId"] == 9156786071
    assert native["verification"]["creatorTargetId"] == 9156786071
    assert native["verification"]["newImagesUploaded"] == 0
    size = native["meshSize"]
    authored_size = source["parts"][0]["size"]
    assert len(size) == 3 and all(abs(a - b) < 2e-6 for a, b in zip(size, authored_size))
    native_cf = native["nativeContract"]["centerFromGrip"] + IDENTITY
    assert native_cf[2] < 0 and abs(native_cf[2] + source["parts"][0]["localCF"][2]) < 1e-8
    root = ET.Element("roblox", version="4")
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"
    folder = ET.SubElement(root, "Item", {"class": "Folder"})
    prop(folder, "string", "Name", "TDKnightShieldModels")
    model = ET.SubElement(folder, "Item", {"class": "Model"})
    prop(model, "string", "Name", "KnightShield")
    primary = prop(model, "Ref", "PrimaryPart", "PENDING")
    grip = ET.SubElement(model, "Item", {"class": "Part"})
    prop(grip, "string", "Name", "Grip")
    vector(grip, "size", [0.12, 0.12, 0.12])
    cframe(grip, [0, 0, 0] + IDENTITY)
    for key, value in {"Anchored": "true", "Massless": "true", "CanCollide": "false", "CanTouch": "false", "CanQuery": "false", "CastShadow": "false"}.items():
        prop(grip, "bool", key, value)
    prop(grip, "float", "Transparency", "1")
    socket = ET.SubElement(grip, "Item", {"class": "Attachment"})
    prop(socket, "string", "Name", "GripSocket")
    cframe(socket, [0, 0, 0] + IDENTITY)
    shield = ET.SubElement(model, "Item", {"class": "MeshPart"})
    prop(shield, "string", "Name", "Shield")
    for key in ["MeshId", "TextureID"]:
        value = native["meshId"] if key == "MeshId" else native["textureId"]
        ET.SubElement(prop(shield, "Content", key), "url").text = value
    vector(shield, "size", size)
    vector(shield, "InitialSize", size)
    cframe(shield, native_cf)
    for key, value in {"Anchored": "true", "Massless": "true", "CanCollide": "false", "CanTouch": "false", "CanQuery": "false", "CastShadow": "true", "DoubleSided": "true"}.items():
        prop(shield, "bool", key, value)
    prop(shield, "Color3uint8", "Color3uint8", 16777215)
    prop(shield, "token", "Material", 272)
    prop(shield, "token", "RenderFidelity", 0)
    prop(shield, "float", "Transparency", 0)
    marker(model, "StringValue", "SourceTowerKind", "swordsman")
    marker(model, "StringValue", "SourceAssetKey", "td.tower.swordsman.shield")
    marker(model, "StringValue", "SourceMeshSha256", EXPECTED_SOURCE_SHA)
    marker(model, "Vector3Value", "ShieldFront", [0, 0, -1])
    marker(model, "Vector3Value", "ShieldCenterFromGrip", native["nativeContract"]["centerFromGrip"])
    for index, node in enumerate(root.iter("Item")):
        node.set("referent", "TLT_TD_SHIELD_" + str(index))
    primary.text = grip.get("referent")
    ET.indent(root)
    runtime = ET.tostring(root, encoding="utf-8", xml_declaration=True)
    assert len(root.findall(".//Item[@class='MeshPart']")) == 1
    assert len(root.findall(".//Item[@class='Part']")) == 1
    assert not any(node.get("class") in {"Script", "LocalScript", "ModuleScript"} for node in root.iter("Item"))
    manifest = copy.deepcopy(source)
    manifest.update({
        "meshId": native["meshId"], "modelId": None,
        "status": "UPLOADED EXACT SHIELD MESH; LOCAL RUNTIME TEMPLATE PREPARED; TLT INTEGRATION/DEVICE ACCEPTANCE PENDING",
        "coordinateContract": "SOURCE GLB: +Z front/Y up/back-center origin. NATIVE ASSET: -Z front/Y up; Shield local center Z=-0.2485014851004278, identity rotation; Grip remains at origin. Do not apply a second Y180 correction.",
        "sourceCoordinateContract": source["coordinateContract"],
        "sourceParts": source["parts"],
        "parts": [{"name": "Shield", "meshId": native["meshId"], "textureId": native["textureId"],
                   "size": size, "initialSize": size, "cf": native_cf, "triangles": 550,
                   "front": [0, 0, -1], "grip": [0, 0, 0], "coordinateStage": "actual native asset template"}],
        "sourceExtractionManifest": {"path": "source-extraction-manifest.json", "sha256": sha(source_bytes)},
        "nativeUploadRecord": {"path": "native-upload.json", "sha256": sha(native_bytes)},
        "runtimeContract": {"folder": "TDKnightShieldModels", "model": "KnightShield", "primaryPart": "Grip",
                            "visiblePart": "Shield", "socket": "Grip/GripSocket", "grip": [0, 0, 0],
                            "meshSize": size, "size": size, "shieldCFrame": native_cf, "shieldFront": [0, 0, -1],
                            "material": "SmoothPlastic (same source material token272)", "color": "white; original ColorMap via TextureID",
                            "surfaceAppearance": "none", "templateAnchored": True,
                            "attach": "Pivot model by Grip, unanchor both parts, weld Shield to Grip, attach Grip to reviewed left-hand offset. Collision/query/touch remain off."},
        "authorization": native["authorization"], "nativeVerification": native["verification"],
        "uploaderAccount": native["uploaderAccount"],
        "permissionEvidence": "native-upload.json records Director-reported actual Dashboard Restricted selection and GetProductInfo/current-user checks; source image historical records remain in ../provenance.json. This builder independently checks files/XML only.",
        "requiredNativeStep": "No further upload required for this mesh. Verify final TLT left-hand contact/lifecycle and source/asset permission evidence; no default.project.json change is made by this builder.",
        "provenance": {"runtime_top_level_folder": "TDKnightShieldModels", "source_project": "../throne-defense",
                       "sourceShape": "exact source islands49+1195; source UV/face provenance retained",
                       "newAsset": "one shield Mesh, not a replacement tower/avatar/model package"},
    })
    manifest["files"]["runtime"] = {"path": "assets/shared/td-player-weapons/shield/runtime.rbxmx", "sha256": sha(runtime), "bytes": len(runtime)}
    manifest["validation"] = {
        "sourceExtractionOnly": copy.deepcopy(source["validation"]),
        "sourceExtractionScope": "The nested cpuRenderOnly/studioOrDeviceValidation flags describe the earlier local GLB extraction stage only, before approved mesh upload. They are not the current native verification result.",
        "runtimeStatic": {"models": 1, "meshParts": 1, "grips": 1, "scripts": 0,
                          "nativeSizeMatchesSourceWithin2e-6": True, "templateHasNoSurfaceAppearanceOrNewImage": True,
                          "builderPerformedStudioOrDeviceValidation": False},
        "nativeStudio": {"status": "Director verified actual Studio native render and asset preload", "front": [0, 0, -1],
                         "sourceUvAndColor": "normal; source star visible from -Z", "meshPreload": "Success", "texturePreload": "Success",
                         "evidencePaths": native["verification"].get("evidencePaths", []), "checkedByThisBuilder": False},
        "device": {"status": "not tested", "mobileFpsMemory": "unverified", "checkedByThisBuilder": False},
        "tltGameplayIntegration": {"status": "pending independent fixture/hand-contact/lifecycle checks; not completed by this builder"},
    }
    return {"runtime.rbxmx": runtime, "manifest.json": (json.dumps(manifest, ensure_ascii=False, indent=2) + "\n").encode()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    result = outputs(args.base)
    for filename, data in result.items():
        path = args.base / filename
        if args.check:
            assert path.read_bytes() == data, "Output changed: " + filename
        else:
            path.write_bytes(data)
    print(json.dumps({"mode": "check" if args.check else "package", "runtimeSha256": sha(result["runtime.rbxmx"]),
                      "models": 1, "visibleMeshParts": 1, "scripts": 0, "meshId": "86935256146675", "newUploadsByBuilder": 0}))


if __name__ == "__main__":
    main()
