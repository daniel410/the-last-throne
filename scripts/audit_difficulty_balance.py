"""Audit authored encounters; output only to an explicit non-canonical path."""
import argparse,csv,io,json,subprocess,os
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--output',required=True);p.add_argument('--baseline-dir');a=p.parse_args()
env=os.environ.copy()
if a.baseline_dir:env['TLT_BALANCE_BASELINE']=str(Path(a.baseline_dir).resolve())
r=subprocess.run(['lua','scripts/audit_difficulty_balance.lua'],capture_output=True,text=True,env=env,check=True)
rows=list(csv.DictReader(io.StringIO(r.stdout),delimiter='\t'))
for row in rows:
 for key in row:
  if key not in ('mission','mode'):row[key]=int(row[key])
data={'scope':'planned finite enemies including reinforcements and elites; rewards per hero; not measured clear time','baseline':bool(a.baseline_dir),'rows':rows}
Path(a.output).write_text(json.dumps(data,indent=2)+'\n')
print(json.dumps({'rows':len(rows),'output':a.output}))
