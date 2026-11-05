local R=dofile('src/server/Story/PartyMapRoster.luau')
local P=dofile('src/shared/PartyMapProjection.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local players={};for i=1,6 do players[i]={UserId=i,DisplayName='Hero '..i}end
local phase,run,hero,positions={},{},{},{}
for i,p in ipairs(players)do phase[p]=true;run[p]={runId=i<=4 and 'same'or 'other'};hero[p]={heroId='h'..i};positions[p]={{i*10,3,-i*10},i==3}end
local snapshot=R.create({players=function()return players end,active=function(p)return hero[p]end,run=function(p)return run[p]end,
 inAdventure=function(p)return phase[p]end,position=function(p)return table.unpack(positions[p])end})
for viewer=1,4 do
 local value=snapshot(players[viewer]);check(value.heroId=='h'..viewer and #value.members==3,'four-player party gets exactly the other three members')
 for _,m in ipairs(value.members)do
  check(m.userId~=viewer and m.userId<=4,'self and other expedition excluded')
  check(m.slot==m.userId and m.name=='Hero '..m.userId,'sorted identity and visible name preserved')
  check(m.downed==(m.userId==3),'downed party member remains locatable')
  check(not m.runId and not m.ticket and not m.heroId,'membership fences and tickets are not disclosed')
 end
end
phase[players[2]]=false;check(#snapshot(players[1]).members==2,'return to lobby removes member');phase[players[2]]=true
positions[players[2]]={nil,false};local m=snapshot(players[1]).members[1];check(m.userId==2 and not m.position,'respawn retains roster identity without stale coordinates')
hero[players[2]].training=true;check(#snapshot(players[1]).members==2,'training session is not a party marker');hero[players[2]].training=nil
run[players[1]]=nil;check(#snapshot(players[1]).members==0,'solo/no run sees no unrelated players');run[players[1]]={runId='same'}
run[players[1]]={};check(#snapshot(players[1]).members==0,'missing run identity cannot join a party map');run[players[1]]={runId='same'}
check(#snapshot(players[5]).members==1,'different run only sees its own ally')
local project=function(x,z)return {X=x,Y=z}end
for _,compact in ipairs({false,true})do
 for _,point in ipairs({{.5,0,.5},{.7,0,.6},{-5,0,.5},{5,0,5},{.5,0,-10},{.5,0,20}})do
  local v=P.position({position=point,downed=true},project,compact)
  check(v and v.x>=0 and v.x<=1 and v.y>=0 and v.y<=1,'party pin stays in map bounds')
  check(v.downed,'downed appearance preserved')
  if compact then check((v.x-.5)^2+(v.y-.5)^2<=.34^2+.000001,'circular minimap reserves space for edge arrows')end
 end
end
for _,position in ipairs({{}, {0/0,0,0},{math.huge,0,0},{'1',0,0},{0,0}})do check(not P.position({position=position},project,true),'invalid/stale coordinates hidden')end
check(not P.position({},project,false),'respawning member has no stale marker')
local east=P.position({position={10,0,.5}},project,true);local north=P.position({position={.5,0,-10}},project,true)
check(east.outside and math.abs(east.angle)<.001,'edge arrow points east')
check(north.outside and math.abs(north.angle+90)<.001,'edge arrow points north')
print('Party map: '..n..' checks passed')
