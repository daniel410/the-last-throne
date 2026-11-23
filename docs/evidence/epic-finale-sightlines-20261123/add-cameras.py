"""Insert fixed diagnostic views into the existing finale audit."""
import json
from pathlib import Path
import sys

audit, views = map(Path, sys.argv[1:])
script = audit.read_text()
marker = "local baseplate = workspace:FindFirstChild('Baseplate')"
assert script.count(marker) == 1
camera_json = json.dumps(json.dumps(json.loads(views.read_text())))
insert = f"for _, shot in ipairs(game.HttpService:JSONDecode({camera_json})) do table.insert(cameras, shot) end"
audit.write_text(script.replace(marker, insert + '\n\n' + marker))
