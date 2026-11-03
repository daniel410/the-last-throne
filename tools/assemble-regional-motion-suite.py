"""Build a motion-scoped Studio suite from saved tests; does not run unrelated story-save mocks."""
from pathlib import Path
import argparse
p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);p.add_argument('--output',type=Path,required=True);a=p.parse_args();parts=[]
for region in ['frozen-vale','ember-caldera']:
 s=(a.root/'tests'/f'{region}-native.luau').read_text();boundary=s.index(' -- Saved personal');s=s[:boundary]+s[s.rindex('end,debug.traceback)'):];s=s.replace(';return report',";assert(report.pass,'regional motion regression failed')");parts.append('do\n'+s+'\nend')
for name in ['regional-individual-review-native.luau','deepwood-individual-review-native.luau','enemy-streaming-presentation-native.luau','battle-bootstrap-native.luau']:
 parts.append('do\n'+(a.root/'tests'/name).read_text()+'\nend')
a.output.write_text('\n'.join(parts));print(a.output)
