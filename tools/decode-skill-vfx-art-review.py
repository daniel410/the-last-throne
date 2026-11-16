"""복원한 Studio 전후 화면과 원본 아이콘을 한 비교표에 배치한다. 원본 자산은 수정하지 않는다."""
from pathlib import Path
import argparse
import hashlib
import json
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('log', type=Path)
p.add_argument('output', type=Path)
p.add_argument('--expected', type=int, default=56)
p.add_argument('--allow-partial', action='store_true')
p.add_argument('--before-label', default='Before 0.111.2')
p.add_argument('--after-label', default='After ART')
a = p.parse_args()
text = a.log.read_text()
if not a.allow_partial:
    assert 'ART_CAPTURE_COMPLETE' in text
rows, chunks = {}, {}
for line in text.splitlines():
    if line.startswith('ART_META '):
        r = json.loads(line.split(' ', 1)[1]); key = (r['index'], r['variant'])
        assert key not in rows; rows[key] = r
    elif line.startswith('ART_RGB '):
        _, idx, var, data = line.split(' ', 3)
        chunks.setdefault((int(idx), int(var)), []).append(data)
icons = {r['id']: r for r in json.loads((ROOT / 'assets/ui/hero-skill-icons-v2/manifest.json').read_text())['records']}
a.output.mkdir(parents=True, exist_ok=True)
try:
    font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 16)
except OSError:
    font = ImageFont.load_default()
records = []
for idx in sorted({key[0] for key in rows}):
    if any((idx, v) not in rows for v in (1, 2)):
        assert a.allow_partial; continue
    frames = []
    for variant in (1, 2):
        r = rows[idx, variant]; raw = bytes.fromhex(''.join(chunks.get((idx, variant), [])))
        if len(raw) != r['width'] * r['height'] * 3:
            assert a.allow_partial; break
        frames.append(Image.frombytes('RGB', (r['width'], r['height']), raw))
    if len(frames) != 2:
        continue
    r = rows[idx, 2]
    assert all(rows[idx, 1][k] == r[k] for k in ['id', 'age', 'pulse', 'clockTime', 'extent', 'width', 'height'])
    frame = Image.new('RGB', (1120, 365), '#101728'); draw = ImageDraw.Draw(frame)
    for i, img in enumerate(frames):
        frame.paste(img, (160 + i * 480, 40))
        draw.text((170 + i * 480, 12), (a.before_label if i == 0 else a.after_label) + f' | {r["age"]:.2f}s | pulse {r["pulse"]}', font=font, fill='white')
    icon = icons.get(r['id']); source = None
    if icon:
        source = ROOT / 'assets/ui/hero-skill-icons-v2' / icon['file']
        image = Image.open(source).convert('RGB'); image.thumbnail((150, 150)); frame.paste(image, (5, 75))
    draw.text((5, 232), 'Skill icon' if icon else r.get('category','Combat VFX'), font=font, fill='white')
    label = r['name']
    for line, start in enumerate(range(0, len(label), 15)):
        draw.text((5, 260 + line * 20), label[start:start + 15], font=font, fill='white')
    name = f'{idx:03}-{r["id"]}.png'; target = a.output / name; frame.save(target)
    records.append({**r, 'file': name, 'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                    'iconSha256': hashlib.sha256(source.read_bytes()).hexdigest() if source else None})
assert a.allow_partial or len(records) == a.expected, f'{len(records)} complete pairs, expected {a.expected}'
(a.output / 'manifest.json').write_text(json.dumps(records, indent=2) + '\n')
for page in range((len(records) + 7) // 8):
    sheet = Image.new('RGB', (2240, 1460), '#101728')
    for slot, row in enumerate(records[page * 8:page * 8 + 8]):
        sheet.paste(Image.open(a.output / row['file']), (slot % 2 * 1120, slot // 2 * 365))
    sheet.save(a.output / f'sheet-{page + 1:02}.png')
print(f'Restored {len(records)} ART comparison pairs')
