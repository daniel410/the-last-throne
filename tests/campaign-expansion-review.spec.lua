local function module(n)return dofile('src/shared/'..n..'.luau')end
local C,P,Text,State,Route,Areas,Log=module('CampaignContent'),module('DeepwoodProgress'),module('StoryEventText'),module('CampaignSceneState'),module('CampaignIncidentRoute'),module('CampaignAreas'),module('DeepwoodQuestLog')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function copy(v)return P.copy(v)end
local outcomes=0;local sizes,layouts={},{}
local function complete(s,c)
 for _,g in ipairs(c.goals)do if P.required(s,g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   local before=copy(s)
   if step and step.solution then
    local wrong=step.choices[2].id;local failed,why=P.apply(s,c.id,g.id,wrong,step.id)
    check(not failed and why=='WrongCircuit','wrong circuit cannot advance')
    check(State.count(s,c.id..':'..g.id,c.id)==State.count(before,c.id..':'..g.id,c.id),'wrong choice keeps confirmed stage')
   end
   s=assert(P.apply(s,c.id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared',step and step.id or nil))
   if g.expansion then
    local text=Text.resolve(g,step.id,step.choices and step.choices[1].id,before,s,c.id)
    local done=s.flags[c.id..':'..g.id]
    check(text==(done and g.text or step.choices and step.choices[1].text or step.text),'actual saved result text')
    if done then
     outcomes=outcomes+1
     check(Text.resolve(g,step.id,nil,s,s,c.id)~=g.text,'duplicate save does not replay outcome')
    end
   end
  end
 end end
 return s
end
local s=assert(P.enableExpansion(P.new()))
for _,c in ipairs(C.mainChapters)do
 for _,g in ipairs(c.expansionGoals)do
  local included=false;for _,phase in ipairs(c.quest.phases)do for _,id in ipairs(phase.goals)do if id==g.id then included=true end end end
  check(included,'expanded incident belongs to a displayed phase')
 end
 s=complete(s,c)
end
for _,c in ipairs(C.chapters)do if c.side then s=assert(P.accept(s,c.id));s=complete(s,c)end end
check(P.validate(s)and outcomes==82,'all incidents finish through confirmed message resolver')
for _,c in ipairs(C.chapters)do for _,g in ipairs(c.expansionGoals)do
 local area;for _,a in ipairs(C.zones[c.zone].expansionAreas)do if a.id==g.area then area=a end end
 layouts[area.layout]=true;sizes[table.concat(area.size,':')]=true
 local route=Route.route(area.entry,g.activity.steps[1].position)
 check(#route>=3,'approach uses connector instead of diagonal shortcut')
 for i=2,#route do
  local a,b=route[i-1],route[i];for j=0,10 do
   local t=j/10;local x,z=a[1]+(b[1]-a[1])*t,a[3]+(b[3]-a[3])*t
   check(Areas.containsZone(C.zones[c.zone],x,z),'approach stays on supported footprint')
  end
 end
 local past={area.entry[1],area.entry[2],area.entry[3]}
 past[area.axis=='x'and 1 or 3]=past[area.axis=='x'and 1 or 3]-area.side*8
 check(#Route.route(past,C.zones[c.zone].center)==2,'leaving the entrance continues forward instead of looping back')
 local leaving=Route.route(g.activity.steps[3].position,area.entry)
 check(#leaving>=3,'return follows the connector')
end end
local n=0;for _ in pairs(layouts)do n=n+1 end;check(n>=30,'distinct regional layout families across 35 chapters')
n=0;for _ in pairs(sizes)do n=n+1 end;check(n>=20,'varied space dimensions')
-- Existing rule-12 journals skip expansion-only phases; current journals include them.
local legacy=P.new();local c=C.byId['DW-01'];local beforeGoal=P.goal(c,'supplies')
for _,g in ipairs(c.coreGoals)do
 if g.id==beforeGoal.id then break end
 if not g.optional then for _,step in ipairs(g.activity and g.activity.steps or {false})do legacy=assert(P.apply(legacy,c.id,g.id,step and step.choices and step.choices[1].id,step and step.id or nil))end end
end
check(Log.target(legacy,c).goal.id=='supplies','legacy next goal unchanged')
local expanded=assert(P.enableExpansion(legacy));check(Log.target(expanded,c).goal.id=='exp_1','new incident becomes current tracked goal')
check(Log.phase(expanded,c)~='Completed','incident phase does not prematurely complete')
print('CAMPAIGN_EXPANSION_REVIEW '..checks..' checks passed; 82 outcome deliveries, safe circuit choices and connector routes')
