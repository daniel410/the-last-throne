-- Lobby companionship is cosmetic. Only the admitted adventure consumes a credit.
local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Visual=require(script.Parent.Parent.World.SeleneVisual)
local Actors=require(script.Parent.Parent.World.NPCActors)
local Follow=require(script.Parent.Parent.Story.SeleneFollow)
local M={}
function M.create(o)
 local api={};local followers={};local nextCheck={};local checking={}
 local function remove(player)
  local f=followers[player];if f then f.model:Destroy();followers[player]=nil end
 end
 function api.remove(player)remove(player);nextCheck[player]=nil end
 function api.update(dt)
  for _,player in ipairs(o.players and o.players() or Players:GetPlayers())do
   local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
   local human=char and char:FindFirstChildOfClass('Humanoid')
   local hero=o.heroSession.getActiveHero(player)
   local valid=player:GetAttribute('K0SessionPhase')=='Lobby' and not player:GetAttribute('TLTTravelLock')
    and hero and root and human and human.Health>0 and char:GetAttribute('K0SpawnReady')==true and o.inventory.available(player)
   local pass=valid and o.inventory.supportState(player,hero.heroId)
   valid=valid and pass and pass.recruited and (pass.credits>0 or pass.trialAvailable)
   if valid and not pass.departure then
    local now=o.clock and o.clock() or os.clock()
    if not checking[player] and now>=(nextCheck[player] or 0) then
     nextCheck[player]=now+2;checking[player]=true
     task.spawn(function()
      local ok,err=pcall(o.inventory.prepareSupport,player,hero.heroId)
      checking[player]=nil
      if not ok then warn('Selene departure preparation failed: '..tostring(err)) end
     end)
    end
   end
   if not valid or not pass.departure then remove(player)
   else
    local f=followers[player]
    if f and (f.heroId~=hero.heroId or f.character~=char)then remove(player);f=nil end
    if not f then
     local model=Visual.create(o.folder,root.Position-root.CFrame.LookVector*8-Vector3.new(0,3,0),'LobbySelene_'..player.UserId)
     model:SetAttribute('OwnerUserId',player.UserId);model:SetAttribute('NPCActorIdentity','npc:selene')
     model:SetAttribute('SeleneLobbyFollower',true);Actors.tag(model,'companion',player.UserId)
     f={model=model,heroId=hero.heroId,character=char};followers[player]=f
    end
    local params=Follow.params(f.model,char,o.folder)
    -- Lobby repositioning cannot bypass combat obstacles or grant support.
    if (f.model.PrimaryPart.Position-root.Position).Magnitude>80 then
     local ground=Follow.ground(root.Position-root.CFrame.LookVector*8,params)
     if ground then f.model:PivotTo(CFrame.new(ground));f.lastOwner=nil;f.waypoints=nil end
    end
    Follow.step(f,root,dt,params,false)
   end
  end
 end
 return api
end
function M.start(o)
 local api=M.create(o)
 Run.Heartbeat:Connect(api.update)
 Players.PlayerRemoving:Connect(api.remove)
 return api
end
return M
