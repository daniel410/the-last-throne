from pathlib import Path
import json
paths=['src/server/Story/DeepwoodService.luau','src/shared/DeepwoodQuestLog.luau','src/client/DeepwoodQuestBook.luau']
sources='local sources={'+','.join('['+json.dumps(p)+']='+json.dumps(Path(p).read_text(),ensure_ascii=False) for p in paths)+'}\n'
s=sources+'local test=('+Path('tests/side-quest-review-native.luau').read_text().replace('return function(sources)','function(sources)',1)+')\n'
s+="print('SIDE_QUEST_REVIEW_NATIVE '..game:GetService('HttpService'):JSONEncode(test(sources)))\n"
Path('/tmp/tlt-side-quest-review-native.luau').write_text(s)
