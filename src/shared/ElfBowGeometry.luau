-- Presentation geometry derived from the Blender bow model, in grip coordinates.
local Data=require(script.Parent.ElfBowClip).model
local Geometry={version=2}
local function vector(v) return Vector3.new(unpack(v)) end

function Geometry.valid(model,grip)
 local bow=model:FindFirstChild("Bow");local nock=grip:FindFirstChild("BowNock")
 if not bow or not nock or not nock:IsA("Attachment") or typeof(bow:GetAttribute("ElfBowRestSize"))~="Vector3" then return false end
 for _,name in ipairs({"Upper","Lower"}) do
  local tip=bow:FindFirstChild("BowString"..name);local beam=grip:FindFirstChild("BowStrand"..name)
  if not tip or not tip:IsA("Attachment") or not beam or not beam:IsA("Beam")
   or beam.Attachment0~=tip or beam.Attachment1~=nock then return false end
 end
 return true
end

function Geometry.install(model,grip)
 local bow=model:FindFirstChild("Bow")
 local arrow=model:FindFirstChild("NockedArrow")
 local sourceString=model:FindFirstChild("String")
 assert(bow and arrow and sourceString,"Elf bow source parts are missing")
 local joint=assert(arrow:FindFirstChild("NockedArrowVisualJoint"))
 arrow.Size=Vector3.new(arrow.Size.X,arrow.Size.Y,Data.arrowLength)
 arrow:SetAttribute("ElfArrowRestTransparency",arrow.Transparency)
 local nock=vector(Data.nock)
 joint.C0=CFrame.new(nock-Vector3.new(0,0,Data.arrowLength*.5))
 bow:SetAttribute("ElfBowRestSize",bow.Size)
 sourceString.Transparency=1
 sourceString:SetAttribute("TLTEquipmentRestTransparency",1)
 local middle=Instance.new("Attachment");middle.Name="BowNock";middle.Position=nock;middle.Parent=grip
 for _,name in ipairs({"Upper","Lower"}) do
  local tip=Instance.new("Attachment");tip.Name="BowString"..name
  tip.Position=bow.CFrame:PointToObjectSpace(vector(Data[string.lower(name)]));tip.Parent=bow
  tip:SetAttribute("ElfBowRestPosition",tip.Position)
  local beam=Instance.new("Beam");beam.Name="BowStrand"..name
  beam.Attachment0,beam.Attachment1=tip,middle
  beam.Width0,beam.Width1=Data.stringWidth,Data.stringWidth
  beam.FaceCamera=true;beam.Segments=1;beam.LightEmission=.05
  beam.Color=ColorSequence.new(Color3.fromRGB(208,189,143));beam.Parent=grip
 end
 model:SetAttribute("ElfBowRigVersion",Geometry.version)
end

function Geometry.pose(model,draw,visible)
 local bow=model:FindFirstChild("Bow");local grip=model:FindFirstChild("WeaponGrip") or model:FindFirstChild("Grip")
 local arrow=model:FindFirstChild("NockedArrow");local nock=grip and grip:FindFirstChild("BowNock")
 local joint=arrow and arrow:FindFirstChild("NockedArrowVisualJoint")
 if not bow or not nock or not joint then return false end
 local amount=math.clamp(draw or 0,0,1)
 local size=bow:GetAttribute("ElfBowRestSize")
 if typeof(size)~="Vector3" then return false end
 local height,depth=1+Data.heightFlex*amount,1+Data.depthFlex*amount
 bow.Size=Vector3.new(size.X,size.Y*height,size.Z*depth)
 nock.Position=vector(Data.nock)+Vector3.new(0,0,Data.drawDistance*amount)
 joint.Transform=CFrame.new(0,0,Data.drawDistance*amount)
 for _,name in ipairs({"Upper","Lower"}) do
  local tip=bow:FindFirstChild("BowString"..name)
  local beam=grip:FindFirstChild("BowStrand"..name)
  if tip then
   local p=tip:GetAttribute("ElfBowRestPosition")
   tip.Position=Vector3.new(p.X,p.Y*height,p.Z*depth)
  end
  if beam then beam.Enabled=visible~=false end
 end
 local muzzle=grip:FindFirstChild("WeaponTip")
 if muzzle then muzzle.Position=nock.Position-Vector3.new(0,0,Data.arrowLength) end
 return true
end
return Geometry
