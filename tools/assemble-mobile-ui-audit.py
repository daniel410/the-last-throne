"""Assemble isolated native GUI regressions for a committed single-build artifact."""
from pathlib import Path
import argparse

ROOT = Path(__file__).resolve().parents[1]
p = argparse.ArgumentParser()
p.add_argument('--output', type=Path, required=True)
args = p.parse_args()
names = [
    'mobile-ui-audit', 'mobile-landscape-details', 'mobile-menu-stats',
    'inventory-mobile-layout', 'lobby-panel-size', 'lobby-atlas',
    'lobby-quest-journal', 'daily-login-ui', 'supporter-details',
    'shop-affordability', 'lobby-top-menu', 'lobby-wallet', 'lobby-hero-dock',
]
parts = ["local results={}\nlocal passed=true"]
for name in names:
    source = (ROOT / 'tests' / f'{name}-native.luau').read_text()
    parts.append(f"""
print('AUDIT_BEGIN {name}')
do
 local ok,result=xpcall(function()
{source}
 end,debug.traceback)
 local pass=ok and (type(result)~='table' or result.pass~=false)
 passed=passed and pass
 table.insert(results,{{name='{name}',pass=pass}})
 print('AUDIT_RESULT {name} '..tostring(ok)..' '..(type(result)=='table' and game.HttpService:JSONEncode(result) or tostring(result)))
end
""")
source = (ROOT / 'tests' / 'checkpoint-map-native.luau').read_text()
parts.append("""
do
 local f=(function()
""" + source + """
 end)()
 local client=game.StarterPlayer.StarterPlayerScripts.Client
 local ui=game.ReplicatedStorage.Shared.TDUI
 local ok,result=xpcall(function()return f(client.DeepwoodMap.Source,client.TDInventoryTheme.Source,ui.StatusWindowArtAssets.Source,ui.UIIconAssets.Source)end,debug.traceback)
 passed=passed and ok
 table.insert(results,{name='checkpoint-map',pass=ok})
 print('CHECKPOINT_AUDIT '..tostring(ok)..' '..tostring(result))
end
print('MOBILE_UI_SUITE '..game.HttpService:JSONEncode({pass=passed,results=results}))
assert(passed,'Mobile UI regressions failed; see individual reports')
""")
args.output.write_text('\n'.join(parts))
print(args.output)
