"""Studio 캡처 로그의 RGB 타일을 원본 시간으로 재생하고 두 직업의 자세표를 만든다."""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

parser = argparse.ArgumentParser()
for option in ('before', 'after', 'catalog', 'output'):
    parser.add_argument('--'+option, required=True, type=Path)
parser.add_argument('--versions', nargs=2, required=True)
parser.add_argument('--ranged', action='store_true')
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)


def font(size, bold=False):
    for name in (('Arial Bold.ttf', 'DejaVuSans-Bold.ttf') if bold else ('Arial.ttf', 'DejaVuSans.ttf')):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default(size=size)


def decode(path):
    pixels, metadata, durations = {}, {}, {}
    with path.open() as stream:
        for line in stream:
            fields = line.split()
            if not fields:
                continue
            if fields[0] == 'POSE_ROW':
                row, frame, y = map(int, fields[1:4])
                pixels[row, frame, y] = bytes.fromhex(fields[4])
            elif fields[0] == 'POSE_META':
                row, frame = map(int, fields[1:3])
                metadata[row, frame] = fields[3]
                durations[row] = float(fields[5])
            elif fields[0] == 'POSE_ACTION' and len(fields) == 5:
                durations[int(fields[1])] = float(fields[4])
    images = {(row, frame): Image.frombytes('RGB', (160,160),
              b''.join(pixels[row, frame, y] for y in range(160)))
              for row, frame, y in pixels if y == 159}
    return images, metadata, durations


before, _, _ = decode(args.before)
after, _, periods = decode(args.after)
catalog, ids, _ = decode(args.catalog)
assert len(before) == len(after) == 120 and len(catalog) == len(ids) == 192
names = ['Downcut', 'Rising Cut', 'Horizontal Sweep', 'Driving Thrust', 'Provoke',
         'Overhead', 'Backhand', 'Wide Sweep', 'Overhead Smash', 'Bomb Toss']
common = {'knight.common.bash': 'Shield Bash', 'dwarf.common.ground': 'Ground Slam',
          'dwarf.common.overhead': 'Overhead Smash', 'dwarf.common.throw': 'Axe Throw'}
heroes = ['Knight', 'Dwarf']
if args.ranged:
    heroes = ['Elf', 'Mage']
    names = ['Bow Shot', 'Rapid Fire', 'Heavy Draw', 'Retreating Shot', 'Spirit Arrowfall',
             'Staff Strike', 'Water Ball', 'Wind Lance', "Caldera's Judgment", 'Eternal Tempest']
    common.update({'elf.common.aimed': 'Aimed Shot', 'elf.common.rapid': 'Rapid Fire',
                   'elf.common.multi': 'Multi Shot', 'mage.pyro.caldera_s_judgment': "Caldera's Judgment"})
for hero, start, first in zip(heroes, [1, 6], [1, 9]):
    frames, delays = [], []
    for row in range(start, start+5):
        for f in range(12):
            canvas = Image.new('RGB', (480,300), '#0e1420')
            draw = ImageDraw.Draw(canvas)
            draw.text((16,10), hero.upper(), font=font(13,True), fill='#9fb7c7')
            draw.text((16,32), names[row-1], font=font(24,True), fill='#f2edde')
            draw.text((18,72), 'Before  ·  '+args.versions[0], font=font(15), fill='#b9c2ca')
            draw.text((257,72), 'After  ·  '+args.versions[1], font=font(15,True), fill='#edc57d')
            for x, image in [(23, before[row,f]), (263, after[row,f])]:
                canvas.paste(image.resize((192,192), Image.Resampling.LANCZOS), (x,93))
            draw.line((239,73,239,283), fill='#343d48')
            frames.append(canvas)
            delays.append(round(periods[row]*1000/12))
    frames[0].save(args.output/(hero.lower()+'-comparison.webp'), save_all=True,
                   append_images=frames[1:], duration=delays, loop=0, quality=90, method=6)
    canvas = Image.new('RGB', (1280, 8*121+64), '#111825')
    draw = ImageDraw.Draw(canvas)
    draw.text((14,12), hero+'  /  Skill poses', font=font(26,True), fill='#f2edde')
    draw.text((14,43), 'Preparation  ·  Contact  ·  Follow-through', font=font(14), fill='#b9c2ca')
    for row in range(8):
        for col in range(4):
            key = ids[first+row,col*3]
            name = key.rsplit('.',1)[-1].removeprefix(hero.lower()+'_').replace('_',' ').title()
            x, y = col*320, 64+row*121
            draw.text((x+10,y), common.get(key,name), font=font(16,True), fill='#dbc9a2')
            for phase in range(3):
                tile = catalog[first+row,col*3+phase].resize((97,97), Image.Resampling.LANCZOS)
                canvas.paste(tile, (x+8+phase*102,y+20))
    canvas.save(args.output/(hero.lower()+'-skill-catalog.jpg'), quality=91)
