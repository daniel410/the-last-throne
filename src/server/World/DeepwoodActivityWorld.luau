-- Native scene props for authored activities; objective anchors themselves are invisible.
local Content=require(game:GetService('ReplicatedStorage').Shared.DeepwoodContent)
local W={}
local function part(parent,name,size,p,color,shape)
 local x=Instance.new('Part');x.Name=name;x.Size=size;x.Position=p;x.Color=color;x.Material=Enum.Material.Slate;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;if shape then x.Shape=shape end;x.Parent=parent;return x
end
local function label(p,text)
 local g=Instance.new('BillboardGui');g.Name='ActivityLabel';g.Size=UDim2.fromOffset(220,48);g.StudsOffset=Vector3.new(0,5,0);g.MaxDistance=65;g.Parent=p
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.Font=Enum.Font.GothamBold;t.TextSize=12;t.TextColor3=Color3.fromRGB(255,232,166);t.TextStrokeTransparency=.2;t.TextWrapped=true;t.AutoLocalize=false;t.Parent=g
end
function W.actor(parent,name,position,spirit)
 if name=='Selene' then return require(script.Parent.SeleneVisual).create(parent,position) end
 local m=Instance.new('Model');m.Name=name
 local root=part(m,'ActorRoot',Vector3.new(1,1,1),position,Color3.new());root.Transparency=1;m.PrimaryPart=root;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 if spirit then
  local orb=part(m,'Spirit',Vector3.new(2,3,2),position+Vector3.new(0,3,0),Color3.fromRGB(97,238,203),Enum.PartType.Ball);orb.Material=Enum.Material.Neon
  local light=Instance.new('PointLight');light.Color=orb.Color;light.Brightness=.6;light.Range=10;light.Parent=orb
 else
  local coat=Color3.fromRGB(45,104,92);local skin=Color3.fromRGB(220,186,139)
  part(m,'Torso',Vector3.new(2,2.3,1.1),position+Vector3.new(0,3.2,0),coat)
  local head=part(m,'Head',Vector3.new(1.4,1.4,1.4),position+Vector3.new(0,5,0),skin,Enum.PartType.Ball)
  local face=Instance.new('Decal');face.Texture='rbxasset://textures/face.png';face.Face=Enum.NormalId.Front;face.Parent=head
  for _,side in ipairs({-1,1}) do
   part(m,'Arm',Vector3.new(.7,2.2,.8),position+Vector3.new(side*1.4,3.1,0),coat)
   part(m,'Leg',Vector3.new(.8,2,.9),position+Vector3.new(side*.55,1,0),Color3.fromRGB(47,51,61))
  end
 end
 label(root,name);m.Parent=parent;return m
end
local function prop(parent,step,p)
 local kind=step.kind
 if kind=='actor' then return W.actor(parent,step.title,p).PrimaryPart end
 if kind=='rune' then
  local x=part(parent,'RunePedestal',Vector3.new(5,1,5),p+Vector3.new(0,.5,0),Color3.fromRGB(99,115,119),Enum.PartType.Cylinder);x.CFrame=x.CFrame*CFrame.Angles(0,0,math.pi/2)
  local gem=part(parent,'RuneLight',Vector3.new(1.5,2,1.5),p+Vector3.new(0,2,0),Color3.fromRGB(103,181,221),Enum.PartType.Ball);gem.Material=Enum.Material.Neon;return gem
 elseif kind=='ledger' then
  local x=part(parent,'OpenRecord',Vector3.new(3,.15,2),p+Vector3.new(0,.3,0),Color3.fromRGB(221,204,150));x.CFrame=x.CFrame*CFrame.Angles(0,.6,0);return x
 elseif kind=='bindings' then
  local x=part(parent,'CutBindings',Vector3.new(2,.3,2),p+Vector3.new(0,.2,0),Color3.fromRGB(147,109,64),Enum.PartType.Cylinder);return x
 elseif kind=='tracks' or kind=='arrival' then
  local x=part(parent,'TrailPrint',Vector3.new(.8,.06,2),p+Vector3.new(-.5,.05,0),Color3.fromRGB(65,65,47));part(parent,'TrailPrint',x.Size,p+Vector3.new(.5,.05,1.5),x.Color);return x
 elseif kind=='lever' then
  part(parent,'MechanismBase',Vector3.new(4,1,4),p+Vector3.new(0,.5,0),Color3.fromRGB(91,105,114))
  local x=part(parent,'ReleaseLever',Vector3.new(.5,4,.5),p+Vector3.new(0,2.5,0),Color3.fromRGB(183,153,89));x.CFrame=x.CFrame*CFrame.Angles(.5,0,0);return x
 elseif kind=='lantern' then
  part(parent,'RestoredLanternPost',Vector3.new(.6,5,.6),p+Vector3.new(0,2.5,0),Color3.fromRGB(102,72,43))
  local x=part(parent,'RestoredLantern',Vector3.new(1.5,2,1.5),p+Vector3.new(0,5,0),Color3.fromRGB(247,212,120),Enum.PartType.Ball);x.Material=Enum.Material.Neon;return x
 else
  local x=part(parent,kind=='relic' and 'SealCoreCradle' or 'RitualResidue',Vector3.new(2,1,2),p+Vector3.new(0,.5,0),Color3.fromRGB(154,83,211),Enum.PartType.Ball);x.Material=Enum.Material.Neon;return x
 end
end
function W.create(world)
 local folder=Instance.new('Folder');folder.Name='AdventureActivities';folder.Parent=world.folder
 local nodes={};world.activityNodes=nodes
 for _,c in ipairs(Content.chapters) do if not c.side then for _,g in ipairs(c.goals) do
  local a=g.activity;local node=world.nodes[c.id..':'..g.id]
  if a then
   node.part.Transparency=1;local gem=node.part:FindFirstChild('ObjectiveGem');if gem then gem.Transparency=1 end
   node.prompt.Enabled=a.mode=='dialogue' or a.mode=='escort'
   if a.actor and a.mode=='dialogue' then W.actor(folder,a.actor,Vector3.new(table.unpack(g.position)),a.spirit) end
   if a.steps then
    for _,step in ipairs(a.steps) do
     local p=Vector3.new(table.unpack(step.position));local anchor=part(folder,c.id..'_'..g.id..'_'..step.id,Vector3.new(1,1,1),p+Vector3.new(0,1,0),Color3.new());anchor.Transparency=1
     anchor:SetAttribute('ChapterId',c.id);anchor:SetAttribute('GoalId',g.id);anchor:SetAttribute('StepId',step.id)
     local prompt
     if a.mode~='dialogue' and a.mode~='escort' then
      prop(folder,step,p)
      if a.mode~='travel' and a.mode~='trail' then
       prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.ObjectText=step.title;prompt.ActionText=a.mode=='sequence' and 'Activate rune' or a.mode=='mechanism' and 'Operate' or 'Examine';prompt.HoldDuration=.45;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=anchor
      end
     end
     nodes[c.id..':'..g.id..':'..step.id]={part=anchor,prompt=prompt,chapter=c,goal=g,step=step}
    end
    if a.clue then label(node.part,a.clue) end
   end
  end
 end end end
end
return W
