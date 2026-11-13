"""Studio CURATED_RGB 전후 로그를 검증하고 PNG·비교표·해시를 저장한다(Pillow 필요)."""
from pathlib import Path
import argparse
import hashlib
import json
from PIL import Image, ImageDraw, ImageFont


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_capture(path, expected):
    rows, chunks = {}, {}
    lines = path.read_text().splitlines()
    assert 'CURATED_CAPTURE_COMPLETE' in lines, f'Incomplete capture: {path}'
    for line in lines:
        if line.startswith('CURATED_META '):
            row = json.loads(line.split(' ', 1)[1])
            assert row['index'] not in rows, f'Duplicate frame: {path}'
            rows[row['index']] = row
        elif line.startswith('CURATED_RGB '):
            _, index, data = line.split(' ', 2)
            chunks.setdefault(int(index), []).append(data)
    assert len(rows) == expected and set(rows) == set(range(1, expected + 1))
    result = {}
    for index, row in rows.items():
        raw = bytes.fromhex(''.join(chunks[index]))
        assert len(raw) == row['width'] * row['height'] * 3
        result[index] = (row, Image.frombytes('RGB', (row['width'], row['height']), raw))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('before', type=Path)
    parser.add_argument('after', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--expected', type=int, required=True)
    args = parser.parse_args()
    captures = {label: read_capture(getattr(args, label), args.expected) for label in ['before', 'after']}
    args.output.mkdir(parents=True, exist_ok=True)
    width, height = captures['before'][1][1].size
    try:
        font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 14)
    except OSError:
        font = ImageFont.load_default()
    comparison = Image.new('RGB', (width * 4, ((args.expected + 1) // 2) * (height + 26)), (18, 22, 29))
    after = Image.new('RGB', (width * 3, ((args.expected + 2) // 3) * (height + 26)), (18, 22, 29))
    draw, after_draw = ImageDraw.Draw(comparison), ImageDraw.Draw(after)
    manifest = []
    for index in range(1, args.expected + 1):
        row = dict(captures['before'][index][0])
        assert row == captures['after'][index][0], f'Conditions differ for frame {index}'
        x, y = (index - 1) % 2 * width * 2, (index - 1) // 2 * (height + 26)
        for side, label in enumerate(['before', 'after']):
            frame = captures[label][index][1]
            assert frame.size == (width, height)
            target = args.output / f'{label}-{index:02}.png'
            frame.save(target)
            row[label + 'Sha256'] = digest(target)
            comparison.paste(frame, (x + side * width, y + 26))
            draw.text((x + side * width + 5, y + 4), row['name'] + ' / ' + label, font=font, fill='white')
        x, y = (index - 1) % 3 * width, (index - 1) // 3 * (height + 26)
        after.paste(captures['after'][index][1], (x, y + 26))
        after_draw.text((x + 5, y + 4), row['name'], font=font, fill='white')
        manifest.append(row)
    comparison.save(args.output / 'comparison.png')
    after.save(args.output / 'after.png')
    (args.output / 'samples.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (args.output / 'capture-logs.json').write_text(json.dumps({label: {'path': str(getattr(args, label)), 'sha256': digest(getattr(args, label))} for label in captures}, indent=2) + '\n')
    print(f'Validated {args.expected} matching before/after frames')


if __name__ == '__main__':
    main()
