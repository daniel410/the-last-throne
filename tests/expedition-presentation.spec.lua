local P=dofile('src/shared/ExpeditionPresentation.luau')
local A=dofile('src/shared/AdventureRules.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local G=dofile('src/shared/HeroProgression.luau')
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local profile=assert(R.addHero(R.new(42),'h','knight',C));local hero=profile.heroes.h
local missions=P.missions(hero);local first=missions[1]
check(first.id=='DW-01'and #first.title>0 and #first.region>0 and #first.objective>0,'named mission with objective and region')
check(first.modes.Easy.allowed and first.modes.Easy.level==1,'Easy Lv1 visible')
check(first.modes.Hard.allowed and first.modes.Hard.previous==nil and first.modes.Hard.level==0,'Hard unlocked without Easy clear')
check(first.modes.Insane.reason=='PreviousDifficulty'and first.modes.Insane.level==0,'Insane has no level floor')
check(first.modes.Easy.firstXP==140 and first.modes.Easy.firstGold==150,'first story reward remains canonical')
check(first.modes.Easy.repeatGold==36 and first.modes.Easy.gems==6 and first.modes.Easy.stones==1,'repeat and forge summary match run rules')
hero.level=80;hero.progression=G.new(80)
hero.expeditions={version=1,clears={['DW-01']={Easy=true,Hard=true,Insane=true}},cacheProgress={}}
local hell=P.missions(hero)[1].modes.Hell
check(hell.allowed and hell.repeatGold==314 and hell.stones==10 and hell.gems==28 and hell.cache==4 and hell.xpCapped,'Hell repeat values and cap')
local party={id='party',hostId=42,target=2,status='forming',missionId='DW-01',difficultyId='Hell',members={['42']={userId=42,heroId='h',name='Knight',classId='knight',main=0,level=80,arrived=true,ready=true},['43']={userId=43,heroId='h2',name='Mage',classId='mage',main=0,level=1,arrived=true,ready=true}}}
local other=R.copy(hero);other.level=1;other.progression=G.new(1)
local function view()return P.party(party,function(m)return m.userId==42 and hero or other end)end
local v=view();check(v.launchAllowed and v.members[2].eligible and v.members[2].requiredLevel==0,'level one member can join Hell with prior clear')
other.level=80;other.progression=G.new(80);party.members['43'].level=80;other.expeditions.clears={}
v=view();check(not v.launchAllowed and v.members[2].reason=='PreviousDifficulty'and v.members[2].previous=='Insane','previous difficulty reason')
other.expeditions=R.copy(hero.expeditions);party.members['43'].ready=false
v=view();check(not v.launchAllowed and v.members[2].eligible and not v.members[2].ready,'eligible but unready still blocks launch')
party.members['43'].ready=true;v=view();check(v.launchAllowed,'all eligible arrived ready heroes may launch')
party.members['43'].arrived=false;v=view();check(not v.launchAllowed and v.members[2].reason=='GatherParty','travelling member blocks launch')
party.members['43'].arrived=true;v=P.party(party,function()return nil end);check(not v.launchAllowed and not v.members[1].eligible,'unavailable account fails closed')
other.level=79;v=view();check(not v.launchAllowed and not v.members[2].ready,'stale roster level cannot reuse Ready')
party.target=3;other.level=80;v=view();check(not v.launchAllowed,'partial roster blocks launch')
party.target=2;party.status='launching';v=view();check(not v.launchAllowed,'launching state blocks another departure')
for _,row in ipairs(v.members)do check(row.token==nil and row.heroId==nil and row.ticket==nil,'party projection omits server capabilities')end
for _,mode in ipairs({'Hard','Insane','Hell'})do
 party.status='forming';party.difficultyId=mode;party.target=4
 for uid=44,45 do party.members[tostring(uid)]={userId=uid,name='Ally',classId='knight',main=0,level=80,arrived=true,ready=true}end
 for _,m in pairs(party.members)do m.level=80 end
 hero.level=80;hero.progression=G.new(80)
 other.level=1;other.progression=G.new(1);party.members['43'].level=1
 local row=P.party(party,function(m)return m.userId==43 and other or hero end)
 check(row.launchAllowed and row.members[2].requiredLevel==0,'four-player '..mode..' permits level one member')
 other.expeditions.clears={}
 row=P.party(party,function(m)return m.userId==43 and other or hero end)
 check(mode=='Hard' and row.launchAllowed or mode~='Hard' and not row.launchAllowed and row.members[2].reason=='PreviousDifficulty','four-player Hard unlocked; upper modes retain prior clear '..mode)
 other.expeditions=R.copy(hero.expeditions)
end
print('Expedition presentation: '..n..' checks passed')
