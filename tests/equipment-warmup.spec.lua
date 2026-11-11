local checks=0
local function check(v,m)checks=checks+1;assert(v,m)end
local manifest=assert(loadfile('src/shared/EquipmentPreloadManifest.luau'))()
local visuals=assert(loadfile('src/shared/FourFamilyArmorVisuals.luau'))()
local provider={calls=0,fail=true};local destroyed=0
function provider:PreloadAsync(inputs,callback)
 self.calls=self.calls+1;check(#inputs>0,'known visual has inputs')
 for _,input in ipairs(inputs) do callback(input.MeshId or input.Texture,self.fail and 'Failure' or 'Success') end
end
local env=setmetatable({game={GetService=function(_,name)
 if name=='ContentProvider' then return provider end
 return {Shared={EquipmentPreloadManifest=manifest,FourFamilyArmorVisuals=visuals}}
end},require=function(x)return x end,Enum={AssetFetchStatus={Success='Success'}},
Instance={new=function()return {Destroy=function()destroyed=destroyed+1 end}end},task={wait=function()end}},{__index=_G})
local W=assert(loadfile('src/client/EquipmentWarmup.luau','t',env))()
check(not W.prepare('traveler_coat','elf'),'failed assets block Equip preparation')
check(provider.calls==3 and destroyed>0,'bounded retry and temporary inputs cleaned')
provider.fail=false
check(W.prepare('traveler_coat','elf'),'later success recovers a failed asset')
local before=provider.calls
check(W.prepare('traveler_coat','elf') and provider.calls==before,'successful visual reused before another Equip')
check(W.prepare('traveler_hood','elf'),'headwear also warms matching hair')
check(provider.calls==before+2,'hood and hair downloaded independently')
check(W.prepare('legacy_item','elf'),'legacy visual retains its existing attach path')
print('equipment-warmup: '..checks..' checks PASS')
