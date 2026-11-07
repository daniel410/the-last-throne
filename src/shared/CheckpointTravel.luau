-- Saved objective flags unlock travel; client coordinates never grant access.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local Content,Progress=load('CampaignContent'),load('DeepwoodProgress')
local T={text={button='TRAVEL · %s',locked='COMPLETE THIS STORY TO UNLOCK TRAVEL',
 ready='Return portal ready. Use the portal or open MAP [M] to travel to Eryn.',
 arrived='Checkpoint reached: %s.',unavailable='Checkpoint travel is unavailable. Finish the current encounter and wait for progress to save.',
 portal='Return to Eryn',use='Travel to checkpoint'}}
function T.report(s)
 local c=Content.byId['DW-07'];local g=Progress.goal(c,'restoration')
 if s and s.flags and s.flags['DW-07:separate'] and Progress.available(s,c,g)then
  return {id='DW-07:restoration',zone='DW-03',chapterId=c.id,title='ERYN',position=g.position}
 end
end
function T.list(s)
 local result={};if not s then return result end
 local current=s.expeditionMission and Content.byId[s.expeditionMission]
 local epic=(current or Content.mainChapters[math.min(Content.mainCount,s.main+1)]).epic or 1
 for _,c in ipairs(Content.mainChapters)do
  if (c.epic or 1)==epic and s.clears[c.id]then
   result[c.zone]={id=c.zone,zone=c.zone,chapterId=c.id,title=c.title:upper()}
  end
 end
 local report=T.report(s);if report then result[report.id]=report end
 return result
end
function T.preferred(s,selected)
 local all=T.list(s);local report=all['DW-07:restoration']
 -- The report shortcut remains visible while the map opens on the uncleared altar.
 if report and (not selected or selected=='DW-03'or selected=='DW-07')then return report end
 if selected then return all[selected]end
 local current=Content.mainChapters[s and s.main or 0]
 return current and all[current.zone]
end
function T.allowed(s,id)return type(id)=='string'and T.list(s)[id]or nil end
return T
