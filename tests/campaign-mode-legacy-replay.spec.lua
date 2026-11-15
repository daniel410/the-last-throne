-- Legacy epic gaps must survive difficulty changes, replays and account reloads.
local function load(name)return dofile('src/shared/'..name..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local C,P,A,D,G,Items=load('CampaignContent'),load('DeepwoodProgress'),load('AdventureRules'),load('Difficulty'),load('HeroProgression'),load('ItemCatalog')
local checks=0
local function check(value,message)checks=checks+1;assert(value,message)end
local function same(a,b)
 if type(a)~=type(b)then return false end
 if type(a)~='table'then return a==b end
 for key,value in pairs(a)do if not same(value,b[key])then return false end end
 for key in pairs(b)do if a[key]==nil then return false end end
 return true
end
local function events(c,required,fn)
 for _,goal in ipairs(c.goals)do if required(goal)then
  for _,step in ipairs(goal.activity and goal.activity.steps or {false})do
   local choice=step and step.choices and(step.solution or step.choices[1].id)or goal.choice and 'sanctuary'or nil
   fn(goal,choice,step and step.id or nil)
  end
 end end
end
local function legacyAccount(userId,completed,expanded)
 local journal=P.new();journal.version=1
 for i=1,completed or 21 do local c=C.legacyMainChapters[i]
  events(c,function(goal)return not goal.optional end,function(goal,choice,step)
   journal=assert(P.apply(journal,c.id,goal.id,choice,step))
  end)
 end
 if expanded then journal=assert(P.enableExpansion(journal))end
 check(P.validate(journal),'historic journal is valid before migration')
 local profile=assert(R.addHero(R.new(userId),'hero','knight',Items));local hero=profile.heroes.hero
 hero.level=99;hero.progression=G.new(99);hero.deepwood=journal
 hero.expeditions={version=1,clears={},cacheProgress={}}
 profile=R.upgrade(profile,Items)
 check(R.validate(profile,Items),'historic account migrates into a valid separated profile')
 check(profile.heroes.hero.expeditions.modeJournals.Hard.main==0,'historic Easy clears do not seed Hard progress')
 return profile
end
local function gapRemains(profile,message,checkGlobal)
 local hero=profile.heroes.hero;local journal=hero.expeditions.modeJournals.Easy
 check(journal.main==7,message..': Easy frontier stays before the actual Gloamwood gap')
 local journals={journal};if checkGlobal then journals[#journals+1]=hero.deepwood end
 for i=8,14 do local c=C.mainChapters[i]
  check(not hero.expeditions.modeRewardClaims.Easy[c.id],message..': no fabricated reward receipt '..c.id)
  for _,saved in ipairs(journals)do
   check(not saved.clears[c.id],message..': synthetic clear never enters permanent history '..c.id)
   for _,goal in ipairs(c.goals)do
    local key=c.id..':'..goal.id
    check(not saved.flags[key]and not saved.activities[key]and not saved.clues[key],message..': synthetic objective never enters permanent history '..key)
    check(not(saved.expansionWaivers or {})[key]and not(saved.pacingWaivers or {})[key],message..': synthetic waiver never enters permanent history '..key)
    for _,step in ipairs(goal.activity and goal.activity.steps or {})do
     check(not saved.decisions[key..':'..step.id],message..': synthetic decision never enters permanent history '..key)
    end
   end
  end
 end
end
local function begin(profile,mission,mode,run)
 local nextProfile,reason=A.begin(profile,'hero',mission,mode,run,profile.revision,R,Items,D.version)
 assert(nextProfile,tostring(reason)..' entering '..mission..' '..mode)
 check(R.validate(nextProfile,Items),'admission produces a loadable account')
 return nextProfile
end
local function apply(profile,c,goal,choice,step,run)
 local nextProfile,reason=A.event(profile,'hero',c.id,goal.id,choice,step,R,Items,run)
 assert(nextProfile,tostring(reason)..' applying '..c.id..':'..goal.id)
 check(R.validate(nextProfile,Items),'objective produces a loadable account '..c.id..':'..goal.id)
 local retry=assert(A.event(nextProfile,'hero',c.id,goal.id,choice,step,R,Items,run))
 check(same(retry,nextProfile),'objective retry cannot advance or regrant '..c.id..':'..goal.id)
 return nextProfile
end
local function finish(profile,c,run)
 events(c,function(goal)return P.required(A.projection(profile.heroes.hero),goal)end,function(goal,choice,step)
  profile=apply(profile,c,goal,choice,step,run)
 end)
 check(profile.heroes.hero.expeditions.active.journal.clears[c.id],'run actually completes '..c.id)
 return profile
end
local function equipment(profile)
 local result={}
 for id,item in pairs(profile.items)do
  if Items.items[item.definitionId].category=='Equipment'then result[id]=R.copy(item)end
 end
 return result
end
local function reconnect(profile,label)
 local database=R.copy(profile)
 local adapter={UpdateAsync=function(_,_,transform)
  local nextProfile=transform(R.copy(database))
  if nextProfile then database=R.copy(nextProfile)end
  return nextProfile and R.copy(database)
 end}
 local first=Store.new(adapter,R,Items,function()return 100 end,function()end,label..'_before')
 local opened=assert(first:open(profile.userId))
 local journal=R.copy(opened.heroes.hero.expeditions.modeJournals)
 local checkpoint=R.copy(opened.heroes.hero.expeditions.active)
 local rewards={gold=opened.wallet.gold,diamonds=opened.wallet.diamonds,items=R.copy(opened.items),claims=R.copy(opened.heroes.hero.expeditions.modeRewardClaims)}
 assert(first:close(profile.userId))
 local second=Store.new(adapter,R,Items,function()return 101 end,function()end,label..'_after')
 local reloaded=assert(second:open(profile.userId))
 check(same(reloaded.heroes.hero.expeditions.modeJournals,journal),'account reconnect preserves every difficulty journal')
 check(same(reloaded.heroes.hero.expeditions.active,checkpoint),'account reconnect preserves the actual replay checkpoint')
 check(reloaded.wallet.gold==rewards.gold and reloaded.wallet.diamonds==rewards.diamonds,'account reconnect cannot repay first or repeat money')
 check(same(reloaded.items,rewards.items)and same(reloaded.heroes.hero.expeditions.modeRewardClaims,rewards.claims),'account reconnect cannot reissue items or reward receipts')
 local closed=assert(second:close(profile.userId))
 return closed
end

-- Hard supplies the missing GW clears while global history already contains FV/EC.
local hard=legacyAccount(851)
gapRemains(hard,'before Hard campaign')
local easyBefore=R.copy(hard.heroes.hero.expeditions.modeJournals.Easy)
hard=begin(hard,'DW-01','Hard','legacy_hard')
local goldBefore,expectedGold=hard.wallet.gold,0
for i=1,14 do local c=C.mainChapters[i]
 hard=finish(hard,c,'legacy_hard');expectedGold=expectedGold+c.reward.coins
end
check(hard.heroes.hero.expeditions.modeJournals.Hard.main==14,'Hard GW-07 completion advances its own real frontier')
check(hard.heroes.hero.deepwood.main==28,'shared history recalculates the complete union past historical FV/EC')
check(same(hard.heroes.hero.expeditions.modeJournals.Easy,easyBefore),'Hard GW completion leaves the Easy gap and choices unchanged')
check(hard.wallet.gold-goldBefore==expectedGold,'Hard receives each first quest Gold award once')
check(hard.heroes.hero.expeditions.modeRewardClaims.Hard['GW-07'],'Hard final Gloamwood award has a durable receipt')
hard=reconnect(hard,'legacy_hard')
gapRemains(hard,'after Hard completion and reconnect')

-- A FV replay has synthetic prior chapters only in its run projection.
local replay=legacyAccount(852)
local initialGold,initialDiamonds=replay.wallet.gold,replay.wallet.diamonds
local firstEquipment=equipment(replay)
replay=begin(replay,'FV-07','Easy','legacy_fv')
gapRemains(replay,'on FV replay admission',true)
check(replay.wallet.gold==initialGold and replay.wallet.diamonds==initialDiamonds,'replay admission does not award money')
local c=C.byId['FV-07'];local firstGoal=c.goals[1];local firstStep=firstGoal.activity and firstGoal.activity.steps and firstGoal.activity.steps[1]
local firstChoice=firstStep and firstStep.choices and(firstStep.solution or firstStep.choices[1].id)or firstGoal.choice and 'sanctuary'or nil
replay=apply(replay,c,firstGoal,firstChoice,firstStep and firstStep.id or nil,'legacy_fv')
local checkpoint=R.copy(replay.heroes.hero.expeditions.active.journal)
replay=begin(replay,'DW-01','Hard','legacy_hard_detour')
gapRemains(replay,'after leaving the partial FV replay',true)
replay=begin(replay,'FV-07','Easy','legacy_fv_return')
check(same(replay.heroes.hero.expeditions.active.journal,checkpoint),'mode round trip restores the real partial FV replay')
gapRemains(replay,'after restoring the FV replay',true)
replay=reconnect(replay,'legacy_fv')
gapRemains(replay,'after reconnecting the partial FV replay',true)
replay=finish(replay,c,'legacy_fv_return')
check(replay.wallet.gold-initialGold==D.completion(c,'Easy',D.version).gold,'FV replay grants only its configured repeat Gold')
check(replay.wallet.diamonds==initialDiamonds and same(equipment(replay),firstEquipment),'FV replay cannot duplicate first Diamonds or equipment')
gapRemains(replay,'after FV replay completion',true)
local continuation=A.continuation(replay.heroes.hero.expeditions.active)
check(continuation and continuation.id=='EC-01','explicit FV replay can continue the next actual replay chapter')
local caldera=C.byId['EC-01'];local calderaGold=replay.wallet.gold
replay=finish(replay,caldera,'legacy_fv_return')
check(replay.wallet.gold-calderaGold==D.completion(caldera,'Easy',D.version).gold,'continued EC replay grants only its configured repeat Gold')
check(replay.wallet.diamonds==initialDiamonds and same(equipment(replay),firstEquipment),'continued EC replay cannot duplicate its first equipment or Diamonds')
gapRemains(replay,'after the continued EC replay',true)
replay=reconnect(replay,'legacy_ec')
gapRemains(replay,'after reconnecting the continued replay',true)

-- Historic EC completion does not waive the actual missing GW epic before HG.
for i=23,28 do local chapter=C.mainChapters[i];local before=replay.wallet.gold
 replay=finish(replay,chapter,'legacy_fv_return')
 check(replay.wallet.gold-before==D.completion(chapter,'Easy',D.version).gold,'continued EC chapter grants only repeat Gold '..chapter.id)
end
gapRemains(replay,'after all historical EC replay chapters',true)
check(A.continuation(replay.heroes.hero.expeditions.active).id=='HG-01','historical replay reaches its first uncompleted chapter')
local allowed,blocked=D.allowed(replay.heroes.hero,'HG-01','Easy')
check(not allowed and blocked=='StoryLocked','unplayed GW still gates a new HG first clear after the historical replay')

-- A legacy28 account really completed GW, so replay can reach a first HG quest.
-- Existing GW choices, objectives and migration waivers must remain unchanged.
local function gloamwoodRecords(journal)
 local result={}
 for _,field in ipairs({'flags','clears','activities','decisions','accepted','clues','expansionWaivers','pacingWaivers'})do
  result[field]={}
  for key,value in pairs(journal[field]or {})do if key:sub(1,3)=='GW-'then result[field][key]=R.copy(value)end end
 end
 return result
end
local newQuest=legacyAccount(853,28,true)
newQuest.heroes.hero.level=80;newQuest.heroes.hero.progression=G.new(80)
local oldGlobalGW=gloamwoodRecords(newQuest.heroes.hero.deepwood)
local oldModeGW=gloamwoodRecords(newQuest.heroes.hero.expeditions.modeJournals.Easy)
newQuest=begin(newQuest,'FV-07','Easy','legacy_new_quest')
for i=21,28 do newQuest=finish(newQuest,C.mainChapters[i],'legacy_new_quest')end
check(A.continuation(newQuest.heroes.hero.expeditions.active).id=='HG-01','eligible historical replay reaches a new Haunted quest')
local haunted=C.byId['HG-01'];local hauntedGold,hauntedDiamonds=newQuest.wallet.gold,newQuest.wallet.diamonds
local hauntedXP=G.totalXP(newQuest.heroes.hero.progression)
local firstItems=equipment(newQuest)
check(not newQuest.heroes.hero.expeditions.modeRewardClaims.Easy[haunted.id],'new Haunted chapter has no prior first reward receipt')
newQuest=finish(newQuest,haunted,'legacy_new_quest')
check(newQuest.wallet.gold-hauntedGold==haunted.reward.coins,'new chapter reached through replay receives its first Gold exactly once')
check(newQuest.wallet.diamonds-hauntedDiamonds==3,'new Easy chapter reached through replay receives its first Diamonds exactly once')
check(G.totalXP(newQuest.heroes.hero.progression)-hauntedXP==load('CampaignXPRewards').Easy[haunted.id].quest,'new chapter reached through replay receives its actual first quest XP')
check(newQuest.heroes.hero.expeditions.modeRewardClaims.Easy[haunted.id]and newQuest.heroes.hero.expeditions.modeJournals.Easy.clears[haunted.id],'new chapter clear and first reward receipt are committed together')
check(same(equipment(newQuest),firstItems),'historical first equipment is not reissued while replay reaches a new chapter')
check(same(gloamwoodRecords(newQuest.heroes.hero.deepwood),oldGlobalGW),'new replay first-clear transaction preserves global GW records and waivers')
check(same(gloamwoodRecords(newQuest.heroes.hero.expeditions.modeJournals.Easy),oldModeGW),'new replay first-clear transaction preserves canonical GW records and waivers')
newQuest=reconnect(newQuest,'legacy_haunted')
check(same(gloamwoodRecords(newQuest.heroes.hero.deepwood),oldGlobalGW)and same(gloamwoodRecords(newQuest.heroes.hero.expeditions.modeJournals.Easy),oldModeGW),'reconnecting the new first-clear transaction preserves both GW histories')
print('Campaign mode legacy replay: '..checks..' checks passed')
