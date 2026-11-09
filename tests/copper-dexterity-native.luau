assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated place only')
local RS=game:GetService('ReplicatedStorage')
local G=require(RS.Shared.HeroProgression);local K=require(RS.Shared.K0Config)
local source=game.ServerScriptService.Server.Combat.CombatService
local private=Instance.new('ModuleScript');private.Parent=source.Parent
private.Source=source.Source:gsub('\nreturn CombatService%s*$', '\nreturn {refresh=CombatService.refreshEquipment,attack=startAttack,states=playerStates,resolver=function(fn)contextResolver=fn end}')
local api=require(private);local n=0
local function near(a,b,m)n+=1;assert(math.abs(a-b)<1e-7,m)end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local model=Instance.new('Model');model.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=model
 local hum=Instance.new('Humanoid');hum.Parent=model;hum.MaxHealth=500;hum.Health=10
 local player={Character=model};local growth=G.new();local base=G.derived(class,growth)
 local state={player=player,character=model,humanoid=hum,root=root,baseClassId=class,growth=growth,derived=base,
  mana=base.mana>0 and 10 or nil,maxMana=base.mana,mode='Idle',skillSlots={1,2,3,0,0},skillReadyAt={},slotCount=3,
  attackProfile=K.BasicAttackProfiles[class],combo=0,lastAttackFinished=-math.huge,attackSeq=0,feedbackSeq=0}
 api.states[player]=state
 api.resolver(function()return {heroId='h',baseClassId=class,epoch=1,characterGeneration=1,growth=growth,skillSlots={1,2,3,0,0}}end)
 local gear={power=0,armor=0,health=0,mana=0,dexterity=3,weapon=false,offhand=false}
 api.refresh(player,gear)
 near(state.derived.totalStats.DEX,base.totalStats.DEX+3,'actual server total DEX')
 near(state.derived.attackRate,1.015,'actual server attack rate');near(hum.WalkSpeed,K.WalkSpeed*1.003,'native Humanoid speed includes ring')
 near(hum.Health,10,'DEX swap does not heal HP')
 if state.mana then near(state.mana,10,'DEX swap does not restore MP')end
 api.attack(state,10)
 near(state.attack.definition.windup,K.BasicAttackProfiles[class].attacks[1].windup/1.015,'actual attack timing uses gear DEX')
 near(model:GetAttribute('K0BasicAttackRate'),1.015,'replicated attack rate includes ring')
 state.attack=nil;state.mode='Idle';gear.dexterity=0;api.refresh(player,gear)
 near(state.derived.attackRate,1,'ring removal restores rate');near(hum.WalkSpeed,K.WalkSpeed,'ring removal restores native speed')
 api.states[player]=nil;model:Destroy()
end
private:Destroy()
for _,name in ipairs({'ArmoryView','EnhancementView','InventoryGui','CombatStatsView','HeroStatsView','MobileHeroStatsView'})do
 assert(type(require(game.StarterPlayer.StarterPlayerScripts.Client[name]))=='table','changed UI loads '..name);n+=1
end
print('COPPER_DEX_NATIVE PASS '..n..' checks; synthetic identities/native timing and Humanoid, no live input or device acceptance')
