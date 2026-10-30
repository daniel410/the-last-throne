local R=dofile('src/server/Inventory/InventoryRules.luau')
local E=dofile('src/shared/EconomyRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local checks=0;local function check(v,m) checks=checks+1;assert(v,m) end
local p=R.addHero(R.new(7),'hero','knight',C);p.wallet.gold=1000;p.wallet.diamonds=20
local buy={action='Buy',requestId='buy1',heroId='hero',revision=p.revision,offerId='knight_weapon_veteran'}
check(not R.shop(p,buy,{atLobby=false},C),'shop blocked outside lobby')
local n,e=R.shop(p,buy,{atLobby=true},C);check(n and not e and n.wallet.gold==400,'Gold and weapon commit together')
check(n.items['shop-buy1'].location.heroId=='hero','delivery belongs to selected hero bag')
local again,_,repeatBuy=R.shop(n,buy,{atLobby=true},C);check(repeatBuy and again.wallet.gold==400 and again.revision==n.revision,'duplicate buy cannot spend twice')
local conflict=R.copy(buy);conflict.offerId='elf_weapon_veteran';check(not R.shop(n,conflict,{atLobby=true},C),'same id cannot purchase another weapon')
local sell={action='Sell',requestId='sell1',heroId='hero',revision=n.revision,instanceId='shop-buy1',itemVersion=1}
local locked=R.copy(n);locked.items['shop-buy1'].locked=true;check(not R.shop(locked,sell,{atLobby=true},C),'locked item cannot be sold')
local equipped=R.copy(n);equipped.items['shop-buy1'].location={kind='equipped',heroId='hero',slot='weapon'};check(not R.shop(equipped,sell,{atLobby=true},C),'equipped item cannot be sold')
local sold=assert(R.shop(n,sell,{atLobby=true},C));check(sold.wallet.gold==520 and not sold.items['shop-buy1'],'sale atomically destroys owned item and credits Gold')
local twice=assert(R.shop(sold,sell,{atLobby=true},C));check(twice.wallet.gold==520 and twice.revision==sold.revision,'duplicate sell cannot mint Gold')
local starter=R.copy(sell);starter.instanceId='hero-starter-3';starter.requestId='starter';starter.revision=p.revision;check(not R.shop(p,starter,{atLobby=true},C),'starter items cannot mint Gold')
local diamond=R.copy(buy);diamond.requestId='diamond';diamond.offerId='mage_weapon_veteran_diamond';diamond.revision=sold.revision
local paid=assert(R.shop(sold,diamond,{atLobby=true},C));check(paid.wallet.gold==520 and paid.wallet.diamonds==10,'Diamond price is server-owned; other-class purchase allowed')
check(paid.items['shop-diamond'].definitionId=='mage_weapon_veteran','premium delivery uses same equip/class/level rules')
local poor=R.copy(p);poor.wallet.gold=0;poor.wallet.diamonds=0
check(not R.shop(poor,buy,{atLobby=true},C) and not R.shop(poor,diamond,{atLobby=true},C),'insufficient balances cannot grant gear')
local full=R.copy(p)
for i=1,60-R.count(full,'bag','hero') do local item=R.copy(full.items['hero-starter-3']);item.instanceId='fill'..i;item.location={kind='bag',heroId='hero'};full.items[item.instanceId]=item end
check(not R.shop(full,buy,{atLobby=true},C),'full bag cannot lose purchase currency')
local old=R.copy(p);old.wallet=nil
old.heroes.hero.deepwood={coins=2290,killCoins=173,clears={['DW-01']=true,['DW-02']=true,['DW-Q1']=true}}
local second=R.copy(old.heroes.hero);second.deepwood={coins=140,killCoins=5,clears={['DW-01']=true}};old.heroes.other=second
E.upgrade(old);check(old.wallet.gold==2608 and old.wallet.diamonds==4,'legacy earnings migrate once; same story on another hero cannot duplicate Diamonds')
old.wallet.gold=7;E.upgrade(old);check(old.wallet.gold==7,'migration cannot refill spent Gold')
local story=R.addHero(R.new(8),'q','mage',C)
local content=dofile('src/shared/DeepwoodContent.luau')
for _,goal in ipairs(content.chapters[1].goals) do
 if goal.activity and goal.activity.steps then for _,step in ipairs(goal.activity.steps) do story=assert(R.story(story,'q','DW-01',goal.id,nil,C,step.id)) end
 else story=assert(R.story(story,'q','DW-01',goal.id,nil,C)) end
end
check(story.wallet.gold==150 and story.wallet.diamonds==2,'first main clear credits approved Gold and two account Diamonds')
local replay=assert(R.story(story,'q','DW-01','trail_exit',nil,C,'approach'));check(replay.wallet.diamonds==2 and replay.wallet.gold==150,'story replay cannot duplicate currencies')
local xp=assert(R.progress(story,{action='AwardXP',heroId='q',stream='test',sequence=1,amount=10,coins=5,rewardKind='Defeat'},{serverReward=true},C))
local xr=assert(R.progress(xp,{action='AwardXP',heroId='q',stream='test',sequence=1,amount=10,coins=5,rewardKind='Defeat'},{serverReward=true},C))
check(xp.wallet.gold==155 and xr.wallet.gold==155,'kill Gold shares XP idempotency')
local broken=R.copy(xp);broken.wallet.diamonds=-1;check(not R.validate(broken,C),'negative Diamond profile is rejected')
local db,fail={},false
local store=Store.new({UpdateAsync=function(_,key,fn) local v=fn(db[key] and R.copy(db[key]));if v then db[key]=R.copy(v) end;if fail then error('unknown after commit') end;return v end},R,C,function() return 100 end,function() end,'lease')
assert(store:open(12));assert(store:transact(12,function(v) v=R.addHero(v,'h','knight',C);v.wallet.gold=1000;return v end))
local command={action='Buy',requestId='unknown',heroId='h',offerId='knight_weapon_fine',revision=db['account:12'].revision}
fail=true;local result,reason=store:transact(12,function(v) return R.shop(v,command,{atLobby=true},C) end);check(not result and reason=='SaveUnknown','unacknowledged debit is not treated as a failed purchase')
fail=false;result=assert(store:transact(12,function(v) return R.shop(v,command,{atLobby=true},C) end));check(result.wallet.gold==750 and result.items['shop-unknown'],'same request recovers exact debit and grant')
fail=true;check(not store:close(12) and store.profiles[12]~=nil,'unknown lease release retains recovery state')
fail=false
print('Economy: '..checks..' checks passed')
