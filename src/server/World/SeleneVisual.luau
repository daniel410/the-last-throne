-- Intact TD Light Nun surface, weighted to a continuous 15-bone rig.
local Storage=game:GetService('ServerStorage')
local Catalog=require(game:GetService('ReplicatedStorage').Shared.NPCCatalog)
local V={}
-- Keep the original TD silhouette just below a standard player avatar.
local BASE_HEIGHT=4.8
local function meshBounds(model)
 local low=Vector3.new(math.huge,math.huge,math.huge)
 local high=-low
 for _,p in model:GetDescendants()do if p:IsA('MeshPart')then
  for _,x in {-1,1}do for _,y in {-1,1}do for _,z in {-1,1}do
   local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)*.5)
   low=low:Min(v);high=high:Max(v)
  end end end
 end end
 return CFrame.new((low+high)*.5),high-low
end
function V.create(parent,position,name,options)
 options=options or {};local c=Catalog.byId.selene
 local template=Storage:WaitForChild('SeleneRepairedModels'):FindFirstChild('nun')
 assert(template and template:IsA('Model'),'Pinned TD Light Nun template missing')
 local model=template:Clone();model.Name=name or c.name
 -- The glTF import already faces native -Z. Keep a canonical feet-space pivot.
 model.PrimaryPart=assert(model:FindFirstChild('VisualRoot'))
 model.PrimaryPart.Size=Vector3.one*.001
 model:PivotTo(CFrame.identity)
 for _,item in ipairs(model:GetDescendants()) do
  assert(not item:IsA('LuaSourceContainer'),'Executable TD appearance is not allowed')
  if item:IsA('BasePart') then item.Anchored=true;item.CanCollide=false;item.CanTouch=false;item.CanQuery=false;item:SetAttribute('TLTDecorative',true) end
 end
 local _,size=meshBounds(model);assert(size.Y>0,'Invalid Light Nun bounds')
 model:ScaleTo(model:GetScale()*BASE_HEIGHT*(options.scale or 1)/size.Y)
 local cf,bounds=meshBounds(model)
 model:PivotTo(CFrame.new(position+Vector3.new(0,bounds.Y/2,0))*cf:Inverse()*model:GetPivot())
 local anchor=Instance.new('Part');anchor.Name='ActorRoot';anchor.Size=Vector3.one;anchor.Transparency=1;anchor.Anchored=true;anchor.CanCollide=false;anchor.CanQuery=false;anchor.CanTouch=false;anchor.Position=position;anchor.Parent=model
 model.PrimaryPart=anchor;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 model:SetAttribute('TLTNPC',true);model:SetAttribute('NPCId','selene');model:SetAttribute('NPCRegion',c.region);model:SetAttribute('NPCVisualVersion',5)
 model:SetAttribute('NPCNameKey',c.nameKey);model:SetAttribute('NPCRoleKey',c.roleKey);model:SetAttribute('TDSourceModel','nun')
 model:PivotTo(CFrame.new(position)*CFrame.Angles(0,options.yaw or 0,0))
 -- Bone rest frames scale with the model. Mesh parts move together; skinning
 -- carries the continuous hood, robe and feet without independent cut pieces.
 for _,part in ipairs(model:GetDescendants()) do
  if part:IsA('BasePart') and part~=anchor then
   part:SetAttribute('SeleneRest',anchor.CFrame:ToObjectSpace(part.CFrame))
  end
 end
 model:SetAttribute('SeleneSkinned',true)
 model:SetAttribute('SeleneMotionScale',options.scale or 1)
 if options.label~=false then
  local gui=Instance.new('BillboardGui');gui.Name='NPCLabel';gui.Size=UDim2.fromOffset(220,44);gui.StudsOffset=Vector3.new(0,BASE_HEIGHT*(options.scale or 1)+.8,0);gui.MaxDistance=55;gui.Parent=anchor
  local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Font=Enum.Font.GothamBold;label.TextSize=12;label.TextColor3=Color3.fromHex(c.accent);label.TextStrokeTransparency=.2;label.Text=c.name..' · '..c.role;label.AutoLocalize=false;label.Parent=gui
 end
 model.Parent=parent
 return model
end
return V
