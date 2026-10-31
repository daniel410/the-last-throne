-- Local straight-line direction guidance; never moves the hero.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Navigation={}
local function flat(p) return Vector3.new(p.X,0,p.Z) end
-- Direction guidance points at the objective; roads and region centers do not alter it.
function Navigation.route(origin,destination)
 return {origin,destination}
end
function Navigation.start()
 local player=Players.LocalPlayer
 local folder=Instance.new('Folder');folder.Name='DeepwoodNavigation';folder.Parent=workspace
 local arrows={};local target;local elapsed=0;local surfacesDirty=true
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
  if surfacesDirty then
   surfacesDirty=false
   local surfaces={};local field=workspace:FindFirstChild('DeepwoodCampaign');local terrain=field and field:FindFirstChild('TerrainBlockout')
   if terrain then for _,p in ipairs(terrain:GetDescendants()) do if p:IsA('BasePart') and (p.Name=='ForestGround' or p.Name:match('^ConnectedPath_')) then table.insert(surfaces,p) end end end
   params.FilterDescendantsInstances=surfaces
  end
  local route=Navigation.route(root.Position,target)
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
