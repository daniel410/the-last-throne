#!/usr/bin/env python3
"""Build/check the four starter-family concept delivery without editing images."""
import argparse
import hashlib
import html
import json
from pathlib import Path
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/concepts/2026-11-09-starter-equipment-v1'
ARCHIVE = 'TLT-Starter-Equipment-Concepts.zip'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    manifest = json.loads((BASE / 'manifest.json').read_text())
    records = manifest['records']
    assert len(records) == 12
    assert [(t['id'], t['rarity']) for t in manifest['tiers']] == [
        ('traveler', 'Common'), ('tempered', 'Common'),
        ('veteran', 'Uncommon'), ('sentinel', 'Rare')]
    definitions = set()
    cards = []
    for record in records:
        path = BASE / record['file']
        data = path.read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II', data[16:24]) == (record['width'], record['height'])
        assert digest(path) == record['sha256']
        assert digest(ROOT / record['reference']) == record['referenceSha256']
        assert record['status'] == 'generated-pending-user-art-acceptance'
        assert len(record['catalog']) == 4
        for item, tier in zip(record['catalog'], manifest['tiers']):
            assert item['tierId'] == tier['id'] and item['rarity'] == tier['rarity']
            assert not any(word in item['definitionId'] for word in ('ring', 'necklace'))
            definitions.add(item['definitionId'])
        title = html.escape(record['title'])
        file = html.escape(record['file'], quote=True)
        cards.append(f'<section id="{record["id"]}"><h2>{title}</h2><a href="{file}"><img src="{file}" alt="{title}: Traveler, Tempered, Veteran, Sentinel" loading="lazy"></a></section>')
    assert len(definitions) == 40
    page = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>TLT · Starter equipment concepts</title>
<style>body{margin:0 auto;padding:24px;max-width:1600px;background:#171b24;color:#e9e3d6;font:16px/1.6 system-ui}a{color:#a8cfef}nav{display:flex;flex-wrap:wrap;gap:18px}section{margin:40px 0}img{display:block;width:100%;height:auto;border-radius:12px}h1{font-size:30px}h2{font-size:20px}</style>
<h1>Traveler · Tempered · Veteran · Sentinel</h1><p>반지·목걸이를 제외한 12개 비교 보드, 48개 외형 시안. 각 보드는 왼쪽부터 Common / Common / Uncommon / Rare입니다. 사용자 최종 수용 전 컨셉이며 3D 모델·게임 적용 결과가 아닙니다.</p>
<p>Traveler: 베이지·가죽 / Tempered: 청회색·강철 / Veteran: 올리브·브론즈 / Sentinel: 남색·은색. Sentinal 요청은 기존 카탈로그 Sentinel 표기로 정리했습니다.</p>
<p><a href="TLT-Starter-Equipment-Concepts.zip">전체 PNG 다운로드</a> · <a href="README.md">제작 기록</a></p><nav>'''
    page += ''.join(f'<a href="#{r["id"]}">{html.escape(r["title"])}</a>' for r in records) + '</nav>'
    page += ''.join(cards) + '</html>\n'
    if args.check:
        assert (BASE / 'index.html').read_text() == page
    else:
        (BASE / 'index.html').write_text(page)
        with zipfile.ZipFile(BASE / ARCHIVE, 'w', zipfile.ZIP_STORED) as archive:
            for name in ['index.html', 'README.md', 'manifest.json'] + [r['file'] for r in records]:
                archive.write(BASE / name, name)
    with zipfile.ZipFile(BASE / ARCHIVE) as archive:
        assert archive.testzip() is None
        for record in records:
            assert hashlib.sha256(archive.read(record['file'])).hexdigest() == record['sha256']
        assert archive.read('manifest.json') == (BASE / 'manifest.json').read_bytes()
        assert archive.read('index.html') == (BASE / 'index.html').read_bytes()
        assert archive.read('README.md') == (BASE / 'README.md').read_bytes()
    print('PASS: 12 PNG boards, 48 visuals, 40 unique definitions, tier mapping, reference hashes, gallery and ZIP')


if __name__ == '__main__':
    main()
