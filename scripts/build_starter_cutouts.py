"""Package/check 20 transparent starter weapons and shields without image edits."""
import argparse
from collections import Counter
import hashlib
import html
import json
from pathlib import Path
import zipfile
from validate_weapon_cutout_pngs import alpha_stats

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/concepts/2026-11-09-starter-cutouts-v1'
ZIP = 'TLT-Starter-Weapons-Shields-Transparent-20.zip'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    manifest = json.loads((BASE / 'manifest.json').read_text())
    records = manifest['records']
    assert len(records) == 20
    assert Counter(r['category'] for r in records) == dict.fromkeys(['sword', 'bow', 'axe', 'staff', 'shield'], 4)
    assert Counter(r['tierId'] for r in records) == dict.fromkeys(['traveler', 'tempered', 'veteran', 'sentinel'], 5)
    assert len({r['definitionId'] for r in records}) == 20
    report = []
    for record in records:
        assert record['rarity'] == {'traveler': 'Common', 'tempered': 'Common', 'veteran': 'Uncommon', 'sentinel': 'Rare'}[record['tierId']]
        path = BASE / record['file']
        assert sha(ROOT / record['reference']) == record['referenceSha256']
        stats = alpha_stats(path)
        assert stats['size'] == [1024, 1536], (path, stats)
        assert stats['minAlpha'] == 0 and stats['maxAlpha'] >= 250
        assert stats['transparentPct'] > 35, (path, stats)
        left, top, right, bottom = stats['opaqueBounds']
        assert left > 4 and top > 4 and right < 1019 and bottom < 1531, (path, stats)
        item = dict(file=record['file'], sha256=sha(path), **stats)
        report.append(item)
        if args.check:
            assert record['sha256'] == item['sha256']
        else:
            record.update(sha256=item['sha256'], width=1024, height=1536, bytes=path.stat().st_size)
    assert len({r['sha256'] for r in report}) == 20
    page = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>TLT · Transparent starter weapons and shields</title>
<style>body{max-width:1600px;margin:auto;padding:24px;background:#1a1f29;color:#eee;font:16px/1.6 system-ui}a{color:#a9d7ff}.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:18px}figure{margin:0}h2{font-size:16px}.preview{background-color:#fff;background-image:conic-gradient(#d5d8dd 25%,transparent 0 50%,#d5d8dd 0 75%,transparent 0);background-size:24px 24px;border-radius:10px}.preview img{display:block;width:100%;height:auto}button{padding:10px;margin:6px;cursor:pointer}@media(max-width:800px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}</style>
<h1>Traveler · Tempered · Veteran · Sentinel</h1><p>검·활·도끼·지팡이·방패 각 4종, 총 20개. 1024 × 1536 RGBA PNG. 파일마다 장비 한 개이며 3D 모델링 참고용 단일 시점 이미지입니다.</p>
<p><a href="TLT-Starter-Weapons-Shields-Transparent-20.zip">20개 PNG 다운로드</a> · <a href="README.md">제작·검증 기록</a></p>
<p>체크무늬는 미리보기 배경이며 PNG에는 포함되지 않습니다.</p><button onclick="document.querySelectorAll('.preview').forEach(x=>{x.style.backgroundImage='';x.style.backgroundColor='#fff'})">흰 배경</button><button onclick="document.querySelectorAll('.preview').forEach(x=>{x.style.backgroundImage='none';x.style.backgroundColor='#222'})">어두운 배경</button><button onclick="document.querySelectorAll('.preview').forEach(x=>{x.style.backgroundImage='';x.style.backgroundColor=''})">투명도 체크무늬</button><div class="grid">'''
    for record in records:
        title = html.escape(record['id'].replace('_', ' ').title())
        file = html.escape(record['file'], quote=True)
        page += f'<figure><h2>{title} · {record["rarity"]}</h2><div class="preview"><a href="{file}" download><img src="{file}" alt="{title}"></a></div><a href="{file}" download>PNG 다운로드</a></figure>'
    page += '</div></html>\n'
    if args.check:
        assert (BASE / 'index.html').read_text() == page
        assert json.loads((BASE / 'alpha-report.json').read_text()) == report
    else:
        manifest['status'] = 'generated-validated-pending-user-art-acceptance'
        (BASE / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n')
        (BASE / 'alpha-report.json').write_text(json.dumps(report, indent=2) + '\n')
        (BASE / 'index.html').write_text(page)
        with zipfile.ZipFile(BASE / ZIP, 'w', zipfile.ZIP_STORED) as archive:
            for name in ['README.md', 'index.html', 'manifest.json', 'alpha-report.json'] + [r['file'] for r in records]:
                archive.write(BASE / name, name)
        package = dict(file=ZIP, sha256=sha(BASE / ZIP), bytes=(BASE / ZIP).stat().st_size, pngCount=20)
        (BASE / 'package.json').write_text(json.dumps(package, indent=2) + '\n')
    package = json.loads((BASE / 'package.json').read_text())
    assert package['sha256'] == sha(BASE / ZIP)
    with zipfile.ZipFile(BASE / ZIP) as archive:
        assert archive.testzip() is None
        assert sum(n.endswith('.png') for n in archive.namelist()) == 20
        for record in records:
            assert hashlib.sha256(archive.read(record['file'])).hexdigest() == record['sha256']
    print('PASS: 20 distinct 1024x1536 RGBA PNGs; 4 families x 5 categories; zero-alpha background, near-opaque objects, no opaque clipping; reference hashes, gallery, ZIP CRC and PNG hashes')


if __name__ == '__main__':
    main()
