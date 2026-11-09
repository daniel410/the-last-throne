-- Real two-control choices beside the existing step; same authoritative journal IDs.
local W={};local V=Vector3.new
function W.create(world,folder,c,g,step)
 world.activityChoices=world.activityChoices or {}
 local display=require(game.ReplicatedStorage.Shared.CampaignCircuit).display(step)
 local function piece(parent,name,size,at,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.Position=at;p.Color=color;p.Material=material or Enum.Material.Metal
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
 end
 for index,answer in ipairs(display)do
  local at=V(table.unpack(step.position))+V(index==1 and -10 or 10,0,0)
  local model=Instance.new('Model');model.Name=c.id..'_'..g.id..'_'..step.id..'_'..answer.id;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
  model:SetAttribute('ExpansionStepEvent',c.id..':'..g.id);model:SetAttribute('ExpansionStepChapter',c.id);model:SetAttribute('ExpansionStepIndex',tonumber(step.id:match('%d+')))
  piece(model,'ValveBase',V(3,1,3),at+V(0,.5,0),Color3.fromRGB(106,108,108))
  piece(model,'ValveStem',V(.5,2.5,.5),at+V(0,2,0),Color3.fromRGB(190,150,83))
  piece(model,'Handle',V(3,.3,.5),at+V(0,3,0),Color3.fromRGB(215,183,109))
  local glyph=piece(model,'ShapeMark',V(3.2,2,.25),at+V(0,2.6,-1.7),Color3.fromRGB(50,64,68))
  local gui=Instance.new('BillboardGui');gui.Size=UDim2.fromOffset(190,44);gui.StudsOffset=V(0,4,0);gui.MaxDistance=30;gui.Parent=glyph
  local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=13;text.TextColor3=Color3.fromRGB(250,222,146);text.TextStrokeTransparency=.2;text.Text=answer.symbol:upper()..' CONTROL';text.AutoLocalize=false;text.Parent=gui
  local cf=CFrame.new(at+V(0,3,0))
  if answer.symbol=='triangle'then
   for _,r in ipairs({0,2*math.pi/3,4*math.pi/3})do local bar=piece(model,'TriangleStroke',V(1.8,.12,.15),at+V(0,3.4,0),Color3.fromRGB(241,201,98));bar.CFrame=cf*CFrame.Angles(0,r,0)*CFrame.new(0,.4,-.5)end
  elseif answer.symbol=='ring'then
   for i=0,5 do local bar=piece(model,'RingStroke',V(.9,.12,.15),at+V(0,3.4,0),Color3.fromRGB(241,201,98));bar.CFrame=cf*CFrame.Angles(0,i*math.pi/3,0)*CFrame.new(0,.4,-.8)end
  else
   local bar=piece(model,'ShieldStroke',V(1.4,.12,1.4),at+V(0,3.4,0),Color3.fromRGB(241,201,98));bar.CFrame=cf*CFrame.new(0,.4,0)*CFrame.Angles(0,math.pi/4,0)
   if answer.symbol=='broken'then piece(model,'BrokenMark',V(.2,.15,2),at+V(0,3.5,0),Color3.fromRGB(76,67,64))end
  end
  for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then p:SetAttribute('ExpansionOriginalColor',p.Color)end end
  model.Parent=folder
  local anchor=piece(folder,'CircuitChoiceAnchor',V(1,1,1),at+V(0,1,0),Color3.new());anchor.Transparency=1
  anchor:SetAttribute('ChapterId',c.id);anchor:SetAttribute('GoalId',g.id);anchor:SetAttribute('StepId',step.id)
  local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX
  prompt.ObjectText=answer.title;prompt.ActionText=step.id=='step3'and 'Connect relay'or 'Turn valve';prompt.HoldDuration=.45;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.Parent=anchor
  world.activityChoices[c.id..':'..g.id..':'..step.id..':'..answer.id]={part=anchor,prompt=prompt,chapter=c,goal=g,step=step,choice=answer.id}
 end
end
return W
