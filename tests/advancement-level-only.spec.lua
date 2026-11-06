-- Level-only eligibility across the actual UI request, account rules and save recovery.
local G=dofile('src/shared/HeroProgression.luau')
local A=dofile('src/shared/AdvancedSkills.luau')
local R=dofile('src/server/Inventory/InventoryRules.luau')
local C=dofile('src/shared/ItemCatalog.luau')
local Store=dofile('src/server/Inventory/AccountStore.luau')
local count=0
local function check(value,message) count=count+1;assert(value,message) end
local viewEnv=setmetatable({game={GetService=function(_,name)
 if name=='ReplicatedStorage' then return {Shared={AdvancedSkills=A,AdvancementText=dofile('src/shared/AdvancementText.luau')}} end
 return {}
end},script={Parent={TDInventoryTheme={},HeroMenuChrome={}}},require=function(module)return module end},{__index=_G})
local source=assert(io.open('src/client/SkillAdvancementView.luau'))
local requestSource=source:read('*a'):match('^(.-)function View.render');source:close()
-- The request path is standard Lua; exclude only the native GUI renderer's Luau syntax.
local View=assert(load(requestSource..'return View','SkillAdvancementView.request','t',viewEnv))()
for classId,paths in pairs(A.order) do
 for _,path in ipairs(paths) do
  local profile=assert(R.addHero(R.new(42),'hero',classId,C))
  for stage=1,4 do
   local g=profile.heroes.hero.progression
   g.level=stage*20-1;profile.heroes.hero.level=g.level
   local cmd={action='Advance',heroId='hero',branch=path,stage=stage,requestId='advance-'..stage,revision=profile.revision}
   local blocked,why=R.progress(profile,cmd,{atHub=false,canInvest=false},C)
   check(blocked==nil and why=='LevelRequired','level boundary still enforced')
   -- Lv22 reproduces the reported first advancement; subsequent stages use exact boundaries.
   g.level=stage==1 and 22 or stage*20;profile.heroes.hero.level=g.level
   check(g.battleWins==0,'fixture never defeats an enemy')
   local hero=profile.heroes.hero
   local snapshot={ready=true,atHub=false,canInvest=false,revision=profile.revision,heroId='hero'}
   local state={path=path};local sent={}
   local function send(action,fields)sent[#sent+1]={action=action,fields=fields}end
   check(not View.request(hero,snapshot,state,send,function()end),'first click reviews in field')
   check(#sent==0,'review never writes')
   check(View.request(hero,snapshot,state,send,function()end),'confirmation sends in field without safety or defeats')
   check(#sent==1 and sent[1].fields.branch==path and sent[1].fields.stage==stage,'exact selected path and next stage')
   local pending={path=path}
   check(not View.request(hero,snapshot,pending,send,function()end,{}),'pending save remains blocked')
   snapshot.ready=false
   check(not View.request(hero,snapshot,pending,send,function()end),'unloaded account remains blocked')
   snapshot.ready=true
   local wrong=G.copy(cmd);wrong.stage=stage+1
   check(not R.progress(profile,wrong,{atHub=false},C),'cannot skip stages')
   if stage>1 then
    wrong=G.copy(cmd);wrong.branch=paths[1]==path and paths[2] or paths[1]
    check(not R.progress(profile,wrong,{atHub=false},C),'saved path cannot change')
   end
   for otherClass,otherPaths in pairs(A.order)do
    if otherClass~=classId then
     wrong=G.copy(cmd);wrong.branch=otherPaths[1]
     check(not R.progress(profile,wrong,{atHub=false},C),'cannot choose another class')
    end
   end
   local stale=G.copy(cmd);stale.revision=profile.revision-1
   local rejected,reason=R.progress(profile,stale,{atHub=false},C)
   check(rejected==nil and reason=='Changed','revision fence remains')
   profile=assert(R.progress(profile,cmd,{atHub=false,canInvest=false},C))
   local saved=profile.heroes.hero.progression
   check(saved.stage==stage and saved.branch==path and saved.battleWins==0,'account saves without defeats')
   check(R.validate(profile,C),'saved account validates on load')
   local replay,_,repeated=R.progress(profile,cmd,{atHub=false},C)
   check(repeated and replay.revision==profile.revision,'receipt replay never advances twice')
  end
 end
end
-- Unknown response after a field advancement must recover once on reconnect.
local data={};local lose=false
local adapter={UpdateAsync=function(_,key,callback)
 local nextValue=callback(G.copy(data[key]));if nextValue then data[key]=G.copy(nextValue)end
 if lose then error('response lost')end
 return G.copy(data[key])
end}
local store=Store.new(adapter,R,C,function()return 1000 end,function()end,'level-only')
assert(store:open(42))
local loaded=assert(store:transact(42,function(p)
 p=assert(R.addHero(p,'hero','mage',C));p.heroes.hero.progression=G.new(22);p.heroes.hero.level=22;return p
end))
local cmd={action='Advance',heroId='hero',branch='pyro',stage=1,requestId='field-save',revision=loaded.revision}
lose=true
local failed,why=store:transact(42,function(p)return R.progress(p,cmd,{atHub=false,canInvest=false},C)end)
check(failed==nil and why=='SaveUnknown','lost response is not success')
lose=false
local recovered=assert(store:transact(42,function(p)return R.progress(p,cmd,{atHub=false,canInvest=false},C)end))
check(recovered.heroes.hero.progression.stage==1,'unknown field save recovers once')
assert(store:close(42))
local rejoined=assert(store:open(42))
check(rejoined.heroes.hero.progression.stage==1 and rejoined.heroes.hero.progression.battleWins==0,'rejoin loads zero-defeat advancement')
print('Level-only advancement: '..count..' checks passed')
