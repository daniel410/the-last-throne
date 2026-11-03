from pathlib import Path
import json,runpy
ns=runpy.run_path('tools/review-expedition-ui.py');sources=ns['sources']
sources['tests/enhancement-probability.spec.lua']=Path('tests/enhancement-probability.spec.lua').read_text()
code='local sources={\n'+''.join('['+json.dumps(k)+']='+json.dumps(v,ensure_ascii=False)+',\n'for k,v in sources.items())+'}\n'
code+='''
local realGame=game
local pureCache={}
local function pure(path)
 if pureCache[path]then return pureCache[path]end
 local fn=assert(loadstring(assert(sources[path]),'@'..path))
 setfenv(fn,setmetatable({game=false,dofile=pure,print=function()end},{__index=getfenv()}))
 local value=fn();pureCache[path]=value or true;return value
end
pure('tests/enhancement-probability.spec.lua')
'''
code+=ns['code'].split('local originalGame=game')[1].split("local existing=")[0].join(['local originalGame=game',''])
code+='''
assert(game.PlaceId==0,'only temporary local place')
assert(not originalGame.CoreGui:FindFirstChild('TLTEnhancementQA'),'review already exists')
local gui=Instance.new('ScreenGui');gui.Name='TLTEnhancementQA';gui.IgnoreGuiInset=true;gui.DisplayOrder=100000;gui.Parent=originalGame.CoreGui
local root=Instance.new('Frame');root.Size=UDim2.fromOffset(1108,707);root.BackgroundColor3=Color3.fromRGB(8,16,30);root.Parent=gui
local view=req(tree.src.client.ArmoryView).create(root,function()error('UI review must not send trades')end,false,'blacksmith')
local R=pure('src/server/Inventory/InventoryRules.luau');local C=pure('src/shared/ItemCatalog.luau')
-- Exercise the actual InventoryService.shop body: one draw across SaveUnknown.
local serviceBody=assert(sources['src/server/Inventory/InventoryService.luau']:match('(function Service.shop.-)\\n%-%- Server%-only'))
local create=assert(loadstring('return function(accounts,Rules,Catalog,store,options,workspace,publish,Random) local Service={refreshCharacter=function()end} '..serviceBody..' return Service end'))()
local serverProfile=assert(R.addHero(R.new(42),'hero','knight',C));local gear
local F=pure('src/shared/EquipmentTransactions.luau')
F.grant(serverProfile,R,C,'hero','enhancement_gem',20,'service-gems')
for _,v in pairs(serverProfile.items)do if v.definitionId=='knight_weapon_fine'and v.location.kind=='bag'then gear=v end end
gear.enhancementLevel=1
local player={UserId=42,GetAttribute=function()return 'Lobby'end};local accounts={[player]={valid=true,profile=serverProfile}}
local draws,calls=0,0
local fakeStore={transact=function(_,_,fn)
 calls+=1;local first=assert(fn(R.copy(serverProfile)));local second=assert(fn(R.copy(serverProfile)))
 assert(first.operations['service-attempt'].enhancementOutcome.roll==second.operations['service-attempt'].enhancementOutcome.roll,'callback rerolled')
 if calls==1 then return nil,'SaveUnknown'end
 serverProfile=second;return second
end}
local service=create(accounts,R,C,fakeStore,{heroSession={getInventoryContext=function()return {heroId='hero',atHub=true}end,refresh=function()end}}, {GetAttribute=function()return 'Lobby'end},function()end,{new=function()draws+=1;return {NextInteger=function()return 9999 end}end})
local cmd={action='Enhance',store='blacksmith',heroId='hero',instanceId=gear.instanceId,itemVersion=gear.version,revision=serverProfile.revision,requestId='service-attempt',rulesVersion=2,expectedLevel=1}
assert(service.shop(player,cmd)=='SaveUnknown','first service response must stay unknown')
local reason,outcome=service.shop(player,cmd)
assert(not reason and outcome and not outcome.success,'service publishes saved failure')
assert(draws==1 and calls==2,'service drew again after unknown response')
local profile=assert(R.addHero(R.new(42),'hero','knight',C));local items={};for _,v in pairs(profile.items)do table.insert(items,v)end
local state={ready=true,heroId='hero',heroes=profile.heroes,items=items,wallet=profile.wallet,revision=profile.revision}
view.render(state);view.panel.Visible=true
local results={}
for _,size in ipairs({Vector2.new(1108,707),Vector2.new(844,390),Vector2.new(667,375)})do
 root.Size=UDim2.fromOffset(size.X,size.Y);task.wait(.15)
 view.setMode('Guide');task.wait(.15)
 local guide=view.panel.EnhancementGuide
 assert(view.panel.EnhancementHelp.AbsolutePosition.Y+view.panel.EnhancementHelp.AbsoluteSize.Y<=view.panel.EnhanceTab.AbsolutePosition.Y,'help must not overlap tabs')
 assert(view.panel.Close.AbsolutePosition.Y+view.panel.Close.AbsoluteSize.Y<=view.panel.EnhanceTab.AbsolutePosition.Y,'close must not overlap tabs')
 assert(guide.Visible and not view.panel.Offers.Visible,'guide must replace offers')
 assert(guide:FindFirstChild('Stage9').Body.Text:find('20%% success / 80%% failure'),'stage9 rate visible')
 assert(#guide:GetChildren()==15,'9 stages plus 5 sections plus layout')
 local clipped={}
 for _,box in ipairs(guide:GetChildren())do if box:IsA('Frame')then
  assert(box.Body.TextBounds.Y<=box.Body.AbsoluteSize.Y+2,'guide text clipped '..box.Name)
  table.insert(clipped,{name=box.Name,height=box.AbsoluteSize.Y,textHeight=box.Body.TextBounds.Y})
 end end
 table.insert(results,{host={size.X,size.Y},panel={view.panel.AbsoluteSize.X,view.panel.AbsoluteSize.Y},guideHeight=guide.AbsoluteSize.Y,canvasHeight=guide.AbsoluteCanvasSize.Y,sections=clipped})
 view.setMode('Enhance');task.wait(.1)
 assert(not view.panel.Categories.Visible,'no categories in enhance')
 assert(view.panel.Offers.Position.Y.Offset<=110,'hidden category gap removed')
 local found=false
 for _,card in ipairs(view.panel.Offers:GetChildren())do if card:IsA('Frame')and profile.items[card.Name] and C.items[profile.items[card.Name].definitionId].slot then
  found=true;assert(card.Description.Text:find('Success: 100%% / Failure: 0%%'),'stage1 chance from runtime')
  assert(card.Action1.TDButtonArt.ImageRectOffset~=card.Action2.TDButtonArt.ImageRectOffset,'primary enhancement uses different TD button art')
 end end
 assert(found,'enhance item cards exist')
end
root.Size=UDim2.fromOffset(1108,707);view.setMode('Guide');task.wait(.2)
_G.TLTEnhancementQA={gui=gui,root=root,view=view,signal=signal}
return {pass=true,probabilityChecks=2857,layouts=results,scope='temporary CoreGui; no user account, live storage or publishing'}
'''
Path('builds').mkdir(exist_ok=True)
Path('builds/enhancement-native.luau').write_text(code)
print('native bytes',len(code))
