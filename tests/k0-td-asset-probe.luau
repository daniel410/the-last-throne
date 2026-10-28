-- Run only against an isolated, unpublished fixture place, never a TD place.
-- The fixture contains three MeshParts in ServerStorage and a unique marker.
-- ImageLabel instances probe image IDs separately, including the sword PBR maps.
-- Studio-owner preload is not proof of permission for a published RPG experience.
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

assert(game.PlaceId == 0, "Asset probe requires an unpublished local place")
assert(not RunService:IsRunning(), "Asset probe requires an idle isolated Studio")
assert(#Players:GetPlayers() == 0, "Asset probe must not run with players")

local fixture = assert(ServerStorage:FindFirstChild("TLTK0AssetProbeFixtures"), "Dedicated fixture folder missing")
local marker = fixture:FindFirstChild("ProbeMarker")
assert(marker and marker:IsA("StringValue") and marker.Value == "TLT-K0-ASSET-PROBE-20261028-5941",
	"Wrong fixture marker; refusing to run")
assert(#fixture:GetChildren() == 4, "Unexpected fixture contents")

local definitions = {
	{ name = "menu_atlas", kind = "ImageLabel", id = "98305074323052" },
	{ name = "battle_atlas", kind = "ImageLabel", id = "97570429280107" },
	{ name = "knight_icons", kind = "ImageLabel", id = "101027288850338" },
	{ name = "knight_sword", kind = "MeshPart", id = "78152429410586", fixture = "KnightSword" },
	{ name = "sword_color", kind = "ImageLabel", id = "129747040508630" },
	{ name = "sword_normal", kind = "ImageLabel", id = "123540236668043" },
	{ name = "sword_roughness", kind = "ImageLabel", id = "82984644200263" },
	{ name = "sword_metalness", kind = "ImageLabel", id = "123863432588878" },
	{ name = "goblin_body", kind = "MeshPart", id = "77403549111699", fixture = "GoblinBody" },
	{ name = "goblin_color", kind = "ImageLabel", id = "134919664038207" },
	{ name = "ogre_body", kind = "MeshPart", id = "98618217378067", fixture = "OgreBody" },
	{ name = "ogre_color", kind = "ImageLabel", id = "90412861785322" },
}

local function numericId(uri)
	return uri:match("rbxassetid://(%d+)") or uri:match("[?&]id=(%d+)")
end

local rows, threads = {}, {}
for _, definition in ipairs(definitions) do
	local row = { name = definition.name, kind = definition.kind, id = definition.id, callbacks = {}, done = false }
	table.insert(rows, row)
	local ok, value = pcall(function()
		if definition.kind == "MeshPart" then
			local item = assert(fixture:FindFirstChild(definition.fixture), "Fixture MeshPart missing")
			assert(item:IsA("MeshPart") and numericId(item.MeshId) == definition.id, "Fixture MeshId mismatch")
			return item
		end
		local image = Instance.new("ImageLabel")
		image.Name = definition.name
		image.Image = "rbxassetid://" .. definition.id
		image.Parent = fixture
		return image
	end)
	if not ok then
		row.error = tostring(value)
		row.done = true
	else
		threads[definition.name] = task.spawn(function()
			local preloadOk, preloadError = pcall(function()
				ContentProvider:PreloadAsync({ value }, function(uri, status)
					table.insert(row.callbacks, { uri = tostring(uri), status = tostring(status) })
				end)
			end)
			if not preloadOk then row.error = tostring(preloadError) end
			row.done = true
		end)
	end
end

local deadline = os.clock() + 30
while os.clock() < deadline do
	local allDone = true
	for _, row in ipairs(rows) do
		if not row.done then allDone = false; break end
	end
	if allDone then break end
	task.wait(0.1)
end

for _, row in ipairs(rows) do
	if not row.done then
		row.outcome = "timeout"
		if threads[row.name] then pcall(task.cancel, threads[row.name]) end
	elseif row.error then
		row.outcome = "error"
	else
		local matched = false
		local allSuccess = true
		for _, callback in ipairs(row.callbacks) do
			if numericId(callback.uri) == row.id then
				matched = true
				if callback.status ~= "Enum.AssetFetchStatus.Success" then allSuccess = false end
			end
		end
		if not matched then row.outcome = "missing_callback"
		elseif allSuccess then row.outcome = "success"
		else row.outcome = "failure" end
	end
end

local identityOk, identity = pcall(function()
	return game:GetService("StudioService"):GetUserId()
end)
local report = {
	kind = "TLT_K0_TD_ASSET_PRELOAD_PROBE",
	placeId = game.PlaceId,
	gameId = game.GameId,
	context = "isolated Studio edit; no published RPG client",
	results = rows,
}
if identityOk then report.studioUserId = identity else report.identityError = tostring(identity) end
print("TLT_K0_TD_ASSET_PRELOAD_PROBE " .. HttpService:JSONEncode(report))
fixture:Destroy()
