local function load(n)return dofile('src/shared/'..n..'.luau')end
local C,B,R,D,Areas=load('CampaignContent'),load('DeepwoodEncounterBalance'),load('CampaignCombatRoutes'),load('Difficulty'),load('CampaignAreas')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local old=assert(io.open('src/shared/CampaignContent.luau')):read('*a')
old=old:gsub("load%('CampaignRouteFootprint'%).install%(C%)",''):gsub("load%('CampaignCombatRoutes'%).install%(C%)",'')
local before=assert(loadstring and loadstring(old)or _G.load(old))()
local function equal(a,b)if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end;for k,v in pairs(a)do if not equal(v,b[k])then return false end end;for k in pairs(b)do if a[k]==nil then return false end end;return true end
local battles,sites,epics=0,0,{}
local totalOld,totalNew=0,0
for id,z in pairs(C.zones)do
 local prior=before.zones[id];check(z.size[1]>=prior.size[1]and z.size[2]>=prior.size[2],'never shrink real ground '..id)
 totalOld=totalOld+prior.size[1]*prior.size[2];totalNew=totalNew+z.size[1]*z.size[2]
 for _,other in pairs(C.zones)do if other~=z then
  check(math.abs(z.center[1]-other.center[1])>=(z.size[1]+other.size[1])/2 or math.abs(z.center[3]-other.center[3])>=(z.size[2]+other.size[2])/2,'expanded regions retain gated separation '..id)
 end end
end
for _,c in ipairs(C.chapters)do
 local prior=before.byId[c.id];check(equal(c.reward,prior.reward),'fixed story reward '..c.id);check(equal(c.coreGoals,prior.coreGoals),'stable core goals/IDs/requires/anchors '..c.id)
 for _,g in ipairs(c.goals)do if #g.enemies>0 then
  battles=battles+1;local plan=c.combatRoutes[g.id];check(plan~=nil,'every battle has a route');sites=sites+#plan.points;epics[c.epic]=true
  for _,point in ipairs(plan.points)do check(Areas.contains(C.zones[c.zone],point[1],point[3],-35),'real supported combat clearing '..c.id..g.id)end
  for party=1,4 do
   local packs=B.encounterWaves(c,g,party);local originals=B.encounterWaves(prior,prior.goals[(function()for i,v in ipairs(prior.goals)do if v.id==g.id then return i end end end)()],party)
   check(equal(packs,originals),'all enemy kinds/levels/counts/receipt IDs preserved '..c.id..g.id..party)
   local points=R.points(c,g,#packs,14);check(#points==#packs,'one distinct clearing per pack')
   for i,p in ipairs(points)do for j=1,i-1 do check(R.distance(p,points[j])>=79.9,'no same-place repeat '..c.id..g.id..party)end end
   local boss=0
   for index,pack in ipairs(packs)do for _,unit in ipairs(pack)do
    if B.isBoss(unit.kind)then boss=boss+1;check(index==#packs,'boss is final once')end
    for _,mode in ipairs(D.order)do
     local xp,gold=B.rewards(unit,mode,13);local x2,g2=B.rewards(unit,mode,14)
     check(xp==x2 and gold==g2,'no kill reward reduction')
     local hp,dmg,level,elite=B.unitStats(unit,party,mode,13,index);local h2,d2,l2,e2=B.unitStats(unit,party,mode,14,index)
     check(hp==h2 and dmg==d2 and level==l2 and elite==e2,'no combat tuning reduction')
    end
   end end
   check(boss<=1,'no repeated boss')
   local run={missionId='DW-01',balanceVersion=14,kills={}}
   check(R.clearedPrefix(c,g,packs,run)==0,'no fabricated recovery')
   for _,unit in ipairs(packs[1])do run.kills[R.killId(c,g,run.missionId,unit)]=true end
   check(R.clearedPrefix(c,g,packs,run)>=1,'confirmed first pack recovered')
   check(equal(R.entry(c,g,run,party),points[math.min(#points,2)]),'rejoin guides directly beyond confirmed clearings')
   for _,pack in ipairs(packs)do for _,unit in ipairs(pack)do run.kills[R.killId(c,g,run.missionId,unit)]=true end end
   check(R.clearedPrefix(c,g,packs,run)==#packs,'all confirmed packs recover without combat')
   check(R.plan(c,g,12)==nil,'pre-expansion run retains old lifecycle')
   check(R.plan(c,g,13)~=nil,'existing expanded run gains spatial routes without reward migration')
  end
 end end
end
check(battles==88 and sites==315,'complete five-epic battle census including thirteen supplemental patrols')
for epic=1,5 do check(epics[epic],'every epic reviewed')end
check(totalNew>totalOld*1.5,'substantial real footprint expansion')
check(D.compatible(13)and D.compatible(14),'old and new admitted rules supported')
print(string.format('Campaign combat routes: %d checks passed; %d battles, %d sites, real ground %.1f%% larger',n,battles,sites,(totalNew/totalOld-1)*100))
