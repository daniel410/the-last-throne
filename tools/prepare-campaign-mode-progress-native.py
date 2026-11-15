"""Pin mode progression sources and verify account transitions in isolated Studio."""
from pathlib import Path
import argparse

p = argparse.ArgumentParser()
p.add_argument('--preview', action='store_true')
args = p.parse_args()
paths = [
    'src/shared/CampaignModeProgress.luau', 'src/shared/AdventureRules.luau',
    'src/shared/Difficulty.luau', 'src/shared/ExpeditionPresentation.luau',
    'src/shared/ExpeditionText.luau', 'src/shared/LobbySideQuests.luau',
    'src/server/Inventory/InventoryRules.luau', 'src/server/Inventory/InventoryService.luau',
    'src/server/Network/ExpeditionService.luau', 'src/client/ExpeditionView.luau',
]
roots = {'shared': 'game.ReplicatedStorage.Shared', 'server': 'game.ServerScriptService.Server',
         'client': 'game.StarterPlayer.StarterPlayerScripts.Client'}
code = "assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\n"
for path in paths:
    parts = path.removesuffix('.luau').split('/')
    parent = roots[parts[1]] + ('.' + '.'.join(parts[2:-1]) if len(parts) > 3 else '')
    node = parent + '.' + parts[-1]
    source = '[====[\n' + Path(path).read_text() + ']====]'
    if args.preview:
        code += f"if not {parent}:FindFirstChild('{parts[-1]}')then local m=Instance.new('ModuleScript');m.Name='{parts[-1]}';m.Parent={parent};end\n"
        code += f'{node}.Source={source}\n'
    else:
        code += f"assert({node}.Source=={source},'source mismatch: {path}')\n"
code += """for _,root in ipairs({game.ReplicatedStorage.Shared,game.ServerScriptService.Server,game.StarterPlayer.StarterPlayerScripts.Client})do
 for _,m in ipairs(root:GetDescendants())do if m:IsA('LuaSourceContainer')then assert(loadstring(m.Source,m:GetFullName()))end end
end
print('MODE_ALL_SOURCE_COMPILE true')
"""
def native_suite(path):
    suite = Path(path).read_text()
    for name in ('n', 'name'):
        suite = suite.replace(
            f"local function load({name})return dofile('src/shared/'..{name}..'.luau')end",
            f'local function load({name})return require(game.ReplicatedStorage.Shared[{name}])end')
    suite = suite.replace("dofile('src/server/Inventory/InventoryRules.luau')", 'require(game.ServerScriptService.Server.Inventory.InventoryRules)')
    suite = suite.replace("dofile('src/server/Inventory/AccountStore.luau')", 'require(game.ServerScriptService.Server.Inventory.AccountStore)')
    return suite.replace(';io.stdout:flush()', '')


suite = native_suite('tests/campaign-mode-progress.spec.lua')
suite = suite.replace('p=finish(p,c,run);expectedGold=', 'p=finish(p,c,run);task.wait();expectedGold=')
code += 'do\n' + suite + "\nprint('MODE_PROFILE_BYTES '..#game.HttpService:JSONEncode(p))\nend\n"
code += 'do\n' + native_suite('tests/campaign-mode-migration.spec.lua') + '\nend\n'
suite = native_suite('tests/campaign-mode-legacy-replay.spec.lua')
suite = suite.replace('for i=1,21 do local c=C.legacyMainChapters[i]',
                      'for i=1,21 do task.wait();local c=C.legacyMainChapters[i]')
suite = suite.replace("hard=finish(hard,c,'legacy_hard');expectedGold=",
                      "hard=finish(hard,c,'legacy_hard');task.wait();expectedGold=")
suite = suite.replace(' check(profile.heroes.hero.expeditions.active.journal.clears[c.id]',
                      ' task.wait();check(profile.heroes.hero.expeditions.active.journal.clears[c.id]')
code += 'do\n' + suite + '\nend\n'
code += 'local routeResult=(function()\n' + Path('tests/campaign-combat-route-runtime-native.luau').read_text() + '\nend)()\n'
code += "print('CAMPAIGN_MODE_NATIVE_PASS true')\n"
target = Path('/tmp/tlt-campaign-mode-progress-native.luau')
target.write_text(code)
print(target)
