"""Freeze current test logic and the unmodified InventoryService.shop body for isolated QA."""
from pathlib import Path
import hashlib
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def native(source):
    def replace(match):
        path=match[1]
        root='game.ReplicatedStorage.Shared.' if path.startswith('src/shared/') else 'game.ServerScriptService.Server.Inventory.'
        return 'require('+root+Path(path).stem+')'
    return re.sub(r"dofile\(['\"](src/[^'\"]+)['\"]\)",replace,source)

parts=["assert(game.PlaceId==0 and #game.Players:GetPlayers()==0,'isolated QA only')"]
for name in ['enhancement-probability','enhancement-current-equipment']:
    parts.append('do\n'+native((ROOT/('tests/'+name+'.spec.lua')).read_text())+'\nend')

source=(ROOT/'src/server/Inventory/InventoryService.luau').read_text()
body=source.split('function Service.shop(player,command)',1)[1].split('-- Server-only durable run binding.',1)[0]
body='function Service.shop(player,command)'+body
prefix=r'''
do
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local Rules=R
local Catalog=require(game.ReplicatedStorage.Shared.ItemCatalog)
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local F=require(game.ReplicatedStorage.Shared.EquipmentTransactions)
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local Service={refreshCharacter=function()end}
local player={UserId=42,GetAttribute=function()return 'Lobby'end}
local workspace={GetAttribute=function()return 'Lobby'end}
local options={heroSession={getInventoryContext=function()return {heroId='hero',atHub=true}end,refresh=function()end}}
local draws=0;local nextRoll=9999
local Random={new=function()return {NextInteger=function(_,low,high)check(low==0 and high==9999,'server draw uses inclusive 0..9999');draws=draws+1;return nextRoll end}end}
local function publish()end
local saved=assert(R.addHero(R.new(42),'hero','knight',Catalog));saved.wallet.gold=1000
assert(F.grant(saved,R,Catalog,'hero','enhancement_gem',500,'gems'))
assert(F.grant(saved,R,Catalog,'hero','magic_stone',500,'stones'))
local item=assert(R.equipped(saved,'hero','weapon'));local id=item.instanceId;item.enhancementLevel=1
local state={profile=R.copy(saved),valid=true};local accounts={[player]=state}
local lose=true;local callbacks=0
local store={transact=function(_,_,fn)
 callbacks=callbacks+2
 local a,err=fn(R.copy(saved));if not a then return nil,err end
 local b=assert(fn(R.copy(saved)))
 check(a.wallet.gold==b.wallet.gold and a.items[id].enhancementLevel==b.items[id].enhancementLevel,'repeated save callbacks use identical outcome')
 saved=b
 if lose then return nil,'SaveUnknown'end
 return R.copy(saved)
end}
'''
suffix=r'''
local command={action='Enhance',store='blacksmith',requestId='service-failure',heroId='hero',instanceId=id,itemVersion=item.version,revision=saved.revision,rulesVersion=E.version,expectedLevel=1,enhancementRoll=0}
local err=Service.shop(player,command)
check(err=='SaveUnknown'and draws==1 and callbacks==2,'save response loss preserves one server draw')
check(saved.wallet.gold==950 and saved.items[id].enhancementLevel==1,'failed enhancement charged once and level kept')
check(state.shopPending and state.shopPending.enhancementRoll==9999,'pending keeps original roll, ignores command roll')
local other=R.copy(command);other.requestId='other'
local otherError=Service.shop(player,other)
check(otherError=='SaveUnknown','unconfirmed account cannot accept a new attempt')
local conflict=R.copy(command);conflict.expectedLevel=2
check(Service.shop(player,conflict)=='RequestConflict','pending request cannot change target level')
lose=false;nextRoll=0
local outcome;err,outcome=Service.shop(player,command)
check(err==nil and outcome.success==false and outcome.roll==9999,'retry cannot turn saved failure into success')
check(draws==1 and saved.wallet.gold==950 and saved.items[id].enhancementLevel==1,'retry neither redraws nor spends')
check(state.valid and not state.shopPending,'acknowledged retry clears pending')
err,outcome=Service.shop(player,command)
check(err==nil and outcome.success==false and saved.wallet.gold==950,'acknowledged duplicate returns original receipt')
local second={action='Enhance',store='blacksmith',requestId='service-success',heroId='hero',instanceId=id,itemVersion=saved.items[id].version,revision=saved.revision,rulesVersion=E.version,expectedLevel=1}
err,outcome=Service.shop(player,second)
check(err==nil and outcome.success and saved.items[id].enhancementLevel==2 and saved.wallet.gold==900,'fresh request gets a fresh server draw')
check(R.validate(saved,Catalog),'mock service account remains valid')
print('InventoryService.shop extracted-body QA: '..n..' checks passed; no real account or DataStore')
end
'''
parts.append(prefix+body+suffix)
parts.append(r'''
do
local E=require(game.ReplicatedStorage.Shared.Enhancement)
local rng=Random.new(20261110)
local chances={100,90,80,70,60,50,40,30,20}
local trials=100000
for target,percent in ipairs(chances)do
 local successes=0
 for _=1,trials do if E.succeeds(target,rng:NextInteger(0,9999))then successes=successes+1 end end
 local p=percent/100;local sigma=math.sqrt(trials*p*(1-p))
 assert(math.abs(successes-trials*p)<=math.max(1,6*sigma),'random sample outside 6-sigma band')
 print(string.format('RNG +%d: %d/%d = %.3f%% (configured %d%%)',target,successes,trials,successes/trials*100,percent))
end
print('Roblox Random sample: 900000 draws PASS; fixed QA seed 20261110')
end
do
local RS=game.ReplicatedStorage
local R=require(game.ServerScriptService.Server.Inventory.InventoryRules)
local C=require(RS.Shared.ItemCatalog)
local F=require(RS.Shared.EquipmentTransactions)
local client=game.StarterPlayer.StarterPlayerScripts.Client
local n=0;local function check(v,m)n=n+1;assert(v,m)end
local gui=Instance.new('ScreenGui');gui.Parent=game.CoreGui
local panel=Instance.new('Frame');panel.Size=UDim2.fromOffset(800,700);panel.Parent=gui
local guide=require(client.EnhancementGuide).create(panel)
guide.scroll.Size=UDim2.fromOffset(760,650);guide.scroll.Visible=true;task.wait(.1);guide.resize()
check(guide.scroll.Introduction.Body.Text:find('Max MP',1,true)and guide.scroll.Introduction.Body.Text:find('DEX',1,true),'guide includes MP and DEX')
local scroll=Instance.new('ScrollingFrame');scroll.Size=UDim2.fromOffset(800,700);scroll.Parent=gui
local notice=Instance.new('TextLabel');notice.Parent=gui
local p=assert(R.addHero(R.new(42),'hero','mage',C));p.wallet.gold=10000
assert(F.grant(p,R,C,'hero','enhancement_gem',500,'gems'));assert(F.grant(p,R,C,'hero','magic_stone',500,'stones'))
local item=assert(R.equipped(p,'hero','weapon'))
local forge=require(client.EnhancementView)
for target,percent in ipairs({100,90,80,70,60,50,40,30,20})do
 item.enhancementLevel=target-1
 local items={};for _,v in pairs(p.items)do items[#items+1]=v end
 for _,child in ipairs(scroll:GetChildren())do child:Destroy()end
 forge.render(scroll,{ready=true,heroId='hero',heroes=p.heroes,items=items,wallet=p.wallet,revision=p.revision},function()end,false,notice)
 local card=scroll:FindFirstChild(item.instanceId)
 check(card.Description.Text:find(string.format('Success: %d%% / Failure: %d%%',percent,100-percent),1,true),'forge chance matches server '..target)
 check(guide.scroll['Stage'..target].Body.Text:find(string.format('%d%% success / %d%% failure',percent,100-percent),1,true),'guide chance matches server '..target)
end
gui:Destroy()
print('Forge/guide actual UI chance QA: '..n..' checks passed')
end
''')
(HERE/'native.luau').write_text('\n'.join(parts).rstrip()+'\n')
print('Extracted InventoryService.shop SHA256',hashlib.sha256(body.encode()).hexdigest())
