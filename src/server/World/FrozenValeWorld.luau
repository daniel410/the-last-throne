-- Native winter route. TD monsters are mounted independently by TrainingField.
local Shared=game:GetService('ReplicatedStorage').Shared
local Content=require(Shared.FrozenValeContent)
local Bounds=require(Shared.CampaignBounds)
local W={}
local snow=Color3.fromRGB(216,235,242)
local ice=Color3.fromRGB(115,185,213)
local stone=Color3.fromRGB(74,102,128)
local gold=Color3.fromRGB(251,196,99)
local function v(p)return Vector3.new(table.unpack(p))end
local function part(parent,name,size,cf,color,material,solid)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=typeof(cf)=='CFrame' and cf or CFrame.new(cf);p.Color=color;p.Material=material or Enum.Material.Snow
 p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if not solid then p:SetAttribute('TLTDecorative',true)end
 p.Parent=parent;return p
end
local function beacon(parent,pos)
 part(parent,'ShelterLanternPost',Vector3.new(1,7,1),pos+Vector3.new(0,3.5,0),stone,Enum.Material.Wood)
 local gem=part(parent,'WarmShelterLight',Vector3.new(2,2,2),pos+Vector3.new(0,7,0),gold,Enum.Material.Neon);gem.Shape=Enum.PartType.Ball
 local light=Instance.new('PointLight');light.Color=gold;light.Range=18;light.Brightness=.8;light:SetAttribute('TLTDecorative',true);light.Parent=gem
end
local function arch(parent,pos,height,width)
 for _,x in ipairs({-width/2,width/2})do part(parent,'IceCitadelPillar',Vector3.new(6,height,7),pos+Vector3.new(x,height/2,0),stone,Enum.Material.Slate,true)end
 part(parent,'IceCitadelLintel',Vector3.new(width+6,5,8),pos+Vector3.new(0,height,0),ice,Enum.Material.Ice,true)
