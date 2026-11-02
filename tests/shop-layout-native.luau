-- Real GUI geometry; fixture snapshots never submit purchases.
local client=game.Players.LocalPlayer.PlayerScripts.Client
local View=require(client.ArmoryView)
local report={kind='SHOP_LAYOUT_NATIVE',checks=0,cases={}}
local function check(ok,message) report.checks+=1;assert(ok,message) end
local gui=Instance.new('ScreenGui');gui.Name='ShopLayoutQA';gui.Parent=game.Players.LocalPlayer.PlayerGui
local ok,err=xpcall(function()
 for _,size in ipairs({Vector2.new(1280,720),Vector2.new(844,390),Vector2.new(750,323),Vector2.new(568,320)})do
  local host=Instance.new('Frame');host.Size=UDim2.fromOffset(size.X,size.Y);host.BackgroundTransparency=1;host.Parent=gui
  local sends=0
  local view=View.create(host,function()sends+=1 end,false,'items')
  view.render({ready=true,heroId='qa',heroes={qa={baseClassId='knight',level=1}},items={},wallet={gold=0,diamonds=0},revision=1})
  view.panel.Visible=true;task.wait(.1)
  local panel,scroll=view.panel,view.panel.Offers
  local cards={};for _,v in scroll:GetChildren()do if v:IsA('Frame')then table.insert(cards,v)end end
  table.sort(cards,function(a,b)return a.LayoutOrder<b.LayoutOrder end)
  check(#cards==8,'all eight potions available')
  local columns=panel.AbsoluteSize.X>=640 and 2 or 1
  check(scroll.UIGridLayout.FillDirectionMaxCells==columns,'appropriate column count')
  check(math.abs(panel.AbsolutePosition.Y+panel.AbsoluteSize.Y-scroll.AbsolutePosition.Y-scroll.AbsoluteSize.Y-16)<1,'list reaches bottom inset')
  check(not view.notice.Visible,'empty notice reserves no footer')
  if columns==2 then check(math.abs(cards[1].AbsolutePosition.Y-cards[2].AbsolutePosition.Y)<1 and cards[2].AbsolutePosition.X>cards[1].AbsolutePosition.X,'first pair side by side')end
  for _,card in cards do
   check(card.Details.TextFits,'description fits '..card.Name)
   check(card.Name~='' and card:FindFirstChild('Name').TextFits,'name fits '..card.Name)
   check(card.Trade.AbsolutePosition.Y>=card.Details.AbsolutePosition.Y+card.Details.AbsoluteSize.Y,'button below description')
   check(not card.Trade.Active,'unaffordable purchase disabled')
  end
  local fullHeight=scroll.AbsoluteSize.Y
  view.notice.Text='CONFIRM: Extra Large Health Potion for 200 Gold. Press the same button again to complete the trade.';task.wait(.1)
  check(view.notice.Visible and view.notice.TextFits,'confirmation visible and fits')
  check(scroll.AbsoluteSize.Y<fullHeight,'confirmation gets measured space')
  view.notice.Text='';task.wait(.1)
  check(math.abs(scroll.AbsoluteSize.Y-fullHeight)<1,'space restored after message clears')
  scroll.CanvasPosition=Vector2.new(0,scroll.AbsoluteCanvasSize.Y);task.wait(.1)
  local last=cards[#cards].Trade
  check(last.AbsolutePosition.Y+last.AbsoluteSize.Y<=scroll.AbsolutePosition.Y+scroll.AbsoluteSize.Y+1,'last purchase reachable')
  check(sends==0,'layout never submits trade')
  table.insert(report.cases,{viewport=tostring(size),panel=tostring(panel.AbsoluteSize),list=tostring(scroll.AbsoluteSize),columns=columns,layout=panel:GetAttribute('ShopLayout')})
  host:Destroy()
 end
end,debug.traceback)
gui:Destroy();report.pass=ok;report.error=not ok and err or nil;return report
