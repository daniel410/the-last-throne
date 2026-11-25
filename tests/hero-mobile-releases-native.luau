-- Studio fixture for the transition from confirmed travel to attack.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Telegraphs = require(Client.K0Telegraphs)
local Hits = require(Client.K0HitEffects)

local ids = {
    "knight.paladin.radiant_charge", "dwarf.gunner.blast_step",
    "elf.magic_archer.gliding_shot", "mage.pyro.ember_step",
}
local camera = workspace.CurrentCamera
local oldCamera, oldCompact = camera.CFrame, FX.isOtherHero
local departure, aim = Vector3.new(0, 720, 0), Vector3.xAxis
local stage = Instance.new("Folder", workspace)
local report = { checks = 0, failures = {}, beams = {} }
camera.CFrame = CFrame.lookAt(departure + Vector3.new(10, 10, 14), departure)

local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end

local function anchored(name, at, parent)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Anchored = name, at, true
    p.Parent = parent
    return p
end

local function nodes(model, name)
    local found = {}
    for _, node in model and model:GetDescendants() or {} do
        if node.Name == name then table.insert(found, node) end
    end
    return found
end

local function rangeParts(previous, center, forward, expected)
    local added = {}
    for _, item in workspace:GetChildren() do
        if not previous[item] and item.Name == "SkillSector" then
            table.insert(added, item)
        end
    end
    local valid = #added > 0
    for _, part in added do
        local delta = part.Position - center
        valid = valid and math.abs(Vector3.new(delta.X, 0, delta.Z).Magnitude - expected) < expected*.15
            and (not forward or delta:Dot(forward) > 0)
    end
    return valid
end

local function snapshot()
    local seen = {}
    for _, item in workspace:GetChildren() do seen[item] = true end
    return seen
end

local floor = anchored("Floor", departure - Vector3.yAxis*3, stage)
floor.Size = Vector3.new(60, 1, 60)
local actor = Instance.new("Model", stage)
local root = anchored("HumanoidRootPart", departure, actor)
root.CFrame = CFrame.lookAt(departure, departure + aim)
local definitions = {}
for i, id in ids do definitions[i] = Catalog.byId[id].definition end

local function motionWithoutOverride(d)
    local copy = table.clone(d)
    copy.id = d.id .. "_fixture"
    Presentation.byId[copy.id] = Presentation.get(d)
    return copy
end
local radiant, blast, glide, ember = table.unpack(definitions)
local generic = motionWithoutOverride(radiant)
for _, rig in Enum.HumanoidRigType:GetEnumItems() do
    local first = radiant.windup + .055
    local second = first + radiant.interval
    local brace = Melee.sample("knight", radiant, radiant.windup*.54, rig)
    local plain = Melee.sample("knight", generic, radiant.windup*.54, rig)
    local low = Melee.sample("knight", radiant, first, rig)
    local lowPlain = Melee.sample("knight", generic, first, rig)
    local rise = Melee.sample("knight", radiant, second, rig)
    local risePlain = Melee.sample("knight", generic, second, rig)
    check(brace.angles.leftElbow.X - plain.angles.leftElbow.X > 20, "Radiant Charge tucks shield " .. rig.Name)
    check(low.angles.leftKnee.X - lowPlain.angles.leftKnee.X > 20, "Radiant Charge first lead leg " .. rig.Name)
    check(rise.angles.rightKnee.X - risePlain.angles.rightKnee.X > 20, "Radiant Charge second lead leg " .. rig.Name)
    local kick = Melee.sample("dwarf", blast, blast.windup + .045, rig)
    local recover = Melee.sample("dwarf", blast, blast.windup + .10, rig)
    check(kick.offhand and recover.offhand and math.abs(kick.angles.leftElbow.X - recover.angles.leftElbow.X) > 28,
        "Blast Step recovers the firing elbow " .. rig.Name)
end
Presentation.byId[generic.id] = nil
local bowPose = { angles = {} }
Bow.bow(bowPose, glide, glide.windup + .09, .09, false, 1)
check(bowPose.angles.leftKnee.X > 26, "Gliding Shot catches the lead foot after release")
local cast = Mage.sample(ember, Mage.profile(ember), ember.windup + .062)
check(cast.angles.torso.Y < -13 and cast.angles.leftKnee.X > 29, "Ember Step looks back over a planted leg")

