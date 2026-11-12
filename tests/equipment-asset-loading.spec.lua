-- Run production loading code with controlled client fetch/frame signals.
local checks = 0
local function check(value, message) checks=checks+1;assert(value,message) end
local function signal()
 local handlers={}
 return {Connect=function(_,fn) handlers[#handlers+1]=fn end,fire=function(_,value) for _,fn in ipairs(handlers) do fn(value) end end}
end
local world={DescendantAdded=signal(),DescendantRemoving=signal()}
local function mesh(name, modifier, attrs, parent)
 local p={Name=name,TextureID="base",Parent=parent or world,LocalTransparencyModifier=modifier,attrs=attrs or {},children={}}
 function p:IsA(kind) return kind=='MeshPart' end
 function p:GetAttribute(key) return self.attrs[key] end
 function p:IsDescendantOf() return self.Parent~=nil end
 function p:GetChildren() return self.children end
 function p:GetFullName() return self.Name end
 return p
end
local weapon=mesh('Axe',0,{TLTPlayerWeaponPart=true})
local shield=mesh('Shield',.4,{TLTPlayerShieldPart=true})
local armor=mesh('Hat',0,{}, {Parent=world,GetAttribute=function(_,key)return key=='TLTArmorAppearance' end})
local scenery=mesh('Scenery',0)
local surface=setmetatable({ColorMapContent={Uri='color'},NormalMapContent={Uri='normal'},MetalnessMapContent={},RoughnessMapContent={Uri='rough'},IsA=function(_,kind)return kind=='SurfaceAppearance' end},{__index=function(_,key)
 error("The current thread cannot read '"..key.."' (lacking capability Plugin)")
end})
weapon.children={surface}
function world:GetDescendants() return {weapon,shield,armor,scenery} end
local jobs,fetches,warnings={},{},{}
local run={PreSimulation=signal()}
function run:BindToRenderStep(_,_,fn) self.render=fn end
local provider={}
function provider:PreloadAsync(inputs, callback)
 fetches[#fetches+1]={inputs=inputs,callback=callback,thread=coroutine.running()}
 coroutine.yield()
end
local services={ContentProvider=provider,RunService=run}
local env=setmetatable({workspace=world,game={GetService=function(_,key)return services[key] end},
 Enum={AssetFetchStatus={Success='Success'},RenderPriority={Last={Value=2000}}},
 Instance={new=function(kind) check(kind=='Decal','image representation uses Decal');return {Destroy=function(self)self.destroyed=true end}end},
 task={spawn=function(fn)local co=coroutine.create(fn);jobs[#jobs+1]=co;assert(coroutine.resume(co))end,wait=function()coroutine.yield('retry')end},
 warn=function(message) warnings[#warnings+1]=message end},{__index=_G})
local assets=assert(loadfile('src/client/EquipmentAssetLoading.luau','t',env))()
assets.start();assets.start()
check(#fetches==3,'start once, only weapon/shield/armor fetched')
check(#fetches[1].inputs==5,'base texture and explicit nonempty PBR maps requested as Decals')
run.render()
check(weapon.LocalTransparencyModifier==1 and armor.LocalTransparencyModifier==1,'pending textured meshes concealed')
check(scenery.LocalTransparencyModifier==0,'scenery unaffected')
run.PreSimulation:fire()
check(shield.LocalTransparencyModifier==.4,'existing local mask restored before presentation')
-- Geometry succeeding alone must not reveal a pending color texture.
fetches[1].callback('mesh','Success');run.render()
check(weapon.LocalTransparencyModifier==1,'geometry callback alone does not reveal equipment')
fetches[1].callback('texture','Success');assert(coroutine.resume(fetches[1].thread))
check(fetches[1].inputs[2].Texture=='base' and fetches[1].inputs[2].destroyed,'texture proxy cleaned after preload')
run.PreSimulation:fire();weapon.LocalTransparencyModifier=.7;run.render()
check(weapon.LocalTransparencyModifier==.7,'ready equipment preserves current animation mask')
-- A streaming removal cancels the old request; its late result cannot unmask re-entry.
world.DescendantRemoving:fire(shield)
check(shield.LocalTransparencyModifier==.4,'stream-out restores original mask')
world.DescendantAdded:fire(shield)
fetches[2].callback('mesh','Success');assert(coroutine.resume(fetches[2].thread));run.render()
check(shield.LocalTransparencyModifier==1,'stale completion cannot reveal new request')
local retry=fetches[3]
for attempt=1,3 do
 retry.callback('texture','Failure');assert(coroutine.resume(retry.thread))
 if attempt<3 then assert(coroutine.resume(retry.thread));retry=fetches[#fetches] end
end
run.PreSimulation:fire();run.render()
check(armor.LocalTransparencyModifier==0 and #warnings==1,'fetch errors retry then release without permanently hiding armor')
check(#fetches==6,'three bounded attempts plus replacement request')
print('equipment-asset-loading: '..checks..' checks PASS')
