"""Read-only validation of the delivered modeling reference files."""
import hashlib
import json
import sys
import zipfile
from collections import Counter
from pathlib import Path

folder = Path(__file__).resolve().parent
sys.path.insert(0, str(folder.parents[2]))
from scripts.validate_weapon_cutout_pngs import alpha_stats

records = json.loads((folder / 'manifest.json').read_text())['records']
assert len(records) == 12
assert Counter(r['family'] for r in records) == {'traveler': 4, 'tempered': 4, 'veteran': 4}
assert Counter(r['file'].split('_')[0] for r in records) == {'knight': 3, 'elf': 3, 'dwarf': 3, 'mage': 3}
assert len({r['sha256'] for r in records}) == 12
report = []
with zipfile.ZipFile(folder / 'TLT-Basic-Weapons-12.zip') as archive:
    assert archive.testzip() is None
    assert sorted(archive.namelist()) == sorted(r['file'] for r in records)
    for record in records:
        name = record['file']
        assert hashlib.sha256((folder / name).read_bytes()).hexdigest() == record['sha256']
        assert hashlib.sha256(archive.read(name)).hexdigest() == record['sha256']
        stats = alpha_stats(folder / name)
        assert stats['size'] == [1024, 1536]
        assert stats['minAlpha'] == 0 and stats['maxAlpha'] >= 250 and stats['transparentPct'] > 40
        left, top, right, bottom = stats['opaqueBounds']
        assert left > 4 and top > 4 and right < 1019 and bottom < 1531
        report.append({'file': name, **stats})
assert report == json.loads((folder / 'alpha-report.json').read_text())
print('PASS: 12 PNGs, alpha/bounds/SHA-256, 4 weapons x 3 families, ZIP CRC and hashes')
