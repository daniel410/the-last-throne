"""Prepare the seven existing server cases affected by dwarf cadence/damage."""
import hashlib
import json
import pathlib
import subprocess
import sys
root=pathlib.Path(__file__).resolve().parents[1]
out=pathlib.Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=True)
source=(root/'tests/k0-basic-attacks-native.luau').read_text()
selector="""local function case(name, body)
 if not (name:match('^dwarf%-reach%-') or name=='targeted-dwarf-turns-and-hits-selected' or name=='dwarf-impact-matches-downstroke' or name=='dwarf-melee-hit-deduplicate-and-buffer' or name=='dwarf-range-and-wall' or name=='dwarf-missed-active-window') then return end
"""
assert source.count('local function case(name, body)\n')==1
source=source.replace('local function case(name, body)\n',selector)
source='for _,s in game:GetDescendants()do if s:IsA("Script")or s:IsA("LocalScript")then s.Disabled=true end end\n'+source
(out/'server-probe.luau').write_text(source)
subprocess.run(['rojo','build','default.project.json','-o',str(out/'tlt-dwarf-tempo-empty.rbxlx')],cwd=root,check=True)
inputs=['tests/k0-basic-attacks-native.luau','tests/dwarf-basic-tempo-native.luau','src/shared/K0Config.luau','src/server/Combat/CombatService.luau']
(out/'test-inputs.json').write_text(json.dumps({p:hashlib.sha256((root/p).read_bytes()).hexdigest()for p in inputs},indent=2)+'\n')
print(out)
