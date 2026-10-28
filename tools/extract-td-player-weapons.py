"""Extract exact existing TD tower weapons. Local files only; no upload/build.

python3 tools/extract-td-player-weapons.py --check
python3 tools/extract-td-player-weapons.py --td-root ../throne-defense
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PINS = {
    "assets/models/meshy-factions-refresh-v1/runtime.rbxmx": "8402a11b665bdbe61240e76df62b2a0ca4fd4400ee8e322643f151c00fa6726f",
    "assets/models/hero-weapons-latest-v1/runtime.rbxmx": "53badbcac662bd476b7da58b7a4102f5a0825ecc5015a28e4179ee046c8bb274",
    "assets/models/hero-weapons-latest-v1/runtime-metadata.json": "41bf0fa1d1a929642cfc14ffed9beb3e78a47b18b90ade54542f39d810365712",
}
SPECS = {
    "knight": ("KnightSword", "swordsman", {"Weapon": "130169610186060"}),
    "dwarf": ("DwarfAxe", "axe", {"Weapon": "106045080642382"}),
    "elf": ("ElfBow", "archer", {"Bow": "83795343518288", "String": "108052120766619", "NockedArrow": "77202496614276"}),
}
SOURCE_RECORDS = [
    "assets/models/hero-weapons-latest-v1/existing-wrappers.json",
    "assets/models/hero-weapons-latest-v1/knight/geometry.json",
    "docs/evidence/hero-weapons-latest-v1/privacy-after.json",
    "docs/evidence/hero-weapons-latest-v1/privacy-before.json",
    "docs/evidence/axe-meshy-v1/privacy-checks.json",
    "docs/evidence/meshy-archer/runtime/privacy-all-ui.json",
    "assets/models/meshy-factions-refresh-v1/upload-textures/uploaded.json",
    "docs/evidence/axe-meshy-v1/vivid-color-owner.json",
    "docs/evidence/axe-meshy-v1/vivid-configure.txt",
    "docs/evidence/axe-meshy-v1/vivid-permissions.txt",
]


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def name(item):
    return item.findtext("Properties/string[@name='Name']")


def prop(item, tag, key, value=None):
    properties = item.find("Properties")
    if properties is None:
        properties = ET.SubElement(item, "Properties")
    node = properties.find(f"*[@name='{key}']")
    if node is None:
        node = ET.SubElement(properties, tag, name=key)
    else:
        assert node.tag == tag
        node.clear()
        node.set("name", key)
    if value is not None:
        node.text = str(value)
    return node


def vector(item, key, xyz):
    node = prop(item, "Vector3", key)
    for axis, value in zip("XYZ", xyz):
        ET.SubElement(node, axis).text = repr(float(value))


def frame(item, values):
    node = prop(item, "CoordinateFrame", "CFrame")
    for key, value in zip(["X", "Y", "Z"] + [f"R{i}{j}" for i in range(3) for j in range(3)], values):
        ET.SubElement(node, key).text = repr(float(value))


def value_child(parent, kind, key, value):
    child = ET.SubElement(parent, "Item", {"class": kind})
    prop(child, "string", "Name", key)
    if kind == "Vector3Value":
        vector(child, "Value", value)
    else:
        prop(child, "string", "Value", value)
    return child


def json_bytes(data):
    return (json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode()


def extract(td):
    snapshots = {}
    review_outputs = {}
    for source, expected in PINS.items():
        raw = (td / source).read_bytes()
        assert sha(raw) == expected, f"Source changed; review before reuse: {source}"
        snapshots[source] = raw
    original = ET.fromstring(snapshots["assets/models/hero-weapons-latest-v1/runtime.rbxmx"])
    originals = {name(m): m for m in original.findall("Item/Item[@class='Model']")}
    metadata = json.loads(snapshots["assets/models/hero-weapons-latest-v1/runtime-metadata.json"])
    records = {m["hero"]: m for m in metadata["models"]}
    assert metadata["sourceTowerRuntimeSha256"] == PINS["assets/models/meshy-factions-refresh-v1/runtime.rbxmx"]
    root = ET.Element("roblox", version="4")
    ET.SubElement(root, "External").text = "null"
    ET.SubElement(root, "External").text = "nil"
    folder = ET.SubElement(root, "Item", {"class": "Folder"})
    prop(folder, "string", "Name", "TDPlayerWeaponModels")
    manifest = {
        "schemaVersion": 1, "date": "2026-10-28", "sourceProject": "../throne-defense",
        "status": "local exact-source extraction; TLT native load/hand-contact/permissions not reverified",
        "newUploads": 0, "buildPerformed": False, "published": False,
        "folderName": "TDPlayerWeaponModels", "sourcePins": PINS, "models": [],
        "sourceReviewMeshes": [],
        "attachmentContract": {
            "primaryPart": "Grip", "gripAttachment": "GripSocket", "origin": [0, 0, 0],
            "visibleGeometryPolicy": "Existing TD weapon wrapper MeshPart properties and SurfaceAppearance preserved exactly; only referents regenerated",
            "scalePolicy": "TD wrapper scale, yaw, grip correction already applied. Do not apply them a second time.",
            "runtime": "Clone, PivotTo(hand.CFrame * reviewedHandOffset), unanchor all BaseParts, weld each visible part to Grip, Motor6D/Weld Grip to hand. Keep collision/query/touch off.",
            "handOffset": "No universal R6/R15 hand CFrame certified by this extraction. Verify with actual avatars.",
        },
        "shield": {"source": "TowerModels.swordsman Body", "status": "not included: no standalone existing Shield MeshId verified; source-preserving local extraction is separate", "noSubstitute": True},
        "permissionStatus": "Historical TD evidence preserved; no fresh API/UI inspection or TLT Experience grant verification performed. Full existing Experience grants were not enumerable in source evidence.",
    }
    for hero, (model_name, tower_kind, ids) in SPECS.items():
        source = originals[hero]
        visible = {name(p): p for p in source.findall("Item[@class='MeshPart']")}
        assert set(visible) == set(ids)
        assert all(p.findtext("Properties/Content[@name='MeshId']/url") == "rbxassetid://" + ids[key] for key, p in visible.items())
        assert not any(p.get("class") in {"Script", "LocalScript", "ModuleScript"} for p in source.iter("Item"))
        model = copy.deepcopy(source)
        prop(model, "string", "Name", model_name)
        grip = ET.SubElement(model, "Item", {"class": "Part"})
        prop(grip, "string", "Name", "Grip")
        vector(grip, "size", [0.12, 0.12, 0.12])
        frame(grip, [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1])
        for key, setting in {"Anchored": "true", "Massless": "true", "CanCollide": "false", "CanTouch": "false", "CanQuery": "false", "CastShadow": "false"}.items():
            prop(grip, "bool", key, setting)
        prop(grip, "float", "Transparency", "1")
        attachment = ET.SubElement(grip, "Item", {"class": "Attachment"})
        prop(attachment, "string", "Name", "GripSocket")
        frame(attachment, [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1])
        prop(model, "Ref", "PrimaryPart", "PENDING_GRIP_REF")
        value_child(model, "StringValue", "SourceTowerKind", tower_kind)
        value_child(model, "StringValue", "SourceAssetKey", "td.tower." + tower_kind + ".weapon")
        value_child(model, "Vector3Value", "WeaponTip", records[hero]["markers"]["WeaponTipPosition"])
        folder.append(model)
        record = copy.deepcopy(records[hero])
        record.update({"modelName": model_name, "primaryPart": "Grip", "sourceTowerKind": tower_kind,
                       "reuseMode": "existing exact tower-derived weapon mesh; wrapper-only change",
                       "sourceWrapperNodeSha256": sha(ET.tostring(source)),
                       "sourceGeometry": "assets/models/hero-weapons-latest-v1/" + hero + "/geometry.json"})
        manifest["models"].append(record)
        review_path = "assets/models/hero-weapons-latest-v1/" + hero + "/textured-review.glb"
        review_raw = (td / review_path).read_bytes()
        local_path = "source/" + model_name + "-td-derived-review.glb"
        review_outputs[local_path] = review_raw
        manifest["sourceReviewMeshes"].append({"modelName": model_name, "path": local_path, "sourcePath": review_path,
                                              "sha256": sha(review_raw), "bytes": len(review_raw),
                                              "kind": "byte-identical TD tower-derived weapon-only review model; not original whole tower",
                                              "note": "Review geometry can predate final TD wrapper grip corrections. runtime.rbxmx records the actual adopted wrapper transform."})
    for index, node in enumerate(root.iter("Item")):
        node.set("referent", "TLT_TD_WEAPON_" + str(index))
    for model in folder.findall("Item"):
        grip = next(p for p in model.findall("Item[@class='Part']") if name(p) == "Grip")
        model.find("Properties/Ref[@name='PrimaryPart']").text = grip.get("referent")
    # Compare every original visible property and surface; referents are storage identities only.
    for hero, (model_name, _, _) in SPECS.items():
        result = next(m for m in folder if name(m) == model_name)
        for before in originals[hero].findall("Item[@class='MeshPart']"):
            after = next(p for p in result.findall("Item[@class='MeshPart']") if name(p) == name(before))
            a, b = copy.deepcopy(before), copy.deepcopy(after)
            for tree in [a, b]:
                for el in tree.iter("Item"):
                    el.attrib.pop("referent", None)
            assert ET.tostring(a) == ET.tostring(b), f"Visible geometry changed: {model_name}/{name(before)}"
    ET.indent(root)
    runtime = ET.tostring(root, encoding="utf-8", xml_declaration=True)
    manifest["runtimeSha256"] = sha(runtime)
    manifest["files"] = {"runtime": {"path": "assets/shared/td-player-weapons/runtime.rbxmx", "sha256": sha(runtime)}}
    manifest["provenance"] = {"runtime_top_level_folder": "TDPlayerWeaponModels", "source_project": "../throne-defense"}
    manifest["validation"] = {"models": 3, "visibleMeshParts": 5, "grips": 3, "originalVisiblePropertiesExact": True, "scripts": 0, "freshNativeTests": False}
    provenance = {"schemaVersion": 1, "sourceRecords": [], "limitations": manifest["permissionStatus"]}
    for path in SOURCE_RECORDS:
        raw = (td / path).read_bytes()
        data = json.loads(raw) if path.endswith(".json") else raw.decode()
        if path.endswith("upload-textures/uploaded.json"):
            data = {"owner": data["owner"], "models": [m for m in data["models"] if m["key"] == "swordsman"]}
        provenance["sourceRecords"].append({"sourcePath": path, "sha256": sha(raw), "record": data})
    return {"runtime.rbxmx": runtime, "manifest.json": json_bytes(manifest), "provenance.json": json_bytes(provenance), **review_outputs}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--td-root", type=Path, default=ROOT.parent / "throne-defense")
    parser.add_argument("--output", type=Path, default=ROOT / "assets/shared/td-player-weapons")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs = extract(args.td_root.resolve())
    if args.check:
        for filename, raw in outputs.items():
            assert (args.output / filename).read_bytes() == raw, "Output changed: " + filename
    else:
        args.output.mkdir(parents=True, exist_ok=True)
        for filename, raw in outputs.items():
            (args.output / filename).parent.mkdir(parents=True, exist_ok=True)
            (args.output / filename).write_bytes(raw)
    print(json.dumps({"mode": "check" if args.check else "extract", "models": [v[0] for v in SPECS.values()], "visibleMeshParts": 5, "runtimeSha256": sha(outputs["runtime.rbxmx"]), "newUploads": 0, "nativeValidation": "pending"}))


if __name__ == "__main__":
    main()
