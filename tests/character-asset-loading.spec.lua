local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local function signal()
 local handlers={};return {Connect=function(_,fn)table.insert(handlers,fn);return {Disconnect=function()end}end,
 fire=function(_,...)for _,fn in ipairs(handlers)do fn(...)end end}
end
local function char(key)
 return {key=key,complete=true,attrs={},DescendantAdded=signal(),DescendantRemoving=signal(),
 GetAttributeChangedSignal=function()return signal()end,SetAttribute=function(self,k,v)self.attrs[k]=v end}
end
local a,b=char('a'),char('b');local player={Character=a,CharacterAdded=signal()}
local fetches,jobs={},{}
local provider={PreloadAsync=function(_,_,callback)
 local co=coroutine.running();table.insert(fetches,{co=co,callback=callback});coroutine.yield('fetch')
end}
local equipment={isReady=function()return true end,preload=function()end}
local shared={FourFamilyArmorVisuals={models={}}}
local env=setmetatable({game={GetService=function(_,name)
 if name=='ContentProvider'then return provider elseif name=='ReplicatedStorage'then return {Shared=shared} else return {}end end},
 script={Parent={EquipmentAssetLoading=equipment,EquipmentWarmup={prepare=function()return true end}}},require=function(x)return x end,
 warn=function()end,Enum={AssetFetchStatus={Success='Success'}},task={spawn=function(fn)local co=coroutine.create(fn);table.insert(jobs,co);assert(coroutine.resume(co))end,wait=function()coroutine.yield('wait')end}},{__index=_G})
local C=assert(loadfile('src/client/CharacterAssetLoading.luau','t',env))()
C.snapshot=function(c)return c.key,c.complete,{}, {},'elf',{}end
C.start(player);check(a.attrs.TLTLocalAppearanceReady==false,'initial character remains covered during fetch')
player.Character=b;player.CharacterAdded:fire(b)
fetches[1].callback('old','Success');assert(coroutine.resume(fetches[1].co))
check(not b.attrs.TLTLocalAppearanceReady,'old character fetch cannot release replacement')
fetches[2].callback('new','Success');assert(coroutine.resume(fetches[2].co))
check(b.attrs.TLTLocalAppearanceReady==true,'complete current character can reveal')
b.DescendantAdded:fire();b.key='new-body'
check(b.attrs.TLTLocalAppearanceReady==false,'new replicated equipment invalidates readiness immediately')
assert(coroutine.resume(jobs[2]));check(#fetches==3,'new wardrobe must preload again')
b.key='newer-body';fetches[3].callback('body','Success');assert(coroutine.resume(fetches[3].co))
check(b.attrs.TLTLocalAppearanceReady==false,'a changed wardrobe cannot use stale completion')
-- Stable permanent failures cannot strand an admitted returning hero forever.
local function resume()assert(coroutine.resume(jobs[2]))end
resume()
for attempt=1,3 do
 local fetch=fetches[#fetches];fetch.callback('legacy-texture','Failure');assert(coroutine.resume(fetch.co))
 if attempt<3 then
  check(not b.attrs.TLTLocalAppearanceReady,'retry remains covered before bounded fallback')
  resume();resume()
 end
end
check(b.attrs.TLTLocalAppearanceReady and b.attrs.TLTLocalAppearanceDegraded,'persistent cosmetic failure releases stable complete character')
check(b.attrs.TLTLocalAppearanceError==nil,'completed fallback clears retry message')
b.complete=false;b.DescendantRemoving:fire();resume()
check(not b.attrs.TLTLocalAppearanceReady,'fallback cannot bypass missing replicated equipment')
b.complete=true;b.key='recovered-body';resume()
local recovery=fetches[#fetches];recovery.callback('fixed-texture','Success');assert(coroutine.resume(recovery.co))
check(b.attrs.TLTLocalAppearanceReady and b.attrs.TLTLocalAppearanceDegraded==nil,'later wardrobe success clears degraded state')
print('character-asset-loading: ' ..checks..' checks PASS')
