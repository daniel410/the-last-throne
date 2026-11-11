-- Spatial plans consume the exact production packs, never a reduced population.
local Population=game and require(script.Parent.EncounterPopulation)or dofile('src/shared/EncounterPopulation.luau')
local R={version=1,ruleVersion=14,spacing=92,approach=38}
local names={
 DW={'Convoy woodland trail','Broken-cart approach','Sanctuary paths','Watchtower approaches','Occupied keep perimeter','Twisted root trail','Altar approach'},
 GW={'Scout lantern trail','Silken watch road','Refuge approaches','Hollowbark rootway','Venomcoil banks','Scout extraction route','Northern ridge'},
 FV={'Snowbound pass','Hearth approaches','Glacier switchbacks','Archive approach','Frozen procession','Sentinel causeway','Palace approach'},
 EC={'Ash freight road','Workshop approaches','Braced mine road','Cooling channels','Foundry circuit','Heatworks gallery','Great furnace approach'},
 HG={'Lantern procession','Keepers approach','Garden of names','Fallen belfry road','Royal gate approach','Royal tomb causeway','Last throne approach'},
}
local function distance(a,b)return math.sqrt((a[1]-b[1])^2+(a[3]-b[3])^2)end
R.distance=distance
function R.enabled(version)return type(version)=='number'and version>=R.ruleVersion end
function R.killId(c,g,launch,spec)
 return (launch and c.id~=launch and c.id..':'or '')..g.id..'_'..assert(spec.killIndex)
end
function R.install(C)
 local pools,reserved,used={},{},{}
 local ids={};for id in pairs(C.zones)do ids[#ids+1]=id end;table.sort(ids)
 for _,id in ipairs(ids)do
  local z=C.zones[id];local pool={};pools[id]=pool;reserved[id]={};used[id]={}
  local nx,nz=math.floor((z.size[1]-100)/R.spacing),math.floor((z.size[2]-100)/R.spacing)
  for row=0,nz do for column=0,nx do
   -- Offset alternate rows: a trail through clearings, rather than a room grid.
   local x=z.center[1]+(column-nx/2)*R.spacing+(row%2==0 and -1 or 1)*8
   local zz=z.center[3]+(row-nz/2)*R.spacing
   pool[#pool+1]={x,z.center[2],zz}
  end end
 end
 for id,z in pairs(C.zones)do for _,area in ipairs(z.expansionAreas or {})do reserved[id][#reserved[id]+1]={point=area.entry,radius=76}end end
 for _,c in ipairs(C.chapters)do for _,g in ipairs(c.goals)do
  if #g.enemies>0 then reserved[c.zone][#reserved[c.zone]+1]={point=g.position,radius=80,combat=true}
  else reserved[c.zone][#reserved[c.zone]+1]={point=g.position,radius=32}end
  for _,step in ipairs(g.activity and g.activity.steps or {})do if step.position then
   reserved[c.zone][#reserved[c.zone]+1]={point=step.position,radius=30}
  end end
 end end
 for _,c in ipairs(C.chapters)do
  local prefix=c.id:sub(1,2);local number=tonumber(c.id:match('%-(%d+)$'))
  c.combatRoutes={}
  for _,g in ipairs(c.goals)do if #g.enemies>0 then
   local maximum=0;local counts={};local boss=false
   for party=1,4 do local waves=Population.encounterWaves(c,g,party);counts[party]=#waves;maximum=math.max(maximum,#waves)
    for _,batch in ipairs(waves)do for _,spec in ipairs(batch)do if Population.isBoss(spec.kind)then boss=true end end end
   end
   local route={points={},counts=counts,title=number and names[prefix][number]or g.title,goalId=g.id,chapterId=c.id}
   local previous=g.position
   if not boss then route.points[1]=g.position end
   local amount=maximum-(boss and 1 or 0)
   while #route.points<amount do
    local best,score
    for _,p in ipairs(pools[c.zone])do
     local free=true
     for _,a in ipairs(reserved[c.zone])do if distance(p,a.point)<a.radius then free=false;break end end
     if free then for _,p2 in ipairs(used[c.zone])do if distance(p,p2)<80 then free=false;break end end end
     if free then
      local value=distance(p,previous)+distance(p,g.position)*.08
      if not score or value<score then best,score=p,value end
     end
    end
    assert(best,'Insufficient distinct combat ground: '..c.id..':'..g.id)
    route.points[#route.points+1]=best;used[c.zone][#used[c.zone]+1]=best;previous=best
   end
   if boss then
    local reversed={};for i=#route.points,1,-1 do reversed[#reversed+1]=route.points[i]end
    reversed[#reversed+1]=g.position;route.points=reversed
   end
   assert(#route.points==maximum,'Combat route must preserve all packs')
   c.combatRoutes[g.id]=route
  end end
 end
end
function R.plan(c,g,version)return R.enabled(version)and c.combatRoutes and c.combatRoutes[g.id]or nil end
function R.points(c,g,count,version)
 local plan=R.plan(c,g,version);if not plan then return nil end
 assert(count>=1 and count<=#plan.points,'Unsupported combat route length')
 local points={}
 for i=1,count do points[i]=plan.points[i==count and #plan.points or i]end
 return points
end
-- Recover only packs with confirmed kill receipts. A partial or unconfirmed pack
-- is replayed, and the existing kill IDs still prevent duplicate rewards.
function R.clearedPrefix(c,g,batches,run)
 local cleared=0
 for _,batch in ipairs(batches)do
  for _,spec in ipairs(batch)do if not (run and run.kills and run.kills[R.killId(c,g,run.missionId,spec)])then return cleared end end
  cleared=cleared+1
 end
 return cleared
end
function R.entry(c,g,run,partySize)
 local plan=R.plan(c,g,run and run.balanceVersion);if not plan then return nil end
 local batches=Population.encounterWaves(c,g,partySize or 1)
 local points=R.points(c,g,#batches,run.balanceVersion)
 return points[math.min(#points,R.clearedPrefix(c,g,batches,run)+1)]
end
return R
