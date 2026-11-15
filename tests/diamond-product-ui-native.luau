-- Run with an injected ArmoryView and no real Player; never opens a paid prompt.
return function(Armory)
 local report={checks=0,sizes={}}
 local function check(v,m)report.checks+=1;assert(v,m)end
 local gui=Instance.new('ScreenGui');gui.Name='DiamondProductsQA';gui.Parent=game.CoreGui
 local ok,err=xpcall(function()
  local host=Instance.new('Frame');host.Parent=gui
  local sent=0
  local view=Armory.create(host,function()sent+=1 end,true)
  local snapshot={ready=true,heroes={},items={},wallet={gold=50,diamonds=100},revision=1}
  view.panel.Visible=true
  for _,size in ipairs({Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(390,650)})do
   host.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.15)
   view.render(snapshot);view.selectCategory('Robux');task.wait(.1)
   check(view.panel.Categories:FindFirstChild('Category_Robux')~=nil,'Robux category exists')
   local count=0
   for _,pack in ipairs(require(game.ReplicatedStorage.Shared.DiamondProducts).packs)do
    local card=view.panel.Offers:FindFirstChild('Robux_'..pack.id)
    check(card and card.Name and card:FindFirstChild('Name').Text==pack.name,'correct pack title')
    check(not card.BuyRobux.Active and card.BuyRobux.Caption.Text=='LOCAL TEST','Studio never charges Robux')
    check(card.Details.Text:find('The Last Throne only',1,true)~=nil,'RPG destination stated')
    count+=1
   end
   check(count==3 and not view.panel.Offers:FindFirstChild('rpg_gold_500_diamond'),'Robux filter excludes diamond spending')
   local categories=view.panel.Categories
   check(categories.AbsolutePosition.Y+categories.AbsoluteSize.Y<=view.panel.Offers.AbsolutePosition.Y,'categories do not overlap offers')
   check(view.panel.Offers.AbsoluteSize.Y>60,'scroll area remains usable')
   table.insert(report.sizes,{x=size.X,y=size.Y,scrollHeight=view.panel.Offers.AbsoluteSize.Y})
  end
  view.selectCategory('Gold');check(view.panel.Offers:FindFirstChild('rpg_gold_500_diamond')~=nil,'existing gold offers preserved')
  check(not view.panel.Offers:FindFirstChild('Robux_diamonds_100'),'Gold filter excludes Robux packs')
  check(sent==0,'render and category changes never send a purchase')
 end,debug.traceback)
 gui:Destroy();assert(ok,err);return report
end
