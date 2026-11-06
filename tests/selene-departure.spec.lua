-- User contract: lobby purchase -> follower -> admitted main story, no camp detour.
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Pass=dofile('src/shared/SupportPassRules.luau')
local Info=dofile('src/shared/SupporterInfo.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local function finish(p,id)
 for _,g in ipairs(Content.byId[id].goals)do if not g.optional then
  for _,s in ipairs(g.activity and g.activity.steps or {false})do
   p=assert(R.story(p,'hero',id,g.id,s and s.choices and s.choices[1].id or g.choice and 'shared' or nil,C,s and s.id or nil))
  end
 end end
 return p
end
local base=assert(R.addHero(R.new(95),'hero','knight',C))
for i=1,3 do base=finish(base,'DW-0'..i)end
base.heroes.hero.level=80;base.heroes.hero.progression=dofile('src/shared/HeroProgression.luau').new(80)
base.wallet.gold=10000
base.supportPasses={version=1,credits=0,active={},trials={hero=true}}
local function apply(p,cmd,ctx)return R.supportPass(p,cmd,ctx or {atLobby=true},C)end
local buy={action='Buy',heroId='hero',offerId='selene_story_5',revision=base.revision,requestId='buy'}
local p=assert(apply(base,buy));local v=Pass.view(p,'hero')
check(v.departure and v.credits==5 and not v.active,'purchase selects lobby follower without using a credit')
check(p.wallet.gold==9000,'existing five-story price preserved')
local duplicate=assert(apply(p,buy));check(duplicate.revision==p.revision and duplicate.supportPasses.credits==5,'purchase retry preserves single grant and selection')
check(Info.project(p.heroes.hero.deepwood,nil,nil,true,v).key=='DepartureReady','details explain departure instead of camp detour')
local loaded=R.copy(p);check(Pass.view(loaded,'hero').departure,'selection survives save/load and teleport independently of client data')
-- Admission creates a new run scope; consume against that scope, never lobby preview.
p=assert(A.begin(p,'hero','DW-04','Easy','depart_run',p.revision,R,C));v=Pass.view(p,'hero')
local activate={action='Activate',heroId='hero',story=v.story,scope=v.scope,requestId='entry'}
p=assert(apply(p,activate,{inAdventure=true,hasCampAccess=false}));v=Pass.view(p,'hero')
check(v.active and v.credits==4 and not v.departure,'entry away from every camp consumes exactly one credit and clears departure')
check(p.heroes.hero.deepwood.seleneFollowing,'entry saves actual following with entitlement')
local again=assert(apply(p,activate,{inAdventure=false}));check(again.supportPasses.credits==4,'same receipt cannot consume twice even after departure cleared')
local resume={action='Activate',heroId='hero',story=v.story,scope=v.scope,requestId='resume'}
local resumed=assert(apply(p,resume,{inAdventure=true,hasCampAccess=true}));check(resumed.supportPasses.credits==4,'same-story camp resume costs nothing')
local unprepared=R.copy(base);unprepared.supportPasses.credits=2
local no,err=apply(unprepared,{action='Activate',heroId='hero',story=4,requestId='forged'},{inAdventure=true,hasCampAccess=false})
check(not no and err=='Unavailable','credits alone cannot enable arbitrary remote activation')
local prep={action='Prepare',heroId='hero',requestId='prepare'}
no,err=apply(unprepared,prep,{atLobby=false});check(not no and err=='ShopLobbyOnly','only confirmed lobby can prepare departure')
local prepared=assert(apply(unprepared,prep));check(prepared.supportPasses.credits==2 and Pass.view(prepared,'hero').departure,'previously purchased credits get a lobby follower without repurchase')
local rev=prepared.revision
prepared=assert(apply(prepared,{action='Prepare',heroId='hero',requestId='prepare_again'}));check(prepared.revision==rev,'already prepared lobby state produces no new mutation')
local fresh=assert(R.addHero(R.new(96),'hero','mage',C));fresh.wallet.gold=1000
fresh=assert(apply(fresh,{action='Buy',heroId='hero',offerId='selene_story_1',revision=fresh.revision,requestId='lockedbuy'}))
check(not Pass.view(fresh,'hero').departure and fresh.supportPasses.credits==1,'purchase before rescue remains saved without bypassing recruitment')
no,err=apply(fresh,prep);check(not no and err=='StoryLocked','lobby preparation preserves rescue gate')
no,err=apply(base,prep);check(not no and err=='SupportPassRequired','no credit or trial means no follower rights')
local trial=R.copy(base);trial.supportPasses=nil
trial=assert(apply(trial,prep));check(Pass.view(trial,'hero').departure and Pass.view(trial,'hero').trialAvailable,'unused free trial can depart from lobby')
trial=assert(apply(trial,{action='Activate',heroId='hero',story=4,requestId='trialentry'},{inAdventure=true,hasCampAccess=false}))
check(Pass.view(trial,'hero').trial and trial.supportPasses.credits==0 and trial.wallet.gold==10000,'free introduction remains free on departure')
local bad=R.copy(prepared);bad.supportPasses.departure='stranger';check(not R.validate(bad,C),'departure must reference owned hero')
bad=R.copy(prepared);bad.supportPasses.departure={};check(not R.validate(bad,C),'malformed saved selection rejected')
local ended=assert(apply(p,{action='End',heroId='hero',requestId='return'},{serverEnd=true}))
check(not Pass.view(ended,'hero').active and ended.supportPasses.credits==4,'return ends only current support')
-- Next story cannot silently spend a second credit within the same adventure.
for _,g in ipairs(Content.byId['DW-04'].goals)do if not g.optional then
 for _,s in ipairs(g.activity and g.activity.steps or {false})do
  p=assert(A.event(p,'hero','DW-04',g.id,s and s.choices and s.choices[1].id or g.choice and 'shared' or nil,s and s.id or nil,R,C,'depart_run'))
 end
end end
check(not Pass.view(p,'hero').active and not Pass.view(p,'hero').departure and p.supportPasses.credits==4,'completion clears active support without automatic paid renewal')
-- Side adventure entry retains departure but does not consume next main-story credit.
local side=assert(A.begin(prepared,'hero','DW-Q1','Easy','side_run',prepared.revision,R,C));local sv=Pass.view(side,'hero')
check(sv.side and sv.departure,'side entry retains main-story departure intent')
no,err=apply(side,{action='Activate',heroId='hero',story=sv.story,scope=sv.scope,requestId='sideentry'},{inAdventure=true,hasCampAccess=false})
check(not no and err=='Unavailable' and side.supportPasses.credits==2,'side entry cannot accidentally consume main-story credit')
-- AccountStore recovery replays the same entry receipt after a lost response.
local saved,lose
local store=Store.new({UpdateAsync=function(_,_,fn)local q=fn(R.copy(saved));if q then saved=R.copy(q)end;if lose then error('lost acknowledgement')end;return q end},R,C,function()return 1000 end,function()end,'departure-test')
assert(store:open(95));assert(store:transact(95,function(current)local q=R.copy(loaded);q.lease=current.lease;q.epoch=current.epoch;return q end))
local cmd={action='Activate',heroId='hero',story=4,scope=Pass.view(loaded,'hero').scope,requestId='uncertain_entry'}
lose=true;no,err=store:transact(95,function(q)return apply(q,cmd,{inAdventure=true,hasCampAccess=false})end)
check(not no and err=='SaveUnknown','unknown save cannot confirm entry')
lose=false;local recovered=assert(store:transact(95,function(q)return apply(q,cmd,{inAdventure=true,hasCampAccess=false})end))
check(Pass.view(recovered,'hero').active and recovered.supportPasses.credits==4 and not Pass.view(recovered,'hero').departure,'same entry receipt recovers one consumption and one active entitlement')
print('Selene departure: '..n..' checks passed')
