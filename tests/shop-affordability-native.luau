-- Real shop rows; only fake snapshots are used and no trade is sent.
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local Items=require(game.ReplicatedStorage.Shared.ItemCatalog)
local Rules=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local p=Rules.addHero(Rules.new(91),'hero','knight',Items)
local report={kind='SHOP_AFFORDABILITY_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='AffordabilityQA';gui.Parent=game.CoreGui
local module=client.ArmoryView:Clone();module.Name='AffordabilityViewQA';module.Parent=client
local sends=0
local ok,err=xpcall(function()
 local View=require(module)
 local stock=View.create(gui,function()sends+=1 end,false,'items')
 local blacksmith=View.create(gui,function()sends+=1 end,false,'blacksmith')
 local diamond=View.create(gui,function()sends+=1 end,true)
 local snapshot={ready=true,heroId='hero',heroes=p.heroes,items={},revision=p.revision,wallet={gold=19,diamonds=9}}
 stock.render(snapshot);blacksmith.render(snapshot);diamond.render(snapshot)
 local potion=stock.panel.Offers.health_potion;local b=potion.Trade
 check(not b.Active and not b.Selectable and b:GetAttribute('InsufficientFunds'),'unaffordable potion is disabled')
 check(b.Caption.Text=='Need 1 more Gold','potion states exact shortfall')
 check(potion.Details.Text:find('Price: 20 Gold',1,true)~=nil,'price remains visible')
 local weapon=blacksmith.panel.Offers.knight_weapon_fine
 check(not weapon.Trade.Active and weapon.Trade.Caption.Text=='Need 231 more Gold','equipment shows its Gold shortfall')
 local premium=diamond.panel.Offers.knight_weapon_veteran_diamond
 check(not premium.Trade.Active and premium.Trade.Caption.Text=='Need 1 more Diamonds','diamond offer uses diamond balance')
 snapshot.wallet.gold=20;snapshot.wallet.diamonds=10
 stock.render(snapshot);diamond.render(snapshot)
 check(stock.panel.Offers.health_potion.Trade.Active and stock.panel.Offers.health_potion.Trade.Selectable,'exact Gold enables purchase')
 check(stock.panel.Offers.health_potion.Trade.Caption.Text=='BUY · 20 Gold','affordable price is restored')
 stock.render(snapshot,nil,true)
 check(not stock.panel.Offers.health_potion.Trade.Active,'trade disabled while a purchase is being confirmed')
 stock.selectCategory('Potions')
 check(not stock.panel.Offers.health_potion.Trade.Active,'changing category cannot clear the pending transaction')
 stock.render(snapshot,nil,false)
 check(stock.panel.Offers.health_potion.Trade.Active,'completed transaction enables another affordable purchase')
 check(diamond.panel.Offers.knight_weapon_veteran_diamond.Trade.Active,'exact Diamond balance enables purchase')
 snapshot.wallet.gold=0;stock.render(snapshot)
 check(not stock.panel.Offers.health_potion.Trade.Active and stock.panel.Offers.health_potion.Trade.Caption.Text=='Need 20 more Gold','lower wallet disables purchase again')
 snapshot.wallet=nil;stock.render(snapshot)
 check(stock.panel.Offers.health_potion.Trade.Caption.Text=='BUY · 20 Gold','unknown balance is not presented as zero')
 check(sends==0,'rendering never submits a trade')
end,debug.traceback)
gui:Destroy();module:Destroy();if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok;return report
