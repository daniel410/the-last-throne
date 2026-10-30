local Access=require(game:GetService('ReplicatedStorage').Shared.DeepwoodAccess)
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local Bounds=require(game:GetService('ReplicatedStorage').Shared.DeepwoodBounds)
local Gate={}
function Gate.create(o)
 local safe,lastNotice,lastReveal={},{},{}
 return {update=function(player)
  local hero=o.heroSession.getActiveHero(player)
  if not hero or hero.training or player:GetAttribute('K0SessionPhase')~='Tutorial' then safe[player]=nil;return end
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
  local s=o.inventory.storyState(player,hero.heroId)
  if not root or not human or human.Health<=0 or not s then return end
  local pos=root.Position
  local supported,floor=Bounds.supported(pos.X,pos.Y,pos.Z)
  if not supported then
   local saved=safe[player]
   local spawn=o.world.spawns[Content.chapters[math.min(7,s.main+1)].zone]
   local pivot=saved and saved.heroId==hero.heroId and saved.character==player.Character and saved.pivot or spawn.CFrame+Vector3.new(0,4,0)
   o.combat.relocateForStoryGate(player,pivot)
   if o.boundaryNotice and os.clock()-(lastNotice[player] or -math.huge)>3 then lastNotice[player]=os.clock();o.boundaryNotice(player) end
   return
  end
  local id=Access.region(root.Position.X,root.Position.Z)
  if Access.allowed(s,id) then
   if pos.Y<=floor+8 then safe[player]={heroId=hero.heroId,character=player.Character,pivot=player.Character:GetPivot()} end
   local x,z=Access.cell(id,root.Position.X,root.Position.Z)
   if o.inventory.reveal and os.clock()-(lastReveal[player] or -math.huge)>2 then lastReveal[player]=os.clock();o.inventory.reveal(player,hero.heroId,id,x,z) end
  else
   local saved=safe[player]
   local spawn=o.world.spawns[Content.chapters[math.min(7,s.main+1)].zone]
   local pivot=saved and saved.heroId==hero.heroId and saved.character==player.Character and saved.pivot or spawn.CFrame+Vector3.new(0,4,0)
   o.combat.relocateForStoryGate(player,pivot)
   if os.clock()-(lastNotice[player] or -math.huge)>3 then lastNotice[player]=os.clock();o.notice(player,Content.zones[id].requiresMain,Content.zones[id].name) end
  end
 end,remove=function(player) safe[player]=nil;lastNotice[player]=nil;lastReveal[player]=nil end}
end
return Gate
