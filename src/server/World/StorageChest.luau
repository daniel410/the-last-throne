local Geometry=require(game:GetService('ReplicatedStorage').Shared.StorageChestGeometry)
local Chest={}
function Chest.create(lobby)
 local model=Instance.new('Model');model.Name='DawnspireAccountStorage'
 model:SetAttribute('StorageVisualVersion','travel-chest-v1')
 local origin=lobby.origin+Vector3.new(12,0,24)
 local body
 for _,spec in ipairs(Geometry)do
  local value=Instance.new('Part');value.Name=spec.name
  value.Size=Vector3.new(table.unpack(spec.size))
  value.CFrame=CFrame.new(origin+Vector3.new(table.unpack(spec.position)))*CFrame.Angles(0,0,spec.angle)
  value.Color=Color3.fromRGB(table.unpack(spec.color));value.Material=Enum.Material[spec.material]
  value.Shape=Enum.PartType[spec.shape]
  value.Anchored=true;value.CanCollide=spec.solid;value.CanQuery=spec.solid;value.CanTouch=false
  value.TopSurface=Enum.SurfaceType.Smooth;value.BottomSurface=Enum.SurfaceType.Smooth
  value.Parent=model;if spec.name=='Chest'then body=value end
 end
 assert(body,'Storage chest requires its collision and interaction body')
 model.PrimaryPart=body
 local prompt=Instance.new('ProximityPrompt');prompt.Style=Enum.ProximityPromptStyle.Custom
 prompt.Name,prompt.ActionText,prompt.ObjectText='OpenAccountStorage','Open Storage','Dawnspire Storage'
 prompt.KeyboardKeyCode,prompt.GamepadKeyCode=Enum.KeyCode.F,Enum.KeyCode.ButtonX
 prompt.HoldDuration,prompt.MaxActivationDistance,prompt.RequiresLineOfSight=0,12,false
 prompt.Parent=body;model.Parent=lobby.folder
 return body,prompt
end
return Chest
