-- Shallow worked seam: a derivative of the existing braced basalt face.
-- No rescue state or personal obstruction is represented by this shared wall.
local K=require(script.Parent.EpicEnvironmentKit)
local M={version=1}
function M.build()
 local m=Instance.new('Model');m.Name='RescueWorkingSeam'
 m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute('SourceDerivative','RegionalArchitecture.BracedMineHead')
 local function part(name,size,pos,color,material,shape)
  local p=K.part(m,name,size,CFrame.new(pos),color,material,shape)
  p:SetAttribute('EpicDetailSolid',true);p:SetAttribute('TLTSceneryDistance',700)
  return p
 end
 -- One continuous backing closes seams; broad offset strata break the skyline.
 part('WorkedSeamBacking',Vector3.new(26,12,3),Vector3.new(0,5.7,-1),Color3.fromRGB(69,65,66),Enum.Material.Basalt)
 for i,r in ipairs({{-9,7,9,14},{-1,8,10,16},{8,6,10,12}})do
  local p=part('WorkedSeamStratum',Vector3.new(r[3],r[4],4),Vector3.new(r[1],r[2]-.3,-1),Color3.fromRGB(65+i*4,61+i*3,62+i*3),Enum.Material.Basalt,'Wedge')
  if i==2 then p.CFrame*=CFrame.Angles(0,math.pi,0)end
 end
 -- Permanent shoring faces the rescue; the interactable supports stay separate.
 for _,x in ipairs({-10,10})do
  part('SeamShoringPost',Vector3.new(1.8,12,1.8),Vector3.new(x,5.7,1.4),Color3.fromRGB(104,72,46),Enum.Material.Wood)
 end
 part('SeamShoringBearer',Vector3.new(24,1.8,1.8),Vector3.new(0,11,1.4),Color3.fromRGB(104,72,46),Enum.Material.Wood)
 m.WorldPivot=CFrame.identity
 return m
end
return M
