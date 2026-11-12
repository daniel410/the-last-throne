local C=dofile('src/shared/CampaignContent.luau')
local A=dofile('src/server/World/StoryPropAssignments.luau')
local G=dofile('src/server/World/StoryQuestGeometry.luau')
local old=dofile('src/server/World/StoryPropGeometry.luau')
local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local seen,usage,regions={},{},{}
local total=0
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.goals)do
 for _,s in ipairs(g.activity and g.activity.steps or {})do
  local id=c.id..':'..g.id..':'..s.id;seen[id]=true
  local physical=g.activity.mode~='dialogue'and g.activity.mode~='escort'and s.kind~='actor'
  if physical then
   local key=A.forStep(c.id,g.id,s)
   check(key~=nil,'Every physical step has an authored assignment: '..id)
   if key then
    check(G[key]or old[key]or key=='ConvoySupplyCrate','Resolvable geometry: '..id)
    check(key~='LedgerDesk'and key~='TrailEvidence','No desk or mixed generic trail fallback: '..id)
    total=total+1;usage[key]=(usage[key]or 0)+1
    regions[c.epic]=regions[c.epic]or {};regions[c.epic][key]=true
   else check(id=='HG-07:crownheart:confirmed','Only the personal Crownheart scene skips static art')end
  end
 end
 local key=A.goals[c.id..':'..g.id]
 if key then check(not g.activity and #(g.enemies or {})==0,'Goal art never duplicates activity or battle art');check(G[key]or old[key],'Goal art exists');check(key~='LedgerDesk','No open-air desk')end
end end
for id in pairs(A.steps)do check(seen[id],'Assignments do not refer to removed story steps: '..id)end
for id in pairs(A.goals)do
 local chapter,goal=id:match('([^:]+):(.+)');local found=false
 for _,g in ipairs(C.byId[chapter].goals)do if g.id==goal then found=true end end
 check(found,'Assignments do not refer to removed story goals: '..id)
end
local distinct=0;for _ in pairs(usage)do distinct=distinct+1 end
check(distinct>=40,'Campaign objects have at least 40 distinct semantic models')
for epic,keys in pairs(regions)do local n=0;for _ in pairs(keys)do n=n+1 end;check(n>=8,'Each epic has more than eight object silhouettes: '..epic)end
local function expected(id,key)check(A.steps[id]==key,id..' must use '..key)end
expected('DW-07:stabilize:roots','RootSealRoots')
expected('DW-07:core_record:cost','SealedDispatch')
expected('DW-07:exp_2:step2','FieldMap')
expected('GW-02:bindings:confirmed','WebBindings')
expected('GW-05:exp_1:step1','ShedCarapace')
expected('EC-07:exp_2:step1','EmptyKeyCarrier')
expected('EC-07:exp_2:step2','SealedDispatch')
expected('EC-03:supports:operate','MineBrace')
expected('EC-06:exp_2:step2','PressureGauge')
expected('HG-07:exp_2:step1','BindingFrame')
check(A.goals['FV-07:mirror_crown']=='SignalMirror','Final palace objective remains a mirror')
check(A.forStep('DW-01','unknown',{id='unknown',kind='ledger',title='Read the record'})==nil,'Unmapped records do not silently become desks')
for key,spec in pairs(G)do
 check(#spec.parts>=1 and #spec.parts<=60,key..' bounded part count')
 local names={}
 for _,p in ipairs(spec.parts)do
  for _,n in ipairs(p.size)do check(n>0 and n<7,key..' valid compact dimensions')end
  check(p.position[2]>=0 and p.position[2]<6,key..' grounded compact asset')
  check(p.name~='Desk'and p.name~='DeskLeg'and p.name~='InkWell'and p.name~='Quill',key..' no field office furniture')
  names[p.name]=true
 end
 if key:match('^RootSeal')and key~='RootSeal'then check(names['StorySymbol'..key:sub(9)],'Portal control has its own recognizable symbol')end
end
print(('STORY_PROP_CONTEXT %d checks passed; %d physical step models, %d distinct used assets, all 47 stories audited'):format(checks,total,distinct))
