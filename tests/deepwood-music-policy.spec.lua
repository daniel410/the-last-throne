local P=dofile('src/shared/DeepwoodMusicPolicy.luau')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local snapshot={heroId='mage',encounters={['DW-07:king_shaman']={boss=true,active=true,remaining=9,position={0,0,0}}}}
local function session()return {heroId='mage',alive=true,mode='Tutorial',route='Adventure',position={0,0,0}}end
check(P.normalId==73105938035554 and P.bossId==120016858360297,'exact TD original normal and boss asset IDs')
check(P.bossKey(snapshot,session())=='DW-07:king_shaman','eligible boss encounter selects TD boss track')
for _,change in ipairs({{alive=false},{mode='Lobby'},{route='Training'},{heroId='knight'},{position={111,0,0}}})do local s=session();for k,v in pairs(change)do s[k]=v end;check(P.bossKey(snapshot,s)==nil,'death/hub/training/hero switch/leaving cannot retain boss track')end
snapshot.training=true;check(not P.bossKey(snapshot,session()),'training snapshot never plays boss music');snapshot.training=false
local e=snapshot.encounters['DW-07:king_shaman']
e.boss=false;check(not P.bossKey(snapshot,session()),'ordinary encounters keep normal track');e.boss=true
e.active=false;check(not P.bossKey(snapshot,session()),'completed/abandoned encounter stops boss music');e.active=true
e.remaining=1;check(P.bossKey(snapshot,session())~=nil,'boss death with surviving guards retains encounter soundtrack')
e.remaining=0;check(not P.bossKey(snapshot,session()),'final enemy death ends boss track')
check(not P.bossKey(nil,session()),'empty snapshot resets to normal')
print('Deepwood music policy: '..checks..' checks passed')
