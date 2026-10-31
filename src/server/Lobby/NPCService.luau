local RS=game:GetService('ReplicatedStorage')
local Catalog=require(RS.Shared.NPCCatalog)
local Access=require(script.Parent.FacilityAccess)
local S={}
function S.start(options)
 local remote=Instance.new('RemoteEvent');remote.Name='NPCDialogue';remote.Parent=RS.Remotes
 local last={}
 for id,entry in pairs(options.residents or {}) do if entry.prompt then
  entry.prompt.Triggered:Connect(function(player)
   if os.clock()-(last[player] or -math.huge)<.6 or not Access.allowed(player,entry.prompt) then return end
   last[player]=os.clock()
   if id=='mira' then
    if options.inventory.ready(player) then RS.Remotes.ArmoryState:FireClient(player,{inventory=options.inventory.snapshot(player),open=true}) end
   else
    local c=Catalog.byId[id];remote:FireClient(player,{id=id,name=c.name,role=c.role,key=c.textKey,text=c.greeting})
   end
  end)
 end end
 game.Players.PlayerRemoving:Connect(function(player) last[player]=nil end)
end
return S
