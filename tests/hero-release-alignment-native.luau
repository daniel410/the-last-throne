assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local client = game.StarterPlayer.StarterPlayerScripts.Client
local catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local Visual = require(client.AdvancedSkillVisual)
local FX = require(client.HeroVFX)
local Melee = require(client.AdvancedSkillMotion)
local Mage = require(client.K0MageMotion)
local Gestures = require(client.RangedActionPoses)

local stage = Instance.new("Folder", workspace)
local origin, forward = Vector3.new(0, 300, 0), -Vector3.zAxis
local report = {checks = 0, failures = {}, poses = {}}
local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end
local function close(a, b)
    return typeof(a) == "Vector3" and (a-b).Magnitude < .04
end
local function definition(id)
    return catalog.byId[id].definition
end
local function actor(at)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, at
    return model, root
end
local function effects(model, name)
    local result = {}
    for _, child in model:GetDescendants() do
        if child.Name == name then table.insert(result, child) end
    end
    return result
end
local function parts(name)
    local result = {}
    for _, child in workspace:GetChildren() do
        if child:IsA("BasePart") and child.Name == name then table.insert(result, child) end
    end
    return result
end
local function clear()
    FX.clear()
    for _, name in {"SkillSector", "BladeCrescent", "ArrowWake", "ArrowShaft", "ArrowHead", "SkillSourceArrow", "SkillContact"} do
        for _, part in parts(name) do part:Destroy() end
    end
end

