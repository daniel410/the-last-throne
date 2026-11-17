-- Approved Meshy surfaces; identity, interaction anchors and routes stay server-owned.
local Storage=game:GetService('ServerStorage')
local Tags=game:GetService('CollectionService')
local V={}

function V.tryCreate(parent,c,position,options)
 local folder=Storage:FindFirstChild('NPCMeshyModels')
 local template=folder and folder:FindFirstChild(c.id)
 if not template then return nil end
 assert(c.id~='selene','Selene uses her existing TD appearance')
 local m=template:Clone();m.Name=options.name or c.name
 local root=assert(m.PrimaryPart,'NPC mesh template needs a feet-space anchor')
 assert(root.Name=='ActorRoot' and m:GetAttribute('NPCMeshyTemplateVersion')==1,'Invalid NPC mesh template')
 local scale=options.scale or (c.race=='dwarf' and .88 or c.race=='child' and .74 or 1)
 local height=6.2*scale
 m:ScaleTo(m:GetScale()*height/assert(m:GetAttribute('NPCSourceHeight')))
 m:PivotTo(CFrame.identity)
 m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('TLTNPC',true);m:SetAttribute('NPCId',c.id);m:SetAttribute('NPCRegion',c.region)
 m:SetAttribute('NPCVisualVersion',6);m:SetAttribute('NPCMeshySkinned',true)
 m:SetAttribute('NPCNameKey',c.nameKey);m:SetAttribute('NPCRoleKey',c.roleKey)
 m:SetAttribute('NPCMeshHeight',height)
 if c.race=='spirit' then m:SetAttribute('NPCSpirit',true) end
 for _,p in m:GetDescendants()do
  assert(not p:IsA('LuaSourceContainer') and not p:IsA('PackageLink'),'NPC templates must be immutable appearance data')
  if p:IsA('BasePart')then
   p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true
   p:SetAttribute('TLTDecorative',true)
   if p~=root then p:SetAttribute('NPCMeshRest',root.CFrame:ToObjectSpace(p.CFrame)) end
  end
 end
 if options.label~=false then
  local gui=Instance.new('BillboardGui');gui.Name='NPCLabel';gui.Size=UDim2.fromOffset(220,44)
  gui.StudsOffset=Vector3.new(0,height+.8,0);gui.MaxDistance=55;gui.Parent=root
  local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1
  label.Text=c.name..' · '..c.role;label.Font=Enum.Font.GothamBold;label.TextSize=12
  label.TextColor3=Color3.fromHex(c.accent);label.TextStrokeTransparency=.2;label.AutoLocalize=false;label.Parent=gui
 end
 m:PivotTo(CFrame.new(position)*CFrame.Angles(0,options.yaw or 0,0));m.Parent=parent
 Tags:AddTag(m,'TLTAnimatedNPC')
 return m
end
return V
