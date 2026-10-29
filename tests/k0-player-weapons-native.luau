-- Independent native fixture QA; run only in an isolated local place:
-- run-in-roblox --place <fixed local build> --script tests/k0-player-weapons-native.luau
-- Native R6/R15 rigs, production adapters and actual MeshPart/SurfaceAppearance.
-- Character lifecycle signals are explicit fixtures; the original client render
-- API is called manually. This is not real Player input/GPU/PBR acceptance or
-- published permissions, gameplay for three unimplemented classes or device QA.
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local ContentProvider = game:GetService("ContentProvider")
local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

assert(game.PlaceId == 0, "Weapon fixture requires an unpublished isolated local place")
assert(not workspace:FindFirstChild("K0PlayerWeaponsQaFixture"), "Weapon QA fixture already exists")
local report = { kind = "K0_PLAYER_WEAPONS_NATIVE", checks = 0, cases = {}, failures = {}, assetLoads = {},
	players = #Players:GetPlayers(), rigFactory = {},
	coverage = "Native R6/R15 fixture attachment and source preservation; native lifecycle signals with identity fixtures; production client render/renderCharacter APIs called manually",
	classBindingCoverage = "K0ClassId is set at the native fixture's server-attribute boundary and observed by production lifecycle code; actual CombatService resolver/network replication is tested separately",
	limits = "No real Player class selection, death/spawn authority, client rendering, network transport, published asset permissions, device/performance or new class combat acceptance",
	shieldCoverage = "Reviewed shield Mesh/Texture IDs, native left socket, source immutability, recovery and explicit missing-source fallback; real client rendering/permissions are separate" }
local EXPECTED = {
	knight = { template = "KnightSword", sourceKey = "td:KnightSword", meshes = { Weapon = "130169610186060" }, texture = "97596525220590" },
	dwarf = { template = "DwarfAxe", sourceKey = "td:DwarfAxe", meshes = { Weapon = "106045080642382" }, maps = {
		ColorMap = "79341687829464", NormalMap = "98465383428887", RoughnessMap = "117012167040323", MetalnessMap = "72615572473617" } },
	elf = { template = "ElfBow", sourceKey = "td:ElfBow", meshes = {
		Bow = "83795343518288", String = "108052120766619", NockedArrow = "77202496614276" }, maps = {
		ColorMap = "115101390772936", RoughnessMap = "105500976380479", MetalnessMap = "110003398368829" } },
	mage = { sourceKey = "authored:WoodenStaff" },
}
local fixture, templates, shieldTemplates, appearance, staffBuilder, lifecycle, clientVisual, sourceSnapshot
local privateModules, eventObjects, fakePlayers, connections = {}, {}, {}, {}
local rigs, buildModels, preloadParts = {}, {}, {}
local origin = Vector3.new(300, 100, 300)

local function check(condition, label)
	report.checks += 1
	assert(condition, label)
end
local function near(a, b, epsilon, label)
	check(math.abs(a - b) <= epsilon, label .. ": expected " .. tostring(b) .. ", actual " .. tostring(a))
end
local function frameNear(a, b, label)
	local delta = a:ToObjectSpace(b)
	check(delta.Position.Magnitude <= 0.002, label .. " position")
	local _, angle = delta:ToAxisAngle()
	check(math.abs(angle) <= 0.001, label .. " rotation")
end
local function waitFor(predicate, seconds)
	local deadline = os.clock() + seconds
	repeat
		local result = predicate()
		if result then return result end
		task.wait(0.05)
	until os.clock() >= deadline
	return nil
end
local function case(id, callback)
	local before = report.checks
	local ok, message = xpcall(callback, debug.traceback)
	table.insert(report.cases, { id = id, pass = ok, checks = report.checks - before, error = not ok and tostring(message) or nil })
	if not ok then table.insert(report.failures, id .. ": " .. tostring(message)) end
end
local function numericId(uri)
	return tostring(uri):match("rbxassetid://(%d+)") or tostring(uri):match("[?&]id=(%d+)")
end
local function parts(model, className)
	local values = {}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA(className or "BasePart") then table.insert(values, item) end
	end
	return values
end
local function inert(model, label)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			check(not item.Anchored and item.Massless and not item.CanCollide and not item.CanTouch and not item.CanQuery,
				label .. " inert visual " .. item.Name)
		elseif item:IsA("LuaSourceContainer") then check(false, label .. " cannot import executable content") end
	end
end
local function sourceProperties(item)
	local values = { Name = item.Name, Parent = item.Parent, Archivable = item.Archivable }
	if item:IsA("Model") then values.PrimaryPart = item.PrimaryPart end
	if item:IsA("BasePart") then
		for _, key in ipairs({ "Size", "CFrame", "Color", "Material", "Transparency", "Reflectance", "Anchored", "Massless", "CanCollide", "CanTouch", "CanQuery" }) do values[key] = item[key] end
	end
	if item:IsA("MeshPart") then values.MeshId, values.TextureID = item.MeshId, item.TextureID end
	if item:IsA("SurfaceAppearance") then
		for _, key in ipairs({ "ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap", "AlphaMode" }) do values[key] = item[key] end
	end
	if item:IsA("Attachment") then values.CFrame = item.CFrame end
	if item:IsA("ValueBase") then values.Value = item.Value end
	return values
end
local function captureSources()
	local snapshot = {}
	for _, library in ipairs({ templates, shieldTemplates }) do
		local list = library:GetDescendants()
		table.insert(list, library)
		for _, item in ipairs(list) do snapshot[item] = { root = library, properties = sourceProperties(item), attributes = item:GetAttributes() } end
	end
	return snapshot
end
local function sourcesUnchanged()
	local count = 2 + #templates:GetDescendants() + #shieldTemplates:GetDescendants()
	local captured = 0
	for item, record in pairs(sourceSnapshot) do
		captured += 1
		check(item == record.root or item:IsDescendantOf(record.root), "source instance remains in original library: " .. record.properties.Name)
		for key, value in pairs(record.properties) do check(item[key] == value, "source property unchanged: " .. record.properties.Name .. "." .. key) end
		local current = item:GetAttributes()
		for key, value in pairs(record.attributes) do check(current[key] == value, "source attribute unchanged: " .. key); current[key] = nil end
		check(next(current) == nil, "source has no new attributes: " .. record.properties.Name)
	end
	check(captured == count, "source library has no inserted/removed instances")
end
local function verifyShield(result, character)
	local source = assert(shieldTemplates:FindFirstChild("KnightShield"))
	local original = assert(source:FindFirstChild("Shield"))
	local shield, grip = result.shield, result.grip
	check(result.sourceKey == "td:SwordsmanShield", "shield explicit original source key")
	check(shield and shield:IsA("MeshPart") and numericId(shield.MeshId) == "86935256146675", "reviewed shield actual native MeshId")
	check(numericId(shield.TextureID) == "97596525220590" and shield.TextureID == original.TextureID, "shield keeps original TD color texture")
	check(shield:FindFirstChildOfClass("SurfaceAppearance") == nil and original:FindFirstChildOfClass("SurfaceAppearance") == nil, "shield does not invent a PBR replacement")
	check(shield.Size == original.Size, "shield keeps canonical size without another scale")
	frameNear(grip.CFrame:ToObjectSpace(shield.CFrame), source.PrimaryPart.CFrame:ToObjectSpace(original.CFrame), "shield source grip-relative transform")
	near(original.Size.X, 1.8906252384, 0.00001, "shield pinned width")
	near(original.Size.Y, 1.8785308599, 0.00001, "shield pinned height")
	near(original.Size.Z, 0.4970029891, 0.00001, "shield pinned depth")
	near(original.CFrame.Position.Z, -0.2485014851, 0.00001, "native shield center is behind origin along -Z")
	frameNear(original.CFrame.Rotation, CFrame.new(), "native -Z shield has no extra yaw180")
	local socket = grip:FindFirstChild("GripSocket")
	check(socket and socket:IsA("Attachment"), "shield native GripSocket preserved")
	frameNear(socket.CFrame, source.PrimaryPart.GripSocket.CFrame, "shield original socket")
	local weld = shield:FindFirstChild("ShieldVisualWeld")
	check(weld and weld:IsA("WeldConstraint") and weld.Part0 == grip and weld.Part1 == shield, "shield visual welded to independent grip")
	for _, item in ipairs({ grip, shield }) do
		check(not item.Anchored and item.Massless and not item.CanCollide and not item.CanTouch and not item.CanQuery, "shield inert visual " .. item.Name)
	end
	if character then
		local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
		local left = assert(character:FindFirstChild(humanoid.RigType == Enum.HumanoidRigType.R15 and "LeftHand" or "Left Arm"))
		local handWeld = grip:FindFirstChild("K0ShieldHandWeld")
		check(handWeld and handWeld:IsA("WeldConstraint") and handWeld.Part0 == left and handWeld.Part1 == grip, "native shield follows current left hand")
		local expected = CFrame.new(-left.Size.X / 2 - 0.02, left.Name == "Left Arm" and -0.65 or 0, 0)
			* CFrame.Angles(0, math.rad(90), 0)
		frameNear(left.CFrame:ToObjectSpace(grip.CFrame), expected, "shield socket remains at the outer hand with its face turned left")
		check(result.model:GetAttribute("UsesTdPlayerShield") == true and result.model:GetAttribute("ShieldSourceKey") == "td:SwordsmanShield", "native shield success is explicit; no fallback")
		check(result.model:GetAttribute("ShieldFallbackReason") == nil, "successful shield has no stale fallback reason")
	end
