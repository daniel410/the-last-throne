"""로컬 격리 Studio에서 소스 변경 없이 실행하는 HP/MP 회귀 검사."""
from pathlib import Path
import json

paths = [
    'src/shared/HeroVitals.luau',
    'src/server/Combat/CombatService.luau',
    'src/server/Inventory/InventoryRules.luau',
    'src/server/Inventory/InventoryService.luau',
    'src/server/Lobby/HeroSessionService.luau',
    'src/server/init.server.luau',
]
code = 'assert(game.PlaceId==0 and #game.Players:GetPlayers()==0)\n'
code += 'local CandidateVitalsSource=' + json.dumps(Path(paths[0]).read_text()) + '\n'
source = Path(paths[1]).read_text()
setup = source[source.index('local Vitals=require('):source.index('local function setupPlayer')]
code += 'local CandidateCombatSetup=' + json.dumps(setup) + '\n'
code += Path('tests/hero-vitals-native.luau').read_text()
Path('/tmp/tlt-hero-vitals-native.luau').write_text(code)
