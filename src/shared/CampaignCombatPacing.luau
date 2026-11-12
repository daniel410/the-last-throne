-- Supplemental finite route encounters; old journals opt in with saved waivers.
local M={version=1}
local rows={
 {'GW-01','exp_2','lantern_patrol','Secure the lantern fork','Webling',3},
 {'GW-02','exp_2','rescue_patrol','Clear the scouts return path','Silkweaver',3},
 {'GW-04','lantern','root_patrol','Secure the far side of the rootway','Barkstalker',3},
 {'GW-05','rope','crossing_patrol','Protect the crossing rope','VenomcoilCentipede',3},
 {'GW-06','exp_2','escape_patrol',"Clear Finn's escape route",'Gloambat',3},
 {'GW-07','exit','ridge_patrol','Drive the hunters from the northern ridge','Silkweaver',3},
 {'EC-05','exp_2','vault_patrol','Secure the design vault departure','Golem',3},
 {'HG-01','shelter','shelter_patrol','Clear the last approach to the shelter','Skeleton',3},
 {'HG-03','passage','passage_patrol','Secure the hidden passage exit','Ghoul',3},
 {'HG-04','allies','gate_patrol','Protect the allies at the opened gate','SkeletonKnight',3},
 {'HG-05','east','device_patrol','Clear the eastern device approach','Hellhound',3},
 {'HG-06','seal','tomb_patrol','Secure the royal tomb seal','DeathKnight',3},
 {'HG-07','veyr','throne_patrol','Break through the last throne approach','DeathKnight',3},
}
local function copy(v)if type(v)~='table'then return v end;local t={};for k,x in pairs(v)do t[k]=copy(x)end;return t end
local function distance(a,b)return math.sqrt((a[1]-b[1])^2+(a[3]-b[3])^2)end
function M.install(C)
 for _,row in ipairs(rows)do
  local c=assert(C.byId[row[1]]);local index,gate
  for i,g in ipairs(c.goals)do if g.id==row[2]then index,gate=i,g;break end end
  assert(index and index>1,'Missing patrol gate '..c.id)
  local previous=c.goals[index-1];local zone=C.zones[c.zone]
  -- Choose supported core ground near the next objective, clear of existing anchors.
  local best,score
  for x=-2,2 do for z=-2,2 do
   local p={zone.center[1]+x*85,zone.center[2],zone.center[3]+z*75}
   local free=math.abs(p[1]-zone.center[1])<zone.size[1]/2-50 and math.abs(p[3]-zone.center[3])<zone.size[2]/2-50
   for _,g in ipairs(c.goals)do
    if distance(p,g.position)<82 then free=false end
    for _,s in ipairs(g.activity and g.activity.steps or {})do if s.position and distance(p,s.position)<42 then free=false end end
   end
   local value=distance(p,gate.position)+distance(p,previous.position)
   if free and (not score or value<score)then best,score=p,value end
  end end
  assert(best,'Missing supported patrol ground '..c.id)
  local level,legacyLevel
  for _,g in ipairs(c.goals)do for _,unit in ipairs(g.enemies)do
   if not level then level,legacyLevel=unit.level,unit.legacyLevel end
  end end
  local goal={id=row[3],title=row[4],text='The route is secure. Continue toward your friends.',position=best,
   requires={previous.id},enemies={{kind=row[5],level=assert(level),legacyLevel=legacyLevel,count=row[6]}},
   optional=true,pacing=true,before=gate.id,
   activity={mode='battle',intro='Clear the hunters ahead, then continue along the marked route.'}}
  gate.pacingRequires=gate.pacingRequires or {};table.insert(gate.pacingRequires,goal.id)
  table.insert(c.goals,index,goal);c.pacingGoals=c.pacingGoals or {};table.insert(c.pacingGoals,goal)
  for _,phase in ipairs(c.quest.phases or {})do for i,id in ipairs(phase.goals)do
   if id==gate.id then table.insert(phase.goals,i,goal.id);break end
  end end
 end
end
return M
