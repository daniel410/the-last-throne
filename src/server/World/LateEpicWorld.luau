-- Disposable native world art. Content IDs, nodes and terrain are independent of creature art.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.LateEpicContent)
local Bounds=require(Shared.CampaignBounds)
local W={}
local function v(p)return Vector3.new(table.unpack(p))end
local function part(parent,name,size,cf,color,solid,material)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=typeof(cf)=='CFrame' and cf or CFrame.new(cf);p.Color=color;p.Material=material or Enum.Material.Slate;p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if not solid then p:SetAttribute('TLTDecorative',true)end
 p.Parent=parent;return p
end
local function line(parent,name,a,b,width,color)
 return part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color)
end
local function web(parent,p,key)
 local m=Instance.new('Model');m.Name='ScoutWeb';m:SetAttribute('LateStoryHideKey',key);m.Parent=parent
 local silk=Color3.fromRGB(189,179,205)
 for i=-2,2 do
  line(m,'WebStrand',p+Vector3.new(i*1.5,0,0),p+Vector3.new(-i*1.5,6,0),.16,silk)
  line(m,'WebCross',p+Vector3.new(-4,i+3,0),p+Vector3.new(4,i+3,0),.12,silk)
 end
end
local function arch(parent,p,color,width)
 for _,x in ipairs({-width/2,width/2})do part(parent,'GatePillar',Vector3.new(6,28,8),p+Vector3.new(x,14,0),color,true)end
 part(parent,'GateLintel',Vector3.new(width+6,5,8),p+Vector3.new(0,28,0),color,true)
end
function W.create(world)
 if world.lateEpicsReady then return world end
 local props=Instance.new('Folder');props.Name='LateEpicProps';props.Parent=world.folder
 local foundation=Instance.new('Model');foundation.Name='LateEpicFoundation';foundation.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;foundation.Parent=world.terrain
 world.lateCompanionCamps={}
 for _,chapter in ipairs(Content.chapters)do
  local id=chapter.zone;local z=Content.zones[id];local center=v(z.center);local forest=chapter.epic==4
  local ground=forest and Color3.fromRGB(77,94,73) or Color3.fromRGB(108,115,131)
  local stone=Color3.fromRGB(87,84,102);world.positions[id]=center
  local region=Instance.new('Model');region.Name=id;region:SetAttribute('EpicId',forest and 'Gloamwood' or 'HauntedGraveyard');region.Parent=world.terrain
  part(foundation,'Support_'..id,Vector3.new(z.size[1],100,z.size[2]),center-Vector3.new(0,50,0),ground,true)
  part(region,'Ground',Vector3.new(z.size[1],.4,z.size[2]),center-Vector3.new(0,.2,0),ground,true,forest and Enum.Material.Grass or Enum.Material.Cobblestone)
  local sp=Instance.new('SpawnLocation');sp.Name=id..'_SP';sp.Size=Vector3.new(12,.2,12);sp.Position=center+Vector3.new(-140,.1,110);sp.Anchored=true;sp.CanCollide=false;sp.CanTouch=false;sp.CanQuery=false;sp.Neutral=true;sp.Enabled=false;sp.Duration=0;sp.Parent=world.folder;world.spawns[id]=sp
  for i=1,16 do
   local side=i%2==0 and -1 or 1;local at=center+Vector3.new(side*195,0,-175+math.floor((i-1)/2)*48)
   if forest then
    part(region,'AncientTrunk',Vector3.new(12,34,12),at+Vector3.new(0,17,0),Color3.fromRGB(71,61,59),true,Enum.Material.Wood)
    part(region,'Canopy',Vector3.new(44,12,42),at+Vector3.new(0,36,0),Color3.fromRGB(59,80,73))
   else
    part(region,'BoundaryPillar',Vector3.new(7,20,7),at+Vector3.new(0,10,0),stone,true)
    part(region,'Memorial',Vector3.new(9,7,4),at+Vector3.new(-side*18,3.5,0),Color3.fromRGB(150,151,156),true)
   end
  end
  if not forest then arch(region,center+Vector3.new(0,0,145),stone,95)end
  for _,x in ipairs({-155,155})do require(script.Parent.StoryProps).build(region,'RouteLantern',center+Vector3.new(x,0,80),{theme=forest and 'Gloamwood' or 'HauntedGraveyard'})end
  if id=='GW-03' or id=='HG-02' then
   local camp=require(script.Parent.NPCActors).acquire(world.folder,'Selene',center+Vector3.new(-45,0,80),{scope=id,role='camp',priority=20})
   camp:SetAttribute('LateEpicCamp',id)
   table.insert(world.lateCompanionCamps,{model=camp,requiresMain=z.requiresMain})
   for _,x in ipairs({-90,90})do
    part(region,'ShelterRoof',Vector3.new(48,3,38),center+Vector3.new(x,18,100),Color3.fromRGB(78,87,101))
    for _,dx in ipairs({-20,20})do part(region,'ShelterPost',Vector3.new(3,18,3),center+Vector3.new(x+dx,9,115),stone,true)end
   end
  elseif id=='GW-07' then
   web(props,center+Vector3.new(0,0,-165),'GW-07:exit')
  elseif id=='HG-07' then
   part(region,'BlackThroneSeat',Vector3.new(18,4,12),center+Vector3.new(65,2,14),stone,true)
   part(region,'BlackThroneBack',Vector3.new(18,24,4),center+Vector3.new(65,12,23),stone,true)
   local heart=part(props,'Crownheart',Vector3.new(3,5,3),center+Vector3.new(65,9,14),Color3.fromRGB(122,228,255),false,Enum.Material.Neon);heart:SetAttribute('LateStoryHideKey','HG-07:crownheart')
   local portal=part(props,'InvasionPortal',Vector3.new(70,40,2),center+Vector3.new(0,20,-175),Color3.fromRGB(152,68,211),false,Enum.Material.Neon);portal.Transparency=.25;portal:SetAttribute('LateStoryHideKey','HG-07:portal')
  end
  for _,g in ipairs(chapter.goals)do
   local p=part(world.folder.Objectives,id..'_'..g.id,Vector3.new(3,2,3),v(g.position)+Vector3.new(0,1,0),Color3.fromRGB(221,180,82));p.Transparency=1;p:SetAttribute('ChapterId',id);p:SetAttribute('GoalId',g.id)
   local prompt=Instance.new('ProximityPrompt');prompt.Name='StoryInteract';prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText=#g.enemies>0 and 'Begin encounter' or 'Interact';prompt.ObjectText=g.title;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=p
   world.nodes[id..':'..g.id]={part=p,prompt=prompt,chapter=chapter,goal=g}
   if forest and (g.id=='bindings' or g.id=='webs')then web(props,v(g.position),id..':'..g.id)end
   if g.id=='west' or g.id=='east'then
    local device=require(script.Parent.StoryProps).build(props,'PortalAnchor',v(g.position),{theme='HauntedGraveyard'});device:SetAttribute('LateStoryRestoreKey',id..':'..g.id)
   end
  end
  task.wait()
 end
 for _,edge in ipairs(Content.edges)do
  local a,b=Bounds.ends(edge);a,b=v(a),v(b)
  part(foundation,'LateTrail_'..edge[1]..'_'..edge[2],Vector3.new(96,4,(b-a).Magnitude+6),CFrame.lookAt((a+b)/2,b)-Vector3.new(0,2,0),Color3.fromRGB(105,111,98),true)
 end
 world.lateEpicsReady=true;world.folder:SetAttribute('LateEpicsReady',true);return world
end
return W
