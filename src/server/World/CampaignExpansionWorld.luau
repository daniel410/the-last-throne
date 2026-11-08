-- Distinct incident wings, connected foundations and quiet recovery spaces.
-- None of the additional scenery is a story gate or a combat actor.
local Shared=game.ReplicatedStorage.Shared
local Content=require(Shared.CampaignContent)
local K=require(script.Parent.EpicEnvironmentKit)
local W={}
local V=Vector3.new
local themes={DW='Deepwood',GW='Gloamwood',FV='FrozenVale',EC='EmberCaldera',HG='HauntedGraveyard'}
local function vec(t)return V(table.unpack(t))end
local function floor(parent,name,rect,color,material)
 local p=Instance.new('Part');p.Name=name
 if rect.rampStart then
  local first,last=vec(rect.rampStart),vec(rect.rampEnd);local delta=last-first
  p.Size=V(32,64,math.max(1,delta.Magnitude))
  p.CFrame=CFrame.lookAt((first+last)/2,last)*CFrame.new(0,-32,0)
 else p.Size=V(rect.size[1],64,rect.size[2]);p.Position=vec(rect.center)-V(0,32,0)end
 p.Color=color;p.Material=material or Enum.Material.Slate;p.Anchored=true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute('ExpansionFloor',true);p.Parent=parent;return p
end
local function label(part,text)
 local gui=Instance.new('BillboardGui');gui.Name='IncidentName';gui.Size=UDim2.fromOffset(260,48);gui.StudsOffset=V(0,6,0);gui.MaxDistance=100;gui.Parent=part
 local t=Instance.new('TextLabel');t.Text=text;t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.TextWrapped=true;t.TextColor3=Color3.fromRGB(247,230,184);t.Font=Enum.Font.GothamBold;t.TextSize=13;t.TextStrokeTransparency=.2;t.AutoLocalize=false;t.Parent=gui
end
-- The archived forest builder owns short perimeter segments. Open only the
-- new, server-authorized connector mouths; retain every other boundary.
function W.openEntrances(world,scope)
 local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={world.folder};params.RespectCanCollide=true
 local opened,moved=0,0
 for _,c in ipairs(scope.content.chapters)do
  local z=Content.zones[c.zone]
  for _,g in ipairs(c.expansionGoals or {})do
   local area;for _,candidate in ipairs(z.expansionAreas)do if candidate.id==g.area then area=candidate end end
   local rect=area.connector
   local hits=workspace:GetPartBoundsInBox(CFrame.new(vec(rect.center)+V(0,7,0)),V(rect.size[1]+4,14,rect.size[2]+4),params)
   for _,part in ipairs(hits)do
    if part.Name=='ForestBoundary'then
     part:SetAttribute('ExpansionEntranceOpened',true);part.Transparency=1;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;opened=opened+1
    elseif part.Name=='TreeCollision'then
     local at=part.Position;local radius=math.max(part.Size.X,part.Size.Z)/2
     local normal=area.axis=='x'and V(0,0,1)or V(1,0,0)
     local size=area.axis=='x'and rect.size[2]or rect.size[1]
     local delta
     for _,side in ipairs({-1,1})do
      local destination=at+normal*side*(size/2+radius+18)
      if require(Shared.CampaignAreas).containsZone(z,destination.X,destination.Z,-4)then delta=destination-at;break end
     end
     if delta then
      for _,tree in ipairs(part.Parent:GetChildren())do if tree:IsA('Model')and (tree.Name=='TDForestTree'or tree.Name=='TDElderTree')then
       local cf=tree:GetBoundingBox();if V(cf.X-at.X,0,cf.Z-at.Z).Magnitude<1 then tree:PivotTo(tree:GetPivot()+delta);break end
      end end
      part:SetAttribute('ExpansionOriginalPosition',at);part.CFrame+=delta;moved=moved+1
     end
    end
   end
  end
 end
 world.folder:SetAttribute('ExpansionBoundaryOpenings',(world.folder:GetAttribute('ExpansionBoundaryOpenings')or 0)+opened)
 world.folder:SetAttribute('ExpansionRelocatedTrees',(world.folder:GetAttribute('ExpansionRelocatedTrees')or 0)+moved)
