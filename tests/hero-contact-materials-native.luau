assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local FX = require(Client.HeroVFX)
local Hits = require(Client.K0HitEffects)
local camera = workspace.CurrentCamera
local originalCamera = camera.CFrame
local at, direction = Vector3.new(0, 735, 0), -Vector3.zAxis
camera.CFrame = CFrame.lookAt(at + Vector3.new(14, 8, 14), at)

local report = {checks = 0, failures = {}}
local function check(condition, label)
    report.checks += 1
    if not condition then table.insert(report.failures, label) end
end

local function findAll(model, name)
    local found = {}
    for _, node in model:GetDescendants() do
        if node.Name == name then table.insert(found, node) end
    end
    return found
end

local function snapshot(model, stroke)
    return assert(model:FindFirstChild(stroke, true)).Attachment0.WorldPosition
end

for _, classId in {"knight", "dwarf", "elf"} do
    local now = workspace:GetServerTimeNow()
    local hit = assert(FX.contact(at, classId, nil, direction, 1))
    local rays = findAll(hit, "ArcadeImpactStar")
    local core = assert(hit:FindFirstChild("ArcadeImpactCore", true))
    check(#rays >= 4 and #rays <= 8, classId .. " uses four tapered rays")
    FX.step(now + .09)
    check(core.Transparency == 1 and rays[1].Transparency < 1, classId .. " flash expires before the rays")
    check(not hit:FindFirstChild("ContactVolume", true), classId .. " uses one flash at contact")
    FX.step(now + .16)
    check(rays[1].Transparency == 1, classId .. " rays clear during recovery")
    FX.clear()
end

for _, row in {
    {"mage.common.water_ball", "WaterContact", "WaterSplash", true},
    {"mage.common.gravity", "GravityContact", "GravityCollapse", false},
} do
    local id, stroke, style, water = table.unpack(row)
    for _, compact in {false, true} do
        local now = workspace:GetServerTimeNow()
        local hit, distinct = FX.contact(at, "mage", id, direction, 1, compact)
        check(distinct and hit:GetAttribute("ContactStyle") == style, id .. " provides one recognized contact")
        local beams = findAll(hit, stroke)
        local drops = findAll(hit, "WaterContactDrop")
        check(#beams == 2 and #drops == (water and not compact and 3 or 0), id .. " has a bounded silhouette")
        local initial = snapshot(hit, stroke)
        FX.step(now + .10)
        local later = snapshot(hit, stroke)
        check(water and (later-at).Magnitude > (initial-at).Magnitude or not water and (later-at).Magnitude < (initial-at).Magnitude,
            id .. " moves in the intended direction")
        check(not hit:FindFirstChild("ImpactFlare", true), id .. " uses its material silhouette instead of a halo")
        if not compact then
            FX.step(now + .195)
            check(beams[1].Transparency.Keypoints[1].Value == 1, id .. " spray or collapse has ended")
            if water and drops[1] then
                check(drops[1].Transparency < 1 and (drops[1].Position-at):Dot(direction) > .2, "water drops follow through after the splash")
            end
        end
        FX.step(now + .4)
        local records, lines, chips, glows, particles, faces = FX.count()
        check(not hit.Parent and records + lines + chips + glows + particles + faces == 0, id .. " releases the shared budgets")
    end
    check(Hits.show(nil, at, 61, "mage", "Goblin", direction, id), id .. " renders a server-confirmed hit")
    local holder = assert(workspace:FindFirstChild("K0HitEffect"))
    check(holder.K0DamageNumber.Amount.Text == "61", id .. " keeps confirmed damage legible")
    check(not holder:FindFirstChild("K0ImpactFlash") and not holder:FindFirstChild("K0SkillImpact"), id .. " removes duplicate legacy flashes")
    holder:Destroy()
    FX.clear()
end

for _, example in {
    {"mage.pyro.cinder_ring", "HeatContactRise", 1},
    {"mage.cryo.frost_lance", "FrostContactFacet", 1},
    {"mage.pyro.earth_rise", "EarthContactFracture", -1},
} do
    local now = workspace:GetServerTimeNow()
    local hit = assert(FX.contact(at, "mage", example[1], direction, 1))
    local stroke = assert(hit:FindFirstChild(example[2], true))
    check((stroke.Attachment1.WorldPosition.Y-at.Y)*example[3] > .12, example[1] .. " has a directional silhouette")
    FX.step(now + .20)
    check(stroke.Transparency.Keypoints[1].Value == 1, example[1] .. " contact stroke fades quickly")
    FX.clear()
end

camera.CFrame = originalCamera
report.pass = #report.failures == 0
print("HERO_CONTACT_MATERIALS_NATIVE " .. game.HttpService:JSONEncode(report))
assert(report.pass, table.concat(report.failures, "\n"))
