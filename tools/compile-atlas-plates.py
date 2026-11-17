"""원본 콘셉트 삽화와 월드 실측 음영도를 Roblox 지도용 팔레트 이미지로 패킹한다."""
import argparse
import base64
import math
import re
import struct
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageOps

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("relief_log", type=Path)
args = parser.parse_args()
log = args.relief_log.read_text()
assert "ATLAS_RELIEF_COMPLETE" in log
model = ET.Element("roblox", version="4")
folder = ET.SubElement(model, "Item", {"class": "Folder", "referent": "AtlasPlates"})
ET.SubElement(ET.SubElement(folder, "Properties"), "string", name="Name").text = "AtlasPlates"


def pack(name, rgb, mask=None):
    # Index 255 is reserved for transparent areas outside the walkable footprint.
    indexed = rgb.quantize(colors=255, dither=Image.Dither.NONE)
    palette = bytes(indexed.getpalette()).ljust(768, b"\0")
    if mask is not None:
        indexed.paste(255, mask=mask)
    raw = struct.pack("<HH", *rgb.size) + palette + indexed.tobytes()
    payload = subprocess.run(["zstd", "-q", "-12", "--no-check", f"--stream-size={len(raw)}", "-c"], input=raw, capture_output=True, check=True).stdout
    item = ET.SubElement(folder, "Item", {"class": "StringValue", "referent": name})
    properties = ET.SubElement(item, "Properties")
    ET.SubElement(properties, "string", name="Name").text = name
    ET.SubElement(properties, "string", name="Value").text = base64.b64encode(payload).decode()


sizes = {key: (int(w), int(h)) for key, w, h in re.findall(r"RELIEF_SIZE\s+([\w-]+)\s+(\d+)\s+(\d+)", log)}
assert len(sizes) == 44
chunks = {key: [] for key in sizes}
for key, chunk in re.findall(r"RELIEF_ROW\s+([\w-]+)\s+([\w+/=]+)", log):
    chunks[key].append(chunk)
for key, (w, h) in sorted(sizes.items()):
    raw = base64.b64decode("".join(chunks[key]), validate=True)
    assert len(raw) == w*h*6, key
    samples = list(struct.iter_unpack("<BBBhB", raw))
    masked = bytearray(w*h)
    pixels = bytearray(w*h*3)
    # Map inks follow the approved regional art direction. Keep the relative
    # luminance of the measured surface so cliffs, roofs and paths stay distinct.
    low, high = {
        "DW": ((26,48,37),(210,210,141)), "GW": ((21,27,52),(149,178,207)),
        "FV": ((41,71,100),(224,241,247)), "EC": ((49,32,40),(224,157,99)),
        "HG": ((35,30,47),(183,171,192)),
    }[key[:2]]
    for i, (r, g, b, elevation, light) in enumerate(samples):
        if not light:
            masked[i] = 255
            continue
        # Northwest hillshade and height contours preserve surveyed granularity.
        west = samples[i-1] if i % w else samples[i]
        north = samples[i-w] if i >= w else samples[i]
        slope = sum(elevation-s[3] for s in (west, north) if s[4])
        shade = .79 + .23*light/250 + .24*math.tanh(slope/85)
        if north[4] and elevation//96 != north[3]//96:
            shade *= .90
        luminance = min(1, (.22*r + .70*g + .08*b)/210)
        ink = [a+(b-a)*luminance for a,b in zip(low,high)]
        mix = .75 if key.startswith(("GW", "HG")) else .55
        pixels[i*3:i*3+3] = bytes(min(255, round(((1-mix)*c + mix*tone)*shade + 4))
                                   for c,tone in zip((r,g,b),ink))
    pack("Relief_"+key, Image.frombytes("RGB", (w,h), bytes(pixels)), Image.frombytes("L",(w,h),bytes(masked)))
    # Side stories Q2-Q4 each own a physical optional region. Q1 shares a main region.
    story = re.sub(r"S([1-3])$", lambda m: "Q"+str(int(m[1])+1), key)
    source_dir = "2026-11-12-deepwood-epic-stories-v1" if key.startswith("DW") else "2026-11-13-regional-epic-stories-v1"
    base = root/"assets/concepts"/source_dir
    for asset in [story] + ([key[:2]+"-EPIC"] if key.endswith("-01") else []):
        with Image.open(base/(asset+".png")) as image:
            pack(key if asset==story else asset, ImageOps.fit(image.convert("RGB"), (320,180), method=Image.Resampling.LANCZOS))
ET.ElementTree(model).write(root/"src/client/AtlasPlates.rbxmx", encoding="utf-8", xml_declaration=True)
