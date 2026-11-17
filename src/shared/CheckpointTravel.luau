-- A saved clear belongs to one hero and difficulty. The main story owns a shared zone.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local Content,Progress=load('CampaignContent'),load('DeepwoodProgress')
local Expansion=load('CampaignExpansionCheckpoints')
local Areas=load('CampaignAreas')
local T={text={button='TRAVEL · %s',checkpoint='Travel to checkpoint',locked='Complete this region’s story to unlock travel.',
 ready='Return portal ready. Use the portal to travel to Eryn.',
 arrived='Checkpoint reached: %s.',unavailable='Checkpoint unavailable. Check story completion, combat, and save status.',
 portal='Return to Eryn',use='Travel to checkpoint'}}
local owners={}
for _,chapter in ipairs(Content.chapters)do
 if not chapter.side or not owners[chapter.zone]then owners[chapter.zone]=chapter end
end
function T.completed(s,zone)
 local owner=owners[zone]
 local clears=s and (s.checkpointClears or s.clears)
 return owner~=nil and clears~=nil and clears[owner.id]==true
end
function T.region(s,zone)
 if not T.completed(s,zone)then return nil end
 return {id=zone,zone=zone,chapterId=owners[zone].id,title=Content.zones[zone].name:upper()}
end
function T.report(s)
 local c=Content.byId['DW-07'];local g=Progress.goal(c,'restoration')
 if T.completed(s,'DW-03') and s.flags and s.flags['DW-07:separate'] and Progress.available(s,c,g)then
  return {id='DW-07:restoration',zone='DW-03',chapterId=c.id,title='ERYN',position=g.position}
 end
end
function T.list(s)
 local result={};if not s then return result end
 for zone in pairs(owners)do result[zone]=T.region(s,zone)end
 for id,row in pairs(Expansion.list(s))do
  if result[row.zone] and Areas.containsZone(Content.zones[row.zone],row.position[1],row.position[3])then result[id]=row end
 end
 local report=T.report(s);if report then result[report.id]=report end
 return result
end
function T.preferred(s,selected)
 local last=s and Content.mainChapters[s.main]
 return T.region(s,selected or (last and last.zone))
end
function T.allowed(s,id)
 if type(id)~='string' then return nil end
 if owners[id]then return T.region(s,id)end
 return T.list(s)[id]
end
return T
