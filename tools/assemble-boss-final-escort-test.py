from pathlib import Path
import json
paths=['src/server/Story/DeepwoodService.luau','src/shared/DeepwoodEncounterBalance.luau']
sources='local sources={'+','.join('['+json.dumps(p)+']='+json.dumps(Path(p).read_text(),ensure_ascii=False) for p in paths)+'}\n'
s=sources+'local test=('+Path('tests/boss-final-escort-native.luau').read_text().replace('return function(sources)','function(sources)',1)+')\n'
s+="print('BOSS_FINAL_ESCORT_NATIVE '..game:GetService('HttpService'):JSONEncode(test(sources)))\n"
Path('/tmp/tlt-boss-final-escort-native.luau').write_text(s)
