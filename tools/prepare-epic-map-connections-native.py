"""격리 Studio 호스트에 지도 후보를 주입하고 에픽 연결 표시를 검증한다."""
from pathlib import Path
import hashlib
import json

paths = [
    'src/client/DeepwoodMap.luau', 'src/client/DeepwoodMapCanvas.luau',
    'src/client/LobbyAtlas.luau', 'src/shared/CampaignMapScope.luau',
    'src/shared/K0Text.luau',
]
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated host only')\n"
for path in paths:
    p = Path(path)
    base = 'game.ReplicatedStorage.Shared' if p.parts[1] == 'shared' else 'game.StarterPlayer.StarterPlayerScripts.Client'
    code += f'{base}.{p.stem}.Source={json.dumps(p.read_text(), ensure_ascii=False)}\n'
code += """for _,root in ipairs({game.ReplicatedStorage.Shared,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do
  if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end
 end
end
print('EPIC_MAP_COMPILE_PASS')
"""
suite = 'tests/epic-map-connections-native.luau'
code += Path(suite).read_text()
out = Path('/tmp/tlt-map-connections-native.luau')
out.write_text(code)
out.with_suffix('.inputs.json').write_text(json.dumps({p: hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in paths + [suite]}, indent=2) + '\n')
print(out)
