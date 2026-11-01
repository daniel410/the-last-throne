-- TD Light Nun derivative: separate head/robe/feet, original sleeves and lantern.
local Storage=game:GetService('ServerStorage')
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local V={}
-- Keep the original TD silhouette just below a standard player avatar.
local BASE_HEIGHT=4.8
function V.create(parent,position,name,options)
 options=options or {};local c=Catalog.byId.selene
 local template=Storage:WaitForChild('SeleneArticulatedModels'):FindFirstChild('nun')
 assert(template and template:IsA('Model'),'Pinned TD Light Nun template missing')
 local model=template:Clone();model.Name=name or c.name
 -- Segment meshes have their own import axes; bounds must use canonical world axes.
 model.WorldPivot=CFrame.new(model:GetPivot().Position)
 for _,item in ipairs(model:GetDescendants()) do
  assert(not item:IsA('LuaSourceContainer'),'Executable TD appearance is not allowed')
  if item:IsA('BasePart') then item.Anchored=true;item.CanCollide=false;item.CanTouch=false;item.CanQuery=false;item:SetAttribute('TLTDecorative',true) end
 end
 local _,size=model:GetBoundingBox();assert(size.Y>0,'Invalid Light Nun bounds')
 model:ScaleTo(model:GetScale()*BASE_HEIGHT*(options.scale or 1)/size.Y)
 local cf,bounds=model:GetBoundingBox()
 model:PivotTo(CFrame.new(position+Vector3.new(0,bounds.Y/2,0))*cf:Inverse()*model:GetPivot())
 local anchor=Instance.new('Part');anchor.Name='ActorRoot';anchor.Size=Vector3.one;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Position=position;anchor.Parent=model
 model.PrimaryPart=anchor;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 model:SetAttribute('TLTNPC',true);model:SetAttribute('NPCId','selene');model:SetAttribute('NPCRegion',c.region);model:SetAttribute('NPCVisualVersion',4)
 model:SetAttribute('NPCNameKey',c.nameKey);model:SetAttribute('NPCRoleKey',c.roleKey);model:SetAttribute('TDSourceModel','nun')
 model:PivotTo(CFrame.new(position)*CFrame.Angles(0,options.yaw or 0,0))
 -- Authored rest space is independent of model yaw and server movement. Shoulder
 -- pivots sit at the upper inner sleeve, never at the lantern/mesh bounding centre.
 for _,part in ipairs(model:GetDescendants()) do
  if part:IsA('BasePart') and part~=anchor then
   local rest=anchor.CFrame:ToObjectSpace(part.CFrame)
   part:SetAttribute('SeleneRest',rest)
   if part.Name=='ArmL' or part.Name=='ArmR' then
    local side=rest.Position.X>=0 and 1 or -1
    part:SetAttribute('SeleneShoulder',Vector3.new(side*.73,BASE_HEIGHT*.67,0)*(options.scale or 1))
   elseif part.Name=='LegL' or part.Name=='LegR' then
    part:SetAttribute('SeleneHip',Vector3.new(rest.Position.X,1.35*(options.scale or 1),rest.Position.Z))
   end
  end
 end
 model:SetAttribute('SeleneArticulated',true)
 model:SetAttribute('SeleneMotionScale',options.scale or 1)
 if options.label~=false then
  local gui=Instance.new('BillboardGui');gui.Name='NPCLabel';gui.Size=UDim2.fromOffset(220,44);gui.StudsOffset=Vector3.new(0,BASE_HEIGHT*(options.scale or 1)+.8,0);gui.MaxDistance=55;gui.Parent=anchor
  local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextSize=12;label.TextColor3=Color3.fromHex(c.accent);label.TextStrokeTransparency=.2;label.Text=c.name..' · '..c.role;label.AutoLocalize=false;label.Parent=gui
 end
 model.Parent=parent
 return model
end
return V