end
function W.create(world)
 if world.frozenReady then return world end
 local root=world.folder;local terrain=world.terrain
 local foundation=Instance.new('Model');foundation.Name='FrozenValeFoundation';foundation.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;foundation.Parent=terrain
 for id,z in pairs(Content.zones)do
  local center=v(z.center);world.positions[id]=center
  local region=Instance.new('Model');region.Name=id;region:SetAttribute('EpicId','FrozenVale');region.Parent=terrain
  -- Thin visible surface on a deep persistent foundation; never floating islands.
  part(foundation,'Support_'..id,Vector3.new(z.size[1],100,z.size[2]),center-Vector3.new(0,50,0),stone,Enum.Material.Slate,true)
  part(region,'SnowGround',Vector3.new(z.size[1],.4,z.size[2]),center-Vector3.new(0,.2,0),snow,Enum.Material.Snow,true)
  local sp=Instance.new('SpawnLocation');sp.Name=id..'_SP';sp.Size=Vector3.new(12,.2,12);sp.Position=center+Vector3.new(-140,.1,110);sp.Anchored=true;sp.CanCollide=false;sp.CanQuery=false;sp.CanTouch=false;sp.Neutral=true;sp.Duration=0;sp.Enabled=false;sp.Color=ice;sp.Parent=root;world.spawns[id]=sp
  beacon(region,sp.Position+Vector3.new(-10,0,0))
  for i=1,14 do
   local angle=i*math.pi*2/14;local pos=center+Vector3.new(math.cos(angle)*(z.size[1]/2+24),0,math.sin(angle)*(z.size[2]/2+24))
   local hill=part(region,'Snowbank',Vector3.new(70,30+i%3*8,65),pos-Vector3.new(0,9,0),snow);hill.Shape=Enum.PartType.Ball
   local spire=part(region,'GlacierSpire',Vector3.new(10,22+i%4*7,10),pos+Vector3.new(0,3,0),ice,Enum.Material.Glacier);spire.CFrame*=CFrame.Angles(.12,i,.16)
  end
  for _,x in ipairs({-160,160})do for _,zz in ipairs({-125,125})do
   local p=center+Vector3.new(x,0,zz)
   part(region,'PineTrunk',Vector3.new(2,16,2),p+Vector3.new(0,8,0),stone,Enum.Material.Wood)
   for j=1,3 do local crown=part(region,'SnowPineCrown',Vector3.new(19-j*3,10,19-j*3),p+Vector3.new(0,9+j*5,0),j%2==0 and snow or Color3.fromRGB(79,124,139));crown.Shape=Enum.PartType.Ball end
  end end
  if id=='FV-02' then
   local call=Instance.new('Model');call.Name='RefugeCompanionCamp';call.Parent=region
   local sign=part(call,'CampBoard',Vector3.new(5,4,1),center+Vector3.new(0,3,80),stone,Enum.Material.Wood,true);call.PrimaryPart=sign;world.refugeCompanionCamp=call

   for _,x in ipairs({-70,65})do
    local p=center+Vector3.new(x,0,90);part(region,'RefugeFloor',Vector3.new(50,1,40),p,stone,Enum.Material.Wood,true)
    for _,side in ipairs({-1,1})do part(region,'WarmRefugeRoof',Vector3.new(29,2,48),CFrame.new(p+Vector3.new(side*12,15,0))*CFrame.Angles(0,0,side*.45),Color3.fromRGB(94,68,77),Enum.Material.Fabric)end
    beacon(region,p+Vector3.new(0,0,-22))
   end
  elseif id=='FV-03' then
   for _,x in ipairs({-170,170})do part(region,'RavineIceWall',Vector3.new(14,50,160),center+Vector3.new(x,25,0),ice,Enum.Material.Glacier,true)end
  elseif id=='FV-04' then arch(region,center+Vector3.new(0,0,65),23,70)
  elseif id=='FV-05' then for i=1,5 do part(region,'FrozenRouteMonument',Vector3.new(7,10+i,5),center+Vector3.new(i*35-105,5,125),stone,Enum.Material.Slate,true)end
  elseif id=='FV-06' then arch(region,center+Vector3.new(0,0,125),42,105)
  elseif id=='FV-07' then
   arch(region,center+Vector3.new(0,0,125),36,115)
   for _,offset in ipairs({Vector3.new(-80,0,0),Vector3.new(70,0,0),Vector3.new(-70,0,-90)})do
    local mirror=part(region,'SignalMirror',Vector3.new(12,18,2),center+offset+Vector3.new(0,9,-8),ice,Enum.Material.Glass,true);mirror.Transparency=.25
   end
  end
  if id:match('FV%-S') then arch(region,center+Vector3.new(0,0,85),24,60)end
  task.wait()
 end
 for _,edge in ipairs(Content.edges)do
  local a,b=Bounds.ends(edge);a,b=v(a),v(b)
  part(foundation,'SnowTrail_'..edge[1]..'_'..edge[2],Vector3.new(96,4,(b-a).Magnitude+6),CFrame.lookAt((a+b)/2,b)-Vector3.new(0,2,0),snow,Enum.Material.Snow,true)
  local delta=b-a;local segments=math.max(1,math.ceil(delta.Magnitude/80))
  for i=0,segments do if i%2==0 then beacon(terrain,a:Lerp(b,i/segments)+Vector3.new(38,0,0))end end
 end
 local objectives=root:FindFirstChild('Objectives')
 for _,c in ipairs(Content.chapters)do for _,g in ipairs(c.goals)do
  local p=part(objectives,c.id..'_'..g.id,Vector3.new(3,2,3),v(g.position)+Vector3.new(0,1,0),ice,Enum.Material.Slate);p.Transparency=1
  p:SetAttribute('ChapterId',c.id);p:SetAttribute('GoalId',g.id)
  local prompt=Instance.new('ProximityPrompt');prompt.Name='StoryInteract';prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText=#g.enemies>0 and 'Begin encounter' or 'Interact';prompt.ObjectText=g.title
  prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=p
  world.nodes[c.id..':'..g.id]={part=p,prompt=prompt,chapter=c,goal=g}
  if #g.enemies==0 and not (g.activity and g.activity.actor) then beacon(terrain,v(g.position)+Vector3.new(-6,0,0))end
 end
 end

 world.frozenReady=true;root:SetAttribute('FrozenValeReady',true)
 return world
end
return W
