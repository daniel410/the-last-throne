"""NPC-5K-20261117: 실제 Blender 렌더로 검토 보드와 로컬 갤러리를 구성한다."""
import html
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/evidence/npc-meshy-5k-20261117'
CONCEPT = ROOT / 'assets/concepts/2026-11-17-npc-blocky-5k-v1'
manifest = json.loads((CONCEPT / 'manifest.json').read_text())
font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 24)
small = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 19)
groups = {}
reports = []
for asset in manifest['assets']:
    report_path = OUT / f"{asset['id']}-geometry.json"
    if not report_path.exists():
        continue
    report = json.loads(report_path.read_text())
    report['name'] = asset['name']
    groups.setdefault(asset['region'], []).append(report)
    reports.append(report)

def board(items, path, columns=3, tile_width=360, tile_height=500):
    result = Image.new('RGB', (columns * tile_width, math.ceil(len(items) / columns) * tile_height), '#eeeeec')
    draw = ImageDraw.Draw(result)
    for index, report in enumerate(items):
        image = Image.open(OUT / f"{report['id']}-three-quarter.png").convert('RGB')
        image.thumbnail((tile_width - 4, tile_height - 52))
        x, y = (index % columns) * tile_width, (index // columns) * tile_height
        result.paste(image, (x + (tile_width - image.width) // 2, y))
        draw.text((x + 12, y + tile_height - 44), f"{report['name']} | {report['candidateTriangles']:,} tris", font=font if tile_width >= 350 else small, fill='#242a32')
    result.save(path)

for region, items in groups.items():
    board(items, OUT / f'{region}-preview.png')
if reports:
    board(reports, OUT / 'all-npcs-preview.jpg', columns=6, tile_width=280, tile_height=390)

sections = []
for region, items in groups.items():
    cards = []
    for item in items:
        cid = item['id']
        concept = f'../../../assets/concepts/2026-11-17-npc-blocky-5k-v1/{cid}.png'
        model = f'../../../assets/models/npc-meshy-5k-v1/candidates/{cid}-5k.glb'
        pictures = [(concept, '생성 PNG'), (f'{cid}-front.png','3D 정면'), (f'{cid}-three-quarter.png','3D 사선'), (f'{cid}-back.png','3D 후면')]
        views = ''.join(f'<figure><a href="{src}"><img loading="lazy" src="{src}" alt="{cid} {caption}"></a><figcaption>{caption}</figcaption></figure>' for src, caption in pictures)
        cards.append(f'<article><h3>{html.escape(item["name"])} <span>{item["candidateTriangles"]:,} tris</span></h3><div class="views">{views}</div><p><a href="{model}">5k GLB 파일</a> · <a href="{cid}-geometry.json">기하 검증</a></p></article>')
    blend = f'../../../assets/models/npc-meshy-5k-v1/npc-5k-review-{region}.blend'
    sections.append(f'<section id="{region}"><h2>{region.replace("-", " ").title()}</h2><p><a href="{blend}">지역 Blender 파일</a></p>{"".join(cards)}</section>')
nav = ' · '.join(f'<a href="#{region}">{region.replace("-", " ").title()}</a>' for region in groups)
document = f'''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>NPC 5k 모델 검토</title>
<style>body{{font:16px/1.6 system-ui,sans-serif;margin:0;background:#10151c;color:#e5eaf2}}main{{max-width:1400px;margin:auto;padding:32px}}a{{color:#96c8ff}}h1{{font-size:32px}}nav{{position:sticky;top:0;padding:12px;background:#10151cf0}}article{{background:#1b2530;padding:20px;margin:24px 0;border-radius:12px}}h3 span{{font-size:15px;color:#acc0d0;margin-left:20px}}.views{{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}}figure{{margin:0}}img{{width:100%;aspect-ratio:4/5;object-fit:contain;background:#999}}figcaption{{text-align:center}}@media(max-width:700px){{main{{padding:14px}}.views{{grid-template-columns:repeat(2,1fr)}}}}</style>
<main><h1>NPC 5k 모델 검토</h1><p>NPC-5K-20261117 · Selene 제외 · {len(reports)}/29명 · 게임 적용 전 검토 후보</p><p>기존 콘셉트 → 개별 PNG → Meshy T2.5 / N1 → Blender 5k 정리. 정면·사선·후면은 실제 후보 메시 렌더다. Standard/sRGB 기준. 리그·애니메이션·Studio·게시 클라이언트·실기기·사용자 수용은 미검증이다.</p><nav>{nav}</nav>{''.join(sections)}</main></html>'''
(OUT / 'index.html').write_text(document)
(OUT / 'geometry-summary.json').write_text(json.dumps(reports, ensure_ascii=False, indent=2)+'\n')
print(json.dumps({'reviewed':len(reports),'boards':list(groups)}, ensure_ascii=False))
