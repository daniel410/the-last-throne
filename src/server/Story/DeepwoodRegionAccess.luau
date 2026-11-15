local Access=require(game:GetService('ReplicatedStorage').Shared.CampaignAccess)
local Content=require(game:GetService('ReplicatedStorage').Shared.CampaignContent)
local Bounds=require(game:GetService('ReplicatedStorage').Shared.CampaignBounds)
local Gate={}
function Gate.create(o)
 local safe,lastNotice,lastReveal,regions={},{},{},{}
 local function fallback(player,hero,s)
  local run=o.inventory.expedition(player,hero.heroId)
  local chapter=run and Content.byId[s.expeditionMission or run.missionId]or Content.mainChapters[math.min(Content.mainCount,s.main+1)]
  return o.world.spawns[chapter.zone]
 end
 local function standingHeight(character,root,human)
  local leg=human.RigType==Enum.HumanoidRigType.R6 and character:FindFirstChild('Left Leg')
  return human.HipHeight+root.Size.Y/2+(leg and leg.Size.Y or 0)
 end
 local function returnPivot(player,hero,s)
  local saved=safe[player]
  if saved and saved.heroId==hero.heroId and saved.character==player.Character then
   local p=saved.position;local supported,floor=Bounds.supported(p.X,p.Y,p.Z)
   if supported and p.Y>=floor+saved.height-.3 and Access.allowed(s,Access.region(p.X,p.Z))then return saved.pivot end
  end
  safe[player]=nil
  return fallback(player,hero,s).CFrame+Vector3.new(0,4,0)
 end
 local function clearRegion(player)
  if regions[player] then regions[player]=nil;if o.regionChanged then o.regionChanged(player,nil) end end
 end
 return {update=function(player)
  local hero=o.heroSession.getActiveHero(player)
  if not hero or hero.training or player:GetAttribute('K0SessionPhase')~='Tutorial' then safe[player]=nil;clearRegion(player);return end
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
  local s=o.inventory.storyState(player,hero.heroId)
  if not root or not human or human.Health<=0 or not s then clearRegion(player);return end
  local pos=root.Position
  local supported,floor=Bounds.supported(pos.X,pos.Y,pos.Z)
  local height=standingHeight(player.Character,root,human)
  -- A root can still be above the mathematical floor while its legs are buried.
  supported=supported and pos.Y>=floor+height-.75
  local id=Access.region(root.Position.X,root.Position.Z)
  if not supported or not o.world.spawns[id]then
   if regions[player] then regions[player].candidate=nil end
   local pivot=returnPivot(player,hero,s)
   o.combat.relocateForStoryGate(player,pivot)
   if o.boundaryNotice and os.clock()-(lastNotice[player] or -math.huge)>3 then lastNotice[player]=os.clock();o.boundaryNotice(player) end
   return
  end
  if Access.allowed(s,id) then
   local entry=regions[player]
   if not entry or entry.heroId~=hero.heroId or entry.character~=player.Character then
    clearRegion(player);entry={heroId=hero.heroId,character=player.Character};regions[player]=entry
   end
   if entry.current==id then entry.candidate=nil
   elseif entry.candidate~=id then entry.candidate=id;entry.since=os.clock()
   elseif os.clock()-entry.since>=.6 then
    entry.current=id;entry.candidate=nil;if o.regionChanged then o.regionChanged(player,id) end
   end
   if pos.Y>=floor+height-.3 and pos.Y<=floor+height+.8 then
    safe[player]={heroId=hero.heroId,character=player.Character,pivot=player.Character:GetPivot(),position=pos,height=height}
   end
   local x,z=Access.cell(id,root.Position.X,root.Position.Z)
   if o.inventory.reveal and os.clock()-(lastReveal[player] or -math.huge)>2 then lastReveal[player]=os.clock();o.inventory.reveal(player,hero.heroId,id,x,z) end
  else
   if regions[player] then regions[player].candidate=nil end
   local pivot=returnPivot(player,hero,s)
   o.combat.relocateForStoryGate(player,pivot)
   if os.clock()-(lastNotice[player] or -math.huge)>3 then lastNotice[player]=os.clock();o.notice(player,Content.zones[id].requiresMain,Content.zones[id].name) end
  end
 end,remove=function(player) safe[player]=nil;lastNotice[player]=nil;lastReveal[player]=nil;clearRegion(player) end}
end
return Gate
