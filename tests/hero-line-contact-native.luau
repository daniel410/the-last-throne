assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Hits = require(Client.K0HitEffects)
local Melee = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local camera = workspace.CurrentCamera
local savedCamera = camera.CFrame
local at = Vector3.new(0, 320, 0)
camera.CFrame = CFrame.lookAt(at + Vector3.new(10, 8, 14), at)

local report = {checks = 0, failures = {}}
local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end
local cases = {
    {"knight.steel_knight.vanguard_strike", "VanguardContactFins", 1, -.15, "leftHip", "X", -12},
    {"dwarf_braced_throw", "BracedThrowContactHooks", 1, -.85, "leftHip", "X", -12},
    {"elf.marksman.piercing_line", "PiercingLineContactBarbs", 1, 0, "leftHip", "X", -19},
    {"mage.cryo.lightning_line", "LightningLineContactFork", -1, .85, "leftElbow", "X", 27},
}
local target = Instance.new("Model", workspace)
local root = Instance.new("Part", target)
root.Name, root.Anchored, root.Position = "HumanoidRootPart", true, at
for _, case in cases do
    local id, style, sign, rise, channel, axis, minAngle = unpack(case)
    local row = assert(Catalog.byId[id])
    local class, d = row.classId, row.definition
    for _, heading in {Vector3.xAxis, -Vector3.zAxis} do
        for _, compact in {false, true} do
            local rendered, distinct = FX.contact(at, class, id, heading, 1, compact)
            check(distinct and rendered:GetAttribute("ContactStyle") == style, id .. " selects its contact silhouette")
            local _, beams, chips, glows, particles, faces = FX.count()
            check(beams == 2 and chips + glows + particles + faces == 0, id .. " spends two beams")
            local count = 0
            for _, beam in rendered:GetDescendants() do
                if beam:IsA("Beam") and beam.Name == style then
                    count += 1
                    local delta = beam.Attachment1.WorldPosition - beam.Attachment0.WorldPosition
                    check(delta:Dot(heading) * sign > .65, id .. " follows the confirmed attack axis")
                    check(rise == 0 and math.abs(delta.Y) < .13 or rise > 0 and delta.Y > rise
                        or rise < 0 and delta.Y < rise, id .. " has the intended vertical shape")
                    check(beam.Segments == 4 and math.abs(beam.CurveSize0) > .03, id .. " has a curved profile")
                end
            end
            check(count == 2, id .. " keeps both edges")
            FX.clear()
        end
    end
    check(Hits.show(target, at, 42, class, "Goblin", -Vector3.zAxis, id, {pulse = 1}), id .. " uses confirmed damage")
    local holder = assert(workspace:FindFirstChild("K0HitEffect"))
    check(holder.K0DamageNumber.Amount.Text == "42", id .. " keeps the damage number")
    check(not holder:FindFirstChild("K0ImpactFlash") and not holder:FindFirstChild("K0SkillImpact"),
        id .. " replaces the overlapping default burst")
    holder:Destroy()
    FX.clear()

    local age = d.windup + .065
    local function checkPose(pose, suffix)
        local actual = pose.angles[channel] and pose.angles[channel][axis]
        check(actual and math.sign(minAngle) * actual >= math.abs(minAngle), id .. " takes the release in the body " .. suffix)
    end
    if class == "elf" or class == "mage" then
        local pose = {angles = {}}
        if class == "elf" then
            Ranged.bow(pose, d, age, .065, false, 1)
        else
            Ranged.mage(pose, d, Mage.profile(d), age)
        end
        checkPose(pose, "ranged")
    else
        for _, rig in {Enum.HumanoidRigType.R6, Enum.HumanoidRigType.R15} do
            checkPose(Melee.sample(class, d, age, rig), rig.Name)
        end
    end
end
target:Destroy()
camera.CFrame = savedCamera
report.pass = #report.failures == 0
print("HERO_LINE_CONTACT_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, "Hero line contact regression")
