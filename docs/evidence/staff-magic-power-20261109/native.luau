assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local RS=game.ReplicatedStorage
local client=game.StarterPlayer.StarterPlayerScripts.Client
local P=require(RS.Shared.SkillStatPreview)
local G=require(RS.Shared.HeroProgression)
local C=require(RS.Shared.ItemCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local n=0
local function check(v,m)n+=1;assert(v,m)end
for _,name in ipairs({'InventoryGui','ArmoryView','CombatStatsView','MobileHeroStatsView'}) do check(type(require(client[name]))=='table','load '..name) end
local g=G.new(1)
check(P.powerGuide('mage'):find('STR does not raise',1,true),'mage STR explanation')
check(P.powerGuide('mage'):find('+3 per point',1,true),'mage MP explanation')
check(P.investmentText('mage',g,{}, {STR=0,DEX=0,INT=1,VIT=0}):find('HOW ATTACK POWER WORKS',1,true),'guide in investment preview')
local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
local panel=Instance.new('Frame');panel.Size=UDim2.fromOffset(1100,700);panel.Parent=gui
task.wait(.1)
local profile=assert(R.addHero(R.new(81),'h','mage',C));local items={};for _,v in pairs(profile.items) do table.insert(items,v)end
local snapshot={ready=true,heroId='h',heroes=profile.heroes,items=items,wallet=profile.wallet,revision=profile.revision,stats=R.stats(profile,'h',C)}
local view=require(client.ArmoryView).create(gui,function()end,'blacksmith')
view.render(snapshot);view.panel.Visible=true;task.wait(.1)
local count=0
for _,card in ipairs(view.panel.Offers:GetChildren())do
 if card:IsA('GuiObject') and card:FindFirstChild('Details') and card.Details.Text:find('Magic Power',1,true)then
  count+=1
  check(card.Details.Text:find('Boosts basic attacks and magic skills.',1,true),'staff skill explanation')
  check(card.Size.Y.Offset>184,'staff description has expanded space')
 end
end
check(count>0,'staff cards rendered')
local height=require(client.CombatStatsView).render(panel,profile.heroes.h,snapshot,{STR=0,DEX=0,INT=0,VIT=0},UDim2.new(),400,{},function()end)
check(panel:FindFirstChild('PowerGuide',true)~=nil,'combat guide rendered')
check(height>0,'measured combat content')
gui:Destroy()
print('STAFF_UI_CHECK '..n..' checks PASS')
