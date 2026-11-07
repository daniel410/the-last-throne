"""Bundle the account migration spec with a native world test; no live saves."""
from pathlib import Path
import json
spec=Path('tests/campaign-reorder.spec.lua').read_text()
code='''assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated fixture required')
local function file(path)
 local node
 if path:sub(1,11)=='src/shared/'then node=game.ReplicatedStorage.Shared
 elseif path:sub(1,11)=='src/server/'then node=game.ServerScriptService.Server
 else error('Unsupported test path '..path)end
 local rest=path:sub(12):gsub('%.luau$','')
 for part in rest:gmatch('[^/]+')do node=assert(node:FindFirstChild(part),path)end
 return require(node)
end
'''
code+='local spec=assert(loadstring('+json.dumps(spec)+",'@tests/campaign-reorder.spec.lua'))\n"
code+="setfenv(spec,setmetatable({dofile=file},{__index=getfenv()}));spec()\n"
code+=Path('tests/campaign-reorder-native.luau').read_text()
Path('/tmp/tlt-campaign-reorder-native.luau').write_text(code)
print('/tmp/tlt-campaign-reorder-native.luau')
