-- Isolated PlaceId 0 fixture. No DataStore or production scripts.
assert(game.PlaceId==0)
local RS=game.ReplicatedStorage
local remotes=Instance.new('Folder');remotes.Name='Remotes';remotes.Parent=RS
for _,name in ipairs({'HeroProgressionRequest','InventoryRequest','InventoryState','K0HeroState'}) do local e=Instance.new('RemoteEvent');e.Name=name;e.Parent=remotes end
local g=require(RS.Shared.HeroProgression).new(20)
local snapshot={ready=true,atHub=true,canInvest=true,heroId='qa',revision=1,items={},stats={power=7,health=30,armor=2},heroes={qa={heroId='qa',baseClassId='knight',progression=g}}}
remotes.InventoryRequest.OnServerEvent:Connect(function(p) remotes.InventoryState:FireClient(p,snapshot) end)
remotes.HeroProgressionRequest.OnServerEvent:Connect(function(p,cmd)
 if cmd.action=='AllocateStats' then for k,v in pairs(cmd.stats) do g.stats[k]+=v end;snapshot.revision+=1 end
 remotes.InventoryState:FireClient(p,snapshot,cmd.requestId)
end)
