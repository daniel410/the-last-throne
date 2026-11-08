local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local C,P=load('CampaignContent'),load('DeepwoodProgress')
local E={}
function E.respawn(s,c)
 if not s or s.expansionVersion~=1 or not c or s.clears[c.id]then return nil end
 for i=#(c.expansionGoals or {}),1,-1 do
  local g=c.expansionGoals[i];local key=c.id..':'..g.id
  local count=(s.activities or {})[key]or 0
  if s.flags[key]and not (s.expansionWaivers or {})[key]or count>0 then
   local index=math.max(1,math.min(#g.activity.steps,count))
   if g.activity.mode=='investigate'then for n in ipairs(g.activity.steps)do if P.collected(s,c,g,n)then index=n end end end
   return {position=g.activity.steps[index].position,chapterId=c.id,goalId=g.id}
  end
 end
end
function E.list(s)
 local result={};if not s or s.expansionVersion~=1 then return result end
 local current=s.expeditionMission and C.byId[s.expeditionMission]or C.mainChapters[math.min(C.mainCount,s.main+1)]
 for _,c in ipairs(C.chapters)do if c.epic==current.epic then for _,g in ipairs(c.expansionGoals or {})do
  if s.flags[c.id..':'..g.id]then
   local area;for _,a in ipairs(C.zones[c.zone].expansionAreas or {})do if a.id==g.area then area=a end end
   local id=c.id..':'..g.id
   result[id]={id=id,zone=c.zone,chapterId=c.id,title=area.name:upper(),position=g.activity.steps[#g.activity.steps].position}
   local exit='exit:'..id
   result[exit]={id=exit,zone=c.zone,chapterId=c.id,title='RETURN TO THE MAIN ROUTE',position=area.entry,exit=true}
  end
 end end end
 return result
end
return E
