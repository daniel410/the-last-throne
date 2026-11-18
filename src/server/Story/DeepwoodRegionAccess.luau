local Access=require(game:GetService('ReplicatedStorage').Shared.CampaignAccess)
local Content=require(game:GetService('ReplicatedStorage').Shared.CampaignContent)
local Bounds=require(game:GetService('ReplicatedStorage').Shared.CampaignBounds)
local Gate={}
function Gate.create(o)
 local safe,lastNotice,lastReveal,regions={},{},{},{}
 local function readyAt(id,pos)
  if not o.world.spawns[id]then return false end
  if o.world.loadedEpics and not o.world.loadedEpics[Content.zones[id].epic or 1]then return false end
  -- Mathematical road bounds exist even before its geometry is constructed.
  if o.world.loadedEpics then for _,edge in ipairs(Content.overlandLinks)do
   local a,b=Bounds.ends(edge);local dx,dz=b[1]-a[1],b[3]-a[3]
   local length=dx*dx+dz*dz
   local t=length>0 and ((pos.X-a[1])*dx+(pos.Z-a[3])*dz)/length or -1
   if t>=0 and t<=1 and (pos.X-a[1]-t*dx)^2+(pos.Z-a[3]-t*dz)^2<=Bounds.trailHalfWidth^2 then
    local roads=o.world.folder:FindFirstChild('OverlandRoads')
    local road=roads and roads:FindFirstChild(edge[1]..'_'..edge[2])
    if not road or road:GetAttribute('BuildComplete')~=true then return false end
   end
  end end
  return true
 end
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
   local id=Access.region(p.X,p.Z)
   if supported and p.Y>=floor+saved.height-.3 and Access.allowed(s,id)and readyAt(id,p)then return saved.pivot end
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
  if not supported or not readyAt(id,pos)then
   if regions[player] then regions[player].candidate=nil end
   local pivot=returnPivot(player,hero,s)
   o.combat.relocateForStoryGate(player,pivot)
   if o.boundaryNotice and os.clock()-(lastNotice[player] or -math.huge)>3 then lastNotice[player]=os.clock();o.boundaryNotice(player) end
   return
  end
  if Access.allowed(s,id) then
   -- Admission/spawn stays focused on its destination; prefetch never blocks
   -- this update and only starts from a supported, authorized story region.
   if o.prepareNearby and player:GetAttribute('TLTTravelLock')~=true
    and player.Character:GetAttribute('K0SpawnReady')==true then o.prepareNearby(player,hero,s,pos)end
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
