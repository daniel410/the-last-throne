-- Local visual guidance follows the authored region bridges; never moves the hero.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local Navigation={}
local function vector(p) return Vector3.new(table.unpack(p)) end
local function flat(p) return Vector3.new(p.X,0,p.Z) end
local edges={}
for i=1,6 do table.insert(edges,{string.format('DW-%02d',i),string.format('DW-%02d',i+1)}) end
for _,edge in ipairs({{'DW-03','DW-S1'},{'DW-03','DW-S2'},{'DW-05','DW-S3'}}) do table.insert(edges,edge) end
local function nearest(p)
 local best,distance
 for id,z in pairs(Content.zones) do local d=(flat(p)-flat(vector(z.center))).Magnitude
  if not distance or d<distance then best=id;distance=d end
 end
 return best
end
local function chain(a,b)
 local queue={a};local previous={[a]=false};local index=1
 while queue[index] do
  local id=queue[index];index+=1;if id==b then break end
  for _,edge in ipairs(edges) do
   local nextId=edge[1]==id and edge[2] or edge[2]==id and edge[1]
   if nextId and previous[nextId]==nil then previous[nextId]=id;table.insert(queue,nextId) end
  end
 end
 local result={b};local id=b
 while previous[id] do id=previous[id];table.insert(result,1,id) end
 return result
end
function Navigation.route(origin,destination)
 local a,b=nearest(origin),nearest(destination)
 local points={origin}
 if a~=b then
  -- While on a bridge, continue toward the endpoint leading to the destination.
  local bridgeEnd,bestDistance
  for _,edge in ipairs(edges) do
   local first,second=vector(Content.zones[edge[1]].center),vector(Content.zones[edge[2]].center)
   local delta=flat(second-first);local t=flat(origin-first):Dot(delta)/delta:Dot(delta)
   if t>0 and t<1 then
    local projected=first:Lerp(second,t);local distance=(origin-projected).Magnitude
    if distance<15 and (not bestDistance or distance<bestDistance) then
     bestDistance=distance
     bridgeEnd=#chain(edge[1],b)<#chain(edge[2],b) and edge[1] or edge[2]
    end
   end
  end
  for _,id in ipairs(chain(bridgeEnd or a,b)) do table.insert(points,vector(Content.zones[id].center)) end
 end
 table.insert(points,destination)
 return points
end
function Navigation.start()
 local player=Players.LocalPlayer
 local folder=Instance.new('Folder');folder.Name='DeepwoodNavigation';folder.Parent=workspace
 local arrows={};local target,route,origin,lastTarget;local elapsed=0;local surfacesDirty=true
 local added=workspace.DescendantAdded:Connect(function(p) if p:IsA('BasePart') and (p.Name=='ForestGround' or p.Name:match('^ConnectedPath_')) then surfacesDirty=true end end)
 local removed=workspace.DescendantRemoving:Connect(function(p) if p:IsA('BasePart') and (p.Name=='ForestGround' or p.Name:match('^ConnectedPath_')) then surfacesDirty=true end end)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
 for i=1,20 do
  local pair={}
  for j=1,2 do
   local p=Instance.new('Part');p.Name='GuideChevron';p.Size=Vector3.new(.18,.09,1.65);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
   p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(255,224,137);p.Transparency=1;p.Parent=folder;pair[j]=p
  end
  arrows[i]=pair
 end
 local function hide() for _,pair in ipairs(arrows) do for _,p in ipairs(pair) do p.Transparency=1 end end end
 local connection=RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<1/30 then return end;elapsed=0
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
  if player:GetAttribute('TLTNavigationEnabled')==false or not target or not root or not human or human.Health<=0 or player:GetAttribute('K0SessionPhase')~='Tutorial' or player:GetAttribute('TLTRoute')=='Training' then hide();return end
  if surfacesDirty or not origin or (root.Position-origin).Magnitude>4 or lastTarget~=target then
   surfacesDirty=false;origin=root.Position;lastTarget=target;route=Navigation.route(origin,target)
   local surfaces={};local field=workspace:FindFirstChild('DeepwoodCampaign');local terrain=field and field:FindFirstChild('TerrainBlockout')
   if terrain then for _,p in ipairs(terrain:GetDescendants()) do if p:IsA('BasePart') and (p.Name=='ForestGround' or p.Name:match('^ConnectedPath_')) then table.insert(surfaces,p) end end end
   params.FilterDescendantsInstances=surfaces
  end
  -- Keep an arrival chevron visible until the active objective changes.
  local arrival=flat(target-root.Position).Magnitude<12
  local phase=(os.clock()*5)%6
  for i,pair in ipairs(arrows) do
   local remaining=5+(i-1)*6+phase;local position,direction
   for j=2,#route do
    local delta=route[j]-route[j-1];local length=delta.Magnitude
    if length>0 and remaining<=length then position=route[j-1]+delta.Unit*remaining;direction=flat(delta).Unit;break end
    remaining-=length
   end
   if arrival and i==1 then
    position=target;direction=flat(target-root.Position)
    direction=direction.Magnitude>.1 and direction.Unit or Vector3.new(0,0,-1)
   end
   local hit=position and workspace:Raycast(position+Vector3.new(0,7,0),Vector3.new(0,-16,0),params)
   if hit and direction and direction.Magnitude>.1 then
    local cf=CFrame.lookAt(hit.Position+Vector3.new(0,.14,0),hit.Position+Vector3.new(0,.14,0)+direction)
    for j,p in ipairs(pair) do local sign=j==1 and -1 or 1
     p.CFrame=cf*CFrame.new(sign*.48,0,.48)*CFrame.Angles(0,sign*math.pi/4,0);p.Transparency=.15+.5*(i/20)
    end
   else for _,p in ipairs(pair) do p.Transparency=1 end end
  end
 end)
 return {setTarget=function(value) target=value;if not value then hide() end end,destroy=function() connection:Disconnect();added:Disconnect();removed:Disconnect();folder:Destroy() end}
end
return Navigation
