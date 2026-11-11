local records={{id="traveler_hood",class="elf",image="rbxassetid://137143080594284"},{id="tempered_hood",class="elf",image="rbxassetid://136521016636025"},{id="veteran_hood",class="elf",image="rbxassetid://78839767508875"},{id="sentinel_tier_hood",class="elf",image="rbxassetid://124750950652536"},{id="traveler_hood",class="knight",image="rbxassetid://125595002040947"},{id="tempered_hood",class="knight",image="rbxassetid://112839896045392"},{id="veteran_hood",class="knight",image="rbxassetid://120982310537665"},{id="sentinel_tier_hood",class="knight",image="rbxassetid://113162779090205"},{id="traveler_hood",class="dwarf",image="rbxassetid://127194582387627"},{id="tempered_hood",class="dwarf",image="rbxassetid://127235271476835"},{id="veteran_hood",class="dwarf",image="rbxassetid://81653443053106"},{id="sentinel_tier_hood",class="dwarf",image="rbxassetid://72777564842196"},{id="traveler_coat",class="elf",image="rbxassetid://80123332938356"},{id="tempered_coat",class="elf",image="rbxassetid://115845822837350"},{id="veteran_coat",class="elf",image="rbxassetid://120310393125164"},{id="sentinel_tier_coat",class="elf",image="rbxassetid://109445230940840"},{id="mage_traveler_coat",class="elf",image="rbxassetid://72185586709543"},{id="mage_tempered_coat",class="elf",image="rbxassetid://75921701620464"},{id="mage_veteran_coat",class="elf",image="rbxassetid://122133651584398"},{id="mage_sentinel_coat",class="elf",image="rbxassetid://106184216220128"},{id="traveler_gloves",class="elf",image="rbxassetid://86281658367231"},{id="tempered_gloves",class="elf",image="rbxassetid://111017676569197"},{id="veteran_gloves",class="elf",image="rbxassetid://132142681367766"},{id="sentinel_tier_gloves",class="elf",image="rbxassetid://140226481680174"},{id="traveler_boots",class="elf",image="rbxassetid://79263733706048"},{id="tempered_boots",class="elf",image="rbxassetid://116315919920509"},{id="veteran_boots",class="elf",image="rbxassetid://125948019718210"},{id="sentinel_tier_boots",class="elf",image="rbxassetid://135156716155826"},{id="knight_shield",class="elf",image="rbxassetid://92819976181635"},{id="knight_shield_fine",class="elf",image="rbxassetid://103003941741748"},{id="veteran_tier_shield",class="elf",image="rbxassetid://86204008047513"},{id="sentinel_tier_shield",class="elf",image="rbxassetid://89490344153714"}}
for _,row in ipairs({{id="mage_traveler_hat",class="mage",image="rbxassetid://125014855680211"},{id="mage_tempered_hat",class="mage",image="rbxassetid://98802336961905"},{id="mage_veteran_hat",class="mage",image="rbxassetid://90018150356432"},{id="mage_sentinel_hat",class="mage",image="rbxassetid://129983894503161"}})do table.insert(records,row)end
assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated local place only')
local client=game.StarterPlayer.StarterPlayerScripts.Client
local RS=game.ReplicatedStorage
local C=require(RS.Shared.ItemCatalog)
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local Growth=require(RS.Shared.HeroProgression)
local Sprites=require(client.ItemSprites)
local report={kind='FOUR_FAMILY_ARMOR_NATIVE',checks=0,loads={},surfaces={}}
local function check(v,m)report.checks+=1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Name='ArmorIconQA';gui.Parent=game.CoreGui
local preload={}
for _,r in ipairs(records)do
 local image=Sprites.create(gui,C.items[r.id],UDim2.new(),UDim2.fromOffset(64,64),r.class)
 check(image.Image==r.image,'record mapping '..r.id..r.class)
 check(image.ScaleType==Enum.ScaleType.Fit and image.ImageRectSize==Vector2.zero,'standalone whole image')
 table.insert(preload,image)
