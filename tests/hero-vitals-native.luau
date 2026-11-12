-- Candidate source strings are supplied by tools/prepare-hero-vitals-native.py.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local original=game.ServerScriptService.Server.Combat.CombatService
local first=assert(original.Source:find('local function setupCharacter',1,true))
local last=assert(original.Source:find('local function setupPlayer',first,true))
local source=(original.Source:sub(1,first-1)..CandidateCombatSetup..original.Source:sub(last)):gsub('local Vitals=require%(ReplicatedStorage.Shared.HeroVitals%)',
 function()return 'local Vitals=(function()\n'..CandidateVitalsSource..'\nend)()'end)
source=source:gsub('return CombatService%s*$',[[
function CombatService.qaSetup(player,context)
 activePlayers[player]=true;contextResolver=function()return context end
 setupCharacter(player,player.Character)
end
function CombatService.qaState(player)return playerStates[player]end
return CombatService]])
local api=assert(loadstring('local script=game.ServerScriptService.Server.Combat.CombatService\n'..source))()
local G=require(game.ReplicatedStorage.Shared.HeroProgression)
local checks=0
local function check(v,m)checks+=1;assert(v,m)end
local function spawn(class,vitals,level)
 local c=Instance.new('Model');c.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=c
 local human=Instance.new('Humanoid');human.Parent=c;c:SetAttribute('K0SpawnReady',true)
 local player={Parent=game.Players,Character=c}
 api.qaSetup(player,{heroId='hero-'..class,baseClassId=class,epoch=1,characterGeneration=1,
  growth=G.new(level or 1),vitals=vitals})
 local deadline=os.clock()+3
 while not api.qaState(player) and os.clock()<deadline do task.wait(.05)end
 local state=assert(api.qaState(player),'combat setup finishes')
 check(c:GetAttribute('K0State')=='Idle','production setup completes')
 return player,state,c,human
end
for _,class in ipairs({'mage','knight','dwarf','elf'})do
 local p,s,c,h=spawn(class,{health=31.25,mana=0,level=1})
 check(h.Health==31.25,'production setup preserves HP '..class)
 check((s.mana or 0)==0,'production setup preserves zero MP '..class)
 check(c:GetAttribute('K0Mana')==s.mana,'HUD projection agrees '..class)
 local id,v=api.snapshotVitals(p)
 check(id=='hero-'..class and v.health==31.25 and v.mana==0,'server checkpoint matches actual resources '..class)
 p.Character=nil;check(api.snapshotVitals(p)==nil,'stale life cannot overwrite lobby checkpoint')
 c:Destroy()
end
for _,value in ipairs({{health=0,mana=0,level=1},{health=3,mana=0,level=1}})do
 local p,s,c,h=spawn('mage',value,value.health>0 and 2 or 1)
 check(h.Health==h.MaxHealth and s.mana==s.maxMana,'death or level-up retains full recovery')
 c:Destroy()
end
print('HERO_VITALS_NATIVE PASS '..checks..' checks; native Humanoid and actual production setup; fake Player, no real teleport')
