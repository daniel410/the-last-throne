local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local P=dofile('src/shared/DeepwoodProgress.luau')
local Pass=dofile('src/shared/SupportPassRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local count=0;local function check(v,m)count=count+1;assert(v,m)end
local base=R.addHero(R.new(77),'hero','knight',C)
local Content=dofile('src/shared/DeepwoodContent.luau')
for _,chapter in ipairs(Content.chapters)do if not chapter.side and chapter.number<=3 then
 for _,g in ipairs(chapter.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {})do base=assert(R.story(base,'hero',chapter.id,g.id,step.choices and step.choices[1].id,C,step.id))end
  if not (g.activity and g.activity.steps)then base=assert(R.story(base,'hero',chapter.id,g.id,g.choice and 'shared' or nil,C))end
 end end
end end
base.wallet.gold=10000
check(R.validate(base,C),'valid loaded rescued profile')
local function apply(p,c,ctx)return R.supportPass(p,c,ctx or {atLobby=true},C)end
for _,offer in ipairs(Pass.offers)do
 local cmd={action='Buy',requestId='purchase'..offer.stories,heroId='hero',offerId=offer.id,revision=base.revision,price=0}
 local p=assert(apply(base,cmd));check(p.wallet.gold==10000-offer.price,'server prices '..offer.id)
 check(Pass.view(p,'hero').credits==offer.stories,'exact story count '..offer.id)
 local again=assert(apply(p,cmd,{atLobby=false}));check(again.wallet.gold==p.wallet.gold and again.supportPasses.credits==offer.stories,'duplicate receipt cannot charge/grant twice')
 local forged=R.copy(cmd);forged.offerId='selene_story_10';if forged.offerId~=cmd.offerId then local _,e=apply(p,forged);check(e=='RequestConflict','same receipt cannot change pack')end
 local _,e=apply(base,cmd,{atLobby=false});check(e=='ShopLobbyOnly','field cannot buy')
end
local poor=R.copy(base);poor.wallet.gold=199
local _,e=apply(poor,{action='Buy',requestId='poor',heroId='hero',revision=poor.revision,offerId='selene_story_1'});check(e=='NotEnoughGold' and poor.wallet.gold==199,'insufficient Gold never produces credits')
local p=assert(apply(base,{action='Buy',requestId='bundle',heroId='hero',revision=base.revision,offerId='selene_story_10'}))
local cmd={action='Activate',requestId='activate4',heroId='hero',story=4}
local ctx={inAdventure=true,hasCampAccess=true,maxStories=21}
local no,e=apply(p,cmd,{inAdventure=true,hasCampAccess=false});check(not no and e=='Unavailable','activation needs server camp access')
p=assert(apply(p,cmd,ctx));check(Pass.view(p,'hero').credits==9 and Pass.view(p,'hero').active,'one credit starts current story')
check(p.heroes.hero.deepwood.seleneFollowing==true,'paid activation and preference commit together')
local q=assert(apply(p,{action='Activate',requestId='reinvite',heroId='hero',story=4},ctx));check(q.revision==p.revision and Pass.view(q,'hero').credits==9,'reinvitations and retry cannot consume another credit')
local loaded=R.copy(q);check(Pass.view(loaded,'hero').active and Pass.view(loaded,'hero').credits==9,'death/reconnect copies retain paid story and unused credits')
do local chapter=Content.byId['DW-04']
 for _,g in ipairs(chapter.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {})do loaded=assert(R.story(loaded,'hero',chapter.id,g.id,step.choices and step.choices[1].id,C,step.id))end
  if not (g.activity and g.activity.steps)then loaded=assert(R.story(loaded,'hero',chapter.id,g.id,g.choice and 'shared' or nil,C))end
 end end
end
check(not Pass.view(loaded,'hero').active and Pass.view(loaded,'hero').credits==9,'main-story completion ends support without losing unused credits')
q=assert(apply(loaded,{action='Activate',requestId='activate5',heroId='hero',story=5},ctx));check(Pass.view(q,'hero').credits==8,'next story uses exactly one more credit')
q=assert(apply(q,{action='End',requestId='end5',heroId='hero'},{serverEnd=true}));check(not Pass.view(q,'hero').active and Pass.view(q,'hero').credits==8,'return ends current support only')
q=assert(apply(q,{action='Activate',requestId='again5',heroId='hero',story=5},ctx));check(Pass.view(q,'hero').credits==7,'return/restart cannot revive the old consumed story entitlement')
local old=R.copy(base);old.heroes.hero.deepwood.seleneFollowing=true
check(not Pass.view(old,'hero').active and Pass.view(old,'hero').credits==0,'legacy free following creates no paid rights')
local cached;local lose=false
local store=Store.new({UpdateAsync=function(_,_,fn)local n=fn(R.copy(cached));if n then cached=R.copy(n)end;if lose then error('lost acknowledgement')end;return n end},R,C,function()return 1000 end,function()end,'support-test')
assert(store:open(77));assert(store:transact(77,function(v)local n=R.copy(base);n.epoch=v.epoch;n.lease=v.lease;return n end))
local purchase={action='Buy',requestId='uncertain',heroId='hero',revision=base.revision,offerId='selene_story_5'}
lose=true;local value,why=store:transact(77,function(v)return apply(v,purchase)end);check(not value and why=='SaveUnknown','lost acknowledgement is not success')
lose=false;value=assert(store:transact(77,function(v)return apply(v,purchase)end));check(value.wallet.gold==9000 and Pass.view(value,'hero').credits==5,'same receipt recovers one debit and one pack after unknown save')
local bad=R.copy(value);bad.supportPasses.credits=-1;check(not R.validate(bad,C),'invalid paid ledger fails validation')
bad=R.copy(value);bad.heroes=nil;check(not R.validate(bad,C),'missing heroes with paid ledger fails closed')
print('Support passes: '..count..' checks passed')
