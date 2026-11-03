-- Imported skinned presentation; server collision, health and attack clocks stay on R6.
local Storage=game:GetService('ServerStorage')
local Appearance={}
local names={QueenIceElf='queen_ice_elf',VolcanoShaman='volcano_shaman',KingVolcanoShaman='king_volcano_shaman'}
function Appearance.supports(kind)return names[kind]~=nil end
local function template(kind)
 local folder=assert(Storage:FindFirstChild('RegionalCasterModels'),'Missing regional caster imports')
 return assert(folder:FindFirstChild(kind),'Missing caster template '..kind)
end
function Appearance.describe(kind)
 local source=template(kind);local height=source.TargetHeight.Value
 return {template=names[kind],targetHeight=height,sourceToStudScale=height,parts={'Body','Staff'}}
end
function Appearance.attach(rig,kind,footOffset,multiplier)
 local source=template(kind);local root=assert(rig:FindFirstChild('HumanoidRootPart'))
 local torso=assert(rig:FindFirstChild('Torso'));multiplier=multiplier or 1
 assert(type(multiplier)=='number' and multiplier>0 and multiplier<math.huge,'Invalid visual multiplier')
 local offset=footOffset or root.Size.Y*1.5
 assert(type(offset)=='number' and offset>=0 and offset<math.huge,'Invalid foot offset')
 local height=source.TargetHeight.Value*multiplier
 local visual=source:Clone();visual.Name='TdMonsterVisual'
 -- The GLB importer already converts +Z source facing into native -Z.
 visual:ScaleTo(height);visual:PivotTo(root.CFrame*CFrame.new(0,-offset,0))
 for _,o in visual:GetDescendants()do if o:IsA('BasePart')then
  o.Anchored=false;o.Massless=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false
 end end
 local weld=Instance.new('WeldConstraint');weld.Name='TdVisualWeld';weld.Part0=torso;weld.Part1=visual.VisualRoot;weld.Parent=visual.VisualRoot
 for _,o in rig:GetChildren()do if o:IsA('BasePart')then o.Transparency=1 end end
 rig:SetAttribute('TdMonsterTemplate',names[kind]);rig:SetAttribute('TdMonsterSourceHeight',source.TargetHeight.Value)
 rig:SetAttribute('TdMonsterTargetHeight',height);rig:SetAttribute('TdMonsterVisualMultiplier',multiplier)
 rig:SetAttribute('TdMonsterScale',height);rig:SetAttribute('TdWeaponArm','ArmR');rig:SetAttribute('TdWeaponPart','Staff')
 rig:SetAttribute('TdSkinnedCaster',true)
 visual.Parent=rig
 return visual
end
return Appearance