for _, compact in {false, true} do
    FX.isOtherHero = function() return compact end
    for _, d in {radiant, glide} do
        local arrival = departure + aim*2 -- clipped but accepted movement
        Visual.play(actor, d.id, departure, departure + aim*6, 0)
        check(not workspace:FindFirstChild("HeroStepWake"), d.id .. " no wake when blocked")
        local startedAt = workspace:GetServerTimeNow()
        Visual.play(actor, d.id, arrival, arrival + aim*6, 0, nil, nil, startedAt, startedAt, aim, nil, departure)
        local wake = workspace:FindFirstChild("HeroStepWake")
        local label = d == radiant and "RadiantBootWake" or "GlidingHeelWake"
        local strokes = nodes(wake, label)
        check(#strokes == (compact and 1 or 2), d.id .. " movement beam budget")
        for _, beam in strokes do
            check(math.abs(beam.Attachment1.WorldPosition.X - arrival.X) < .02, d.id .. " wake stops at clipped arrival")
            check(beam.Attachment1.WorldPosition.Y < departure.Y - 2, d.id .. " foot trail projects onto floor")
        end
        FX.clear()
    end

    local first = FX.skill(actor, radiant.id, departure, departure + aim*6, 1, {}, nil, aim)
    local second = FX.skill(actor, radiant.id, departure, departure + aim*6, 2, {}, nil, aim)
    local low, rise = nodes(first, "RadiantChargeEdge"), nodes(second, "RadiantChargeEdge")
    check(#low == (compact and 2 or 4) and #rise == #low, "Radiant Charge both pulse silhouettes")
    if #low > 0 and #rise > 0 then
        local function height(lines)
            local min, max = math.huge, -math.huge
            for _, beam in lines do
                for _, y in {beam.Attachment0.WorldPosition.Y, beam.Attachment1.WorldPosition.Y} do
                    min, max = math.min(y, min), math.max(y, max)
                end
            end
            return max - min
        end
        check(height(rise) - height(low) > 1.4, "Radiant Charge second contact rises clearly")
        local lateral = aim:Cross(Vector3.yAxis)
        local left, right = math.huge, -math.huge
        for _, beam in low do
            for _, p in {beam.Attachment0.WorldPosition, beam.Attachment1.WorldPosition} do
                left, right = math.min(left, p:Dot(lateral)), math.max(right, p:Dot(lateral))
            end
        end
        check(right-left > 4, "Radiant Charge first edge extends past the shield sides")
    end
    check(#nodes(first, "GuardHalo") == 0 and #nodes(second, "GuardSurface") == 0, "Radiant Charge removes duplicate shield geometry")
    FX.clear()
    local muzzle = departure + Vector3.new(.6, .8, .8)
    local fired = FX.skill(actor, blast.id, departure, departure - aim*4, 1, {}, muzzle, aim)
    local axis = nodes(fired, "BlastMuzzleKick")[1]
    local front = nodes(fired, "BlastForwardPressure")
    check(axis and (axis.Attachment0.WorldPosition - muzzle).Magnitude < .01
        and (axis.Attachment1.WorldPosition - muzzle):Dot(aim) > .5, "Blast Step fires forward through the left muzzle")
    check(#front == (compact and 1 or 4) and #nodes(fired, "GroundSector") == 0, "Blast Step uses one forward pressure wave")
    FX.clear()
    local before = snapshot()
    Visual.play(actor, blast.id, departure, departure - aim*4, 1, {}, nil, nil, nil, aim)
    check(rangeParts(before, departure, aim, blast.range), "Blast Step keeps the forward damage sector")
    FX.clear()

    local wall = departure + aim*.30
    local arrow = FX.skill(actor, glide.id, departure, wall, 1, {}, muzzle, aim)
    local trace = nodes(arrow, "GlidingShotWake")[1]
    check(trace and (trace.Attachment0.WorldPosition - departure).Magnitude < .01
        and (trace.Attachment1.WorldPosition - wall).Magnitude < .01, "Gliding Shot starts before close cover and stops at the packet endpoint")
    check(#nodes(arrow, "ProjectileSurface") == 0 and #nodes(arrow, "GlidingShotFletching") == 0, "Gliding Shot has a single release streak")
    FX.clear()

    local arrival = departure + aim*ember.move
    before = snapshot()
    Visual.play(actor, ember.id, arrival, departure, 1, {}, nil, nil, nil, aim)
    local flame
    for _, obj in workspace:GetChildren() do
        if not before[obj] and obj.Name == "HeroVFX" and obj:GetAttribute("SkillId") == ember.id then flame = obj end
    end
    local edge = nodes(flame, "EmberDepartureEdge")
    check(#edge == (compact and 4 or 6) and #nodes(flame, "EmberDepartureSpark") == (compact and 0 or 2),
        "Ember Step keeps a single back-sweeping flame edge")
    if #edge > 0 then
        local rear = math.huge
        for _, beam in edge do rear = math.min(rear, beam.Attachment0.WorldPosition.X, beam.Attachment1.WorldPosition.X) end
        check(rear < departure.X - .5, "Ember Step curls behind the departure on packet heading")
    end
    check(rangeParts(before, departure, nil, ember.range), "Ember Step keeps the departure damage circle")
    check(#nodes(flame, "CinderShockwave") == 0 and #nodes(flame, "AreaFire") == 0, "Ember Step removes the duplicate fire ring and particles")
    report.beams[compact and "ally" or "owner"] = { radiant = #low, blast = #front, ember = #edge }
    FX.clear()
end
local world = Instance.new("Folder", workspace)
world.Name = "DeepwoodK0"
local blockout = Instance.new("Folder", world)
blockout.Name = "TerrainBlockout"
floor.Parent = blockout
local enemies = Instance.new("Folder", world)
local target = Instance.new("Model", enemies)
anchored("HumanoidRootPart", departure + aim*3, target)
target:SetAttribute("K0EnemyState", "Windup")
target:SetAttribute("K0Telegraph", "Unblockable")
target:SetAttribute("K0AttackOrigin", departure + aim*3)
target:SetAttribute("K0AttackDirection", aim)
target:SetAttribute("K0AttackRange", 9)
target:SetAttribute("K0AttackAngle", 360)
local player = Instance.new("Folder", stage)
player:SetAttribute("K0SessionPhase", "Tutorial")
actor.Name = "Character"
actor.Parent = player
local warnings = Telegraphs.create(enemies, player)
FX.isOtherHero = function(character) return character ~= nil and character ~= actor end
local allies = {}
for i = 1, 3 do
    local ally = Instance.new("Model", stage)
    local origin = departure - aim + Vector3.zAxis*(i-2)*2
    anchored("HumanoidRootPart", origin, ally)
    local endpoint = origin + aim*7
    Visual.play(ally, ids[i], origin, endpoint, i == 1 and 2 or 1, {endpoint}, nil, nil, nil, aim)
    allies[i] = ally
end
Visual.play(actor, ember.id, departure + aim*5, departure, 1, {}, nil, nil, nil, aim)
local active, beams, _, glows, particles, surfaces = FX.count()
check(active == 4 and glows + particles == 0, "Three compact allies and the owner keep their releases without extra glow or particles")
warnings.update()
local red = 0
for _, edge in workspace.K0LocalTelegraphs:GetDescendants() do
    if edge:IsA("BasePart") and edge.Transparency < 1 and edge.Color == Color3.fromRGB(255, 73, 58) then red += 1 end
end
check(red == 16, "All 16 enemy warning segments remain in the four-cast fixture")
local hitAt = target.HumanoidRootPart.Position
check(Hits.show(target, hitAt, 42, "elf", "Goblin", aim, glide.id, {attacker = allies[3]}), "Gliding Shot routes the confirmed hit")
local number = workspace:FindFirstChild("K0HitEffect")
check(number and number.K0DamageNumber.Amount.Text == "42", "The allied arrow keeps the confirmed damage number")
if number then number:Destroy() end
report.overlap = { active = active, beams = beams, glows = glows, particles = particles, surfaces = surfaces, warningSegments = red }
warnings.destroy()
world:Destroy()
FX.clear()
FX.isOtherHero, camera.CFrame = oldCompact, oldCamera
stage:Destroy()
report.pass = #report.failures == 0
print("HERO_MOBILE_RELEASES_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero mobile releases regression")