end
local function observedShield(model)
	return { model = model, grip = assert(model:FindFirstChild("ShieldGrip")), shield = assert(model:FindFirstChild("Shield")), sourceKey = model:GetAttribute("ShieldSourceKey") }
end
local function verifyMeshes(result, classId)
	local spec = EXPECTED[classId]
	check(result.sourceKey == spec.sourceKey, classId .. " explicit source identity")
	if classId == "mage" then
		check(#parts(result.model, "MeshPart") == 0, "new staff does not silently reuse a TD mesh")
		check(result.tip and result.tip:IsA("Attachment") and result.tip.Parent == result.grip, "new staff tip socket")
		check(result.tip.Position.Y > 0, "new staff tip above grip")
		local shaft = result.model:FindFirstChild("WoodenShaft", true)
		check(shaft and shaft:IsA("BasePart") and shaft.Material == Enum.Material.Wood, "new staff has authored wooden shaft")
		return
	end
	local source = assert(templates:FindFirstChild(spec.template))
	local sourceGrip = assert(source:FindFirstChild("Grip"))
	local found = {}
	for _, part in ipairs(parts(result.model, "MeshPart")) do
		local name = part:GetAttribute("SourcePartName")
		check(spec.meshes[name] ~= nil and not found[name], classId .. " unique original part " .. tostring(name))
		found[name] = true
		local original = assert(source:FindFirstChild(name))
		check(numericId(part.MeshId) == spec.meshes[name] and part.MeshId == original.MeshId, classId .. "." .. name .. " original MeshId")
		check(part.TextureID == original.TextureID, classId .. "." .. name .. " original TextureID")
		check(part.Size == original.Size, classId .. "." .. name .. " no second scale")
		frameNear(result.grip.CFrame:ToObjectSpace(part.CFrame), sourceGrip.CFrame:ToObjectSpace(original.CFrame), classId .. "." .. name .. " no second import transform")
		local surface, originalSurface = part:FindFirstChildOfClass("SurfaceAppearance"), original:FindFirstChildOfClass("SurfaceAppearance")
		check((surface ~= nil) == (originalSurface ~= nil), classId .. "." .. name .. " original SurfaceAppearance presence")
		if spec.maps then
			check(surface ~= nil, classId .. "." .. name .. " native SurfaceAppearance exists")
			for _, key in ipairs({ "ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap" }) do
				check(surface[key] == originalSurface[key], classId .. "." .. name .. " preserves " .. key)
				if spec.maps[key] then check(numericId(surface[key]) == spec.maps[key], classId .. "." .. name .. " pinned " .. key)
				else check(surface[key] == "", classId .. "." .. name .. " no invented " .. key) end
			end
			check(surface.AlphaMode == originalSurface.AlphaMode, classId .. "." .. name .. " original alpha mode")
		else check(numericId(part.TextureID) == spec.texture, classId .. "." .. name .. " pinned source texture") end
	end
	for name in pairs(spec.meshes) do check(found[name], classId .. " includes " .. name) end
	local socket = result.grip:FindFirstChild("GripSocket")
	check(socket and socket:IsA("Attachment"), classId .. " copied native GripSocket")
	frameNear(socket.CFrame, sourceGrip.GripSocket.CFrame, classId .. " source socket preserved")
	local tipMarker = source:FindFirstChild("WeaponTip") or source:FindFirstChild("WeaponTipPosition")
	if tipMarker and tipMarker:IsA("Vector3Value") then
		check(result.tip and result.tip:IsA("Attachment") and result.tip.Parent == result.grip, classId .. " source tip becomes native attachment")
		check((result.tip.Position - sourceGrip.CFrame:PointToObjectSpace(tipMarker.Value)).Magnitude <= 0.00001, classId .. " source tip coordinate preserved")
	end
end
local function cloneRig(rigName, suffix)
	local model = assert(rigs[rigName], rigName .. " engine fixture unavailable"):Clone()
	model.Name = rigName .. "_" .. suffix
	model.Parent = fixture
	model:PivotTo(CFrame.new(origin + Vector3.new(#fixture:GetChildren() * 7, 0, 0)))
	for _, part in ipairs(parts(model)) do part.CanCollide = false end
	local root = assert(model:FindFirstChild("HumanoidRootPart"))
	root.Anchored = true
	return model
end
local function handsFor(character)
	local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
	local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
	return { right = assert(character:FindFirstChild(isR15 and "RightHand" or "Right Arm")),
		left = assert(character:FindFirstChild(isR15 and "LeftHand" or "Left Arm")) }
end
local function owned(character)
	local list = {}
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("TLT_K0_KnightAppearance") == true then table.insert(list, child) end
	end
	return list
end
local function preload()
	local requests, images = {}, {}
	for classId, result in pairs(buildModels) do
		for _, part in ipairs(parts(result.model, "MeshPart")) do
			table.insert(requests, { name = classId .. "." .. part.Name, instance = part, expected = { numericId(part.MeshId) }, kind = "actual MeshPart" })
			if part.TextureID ~= "" then images[numericId(part.TextureID)] = true end
			local surface = part:FindFirstChildOfClass("SurfaceAppearance")
			if surface then
				for _, key in ipairs({ "ColorMap", "NormalMap", "RoughnessMap", "MetalnessMap" }) do
					if surface[key] ~= "" then images[numericId(surface[key])] = true end
				end
			end
		end
	end
	for id in pairs(images) do
		local image = Instance.new("ImageLabel")
		image.Name = "QA_Map_" .. id
		image.Image = "rbxassetid://" .. id
		image.Parent = fixture
		table.insert(requests, { name = image.Name, instance = image, expected = { id }, kind = "explicit image dependency; PBR rendering not tested" })
	end
	check(#requests == 14, "six source meshes including shield plus eight unique texture/PBR images")
	local threads = {}
	for _, request in ipairs(requests) do
		local row = { name = request.name, kind = request.kind, callbacks = {}, expected = request.expected, done = false }
		table.insert(report.assetLoads, row)
		threads[row] = task.spawn(function()
			local ok, message = pcall(function()
				-- Actual MeshParts retain their native SurfaceAppearance. Explicit
				-- image requests verify each map without claiming shader/GPU load.
				ContentProvider:PreloadAsync({ request.instance }, function(uri, status)
					table.insert(row.callbacks, { uri = tostring(uri), id = numericId(uri), status = tostring(status) })
				end)
			end)
			if not ok then row.error = tostring(message) end
			row.done = true
		end)
	end
	waitFor(function() for _, row in ipairs(report.assetLoads) do if not row.done then return false end end; return true end, 45)
	for _, row in ipairs(report.assetLoads) do
		local successful, failed = {}, false
		for _, callback in ipairs(row.callbacks) do
			if callback.id then
				if callback.status == "Enum.AssetFetchStatus.Success" then successful[callback.id] = true else failed = true end
			end
		end
		if not row.done then row.outcome = "timeout"; pcall(task.cancel, threads[row])
		elseif row.error then row.outcome = "error"
		elseif failed then row.outcome = "failure"
		else
			row.outcome = "success"
			for _, id in ipairs(row.expected) do if not successful[id] then row.outcome = "missing_callback" end end
		end
	end
	for _, row in ipairs(report.assetLoads) do check(row.outcome == "success", "preload " .. row.name .. ": " .. row.outcome) end
end

local ok, fatal = xpcall(function()
	local cosmetics = assert(ServerScriptService:FindFirstChild("Server")):FindFirstChild("Cosmetics")
	assert(cosmetics, "Cosmetics modules missing")
	templates = assert(ServerStorage:FindFirstChild("TDPlayerWeaponModels"), "actual TD weapon runtime missing")
	shieldTemplates = assert(ServerStorage:FindFirstChild("TDKnightShieldModels"), "reviewed native shield runtime missing")
	appearance = require(assert(cosmetics:FindFirstChild("WeaponAppearance")))
	staffBuilder = require(assert(cosmetics:FindFirstChild("WoodenStaffBuilder")))
	sourceSnapshot = captureSources()
	fixture = Instance.new("Folder")
	fixture.Name = "K0PlayerWeaponsQaFixture"
	fixture.Parent = workspace

	-- Ask the engine for real rig types, not a hand-name-only mock. Factory
	-- failures/timeouts are test failures and are never replaced by fake rigs.
	local factoryThreads, factoryRows = {}, {}
	for _, rigType in ipairs({ Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15 }) do
		local row = { rig = rigType.Name, done = false }
		table.insert(factoryRows, row)
		factoryThreads[row] = task.spawn(function()
			local description = Instance.new("HumanoidDescription")
			local success, model = pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(description, rigType) end)
			description:Destroy()
			if success then
				model.Name = "QaRigTemplate_" .. rigType.Name
				model.Archivable = true
				model.Parent = fixture
				rigs[rigType.Name] = model
			else row.error = tostring(model) end
			row.done = true
		end)
	end
	waitFor(function() for _, row in ipairs(factoryRows) do if not row.done then return false end end; return true end, 45)
	for _, row in ipairs(factoryRows) do
		if not row.done then pcall(task.cancel, factoryThreads[row]); row.error = "45-second rig factory timeout" end
		table.insert(report.rigFactory, row)
		check(row.done and not row.error and rigs[row.rig] ~= nil, "native " .. row.rig .. " factory: " .. tostring(row.error))
		check(rigs[row.rig]:FindFirstChildOfClass("Humanoid").RigType.Name == row.rig, row.rig .. " engine rig identity")
		for _, part in ipairs(parts(rigs[row.rig])) do part.Anchored = true; part.CanCollide = false end
	end

	for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
		case("build-" .. classId, function()
			local result, reason = appearance.build(classId)
			check(result ~= nil, classId .. " build must not fall back: " .. tostring(reason))
			check(result.model:IsA("Model") and result.model.Parent == nil and result.grip:IsA("BasePart"), classId .. " independent model/grip result")
			result.model.Parent = fixture
			buildModels[classId] = result
			inert(result.model, classId)
			verifyMeshes(result, classId)
		end)
	end
	case("build-reviewed-shield-with-original-native-properties", function()
		local result, reason = appearance.buildShield()
		check(result ~= nil, "reviewed shield build: " .. tostring(reason))
		check(result.model.Parent == nil and result.model.PrimaryPart == result.grip, "shield builder returns independent grip-origin model")
		result.model.Parent = fixture
		buildModels.shield = result
		verifyShield(result)
		inert(result.model, "reviewed shield")
	end)
	case("actual-mesh-and-image-preload", preload)
	for _, rigName in ipairs({ "R6", "R15" }) do
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage" }) do
			case("attach-" .. rigName .. "-" .. classId, function()
				local character = cloneRig(rigName, classId)
				local model = Instance.new("Model")
				model.Name = "QaWeaponAppearance"
				model.Parent = character
				local unrelated = Instance.new("Part")
				unrelated.Name = "ExistingUserEquipment"
				unrelated.Anchored = false
				unrelated.Massless = true
				unrelated.CanCollide, unrelated.CanTouch, unrelated.CanQuery = false, false, false
				unrelated.Parent = model
				local hands = handsFor(character)
				local result, reason = appearance.attachInto(model, character, classId, hands)
				check(result ~= nil, "attachInto: " .. tostring(reason))
				check(result.model == model and result.joint and result.joint:IsA("Motor6D"), "existing appearance container and native joint")
				check(result.joint.Part0 == (classId == "elf" and hands.left or hands.right) and result.joint.Part1 == result.grip, "declared class-specific hand socket")
				frameNear(result.joint.Part0.CFrame * result.joint.C0, result.joint.Part1.CFrame * result.joint.C1, "hand/grip socket closure")
				if classId == "knight" then
					local bladeAxis = result.joint.C0.UpVector
					check(bladeAxis.Y > 0.85 and bladeAxis.Z < -0.45 and math.abs(bladeAxis.X) < 0.01,
						"Knight sword stands upright and tilts forward from the hand")
				elseif classId == "dwarf" then
					check(result.joint.C0.UpVector.Z < -0.5, "Dwarf axe shaft tilts forward from the hand")
				end
				inert(model, rigName .. "/" .. classId)
				verifyMeshes(result, classId)
				local count = #model:GetDescendants()
				local again, repeatedReason = appearance.attachInto(model, character, classId)
				check(again ~= nil, "automatic rig-hand selection: " .. tostring(repeatedReason))
				check(again.grip == result.grip and again.joint == result.joint and #model:GetDescendants() == count, "idempotent repeated attach without duplicate parts/joints")
				check(unrelated.Parent == model, "unowned equipment survives repeat attach")
			end)
		end
		case("attach-reviewed-shield-" .. rigName, function()
			local character = cloneRig(rigName, "reviewedShield")
			local model = Instance.new("Model")
			model.Name, model.Parent = "QaCombinedEquipment", character
			local external = Instance.new("Folder")
			external.Name, external.Parent = "UserShieldDecoration", model
			local sword, swordReason = appearance.attachInto(model, character, "knight")
			check(sword ~= nil, "shield fixture retains original sword: " .. tostring(swordReason))
			local result, reason = appearance.attachShieldInto(model, character, handsFor(character))
			check(result ~= nil, "reviewed shield attach: " .. tostring(reason))
			verifyShield(result, character)
			check(appearance.isShieldAttached(model, character), "adapter recognizes complete reviewed shield")
			check(appearance.isAttached(model, character, "knight"), "shield does not damage independent sword ownership")
			local count = #model:GetDescendants()
			local again = assert(appearance.attachShieldInto(model, character))
			check(again.grip == result.grip and again.shield == result.shield and #model:GetDescendants() == count, "repeated shield attach is idempotent")
			local rejected, rejectedReason = appearance.attachShieldInto(model, character, { left = handsFor(character).right })
			check(rejected == nil and rejectedReason == "left_hand_not_ready", "caller cannot substitute right hand for shield hand")
			check(appearance.isShieldAttached(model, character), "rejected hand leaves valid shield intact")
			check(appearance.detachShield(model), "owned shield can be detached")
			check(not appearance.isShieldAttached(model, character) and result.grip.Parent == nil and result.shield.Parent == nil, "detach removes only owned shield")
			check(external.Parent == model and sword.grip.Parent == model and appearance.isAttached(model, character, "knight"), "shield detach preserves unrelated equipment and sword")
			check(model:GetAttribute("ShieldSourceKey") == nil and model:GetAttribute("UsesTdPlayerShield") == nil, "detach clears shield source state")
			verifyMeshes(sword, "knight")
			local restored = assert(appearance.attachShieldInto(model, character))
			check(restored.grip ~= result.grip and restored.shield ~= result.shield, "explicit reattach clones fresh reviewed shield")
			verifyShield(restored, character)
		end)
	end
	case("fixture-class-switch-and-partial-damage-rebuild", function()
		local character = cloneRig("R15", "classPreviewOnly")
		local model = Instance.new("Model")
		model.Name, model.Parent = "QaClassPreviewAppearance", character
		local unrelated = Instance.new("Folder")
		unrelated.Name, unrelated.Parent = "ExistingUserEquipment", model
		for _, classId in ipairs({ "knight", "elf", "dwarf", "mage", "knight" }) do
			local result, reason = appearance.attachInto(model, character, classId)
			check(result ~= nil, "fixture class preview: " .. tostring(reason))
			check(appearance.isAttached(model, character, classId), "adapter recognizes complete attached " .. classId)
			verifyMeshes(result, classId)
			check(unrelated.Parent == model, "fixture replacement preserves unowned content")
		end
		local elf, reason = appearance.attachInto(model, character, "elf")
		check(elf ~= nil, "elf damage fixture: " .. tostring(reason))
		model:FindFirstChild("NockedArrow"):Destroy()
		check(not appearance.isAttached(model, character, "elf"), "missing original part is not reported attached")
		local repaired, repairReason = appearance.attachInto(model, character, "elf")
		check(repaired ~= nil, "damaged appearance rebuild: " .. tostring(repairReason))
		check(repaired.grip ~= elf.grip, "damage rebuild creates fresh owned weapon")
		verifyMeshes(repaired, "elf")
		check(unrelated.Parent == model, "damage rebuild preserves unowned content")
	end)
	case("unsupported-class-is-not-a-player-class", function()
		local result, reason = appearance.build("priest")
		check(result == nil and reason == "unsupported_class", "Priest is not silently mapped to a playable class")
	end)
	case("wooden-staff-builder-independent-and-fresh", function()
		local first, second = staffBuilder.build(), staffBuilder.build()
		check(first ~= second and first.Parent == nil and second.Parent == nil, "staff builder returns fresh unparented models")
		first.Parent, second.Parent = fixture, fixture
		check(first.PrimaryPart and first.PrimaryPart.Name == "Grip" and first.PrimaryPart.CFrame == CFrame.new(), "authored staff grip origin")
		check(first:GetAttribute("SourceKind") == "AuthoredWoodenStaff", "authored staff source identity")
		check(first.PrimaryPart:FindFirstChild("WeaponTip"):IsA("Attachment"), "staff native tip")
		check(#parts(first, "MeshPart") == 0, "wooden staff has no external mesh dependency")
		inert(first, "wooden staff")
		first:Destroy(); second:Destroy()
	end)

	-- Expose lifecycle functions only in a private copy. Native BindableEvent
	-- signals represent CharacterAdded/Removing; no real Player is fabricated.
	local originalLifecycle = assert(cosmetics:FindFirstChild("KnightAppearance")).Source
	local lifecycleSource, count = originalLifecycle:gsub("\nreturn KnightAppearance%s*$", "\nreturn {bind=bindPlayer,unbind=unbindPlayer,sync=syncAppearance,bindings=bindings}\n")
	assert(count == 1, "KnightAppearance return boundary changed")
	local module = Instance.new("ModuleScript")
	module.Name, module.Source, module.Parent = "QaKnightLifecyclePrivate", lifecycleSource, cosmetics
	table.insert(privateModules, module)
	lifecycle = require(module)
	for _, rigName in ipairs({ "R6", "R15" }) do
		case("knight-native-lifecycle-" .. rigName, function()
			local first = cloneRig(rigName, "firstLife")
			first:SetAttribute("K0ClassId", "knight")
			local unrelated = Instance.new("Model")
			unrelated.Name = "TLT_K0_KnightAppearance"
			unrelated.Parent = first
			local tool = Instance.new("Tool")
			tool.Name, tool.RequiresHandle, tool.Parent = "ExistingEquipment", false, first
			local added, removing = Instance.new("BindableEvent"), Instance.new("BindableEvent")
			table.insert(eventObjects, added); table.insert(eventObjects, removing)
			local player = { Character = first, CharacterAdded = added.Event, CharacterRemoving = removing.Event }
			table.insert(fakePlayers, player)
			lifecycle.bind(player); lifecycle.bind(player)
			check(waitFor(function() return #owned(first) == 1 end, 2), "first life attaches exactly once")
			local visual = owned(first)[1]
			check(visual:GetAttribute("UsesTdPlayerWeapon") == true and visual:GetAttribute("WeaponSourceKey") == "td:KnightSword", "actual TD source, no temporary fallback")
			local hand = handsFor(first)
			check(visual:FindFirstChild("SwordBlade"):IsA("MeshPart"), "lifecycle uses actual sword mesh")
			verifyShield(observedShield(visual), first)
			check(visual:GetAttribute("TemporaryVisual") == false, "reviewed sword and shield do not claim a temporary visual")
			check(unrelated.Parent == first and tool.Parent == first, "unowned same-name model and Tool preserved")
			lifecycle.sync(first)
			check(#owned(first) == 1 and owned(first)[1] == visual, "repeated lifecycle sync is idempotent")
			-- Do not call sync here: exercise the production DescendantRemoving
			-- observer and deferred repair after each real engine part deletion.
			for _, name in ipairs({ "Shield", "ShieldGrip", "SwordBlade", "SwordGrip" }) do
				local previous = owned(first)[1]
				assert(previous:FindFirstChild(name)):Destroy()
				check(waitFor(function()
					local list = owned(first)
					return #list == 1 and list[1] ~= previous and appearance.isAttached(list[1], first, "knight") and appearance.isShieldAttached(list[1], first)
				end, 2), "observer automatically repairs missing " .. name)
				visual = owned(first)[1]
				verifyShield(observedShield(visual), first)
				check(previous.Parent == nil and unrelated.Parent == first and tool.Parent == first, "repair replaces owned model only: " .. name)
			end
			local oldLeft = hand.left
			local replacement = oldLeft:Clone()
			replacement.CFrame = oldLeft.CFrame
			for _, motor in ipairs(first:GetDescendants()) do
				if motor:IsA("Motor6D") and motor.Part1 == oldLeft and not motor:IsDescendantOf(oldLeft) then motor.Part1 = replacement end
			end
			oldLeft.Parent = nil
			check(waitFor(function() return #owned(first) == 0 end, 2), "missing shield hand removes owned appearance")
			replacement.Parent = first
			check(waitFor(function() return #owned(first) == 1 end, 2), "replacement left hand restores owned appearance")
			verifyShield(observedShield(owned(first)[1]), first)
			check(owned(first)[1]:FindFirstChild("K0ShieldHandWeld", true).Part0 == replacement, "shield weld follows replacement left-hand identity")
			oldLeft:Destroy()
			local right = hand.right
			right.Parent = nil
			check(waitFor(function() return #owned(first) == 0 end, 2), "missing hand removes owned appearance")
			right.Parent = first
			check(waitFor(function() return #owned(first) == 1 end, 2), "late hand restores appearance")
			local oldLife = owned(first)[1]
			oldLife:FindFirstChild("Shield"):Destroy()
			removing:Fire(first)
			check(waitFor(function() return lifecycle.bindings[player].character == nil end, 2), "old life disconnects before deferred recovery")
			task.wait(0.05)
			check(#owned(first) == 1 and owned(first)[1] == oldLife and oldLife:FindFirstChild("Shield") == nil, "pending old-life shield repair cannot run after CharacterRemoving")
			oldLife:Destroy()
			task.wait(0.05)
			check(#owned(first) == 0, "old character does not resurrect removed equipment")
			local second = cloneRig(rigName, "respawnLife")
			second:SetAttribute("K0ClassId", "knight")
			player.Character = second
			added:Fire(second)
			check(waitFor(function() return #owned(second) == 1 end, 2), "respawn event attaches fresh owned appearance")
			local respawnVisual = owned(second)[1]
			check(respawnVisual ~= oldLife and respawnVisual:FindFirstChild("SwordBlade"):IsA("MeshPart"), "respawn clones fresh TD mesh")
			verifyShield(observedShield(respawnVisual), second)
			respawnVisual:FindFirstChild("ShieldGrip"):Destroy()
			lifecycle.unbind(player)
			task.wait(0.05)
			check(#owned(second) == 1 and owned(second)[1] == respawnVisual and respawnVisual:FindFirstChild("ShieldGrip") == nil, "pending repair cannot run after player unbind")
			local third = cloneRig(rigName, "afterLeave")
			third:SetAttribute("K0ClassId", "knight")
			player.Character = third; added:Fire(third)
			task.wait(0.05)
			check(#owned(third) == 0, "unbind disconnects future character events")
		end)
	end
	case("missing-shield-source-is-explicit-and-keeps-original-sword", function()
		-- Point a private copy of the real adapter at an isolated namespace.
		-- The production source library is never moved, deleted or edited.
		local isolatedStorage = Instance.new("Folder")
		isolatedStorage.Name, isolatedStorage.Parent = "QaMissingShieldStorage", fixture
		templates:Clone().Parent = isolatedStorage
		local original = assert(cosmetics:FindFirstChild("WeaponAppearance")).Source
		local adapterSource, replacements = original:gsub('local ServerStorage = game:GetService%("ServerStorage"%)', 'local ServerStorage = script.QaStorage.Value', 1)
		check(replacements == 1, "private negative fixture changes only adapter storage dependency")
		local adapterModule = Instance.new("ModuleScript")
		adapterModule.Name, adapterModule.Source, adapterModule.Parent = "QaMissingShieldAdapter", adapterSource, cosmetics
		table.insert(privateModules, adapterModule)
		local storageRef = Instance.new("ObjectValue")
		storageRef.Name, storageRef.Value, storageRef.Parent = "QaStorage", isolatedStorage, adapterModule
		local isolatedAdapter = require(adapterModule)
		local missing, missingReason = isolatedAdapter.buildShield()
		check(missing == nil and type(missingReason) == "string" and missingReason:find("TDKnightShieldModels", 1, true), "missing reviewed source produces a visible reason")
		local privateSource, requires = lifecycleSource:gsub('require%(script%.Parent%.WeaponAppearance%)', 'require(script.QaWeapon.Value)', 1)
		check(requires == 1, "negative lifecycle fixture redirects only adapter dependency")
		local privateLifecycle = Instance.new("ModuleScript")
		privateLifecycle.Name, privateLifecycle.Source, privateLifecycle.Parent = "QaMissingShieldLifecycle", privateSource, cosmetics
		table.insert(privateModules, privateLifecycle)
		local adapterRef = Instance.new("ObjectValue")
		adapterRef.Name, adapterRef.Value, adapterRef.Parent = "QaWeapon", adapterModule, privateLifecycle
		local fallbackLifecycle = require(privateLifecycle)
		local warnings = {}
		local connection = LogService.MessageOut:Connect(function(message, messageType)
			if messageType == Enum.MessageType.MessageWarning and message:find("temporary shield geometry:", 1, true) then table.insert(warnings, message) end
		end)
		table.insert(connections, connection)
		local character = cloneRig("R15", "explicitShieldFallback")
		character:SetAttribute("K0ClassId", "knight")
		fallbackLifecycle.sync(character)
		check(#owned(character) == 1, "missing shield retains one complete fallback appearance")
		local visual = owned(character)[1]
		check(visual:GetAttribute("WeaponSourceKey") == "td:KnightSword" and visual:GetAttribute("UsesTdPlayerWeapon") == true, "shield source failure does not discard available original sword")
		check(visual:GetAttribute("ShieldSourceKey") == "temporary:K0Shield" and visual:GetAttribute("UsesTdPlayerShield") == false and visual:GetAttribute("TemporaryVisual") == true, "shield fallback is explicitly marked")
		local reason = visual:GetAttribute("ShieldFallbackReason")
		check(type(reason) == "string" and reason:find("TDKnightShieldModels", 1, true), "fallback retains source failure reason")
		check(visual:FindFirstChild("Shield") == nil and visual:FindFirstChild("ShieldGrip") == nil, "fallback does not claim the approved shield mesh")
		local count = 0
		for _, item in ipairs(visual:GetChildren()) do
			if item:GetAttribute("TLTPlayerShieldPart") == true then count += 1; check(item:IsA("Part"), "fallback shield uses the existing simple geometry") end
		end
		check(count == 4, "explicit fallback preserves four prototype shield parts")
		check(visual:FindFirstChild("K0ShieldHandWeld", true).Part0 == handsFor(character).left, "fallback still follows left hand")
		check(waitFor(function() return #warnings > 0 end, 2), "native warning reports temporary shield and missing source")
		check(warnings[1]:find("TDKnightShieldModels", 1, true) ~= nil, "warning includes actionable missing source")
		connection:Disconnect()
		shieldTemplates:Clone().Parent = isolatedStorage
		local newLife = cloneRig("R6", "restoredShieldSource")
		newLife:SetAttribute("K0ClassId", "knight")
		fallbackLifecycle.sync(newLife)
		check(#owned(newLife) == 1, "next life can use restored reviewed source")
		verifyShield(observedShield(owned(newLife)[1]), newLife)
	end)

	clientVisual = require(assert(StarterPlayer.StarterPlayerScripts:FindFirstChild("K0SwordVisual", true)))
	for _, rigName in ipairs({ "R6", "R15" }) do
		for _, classId in ipairs({ "dwarf", "mage" }) do
			case("replicated-class-lifecycle-" .. rigName .. "-" .. classId, function()
				local first = cloneRig(rigName, classId .. "ClassPending")
				first:SetAttribute("K0ClassId", nil)
				local unrelated = Instance.new("Model")
				unrelated.Name, unrelated.Parent = "TLT_K0_KnightAppearance", first
				local tool = Instance.new("Tool")
				tool.Name, tool.RequiresHandle, tool.Parent = "ExistingEquipment", false, first
				local added, removing = Instance.new("BindableEvent"), Instance.new("BindableEvent")
				table.insert(eventObjects, added); table.insert(eventObjects, removing)
				local player = { Character = first, CharacterAdded = added.Event, CharacterRemoving = removing.Event }
				table.insert(fakePlayers, player)
				lifecycle.bind(player); lifecycle.bind(player)
				task.wait(0.05)
				check(#owned(first) == 0, "unknown server class waits without a guessed Knight appearance")
				first:SetAttribute("K0ClassId", classId) -- server attribute boundary; no persistent class selection
				check(waitFor(function() return #owned(first) == 1 end, 2), "class attribute observer attaches one " .. classId .. " appearance")
				local visual = owned(first)[1]
				check(visual:GetAttribute("WeaponClassId") == classId and visual:GetAttribute("WeaponSourceKey") == EXPECTED[classId].sourceKey,
					"lifecycle appearance follows actual server class identity")
				check(appearance.isAttached(visual, first, classId), "observed lifecycle result is completely attached before verification")
				local function noKnightShield(model)
					for _, item in ipairs(model:GetDescendants()) do
						check(not item.Name:lower():find("shield", 1, true), classId .. " lifecycle does not inherit Knight shield: " .. item.Name)
					end
				end
				noKnightShield(visual)
				check(unrelated.Parent == first and tool.Parent == first, "class attachment preserves external same-name model and Tool")
				local grip = assert(visual:FindFirstChild("WeaponGrip"))
				local joint = assert(grip:FindFirstChild("PlayerWeaponJoint"))
				first:SetAttribute("K0AttackPhase", "Windup"); first:SetAttribute("K0Combo", 1)
				check(clientVisual.renderCharacter(first, 1 / 30) == 1, "observed class appearance enters original melee renderer")
				local windup = joint.Transform
				first:SetAttribute("K0AttackPhase", "Active"); first:SetAttribute("K0Combo", 2)
				check(clientVisual.renderCharacter(first, 1 / 30) == 1 and joint.Transform ~= windup, "observed class appearance swings through actual client API")
				lifecycle.sync(first)
				check(#owned(first) == 1 and owned(first)[1] == visual, "class-aware sync does not duplicate or replace healthy appearance")
				local left = handsFor(first).left
				left.Parent = nil
				task.wait(0.05)
				check(#owned(first) == 1 and owned(first)[1] == visual, "non-Knight held weapon does not wait for an unused shield hand")
				left.Parent = first
				task.wait(0.05)
				check(#owned(first) == 1 and owned(first)[1] == visual, "restoring unused shield hand does not duplicate weapon")
				local hand = handsFor(first).right
				local replacement = hand:Clone()
				replacement.Name, replacement.CFrame = hand.Name, hand.CFrame
				for _, candidate in ipairs(first:GetDescendants()) do
					if candidate:IsA("Motor6D") and candidate.Part1 == hand and not candidate:IsDescendantOf(hand) then candidate.Part1 = replacement end
				end
				hand.Parent = nil
				check(waitFor(function() return #owned(first) == 0 end, 2), "missing original hand removes owned class appearance")
				replacement.Parent = first
				check(waitFor(function() return #owned(first) == 1 end, 2), "replacement hand rebuilds observed class appearance")
				local replaced = owned(first)[1]
				check(replaced ~= visual and appearance.isAttached(replaced, first, classId), "hand replacement makes fresh complete class weapon")
				check(replaced:FindFirstChild("PlayerWeaponJoint", true).Part0 == replacement, "new class socket follows replacement hand identity")
				noKnightShield(replaced)
				check(unrelated.Parent == first and tool.Parent == first, "hand replacement preserves external equipment")
				hand:Destroy()
				removing:Fire(first)
				check(waitFor(function() return lifecycle.bindings[player].character == nil end, 2), "CharacterRemoving disconnects old class observers")
				replaced:Destroy()
				first:SetAttribute("K0ClassId", "knight")
				task.wait(0.05)
				check(#owned(first) == 0, "removed character's class signal cannot reattach an old appearance")
				local second = cloneRig(rigName, classId .. "RespawnPending")
				second:SetAttribute("K0ClassId", nil)
				player.Character = second; added:Fire(second)
				task.wait(0.05)
				check(#owned(second) == 0, "new life waits for its own server class assignment")
				second:SetAttribute("K0ClassId", classId)
				check(waitFor(function() return #owned(second) == 1 end, 2), "new life observes restored server class")
				local respawnVisual = owned(second)[1]
				check(respawnVisual ~= replaced and appearance.isAttached(respawnVisual, second, classId), "respawn makes fresh complete class appearance")
				noKnightShield(respawnVisual)
				second:SetAttribute("K0AttackPhase", "Active"); second:SetAttribute("K0Combo", 1)
				check(clientVisual.renderCharacter(second, 1 / 30) == 1, "respawn class weapon still renders melee")
				lifecycle.unbind(player)
				respawnVisual:Destroy()
				second:SetAttribute("K0ClassId", "knight")
				task.wait(0.05)
				check(#owned(second) == 0, "unbind disconnects class-attribute observer")
			end)
		end
	end
	for _, rigName in ipairs({ "R6", "R15" }) do
		case("avatar-arms-attack-block-and-cast-" .. rigName, function()
			local character = cloneRig(rigName, "combatArmPose")
			local right = character:FindFirstChild("RightShoulder", true) or character:FindFirstChild("Right Shoulder", true)
			local left = character:FindFirstChild("LeftShoulder", true) or character:FindFirstChild("Left Shoulder", true)
			check(right ~= nil and left ~= nil, "rig exposes both avatar shoulder joints")
			for _, classId in ipairs({ "knight", "dwarf", "mage" }) do
				character:SetAttribute("K0ClassId", classId)
				character:SetAttribute("K0State", "Attack")
				character:SetAttribute("K0AttackKind", "Basic")
				character:SetAttribute("K0AttackPhase", "Windup")
				clientVisual.renderArms(character, 0.1)
				local windup = right.Transform
				character:SetAttribute("K0AttackPhase", "Active")
				clientVisual.renderArms(character, 0.1)
				check(right.Transform ~= windup, classId .. " swings the avatar arm between windup and active")
			end
			character:SetAttribute("K0ClassId", "knight"); character:SetAttribute("K0State", "Block")
			clientVisual.renderArms(character, 0.1)
			check(left.Transform ~= CFrame.new(), "Knight raises and turns the shield arm while blocking")
			character:SetAttribute("K0ClassId", "mage"); character:SetAttribute("K0State", "Attack")
			character:SetAttribute("K0AttackKind", "Arcane"); character:SetAttribute("K0AttackPhase", "Windup")
			clientVisual.renderArms(character, 0.1)
			check(right.Transform ~= CFrame.new(), "Mage extends the staff arm while casting")
			character:SetAttribute("K0ClassId", "elf")
			clientVisual.renderArms(character, 0.1)
			check(right.Transform ~= CFrame.new() and left.Transform ~= CFrame.new(), "Elf raises both arms to draw")
		end)
	end
	for _, rigName in ipairs({ "R6", "R15" }) do
		case("ground-slam-hop-and-landing-" .. rigName, function()
			local character = cloneRig(rigName, "groundSlamHop")
			local root = character.HumanoidRootPart
			local joint = rigName == "R15" and character.LowerTorso:FindFirstChild("Root") or root:FindFirstChild("RootJoint")
			assert(joint, "root animation joint required")
			local original = root.CFrame
			character:SetAttribute("K0ClassId", "dwarf"); character:SetAttribute("K0State", "Attack")
			character:SetAttribute("K0SkillId", "dwarf.common.ground"); character:SetAttribute("K0AttackPhase", "Windup")
			character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow() - 0.20)
			clientVisual.renderArms(character, 0.05)
			check(joint.Transform.Position.Magnitude > 0.9, "body rises during windup")
			check(root.CFrame == original, "visual hop leaves combat root in place")
			character:SetAttribute("K0AttackPhase", "Active")
			character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow() - 0.42)
			clientVisual.renderArms(character, 0.05)
			check(joint.Transform.Position.Magnitude < 0.01, "body lands by the configured hit time")
			character:SetAttribute("K0AttackPhase", "Windup")
			character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow() - 0.20)
			clientVisual.renderArms(character, 0.05)
			character:SetAttribute("K0State", "Idle"); character:SetAttribute("K0SkillId", nil)
			for _ = 1, 6 do clientVisual.renderArms(character, 0.05) end
			check(joint.Transform.Position.Magnitude < 0.01, "interruption and recovery restore root pose")
		end)
	end
	case("ground-slam-pulse-matches-hit-window", function()
		local character = cloneRig("R15", "groundSlamPulse")
		character:SetAttribute("K0ClassId", "dwarf"); character:SetAttribute("K0SkillId", "dwarf.common.ground")
		character:SetAttribute("K0AttackPhase", "Active"); character:SetAttribute("K0AttackSeq", 1)
		local function countPulses()
			local count = 0; for _, child in ipairs(workspace:GetChildren()) do if child.Name == "K0SkillArea" then count += 1 end end
			return count
		end
		local before = countPulses()
		character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow() - 0.36)
		clientVisual.renderCharacter(character, 0.01)
		check(countPulses() == before, "impact does not precede landing")
		character:SetAttribute("K0SkillStartedAt", workspace:GetServerTimeNow() - 0.42)
		clientVisual.renderCharacter(character, 0.01)
		check(countPulses() == before + 1, "impact appears at server hit window")
		clientVisual.renderCharacter(character, 0.01)
		check(countPulses() == before + 1, "impact appears only once")
	end)
	case("class-signal-replaces-owned-only-and-waits-on-invalid", function()
		local character = cloneRig("R15", "classSignalMatrix")
		character:SetAttribute("K0ClassId", nil)
		local external = Instance.new("Model")
		external.Name, external.Parent = "ExternalUserCosmetic", character
		local added, removing = Instance.new("BindableEvent"), Instance.new("BindableEvent")
		table.insert(eventObjects, added); table.insert(eventObjects, removing)
		local player = { Character = character, CharacterAdded = added.Event, CharacterRemoving = removing.Event }
		table.insert(fakePlayers, player); lifecycle.bind(player)
		for _, classId in ipairs({ "knight", "dwarf", "mage", "elf", "priest", "knight" }) do
			character:SetAttribute("K0ClassId", classId)
			if classId == "priest" then
				check(waitFor(function() return #owned(character) == 0 end, 2), "unsupported server class removes stale owned appearance")
			else
				check(waitFor(function() return #owned(character) == 1 and owned(character)[1]:GetAttribute("WeaponClassId") == classId end, 2), "class signal replaces owned appearance with " .. classId)
				check(appearance.isAttached(owned(character)[1], character, classId), "class signal result attached as " .. classId)
				check((owned(character)[1]:FindFirstChild("K0ShieldHandWeld", true) ~= nil) == (classId == "knight"), "shield appears only for Knight")
			end
			check(external.Parent == character, "class signal keeps external cosmetics")
		end
		character:SetAttribute("K0ClassId", nil)
		check(waitFor(function() return #owned(character) == 0 end, 2), "cleared class waits without stale weapon")
		lifecycle.unbind(player)
	end)
	case("unavailable-knight-meshes-have-local-visuals", function()
		local character = cloneRig("R15", "fallbackVisible")
		local model = Instance.new("Model"); model.Name, model.Parent = "QaKnight", character
		local sword = assert(appearance.attachInto(model, character, "knight"))
		local shield = assert(appearance.attachShieldInto(model, character))
		for _, kind in ipairs({ "sword", "shield" }) do
			check(clientVisual.setKnightMeshReady(model, kind, false), kind .. " creates fallback")
			check(clientVisual.setKnightMeshReady(model, kind, false), kind .. " fallback is idempotent")
			local folder = assert(model:FindFirstChild(kind == "sword" and "K0LocalSwordFallback" or "K0LocalShieldFallback"))
			check(#parts(folder) >= 3, kind .. " fallback has visible geometry")
			for _, part in ipairs(parts(folder)) do
				check(part.Transparency == 0 and not part.CanCollide and not part.CanTouch and not part.CanQuery, "fallback is visible and presentation-only")
			end
			local mesh = kind == "sword" and sword.trailPart or shield.shield
			check(mesh.LocalTransparencyModifier == 1, "unavailable mesh hidden while fallback is shown")
			check(clientVisual.setKnightMeshReady(model, kind, true), kind .. " can restore its TD source")
			check(folder.Parent == nil and mesh.LocalTransparencyModifier == 0, "loaded TD source replaces fallback")
		end
	end)
	case("production-sword-render-api-with-native-effects", function()
		local character = cloneRig("R15", "swordEffects")
		local model = Instance.new("Model")
		model.Name, model.Parent = "TLT_K0_KnightAppearance", character
		local result, reason = appearance.attachInto(model, character, "knight")
		check(result ~= nil, "sword effect setup: " .. tostring(reason))
		character:SetAttribute("K0ClassId", "knight")
		character:SetAttribute("K0Combo", 1)
		character:SetAttribute("K0AttackPhase", "Windup")
		check(clientVisual.renderCharacter(character, 1 / 30) == 1, "production renderCharacter selects Knight appearance")
		local trail = result.trailPart:FindFirstChild("K0SwordTrail")
		check(trail and trail:IsA("Trail") and not trail.Enabled, "native trail created but disabled in windup")
		check(result.joint.Transform ~= CFrame.new(), "original client code changes native sword joint")
		check(trail.Attachment0 == result.trailPart.K0TrailBottom and trail.Attachment1 == result.trailPart.K0TrailTop, "trail reuses authored sword-axis endpoints")
		character:SetAttribute("K0AttackPhase", "Active"); clientVisual.renderCharacter(character, 1 / 30)
		check(trail.Enabled, "active phase enables native trail")
		character:SetAttribute("K0AttackPhase", "Recovery"); clientVisual.renderCharacter(character, 1 / 30)
		check(not trail.Enabled, "recovery phase disables trail")
		clientVisual.renderCharacter(character, 1 / 30)
		check(#parts(result.trailPart, "Trail") == 1, "repeated rendering does not duplicate trails")
		local oldGrip = result.grip
		result.trailPart:Destroy()
		local rebuilt, rebuildReason = appearance.attachInto(model, character, "knight")
		check(rebuilt ~= nil and rebuilt.grip ~= oldGrip, "damaged sword rebuild: " .. tostring(rebuildReason))
		character:SetAttribute("K0AttackPhase", "Active"); clientVisual.renderCharacter(character, 1 / 30)
		local replacementTrail = rebuilt.trailPart:FindFirstChild("K0SwordTrail")
		check(replacementTrail and replacementTrail.Enabled and replacementTrail ~= trail, "original client code reconnects rebuilt native sword effects")
		check(trail.Parent == nil and #parts(rebuilt.trailPart, "Trail") == 1, "rebuild removes stale trail without duplication")
	end)
	for _, rigName in ipairs({ "R6", "R15" }) do
		for _, classId in ipairs({ "dwarf", "mage" }) do
			case("held-melee-render-" .. rigName .. "-" .. classId, function()
				local character = cloneRig(rigName, classId .. "MeleeRender")
				local model = Instance.new("Model")
				model.Name, model.Parent = "QaMeleeAppearance", character
				local result, reason = appearance.attachInto(model, character, classId)
				check(result ~= nil, "held melee setup: " .. tostring(reason))
				character:SetAttribute("K0ClassId", classId) -- fixture only, no class selection/save
				character:SetAttribute("K0AttackPhase", "Windup")
				character:SetAttribute("K0Combo", 1)
				local parents, transparencies = {}, {}
				for _, part in ipairs(parts(model)) do parents[part], transparencies[part] = part.Parent, part.Transparency end
				check(clientVisual.renderCharacter(character, 1 / 30) == 1, "matching server class attribute selects held melee render")
				local trail = result.grip:FindFirstChild("K0WeaponTrail")
				check(trail and trail:IsA("Trail") and not trail.Enabled, "melee windup has a ready class-colored effect")
				local descendantCount = #model:GetDescendants()
				local windup = result.joint.Transform
				check(windup ~= CFrame.new(), "held weapon windup changes native joint")
				character:SetAttribute("K0AttackPhase", "Active"); character:SetAttribute("K0Combo", 2)
				check(clientVisual.renderCharacter(character, 1 / 30) == 1 and result.joint.Transform ~= windup, "held weapon active phase changes native joint")
				check(trail.Enabled, "melee active phase shows attack trail")
				check(result.joint.Part0 == handsFor(character).right and result.joint.Part1 == result.grip, "melee weapon stays attached to original hand")
				for part, parent in pairs(parents) do
					check(part.Parent == parent and part.Transparency == transparencies[part], "melee renderer does not throw or hide " .. part.Name)
				end
				check(#model:GetDescendants() == descendantCount, "repeated melee rendering does not duplicate effects")
				character:SetAttribute("K0ClassId", "elf")
				check(clientVisual.renderCharacter(character, 1 / 30) == 0, "different class attribute does not animate this fixture")
			end)
		end
	end
	case("elf-bow-pose-and-harmless-local-arrow", function()
		local character = cloneRig("R15", "elfBowRender")
		local model = Instance.new("Model")
		model.Name, model.Parent = "QaElfAppearance", character
		local result, reason = appearance.attachInto(model, character, "elf")
		check(result ~= nil, "bow setup: " .. tostring(reason))
		character:SetAttribute("K0ClassId", "elf")
		character:SetAttribute("K0Combo", 1)
		character:SetAttribute("K0AttackPhase", "Windup")
		local stringPart = assert(model:FindFirstChild("String"))
		local arrowPart = assert(model:FindFirstChild("NockedArrow"))
		local initialSize = stringPart.Size
		character:SetAttribute("K0State", "Attack")
		clientVisual.renderArms(character, 1 / 30)
		local drawIK = assert(character:FindFirstChildOfClass("Humanoid"):FindFirstChild("K0BowDrawIK"))
		check(drawIK.Enabled and drawIK.Target.Parent == arrowPart and drawIK.EndEffector == character.RightHand, "R15 right hand targets the drawn nock")
		character:SetAttribute("K0AttackPhase", "Active"); clientVisual.renderArms(character, 1 / 30)
		check(drawIK.Enabled and drawIK.Weight == 1, "release holds hand at the nock")
		character:SetAttribute("K0AttackPhase", "Recovery"); clientVisual.renderArms(character, 1 / 30)
		check(drawIK.Enabled and drawIK.Weight > 0 and drawIK.Weight < 1, "recovery blends hand away from the nock")
		for _ = 1, 12 do clientVisual.renderArms(character, 1 / 30) end
		check(not drawIK.Enabled, "hand control is released after recovery")
		character:SetAttribute("K0AttackPhase", "Windup")
		check(clientVisual.samplePose("elf", "Windup", 1) ~= nil, "Elf has an explicit bow pose")
		character:SetAttribute("K0AttackPhase", "None"); clientVisual.renderCharacter(character, 1 / 30)
		local relaxedDepth = stringPart.Size.Z
		check(relaxedDepth < initialSize.Z * 0.5, "idle bowstring rests forward")
		for _ = 1, 120 do clientVisual.renderCharacter(character, 1 / 60) end
		near(stringPart.Size.Z, relaxedDepth, 0.001, "bowstring baseline does not shrink across frames")
		character:SetAttribute("K0AttackPhase", "Windup")
		check(clientVisual.renderCharacter(character, 1 / 30) == 1, "matching Elf bow renders")
		local windup = result.joint.Transform
		check(windup ~= CFrame.new(), "bow windup moves its joint")
		local arrowJoint = assert(arrowPart:FindFirstChild("NockedArrowVisualJoint"))
		check(stringPart.Size.Z > relaxedDepth and arrowJoint.Transform.Position.Z > 0, "windup pulls string and arrow together from the relaxed baseline")
		near(stringPart.Size.Z - relaxedDepth, arrowJoint.Transform.Position.Z, 0.001, "string and arrow draw use the same displacement")
		character:SetAttribute("K0AttackPhase", "Active")
		check(clientVisual.renderCharacter(character, 1 / 30) == 1 and result.joint.Transform ~= windup, "bow release pose differs")
		check(arrowJoint.Transform.Position.Z < 0.48 and stringPart.Size.Z <= relaxedDepth + 0.001, "release returns the string and nocked arrow forward")
		check(arrowPart.Transparency == 1, "released nocked arrow hides during flight")
		character:SetAttribute("K0AttackPhase", "None"); clientVisual.renderCharacter(character, 1 / 30)
		check(arrowPart.Transparency == 0, "idle restores the nocked arrow")
		local root = assert(character:FindFirstChild("HumanoidRootPart"))
		local from, to = root.Position, root.Position + Vector3.new(0, 0, -10)
		character:SetAttribute("K0ArrowVisual", string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", from.X, from.Y, from.Z, to.X, to.Y, to.Z))
		local visualOrigin = result.tip and result.tip.WorldPosition or result.grip.Position
		clientVisual.renderCharacter(character, 1 / 30)
		local arrow = workspace:FindFirstChild("K0VisualArrow")
		check(arrow and arrow:IsA("Model"), "server shot snapshot produces a visible local arrow")
		check((arrow.Shaft.Position - visualOrigin).Magnitude < 0.01, "visual arrow starts at the authored bow socket")
		for _, part in ipairs(parts(arrow)) do
			check(part.Transparency == 0 and part.Anchored and not part.CanCollide and not part.CanTouch and not part.CanQuery,
				"arrow is visible and does not collide or inflict touch damage: " .. part.Name)
		end
		check(#parts(arrow) >= 2 and #parts(arrow, "LuaSourceContainer") == 0, "local arrow has shape and no executable content")
		clientVisual.renderCharacter(character, 1 / 30)
		local count = 0
		for _, child in ipairs(workspace:GetChildren()) do if child.Name == "K0VisualArrow" then count += 1 end end
		check(count == 1, "one shot snapshot is consumed once")
		arrow:Destroy()
		local missingBow = cloneRig("R15", "elfMissingBow")
		missingBow:SetAttribute("K0ClassId", "elf")
		local fallback = assert(missingBow:FindFirstChild("HumanoidRootPart")).Position
		missingBow:SetAttribute("K0ArrowVisual", string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f",
			fallback.X, fallback.Y, fallback.Z, fallback.X, fallback.Y, fallback.Z - 10))
		clientVisual.renderCharacter(missingBow, 1 / 30)
		local fallbackArrow = workspace:FindFirstChild("K0VisualArrow")
		check(fallbackArrow and (fallbackArrow.Shaft.Position - fallback).Magnitude < 0.002, "late or missing bow uses server snapshot origin")
		fallbackArrow:Destroy()
	end)
	case("mage-arcane-visual-is-local-and-harmless", function()
		local character = cloneRig("R15", "mageSpellRender")
		local model = Instance.new("Model"); model.Name = "QaMageAppearance"; model.Parent = character
		local result = assert(appearance.attachInto(model, character, "mage"))
		character:SetAttribute("K0ClassId", "mage")
		character:SetAttribute("K0AttackKind", "Arcane"); character:SetAttribute("K0AttackPhase", "Windup")
		clientVisual.renderCharacter(character, 0.1)
		check(result.joint.Transform ~= CFrame.new(), "Arcane cast moves the staff joint")
		local root = assert(character:FindFirstChild("HumanoidRootPart"))
		local from, to = root.Position, root.Position + Vector3.new(0, 0, -10)
		character:SetAttribute("K0SpellVisual", string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", from.X, from.Y, from.Z, to.X, to.Y, to.Z))
		clientVisual.renderCharacter(character, 0.1)
		local orb = workspace:FindFirstChild("K0VisualSpell")
		check(orb and orb:IsA("BasePart") and orb.Anchored and not orb.CanCollide and not orb.CanTouch and not orb.CanQuery,
			"server snapshot creates a visible non-colliding local magic orb")
		check(orb and orb:FindFirstChildOfClass("Trail") ~= nil, "magic orb has a visible trail")
		if orb then orb:Destroy() end
	end)
	case("multi-shot-renders-five-arrows", function()
		local character = cloneRig("R15", "multiFan")
		character:SetAttribute("K0ClassId", "elf")
		local p = character.HumanoidRootPart.Position
		character:SetAttribute("K0ArrowVisual", string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", p.X, p.Y, p.Z, p.X, p.Y, p.Z - 20))
		local fields = { "1", tostring(p.X), tostring(p.Y), tostring(p.Z) }
		for _, x in ipairs({-6, -3, 3, 6}) do
			table.insert(fields, tostring(p.X + x)); table.insert(fields, tostring(p.Y)); table.insert(fields, tostring(p.Z - 20))
		end
		character:SetAttribute("K0MultiShotVisual", table.concat(fields, "|"))
		clientVisual.renderCharacter(character, 1 / 30)
		local arrows = {}
		for _, child in ipairs(workspace:GetChildren()) do if child.Name == "K0VisualArrow" then table.insert(arrows, child) end end
		check(#arrows == 5, "primary and four simultaneous secondary arrows created")
		for _, arrow in ipairs(arrows) do arrow:Destroy() end
	end)
	case("thrown-axe-never-retains-character-weld", function()
		local character = cloneRig("R15", "axeProjectileSafety")
		local model = Instance.new("Model"); model.Name = "QaDwarfAppearance"; model.Parent = character
		assert(appearance.attachInto(model, character, "dwarf"))
		local root = assert(character:FindFirstChild("HumanoidRootPart"))
		local original = root.CFrame
		character:SetAttribute("K0ClassId", "dwarf")
		character:SetAttribute("K0SkillId", "dwarf.common.throw")
		local p = root.Position
		character:SetAttribute("K0SpellVisual", string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", p.X, p.Y, p.Z, p.X, p.Y, p.Z - 10))
		clientVisual.renderCharacter(character, 1 / 30)
		local axe = workspace:FindFirstChild("K0VisualThrownAxe")
		check(axe ~= nil and axe.Anchored and not axe.CanCollide, "thrown visual exists and is harmless")
		if axe then
			for _, item in ipairs(axe:GetDescendants()) do
				check(not item:IsA("WeldConstraint") and not item:IsA("JointInstance") and not item:IsA("Constraint"), "projectile has no physical connections")
			end
			check(root.CFrame == original, "creating projectile does not move character")
			axe:Destroy()
		end
	end)
	case("water-ball-has-orbiting-droplets", function()
		local character = cloneRig("R15", "waterProjectile")
		character:SetAttribute("K0ClassId", "mage"); character:SetAttribute("K0SkillId", "mage.common.water_ball")
		local p = character.HumanoidRootPart.Position
		character:SetAttribute("K0SpellVisual", string.format("1|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f", p.X, p.Y, p.Z, p.X, p.Y, p.Z - 10))
		clientVisual.renderCharacter(character, 1 / 30)
		local orb = workspace:FindFirstChild("K0WaterBall")
		check(orb ~= nil and orb.Material == Enum.Material.Glass and not orb.CanCollide, "water ball is a harmless glass sphere")
		local count = 0
		if orb then for _, child in ipairs(orb:GetChildren()) do if child.Name == "K0WaterDroplet" then count += 1 end end end
		check(count == 5, "five water droplets surround the ball")
		if orb then orb:Destroy() end
	end)
	case("source-library-immutable-after-all-builds-and-attachments", sourcesUnchanged)
end, debug.traceback)
if not ok then table.insert(report.failures, "fixture: " .. tostring(fatal)) end
local cleaned, cleanupError = pcall(function()
	if lifecycle then for _, player in ipairs(fakePlayers) do lifecycle.unbind(player) end end
	for _, connection in ipairs(connections) do connection:Disconnect() end
	for _, event in ipairs(eventObjects) do event:Destroy() end
	for _, module in ipairs(privateModules) do module:Destroy() end
	if clientVisual and fixture then
		for _, model in ipairs(fixture:GetDescendants()) do
			if model:IsA("Model") and model:GetAttribute("WeaponClassId") then
				model:SetAttribute("WeaponClassId", "qa_cleanup")
				clientVisual.render(model, "None", 1, 1 / 60)
			end
		end
	end
	if fixture then fixture:Destroy() end
end)
if not cleaned then table.insert(report.failures, "cleanup: " .. tostring(cleanupError)) end
report.running = RunService:IsRunning()
report.pass = #report.failures == 0
print("K0_PLAYER_WEAPONS_NATIVE " .. HttpService:JSONEncode(report))
assert(report.pass, "K0 player weapon native fixtures failed; see K0_PLAYER_WEAPONS_NATIVE")
