-- Intact Meshy surfaces and custom skeletons; gameplay stays on the server R6 rig.
local Storage=game:GetService('ServerStorage')
local G={}
local kinds={Webling=18,Silkweaver=18,Barkstalker=18,Gloambat=6,VenomcoilCentipede=14,AncientHollowbark=10,HollowbarkSovereign=10,VenomcoilKing=14,WidowQueen=18}
function G.supports(kind)return kinds[kind]~=nil end
local function template(kind)
 assert(kinds[kind],'Unsupported Gloamwood kind')
 local folder=assert(Storage:FindFirstChild('GloamwoodMeshyModels'),'Missing Gloamwood Meshy templates')
 local source=assert(kind=='HollowbarkSovereign' and Storage:FindFirstChild('HollowbarkSovereignTemplate') or folder:FindFirstChild(kind),'Missing Gloamwood template '..kind)
 assert(source:IsA('Model') and source:FindFirstChild('Body') and source.Body:IsA('MeshPart'),'Invalid Gloamwood model')
 assert(source.Body.MeshId~='' and source.Body.TextureID~='','Missing Gloamwood mesh or texture')
 assert(source.SourceToStudScale.Value>0 and source.TargetHeight.Value>0,'Invalid Gloamwood scale')
 return source
end
function G.describe(kind)
 local source=template(kind)
 return {template=kind,targetHeight=source.TargetHeight.Value+source.HoverHeight.Value,sourceToStudScale=source.SourceToStudScale.Value,parts={'Body'},prototype=false,version=3}
end
function G.attach(rig,kind,footOffset,multiplier)
 local source=template(kind);local root=assert(rig:FindFirstChild('HumanoidRootPart'))
 assert(not rig:FindFirstChild('TdMonsterVisual'),'Gloamwood visual already attached')
 multiplier=multiplier or 1
 assert(type(multiplier)=='number' and multiplier>0 and multiplier<math.huge,'Invalid visual multiplier')
 local offset=footOffset or root.Size.Y*1.5
 assert(type(offset)=='number' and offset>=0 and offset<math.huge,'Invalid foot offset')
 local visual=source:Clone();visual.Name='TdMonsterVisual'
 local scale=source.SourceToStudScale.Value*multiplier
 local hover=source.HoverHeight.Value*multiplier
 visual:ScaleTo(scale);visual:PivotTo(root.CFrame*CFrame.new(0,-offset+hover,0))
 local count=0
 for _,o in visual:GetDescendants()do
  if o:IsA('Bone')then count+=1;o.Transform=CFrame.identity end
  if o:IsA('BasePart')then o.Anchored=false;o.Massless=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false end
 end
 assert(count==kinds[kind],'Incomplete Gloamwood skeleton')
 local weld=Instance.new('WeldConstraint');weld.Name='GloamwoodVisualWeld';weld.Part0=root;weld.Part1=visual.VisualRoot;weld.Parent=visual.VisualRoot
 for _,p in rig:GetChildren()do if p:IsA('BasePart')then p.Transparency=1 end end
 rig:SetAttribute('TdMonsterTemplate',kind)
 rig:SetAttribute('TdMonsterTargetHeight',source.TargetHeight.Value*multiplier+hover)
 rig:SetAttribute('TdMonsterScale',scale);rig:SetAttribute('TdMonsterVisualMultiplier',multiplier)
 rig:SetAttribute('GloamwoodMeshyVersion',1);rig:SetAttribute('GloamwoodPrototypeVersion',nil)
 visual.Parent=rig
 return visual
end
return G
