-- Translate whole epics after authoring, preserving every local story layout.
-- Deepwood stays fixed; each following region begins north of the previous one.
local O={version=1,gap=160}
local pointKeys={center=true,originalCenter=true,position=true,offerPosition=true,entry=true,rampStart=true,rampEnd=true}
function O.install(C)
 C.overlandLinks={};C.epicOffsets={[1]={0,0,0}}
 local function extent(epic)
  local north,south=math.huge,-math.huge
  local function rect(a)north=math.min(north,a.center[3]-a.size[2]/2);south=math.max(south,a.center[3]+a.size[2]/2)end
  for _,z in pairs(C.zones)do if z.epic==epic then
   rect(z);for _,a in ipairs(z.expansionAreas or {})do rect(a);rect(a.connector)end
  end end
  return north,south
 end
 for epic=2,#C.epics do
  local previous=C.mainChapters[(epic-1)*7];local first=C.mainChapters[(epic-1)*7+1]
  local a,b=C.zones[previous.zone],C.zones[first.zone]
  local north=extent(epic-1);local _,south=extent(epic)
  local delta={a.center[1]-b.center[1],a.center[2]-b.center[2],north-O.gap-south}
  C.epicOffsets[epic]=delta
  local visited={}
  local function point(p)
   if visited[p]then return end;visited[p]=true
   for axis=1,3 do p[axis]=p[axis]+delta[axis]end
  end
  local function walk(t)
   if visited[t]then return end;visited[t]=true
   for key,value in pairs(t)do if type(value)=='table'then
    if pointKeys[key]then point(value)
    elseif key=='points'or key=='easyPoints'or key=='worldPoints'then for _,p in ipairs(value)do point(p)end
    else walk(value)end
   end end
  end
  for _,z in pairs(C.zones)do if z.epic==epic then walk(z)end end
  for _,c in ipairs(C.chapters)do if c.epic==epic then walk(c)end end
  table.insert(C.overlandLinks,{previous.zone,first.zone})
 end
end
return O
