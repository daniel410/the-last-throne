"""Validate the four generated equipment art grades without changing assets."""
import hashlib
import json
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'assets/concepts/2026-11-04-equipment-icons'
GRADES = {'Rare': 'generated-rare-v1', 'Epic': 'generated-v1', 'Legendary': 'generated-legendary-v1', 'Unique': 'generated-unique-v1'}

class Links(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ('href', 'src') and value and not value.startswith(('http:', 'https:', '#', 'data:')):
                assert (self.base / value.split('#')[0]).exists(), (self.base, value)

manifest = json.loads((ROOT / 'manifest.json').read_text())
families = {f['id']: f for f in manifest['families']}
assert len(families) == 40
assert len({v['proposalId'] for v in manifest['variants']}) == 240
names = set()
hashes = {}
for grade, folder in GRADES.items():
    records = json.loads((ROOT / folder / 'generation.json').read_text())['records']
    assert len(records) == 40 and {r['familyId'] for r in records} == set(families)
    counts = Counter()
    for r in records:
        f = families[r['familyId']]
        p = ROOT / folder / r['file']
        assert hashlib.sha256(p.read_bytes()).hexdigest() == r['sha256'], p
        assert r['file'] not in names
        names.add(r['file'])
        assert r['file'] == r['displayMetadata']['name'] + '.png'
        assert r['displayMetadata']['rarity'] == grade
        assert f['iconVariants'][grade] == folder + '/' + p.name
        assert min(r['width'], r['height']) >= 1024 and r['colorType'] == 6
        if grade != 'Unique': assert r['width'] == r['height'] == 1254
        counts[f['classId'] or 'shared'] += 1
        hashes[(r['familyId'], grade)] = r['sha256']
        if grade in ('Legendary', 'Unique'):
            assert hashlib.sha256((ROOT / r['reference']).read_bytes()).hexdigest() == r['referenceSha256']
            if grade == 'Legendary': assert r['balanceProposal']['relativeToEpic'] == 1.4 / 1.28
            if grade == 'Unique': assert r['displayMetadata']['requiredLevel'] == 60 and r['displayMetadata']['setName'] is None
    assert counts == {'shared': 11, 'knight': 8, 'elf': 7, 'dwarf': 7, 'mage': 7}, counts
    for a in json.loads((ROOT / folder / 'alpha-check.json').read_text()):
        assert a['hasAlpha']
for fid in families:
    assert len({hashes[(fid, g)] for g in GRADES}) == 4
for page in [ROOT / 'comparison.html', ROOT / 'index.html'] + [ROOT / f / 'index.html' for f in GRADES.values()]:
    parser = Links(); parser.base = page.parent; parser.feed(page.read_text())
assert (ROOT / 'comparison.html').read_text().count('<figure ') == 160
print('PASS: 160 unique labeled PNGs / 40 families / 240 proposal IDs; hashes, grade mapping, references, counts, alpha presence and local board links')
