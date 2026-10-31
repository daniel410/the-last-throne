-- Original TD Light Nun meshes; independent anchored presentation for the trial supporter.
local Storage=game:GetService('ServerStorage')
local V={}
function V.create(parent,position,name)
 local template=Storage:WaitForChild('TDSeleneModels'):FindFirstChild('nun')
 assert(template and template:IsA('Model'),'Pinned TD Light Nun template missing')
 local model=template:Clone();model.Name=name or 'Selene'
 for _,item in ipairs(model:GetDescendants()) do
  assert(not item:IsA('LuaSourceContainer'),'Executable TD appearance is not allowed')
  if item:IsA('BasePart') then item.Anchored=true;item.CanCollide=false;item.CanTouch=false;item.CanQuery=false end
 end
 local _,size=model:GetBoundingBox();assert(size.Y>0,'Invalid Light Nun bounds')
 model:ScaleTo(model:GetScale()*6.5/size.Y)
 local cf,bounds=model:GetBoundingBox();model:PivotTo(CFrame.new(position+Vector3.new(0,bounds.Y/2,0))*cf:Inverse()*model:GetPivot())
 local anchor=Instance.new('Part');anchor.Name='SupportRoot';anchor.Size=Vector3.one;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Position=position;anchor.Parent=model
 model.PrimaryPart=anchor;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model:SetAttribute('TDSourceModel','nun')
 local gui=Instance.new('BillboardGui');gui.Name='SupportLabel';gui.Size=UDim2.fromOffset(200,44);gui.StudsOffset=Vector3.new(0,8,0);gui.MaxDistance=65;gui.Parent=anchor
 local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextSize=13;label.TextColor3=Color3.fromRGB(255,236,177);label.TextStrokeTransparency=.2;label.Text='Selene · Priest';label.AutoLocalize=false;label.Parent=gui
 model.Parent=parent;return model
end
return V