local crescent = definition("knight_crescent_cut")
local axe = definition("dwarf_braced_throw")
local retreat = definition("elf_retreating_shot")
local spear = definition("mage.cryo.thunder_spear")
local character, root = actor(origin)
local target, enemyRoot = actor(origin + Vector3.new(2.5, 0, -3))
local humanoid = Instance.new("Humanoid", target)
enemyRoot.CanCollide = false
local aim, ending, hits
local enemy = {id = 1, model = target, root = enemyRoot, humanoid = humanoid}
local function resolve(d, cast)
    hits = 0
    Combat.resolve({character = character, root = root}, {definition = d, direction = forward, advancedCast = cast}, 0, {
        enemies = {[target] = enemy},
        clear = function() return true end,
        damage = function(_, victim, _, _, direction, pulse)
            hits += 1
            check(victim == enemy and pulse == 1 and direction.Magnitude > .99, d.id .. " retains its confirmed hit")
        end,
        visual = function(_, _, _, center, _, points, direction)
            aim, ending = direction, center
            check(#points == 1 and close(points[1], enemyRoot.Position), d.id .. " retains its confirmed hit position")
        end,
    }, 1)
end

resolve(crescent, {origin = origin, center = enemyRoot.Position, target = target})
check(close(aim, forward) and close(ending, enemyRoot.Position) and hits == 1, "Cone exports its locked heading alongside the selected target")
Visual.play(character, crescent.id, origin, ending, 1, {enemyRoot.Position}, nil, nil, nil, forward)
local model = assert(workspace:FindFirstChild("HeroVFX"))
local bounds, edge = parts("SkillSector"), effects(model, "CrescentCutEdge")
local middle = Vector3.zero
for _, part in bounds do middle += part.Position - origin end
check(#bounds == 12 and math.abs(middle.X) < .08 and middle.Z < -30, "Cone boundary is symmetric about server heading")
check(#edge >= 6 and model:GetAttribute("CrescentCutEdge") == true, "Crescent uses its own cutting edge")
if #edge >= 6 then
    local a, b = edge[1].Attachment0.WorldPosition, edge[#edge].Attachment1.WorldPosition
    check(math.abs(a.X+b.X-2*origin.X) < .1 and a.Y-b.Y > 1, "Crescent falls across the full front")
end
check(#parts("BladeCrescent") == 0, "Crescent avoids the duplicate legacy arc")
clear()

root.Position = origin + Vector3.xAxis*3
enemyRoot.Position = root.Position+forward*5
local wall = Instance.new("Part", stage)
wall.Anchored, wall.Size, wall.Position = true, Vector3.new(2, 5, 1), root.Position+forward*10
resolve(axe, {origin = origin, center = origin+forward*axe.range})
check(close(ending, root.Position+forward*9.3) and hits == 1, "Braced Throw stops at a wall on the confirmed release ray")
wall:Destroy()
resolve(axe, {origin = origin, center = origin+forward*axe.range})
check(close(ending, root.Position+forward*axe.range), "Unobstructed release preserves the configured range from the new position")
local socket = root.Position+Vector3.new(.5, .6, -1)
model = assert(FX.skill(character, axe.id, root.Position, ending, 1, {}, socket))
local wake = effects(model, "BracedThrowWake")[1]
check(wake and close(wake.Attachment0.WorldPosition, socket), "Braced Throw begins its wake at the weapon")
if wake then
    local initial = wake.Attachment1.WorldPosition
    FX.step(workspace:GetServerTimeNow()+.07)
    check((wake.Attachment1.WorldPosition-initial):Dot(forward) > 8, "The wake advances down the confirmed line")
end
check(model:GetAttribute("ArtSilhouette") == "ThrownAxe", "Throw keeps its axe silhouette")
clear()

local grip = Instance.new("Part", character)
grip.Name, grip.Anchored, grip.CFrame = "WeaponGrip", true, CFrame.new(socket)
local tip = Instance.new("Attachment", grip)
tip.Name = "WeaponTip"
local endpoint = root.Position+forward*23
Visual.play(character, retreat.id, root.Position, endpoint, 1, {})
model = assert(workspace:FindFirstChild("HeroVFX"))
wake = effects(model, "RetreatingShotWake")[1]
check(wake and close(wake.Attachment0.WorldPosition, socket) and close(wake.Attachment1.WorldPosition, endpoint),
    "Retreating Shot connects bow and confirmed endpoint")
check(#parts("ArrowWake") == 0 and #parts("ArrowShaft") == 1, "Retreating Shot has one wake and a physical arrow fallback")
clear()
Visual.play(character, spear.id, root.Position, endpoint, 1, {})
model = assert(workspace:FindFirstChild("HeroVFX"))
local axis = effects(model, "IconThunderSpearAxis")[1]
check(axis and close(axis.Attachment0.WorldPosition, socket) and close(axis.Attachment1.WorldPosition, endpoint),
    "Thunder Spear begins at the staff and terminates at the confirmed point")
clear()
tip.Position = forward*5
model = assert(FX.skill(character, spear.id, root.Position, root.Position+forward*2, 1, {}, tip.WorldPosition))
axis = effects(model, "IconThunderSpearAxis")[1]
check(axis and close(axis.Attachment0.WorldPosition, root.Position), "Thunder Spear falls back when the socket would reverse the trace")
clear()

for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
    local cut = Melee.sample("knight", crescent, crescent.windup*.5, rig)
    local cutEnd = Melee.sample("knight", crescent, crescent.windup+.075, rig)
    local throw = Melee.sample("dwarf", axe, axe.windup*.5, rig)
    local throwEnd = Melee.sample("dwarf", axe, axe.windup+.065, rig)
    report.poses[rig.Name] = {crescentLoadYaw = cut.angles.torso.Y, crescentFinishYaw = cutEnd.angles.torso.Y,
        axeLoadKnee = throw.angles.rightKnee.X, axeFinishKnee = throwEnd.angles.leftKnee.X}
    check(cut.angles.torso.Y < -10 and cutEnd.angles.torso.Y > 7, "Crescent coils then follows through on " .. rig.Name)
    check(throw.angles.rightKnee.X > 20 and throwEnd.angles.leftKnee.X > 12, "Braced Throw loads and shifts weight on " .. rig.Name)
end
local bow = {angles = {}}
Gestures.bow(bow, retreat, retreat.windup+.05, .05, false, 1)
report.poses.retreatKnee = bow.angles.rightKnee.X
check(bow.angles.rightKnee.X > 37, "Retreating Shot absorbs the rearward step through the rear leg")
local cast = {angles = {}}
Gestures.mage(cast, spear, Mage.profile(spear), spear.windup+.0616)
report.poses.spearElbow = cast.angles.leftElbow.X
check(cast.angles.leftElbow.X > 32, "Thunder Spear drives the guiding arm forward")

stage:Destroy()
report.pass = #report.failures == 0
print("HERO_RELEASE_ALIGNMENT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, table.concat(report.failures, "\n"))
