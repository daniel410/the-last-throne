-- 기존 저장 일지의 근거: eb3c4e7dea79512adce9fa0ee714e9166f3a8ff9.
-- 해당 소스에서 Easy DW-01/02 완료 후 DW-Q1 보고 직전, 또는 Easy
-- DW-02 cart_guards 완료 후 Hard DW-01 재도전을 시작한 실제 저장 형태다.
-- 첫 Hard DW-01 trail_guards 완료 시 글로벌/활성 일지에 함께 기록된
-- 진도는 Hard에만 귀속하며, 다른 Easy 선택 퀘스트는 별도로 보존한다.
-- 최소 일지를 고정하여 검사 실행 시 Git 이력이나 네트워크에 의존하지 않는다.
local function load(n)return dofile('src/shared/'..n..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local Items,P,A,M,S,C,G=load('ItemCatalog'),load('DeepwoodProgress'),load('AdventureRules'),load('CampaignModeProgress'),load('LobbySideQuests'),load('CampaignContent'),load('HeroProgression')
local checks=0;local function check(v,m)checks=checks+1;assert(v,m)end
local function same(a,b)
 if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end
 for k,v in pairs(a)do if not same(v,b[k])then return false end end
 for k in pairs(b)do if a[k]==nil then return false end end;return true
end
local function firstJournal()
 local j=P.new();j.main=1;j.coins=150;j.clears['DW-01']=true
 j.flags={['DW-01:trail_guards']=true,['DW-01:tracks']=true,['DW-01:supplies']=true,['DW-01:supply_guards']=true,['DW-01:trail_exit']=true}
 j.activities={['DW-01:tracks']=3,['DW-01:supplies']=3,['DW-01:trail_exit']=1}
 j.clues={['DW-01:supplies']={bindings=true,manifest=true,resin=true}}
 return j
end
local function secondJournal()
 local j=firstJournal();j.main=2;j.coins=390;j.clears['DW-02']=true
 for _,id in ipairs({'cart_guards','survivors','testimony','escape_guards','clearing_exit'})do j.flags['DW-02:'..id]=true end
 j.activities['DW-02:survivors']=3;j.activities['DW-02:testimony']=3;j.activities['DW-02:clearing_exit']=2
 j.clues['DW-02:testimony']={crest=true,ritual=true,witness=true}
 return j
end
local function legacy(journal,mode,mission,run,activeJournal)
 local p=assert(R.addHero(R.new(850),'hero','knight',Items));local h=p.heroes.hero
 h.level=80;h.progression=G.new(80);h.deepwood=P.copy(journal)
 h.expeditions={version=1,clears={},cacheProgress={['1']=journal.main%4},active={version=1,balanceVersion=1,runId=run,missionId=mission,difficultyId=mode,journal=P.copy(activeJournal or journal),completed=false,firstClear=not journal.clears[mission],kills={},completedChapters={}}}
 p.wallet.gold=journal.coins;p.wallet.heroClaims.hero={}
 for id in pairs(journal.clears)do
  h.expeditions.clears[id]={Easy=true};p.wallet.heroClaims.hero[id]={Easy=true};p.wallet.diamonds=p.wallet.diamonds+3
 end
 check(R.validate(p,Items),'legacy account fixture is valid '..run)
 check(not h.expeditions.modeJournals and not h.expeditions.active.modeProgressVersion,'fixture predates separate mode journals')
 return p
end
local function row(p,id)
 for _,v in ipairs(S.project({ready=true,heroId='hero',heroes=p.heroes}).rows)do if v.id==id then return v end end
end
local function reload(p,label)
 local loaded=assert(R.upgrade(R.copy(p),Items))
 check(R.validate(loaded,Items),'reloaded account is valid '..label)
 check(same(loaded,p),'reload is idempotent for progress, payouts and revision '..label)
 return loaded
end
-- A pending side report is personal progress even though no clear receipt exists.
local sideJournal=secondJournal();sideJournal.accepted['DW-Q1']=true;sideJournal.flags['DW-Q1:waterproof_log']=true
local side=legacy(sideJournal,'Easy','DW-Q1','old-side')
check(row(side,'DW-Q1').canReport,'old side quest is ready to report before migration')
local sideBefore=R.copy(side)
side=assert(R.upgrade(side,Items))
check(R.validate(side,Items),'migrated pending side account is valid')
check(same(side.heroes.hero.deepwood,sideBefore.heroes.hero.deepwood),'migration retains the original shared journal')
check(same(side.wallet,sideBefore.wallet)and same(side.items,sideBefore.items),'migration does not repay existing story rewards')
local hero=side.heroes.hero
check(P.accepted(M.journal(hero,'Easy'),C.byId['DW-Q1']),'Easy canonical journal keeps accepted side quest')
check(hero.expeditions.active.journal.flags['DW-Q1:waterproof_log'],'active side objective survives migration')
check(row(side,'DW-Q1').phase=='report'and row(side,'DW-Q1').canReport,'pending side quest can still be reported')
for _,mode in ipairs({'Hard','Insane','Hell'})do
 local j=M.journal(hero,mode)
 check(not j.accepted['DW-Q1']and not j.flags['DW-Q1:waterproof_log']and not j.clears['DW-Q1'],'Easy side progress is not inherited by '..mode)
end
side=reload(side,'pending side report')
local report={action='Report',heroId='hero',questId='DW-Q1',runId='old-side'}
local reported=assert(S.apply(side,report,R,Items))
check(reported.heroes.hero.expeditions.modeJournals.Easy.clears['DW-Q1'],'migrated side quest completes on Easy')
check(reported.wallet.gold-side.wallet.gold==C.byId['DW-Q1'].reward.coins,'pending side report grants its first Gold once')
check(same(assert(S.apply(reported,report,R,Items)),reported),'repeated migrated report cannot duplicate progress or rewards')
reported=reload(reported,'completed side report')
check(same(assert(S.apply(reported,report,R,Items)),reported),'report retry after reconnect remains idempotent')
-- Starting a Hard replay before the migration must not hide Easy's next objective.
local partialJournal=firstJournal();partialJournal.flags['DW-02:cart_guards']=true
local partial=legacy(partialJournal,'Hard','DW-01','old-hard',P.new())
local partialBefore=R.copy(partial)
partial=assert(R.upgrade(partial,Items));hero=partial.heroes.hero
check(R.validate(partial,Items),'migrated Easy partial account is valid')
check(same(hero.deepwood,partialBefore.heroes.hero.deepwood),'migration retains the legacy Easy partial source')
check(same(partial.wallet,partialBefore.wallet)and same(partial.items,partialBefore.items),'Easy partial migration grants no new payout')
check(M.journal(hero,'Easy').main==1 and M.journal(hero,'Easy').flags['DW-02:cart_guards'],'Easy main objective survives an active Hard replay')
for _,mode in ipairs({'Hard','Insane','Hell'})do
 local j=M.journal(hero,mode)
 check(j.main==0 and not j.clears['DW-01']and not j.flags['DW-02:cart_guards'],'Easy partial or clear is not inherited by '..mode)
end
check(A.selection(hero,'Easy').missionId=='DW-02'and A.selection(hero,'Hard').missionId=='DW-01','migration retains each difficulty frontier')
partial=reload(partial,'Easy partial while Hard active')
partial=assert(A.begin(partial,'hero','DW-02','Easy','easy-return',partial.revision,R,Items))
check(A.projection(partial.heroes.hero).flags['DW-02:cart_guards'],'returning to Easy resumes the migrated objective')
local easyBefore=R.copy(partial.heroes.hero.expeditions.modeJournals.Easy)
partial=assert(A.begin(partial,'hero','DW-01','Hard','hard-return',partial.revision,R,Items))
check(not A.projection(partial.heroes.hero).flags['DW-02:cart_guards'],'returning to Hard does not import Easy progress')
check(same(partial.heroes.hero.expeditions.modeJournals.Easy,easyBefore),'switching back to Hard leaves Easy progress unchanged')
partial=reload(partial,'mode round trip')
-- A completed replay points at the next chapter before that mode has played it.
-- Only actual continuation events can establish ownership of a partial chapter.
local function completedHardCheckpoint(continued)
 local p=legacy(partialJournal,'Hard','DW-01',continued and 'old-hard-continued'or 'old-hard-completed',P.new())
 local e=p.heroes.hero.expeditions
 e.active.journal=firstJournal();e.active.completed=true;e.active.completedChapters['DW-01']=true
 e.clears['DW-01'].Hard=true;e.cacheProgress['1']=3
 p.wallet.heroClaims.hero['DW-01'].Hard=true;p.wallet.diamonds=p.wallet.diamonds+5
 if continued then e.active.journal.flags['DW-02:cart_guards']=true end
 check(R.validate(p,Items),'legacy completed Hard checkpoint is valid')
 return p
end
local completedHard=assert(R.upgrade(completedHardCheckpoint(false),Items))
check(M.journal(completedHard.heroes.hero,'Easy').flags['DW-02:cart_guards'],'unplayed Hard continuation does not erase earlier Easy partial progress')
check(not M.journal(completedHard.heroes.hero,'Hard').flags['DW-02:cart_guards'],'unplayed Hard continuation does not inherit Easy partial progress')
completedHard=reload(completedHard,'completed Hard replay without continuation events')
local continuedHard=assert(R.upgrade(completedHardCheckpoint(true),Items))
check(M.journal(continuedHard.heroes.hero,'Hard').flags['DW-02:cart_guards'],'confirmed Hard continuation event belongs to Hard')
check(not M.journal(continuedHard.heroes.hero,'Easy').flags['DW-02:cart_guards'],'confirmed Hard continuation event is not imported into Easy')
continuedHard=reload(continuedHard,'completed Hard replay with continuation event')
-- The active Hard chapter owns matching unfinished flags in the shared journal.
local hardJournal=P.new();hardJournal.flags['DW-01:trail_guards']=true
local hardOnly=legacy(hardJournal,'Hard','DW-01','old-hard-first')
hardOnly=assert(R.upgrade(hardOnly,Items));hero=hardOnly.heroes.hero
check(R.validate(hardOnly,Items),'migrated first Hard partial account is valid')
check(M.journal(hero,'Hard').flags['DW-01:trail_guards'],'active Hard objective retains its own mode attribution')
for _,mode in ipairs({'Easy','Insane','Hell'})do
 check(not M.journal(hero,mode).flags['DW-01:trail_guards'],'active Hard partial is not inherited by '..mode)
end
hardOnly=reload(hardOnly,'first Hard partial')
hardOnly=assert(A.begin(hardOnly,'hero','DW-01','Easy','new-easy-first',hardOnly.revision,R,Items))
check(not A.projection(hardOnly.heroes.hero).flags['DW-01:trail_guards'],'first Easy launch starts without Hard partial objective')
hardOnly=assert(A.begin(hardOnly,'hero','DW-01','Hard','old-hard-first-return',hardOnly.revision,R,Items))
check(A.projection(hardOnly.heroes.hero).flags['DW-01:trail_guards'],'Hard partial resumes after an Easy visit')
-- A different active Hard chapter does not claim an unfinished Easy side quest.
local mixed=legacy(sideJournal,'Hard','DW-01','old-hard-with-easy-side',hardJournal)
mixed=assert(R.upgrade(mixed,Items));hero=mixed.heroes.hero
check(R.validate(mixed,Items),'migrated Easy side with Hard active is valid')
check(M.journal(hero,'Easy').flags['DW-Q1:waterproof_log']and M.journal(hero,'Easy').accepted['DW-Q1'],'unrelated Easy side objective survives an active Hard chapter')
check(not M.journal(hero,'Hard').flags['DW-Q1:waterproof_log']and not M.journal(hero,'Hard').accepted['DW-Q1'],'unrelated Easy side objective never enters Hard')
mixed=reload(mixed,'Easy side with Hard active')
-- Keep the saved rule contract here; expansion objectives on a new rule version
-- are covered separately from retaining this legacy report checkpoint.
mixed=assert(A.begin(mixed,'hero','DW-Q1','Easy','easy-side-return',mixed.revision,R,Items,1))
check(row(mixed,'DW-Q1').canReport,'returning to Easy side retains its pending report')
-- Without combatPacingVersion, the supported journal API skips patrol goals and
-- their gates. The current catalog can therefore produce an authentic old save.
local oldContent=C
local oldExpanded=P.new();oldExpanded.expansionVersion=1
local function oldGoal(j,c,g,step)
 return assert(P.apply(j,c.id,g.id,step and step.choices and(step.solution or step.choices[1].id)or g.choice and 'shared',step and step.id or nil))
end
for _,chapter in ipairs(oldContent.mainChapters)do
 for _,g in ipairs(chapter.goals)do if P.required(oldExpanded,g)then
  for _,step in ipairs(g.activity and g.activity.steps or {false})do oldExpanded=oldGoal(oldExpanded,chapter,g,step)end
 end end
 if chapter.id=='GW-01'then break end
end
check(P.validate(oldExpanded)and oldExpanded.main==8 and not oldExpanded.combatPacingVersion,'pre-patrol completed expanded journal is valid')
local expandedComplete=legacy(oldExpanded,'Easy','GW-02','old-expanded-completed')
expandedComplete.heroes.hero.expeditions.active=nil
expandedComplete=assert(R.upgrade(expandedComplete,Items))
local expanded=M.journal(expandedComplete.heroes.hero,'Easy')
check(R.validate(expandedComplete,Items),'pre-patrol completed expanded account migrates')
check(expanded.clears['GW-01']and expanded.combatPacingVersion==1,'expanded completion survives mode and pacing migration')
check(expanded.flags['GW-01:lantern_patrol']and expanded.pacingWaivers['GW-01:lantern_patrol'],'historic completed gate receives its pacing waiver')
expandedComplete=reload(expandedComplete,'completed pre-patrol expanded story')
local oldPartial=P.copy(oldExpanded);local chapter=oldContent.byId['GW-02']
for _,g in ipairs(chapter.goals)do if P.required(oldPartial,g)then
 local steps=g.activity and g.activity.steps or {false}
 if g.id=='exp_2'then oldPartial=oldGoal(oldPartial,chapter,g,steps[1]);break end
 for _,step in ipairs(steps)do oldPartial=oldGoal(oldPartial,chapter,g,step)end
end end
check(P.validate(oldPartial)and oldPartial.activities['GW-02:exp_2']==1 and not oldPartial.combatPacingVersion,'pre-patrol partial expanded journal is valid')
local expandedPartial=legacy(oldPartial,'Easy','GW-02','old-expanded-partial')
expandedPartial.heroes.hero.expeditions.active.balanceVersion=14
expandedPartial=assert(R.upgrade(expandedPartial,Items))
expanded=M.journal(expandedPartial.heroes.hero,'Easy')
check(R.validate(expandedPartial,Items),'pre-patrol active expanded account migrates')
check(expanded.activities['GW-02:exp_2']==1 and same(expanded.clues,oldPartial.clues),'active expanded objective and collected clues survive migration')
check(expanded.flags['GW-02:rescue_patrol']and expanded.pacingWaivers['GW-02:rescue_patrol'],'active old downstream activity receives its pacing waiver')
check(expandedPartial.heroes.hero.expeditions.active.journal.activities['GW-02:exp_2']==1,'active checkpoint retains its partial expanded activity')
check(M.journal(expandedPartial.heroes.hero,'Hard').main==0 and not M.journal(expandedPartial.heroes.hero,'Hard').flags['GW-02:rescue_patrol'],'old expanded Easy progress is not inherited by Hard')
expandedPartial=reload(expandedPartial,'partial pre-patrol expanded story')
print('CAMPAIGN_MODE_MIGRATION '..checks..' checks passed')
