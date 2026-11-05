#!/usr/bin/env python3
"""Prepare the isolated stat fixture; no game build, publication or source edits.
Pass --output-dir as for make_k0_source_probe.py. Large unrelated enemy clips
exceed Studio plugin Source limits and are not dependencies of this test.
"""
from pathlib import Path
import sys
source = Path(__file__).with_name('make_k0_source_probe.py').resolve()
text = source.read_text()
needle = "    variable = {'shared': 'shared', 'server': 'server', 'client': 'client'}[tree[0]]"
assert text.count(needle) == 1
text = text.replace(needle, """    if tree[0] not in ('shared', 'server', 'client') or source.name in ('FrozenValeClips.luau', 'EmberCalderaClips.luau', 'K0EnemyClips.luau'):
        continue
""" + needle)
sys.argv += ['--test-script', 'tests/hero-stat-effects-native.luau']
exec(compile(text, str(source), 'exec'), {'__file__': str(source), '__name__': '__main__'})
