from pathlib import Path
import re
s=Path('tests/optional-epic-continuation.spec.lua').read_text()
s=re.sub(r"dofile\('src/shared/([A-Za-z0-9_]+)\.luau'\)",r'require(game.ReplicatedStorage.Shared.\1)',s)
s=s.replace("dofile('src/server/Inventory/InventoryRules.luau')",'require(game.ServerScriptService.Server.Inventory.InventoryRules)')
s="assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')\n"+s
s+='''
local side=assert(A.begin(prefixes[7],'hero','DW-Q3','Easy','native_side',prefixes[7].revision,R,C))
local gui=Instance.new('ScreenGui');gui.Name='OptionalContinuationBookQA';gui.Parent=game.CoreGui
local book=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodQuestBook).create(gui,function()end)
book.render({journal=A.projection(side.heroes.hero)})
local found=false
for _,label in ipairs(book.panel:GetDescendants())do if label:IsA('TextLabel')and label.Text=='CONTINUE MAIN STORY'then found=true end end
check(found,'actual main quest card offers continuation from an active side expedition')
gui:Destroy()
print('OPTIONAL_CONTINUATION_NATIVE '..game:GetService('HttpService'):JSONEncode({checks=n,pass=true}))
'''
Path('/tmp/tlt-optional-continuation-native.luau').write_text(s)
