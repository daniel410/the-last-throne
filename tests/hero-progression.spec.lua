-- Pure growth/account invariants, including save-unknown replay and legacy migration.
if game then return {} end
local G=dofile('src/shared/HeroProgression.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local S=dofile('src/server/Inventory/AccountStore.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local n=0
local function check(v,label) n=n+1; assert(v,label) end
local function eq(a,b,label) check(a==b,label..': '..tostring(a)..' ~= '..tostring(b)) end
for id,hp in pairs({knight=250,dwarf=200,elf=150,mage=100}) do
 local g=G.new(); check(G.validate(g),'valid level1')
 local d=G.derived(id,g); eq(d.health,hp,id..' starting HP'); eq(d.mana,id=='mage' and 100 or 0,id..' starting MP')
 local st,sp=G.points(g); eq(st,0,'no free stats'); eq(sp,0,'no free skills')
end
local g=assert(G.apply(G.new(),{action='AwardXP',stream='server-a',sequence=1,amount=225}))
eq(g.level,3,'multi-level XP'); eq(g.xp,0,'XP remainder'); local st,sp=G.points(g); eq(st,8,'4 stats per level'); eq(sp,2,'separate 1SP')
local same,err,repeated=G.apply(g,{action='AwardXP',stream='server-a',sequence=1,amount=225});check(repeated,'highwater replay'); eq(same.level,3,'no duplicate XP')
check(not G.apply(g,{action='AwardXP',stream='server-a',sequence=3,amount=100}),'reject skipped sequence')
check(not G.apply(g,{action='AwardXP',stream='',sequence=1,amount=100}),'reject empty stream')
for _,bad in ipairs({-1,0,0/0,math.huge,1.5,1000001}) do check(not G.apply(g,{action='AwardXP',stream='x',sequence=1,amount=bad}),'reject invalid XP') end
check(not G.apply(g,{action='AllocateStats',stats={VIT=9}}),'overspend')
check(not G.apply(g,{action='AllocateStats',stats={VIT=-1}}),'no refund')
check(not G.apply(g,{action='AllocateStats',stats={Luck=1}}),'unknown stat')
g=assert(G.apply(g,{action='AllocateStats',stats={VIT=4,STR=4}})); st,sp=G.points(g); eq(st,0,'all stats invested');eq(sp,2,'SP preserved')
eq(G.derived('knight',g).health,320,'level+invested VIT');eq(G.derived('knight',g).physicalPower,114,'power scaling')
g=assert(G.apply(g,{action='TrainSkill',skill=1}));eq(g.mastery[1],1,'rank trained'); st,sp=G.points(g);eq(sp,1,'only1SP cost')
local base={damage=.8,posture=55,cooldown=10,id='bash'}
local skill=G.skill('knight',1,base,g); check(math.abs(skill.damage-.84)<.00001,'mastery damage');eq(skill.posture,58,'mastery posture');eq(base.posture,55,'base immutable');eq(skill.cooldown,10,'CD unchanged')
g=assert(G.apply(g,{action='SetSkillSlot',slot=1,skill=3}));eq(g.skillSlots[1],3,'slot swap');eq(g.skillSlots[3],1,'unique loadout')
check(not G.apply(g,{action='SetSkillSlot',slot=4,skill=2}),'advancement slot locked')
local cap=assert(G.apply(g,{action='AwardXP',stream='server-a',sequence=2,amount=1000000}));eq(cap.level,80,'cap80');eq(cap.xp,0,'capXP0');st,sp=G.points(cap);eq(st+8,316,'316 stat budget');eq(sp+1,79,'79 skill budget')
for i=1,2 do cap=assert(G.apply(cap,{action='TrainSkill',skill=1})) end
check(not G.apply(cap,{action='TrainSkill',skill=1}),'rank cap3')
local p=assert(R.addHero(R.new(42),'hero','mage',C));p.heroes.hero.progression=nil
check(R.validate(p,C),'legacy accepted');local oldRevision=p.revision
p=R.upgrade(p);check(R.validate(p,C),'migration valid');eq(p.revision,oldRevision+1,'migration revision');eq(p.heroes.hero.progression.level,1,'legacy level preserved');eq(R.upgrade(p).revision,p.revision,'migration idempotent')
local award={action='AwardXP',heroId='hero',stream='server-b',sequence=1,amount=100}
check(not R.progress(p,award,{serverReward=false},C),'client XP rejected')
p=assert(R.progress(p,award,{serverReward=true},C));eq(p.heroes.hero.level,2,'stored level synchronized')
local cmd={action='AllocateStats',heroId='hero',requestId='points',revision=p.revision,stats={INT=4}}
local updated=assert(R.progress(p,cmd,{atHub=true},C));eq(updated.heroes.hero.progression.stats.INT,4,'stored investment')
local replay,_,r=R.progress(updated,cmd,{atHub=false},C);check(r,'receipt replay survives context loss');eq(replay.revision,updated.revision,'receipt does not spend twice')
local forged=G.copy(cmd);forged.stats.INT=3;local _,reason=R.progress(updated,forged,{atHub=true},C);eq(reason,'RequestConflict','sameid different payload')
cmd.requestId='stale';local _,reason2=R.progress(updated,cmd,{atHub=true},C);eq(reason2,'Changed','old revision fails')
local data={};local lose=false
local adapter={UpdateAsync=function(_,key,callback) local value=callback(G.copy(data[key])); if value then data[key]=G.copy(value) end; if lose then error('response lost') end;return G.copy(value) end}
local store=S.new(adapter,R,C,function()return 1000 end,function()end,'fence-a')
local loaded=assert(store:open(42));loaded=assert(store:transact(42,function(cur)return R.addHero(cur,'hero','mage',C)end))
lose=true;local missing,unknown=store:transact(42,function(cur)return R.progress(cur,award,{serverReward=true},C)end);check(not missing,'unknown fail closed');eq(unknown,'SaveUnknown','unknown distinguished')
lose=false;local recovered=assert(store:transact(42,function(cur)return R.progress(cur,award,{serverReward=true},C)end));eq(recovered.heroes.hero.progression.level,2,'unknown XP replay once');eq(recovered.heroes.hero.progression.xp,0,'no duplicate remainder')
local field=assert(R.addHero(R.new(55),'field','knight',C))
field=assert(R.progress(field,{action='AwardXP',heroId='field',stream='field',sequence=1,amount=225},{serverReward=true},C))
local statCommand={action='AllocateStats',heroId='field',requestId='field-stats',revision=field.revision,stats={STR=4}}
local blocked,why=R.progress(field,statCommand,{atHub=false,canInvest=false},C)
eq(blocked,nil,'unsafe field investment denied');eq(why,'UnsafeGrowth','actionable unsafe reason')
field=assert(R.progress(field,statCommand,{atHub=false,canInvest=true},C))
eq(field.heroes.field.progression.stats.STR,4,'safe field stats persist')
local train={action='TrainSkill',heroId='field',requestId='field-mastery',revision=field.revision,skill=1}
field=assert(R.progress(field,train,{atHub=false,canInvest=true},C));eq(field.heroes.field.progression.mastery[1],1,'safe field mastery persists')
local repeatedField,_,receipt=R.progress(field,train,{atHub=false,canInvest=false},C);check(receipt,'same confirmed investment recovers after safety lost');eq(repeatedField.revision,field.revision,'no duplicate SP spend')
local a,b=G.points(field.heroes.field.progression);eq(a,4,'remaining stats exact');eq(b,1,'remaining skill points exact')
local loadout={action='SetSkillSlot',heroId='field',requestId='field-loadout',revision=field.revision,slot=1,skill=2}
local noLoadout,gate=R.progress(field,loadout,{atHub=false,canInvest=true},C);eq(noLoadout,nil,'safe investment never grants field loadout permission');eq(gate,'WaitForLobby','loadout stays at Hub')
print('Hero progression: '..n..' checks passed')
