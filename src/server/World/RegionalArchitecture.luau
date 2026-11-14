-- Blender-authored primitives retain their exact local rotations and proportions.
local Templates=require(script.Parent.RegionalArchitectureTemplates)
local K=require(script.Parent.EpicEnvironmentKit)
local Architecture={version=1}
function Architecture.build(kind)
 local rows=assert(Templates[kind],'Unknown regional architecture '..kind)
 local m=Instance.new('Model');m.Name=kind;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('RegionalConceptRole','Signature')
 m:SetAttribute('BlenderSource','regional-architecture-blender-v1')
 m:SetAttribute('BlenderTemplateVersion',Architecture.version)
 for _,r in ipairs(rows)do
  local p=K.part(m,r[1],Vector3.new(table.unpack(r[4])),CFrame.new(table.unpack(r[6])),Color3.fromRGB(table.unpack(r[5])),Enum.Material[r[3]],r[2])
  if r[2]=='Cylinder'then p.Shape=Enum.PartType.Cylinder end
  p:SetAttribute('EpicDetailSolid',r[7]);p:SetAttribute('TLTSceneryDistance',700)
 end
 m.WorldPivot=CFrame.identity
 return m
end
return Architecture
