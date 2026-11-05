local config=assert(loadfile('src/shared/ExpeditionConfig.luau'))()
local env=setmetatable({script={Parent={WaitForChild=function()return config end}},require=function(value)return value end},{__index=_G})
local Role=assert(loadfile('src/shared/PlaceRole.luau','t',env))()
local checks=0
local function check(value) checks=checks+1;assert(value)end
for _,studio in ipairs({false,true}) do
 check(Role.resolve(config.lobbyPlaceId,studio,'Battle')=='Lobby')
 check(Role.resolve(config.battlePlaceId,studio,'Lobby')=='Battle')
end
check(Role.resolve(0,true)== 'Lobby')
check(Role.resolve(0,true,'Battle')== 'Battle')
check(Role.resolve(123,true,'Lobby')== 'Lobby')
check(not pcall(Role.resolve,0,false,'Battle'))
check(not pcall(Role.resolve,103116209434833,false,'Lobby'))
check(not pcall(Role.resolve,123,true,'Invalid'))
print('place-role: '..checks..' checks PASS')
