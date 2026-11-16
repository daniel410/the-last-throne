"""고정 빌드의 실제 모듈·GUI를 검증하는 격리 Studio 실행기를 준비한다."""
from pathlib import Path
import argparse
import re

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--ui-only',action='store_true')
args=parser.parse_args()

tests = [
    'gold-reward-tuning.spec.lua', 'campaign-mode-progress.spec.lua',
    'campaign-mode-migration.spec.lua', 'campaign-mode-legacy-replay.spec.lua',
    'economy.spec.lua', 'difficulty-reward-rates.spec.lua',
    'gold-diamond-tuning.spec.lua', 'expedition-presentation.spec.lua',
    'studio-test-defaults.spec.lua',
]
paths = [
    'src/shared/GoldRewardTuning.luau', 'src/shared/Difficulty.luau',
    'src/shared/AdventureRules.luau', 'src/shared/DeepwoodEncounterBalance.luau',
    'src/shared/DeepwoodQuestLog.luau', 'src/shared/ExpeditionPresentation.luau',
    'src/shared/LobbySideQuests.luau', 'src/server/Inventory/InventoryRules.luau',
    'src/server/Inventory/InventoryService.luau', 'src/server/Inventory/StudioTestRules.luau',
    'src/server/Story/DeepwoodService.luau', 'src/client/DeepwoodQuestBook.luau',
    'src/client/DeepwoodJournal.luau', 'src/client/LobbyQuestJournal.luau',
]
roots = {'shared': 'game.ReplicatedStorage.Shared', 'server': 'game.ServerScriptService.Server',
         'client': 'game.StarterPlayer.StarterPlayerScripts.Client'}


def node(path):
    parts = path.removesuffix('.luau').split('/')
    return roots[parts[1]] + ''.join('[' + repr(p) + ']' for p in parts[2:])


code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local Place only')\n"
for path in paths:
    code += f"assert({node(path)}.Source==[====[\n{Path(path).read_text()}]====],'source mismatch: {path}')\n"
code += """local compiled=0
for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then
  assert(loadstring(m.Source,m:GetFullName()));compiled=compiled+1;if compiled%100==0 then task.wait()end
 end end
end
assert(require(game.ReplicatedStorage.Shared.Difficulty).version==19)
print('GOLD_TUNING_SOURCE_COMPILE '..compiled)
"""
for name in ([] if args.ui_only else tests):
    suite = (Path('tests') / name).read_text()
    suite = re.sub(r"dofile\('(src/(?:shared|server)/[^']+\.luau)'\)",
                   lambda m: 'require(' + node(m[1]) + ')', suite)
    for param in ('n', 'name'):
        suite = suite.replace(f"dofile('src/shared/'..{param}..'.luau')",
                              f'require(game.ReplicatedStorage.Shared[{param}])')
    suite = suite.replace(';io.stdout:flush()', ';task.wait()')
    suite = suite.replace("local f = assert(io.open('src/server/Inventory/InventoryService.luau')); local source = f:read('*a'); f:close()",
                          'local source=game.ServerScriptService.Server.Inventory.InventoryService.Source')
    suite = suite.replace('checks=checks+1;', 'checks=checks+1;if checks%100==0 then task.wait()end;')
    assert 'dofile(' not in suite and re.search(r'\bio\.', suite) is None, name
    code += f"do\n{suite}\nend\nprint('GOLD_TUNING_SUITE_PASS {name}');task.wait()\n"
code += 'local ui=(function()\n' + Path('tests/quest-reward-ui-native.luau').read_text() + '\nend)()\n'
code += "print('GOLD_REWARD_TUNING_NATIVE_PASS '..game.HttpService:JSONEncode({compiled=compiled,uiChecks=ui.checks,published=false}))\n"
target = Path('/tmp/tlt-gold-reward-tuning-native.luau')
target.write_text(code)
print(target)
