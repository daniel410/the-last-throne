"""Build and validate the concept review gallery; never edits raster images."""
import argparse
import hashlib
import html
import json
import struct
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets/concepts/2026-11-08-equipment-rarity-v2'
GROUPS = {'shared': '공통', 'knight': '기사 · Oathguard', 'elf': '엘프 · Briarwatch',
          'dwarf': '드워프 · Stonehearth', 'mage': '마법사 · Aetherweave'}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build():
    manifest = json.loads((ART / 'generation.json').read_text())
    cards = []
    for record in manifest['records']:
        group = record['classId'] or 'shared'
        name = html.escape(record['name'])
        warning = '<strong>활의 중간 길이 보정은 생성 도구 거부로 미반영 · 긴 버전 검토 필요</strong>' if record.get('lengthRevisionStatus') else ''
        cards.append(f'''<article data-group="{group}" id="{record['familyId']}">
<h2>{name} <small>{GROUPS[group]} · {record['slot']}</small></h2>
<p>Rare → Epic → Legendary → Unique · Unique 고유명: {html.escape(record['uniqueName'])}</p>
{warning}<a href="{record['file']}"><img loading="lazy" src="{record['file']}" width="{record['width']}" height="{record['height']}" alt="{name} 네 등급 컨셉 비교"></a>
</article>''')
    controls = ''.join(f'<button type="button" data-filter="{key}">{name}</button>' for key, name in {'all': '전체 40품목', **GROUPS}.items())
    page = '''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>장비 희귀도 v2 · 40품목 / 160등급 컨셉</title>
<style>body{margin:0;background:#171b24;color:#f0eadc;font:16px/1.6 system-ui,sans-serif}header,main{max-width:1780px;margin:auto;padding:24px}header{padding-bottom:0}h1{font-size:28px;margin:0}h2{font-size:22px;margin:0}small{font-size:14px;color:#bac3d4}article{padding:16px;margin-bottom:28px;border:1px solid #4b4d57;border-radius:12px;background:#20232c}img{display:block;width:100%;height:auto;border-radius:6px}a{color:#c0d6ff}button,input{padding:10px 14px;margin:4px;color:#f0eadc;background:#303746;border:1px solid #6c7586;border-radius:6px;font:inherit}button[aria-pressed=true]{background:#6b5429}input{min-width:230px}p{margin:8px 0 14px}strong{display:block;color:#ffd58b;margin:12px 0}[hidden]{display:none!important}nav{position:sticky;top:0;z-index:2;padding:12px 24px;background:#171b24f5;border-bottom:1px solid #4b4d57}nav>div{max-width:1780px;margin:auto}.notice{border-left:4px solid #bda468;padding-left:14px}article:target{outline:2px solid #bda468}#count{display:inline-block;padding:8px}</style>
<header><h1>장비 희귀도 v2 · 40품목 / 160등급 컨셉</h1>
<p class="notice">자산 검수용 목록입니다. 39개 신규 비교 보드 + 승인 후드1개이며, 개별 투명 아이콘160개·실제 착용3D·게임 적용 완료가 아닙니다. 내장 image_gen 결과로 Blender Standard 렌더가 아닙니다.</p>
<p>같은 장비군·등급은 천/에나멜·금속·보석 팔레트를 통일합니다. 기사·드워프는 기존 컨셉을 참고한 금속 헬멧입니다. 둥근 꼭대기 규칙은 후드에만 적용합니다.</p>
<p><a href="set-palettes.json">장비군별 색상 기준</a> · <a href="generation.json">생성 프롬프트·출처·해시</a> · <a href="README.md">제작/검증 기록</a></p></header>
<nav><div>''' + controls + '''<input id="query" aria-label="품목 검색" placeholder="영어 장비명 검색"><span id="count" aria-live="polite"></span></div></nav><main>''' + ''.join(cards) + '''</main>
<script>let selected='all';const buttons=[...document.querySelectorAll('[data-filter]')];function apply(){const q=document.querySelector('#query').value.toLowerCase();let n=0;document.querySelectorAll('article').forEach(a=>{a.hidden=!((selected==='all'||a.dataset.group===selected)&&a.textContent.toLowerCase().includes(q));if(!a.hidden)n++});buttons.forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.filter===selected)));document.querySelector('#count').textContent=n+' / 40품목'}buttons.forEach(b=>b.addEventListener('click',()=>{selected=b.dataset.filter;apply()}));document.querySelector('#query').addEventListener('input',apply);apply();</script></html>'''
    (ART / 'index.html').write_text(page)


class Links(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ('href', 'src') and value and not value.startswith(('https:', '#')):
                assert (ART / value).is_file(), value


def check():
    manifest = json.loads((ART / 'generation.json').read_text())
    records = manifest['records']
    originals = json.loads((ROOT / 'assets/concepts/2026-11-04-equipment-icons/manifest.json').read_text())['families']
    assert len(records) == 40 and {r['familyId'] for r in records} == {r['id'] for r in originals}
    assert Counter(r['classId'] or 'shared' for r in records) == {'shared': 11, 'knight': 8, 'elf': 7, 'dwarf': 7, 'mage': 7}
    hashes = set()
    for record in records:
        path = ART / record['file']
        raw = path.read_bytes()
        assert raw[:8] == b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II', raw[16:24]) == (record['width'], record['height'])
        assert record['width'] >= 1500 and record['height'] >= 800
        assert digest(path) == record['sha256']
        assert record['sha256'] not in hashes
        hashes.add(record['sha256'])
        assert record['status'] != 'pending'
        assert record.get('prompt') or record['status'] == 'approved-reference'
        for reference in record['inputReferences']:
            assert digest(ROOT / reference['path']) == reference['sha256']
        if record['familyId'] in ('knight_head_family', 'dwarf_head_family'):
            assert record['shape'] == 'helmet'
    palette = json.loads((ART / 'set-palettes.json').read_text())
    assert set(palette['groups']) == {'wayfarer', 'knight', 'elf', 'dwarf', 'mage'}
    assert all(set(p) == {'Rare', 'Epic', 'Legendary', 'Unique'} for p in palette['groups'].values())
    inventory = json.loads((ART / 'inventory.json').read_text())
    for record in inventory:
        assert digest(ART / record['file']) == record['sha256']
    page = (ART / 'index.html').read_text()
    assert page.count('<article ') == 40
    Links().feed(page)
    print(f'PASS 40 boards / 160 tier concepts; 40 distinct hashes, class counts, PNG metadata, 5 palette groups, 2 helmet categories, {len(inventory)} current/archive images and gallery links')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if not args.check:
        build()
    check()
