local G=dofile('src/shared/HeroProgression.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local S=dofile('src/server/Inventory/AccountStore.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local n=0
local function check(v,m)n=n+1;assert(v,m)end
local function eq(a,b,m)check(a==b,m..': '..tostring(a)..' ~= '..tostring(b))end
for level=1,80 do
 for _,xp in ipairs(level==80 and {0} or {0,1,9,10,G.xpToNext(level)-1}) do
  local g=G.new(level);g.xp=xp
  local changed=assert(G.apply(g,{action='DeathPenalty',training=false},'knight'))
  local loss=math.ceil(xp/10)
  eq(changed.xp,xp-loss,'10% of earned current-level XP, rounded up')
  eq(changed.level,level,'death never demotes')
  eq(G.totalXP(g)-G.totalXP(changed),loss,'cumulative XP decreases by actual loss')
  check(G.totalXP(changed)>=G.xpAtLevel(level),'earned level floor protected')
  eq(changed.rewardSequence,g.rewardSequence,'death does not consume reward sequence')
  check(G.validate(changed,'knight'),'post-death profile remains valid')
  local a,b=G.points(changed);local beforeA,beforeB=G.points(g)
  eq(a,beforeA,'stat points retained');eq(b,beforeB,'skill points retained')
  check(not G.apply(g,{action='DeathPenalty',training=true},'knight'),'training command cannot deduct XP')
 end
end
local profile=assert(R.addHero(R.new(81),'hero','knight',C))
profile.heroes.hero.progression=G.new(2);profile.heroes.hero.progression.xp=40;profile.heroes.hero.level=2
local command={action='DeathPenalty',heroId='hero',requestId='death-one',training=false}
check(not R.progress(profile,command,{serverReward=false},C),'client penalty rejected')
local changed=assert(R.progress(profile,command,{serverReward=true},C))
eq(changed.heroes.hero.progression.xp,36,'server penalty applied')
eq(changed.operations['death-one'].xpLost,4,'receipt records actual loss')
eq(changed.wallet.gold,profile.wallet.gold,'gold unchanged')
local replay,_,repeated=R.progress(changed,command,{serverReward=true},C)
check(repeated,'repeated death returns durable receipt');eq(replay.revision,changed.revision,'no second transaction');eq(replay.heroes.hero.progression.xp,36,'no duplicate deduction')
local data,fail={},false
local adapter={UpdateAsync=function(_,key,fn)local result=fn(R.copy(data[key]));if result then data[key]=R.copy(result)end;if fail then error('lost acknowledgement')end;return R.copy(result)end}
local store=S.new(adapter,R,C,function()return 1000 end,function()end,'death-server')
assert(store:open(81));assert(store:transact(81,function(current)local seeded=R.copy(profile);seeded.lease=R.copy(current.lease);seeded.epoch=current.epoch;return seeded end))
fail=true;local noProfile,reason=store:transact(81,function(p)return R.progress(p,command,{serverReward=true},C)end)
eq(noProfile,nil,'unknown result fails closed');eq(reason,'SaveUnknown','unknown write distinguished')
fail=false;local recovered=assert(store:transact(81,function(p)return R.progress(p,command,{serverReward=true},C)end))
eq(recovered.heroes.hero.progression.xp,36,'unknown write retry deducts once');eq(recovered.operations['death-one'].xpLost,4,'recovered notice keeps original loss')
print('Death XP penalty: '..n..' checks passed')
