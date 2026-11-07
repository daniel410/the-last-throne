-- Execute actual dock progress rendering with delayed inventory snapshots.
local f=assert(io.open('src/client/LobbyHeroDock.luau'));local source=f:read('*a');f:close()
local a=assert(source:find('  local hero=inventory',1,true));local b=assert(source:find('  layout(root.AbsoluteSize)',a,true))
local render=assert(load('return function(inventory,state,busy,notice,xp,track,amount,fill,TEXT,NAMES,Growth,UDim2,math)\n'..source:sub(a,b-1)..'end'))()
local checks=0
local function check(v,m) checks=checks+1;assert(v,m) end
local Growth={maxLevel=80,xpToNext=function() return 100 end}
local UDim2={fromScale=function(x,y) return {X=x,Y=y} end}
local mathApi=setmetatable({clamp=function(v,a,b) return math.min(b,math.max(a,v)) end},{__index=math})
local TEXT={waiting='WAIT',level='%s Hero Lv.%d',choose='CHOOSE',loading='LOADING',max='MAX',xp='%d / %d XP'}
local state={selectedHeroId='dwarf',heroes={{heroId='dwarf',classId='dwarf'}}}
local function run(inventory,current)
 local xp={SetAttribute=function()end};local track,amount,fill={},{},{}
 render(inventory,current or state,false,nil,xp,track,amount,fill,TEXT,{dwarf='Dwarf'},Growth,UDim2,mathApi)
 return xp,track,amount,fill
end
for _,inventory in ipairs({{ready=false,heroId='dwarf',heroes={}},
 {ready=false,heroId='dwarf',heroes={dwarf={progression={level=5,xp=25}}}},
 {ready=true,heroId='dwarf',heroes={}},
 {ready=true,heroId='elf',heroes={dwarf={progression={level=5,xp=25}}}}}) do
 local xp,track=run(inventory)
 check(xp.Text=='LOADING' and not track.Visible,'unready or stale snapshot waits without throwing')
end
local xp,track=run(nil);check(xp.Text=='LOADING' and not track.Visible,'missing inventory waits')
local ready={ready=true,heroId='dwarf',heroes={dwarf={progression={level=5,xp=25}}}}
local amount,fill;xp,track,amount,fill=run(ready)
check(xp.Text=='Dwarf Hero Lv.5' and track.Visible,'confirmed growth renders selected hero')
check(amount.Text=='25 / 100 XP' and fill.Size.X==.25,'XP fraction retained')
xp,track=run({ready=false,heroes={}},{heroes={}})
check(xp.Text=='CHOOSE' and not track.Visible,'empty account waits for hero choice')
print('Lobby hero progress: '..checks..' checks PASS')
