assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local RS=game.ReplicatedStorage
local client=game.StarterPlayer.StarterPlayerScripts.Client
local I=require(RS.Shared.ItemCatalog);local C=require(RS.Shared.EconomyCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local report={kind='BLACKSMITH_NATIVE',checks=0,failures={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='BlacksmithQA';gui.Parent=game.CoreGui
local sign=Instance.new('Part');sign.Anchored=true;sign.Size=Vector3.new(20,3,.5);sign.Parent=workspace
local ok,err=xpcall(function()
 local view=require(client.ArmoryView).create(gui,function()end,false,'blacksmith')
 local p=R.addHero(R.new(81),'h','knight',I);local items={};for _,v in pairs(p.items)do table.insert(items,v)end
 view.render({ready=true,heroId='h',heroes=p.heroes,items=items,wallet=p.wallet,revision=p.revision});view.panel.Visible=true
 check(not view.panel.Categories:FindFirstChild('Category_All'),'blacksmith must not show All')
 check(view.panel.Categories.Category_Weapons.Caption.Text:find('[X]',1,true)~=nil,'Weapons selected initially')
 view.selectCategory('All')
 check(view.panel.Categories.Category_Weapons.Caption.Text:find('[X]',1,true)~=nil,'All cannot be selected through the public API')
 check(view.panel.BuyTab.Size.Y.Offset==44 and view.panel.SellTab.Size.Y.Offset==44,'trade tabs retain touch height')
 check(view.panel.BuyTab.Position.Y.Offset<view.panel.Categories.Position.Y.Offset and view.panel.SellTab.Position.Y.Offset<view.panel.Categories.Position.Y.Offset,'trade tabs above categories')
 for _,cat in ipairs({'Weapons','Armor','Accessories'})do
  check(view.panel.Categories:FindFirstChild('Category_'..cat)~=nil,'category button '..cat)
  view.selectCategory(cat)
  local count=0
  for _,card in ipairs(view.panel.Offers:GetChildren())do if card:IsA('GuiObject')then
   count+=1;check(C.category(I.items[card.Name])==cat,'correct category stock')
   check(card.Trade.Caption.Text:find('Gold',1,true)~=nil,'Gold price before confirmation')
  end end
  check(count==({Weapons=12,Armor=11,Accessories=5})[cat],'exact category count')
 end
 check(not view.panel.Categories:FindFirstChild('Category_Potions'),'no potions in forge')
 view.selectCategory('Accessories');check(view.panel.Offers.guardian_charm.Details.Text:find('HP +100',1,true)~=nil,'health bonus visible on accessories')
 local spec=require(RS.Shared.LobbyFacilities).defense
 require(game.ServerScriptService.Server.World.LobbyArchitecture).sign(sign,spec)
 local art=sign.FacilitySign.DestinationIcon
 check(art.Image=='rbxthumb://type=GameIcon&id=10770905829&w=150&h=150','actual TD experience icon')
 check(art.ScaleType==Enum.ScaleType.Fit and art.UIAspectRatioConstraint.AspectRatio==1,'square icon preserves aspect')
 check(sign.FacilitySign.Title.Position.X.Scale>=art.Position.X.Scale+art.Size.X.Scale,'text does not overlap icon')
 check(sign.FacilitySign.Title.Text=='THRONE DEFENSE','destination label remains English')
 local fetched={}
 game:GetService('ContentProvider'):PreloadAsync({art},function(id,status)table.insert(fetched,{id=id,status=tostring(status)})end)
 report.iconFetch=fetched;report.iconLoaded=art.IsLoaded
end,debug.traceback)
gui:Destroy();sign:Destroy()
if not ok then table.insert(report.failures,tostring(err))end
report.pass=ok
return report
