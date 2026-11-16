-- One skill-ID lookup shared by the tree, loadout and combat HUD.
local Assets = require(game:GetService("ReplicatedStorage").Shared.SkillIconAssets)
local Icon = {}

function Icon.create(parent, position, size)
	local image = Instance.new("ImageLabel")
	image.Name = "SkillIcon"
	image.Position, image.Size = position, size
	image.BackgroundTransparency = 1
	image.ScaleType = Enum.ScaleType.Fit
	image.ZIndex = parent.ZIndex + 1
	image.Visible = false
	image.Parent = parent
	return image
end

function Icon.set(image, definition, unlocked, cooling)
	local id = definition and definition.id
	local asset = id and Assets.byId[id]
	if image.Image ~= (asset or "") then image.Image = asset or "" end
	image:SetAttribute("SkillId", id)
	image.Visible = asset ~= nil
	image.ImageColor3 = unlocked and Color3.new(1, 1, 1) or Color3.fromRGB(115, 115, 115)
	image.ImageTransparency = cooling and .48 or 0
	return image.Visible
end

return Icon
