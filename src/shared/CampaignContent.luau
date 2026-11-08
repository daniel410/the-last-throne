-- Authoring modules retain their old order for saved-run compatibility.
-- This projection owns the current campaign order; stable chapter/goal IDs never move.
local function load(name)return game and require(script.Parent[name]) or dofile('src/shared/'..name..'.luau')end
local function copy(v)if type(v)~='table'then return v end;local n={};for k,x in pairs(v)do n[k]=copy(x)end;return n end
local base=load('DeepwoodContent')
local C={chapters={},zones={},byId={},mainChapters={},legacyMainChapters={},mainCount=35,maxStoryGold=16570,orderVersion=2,edges={}}
for k,v in pairs(base)do if C[k]==nil then C[k]=copy(v)end end
local routes={DW={epic=1,offset=0,shift=0},GW={epic=2,offset=7,shift=-16},FV={epic=3,offset=14,shift=7},EC={epic=4,offset=21,shift=7},HG={epic=5,offset=28,shift=4}}
local modules={base,load('FrozenValeContent'),load('EmberCalderaContent'),load('LateEpicContent')}
for _,source in ipairs(modules)do
 for _,original in ipairs(source.chapters)do
  local c=copy(original);local route=assert(routes[c.id:sub(1,2)])
  c.legacyNumber=c.number;c.legacyEpic=c.epic or 1;c.legacyMinMain=c.minMain
  local oldOffset=(c.legacyEpic-1)*7
  c.epic=route.epic
  c.number=c.side and 0 or route.offset+(c.legacyNumber-oldOffset)
  c.minMain=c.side and route.offset+(c.minMain-oldOffset)or c.number-1
  for _,g in ipairs(c.goals)do
   if g.minMain then g.legacyMinMain=g.minMain;g.minMain=route.offset+(g.minMain-oldOffset)end
   local function units(specs)for _,unit in ipairs(specs or {})do unit.legacyLevel=unit.level;unit.level=math.max(1,unit.level+route.shift)end end
   units(g.enemies)
   for _,wave in ipairs(g.bossEncounter and g.bossEncounter.waves or {})do units(wave.enemies)end
  end
  table.insert(C.chapters,c);C.byId[c.id]=c
  if not c.side then C.mainChapters[c.number]=c;C.legacyMainChapters[c.legacyNumber]=c end
 end
 for id,original in pairs(source.zones)do
  local z=copy(original);local route=assert(routes[id:sub(1,2)]);local oldEpic=z.epic or 1
  z.legacyRequiresMain=z.requiresMain;z.epic=route.epic
  z.requiresMain=route.offset+(z.requiresMain-(oldEpic-1)*7)
  C.zones[id]=z
 end
end
table.sort(C.chapters,function(a,b)
 if a.epic~=b.epic then return a.epic<b.epic end
 if a.side~=b.side then return not a.side end
 if a.number~=b.number then return a.number<b.number end
 return a.id<b.id
end)
C.epics={
 {region='Deepwood',title='FRIENDS OF THE FOREST',promise='Rescue the missing convoy and follow the Crownheart trail into Gloamwood.',hub='DW-03'},
 {region='Gloamwood',title='ONE BRAVE STEP',promise='Rescue the scouts and reopen the northern road to Frozen Vale.',hub='GW-03'},
 {region='Frozen Vale',title='BEYOND THE BLIZZARD',promise='Rescue the travelers, calm the guardians, and follow the delivery records to Ember Caldera.',hub='FV-02'},
 {region='Ember Caldera',title='THE GREAT FURNACE',promise='Save the city and uncover Veyr\'s invasion plans and the royal tomb approach.',hub='EC-02'},
 {region='Haunted Graveyard',title='TOGETHER WE BRING BACK THE LIGHT',promise='Stop Veyr, recover the Crownheart, and save Dawnspire.',hub='HG-02'},
}
for i=1,C.mainCount-1 do table.insert(C.edges,{C.mainChapters[i].zone,C.mainChapters[i+1].zone})end
for _,source in ipairs(modules)do for _,edge in ipairs(source.edges or {})do
 if edge[1]:sub(1,2)==edge[2]:sub(1,2)and (edge[1]:find('%-S')or edge[2]:find('%-S'))then table.insert(C.edges,copy(edge))end
end end
for _,edge in ipairs({{'DW-03','DW-S1'},{'DW-03','DW-S2'},{'DW-05','DW-S3'}})do table.insert(C.edges,edge)end
-- Existing saves keep access to already unlocked regions while filling the new GW gap.
function C.accessible(s,required,legacyRequired)
 if not s then return false end
 if s.version==1 then return s.main>=(legacyRequired or required)end
 return s.main>=required or s.legacyMain~=nil and s.legacyMain>=(legacyRequired or required)
end
function C.region(prefix)
 local r={chapters={},zones={},edges={}}
 for _,c in ipairs(C.chapters)do if c.id:sub(1,2)==prefix then table.insert(r.chapters,c)end end
 for id,z in pairs(C.zones)do if id:sub(1,2)==prefix then r.zones[id]=z end end
 for _,edge in ipairs(C.edges)do if r.zones[edge[1]]and r.zones[edge[2]]then table.insert(r.edges,edge)end end
 return r
end
load('CampaignStoryText').install(C)
load('QuestCompletionRewards').install(C)
return C
