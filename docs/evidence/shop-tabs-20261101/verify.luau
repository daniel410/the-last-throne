local pg=game.Players.LocalPlayer:WaitForChild('PlayerGui')
local client=game.Players.LocalPlayer.PlayerScripts:WaitForChild('Client')
local View=require(client.ArmoryView)
local gui=Instance.new('ScreenGui');gui.Name='ShopLayoutQA';gui.IgnoreGuiInset=true;gui.DisplayOrder=100;gui.Parent=pg
local host=Instance.new('Frame');host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(1280,720);host.Parent=gui
local checks=0;local report={}
local function check(v,m)assert(v,m);checks+=1 end
for _,size in ipairs({Vector2.new(1280,720),Vector2.new(750,323),Vector2.new(1280,720)})do
 host.Size=UDim2.fromOffset(size.X,size.Y)
 for _,store in ipairs({'items','blacksmith'})do
  local view=View.create(host,function()end,false,store);local p=view.panel;p.Visible=true
  view.render({ready=false,wallet={gold=0,diamonds=0},items={}})
  task.wait(.15)
  local buy,sell=p.BuyTab,p.SellTab
  local order=store=='items' and {'Potions','Accessories','Etc'} or {'Weapons','Armor','Accessories'}
  local last=-math.huge
  for _,id in ipairs(order)do local b=p.Categories['Category_'..id];check(b.AbsolutePosition.X>last,'left-to-right '..id);last=b.AbsolutePosition.X;check(b.AbsolutePosition.Y==p.Categories.AbsolutePosition.Y,'one row') end
  check(p.Offers.AbsolutePosition.Y>=p.Categories.AbsolutePosition.Y+p.Categories.AbsoluteSize.Y,'offers below categories')
  check(buy.AbsolutePosition.Y==sell.AbsolutePosition.Y,'buy sell same row')
  check(buy.AbsolutePosition.X+buy.AbsoluteSize.X<sell.AbsolutePosition.X,'no button overlap')
  if size.Y==720 then
   local middle=(buy.AbsolutePosition.X+sell.AbsolutePosition.X+sell.AbsoluteSize.X)/2
   check(math.abs(middle-(p.AbsolutePosition.X+p.AbsoluteSize.X/2))<1,'centered pair')
   check(buy.AbsolutePosition.Y>=p.Balance.AbsolutePosition.Y+p.Balance.AbsoluteSize.Y,'wallet separate row')
  end
  check(p.Title.Text==(store=='items' and 'POTION SHOP' or 'BLACKSMITH'),'correct title')
  table.insert(report,{store=store,host=tostring(size),panel=tostring(p.AbsoluteSize),buy=tostring(buy.AbsolutePosition),sell=tostring(sell.AbsolutePosition),order=order})
  p:Destroy()
 end
end
gui:Destroy()
return {checks=checks,result='passed',measurements=report}
