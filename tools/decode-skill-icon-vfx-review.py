"""12개 Studio 전후 RGB 로그를 원본 픽셀 그대로 PNG와 해시 목록으로 복원한다."""
from pathlib import Path
import argparse
import hashlib
import json
from PIL import Image, ImageDraw

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('log', type=Path)
p.add_argument('output', type=Path)
a = p.parse_args()
rows, chunks = {}, {}
text = a.log.read_text()
assert 'ICON_VFX_CAPTURE_COMPLETE' in text
for line in text.splitlines():
    if line.startswith('ICON_VFX_META '):
        row = json.loads(line.split(' ', 1)[1])
        assert row['index'] not in rows
        rows[row['index']] = row
    elif line.startswith('ICON_VFX_RGB '):
        _, index, data = line.split(' ', 2)
        chunks.setdefault(int(index), []).append(data)
assert set(rows) == set(range(1, 13)), '12 complete comparisons required'
a.output.mkdir(parents=True, exist_ok=True)
sheet = Image.new('RGB', (1440, 1200), '#101728')
draw = ImageDraw.Draw(sheet)
for index, row in sorted(rows.items()):
    raw = bytes.fromhex(''.join(chunks[index]))
    assert len(raw) == row['width'] * row['height'] * 3
    frame = Image.frombytes('RGB', (row['width'], row['height']), raw)
    f = a.output / f'comparison-{index:02}.png'
    frame.save(f)
    row['sha256'] = hashlib.sha256(f.read_bytes()).hexdigest()
    x, y = (index - 1) % 3 * 480, (index - 1) // 3 * 300
    sheet.paste(frame, (x, y + 25))
    draw.text((x + 5, y + 5), f'{index}. {row["name"]} | Before / After', fill='white')
sheet.save(a.output / 'comparison-sheet.png')
(a.output / 'comparisons.json').write_text(json.dumps(list(rows.values()), indent=2) + '\n')
print('Restored 12 comparison frames')
