-- Native scene props for authored activities; objective anchors themselves are invisible.
local Content=require(game:GetService('ReplicatedStorage').Shared.CampaignContent)
local W={}
local function part(parent,name,size,p,color,shape)
 local x=Instance.new('Part');x.Name=name;x.Size=size;x.Position=p;x.Color=color;x.Material=Enum.Material.Slate;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;if shape then x.Shape=shape end;x.Parent=parent;return x
end
local function label(p,text)
 local g=Instance.new('BillboardGui');g.Name='ActivityLabel';g.Size=UDim2.fromOffset(220,48);g.StudsOffset=Vector3.new(0,5,0);g.MaxDistance=65;g.Parent=p
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.Font=Enum.Font.GothamBold;t.TextSize=12;t.TextColor3=Color3.fromRGB(255,232,166);t.TextStrokeTransparency=.2;t.TextWrapped=true;t.AutoLocalize=false;t.Parent=g
end
function W.actor(parent,name,position,spirit,options)
 options=options or {}
 local Actors=require(script.Parent.NPCActors)
 if options.dynamic then
  local model=require(script.Parent.NPCVisual).actor(parent,name,position,spirit)
  return Actors.tag(model,options.role or 'escort',options.ownerUserId)
 end
 return Actors.acquire(options.world or parent,name,position,{spirit=spirit,role=options.role or 'dialogue',priority=30,scope=options.scope})
end
local function prop(parent,chapter,goal,step,p)
 if chapter=='HG-07' and goal=='crownheart' then return end
 local kind=step.kind
 -- An interaction title ("Ask...", "Set out...") is not an NPC identity.
 if kind=='actor' then if step.actor then return W.actor(parent,step.actor,p).PrimaryPart end;return end
 return require(script.Parent.StoryProps).activity(parent,chapter,goal,step,p)
end
function W.create(world)
 local folder=world.folder:FindFirstChild('AdventureActivities') or Instance.new('Folder');folder.Name='AdventureActivities';folder.Parent=world.folder
 local nodes=world.activityNodes or {};world.activityNodes=nodes
 for _,c in ipairs(Content.chapters) do for _,g in ipairs(c.goals) do
  local a=g.activity;local node=world.nodes[c.id..':'..g.id]
  if node and not node.storyArtBuilt then
   node.storyArtBuilt=true
   local visual=require(script.Parent.StoryProps).goal(folder,c.id,g)
   if visual then local gem=node.part:FindFirstChild('ObjectiveGem');if gem then gem.Transparency=1 end end
  end
  if a and node and not node.activityBuilt then
   node.activityBuilt=true
   node.part.Transparency=1;local gem=node.part:FindFirstChild('ObjectiveGem');if gem then gem.Transparency=1 end
   node.prompt.Enabled=a.mode=='dialogue' or a.mode=='escort'
   if a.actor and a.mode=='dialogue' then W.actor(folder,a.actor,Vector3.new(table.unpack(g.position)),a.spirit,{world=world.folder,role='dialogue',scope=(c.id:sub(1,2)=='GW'or c.id:sub(1,2)=='HG')and c.zone or nil}) end
   if a.steps then
    for _,step in ipairs(a.steps) do
     local p=Vector3.new(table.unpack(step.position));local anchor=part(folder,c.id..'_'..g.id..'_'..step.id,Vector3.new(1,1,1),p+Vector3.new(0,1,0),Color3.new());anchor.Transparency=1
     anchor:SetAttribute('ChapterId',c.id);anchor:SetAttribute('GoalId',g.id);anchor:SetAttribute('StepId',step.id)
     local prompt
     if a.mode~='dialogue' and a.mode~='escort' then
      prop(folder,c.id,g.id,step,p)
      if a.mode~='travel' and a.mode~='trail' then
       prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.ObjectText=step.title;prompt.ActionText=a.mode=='sequence' and 'Activate rune' or a.mode=='mechanism' and 'Operate' or 'Examine';prompt.HoldDuration=.45;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=anchor
      end
     end
     if step.circuitControls then require(script.Parent.CampaignCircuitWorld).create(world,folder,c,g,step)end
     nodes[c.id..':'..g.id..':'..step.id]={part=anchor,prompt=prompt,chapter=c,goal=g,step=step}
    end
    if a.clue then label(node.part,a.clue) end
   end
  end
 end end
end
return W
