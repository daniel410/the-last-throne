-- Actual production begin/spawn/defeat/recovery/approach logic in an isolated place.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local RS,SSS=game.ReplicatedStorage,game.ServerScriptService
local C=require(RS.Shared.CampaignContent);local P=require(RS.Shared.DeepwoodProgress)
local B=require(RS.Shared.DeepwoodEncounterBalance);local R=require(RS.Shared.CampaignCombatRoutes)
local report={kind='COMBAT_ROUTE_RUNTIME',checks=0}
local function check(v,m)report.checks+=1;assert(v,m)end
local parent=Instance.new('Folder');parent.Name='CombatRouteLifecycleQA';parent.Parent=game.ServerStorage
local c=C.byId['DW-05'];local g=P.goal(c,'warlord');local batches=B.encounterWaves(c,g,4)
local points=R.points(c,g,#batches,14)
local players,journals,runs,awards={},{},{},{}
for i=1,5 do
 local char=Instance.new('Model');char.Parent=parent
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(table.unpack(points[1]));root.Parent=char;char.PrimaryPart=root
 local h=Instance.new('Humanoid');h.Parent=char;if i==3 then h.Health=0 end
 players[i]={UserId=i,Parent=game.Players,Character=char}
 journals[players[i]]={version=2,main=c.number-1,flags={},clears={},expansionVersion=1}
 for _,goal in ipairs(c.goals)do if goal~=g then journals[players[i]].flags[c.id..':'..goal.id]=true end end
 runs[players[i]]={runId=i==5 and 'other' or 'route-qa',missionId=c.id,balanceVersion=14,difficultyId='Easy',kills={}}
 awards[players[i]]=0
end
players[2].Character.PrimaryPart.Position=Vector3.new(table.unpack(points[1]))+Vector3.new(500,0,0)
local source=SSS.Server.Story.DeepwoodService.Source
local first=assert(source:find('local function publish',1,true));local last=assert(source:find('function Service.destination',first,true))
source=source:sub(1,first-1)..'local function publish()end\n'..source:sub(last)
source=source:gsub('Players:GetPlayers%(%)','fixturePlayers '):gsub('return Service\n','function Service.qa(o)options=o end\nreturn Service\n')
local fakeRig={makeEnemy=function(folder,kind,x,z)
 local m=Instance.new('Model');m.Name=kind;local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Position=Vector3.new(x,0,z);root.Parent=m;m.PrimaryPart=root
 local h=Instance.new('Humanoid');h.Parent=m;m:SetAttribute('EnemyKind',kind);m.Parent=folder;return m
end}
local inventory={storyState=function(p)return journals[p]end,expedition=function(p)return runs[p]end,
 storyEvent=function(p,_,cid,gid)journals[p].flags[cid..':'..gid]=true end,
 awardXP=function(p,_,_,_,_,run,id)check(run==runs[p].runId,'exact admitted reward run');check(not runs[p].kills[id],'no duplicate kill reward');runs[p].kills[id]=true;awards[p]+=1 end}
local enemies=Instance.new('Folder');enemies.Parent=parent
local marker=Instance.new('Part');marker.Position=Vector3.new(table.unpack(g.position));marker.Parent=parent
local settings={world={folder=parent,nodes={[c.id..':'..g.id]={chapter=c,goal=g,part=marker}}},enemies=enemies,inventory=inventory,
 heroSession={getActiveHero=function(p)return {heroId=tostring(p.UserId)}end,getCombatContext=function(p)return {heroId=tostring(p.UserId)}end},
 combat={addStoryEnemy=function(m)local h=m:FindFirstChildOfClass('Humanoid');h.MaxHealth=m:GetAttribute('StoryHealth');h.Health=h.MaxHealth end}}
local function create()
 local fn=assert(loadstring(source,'ProductionCombatRouteFixture'))
 setfenv(fn,setmetatable({script=SSS.Server.Story.DeepwoodService,fixturePlayers=players,require=function(m)if m.Name=='TrainingField'then return fakeRig end;return require(m)end},{__index=getfenv()}))
 local service=fn();service.qa(settings);return service
end
local function living()local result={};for _,m in ipairs(enemies:GetChildren())do local h=m:FindFirstChildOfClass('Humanoid');if h and h.Health>0 then result[#result+1]=m end end;return result end
local service=create();service.interact(players[1],c.id,g.id)
check(#living()==0,'admission alone does not produce a remote pack')
local function projection()return service.encounterState(players[1],'1')[c.id..':'..g.id]end
check(projection().waiting and projection().route,'next clearing and route projected')
local total,boss=0,0
for index,batch in ipairs(batches)do
 local at=Vector3.new(table.unpack(points[index]));players[1].Character.PrimaryPart.Position=at
 service.stepEncounters();local pack=living();check(#pack==#batch,'preserved pack population at clearing '..index)
 for _,m in ipairs(pack)do
  check((m.PrimaryPart.Position-at).Magnitude<16,'exact production clearing position')
  if m:GetAttribute('StoryBoss')then boss+=1;check(index==#batches,'boss only at final clearing')end
  total+=1;m:FindFirstChildOfClass('Humanoid').Health=0;service.defeated(m);service.defeated(m)
 end
 check(#living()==0,'no same-place next-pack spawn after final death')
 if index<#batches then
  local nextAt=Vector3.new(table.unpack(points[index+1]));check(projection().waiting,'route waits for real approach')
  service.stepEncounters();check(#living()==0,'remaining at cleared site cannot activate next pack')
  players[5].Character.PrimaryPart.Position=nextAt;players[3].Character.PrimaryPart.Position=nextAt
  service.stepEncounters();check(#living()==0,'other run and downed member cannot activate pack')
  local checkpoint=service.destination(players[1],'1');check(checkpoint:IsA('SpawnLocation')and checkpoint.Enabled,'real route respawn destination')
  check((checkpoint.Position-at).Magnitude<2,'respawn uses cleared route ground')
  check(checkpoint~=service.destination(players[2],'2'),'another hero cannot move this pending respawn anchor')
 end
end
task.wait(.1)
local expected=0;for _,batch in ipairs(batches)do expected+=#batch end
check(total==expected and boss==1,'entire encounter retained, final boss once')
for i=1,4 do check(journals[players[i]].flags[c.id..':'..g.id],'party shared completion, including far and downed members')end
check(awards[players[1]]==expected and awards[players[2]]==expected,'all active admitted members retain all rewards')
check(awards[players[5]]==0 and not journals[players[5]].flags[c.id..':'..g.id],'other run isolated')
-- Simulate a server change after kill receipts committed but goal save did not.
-- All four members have confirmed receipts (the downed hero is deliberately filled
-- from the persisted server record rather than claiming missing rewards existed).
for i=1,4 do journals[players[i]].flags[c.id..':'..g.id]=nil;for _,batch in ipairs(batches)do for _,spec in ipairs(batch)do runs[players[i]].kills[R.killId(c,g,c.id,spec)]=true end end end
players[1].Character.PrimaryPart.Position=Vector3.new(table.unpack(R.entry(c,g,runs[players[1]],4)))
service=create();service.interact(players[1],c.id,g.id);service.stepEncounters();task.wait(.1)
check(#living()==0,'all confirmed clearings recover without replay')
for i=1,4 do check(journals[players[i]].flags[c.id..':'..g.id],'saved kills can finish pending goal')end
-- Actual Journal guidance must track the moving server position on every device.
local journal=require(game.StarterPlayer.StarterPlayerScripts.Client.DeepwoodJournal)
local s=journals[players[1]];s.flags[c.id..':'..g.id]=nil
local current={journal=s,expedition=runs[players[1]],routePartySize=4,encounters={[c.id..':'..g.id]={route=true,waiting=true,wave=1,waves=#batches,remaining=0,position=points[2]}}}
local guidance=journal.guidance(current,{chapter=c,goal=g})
check((guidance.position-Vector3.new(table.unpack(points[2]))).Magnitude<.01,'real client guidance follows next clearing')
check(guidance.note:find('Follow the trail',1,true)~=nil,'movement, not fake respawn, explained in English')
-- A member admitted after the encounter began must join its current stretch,
-- rather than being stranded at the original trigger or changing its population.
for i=1,4 do journals[players[i]].flags[c.id..':'..g.id]=nil;runs[players[i]].kills={}end
runs[players[4]].runId='not-admitted-yet'
players[1].Character.PrimaryPart.Position=Vector3.new(table.unpack(R.entry(c,g,runs[players[1]],3)))
service=create();service.interact(players[1],c.id,g.id)
check(service.encounterState(players[4],'4')[c.id..':'..g.id]==nil,'not-yet-admitted member remains outside')
runs[players[4]].runId='route-qa';service.stepEncounters()
check(service.encounterState(players[4],'4')[c.id..':'..g.id]~=nil,'late admitted member joins the current route automatically')
check(#living()==#B.encounterWaves(c,g,3)[1],'late arrival does not duplicate or rewrite the active pack')
parent:Destroy()
print('COMBAT_ROUTE_RUNTIME '..game.HttpService:JSONEncode(report));return report
