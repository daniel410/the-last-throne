-- Run in an isolated copy of the built place with Studio in Edit mode.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local Melee = require(Client.AdvancedSkillMotion)
local Mage = require(Client.K0MageMotion)
local Ranged = require(Client.RangedActionPoses)
local FX = require(Client.HeroVFX)
local Hit = require(Client.K0HitEffects)

local cases = {
    { classId = "knight", id = "knight_guarded_strike", style = "GuardedStrikeContact" },
    { classId = "dwarf", id = "dwarf_low_sweep", style = "LowSweepContact" },
    { classId = "elf", id = "elf.magic_archer.rooting_fan", style = "RootingFanContact" },
    { classId = "mage", id = "mage.cryo.frost_ring", style = "FrostRingContact" },
}
local at = Vector3.new(0, 330, 0)
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
local originalChildren = {}
for _, node in workspace:GetChildren() do originalChildren[node] = true end
camera.CFrame = CFrame.lookAt(at + Vector3.new(8, 10, 16), at)

local checks, failures = 0, {}
local function check(pass, name)
    checks += 1
    if not pass then table.insert(failures, name) end
end

local function reference(d)
    local other = table.clone(d)
    other.id = "fixture:" .. d.id
    Presentation.byId[other.id] = Presentation.get(d)
    return other
end

local function matches(name)
    local matchesByName = {}
    for _, node in workspace:GetChildren() do
        if node.Name == name and not originalChildren[node] then table.insert(matchesByName, node) end
    end
    return matchesByName
end

local function verifyPose(case)
    local d = Catalog.byId[case.id].definition
    local other = reference(d)
    local contact = d.windup + (d.hitDelay or 0)
    local ending = d.windup + d.active + d.recovery
    if case.classId == "knight" or case.classId == "dwarf" then
        for _, rigType in Enum.HumanoidRigType:GetEnumItems() do
            local function difference(joint, age)
                return Melee.sample(case.classId, d, age, rigType).angles[joint].X
                    - Melee.sample(case.classId, other, age, rigType).angles[joint].X
            end
            if case.classId == "knight" then
                check(difference("leftElbow", contact * .55) > 15, "Shield tucked " .. rigType.Name)
                check(difference("leftElbow", contact + .075) > 18, "Shield recovers " .. rigType.Name)
            else
                check(difference("leftKnee", contact) > 24, "Sweep drops the lead knee " .. rigType.Name)
                check(difference("rightKnee", contact) > 20, "Sweep drops the rear knee " .. rigType.Name)
            end
            check(math.abs(difference("torso", ending)) < .05, case.id .. " settles " .. rigType.Name)
        end
    elseif case.classId == "elf" then
        local pose, generic = { angles = {} }, { angles = {} }
        for _, sample in { { pose, d }, { generic, other } } do
            Ranged.bow(sample[1], sample[2], contact + .05, .05, false, 1)
        end
        check(pose.angles.elbow.X - generic.angles.elbow.X > 20, "Rooting Fan opens the draw elbow")
        check(pose.angles.leftKnee.X - generic.angles.leftKnee.X > 13, "Rooting Fan plants the lead leg")
        check((pose.angles.left - generic.angles.left).Magnitude < 3, "Rooting Fan keeps the bow arm on aim")
    else
        local pose = Mage.sample(d, Mage.profile(d), contact + .062)
        local generic = Mage.sample(other, Mage.profile(other), contact + .062)
        check(pose.angles.left.X < generic.angles.left.X - 30, "Frost Ring presses the guiding palm down")
        check(pose.angles.right.X < generic.angles.right.X - 20, "Frost Ring lowers the staff into the cast")
        check(pose.angles.leftKnee.X > generic.angles.leftKnee.X + 12, "Frost Ring plants the lead leg")
    end
    Presentation.byId[other.id] = nil
end

local ok, err = xpcall(function()
    for _, case in cases do verifyPose(case) end
    for _, compact in { false, true } do
        FX.isOtherHero = function() return compact end
        for _, case in cases do
            for _, direction in { Vector3.xAxis, -Vector3.zAxis } do
                FX.clear()
                check(Hit.show(nil, at, 42, case.classId, "Goblin", direction, case.id),
                    case.id .. " accepts confirmed damage")
                local models = matches("HeroVFX")
                local model = models[#models]
                check(model and model:GetAttribute("ContactStyle") == case.style, case.id .. " selects its impact")
                local count = 0
                for _, node in model and model:GetDescendants() or {} do
                    if node:IsA("Beam") and node.Name == case.style then
                        count += 1
                        local from, to = node.Attachment0.WorldPosition, node.Attachment1.WorldPosition
                        check(node.Segments == 4 and node.Width0 > .12, case.id .. " keeps a readable curved edge")
                        check((from - at):Dot(direction) < -.8 and (to - at):Dot(direction) < -.8,
                            case.id .. " sits on the incoming face")
                    end
                end
                check(count == 2 and select(2, FX.count()) == 2, case.id .. " uses two primary beams")
                local holders = matches("K0HitEffect")
                local holder = holders[#holders]
                check(holder and holder.K0DamageNumber.Amount.Text == "42", case.id .. " keeps the damage number")
                check(holder and not holder:FindFirstChild("K0ImpactFlash") and not holder:FindFirstChild("K0SkillImpact"),
                    case.id .. " replaces the generic flash and stamp")
                if holder then holder:Destroy() end
                FX.step(workspace:GetServerTimeNow() + 1)
                check(FX.count() == 0, case.id .. " releases its VFX budget")
            end
        end
    end
end, debug.traceback)
FX.isOtherHero = originalCompact
FX.clear()
camera.CFrame = originalCamera
for _, node in matches("K0HitEffect") do node:Destroy() end
for _, node in matches("PixelFXAccent") do node:Destroy() end
if not ok then table.insert(failures, err) end
print("HERO_CONTROL_ATTACKS " .. game:GetService("HttpService"):JSONEncode({ checks = checks, failures = failures }))
assert(ok and #failures == 0, "Hero control attack presentation regression")
