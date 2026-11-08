-- Expansion content is gated by the admitted journal, never by array indices.
-- Core IDs/rewards/encounters remain intact for saved rules 1-12.
local Data=game and require(script.Parent.CampaignExpansionContent)or dofile('src/shared/CampaignExpansionContent.luau')
local E={version=1,ruleVersion=13}
local function copy(v)if type(v)~='table'then return v end;local t={};for k,x in pairs(v)do t[k]=copy(x)end;return t end
local function overlaps(a,b,margin)
 return math.abs(a.center[1]-b.center[1])<(a.size[1]+b.size[1])/2+margin and math.abs(a.center[3]-b.center[3])<(a.size[2]+b.size[2])/2+margin
end
function E.install(C)
 local used={};local ordered={};for _,c in ipairs(C.chapters)do table.insert(ordered,c)end
 table.sort(ordered,function(a,b)return a.id<b.id end)
 local function pocket(c,index,name)
  local z=C.zones[c.zone];local cx,y,cz=table.unpack(z.center);local hx,hz=z.size[1]/2,z.size[2]/2
  local candidates={}
  -- Different wings fit the reviewed zigzag campaign without moving old roads.
  for _,distance in ipairs({120,210,300})do
   for _,side in ipairs({index==1 and -1 or 1,index==1 and 1 or -1})do
    for _,shift in ipairs({0,-100,100,-180,180})do
     table.insert(candidates,{center={cx+side*(hx+distance),y,cz+shift},size={180,160},axis='x',side=side})
     table.insert(candidates,{center={cx+shift,y,cz+side*(hz+distance)},size={160,180},axis='z',side=side})
    end
   end
  end
  for _,a in ipairs(candidates)do
   local start=a.axis=='x'and {cx+a.side*(hx-20),y,a.center[3]}or {a.center[1],y,cz+a.side*(hz-20)}
   local connector={center={(start[1]+a.center[1])/2,y,(start[3]+a.center[3])/2},size={math.abs(start[1]-a.center[1])+32,math.abs(start[3]-a.center[3])+32}}
   local free=true
   for id,other in pairs(C.zones)do if id~=c.zone and (overlaps(a,other,18)or overlaps(connector,other,8))then free=false;break end end
   if free then for _,other in ipairs(used)do if overlaps(a,other,18)or overlaps(connector,other,0)or overlaps(a,other.connector,0)or other.zone~=c.zone and overlaps(connector,other.connector,0)then free=false;break end end end
   if free then
    local lower=name:lower()
    local rise=(lower:find('overlook',1,true)or lower:find('outlook',1,true)or lower:find('lookout',1,true)or lower:find('terrace',1,true))and 10
     or (lower:find('gallery',1,true)or lower:find('cellar',1,true)or lower:find('archive',1,true)or lower:find('crypt',1,true))and -10 or 0
    a.center[2]=y+rise
    local rampStart={start[1],y,start[3]}
    if a.axis=='x'then rampStart[1]=cx+a.side*hx else rampStart[3]=cz+a.side*hz end
    local rampEnd=copy(a.center)
    if a.axis=='x'then rampEnd[1]=rampEnd[1]-a.side*a.size[1]/2 else rampEnd[3]=rampEnd[3]-a.side*a.size[2]/2 end
    connector.rampStart=rampStart;connector.rampEnd=rampEnd
    a.zone=c.zone;a.name=name;a.id=c.id..':wing'..index;a.chapterId=c.id;a.entry=start;a.connector=connector
    table.insert(used,a);z.expansionAreas=z.expansionAreas or {};table.insert(z.expansionAreas,a);return a
   end
  end
  error('No safe expansion wing for '..c.id..' '..index)
 end
 C.expansionVersion=E.version
 for _,c in ipairs(ordered)do
  local rows=Data.chapters[c.id]
  assert(rows,'Missing expansion story '..c.id)
  c.coreGoals=copy(c.goals);c.expansionGoals={};local before={}
  for index,row in ipairs(rows)do
   local area=pocket(c,index,row.space)
   local gate;for _,g in ipairs(c.goals)do if g.id==row.before then gate=g end end
   assert(gate and not gate.optional,'Invalid expansion gate '..c.id..':'..row.before)
   local steps={};local offsets=row.mode=='escort'and {{-42,35},{0,0},{42,-35}}or {{-50,35},{40,25},{0,-45}}
   for n,s in ipairs(row.steps)do
    local offset=offsets[(n-1)%#offsets+1]
    steps[n]={id='step'..n,title=s[1],text=s[2],kind=s[3]or 'tracks',position={area.center[1]+offset[1],area.center[2],area.center[3]+offset[2]}}
   end
   local g={id='exp_'..index,title=row.title,text=row.outcome,position=copy(steps[1].position),requires=copy(gate.requires),enemies={},choice=false,
    optional=true,expansion=true,before=row.before,area=area.id,restoration=row.restoration or row.space,
    activity={mode=row.mode,actor=row.actor,steps=steps,clue=row.clue or row.title},result=row.result or 'route'}
   if row.mode=='escort'then g.position=copy(area.entry)end
   if before[row.before]then table.insert(g.requires,before[row.before][#before[row.before]].id)end
   before[row.before]=before[row.before]or {};table.insert(before[row.before],g);table.insert(c.expansionGoals,g)
   gate.expansionRequires=gate.expansionRequires or {};table.insert(gate.expansionRequires,g.id)
   area.goalId=g.id;area.mode=row.mode;area.result=g.result;area.outcome=row.outcome
  end
  local goals={}
  for _,g in ipairs(c.goals)do
   for _,event in ipairs(before[g.id]or {})do table.insert(goals,event)end
   table.insert(goals,g)
  end
  c.goals=goals
 end
end
return E
