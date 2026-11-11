-- Corridor-aware objective guidance; never moves the hero.
local Players=game:GetService('Players')
local RunService=game:GetService('RunService')
local Settings=require(script.Parent.GameSettings)
local Navigation={}
local function flat(p) return Vector3.new(p.X,0,p.Z) end
local function isSurface(p)
 return p:IsA('BasePart') and (p==workspace.Terrain or p:GetAttribute('ExpansionFloor')==true or p.Name=='JourneyGround' or p.Name=='JourneyPass' or p.Name=='Ground' or p.Name=='WalkableTerrace' or p.Name=='WalkableRamp' or p.Name=='TerraceLanding' or p.Name=='ForestGround' or p.Name=='SnowGround' or p.Name=='BasaltGround'
  or p.Name=='TrailEmbankment' or p.Name:match('^Support_') or p.Name:match('^TrailSupport_')
  or p.Name:match('^LateTrail_') or p.Name:match('^CalderaTrail_') or p.Name:match('^SnowTrail_') or p.Name:match('^ConnectedPath_'))
end
-- Keep local incident ramps and regional return corridors on the authored route.
function Navigation.route(origin,destination)
 local points=require(game.ReplicatedStorage.Shared.CampaignNavigationRoute).route({origin.X,origin.Y,origin.Z},{destination.X,destination.Y,destination.Z})
 local result={};for _,p in ipairs(points)do table.insert(result,Vector3.new(table.unpack(p)))end
 return result
end
function Navigation.start()
 local player=Players.LocalPlayer
 local folder=Instance.new('Folder');folder.Name='DeepwoodNavigation';folder.Parent=workspace
 local function opacity(p,value) p.Transparency=value;p.GuideOverlay.Transparency=value end
 local arrows={};local target;local elapsed=0;local surfacesDirty=true
 local added=workspace.DescendantAdded:Connect(function(p) if isSurface(p) then surfacesDirty=true end end)
 local removed=workspace.DescendantRemoving:Connect(function(p) if isSurface(p) then surfacesDirty=true end end)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
 for i=1,20 do
  local pair={}
  for j=1,2 do
   local p=Instance.new('Part');p.Name='GuideChevron';p.Size=Vector3.new(.18,.09,1.65);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
   p.Material=Enum.Material.Neon;p.Color=Color3.fromRGB(255,224,137);p.Transparency=1;p.Parent=folder
   local overlay=Instance.new('BoxHandleAdornment');overlay.Name='GuideOverlay';overlay.Adornee=p;overlay.Size=p.Size;overlay.Color3=p.Color
   overlay.AlwaysOnTop=true;overlay.ZIndex=1;overlay.Transparency=1;overlay.Parent=p;pair[j]=p
  end
  arrows[i]=pair
 end
 local function hide() for _,pair in ipairs(arrows) do for _,p in ipairs(pair) do opacity(p,1) end end end
 local connection=RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<1/30 then return end;elapsed=0
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
  if not Settings.enabled(player,'navigation') or not target or not root or not human or human.Health<=0 or player:GetAttribute('K0SessionPhase')~='Tutorial' or player:GetAttribute('TLTRoute')=='Training' then hide();return end
  if surfacesDirty then
   surfacesDirty=false
   local surfaces={workspace.Terrain};local field=workspace:FindFirstChild('DeepwoodCampaign')
   if field then for _,p in ipairs(field:GetDescendants()) do if isSurface(p) then table.insert(surfaces,p) end end end
   params.FilterDescendantsInstances=surfaces
  end
  local destination=Vector3.new(target.X,root.Position.Y,target.Z)
  local route=Navigation.route(root.Position,target)
  if #route<2 then hide();return end
  -- Keep an arrival chevron visible until the active objective changes.
  local arrival=flat(target-root.Position).Magnitude<12
  local phase=(os.clock()*5)%6
  local firstVisible=false
  for i,pair in ipairs(arrows) do
   local remaining=5+(i-1)*6+phase;local position,direction
   for j=2,#route do
    local delta=route[j]-route[j-1];local length=delta.Magnitude
    if length>0 and remaining<=length then position=route[j-1]+delta.Unit*remaining;direction=flat(delta).Unit;break end
    remaining-=length
   end
   if arrival and i==1 then
    position=destination;direction=flat(target-root.Position)
    direction=direction.Magnitude>.1 and direction.Unit or Vector3.new(0,0,-1)
   end
   local hit=position and workspace:Raycast(position+Vector3.new(0,50,0),Vector3.new(0,-120,0),params)
   if hit and direction and direction.Magnitude>.1 then
    local cf=CFrame.lookAt(hit.Position+Vector3.new(0,.14,0),hit.Position+Vector3.new(0,.14,0)+direction)
    if i==1 then firstVisible=true end
    for j,p in ipairs(pair) do local sign=j==1 and -1 or 1
     p.CFrame=cf*CFrame.new(sign*.48,0,.48)*CFrame.Angles(0,sign*math.pi/4,0);opacity(p,.15+.5*(i/20))
    end
   else for _,p in ipairs(pair) do opacity(p,1) end end
  end
  if not firstVisible then
   -- Keep a local bearing even while nearby floor geometry is streaming in.
   local direction=flat(route[2]-root.Position)
   if direction.Magnitude<.1 then direction=flat(root.CFrame.LookVector) end
   if direction.Magnitude<.1 then direction=Vector3.new(0,0,-1)else direction=direction.Unit end
   local hit=workspace:Raycast(root.Position+Vector3.new(0,8,0),Vector3.new(0,-24,0),params)
   local floor=hit and hit.Position.Y or root.Position.Y-math.max(root.Size.Y*1.5,root.Size.Y*.5+human.HipHeight)
   local origin=Vector3.new(root.Position.X,floor+.14,root.Position.Z)+direction*2
   local cf=CFrame.lookAt(origin,origin+direction)
   for j,p in ipairs(arrows[1])do local sign=j==1 and -1 or 1;p.CFrame=cf*CFrame.new(sign*.48,0,.48)*CFrame.Angles(0,sign*math.pi/4,0);opacity(p,.2) end
  end
 end)
 return {setTarget=function(value) target=value;if not value then hide() end end,destroy=function() connection:Disconnect();added:Disconnect();removed:Disconnect();folder:Destroy() end}
end
return Navigation
