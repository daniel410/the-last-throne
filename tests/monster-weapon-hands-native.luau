-- Measure the displayed blade in torso space, including models with a shared rig.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local client = game.StarterPlayer.StarterPlayerScripts.Client
local shared = game.ReplicatedStorage.Shared
local field = require(game.ServerScriptService.Server.World.TrainingField)
local motion = require(client.K0EnemyMotion)
local snapshot = require(client.EnemyPatternDefinition)
local patterns = require(shared.EnemyPatterns)
local profiles = require(shared.EnemyCombatProfiles)
local rigs = require(shared.BladeMonsterRigs)
local stage = Instance.new("Folder", workspace)
local rows = {}
local tipErrors = {}

for _,kind in {"Veyr", "DreadCommander", "DeathKnight", "EnragedWarlord"} do
	local actor = field.makeEnemy(stage, kind, 0, 0, 1, 1)
	local root = actor.HumanoidRootPart
	root.Anchored = true
	local originalRoot, health = root.CFrame, actor.Humanoid.Health
	local state = assert(motion.bind(actor))
	local shoulder = assert(state.joints.weapon)
	local fx = assert(state.weaponFX)
	local visual = actor.TdMonsterVisual
	assert(shoulder.Name == "Right Shoulder" and shoulder.Part1 == actor["Right Arm"])
	assert(fx.a.Parent == visual.ArmL and visual.ArmL.TdVisualWeld.Part0 == shoulder.Part1)
	assert(visual.Body.TdVisualWeld.Part0 == actor.Torso and visual.Body.MeshId ~= visual.ArmL.MeshId)
	assert(not visual.CombatDetails:FindFirstChild("FocusProng"))
	if kind == "EnragedWarlord" then
		assert(visual.ArmR.TdVisualWeld.Part0 == state.joints.off.Part1)
	end

	-- Compare the authored tip to actual vertices downloaded from the registered MeshId.
	local id = visual.ArmL.MeshId
	if not tipErrors[id] then
		local mesh = game.AssetService:CreateEditableMeshAsync(visual.ArmL.MeshContent)
		local size = mesh:GetSize()
		local target = Vector3.new(unpack(rigs[kind].socket.tip)) * size
		local smallest = math.huge
		for _,vertex in mesh:GetVertices() do
			smallest = math.min(smallest, (mesh:GetPosition(vertex) - target).Magnitude)
		end
		mesh:Destroy()
		tipErrors[id] = smallest
	end
	assert(tipErrors[id] < .002, kind .. " trail must start on the blade point")
	local armTip = shoulder.Part1.CFrame:PointToObjectSpace(fx.a.WorldPosition)
	local function sample(time, label)
		actor:SetAttribute("K0EnemyState", label)
		motion.step(state, 1/60, time)
		return (shoulder.C0 * shoulder.Transform * shoulder.C1:Inverse()):PointToWorldSpace(armTip)
	end

	local results = {}
	local function measure(index, d)
		local start = 100 + index * 30
		local w,a,r = d.windup,d.active,d.recovery
		actor:SetAttribute("K0EnemyAttackClock", string.format("%d|%d|%.8f|%.8f|%.8f|%d", index,start,w,a,r,d.heavy and 1 or 0))
		sample(start, "Windup")
		local wind = sample(start+w*.78, "Windup")
		local readyRotation = shoulder.Transform
		local hit = sample(start+w, "Active")
		local _,angle = readyRotation:ToObjectSpace(shoulder.Transform):ToAxisAngle()
		local distance = (wind-hit).Magnitude/state.height
		assert(distance > .3 and math.deg(angle) > 48, kind .. " sword cannot stay on the chest during the strike")
		assert(hit.Z < -.24*state.height, kind .. " blade must reach in front")
		for pulse=2,d.pulses or 1 do
			local repeatHit = sample(start+w+(pulse-1)*d.interval, "Active")
			assert((hit-repeatHit).Magnitude < .003*state.height, kind .. " repeated hit pose")
		end
		sample(start+w+a+r, "Recovery")
		local _,endAngle = shoulder.Transform:ToAxisAngle()
		assert(math.abs(endAngle)<.001 and root.CFrame == originalRoot and actor.Humanoid.Health == health)
		table.insert(results,{attack=d.id or "basic", pulses=d.pulses or 1, shoulderDegrees=math.deg(angle),
			tipTravelInHeights=distance, forwardInHeights=-hit.Z/state.height})
	end
	measure(1,{windup=.8,active=.18,recovery=.5})
	for index,base in patterns.get(kind).attacks do
		local d = profiles.resolve(kind,base,"Hell",.3)
		actor:SetAttribute("K0AttackSeq",index)
		actor:SetAttribute("K0PatternId",d.id)
		snapshot.message({kind="begin",id=d.id,sequence=index,model=actor,definition=d,origin=root.Position,
			direction=-Vector3.zAxis,aim=root.Position-Vector3.zAxis*12})
		measure(index+1,d)
	end
	rows[kind] = results
	motion.unbind(state)
	actor:Destroy()
end
stage:Destroy()
print("WEAPON_HANDS_PASS " .. game.HttpService:JSONEncode({attacks=rows,bladePointErrors=tipErrors}))
