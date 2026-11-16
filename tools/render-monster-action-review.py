"""Studio가 기록한 동일 시각 표본을 공격 원래 길이로 재생한다."""
import argparse
import base64
from pathlib import Path
import subprocess
from PIL import Image, ImageDraw, ImageFont

parser = argparse.ArgumentParser()
for key in ('before', 'after', 'output'):
    parser.add_argument('--'+key, type=Path, required=True)
parser.add_argument('--versions', nargs=2, required=True)
args = parser.parse_args()


def decode(path):
    chunks, actions = {}, {}
    complete = False
    for line in path.open():
        fields = line.split()
        if fields[:1] == ['MONSTER_ACTION']:
            actions[fields[1]] = (' '.join(fields[3:-1]), float(fields[-1]))
        elif fields[:1] == ['MONSTER_PIXELS']:
            chunks.setdefault((fields[1], int(fields[2])), []).append(fields[3])
        elif fields[:1] == ['MONSTER_CAPTURE_PASS']:
            complete = True
    assert complete and len(actions) == 6 and len(chunks) == 16*len(actions)
    frames = {}
    for key, data in chunks.items():
        packed = base64.b64decode(''.join(data), validate=True)
        raw = subprocess.run(['zstd', '-qd', '-c'], input=packed, capture_output=True, check=True).stdout
        assert len(raw) == 240*240*3
        frames[key] = Image.frombytes('RGB', (240,240), raw)
    return actions, frames


def font(size):
    for face in ('Arial.ttf', 'DejaVuSans.ttf'):
        try:
            return ImageFont.truetype(face, size)
        except OSError:
            pass
    return ImageFont.load_default(size=size)


actions, before = decode(args.before)
after_actions, after = decode(args.after)
assert actions == after_actions
args.output.mkdir(parents=True, exist_ok=True)
for file, kinds in [('melee', ('Goblin', 'Ogre', 'IceWolf')), ('wings-spells-boss', ('Gloambat', 'VolcanoShaman', 'Veyr'))]:
    frames, times = [], []
    for kind in kinds:
        label, duration = actions[kind]
        for i in range(16):
            frame = Image.new('RGB', (504, 310), '#121821')
            draw = ImageDraw.Draw(frame)
            draw.text((9, 8), kind+'  /  '+label, font=font(22), fill='#f4ecd9')
            draw.text((9, 43), 'Before  ·  '+args.versions[0], font=font(15), fill='#c3cbd2')
            draw.text((255, 43), 'After  ·  '+args.versions[1], font=font(15), fill='#ffce79')
            frame.paste(before[kind, i], (9, 65))
            frame.paste(after[kind, i], (255, 65))
            frames.append(frame)
            times.append(round(duration*1000/16))
    frames[0].save(args.output/(file+'.webp'), save_all=True, append_images=frames[1:],
                   duration=times, quality=91, loop=0, method=5)
