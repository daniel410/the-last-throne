-- Preserve the original Deepwood module for its world authoring and old saves.
local function load(name)return game and require(script.Parent[name]) or dofile('src/shared/'..name..'.luau')end
local base=load('DeepwoodContent')
local C={chapters={},zones={},byId={},mainChapters={},mainCount=14,maxStoryGold=5650}
for k,v in pairs(base)do if C[k]==nil then C[k]=v end end
for _,c in ipairs(base.chapters)do table.insert(C.chapters,c);C.byId[c.id]=c;if not c.side then C.mainChapters[c.number]=c end end
for id,z in pairs(base.zones)do C.zones[id]=z end
local frozen=load('FrozenValeContent')
for _,c in ipairs(frozen.chapters)do table.insert(C.chapters,c);C.byId[c.id]=c;if not c.side then C.mainChapters[c.number]=c end end
for id,z in pairs(frozen.zones)do C.zones[id]=z end
return C
