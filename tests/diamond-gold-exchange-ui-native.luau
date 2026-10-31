assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Items=require(game.ReplicatedStorage.Shared.ItemCatalog)
local Rules=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local p=Rules.addHero(Rules.new(51),'h','knight',Items)
local gui=Instance.new('ScreenGui');gui.Name='GoldExchangeQA';gui.Parent=game.CoreGui
local report={kind='DIAMOND_GOLD_UI_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local ok,err=xpcall(function()
 local sent=0;local view=require(client.ArmoryView).create(gui,function()sent+=1 end,true)
 local snapshot={ready=true,heroId='h',heroes=p.heroes,items={},wallet={gold=50,diamonds=9},revision=p.revision}
 view.render(snapshot);local offer=view.panel.Offers:FindFirstChild('rpg_gold_100_diamond')
 check(offer and offer:FindFirstChild('Name').Text=='100 Gold','Gold product appears in Diamond Shop')
 check(offer.Details.Text:find('RPG account wallet',1,true)~=nil,'persistent RPG wallet destination is stated')
 check(not offer.Trade.Active and offer.Trade.Caption.Text=='Need 1 more Diamonds','insufficient Diamonds disabled and explained')
 check(offer.Details.Text:find('Price: 10 Diamonds',1,true)~=nil,'original price remains visible')
 check(view.panel.Categories:FindFirstChild('Category_Gold')~=nil,'Gold category is available')
 view.selectCategory('Gold');check(view.panel.Offers:FindFirstChild('rpg_gold_100_diamond') and not view.panel.Offers:FindFirstChild('knight_weapon_veteran_diamond'),'Gold filter excludes equipment')
 snapshot.wallet.diamonds=10;view.render(snapshot);offer=view.panel.Offers.rpg_gold_100_diamond
 check(offer.Trade.Active and offer.Trade.Caption.Text=='BUY · 10 Diamonds','exact balance enables purchase')
 check(sent==0,'rendering and filtering never performs a trade')
end,debug.traceback)
gui:Destroy();if not ok then table.insert(report.failures,tostring(err))end;report.pass=ok;return report
