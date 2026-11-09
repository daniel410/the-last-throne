-- Synthetic identities, real production refreshEquipment and native Humanoids.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated place only')
local RS=game:GetService('ReplicatedStorage')
local G=require(RS.Shared.HeroProgression)
local source=game.ServerScriptService.Server.Combat.CombatService
local private=Instance.new('ModuleScript');private.Parent=source.Parent
private.Source=source.Source:gsub('\nreturn CombatService%s*$', '\nreturn {refresh=CombatService.refreshEquipment,states=playerStates,resolver=function(fn)contextResolver=fn end}')
local api=require(private)
local n=0
local function check(v,m)n+=1;assert(v,m)end
for _,class in ipairs({'knight','elf','dwarf','mage'})do
 local model=Instance.new('Model');model.Parent=workspace
 local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=model
 local hum=Instance.new('Humanoid');hum.Parent=model;hum.MaxHealth=500;hum.Health=10
 local player={Character=model};local growth=G.new();local base=G.derived(class,growth)
 local state={player=player,character=model,humanoid=hum,root=root,baseClassId=class,growth=growth,derived=base,
  mana=base.mana>0 and 10 or nil,maxMana=base.mana,mode='Idle',skillSlots={1,2,3,0,0},skillReadyAt={},slotCount=3}
 api.states[player]=state
 api.resolver(function()return {heroId='h',baseClassId=class,epoch=1,characterGeneration=1,growth=growth,skillSlots={1,2,3,0,0}}end)
 local equipment={power=0,armor=0,health=0,mana=30,weapon=false,offhand=false}
 api.refresh(player,equipment)
 check(state.maxMana==(base.mana>0 and base.mana+30 or 0),'MP gear increases only an existing pool '..class)
 check(state.mana==(base.mana>0 and 10 or nil),'equipping never restores current MP '..class)
 check(hum.Health==10,'equipping never heals HP '..class)
 check(model:GetAttribute('K0MaxMana')==(base.mana>0 and base.mana+30 or nil),'replicated maximum agrees '..class)
 api.refresh(player,equipment)
 check(state.mana==(base.mana>0 and 10 or nil),'repeated refresh cannot restore MP '..class)
 if base.mana>0 then state.mana=base.mana+25 end
 equipment.mana=0;api.refresh(player,equipment)
 check(state.mana==(base.mana>0 and base.mana or nil),'removing gear clamps current MP '..class)
 check(model:GetAttribute('K0Mana')==state.mana,'replicated current agrees '..class)
 api.states[player]=nil;model:Destroy()
end
private:Destroy()
for _,name in ipairs({'ArmoryView','EnhancementView','InventoryGui','CombatStatsView','MobileHeroStatsView'})do
 check(type(require(game.StarterPlayer.StarterPlayerScripts.Client[name]))=='table','changed UI module loads '..name)
end
print('EQUIPMENT_MANA_NATIVE PASS '..n..' checks; synthetic identities/native production refresh, not live players or device acceptance')
