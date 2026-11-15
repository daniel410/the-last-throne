"""출발 안내를 격리된 Studio UI에서 검사한다. 게시/저장/Teleport는 실행하지 않는다."""
from pathlib import Path
import json
import runpy
ns = runpy.run_path('tools/review-expedition-ui.py')
code = ns['code'].split('local view=req')[0]
code = code.replace("TLT_ExpeditionUIReview", "TLT_AdventureStartingQA")
code += "\nlocal test=assert(loadstring(" + json.dumps(Path('tests/adventure-starting-native.luau').read_text()) + "))()\n"
code += "local ok,result=xpcall(function()return test(req(tree.src.client.AdventureStartingNotice),req(tree.src.client.ExpeditionView),root,actor,signal)end,debug.traceback)\ngui:Destroy();signal:Destroy();assert(ok,result);print(originalGame:GetService('HttpService'):JSONEncode(result))\n"
Path('builds/adventure-starting-test.luau').write_text(code)
