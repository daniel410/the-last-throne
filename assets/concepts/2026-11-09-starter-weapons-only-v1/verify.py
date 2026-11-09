"""Package/check exact starter weapon PNGs without changing image pixels."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import zipfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from validate_weapon_cutout_pngs import alpha_stats


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    manifest = json.loads((BASE / 'manifest.json').read_text())
    records = manifest['records']
    assert len(records) == 4
    assert {r['category'] for r in records} == {'sword', 'bow', 'axe', 'staff'}
    report = []
    cards = []
    for record in records:
        path = BASE / record['file']
        assert path.read_bytes() == (ROOT / record['source']).read_bytes()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == record['sha256']
        stats = alpha_stats(path)
        assert stats['size'] == [1024, 1536]
        assert stats['minAlpha'] == 0 and stats['maxAlpha'] >= 250
        assert stats['transparentPct'] > 40
        left, top, right, bottom = stats['opaqueBounds']
        assert left > 4 and top > 4 and right < 1019 and bottom < 1531
        report.append(dict(file=record['file'], **stats))
        cards.append(f'<figure><h2>{record["name"]}</h2><div class="preview"><img src="{record["file"]}" alt="{record["name"]}"></div><a href="{record["file"]}" download>PNG 다운로드</a></figure>')
    assert len({r['sha256'] for r in records}) == 4
    page = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>TLT · Starter weapons only</title><style>body{max-width:1500px;margin:auto;padding:24px;background:#1b202a;color:#eee;font:16px/1.6 system-ui}a{color:#a7d6ff}.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:16px}figure{margin:0}h2{font-size:18px}.preview{background-color:#fff;background-image:conic-gradient(#d1d5dc 25%,transparent 0 50%,#d1d5dc 0 75%,transparent 0);background-size:24px 24px}img{width:100%;height:auto;display:block}@media(max-width:800px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}</style><h1>Starter weapons · 4 PNGs</h1><p>검·활·도끼·지팡이만. 각 1024×1536 투명 RGBA PNG. 최신 선택된 Traveler=Tempered 원본을 그대로 사용합니다.</p><p><a href="TLT-Starter-Weapons-Only-4.zip">4개 PNG 다운로드</a> · <a href="README.md">제작·검증 기록</a></p><p>체크무늬는 미리보기 배경이며 PNG에는 포함되지 않습니다. 3D 모델링 참고용 단일 시점 이미지입니다.</p><div class="grid">'''
    page += ''.join(cards) + '</div></html>\n'
    archive = BASE / 'TLT-Starter-Weapons-Only-4.zip'
    if args.check:
        assert json.loads((BASE / 'alpha-report.json').read_text()) == report
        assert (BASE / 'index.html').read_text() == page
    else:
        (BASE / 'alpha-report.json').write_text(json.dumps(report, indent=2) + '\n')
        (BASE / 'index.html').write_text(page)
        with zipfile.ZipFile(archive, 'w', zipfile.ZIP_STORED) as output:
            for name in ['README.md', 'index.html', 'manifest.json', 'alpha-report.json'] + [r['file'] for r in records]:
                output.write(BASE / name, name)
    with zipfile.ZipFile(archive) as output:
        assert output.testzip() is None
        assert sum(n.endswith('.png') for n in output.namelist()) == 4
        for record in records:
            assert hashlib.sha256(output.read(record['file'])).hexdigest() == record['sha256']
    print('PASS: 4 exact selected starter PNGs, 1024x1536 RGBA, real transparency, no opaque clipping, ZIP CRC and image hashes')


if __name__ == '__main__':
    main()
