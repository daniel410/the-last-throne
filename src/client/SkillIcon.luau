-- One skill-ID lookup shared by the tree, loadout and combat HUD.
local ContentProvider = game:GetService("ContentProvider")
local Assets = require(game:GetService("ReplicatedStorage").Shared.SkillIconAssets)
local Icon = {}

local pending = {}
local checking = false

-- Roblox updates IsLoaded without firing its property signal.
local function checkImages()
	for image, fallback in pairs(pending) do
		if not image.Parent then
			pending[image] = nil
		elseif image.IsLoaded then
			fallback.Visible = false
			pending[image] = nil
		else
			local status = ContentProvider:GetAssetFetchStatus(image.Image)
			if status == Enum.AssetFetchStatus.Failure or status == Enum.AssetFetchStatus.TimedOut then
				pending[image] = nil
			end
		end
	end
	checking = next(pending) ~= nil
	if checking then task.delay(.1, checkImages) end
end

function Icon.create(parent, position, size)
	local image = Instance.new("ImageLabel")
	image.Name = "SkillIcon"
	image.Position, image.Size = position, size
	image.BackgroundTransparency = 1
	image.ScaleType = Enum.ScaleType.Fit
	image.ZIndex = parent.ZIndex + 1
	image.Visible = false

	local fallback = Instance.new("TextLabel")
	fallback.Name = "Fallback"
	fallback.Size = UDim2.fromScale(1, 1)
	fallback.BackgroundTransparency = 1
	fallback.Font = Enum.Font.GothamBold
	fallback.Text = ""
	fallback.TextScaled = true
	fallback.ZIndex = image.ZIndex
	fallback.Visible = false
	fallback.Parent = image

	local sizeLimit = Instance.new("UITextSizeConstraint")
	sizeLimit.MaxTextSize = 17
	sizeLimit.Parent = fallback

	image.Parent = parent
	return image
end

function Icon.set(image, definition, unlocked, cooling)
	local id = definition and definition.id
	local asset = Assets.byId[id] or ""
	local fallback = image.Fallback
	if image:GetAttribute("SkillId") ~= id then
		fallback.Text = definition and (definition.glyph or definition.name:sub(1, 2)) or ""
	end
	if image.Image ~= asset then
		image.Image = asset
		pending[image] = if asset ~= "" and not image.IsLoaded then fallback else nil
		if pending[image] and not checking then
			checking = true
			task.delay(.1, checkImages)
		end
	end
	image:SetAttribute("SkillId", id)
	image.Visible = id ~= nil
	image.ImageColor3 = unlocked and Color3.new(1, 1, 1) or Color3.fromRGB(115, 115, 115)
	image.ImageTransparency = cooling and .48 or 0
	fallback.TextColor3 = unlocked and Color3.fromRGB(255, 217, 143) or image.ImageColor3
	fallback.TextTransparency = image.ImageTransparency
	fallback.Visible = image.Visible and (asset == "" or not image.IsLoaded)
end

return Icon
