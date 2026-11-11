-- Personal restoration driven only by the selected hero's server snapshot.
local Design = require(game.ReplicatedStorage.Shared.DawnspireDesign)
local M = {}
local scene, latestSnapshot, watching
local function refresh()
 local snapshot = latestSnapshot
 local hero = snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]
 local done = hero and hero.deepwood and hero.deepwood.clears and hero.deepwood.clears['HG-07'] == true
 local lobby = workspace:FindFirstChild('DawnspireLobbyPrototype')
 local throne = lobby and lobby:FindFirstChild('DawnspireThrone')
 if scene and (not done or not throne or scene.Parent ~= throne) then scene:Destroy();scene=nil end
 local sign = throne and throne:FindFirstChild('ThroneStorySign')
 local gui = sign and sign:FindFirstChild('FacilitySign')
 if gui then
  gui.Subtitle.Text = done and Design.text.restored or Design.text.missing
  gui.Subtitle:SetAttribute('TextKey', done and 'lobby.throne.restored' or 'lobby.throne.missing')
 end
 if not done or not throne or (scene and scene.Parent) then return end
 local origin = throne:GetAttribute('HeartPosition')
 if typeof(origin) ~= 'Vector3' then return end
 scene = Instance.new('Model');scene.Name='DawnspireHomecoming';scene:SetAttribute('PersonalStoryVisual',true)
 local function part(name,size,offset,color,material,rotation,className)
  local p=Instance.new(className or 'Part');p.Name=name;p.Size=size;p.CFrame=CFrame.new(origin+offset)*(rotation or CFrame.identity)
  p.Color=color;p.Material=material or Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
  p.CastShadow=false;p:SetAttribute('TLTDecorative',true);p.Parent=scene;return p
 end
 -- Eight geometric facets form a floating crystal rather than a box placeholder.
 local color=Color3.fromRGB(127,236,255)
 local heart=part('Crownheart',Vector3.new(1.7,2.8,1.7),Vector3.zero,color,Enum.Material.Glass,CFrame.Angles(0,math.pi/4,0))
 for i=0,3 do
  local yaw=CFrame.Angles(0,i*math.pi/2,0)
  part('HeartUpperFacet',Vector3.new(1.7,2.5,1.7),Vector3.new(0,1.1,0),color,Enum.Material.Neon,yaw,'CornerWedgePart')
  part('HeartLowerFacet',Vector3.new(1.7,2.5,1.7),Vector3.new(0,-1.1,0),color,Enum.Material.Glass,yaw*CFrame.Angles(math.pi,0,0),'CornerWedgePart')
 end
 local light=Instance.new('PointLight');light.Color=color;light.Range=30;light.Brightness=1.4;light.Shadows=false;light.Parent=heart
 for i=0,23 do
  local a=i*math.pi/12
  part('RestoredProtectionRing',Vector3.new(.14,.14,1.1),Vector3.new(math.cos(a)*4, -3.9, math.sin(a)*4),color,nil,CFrame.Angles(0,-a,0))
 end
 local welcome=Instance.new('BillboardGui');welcome.Name='HomecomingGreeting';welcome.Size=UDim2.fromOffset(300,44);welcome.StudsOffset=Vector3.new(0,7,0);welcome.MaxDistance=55;welcome.Parent=heart
 local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=16;text.TextColor3=Color3.fromRGB(255,235,174);text.TextStrokeTransparency=.15;text.Text=Design.text.welcome;text.AutoLocalize=false;text:SetAttribute('TextKey','lobby.throne.welcome');text.Parent=welcome
 scene.Parent=throne
end
function M.update(snapshot)
 latestSnapshot=snapshot
 local hero=snapshot and snapshot.heroId and snapshot.heroes and snapshot.heroes[snapshot.heroId]
 require(script.Parent.CampaignExpansionPresentation).update({journal=hero and hero.deepwood})
 if not watching then
  watching=true
  -- A snapshot may arrive before the atomic throne streams in or after it leaves.
  workspace.DescendantAdded:Connect(function(item)
   if item.Name=='DawnspireThrone' then task.defer(refresh) end
  end)
 end
 refresh()
end
return M
