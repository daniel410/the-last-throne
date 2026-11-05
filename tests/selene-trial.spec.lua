local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items=dofile('src/shared/ItemCatalog.luau')
local Content=dofile('src/shared/CampaignContent.luau')
local A=dofile('src/shared/AdventureRules.luau')
local Pass=dofile('src/shared/SupportPassRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local Info=dofile('src/shared/SupporterInfo.luau')
local Completion=dofile('src/shared/StoryCompletion.luau')
local count=0;local function check(v,m)count=count+1;assert(v,m)end
local p=assert(R.addHero(R.new(87),'hero','knight',Items))
p=assert(A.begin(p,'hero','DW-01','Easy','trial_run',p.revision,R,Items))
local function finish(profile,id)
 local c=Content.byId[id]
 for _,g in ipairs(c.goals)do if not g.optional then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do
   profile=assert(A.event(profile,'hero',id,g.id,step and step.choices and step.choices[1].id or g.choice and 'shared' or nil,step and step.id or nil,R,Items,'trial_run'))
  end
 end end
 return profile
end
local function activate(profile,id,ctx)
 local view=Pass.view(profile,'hero')
 return R.supportPass(profile,{action='Activate',heroId='hero',story=view.story,scope=view.scope,requestId=id},ctx or {inAdventure=true,hasCampAccess=true,maxStories=35},Items)
end
check(not Pass.view(p,'hero').trialAvailable,'fresh hero cannot start trial')
local no,err=activate(p,'locked');check(not no and err=='StoryLocked','trial cannot bypass rescue')
p=finish(p,'DW-01');p=finish(p,'DW-02')
check(not Pass.view(p,'hero').trialAvailable,'story 3 must be complete before introduction')
p=finish(p,'DW-03')
local base=R.copy(p);local view=Pass.view(p,'hero')
check(view.trialAvailable and view.story==4 and not view.active,'rescue completion opens one-story trial on story 4')
check(Info.project(A.projection(p.heroes.hero),nil,nil,false,view).key=='TrialReady','details explain automatic free support')
no,err=activate(p,'notcamp',{inAdventure=true,hasCampAccess=false});check(not no and err=='Unavailable' and Pass.view(p,'hero').trialAvailable,'out-of-camp request preserves trial')
no,err=activate(p,'lobby',{hasCampAccess=true});check(not no and err=='Unavailable','lobby cannot activate trial')
local gold=p.wallet.gold
p=assert(activate(p,'trial'))
view=Pass.view(p,'hero')
check(view.active and view.trial and not view.trialAvailable and view.credits==0,'trial needs no purchased credits')
check(p.wallet.gold==gold and p.heroes.hero.deepwood.seleneFollowing and p.supportPasses.trials.hero,'free support and used marker commit together without Gold')
check(R.validate(p,Items),'trial ledger is valid')
check(Info.project(A.projection(p.heroes.hero),nil,'Following',false,view).key=='TrialFollowing','active details clearly identify free trial')
local revision=p.revision;p=assert(activate(p,'same_story'));check(p.revision==revision,'same-story invitation cannot consume trial again')
local copy=R.copy(p);check(Pass.view(copy,'hero').active and Pass.view(copy,'hero').trial,'reload resumes the same trial')
p=assert(R.selectSelene(p,'hero',false));check(Pass.view(p,'hero').active,'rest keeps current trial entitlement')
p=assert(R.selectSelene(p,'hero',true));check(Pass.view(p,'hero').credits==0,'resume uses no credits')
local before={heroId='hero',supporter={pass=Pass.view(p,'hero')}}
p=finish(p,'DW-04');view=Pass.view(p,'hero')
check(not view.active and not view.trialAvailable and view.credits==0,'story completion ends trial permanently without automatic renewal')
local card=Completion.project({heroId='hero',journal=A.projection(p.heroes.hero),completion={id='DW-04',xp=0,coins=0}},before)
check(card.support==Info.text.trialEnded and card.support:find('Dawnspire lobby',1,true),'completion card sends the player to lobby Selene')
no,err=activate(p,'again');check(not no and err=='SupportPassRequired','next story cannot start another free trial')
p.wallet.gold=1000
p=assert(R.supportPass(p,{action='Buy',heroId='hero',requestId='buy',revision=p.revision,offerId='selene_story_1'},{atLobby=true},Items))
p=assert(activate(p,'paid'))
check(Pass.view(p,'hero').active and not Pass.view(p,'hero').trial and Pass.view(p,'hero').credits==0 and p.wallet.gold==800,'later support consumes paid credit at existing price')
-- An interrupted trial is not a second entitlement after Return to Lobby.
local ended=assert(activate(base,'return_trial'))
ended=assert(R.supportPass(ended,{action='End',heroId='hero',requestId='end_trial'},{serverEnd=true},Items))
check(not Pass.view(ended,'hero').active and not Pass.view(ended,'hero').trialAvailable,'Return to Lobby does not reset trial use')
no,err=activate(ended,'return_again');check(not no and err=='SupportPassRequired','return cannot farm free support')
-- Saved paid credits are preserved when the introduction is still unused.
local funded=R.copy(base);funded.supportPasses={version=1,credits=5,active={}}
funded=assert(activate(funded,'funded_trial'))
check(Pass.view(funded,'hero').trial and Pass.view(funded,'hero').credits==5,'trial does not consume purchased credits')
-- Unknown write response: retry the same activation and recover one trial.
local saved,lose
local store=Store.new({UpdateAsync=function(_,_,fn)local n=fn(R.copy(saved));if n then saved=R.copy(n)end;if lose then error('lost response')end;return n end},R,Items,function()return 1000 end,function()end,'selene-trial')
assert(store:open(87));assert(store:transact(87,function(current)local n=R.copy(base);n.lease=current.lease;n.epoch=current.epoch;return n end))
lose=true;no,err=store:transact(87,function(v)return activate(v,'uncertain_trial')end)
check(not no and err=='SaveUnknown','unknown save never confirms trial')
lose=false;local recovered=assert(store:transact(87,function(v)return activate(v,'uncertain_trial')end))
check(Pass.view(recovered,'hero').active and recovered.supportPasses.trials.hero and recovered.wallet.gold==base.wallet.gold,'same receipt recovers single free entitlement')
local legacy=R.copy(base);check(not legacy.supportPasses and Pass.view(legacy,'hero').trialAvailable,'existing rescued save receives unused trial without resetting progress')
local bad=R.copy(funded);bad.supportPasses.trials.hero=false;check(not R.validate(bad,Items),'invalid trial marker is rejected')
bad=R.copy(funded);bad.supportPasses.trials={stranger=true};check(not R.validate(bad,Items),'unowned trial marker is rejected')
bad=R.copy(funded);bad.supportPasses.active.hero.trial='true';check(not R.validate(bad,Items),'invalid trial entitlement is rejected')
print('Selene trial: '..count..' checks passed')
