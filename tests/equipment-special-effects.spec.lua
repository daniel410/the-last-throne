-- Runs both in plain Lua and in an isolated Roblox Place built from the same source.
local function loadModule(path)
 if not game then return dofile(path)end
 local root,relative
 if path:sub(1,11)=='src/shared/'then root=game.ReplicatedStorage.Shared;relative=path:sub(12)
 else root=game.ServerScriptService.Server.Inventory;relative=path:match('([^/]+)$')end
 return require(root[relative:gsub('%.luau$','')])
end
if game then assert(#game.Players:GetPlayers()==0,'isolated test place only')end
local E=loadModule('src/shared/EquipmentEffects.luau')
local C=loadModule('src/shared/ItemCatalog.luau')
local R=loadModule('src/server/Inventory/InventoryRules.luau')
local P=loadModule('src/shared/SkillStatPreview.luau')
local G=loadModule('src/shared/HeroProgression.luau')
local I=loadModule('src/shared/EquipmentImpact.luau')
local H=loadModule('src/shared/Enhancement.luau')
local Config=loadModule('src/shared/K0Config.luau')
local n=0
local function check(value,message)n=n+1;assert(value,message)end
local function near(a,b)return math.abs(a-b)<1e-8 end
local function effect(id,value,skillId)return {id=id,value=value,skillId=skillId}end
for _,def in pairs(C.items)do check(E.validateDefinition(def),'existing catalog remains valid')end
local cases={
 {effect('physical_damage',.2),1.2,1,1.2,1},
 {effect('magic_damage',.2),1,1.2,1,1.2},
 {effect('basic_damage',.2),1.2,1.2,1,1},
 {effect('skill_damage',.2),1,1,1.2,1.2},
}
for _,row in ipairs(cases)do
 for index,context in ipairs({{false,false},{true,false},{false,true},{true,true}})do
  check(near(E.damageMultiplier({row[1]},context[1],context[2]),row[index+1]),'damage type / basic versus skill scope')
 end
end
check(near(E.damageMultiplier({effect('damage',.1),effect('physical_damage',.2),effect('skill_damage',.3)},false,true),1.6),'bonuses add, never multiply individually')
check(E.damageMultiplier({effect('damage',1),effect('physical_damage',1)},false,true)==2,'combined damage cap')
check(E.incomingMultiplier({effect('damage_reduction',.3),effect('damage_reduction',.3)})==.5,'reduction cap')
check(near(E.incomingMultiplier({effect('damage_reduction',.1)}),.9),'reduction applies to incoming damage only')
local target='knight.common.whirlwind'
check(E.damageMultiplier({effect('skill_damage',.15,target)},false,true,target)==1.15,'targeted skill applies')
check(E.damageMultiplier({effect('skill_damage',.15,target)},false,true,'knight.common.bash')==1,'targeted skill excludes other skills')
for _,bad in ipairs({effect('unknown',.1),effect('damage',-1),effect('damage',0/0),effect('damage',math.huge),effect('damage',1.1),effect('skill_damage',.1,'missing'),effect('damage',.1,target)})do
 check(not E.validateDefinition({slot='weapon',specialEffects={bad}}),'malformed catalog effect rejected')
 check(E.damageMultiplier({bad},false,true)==1,'malformed effect cannot amplify damage')
end
check(not E.validateDefinition({specialEffects={effect('damage',.1)}}),'consumable effects rejected')
check(not E.validateDefinition({slot='weapon',specialEffects={effect('damage',.1),effect('damage',.2)}}),'duplicate item scope rejected')
check(not E.validateDefinition({slot='weapon',specialEffects={[2]=effect('damage',.1)}}),'sparse list rejected')
check(#E.fromDefinition({slot='weapon',deleted=true,specialEffects={effect('damage',1)}})==0,'deleted gear has no effects')
local profile=assert(R.addHero(R.new(88),'hero','knight',C))
local selected=R.equipped(profile,'hero','weapon')
local def=C.items[selected.definitionId];local saved=def.specialEffects
def.specialEffects={effect('skill_damage',.15,target)}
local stats=R.stats(profile,'hero',C)
check(#stats.specialEffects==1,'server collects equipped definition effects')
selected.specialEffects={effect('damage',1)}
check(E.damageMultiplier(R.stats(profile,'hero',C).specialEffects,false,true,'knight.common.bash')==1,'instance effect values are never trusted')
local baseStats={power=stats.power,armor=stats.armor,health=stats.health,mana=stats.mana,dexterity=stats.dexterity}
local growth=profile.heroes.hero.progression
local normal=P.value('knight',2,growth,baseStats)
local boosted=P.value('knight',2,growth,stats)
local power=P.derived('knight',growth,stats).physicalPower
check(boosted.damage==math.floor(power*boosted.skill.damage*1.15+.5)and boosted.damage>normal.damage,'skill preview includes effect before final rounding')
check(P.value('knight',1,growth,stats).damage==P.value('knight',1,growth,baseStats).damage,'other skill unchanged')
check(P.basicAttacks('knight',growth,stats)[1].before==P.basicAttacks('knight',growth,baseStats)[1].before,'skill effect excludes normal attacks')
local upgraded=H.stats(def,{enhancementLevel=9})
check(near(upgraded.power,3.81)and E.fromDefinition(def)[1].value==.15,'enhancement improves base stats, not effects')
check(E.text(def):find('WHIRLWIND damage +15%',1,true)~=nil,'skill-specific English label')
local items={};for _,item in pairs(profile.items)do items[#items+1]=item end
local replacement={definitionId='knight_weapon_fine',location={kind='bag'}}
local rows=assert(I.compare(profile.heroes.hero,items,replacement,nil,C))
check(rows.specialEffects:find('15% -> 0%',1,true)~=nil,'replacement shows lost effect')
check(I.text(rows):find('percentage points',1,true)~=nil,'effect units differ from attack points')
local same=assert(I.compare(profile.heroes.hero,items,selected,nil,C))
check(same.specialEffects:find('15% -> 15%',1,true)~=nil,'equipped preview never doubles effects')
selected.location.kind='bag'
check(#R.stats(profile,'hero',C).specialEffects==0,'bag gear has no effect')
selected.location.kind='storage'
check(#R.stats(profile,'hero',C).specialEffects==0,'storage gear has no effect')
selected.location.kind='equipped';selected.location.heroId='other'
check(#R.stats(profile,'hero',C).specialEffects==0,'other hero gear has no effect')
selected.location.heroId='hero';def.specialEffects=saved
check(#R.stats(profile,'hero',C).specialEffects==0,'removing definition effect leaves no stale bonus')
-- Every class uses the same server multiplier for preview, including branch/ultimate skills.
for _,class in ipairs({'knight','dwarf','elf','mage'})do
 local g=G.new(80);local bonuses={specialEffects={effect('damage',.2)}}
 for index,skill in ipairs(Config.Skills[class])do
  local value=P.value(class,index,g,bonuses)
  local d=P.derived(class,g,bonuses);local attack=skill.magic and d.magicPower or d.physicalPower
  check(value.damage==(value.skill.damage>0 and math.max(1,math.floor(attack*value.skill.damage*1.2+.5))or 0),'all class/branch skill damage matches shared multiplier')
 end
 local a,b=P.basicAttacks(class,g,{}),P.basicAttacks(class,g,bonuses)
 check(b[1].before>=a[1].before,'all class normal attacks support effects')
end
if game then
 local client=game.StarterPlayer.StarterPlayerScripts.Client
 for _,name in ipairs({'InventoryGui','ArmoryView','EnhancementView','HeroStatsView','CombatStatsView','MobileHeroStatsView'})do check(type(require(client[name]))=='table','engine loads '..name)end
 check(type(require(game.ServerScriptService.Server.Combat.CombatService))=='table','engine loads combat service')
 local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
 local scroll=Instance.new('ScrollingFrame');scroll.Size=UDim2.fromOffset(400,700);scroll.Parent=gui
 local notice=Instance.new('TextLabel');notice.Parent=gui
 local snapshot={ready=true,heroId='hero',heroes=profile.heroes,items=items,wallet=profile.wallet,revision=profile.revision}
 def.specialEffects={effect('skill_damage',.15,target)}
 local forge=require(client.EnhancementView)
 for _,width in ipairs({400,900})do
  scroll.Size=UDim2.fromOffset(width,700)
  for _,child in ipairs(scroll:GetChildren())do child:Destroy()end
  task.wait(.1);forge.render(scroll,snapshot,function()end,false,notice);task.wait(.1)
  local card=scroll:FindFirstChild(selected.instanceId)
  check(card and card.Description.Text:find('WHIRLWIND damage +15%',1,true),'forge displays authored special effect')
  check(card.Description.AbsoluteSize.Y>=game:GetService('TextService'):GetTextSize(card.Description.Text,12,card.Description.Font,Vector2.new(card.Description.AbsoluteSize.X,10000)).Y,'forge description fits at width '..width)
 end
 def.specialEffects=saved
 local fine=C.items.knight_weapon_fine;local old=fine.specialEffects;fine.specialEffects={effect('physical_damage',.1)}
 local shop=require(client.ArmoryView).create(gui,function()end,false,'blacksmith')
 shop.render(snapshot);shop.panel.Visible=true;task.wait(.1)
 local found=false
 for _,card in ipairs(shop.panel.Offers:GetChildren())do
  if card:FindFirstChild('Details')and card.Details.Text:find('Physical damage +10%',1,true)then found=true end
 end
 check(found,'shop shows definition effect and comparison')
 fine.specialEffects=old;gui:Destroy()
end
print('Equipment special effects: '..n..' checks passed')
