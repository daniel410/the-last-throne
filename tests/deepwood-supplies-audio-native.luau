-- Native GUI/fade lifecycle. Audio fetch is reported independently from state tests.
local RS=game:GetService('ReplicatedStorage');local Run=game:GetService('RunService')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local report={kind='DEEPWOOD_SUPPLIES_AUDIO_NATIVE',checks=0,failures={},audio={},coverage='Native Sound/Tween/GUI and production modules; no physical listening/device or purchase input'}
local function check(v,m)report.checks+=1;assert(v,m)end
local controller,gui
local ok,err=xpcall(function()
 Run:Run();task.wait(2)
 local C=require(RS.Shared.ItemCatalog);local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
 local View=require(client.ArmoryView)
 gui=Instance.new('ScreenGui');gui.Name='SuppliesQA';gui.Parent=game.CoreGui
 local view=View.create(gui,function()end)
 for _,class in ipairs({'knight','elf','dwarf','mage'})do
  local p=R.addHero(R.new(93),class,class,C);local list={};for _,v in pairs(p.items)do table.insert(list,v)end
  local snapshot={ready=true,heroId=class,heroes=p.heroes,items=list,wallet=p.wallet,revision=p.revision}
  view.render(snapshot);view.panel.Visible=true
  local offers=view.panel.Offers
  for _,id in ipairs(C.potions)do
   local card=offers:FindFirstChild(id);check(card~=nil,'every HP/MP size renders for every class')
   check(card.Details.Text:find('Restores up to',1,true)~=nil,'potion card shows restore amount instead of equipment stats')
   check(card.Details.Text:find('In bag:',1,true)~=nil,'potion card shows owned stock')
   check(card.Trade.Caption.Text:find('Gold',1,true)~=nil,'server Gold price is visible before confirmation')
  end
  check(offers:FindFirstChild(class..'_weapon_fine')~=nil,'weapon offers remain alongside supplies')
  for _,category in ipairs(require(RS.Shared.EconomyCatalog).categories)do
   view.selectCategory(category.id)
   local visible=0
   for _,card in ipairs(offers:GetChildren())do if card:IsA('GuiObject') and C.items[card.Name] then visible+=1;check(category.id=='All' or require(RS.Shared.EconomyCatalog).category(C.items[card.Name])==category.id,'buy category excludes unrelated items')end end
   check(visible>0,'every buy category has real purchasable stock')
  end
  view.selectCategory('All')
  local fine=offers:FindFirstChild(class..'_weapon_fine');check(fine.Details.Text:find('On equip:',1,true)~=nil,'shop uses actual attack and max resource delta')
  check(p.heroes[class].quickSlots[2]==(class=='mage' and 'mana_potion' or 'health_potion_medium'),'native starter quick slot matches hero resources')
 end
 local ready=false
 controller=require(client.K0BackgroundMusic).create({isReady=function()return ready end})
 check(controller.normal.SoundId=='rbxassetid://73105938035554' and controller.boss.SoundId=='rbxassetid://120016858360297','native Sounds use exact original TD upload IDs')
 check(controller.normal.Looped and controller.boss.Looped,'both TD tracks loop')
 check(controller.select('DW-07:king_shaman')==controller.normal,'unready boss asset selects normal soundtrack')
 ready=true;check(controller.select('DW-07:king_shaman')==controller.boss,'ready boss asset selects boss soundtrack')
 controller.select(nil);check(controller.select('DW-07:king_shaman')==controller.boss,'rapid transitions cancel/create native tweens without changing selection')
 check(controller.select(nil)==controller.normal,'encounter end selects normal soundtrack')
 report.fadeEnvelope='Native Tween construction/selection verified; temporal gain and listening require Client playback'
 local done=false
 task.spawn(function()
  local cp=game:GetService('ContentProvider')
  report.audio.preload_ok,report.audio.error=pcall(function()cp:PreloadAsync({controller.normal,controller.boss},function(id,status)report.audio[id]=tostring(status)end)end)
  done=true
 end)
 local start=os.clock();repeat task.wait(.1) until done or os.clock()-start>10
 report.audio.finished=done;report.audio.normal_loaded=controller.normal.IsLoaded;report.audio.boss_loaded=controller.boss.IsLoaded
 report.audio.boss_seconds=controller.boss.TimeLength
 report.audio.scope='Local Studio fetch only; actual RPG Experience permission and listening unverified'
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(err))end
if controller then controller.destroy()end;if gui then gui:Destroy()end
if Run:IsRunning()then Run:Stop()end
report.pass=#report.failures==0
print('DEEPWOOD_SUPPLIES_AUDIO_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Supplies/audio native state checks failed')
