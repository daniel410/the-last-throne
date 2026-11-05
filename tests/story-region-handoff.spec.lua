-- Run the actual service handoff and respawn bodies with isolated world adapters.
local Content=dofile('src/shared/CampaignContent.luau')
local Text=dofile('src/shared/K0Text.luau')
local f=assert(io.open('src/server/Story/DeepwoodService.luau'));local source=f:read('*a');f:close()
local first=assert(source:find('    local transitionNotice',1,true))
local last=assert(source:find('    local run=options.inventory.expedition',first,true))
local transition=assert(load('return function(player,e,after,complete,Content,options,context,publish,Vector3,Text)\n'..source:sub(first,last-1)..'\nreturn transitionNotice end'))()
local firstDestination=assert(source:find('function Service.destination',1,true))
local lastDestination=assert(source:find('local function enqueue',firstDestination,true))
local makeDestination=assert(load('return function(options,state,Content) local Service={}\n'..source:sub(firstDestination,lastDestination-1)..'return Service end'))()
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local vectors={new=function(x,y,z)check(x==0 and y==4 and z==0,'arrival is above the safe spawn');return y end}
for _,number in ipairs({7,14,21,28})do
 local c,nextChapter=Content.mainChapters[number],Content.mainChapters[number+1]
 local player={};local after={main=number,expeditionMission=nextChapter.id}
 local e={c=c,heroId='hero',runId='campaign'}
 local prepared,moved,messages=0,0,{}
 local options={world={spawns={}},inventory={expedition=function()return {runId='campaign',missionId='DW-01'}end}}
 options.prepareStory=function(id)
  check(id==nextChapter.id and after.main==number,'prepare only the saved next story')
  prepared=prepared+1;options.world.spawns[nextChapter.zone]={CFrame=100}
 end
 options.combat={relocateForStoryGate=function(who,pivot)check(who==player and pivot==104,'move the completing hero to the next region');moved=moved+1 end}
 local function ctx()return {heroId='hero'}end
 local function publish(_,message)messages[#messages+1]=message end
 local notice=transition(player,e,after,true,Content,options,ctx,publish,vectors,Text)
 check(prepared==1 and moved==1 and notice==nil,'epic handoff prepares and moves without lobby return')
 check(messages[1]==Text.StoryPreparingRegion,'preparation explains that progress is already saved')
 prepared,moved=0,0
 transition(player,e,after,false,Content,options,ctx,publish,vectors,Text)
 check(prepared==0 and moved==0,'unconfirmed save never starts a region transition')
 -- A late build must not move a different hero or a different admitted run.
 transition(player,e,after,true,Content,options,function()return {heroId='other'}end,publish,vectors,Text)
 check(moved==0,'hero switch while loading cannot move the new hero')
 options.inventory.expedition=function()return {runId='new_run',missionId='DW-01'}end
 transition(player,e,after,true,Content,options,ctx,publish,vectors,Text)
 check(moved==0,'run switch while loading cannot move a different run')
 options.inventory.expedition=function()return {runId='campaign',missionId='DW-01'}end
 options.world.spawns={};options.prepareStory=function()error('injected region failure')end
 notice=transition(player,e,after,true,Content,options,ctx,publish,vectors,Text)
 check(notice==Text.StoryRegionLoadFailed and moved==0,'failed region load preserves progress and explains rejoin recovery')
 options.prepareStory=function(id)check(id==nextChapter.id,'rejoin loads current story, not the launch mission');options.world.spawns[nextChapter.zone]={CFrame=200}end
 local service=makeDestination(options,function()return after end,Content)
 check(service.destination(player,'hero').CFrame==200,'rejoin resolves the next epic even when only the launch epic is initially loaded')
end
print('Story region handoff: '..n..' checks passed')
