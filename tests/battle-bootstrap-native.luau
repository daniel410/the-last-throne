local Run=game:GetService('RunService')
local report={kind='BATTLE_BOOTSTRAP_NATIVE',checks=0,failures={},coverage='Native battle-role startup; no real Player admission or published teleport'}
local function check(v,m) report.checks+=1;assert(v,m) end
local ok,e=xpcall(function()
 check(game.ServerStorage.ServerRole.Value=='Battle','battle artifact selects battle role')
 Run:Run();task.wait(3)
 check(workspace:GetAttribute('TLTServerRole')=='Battle','battle bootstrap active')
 check(not workspace:FindFirstChild('DawnspireLobbyPrototype'),'battle does not construct public lobby')
 check(workspace:FindFirstChild('DeepwoodCampaign')~=nil,'battle builds campaign')
 for _,name in ipairs({'K0HeroRequest','InventoryRequest','ExpeditionRequest','ArmoryRequest','DeepwoodRequest'}) do check(game.ReplicatedStorage.Remotes:FindFirstChild(name)~=nil,name..' initialized') end
 check(require(game.ReplicatedStorage.Shared.ExpeditionConfig).battleCapacity==4,'four authorized participants maximum')
end,debug.traceback)
if not ok then table.insert(report.failures,tostring(e)) end
if Run:IsRunning() then Run:Stop() end
report.pass=#report.failures==0
print('BATTLE_BOOTSTRAP_NATIVE '..game.HttpService:JSONEncode(report));assert(report.pass,'Battle bootstrap failed')
