"""Studio가 북쪽 고정 카메라로 렌더링한 월드 화면을 Roblox 지도용 팔레트 이미지로 패킹한다."""
import argparse
import base64
import re
import struct
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("render_log", type=Path)
args = parser.parse_args()
log = args.render_log.read_text()
assert "ATLAS_RENDER_COMPLETE" in log
model = ET.Element("roblox", version="4")
folder = ET.SubElement(model, "Item", {"class": "Folder", "referent": "AtlasPlates"})
ET.SubElement(ET.SubElement(folder, "Properties"), "string", name="Name").text = "AtlasPlates"


def pack(name, rgb, mask):
    # Index 255 is reserved for pixels where the calibration background was visible.
    indexed = rgb.quantize(colors=255, dither=Image.Dither.NONE)
    palette = bytes(indexed.getpalette()).ljust(768, b"\0")
    indexed.paste(255, mask=mask)
    raw = struct.pack("<HH", *rgb.size) + palette + indexed.tobytes()
    payload = subprocess.run(["zstd", "-q", "-12", "--no-check", f"--stream-size={len(raw)}", "-c"], input=raw, capture_output=True, check=True).stdout
    item = ET.SubElement(folder, "Item", {"class": "StringValue", "referent": name})
    properties = ET.SubElement(item, "Properties")
    ET.SubElement(properties, "string", name="Name").text = name
    ET.SubElement(properties, "string", name="Value").text = base64.b64encode(payload).decode()


sizes = {key: (int(w), int(h)) for key, w, h in re.findall(r"SURVEY_SIZE\s+([\w-]+)\s+(\d+)\s+(\d+)", log)}
assert len(sizes) == 44
chunks = {key: [] for key in sizes}
for key, chunk in re.findall(r"SURVEY_RGBA\s+([\w-]+)\s+([a-f0-9]+)", log):
    chunks[key].append(chunk)
for key, (w, h) in sorted(sizes.items()):
    raw = bytes.fromhex("".join(chunks[key]))
    raw = subprocess.run(["zstd", "-dq", "-c"], input=raw, capture_output=True, check=True).stdout
    assert len(raw) == w*h*4, key
    rgba = Image.frombytes("RGBA", (w, h), raw)
    alpha = rgba.getchannel("A")
    assert alpha.getextrema()[1] == 255, key + " has no visible surface"
    pack("Relief_"+key, rgba.convert("RGB"), alpha.point(lambda a: 255 if a == 0 else 0))
ET.ElementTree(model).write(root/"src/client/AtlasPlates.rbxmx", encoding="utf-8", xml_declaration=True)
