-- Run on an isolated local place. The input is the client damage callback's payload.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Advanced = require(Shared.AdvancedSkills)
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local Melee = require(Client.AdvancedSkillMotion)
local Mage = require(Client.K0MageMotion)
local Ranged = require(Client.RangedActionPoses)
local FX = require(Client.HeroVFX)
local Hit = require(Client.K0HitEffects)

local styles = {
    oath = "OathSealSet", fracture = "ArmorFaultSet", weakpoint = "WeakpointBracketSet",
    nature = "NatureBudSet", ember = "EmberSealSet", frost = "FrostSealSet",
}
local checks, failures = 0, {}
local function check(pass, label)
    checks += 1
    if not pass then table.insert(failures, label) end
end

local at = Vector3.new(0, 330, 0)
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
local original = {}
for _, node in workspace:GetChildren() do original[node] = true end
camera.CFrame = CFrame.lookAt(at + Vector3.new(8, 8, 16), at)

local function fixture(name)
    for _, node in workspace:GetChildren() do
        if node.Name == name and not original[node] then return node end
    end
end

local function testContact(classId, d, direction, compact)
    FX.clear()
    check(Hit.show(nil, at, 42, classId, "Goblin", direction, d.id, {appliedMark = d.mark}), d.id .. " hit")
    local model, feedback = fixture("HeroVFX"), fixture("K0HitEffect")
    local style = styles[d.mark]
    check(model and model:GetAttribute("ContactStyle") == style, d.id .. " mark set")
    local count = 0
    for _, beam in model and model:GetDescendants() or {} do
        if beam:IsA("Beam") and beam.Name == style then
            count += 1
            check(beam.Segments == 5, d.id .. " curvature")
            check((at - beam.Attachment0.WorldPosition):Dot(direction) > 1, d.id .. " front endpoint")
            check((at - beam.Attachment1.WorldPosition):Dot(direction) > 1, d.id .. " front endpoint")
        end
    end
    check(count == 2, d.id .. " beam budget")
    local number = feedback and feedback:FindFirstChild("K0DamageNumber")
    check(number and number.Amount.Text == "42", d.id .. " damage number")
    check(feedback and not feedback:FindFirstChild("K0ImpactFlash"), d.id .. " no duplicate flash")
    if feedback then feedback:Destroy() end
    FX.clear()
    local fallback, distinct = FX.contact(at, classId, d.id, direction, 1, compact, nil, "wrong mark")
    check(fallback and not distinct, d.id .. " mismatched mark keeps the normal hit")
    check(fallback and fallback:GetAttribute("ContactStyle") ~= style, d.id .. " no false mark")
end

local function comparePose(classId, id, before, after)
    local d = Catalog.byId[id].definition
    local generic = table.clone(d)
    generic.id = "fixture:" .. d.id
    Presentation.byId[generic.id] = Presentation.get(d)
    local contact = d.windup + (d.hitDelay or 0)
    if classId == "knight" or classId == "dwarf" then
        for _, rig in Enum.HumanoidRigType:GetEnumItems() do
            local function sample(definition, age) return Melee.sample(classId, definition, age, rig) end
            before(sample(d, contact * .55), sample(generic, contact * .55))
            after(sample(d, contact + .12), sample(generic, contact + .12))
        end
    elseif classId == "elf" then
        local function sample(definition, age, since)
            local pose = {angles = {}}
            Ranged.bow(pose, definition, age, since, false, 1)
            return pose
        end
        before(sample(d, contact * .55), sample(generic, contact * .55))
        after(sample(d, contact + .05, .05), sample(generic, contact + .05, .05))
    else
        local function sample(definition, age) return Mage.sample(definition, Mage.profile(definition), age) end
        before(sample(d, contact * .58), sample(generic, contact * .58))
        after(sample(d, contact + .062), sample(generic, contact + .062))
    end
    Presentation.byId[generic.id] = nil
end

local ok, err = xpcall(function()
    comparePose("knight", "knight.paladin.radiant_sweep", function(a, b)
        check(a.angles.left.Z < b.angles.left.Z - 10, "Radiant Sweep loads behind the shield")
    end, function(a, b)
        check(a.angles.leftKnee.X > b.angles.leftKnee.X + 12, "Radiant Sweep plants the lead knee")
    end)
    comparePose("dwarf", "dwarf.iron_axe.armor_splitter", function(a, b)
        check(a.angles.left.X > b.angles.left.X + 18, "Armor Splitter braces the free arm")
    end, function(a, b)
        check(a.angles.elbow.X < b.angles.elbow.X - 13, "Armor Splitter pulls the axe clear")
    end)
    comparePose("elf", "elf.marksman.weakpoint_shot", function(a, b)
        check(a.angles.neck.X > b.angles.neck.X + 7, "Weakpoint Shot sights the arrow")
    end, function(a, b)
        check(a.angles.elbow.X > b.angles.elbow.X + 16, "Weakpoint Shot draws the elbow back")
        check((a.angles.left - b.angles.left).Magnitude < .01, "Weakpoint Shot preserves bow aim")
    end)
    comparePose("mage", "mage.pyro.ember_lance", function(a, b)
        check(a.angles.leftElbow.X < b.angles.leftElbow.X - 16, "Ember Lance gathers near the staff")
    end, function(a, b)
        check(a.angles.left.Z < b.angles.left.Z - 15, "Ember Lance turns the guiding palm")
        check((a.angles.right - b.angles.right).Magnitude < .01, "Ember Lance preserves staff aim")
    end)

    local count = 0
    for classId, definitions in Advanced.skills do
        for _, d in definitions do
            if not d.mark then continue end
            count += 1
            for _, compact in {false, true} do
                FX.isOtherHero = function() return compact end
                for _, direction in {Vector3.xAxis, -Vector3.zAxis} do
                    testContact(classId, d, direction, compact)
                end
            end
        end
    end
    check(count == 8, "all mark application skills")

    FX.clear()
    local spend, distinct = FX.contact(at, "knight", "knight.paladin.shield_verdict", Vector3.xAxis, 1, true, "oath")
    check(distinct and spend:GetAttribute("ContactStyle") == "OathSealBreak", "consumption keeps its outward seal")
end, debug.traceback)
FX.clear()
FX.isOtherHero, camera.CFrame = originalCompact, originalCamera
for _, node in workspace:GetChildren() do
    if not original[node] and node.Name == "K0HitEffect" then node:Destroy() end
end
if not ok then table.insert(failures, err) end
local result = {checks = checks, failures = failures}
print(game.HttpService:JSONEncode(result))
assert(#failures == 0, "Mark application regression")
return result
