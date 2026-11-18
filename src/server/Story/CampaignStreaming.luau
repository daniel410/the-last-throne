-- Demand-driven preparation; loading geometry never grants story access.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.CampaignContent)
local Access=require(Shared.CampaignAccess)
local Bounds=require(Shared.CampaignBounds)
local Areas=require(Shared.CampaignAreas)
local M={}
function M.create(o)
 local pending,failedAt={},{}
 local previous=setmetatable({},{__mode='k'})
 local function loaded(id)
  return o.world.loadedEpics[Content.zones[id].epic or 1]==true
 end
 local function schedule(target)
  local epic=Content.zones[target].epic or 1
  if loaded(target) or pending[epic] or os.clock()-(failedAt[epic] or -math.huge)<=5 then return end
  pending[epic]=true
  task.spawn(function()
   local ok,err=pcall(o.prepareStory,target)
   if not ok then failedAt[epic]=os.clock();warn('[CampaignLoading] preparation failed: '..tostring(err)) end
   pending[epic]=nil
  end)
 end
 return function(player,hero,journal,position)
  local current=Access.region(position.X,position.Z)
  if not loaded(current) or not Access.allowed(journal,current) then return end
  -- Entering the outgoing story prepares only its immediate neighbour. The
  -- next region may still be locked: geometry preparation grants no access.
  for _,edge in ipairs(Content.overlandLinks)do
   if current==edge[1] and Areas.containsZone(Content.zones[current],position.X,position.Z)then
    schedule(edge[2])
   end
  end
  local last=previous[player]
  if not last or last.character~=player.Character or last.heroId~=hero.heroId then
   previous[player]={character=player.Character,heroId=hero.heroId,position=position};return
  end
  local before=last.position
  local moved=(position.X-before.X)^2+(position.Z-before.Z)^2
  if moved<1 then return end
  last.position=position
  for _,edge in ipairs(Content.overlandLinks)do
   for side=1,2 do
    local source,target=edge[side],edge[3-side]
    local epic=Content.zones[target].epic or 1
    if loaded(source) and not loaded(target) and Access.allowed(journal,source) and Access.allowed(journal,target)
     and not pending[epic] and os.clock()-(failedAt[epic] or -math.huge)>5 then
     local a,b=Bounds.ends(edge);local mouth=side==1 and a or b
     -- Match the existing streaming radius: request before reaching the road.
     local radius=workspace.StreamingTargetRadius
     local distance=(position.X-mouth[1])^2+(position.Z-mouth[3])^2
     local priorDistance=(before.X-mouth[1])^2+(before.Z-mouth[3])^2
     -- Spawning beside an old region must not immediately rebuild it. Wait for
     -- actual approach movement, excluding large checkpoint/respawn jumps.
     if moved<=radius*radius and distance<priorDistance and distance<=radius*radius then
      schedule(target)
     end
    end
   end
  end
 end
end
return M
