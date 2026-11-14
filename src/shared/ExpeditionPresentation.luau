-- Server-authored entry summaries. These projections grant no gameplay rights.
local function load(name)return game and require(script.Parent[name])or dofile('src/shared/'..name..'.luau')end
local D,Content,Summary=load('Difficulty'),load('CampaignContent'),load('EncounterSummary')
local Economy=load('EconomyCatalog')
local GrowthBudget=load('CampaignGrowthBudget')
local P={}
function P.missions(hero,players)
 local list={}
 for _,c in ipairs(Content.chapters)do
  local modes={};local combat=D.combat(c)
  for _,mode in ipairs(D.order)do
   local m=D.modes[mode];local ok,why=D.allowed(hero,c.id,mode)
   local cycle=GrowthBudget.cycle(hero,mode)
   local reward=D.completion(c,mode,D.version,cycle)
   local firstXP=GrowthBudget.questXP(c.id,mode,D.version,cycle)or c.reward.xp
   modes[mode]={allowed=ok,reason=why,level=D.requiredLevel(c,mode),previous=m.previous,
    storyMain=D.requiredMain(c),firstClear=not(hero and hero.deepwood and hero.deepwood.clears[c.id]),
    storyDiamonds=Economy.storyDiamondIds[c.id]and Economy.storyDiamondsByMode[mode] or 0,firstXP=firstXP,firstGold=c.reward.coins,firstOre=c.reward.ore or 0,firstGems=c.reward.gems or 0,repeatXP=reward.xp,repeatGold=reward.gold,
    xpCapped=hero and hero.level>=99 or false,ore=reward.ore,cores=reward.cores,gems=reward.gems,stones=reward.stones,rewardLevel=reward.rewardLevel,rewardBand=reward.rewardBand,cache=reward.cache,encounter=Summary.mission(c,mode,players,D.version,cycle),campaignCycle=cycle,
    hp=m.hp,damage=m.damage,bossHP=m.bossHP,bossDamage=m.bossDamage}
  end
  local epic=Content.epics[c.epic or 1]
  table.insert(list,{id=c.id,title=c.quest and c.quest.title or c.title,region=epic and epic.region or 'Deepwood',
   objective=c.goals[1]and c.goals[1].title or '',combat=combat,modes=modes})
 end
 return list
end
function P.party(party,resolve)
 if not party then return nil end
 local view={id=party.id,hostId=party.hostId,target=party.target,status=party.status,missionId=party.missionId,difficultyId=party.difficultyId,members={}}
 local all=party.status=='forming';local n=0
 for _,m in pairs(party.members)do
  n=n+1;local hero=resolve(m);local ok,why=false,'GatherParty'
  if m.arrived and hero then ok,why=D.allowed(hero,party.missionId,party.difficultyId)end
  local required=Content.byId[party.missionId];local mode=D.modes[party.difficultyId]
  local row={userId=m.userId,name=m.name,classId=m.classId,level=hero and hero.level or m.level,main=m.main,ready=m.ready,arrived=m.arrived,
   eligible=ok,reason=why,requiredLevel=required and mode and D.requiredLevel(required,party.difficultyId)or 1,
   previous=D.modes[party.difficultyId]and D.modes[party.difficultyId].previous,storyMain=required and D.requiredMain(required)or 0}
  -- Ready refers to this exact roster snapshot, not a different selected hero.
  if hero and(hero.level~=m.level or(hero.deepwood and hero.deepwood.main or 0)~=m.main)then row.ready=false end
  if not row.eligible or not row.ready or not row.arrived then all=false end
  table.insert(view.members,row)
 end
 table.sort(view.members,function(a,b)return a.userId<b.userId end)
 view.launchAllowed=all and n==party.target
 return view
end
return P
