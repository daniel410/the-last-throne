-- Selene always uses the pinned original TD Light Nun meshes and materials.
local Storage=game:GetService('ServerStorage')
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local V={}
function V.create(parent,position,name,options)
 options=options or {};local c=Catalog.byId.selene
 local template=Storage:WaitForChild('TDSeleneModels'):FindFirstChild('nun')
 assert(template and template:IsA('Model'),'Pinned TD Light Nun template missing')
 local model=template:Clone();model.Name=name or c.name
 for _,item in ipairs(model:GetDescendants()) do
  assert(not item:IsA('LuaSourceContainer'),'Executable TD appearance is not allowed')
  if item:IsA('BasePart') then item.Anchored=true;item.CanCollide=false;item.CanTouch=false;item.CanQuery=false;item:SetAttribute('TLTDecorative',true) end
 end
 local _,size=model:GetBoundingBox();assert(size.Y>0,'Invalid Light Nun bounds')
 model:ScaleTo(model:GetScale()*6.5*(options.scale or 1)/size.Y)
 local cf,bounds=model:GetBoundingBox()
 model:PivotTo(CFrame.new(position+Vector3.new(0,bounds.Y/2,0))*cf:Inverse()*model:GetPivot())
 local anchor=Instance.new('Part');anchor.Name='ActorRoot';anchor.Size=Vector3.one;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Position=position;anchor.Parent=model
 model.PrimaryPart=anchor;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 model:SetAttribute('TLTNPC',true);model:SetAttribute('NPCId','selene');model:SetAttribute('NPCRegion',c.region);model:SetAttribute('NPCVisualVersion',2)
 model:SetAttribute('NPCNameKey',c.nameKey);model:SetAttribute('NPCRoleKey',c.roleKey);model:SetAttribute('TDSourceModel','nun')
 model:PivotTo(CFrame.new(position)*CFrame.Angles(0,options.yaw or 0,0))
 if options.label~=false then
  local gui=Instance.new('BillboardGui');gui.Name='NPCLabel';gui.Size=UDim2.fromOffset(220,44);gui.StudsOffset=Vector3.new(0,7.3,0);gui.MaxDistance=55;gui.Parent=anchor
  local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextSize=12;label.TextColor3=Color3.fromHex(c.accent);label.TextStrokeTransparency=.2;label.Text=c.name..' · '..c.role;label.AutoLocalize=false;label.Parent=gui
 end
 model.Parent=parent
 return model
end
return V
