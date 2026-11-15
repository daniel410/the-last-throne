-- Run from the repository root. Pure supported account APIs; no source changes.
local function module(n)return dofile('src/shared/'..n..'.luau')end
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C,P,A,M,I,G,Access,Scene,Text,Log=module('CampaignContent'),module('DeepwoodProgress'),module('AdventureRules'),module('CampaignModeProgress'),module('ItemCatalog'),module('HeroProgression'),module('CampaignAccess'),module('CampaignSceneState'),module('LobbyQuestText'),module('DeepwoodQuestLog')
local p=assert(R.addHero(R.new(991),'hero','knight',I));p.heroes.hero.level=99;p.heroes.hero.progression=G.new(99)
p=assert(A.begin(p,'hero','DW-01','Easy','consumer-easy',p.revision,R,I))
local c=C.byId['DW-01']
for _,g in ipairs(c.goals)do if P.required(A.projection(p.heroes.hero),g)then for _,s in ipairs(g.activity and g.activity.steps or {false})do
 p=assert(A.event(p,'hero',c.id,g.id,s and s.choices and(s.solution or s.choices[1].id)or g.choice and 'shared',s and s.id or nil,R,I,'consumer-easy'))
end end end
p=assert(A.begin(p,'hero','DW-01','Hard','consumer-hard',p.revision,R,I))
assert(R.validate(p,I));local h=p.heroes.hero;local actual=M.journal(h,'Hard')
-- This is the exact pure local status function called by LobbyQuestJournal.render.
local file=assert(io.open('src/client/LobbyQuestJournal.luau'));local source=file:read('*a');file:close()
local statusSource=assert(source:match(' local function status%(s,c%)(.-)\n local function render'))
local status=assert(load('return function(s,c)'..statusSource,'@LobbyQuestJournal.status','t',{Text=Text,Content=C,Progress=P,Log=Log}))()
print('ACCOUNT valid=true activeMode='..h.expeditions.active.difficultyId)
print('QUEST actual lobby status='..status(h.deepwood,c)..' mode-specific status='..status(actual,c))
print('ATLAS raw DW-02 open='..tostring(Access.allowed(h.deepwood,'DW-02'))..' Hard DW-02 open='..tostring(Access.allowed(actual,'DW-02')))
print('SCENE raw supplies stage='..Scene.count(h.deepwood,'DW-01:supplies','DW-01')..' Hard supplies stage='..Scene.count(actual,'DW-01:supplies','DW-01'))
