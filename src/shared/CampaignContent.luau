-- Preserve the original Deepwood module for its world authoring and old saves.
local function load(name)return game and require(script.Parent[name]) or dofile('src/shared/'..name..'.luau')end
local base=load('DeepwoodContent')
local C={chapters={},zones={},byId={},mainChapters={},mainCount=21,maxStoryGold=10290}
for k,v in pairs(base)do if C[k]==nil then C[k]=v end end
for _,c in ipairs(base.chapters)do table.insert(C.chapters,c);C.byId[c.id]=c;if not c.side then C.mainChapters[c.number]=c end end
for id,z in pairs(base.zones)do C.zones[id]=z end
local frozen=load('FrozenValeContent')
for _,c in ipairs(frozen.chapters)do table.insert(C.chapters,c);C.byId[c.id]=c;if not c.side then C.mainChapters[c.number]=c end end
for id,z in pairs(frozen.zones)do C.zones[id]=z end
local ember=load('EmberCalderaContent')
for _,c in ipairs(ember.chapters)do table.insert(C.chapters,c);C.byId[c.id]=c;if not c.side then C.mainChapters[c.number]=c end end
for id,z in pairs(ember.zones)do C.zones[id]=z end
C.epics={{region='Deepwood',title='FRIENDS OF THE FOREST',promise='Rescue the missing convoy and close the monster portal.',hub='DW-03'},{region='Frozen Vale',title='BEYOND THE BLIZZARD',promise='Rescue the travelers, reconnect the shelters, and calm the ice guardians.',hub='FV-02'},{region='Ember Caldera',title='THE GREAT FURNACE',promise='Rescue the miners, repair the cooling machines, and reclaim the great furnace.',hub='EC-02'}}
return C