end
function W.create(world,scope)
 local container=world.folder:FindFirstChild('CampaignExpansion')or Instance.new('Folder');container.Name='CampaignExpansion';container.Parent=world.folder
 local key='Epic'..scope.epic;if container:FindFirstChild(key)then return end
 local site=Instance.new('Folder');site.Name=key;site.Parent=container
 local support=Instance.new('Model');support.Name=key..'ExpansionFoundation';support.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;support.Parent=world.terrain
 for _,c in ipairs(scope.content.chapters)do
  local z=Content.zones[c.zone];local theme=themes[c.id:sub(1,2)];local pal=K.palette[theme]
  for _,g in ipairs(c.expansionGoals or {})do
   local area;for _,a in ipairs(z.expansionAreas)do if a.id==g.area then area=a end end
   local center=vec(area.center);local entry=vec(area.entry)
   local material=theme=='FrozenVale'and Enum.Material.Snow or (theme=='Deepwood'or theme=='Gloamwood')and Enum.Material.Grass or theme=='EmberCaldera'and Enum.Material.Basalt or Enum.Material.Slate
   floor(support,c.id..'_'..g.id..'_Wing',area,pal.ground,material)
   floor(support,c.id..'_'..g.id..'_Walk',area.connector,pal.ground,material)
   local edge=vec(area.connector.rampStart)
   floor(support,c.id..'_'..g.id..'_Apron',{center={(entry.X+edge.X)/2,entry.Y,(entry.Z+edge.Z)/2},size={area.axis=='x'and math.max(1,math.abs(entry.X-edge.X))or 32,area.axis=='z'and math.max(1,math.abs(entry.Z-edge.Z))or 32}},pal.ground,material)
   local scene=Instance.new('Model');scene.Name=c.id..'_'..g.id;scene.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;scene:SetAttribute('Theme',theme);scene:SetAttribute('IncidentSpace',area.name);scene.Parent=site
   for _,pair in ipairs({{entry,edge},{edge,vec(area.connector.rampEnd)},{vec(area.connector.rampEnd),center}})do local path=K.beam(scene,'ExpansionWalkingLine',pair[1]+V(0,.05,0),pair[2]+V(0,.05,0),5,pal.trim,Enum.Material.Ground);path.Size=V(12,.08,path.Size.Z)end
   K.arch(scene,entry,24,15,pal)
   local post=K.part(scene,'IncidentBoard',V(5,4,.5),CFrame.new(entry+V(12,3,0)),pal.wood,Enum.Material.Wood);label(post,area.name)
   require(script.Parent.CampaignIncidentScenes).create(scene,c,g,area)
   -- Deepwood's original builder still consumes its archived raw content.
   -- All other builders already create the new objective anchors from the projection.
   local node=world.nodes[c.id..':'..g.id]
   if not node then
    local anchor=Instance.new('Part');anchor.Name=c.id..'_'..g.id;anchor.Size=V(1,1,1);anchor.Position=vec(g.position)+V(0,1,0);anchor.Anchored=true;anchor.Transparency=1;anchor.CanCollide=false;anchor.CanTouch=false;anchor.CanQuery=false;anchor:SetAttribute('ChapterId',c.id);anchor:SetAttribute('GoalId',g.id);anchor.Parent=world.folder.Objectives
    local prompt=Instance.new('ProximityPrompt');prompt.Name='StoryInteract';prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ObjectText=g.title;prompt.ActionText='Interact';prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=12;prompt.HoldDuration=.3;prompt.RequiresLineOfSight=false;prompt.Parent=anchor
    world.nodes[c.id..':'..g.id]={part=anchor,prompt=prompt,chapter=c,goal=g}
   end
  end
  task.wait()
 end
end
return W
