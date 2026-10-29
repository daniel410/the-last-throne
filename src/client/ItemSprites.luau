local Atlas=require(game:GetService("ReplicatedStorage").Shared.ItemSpriteAtlas)
local Sprites={}
function Sprites.create(parent,definition,position,size)
	if not Atlas.image then return nil end
	local key=definition.potionTier and definition.id or definition.slot=="weapon" and definition.classId.."_weapon"
		or Atlas.cells[definition.id] and definition.id or definition.slot
	local cell=Atlas.cells[key]
	if not cell then return nil end
	local image=Instance.new("ImageLabel")
	image.Name,image.BackgroundTransparency,image.Image="ItemIllustration",1,Atlas.image
	image.Position,image.Size,image.ScaleType=position,size,Enum.ScaleType.Fit
	local sx,sy=Atlas.renderWidth/Atlas.width,Atlas.renderHeight/Atlas.height
	local x,y=math.round(cell[1]*sx),math.round(cell[2]*sy)
	image.ImageRectOffset=Vector2.new(x,y)
	image.ImageRectSize=Vector2.new(math.round((cell[1]+cell[3])*sx)-x,math.round((cell[2]+cell[4])*sy)-y)
	image:SetAttribute("DefinitionId",definition.id)
	image:SetAttribute("SpriteKey",key)
	image.Parent=parent
	return image
end
return Sprites