end
local expectedLoads={};for _,r in ipairs(records)do expectedLoads[r.image]=true end
local ok,err=xpcall(function()
 game:GetService('ContentProvider'):PreloadAsync(preload,function(id,status)report.loads[id]=status.Name end)
 for id in pairs(expectedLoads)do check(report.loads[id]=='Success','load '..id..' '..tostring(report.loads[id]))end
 local heads={'traveler_hood','tempered_hood','veteran_hood','sentinel_tier_hood'}
 local function expected(id,class)local a=require(RS.Shared.ItemSpriteAtlas);return a.classImages[id]and a.classImages[id][class]or a.images[id]end
 local function assertHead(parent,id,class,label)
  local count=0;for _,node in ipairs(parent:GetDescendants())do if node:IsA('ImageLabel')and node:GetAttribute('DefinitionId')==id then check(node.Image==expected(id,class),label..' '..id..' '..class);count+=1 end end
  check(count>0,label..' image exists '..id);return count
 end
 local armory=require(client.ArmoryView).create(gui,function()end,false,'blacksmith')
 local facade=Instance.new('Folder');facade.Name='ArmorQAFacade';facade:SetAttribute('K0SessionPhase','Lobby');facade.Parent=workspace
 local module=client.InventoryGui:Clone();module.Name='ArmorInventoryQA'
 local source=module.Source:gsub('local Players = game:GetService%("Players"%)',[[local Players={LocalPlayer={WaitForChild=function()return script.Facade.Value end,GetAttribute=function(_,k)return script.Facade.Value:GetAttribute(k)end,SetAttribute=function(_,k,v)script.Facade.Value:SetAttribute(k,v)end,GetAttributeChangedSignal=function(_,k)return script.Facade.Value:GetAttributeChangedSignal(k)end}}]])
 source=source:gsub('local ContextActionService = game:GetService%("ContextActionService"%)','local ContextActionService={BindActionAtPriority=function()end,UnbindAction=function()end}')
 source=source:gsub('local width,height=shell.AbsoluteSize.X,shell.AbsoluteSize.Y','local width,height=1100,700')
 local start=assert(source:find('\n\ttask.spawn(function()',1,true));local last=assert(source:find('\n\tresize()\n\treturn {',start,true));source=source:sub(1,start-1)..source:sub(last)
 source=source:gsub('\n\treturn {\n\t\topen=',[[
 return {
 qaSet=function(value,tab,id,storage) snapshot=value;sourceTab=tab;selectedId=id;storageMode=storage;opened=true;gearMode=false;mobileDetail=true;resize();render()end,
 open=]])
 module.Source=source;local ref=Instance.new('ObjectValue');ref.Name='Facade';ref.Value=facade;ref.Parent=module;module.Parent=client
 local inventory=require(module).create(function()end,function()end)
 for _,class in ipairs({'knight','dwarf','elf','mage'})do
  local heads=class=='mage' and {'mage_traveler_hat','mage_tempered_hat','mage_veteran_hat','mage_sentinel_hat'}or heads
  local profile=assert(R.addHero(R.new(5),class,class,C));local hero=profile.heroes[class]
  hero.progression.level=20
  local items={};local seq=0
  for _,id in ipairs(heads)do seq+=1;table.insert(items,{instanceId='qa'..seq,definitionId=id,quantity=1,version=1,location={kind='bag',heroId=class}})end
  table.insert(items,{instanceId='equipped',definitionId=heads[1],quantity=1,version=1,location={kind='equipped',heroId=class,slot='head'}})
  local snapshot={ready=true,heroId=class,heroes=profile.heroes,items=items,revision=1,bagCapacity=60,storageCapacity=120,safe=true,atHub=true,atStorage=true,pending=0,bagUsed=4,storageUsed=0,wallet={gold=100000,diamonds=10000},stats={}}
  armory.render(snapshot);armory.selectCategory('Armor')
  for i=2,4 do assertHead(armory.panel,heads[i],class,'blacksmith')end
  armory.setMode('Enhance');for _,id in ipairs(heads)do assertHead(armory.panel.Offers,id,class,'enhancement')end;armory.setMode('Buy')
  for i,id in ipairs(heads)do inventory.qaSet(snapshot,'bag','qa'..i,false);assertHead(facade.InventoryGui,id,class,'bag/list/detail/gear')end
  -- Storage uses the selected hero; pending uses the item's owner.
  items[1].location={kind='storage'};snapshot.storageUsed=1;inventory.qaSet(snapshot,'storage','qa1',true);assertHead(facade.InventoryGui,heads[1],class,'storage')
  items[1].location={kind='pending',heroId=class};snapshot.pending=1;inventory.qaSet(snapshot,'pending','qa1',false);assertHead(facade.InventoryGui,heads[1],class,'pending')
  for _,viewName in ipairs({'HeroStatsView','MobileHeroStatsView'})do
   local body=Instance.new('ScrollingFrame');body.Size=UDim2.fromOffset(900,700);body.Parent=gui
   require(client[viewName]).render(body,hero,snapshot,Growth.derived(class,hero.progression,{}),{STR=0,DEX=0,INT=0,VIT=0},false,function()end,function()end,function()end,function()end,{mobile=true,section='Gear'})
   assertHead(body,heads[1],class,viewName);body:Destroy()
  end
  if class=='knight' then
   local other=assert(R.addHero(R.new(5),'otherMage','mage',C));snapshot.heroes.otherMage=other.heroes.otherMage
   items[1].location={kind='pending',heroId='otherMage'};items[5].definitionId='tempered_hood'
   inventory.qaSet(snapshot,'pending','qa1',false)
   assertHead(facade.InventoryGui,heads[1],'mage','pending owner differs from active Knight')
  end
  report.surfaces[class]='blacksmith/enhancement/bag/detail/equipped/storage/pending/desktop-gear/mobile-gear'
 end
 for _,id in ipairs(heads)do check(Sprites.resolveImage(C.items[id])==expected(id,'elf'),'unknown class default hood')end
 inventory.close();module:Destroy();facade:Destroy();armory.panel:Destroy()
end,debug.traceback)
gui:Destroy();report.ok=ok;report.error=err
print('ARMOR_QA_JSON '..game:GetService('HttpService'):JSONEncode(report))
assert(ok,err)
