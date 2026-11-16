"""선택된 원본 PNG·실제 업로드 응답을 대조하고 런타임 등록표를 만든다. 픽셀은 수정하지 않는다."""
from pathlib import Path
from collections import Counter
import hashlib
import json
import re
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/ui/hero-skill-icons-v2'
rows = json.loads((BASE / 'prompts.json').read_text())['records']
uploads = {}
for file in sorted((BASE / 'uploads').glob('*.json')):
    if file.name.startswith('error-'):
        continue
    data = json.loads(file.read_text())
    for url, asset in data.get('images', data).items():
        if url.startswith('http://127.0.0.1:8822/'):
            uploads[url.rsplit('/', 1)[-1][:-4]] = asset
assert len(rows) == len(uploads) == 128, (len(rows), len(uploads))

def sha(file):
    return hashlib.sha256(file.read_bytes()).hexdigest()

# Compare against current runtime definitions, including append-only common indices.
expected = set(re.findall(r'\{ id = "([^"]+\.common\.[^"]+)"', (ROOT / 'src/shared/K0Config.luau').read_text()))
advanced = (ROOT / 'src/shared/AdvancedSkills.luau').read_text()
for match in re.finditer(r'branch\("([^"]+)","([^"]+)"[^\n]*\{\n(.*?)\n\}\)', advanced, re.S):
    branch, class_id, body = match.groups()
    for name in re.findall(r' s\("([^"]+)"', body):
        expected.add(class_id + '.' + branch + '.' + re.sub(r'[^a-zA-Z0-9_]+', '_', name.lower()))
expected.update(re.findall(r"common\('[^']+','([^']+)'", advanced))
assert expected == {r['id'] for r in rows} == set(uploads)
assert Counter(r['classId'] for r in rows) == {'knight': 32, 'dwarf': 32, 'elf': 32, 'mage': 32}
assert len(set(uploads.values())) == 128

records, pixels, generation = [], [], []
for row in rows:
    file = BASE / row['file']
    receipt = json.loads((BASE / 'receipts' / (row['id'] + '.json')).read_text())
    image = Image.open(file)
    assert image.width == image.height and image.width >= 1024
    assert image.mode in ('RGB', 'RGBA')
    assert re.fullmatch(r'rbxassetid://\d+', uploads[row['id']])
    digest = sha(file)
    original = Path(receipt['sourcePath'])
    if original.exists():
        assert sha(original) == digest, row['id'] + ' original bytes'
    for reference in row['references']:
        assert sha(ROOT / reference['file']) == reference['sha256']
    assert receipt['prompt'] == row['prompt']
    records.append({k: row[k] for k in ['id', 'classId', 'name', 'group', 'index', 'file', 'straightSwordRequired']})
    records[-1].update(sha256=digest, width=image.width, height=image.height, assetId=uploads[row['id']])
    pixels.append(dict(id=row['id'], size=list(image.size), mode=image.mode, sha256=digest, bytes=file.stat().st_size))
    generation.append(dict(id=row['id'], sourcePath=receipt['sourcePath'], sha256=digest, generator=receipt['generator'], promptFile='prompts.json'))
assert len({r['sha256'] for r in records}) == 128

manifest = dict(schemaVersion=1, styleRevision='skill-tree-symbols-straight-swords', tasks=['TLT-057', 'TLT-059'], records=records,
                sourceHashes={p: sha(ROOT / p) for p in ['src/shared/K0Config.luau', 'src/shared/AdvancedSkills.luau']})
for name, data in [('manifest.json', manifest), ('pixel-report.json', pixels), ('generation.json', generation), ('uploaded.json', uploads)]:
    (BASE / name).write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')

asset_source = '-- Generated skill icons; PNGs, prompts and upload receipts: assets/ui/hero-skill-icons-v2.\nreturn {byId = {\n'
asset_source += ''.join('\t[' + json.dumps(r['id']) + '] = ' + json.dumps(uploads[r['id']]) + ',\n' for r in rows)
asset_source += '}}\n'
(ROOT / 'src/shared/SkillIconAssets.luau').write_text(asset_source)

gallery = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>영웅 스킬 아이콘 검토</title><style>
:root{color-scheme:dark;font-family:system-ui;background:#08101e;color:#eef5ff}body{max-width:1440px;margin:24px auto;padding:0 20px}
header{position:sticky;top:0;background:#08101ef5;padding:12px 0;z-index:1;border-bottom:1px solid #637d9b}h1{font-size:24px;margin:0 0 8px}p{color:#b5c8dd}
button,input{font:inherit;padding:9px 14px;border:1px solid #7896b7;border-radius:7px;background:#142843;color:inherit;margin:3px}button[aria-pressed=true]{border-color:#ffcc4a;background:#184c89}
#grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(158px,1fr));gap:12px;margin-top:18px}article{background:#10213a;border:1px solid #486987;border-radius:10px;padding:12px;min-width:0;text-align:center}
article img{height:var(--icon,64px);width:var(--icon,64px);object-fit:contain;border-radius:50%;margin:8px auto;display:block}h2{font-size:12px;min-height:30px;margin:10px 0 6px}small{font-size:10px;overflow-wrap:anywhere;color:#a6bad0}a{color:inherit;text-decoration:none}code{font-size:10px;display:block;color:#9cbbd9}
</style><header><h1>영웅 스킬 아이콘 · 128종</h1><p>승인 Skill Tree 컨셉의 굵은 심볼·발광 대비, 곧은 검신 기준. 이 페이지는 PNG 비교표이며 실제 게임 UI 화면 증거는 검증 기록을 참고한다.</p>
<div id="filters"></div><input id="search" placeholder="스킬 이름 검색"><button id="size">40px로 보기</button><a href="../../../docs/evidence/hero-skill-icons-20261115/README.md">검증 기록</a></header><main id="grid"></main><script>
const rows=ROWS;let selected='all',small=false;const grid=document.querySelector('#grid'),filters=document.querySelector('#filters');
function render(){const query=document.querySelector('#search').value.toLowerCase();grid.replaceChildren();for(const r of rows){if(selected!=='all'&&selected!==r.classId||!r.name.toLowerCase().includes(query))continue;const card=document.createElement('article'),link=document.createElement('a'),img=document.createElement('img'),title=document.createElement('h2'),meta=document.createElement('small'),id=document.createElement('code');link.href=r.file;link.target='_blank';img.src=r.file;img.alt=r.name;img.loading='lazy';link.append(img);title.textContent=r.name;meta.textContent=r.classId+' / '+r.group;id.textContent=r.id;card.append(link,title,meta,id);grid.append(card)}for(const b of filters.children)b.setAttribute('aria-pressed',b.dataset.class===selected)}
for(const [key,label]of [['all','전체'],['knight','Knight'],['dwarf','Dwarf'],['elf','Elf'],['mage','Mage']]){const b=document.createElement('button');b.textContent=label;b.dataset.class=key;b.onclick=()=>{selected=key;render()};filters.append(b)}
document.querySelector('#search').oninput=render;document.querySelector('#size').onclick=()=>{small=!small;document.documentElement.style.setProperty('--icon',small?'40px':'64px');document.querySelector('#size').textContent=small?'64px로 보기':'40px로 보기'};render();
</script></html>'''.replace('ROWS', json.dumps(records, ensure_ascii=False))
(BASE / 'gallery.html').write_text(gallery)
print(json.dumps(dict(result='PASS', skills=128, classes=4, straightSwords=sum(r['straightSwordRequired'] for r in rows), registered=128, bytes=sum(r['bytes'] for r in pixels))))
