-- Exercise directional releases on the shipping Studio client modules.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio Place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local Presentation = require(Shared.SkillPresentation)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Geometry = require(Client.SkillEffectGeometry)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Telegraphs = require(Client.K0Telegraphs)
local Hits = require(Client.K0HitEffects)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)

local guardian = Catalog.byId["knight.paladin.guardian_slash"].definition
local scatter = Catalog.byId["dwarf.gunner.scatter_shot"].definition
local fan = Catalog.byId["elf.marksman.fan_break"].definition
local lightning = Catalog.byId["mage.cryo.lightning_line"].definition
local origin, aim = Vector3.new(0, 735, 0), -Vector3.zAxis
local camera = workspace.CurrentCamera
local oldCamera, oldCompact = camera.CFrame, FX.isOtherHero
camera.CFrame = CFrame.lookAt(origin + Vector3.new(7, 12, 18), origin + aim*4)
local report = {checks = 0, failures = {}}
local stage = Instance.new("Folder", workspace)
local warnings
local original = {}
for _, item in workspace:GetChildren() do original[item] = true end

local function check(ok, label)
    report.checks += 1
    if not ok then table.insert(report.failures, label) end
end

local function anchored(parent, name, at)
    local part = Instance.new("Part")
    part.Name, part.Anchored, part.Position = name, true, at
    part.Parent = parent
    return part
end

local function actor(parent, at)
    local model = Instance.new("Model", parent)
    anchored(model, "HumanoidRootPart", at).CanCollide = false
    return model
end

local function named(model, name)
    local found = {}
    for _, item in model and model:GetDescendants() or {} do
        if item.Name == name then table.insert(found, item) end
    end
    return found
end

local function release(id)
    for _, item in workspace:GetChildren() do
        if item.Name == "HeroVFX" and item:GetAttribute("SkillId") == id then return item end
    end
end

local function clear()
    FX.clear()
    for _, item in workspace:GetChildren() do
        if not original[item] then item:Destroy() end
    end
end

local world = workspace:FindFirstChild("DeepwoodK0") or Instance.new("Folder", workspace)
local ownWorld = not original[world]
original[world] = true
world.Name = "DeepwoodK0"
local blockout = world:FindFirstChild("TerrainBlockout")
local ownBlockout = blockout == nil
blockout = blockout or Instance.new("Folder", world)
blockout.Name = "TerrainBlockout"
local enemies = Instance.new("Folder", world)
local floor = anchored(blockout, "Floor", origin - Vector3.yAxis*3)
floor.Size = Vector3.new(55, 1, 55)
local caster = actor(stage, origin)
local function poses()
    local plain = table.clone(guardian)
    plain.id = "guardian_fixture"
    Presentation.byId[plain.id] = Presentation.get(guardian)
    for _, rig in Enum.HumanoidRigType:GetEnumItems() do
        local age = guardian.windup*.54
        local load = Melee.sample("knight", guardian, age, rig)
        local generic = Melee.sample("knight", plain, age, rig)
        check(load.angles.leftElbow.X - generic.angles.leftElbow.X > 19, rig.Name.." guardian covers the sword shoulder")
        age = guardian.windup+.048
        local follow = Melee.sample("knight", guardian, age, rig)
        generic = Melee.sample("knight", plain, age, rig)
        check(follow.angles.leftKnee.X - generic.angles.leftKnee.X > 16, rig.Name.." guardian weights the front foot")
        local shot = Melee.sample("dwarf", scatter, scatter.windup+.04, rig)
        local settle = Melee.sample("dwarf", scatter, scatter.windup+.115, rig)
        check(shot.offhand and settle.offhand and shot.angles.leftKnee.X-settle.angles.leftKnee.X > 18
            and settle.angles.rightKnee.X-shot.angles.rightKnee.X > 4,
            rig.Name.." scatter transfers weight from the rear foot to the lead foot")
    end
    Presentation.byId[plain.id] = nil
    local bow = {angles = {}}
    Bow.bow(bow, fan, fan.windup+.052, .052, false, 1)
    check(bow.angles.leftKnee.X > 32 and bow.angles.elbow.X > 21, "Fan Break opens the elbow over the lead foot")
    local cast = Mage.sample(lightning, Mage.profile(lightning), lightning.windup+.064)
    check(cast.angles.torso.X > 12 and cast.angles.leftKnee.X > 34, "Lightning Line drives the palm through a planted stance")
end

local function releases()
    local cover = anchored(stage, "Cover", origin+aim*8.7)
    cover.Size = Vector3.new(1, 5, 1)
    local wall
    local state = {character=caster, root=caster.HumanoidRootPart}
    local attack = {definition=lightning, direction=aim, advancedCast={origin=origin,center=origin+aim*lightning.range}}
    Combat.resolve(state, attack, workspace:GetServerTimeNow(), {enemies={},visual=function(_, _, _, endpoint)
        wall=endpoint
    end}, 1)
    cover:Destroy()
    check(wall and (wall-origin-aim*8).Magnitude < .01, "The server clips the lightning release before the wall")
    assert(wall, "Missing server release endpoint")
    for _, compact in {false, true} do
        FX.isOtherHero = function() return compact end
        Visual.play(caster, guardian.id, origin, origin+aim*3, 1, {}, nil, nil, nil, aim)
        local gold = release(guardian.id)
        local edge = named(gold, "GuardianShelteringWing")
        check(#edge == (compact and 5 or 8), "Guardian Slash uses one cut with the expected segment count")
        check(#named(gold, "GuardianShieldVeil") == 0 and not workspace:FindFirstChild("BladeCrescent"),
            "Guardian Slash removes the overlapping veil and generic second cut")
        check(workspace:FindFirstChild("SkillSector"), "Guardian Slash retains its damage boundary")
        local low, high = math.huge, -math.huge
        for _, beam in edge do
            for _, point in {beam.Attachment0.WorldPosition, beam.Attachment1.WorldPosition} do
                local offset = point-origin
                local horizontal = Vector3.new(offset.X, 0, offset.Z)
                low, high = math.min(low, point.Y), math.max(high, point.Y)
                check(horizontal:Dot(aim) > 0 and horizontal.Magnitude <= guardian.range,
                    "Guardian Slash follows the confirmed forward sector")
            end
        end
        check(high-low > 1.1, "Guardian Slash changes blade height through the cut")
        clear()

        for _, definition in {scatter, fan} do
            local endpoints = Geometry.sector(origin, aim, definition.range, definition.angle, 4)
            endpoints[3] = origin+aim*.7
            local muzzle = origin+aim*2
            local isScatter = definition == scatter
            local model = FX.skill(caster, definition.id, origin, endpoints[3], 1, {}, muzzle, aim, endpoints)
            local traces = named(model, isScatter and "ScatterPelletTrace" or "FanBreakShaft")
            check(#traces == 5, definition.id.." keeps five simulated release lanes")
            local center = traces[3]
            check(center and (center.Attachment0.WorldPosition-origin).Magnitude < .01
                and (center.Attachment1.WorldPosition-endpoints[3]).Magnitude < .01,
                definition.id.." near cover clamps the middle lane before the weapon socket")
            if isScatter then
                local flash = named(model, "ScatterMuzzleKick")[1]
                check(compact and flash == nil or not compact and flash
                    and (flash.Attachment1.WorldPosition-origin):Dot(aim) <= .71,
                    "Scatter Shot local muzzle flash stays before close cover")
            else
                check(#named(model, "VolleyArrowhead") == 10 and #named(model, "ProjectileSurface") == 0,
                    "Fan Break shows paired arrowheads and no extra projectile surface")
            end
            FX.step(workspace:GetServerTimeNow()+.125)
            local side = traces[2]
            check(side and (side.Transparency.Keypoints[1].Value > .99) == isScatter,
                definition.id.." pellet traces clear before the arrow wake")
            clear()
        end

        Visual.play(caster, lightning.id, origin, wall, 1, {}, nil, nil, nil, aim)
        local bolt = release(lightning.id)
        local spine = named(bolt, "IconLightningCorridor")[1]
        local firstHead = spine and (spine.Attachment1.WorldPosition-origin):Dot(aim)
        check(firstHead and firstHead > 0 and firstHead < 2, "Lightning Line first frame starts near the caster")
        FX.step(workspace:GetServerTimeNow()+.052)
        local middle = spine and (spine.Attachment1.WorldPosition-origin):Dot(aim)
        check(middle and middle > 3 and middle < 7.9, "Lightning Line head travels along the confirmed axis")
        FX.step(workspace:GetServerTimeNow()+.13)
        check(spine and math.abs((spine.Attachment1.WorldPosition-wall):Dot(aim)) < .01
            and math.abs(spine.Attachment1.WorldPosition.Y-(floor.Position.Y+.80)) < .03,
            "Lightning Line stops at the wall along the floor")
        check(#named(bolt, "LightningLineFork") == (compact and 2 or 3)
            and #named(bolt, "LightningLineForkTip") == (compact and 0 or 3),
            "Lightning Line keeps fewer branches for allies")
        check(#named(bolt, "ElectricSpearSpine") == 0, "Lightning Line avoids a duplicate static core")
        clear()
    end
end

local function overlap()
    local player = Instance.new("Folder", stage)
    player:SetAttribute("K0SessionPhase", "Tutorial")
    caster.Name = "Character"
    caster.Parent = player
    Instance.new("Humanoid", caster).RequiresNeck = false
    local target = actor(enemies, origin+aim*4)
    target:SetAttribute("K0EnemyState", "Windup")
    target:SetAttribute("K0Telegraph", "Unblockable")
    target:SetAttribute("K0AttackOrigin", target.HumanoidRootPart.Position)
    target:SetAttribute("K0AttackDirection", aim)
    target:SetAttribute("K0AttackRange", 9)
    target:SetAttribute("K0AttackAngle", 360)
    warnings = Telegraphs.create(enemies, player)
    FX.isOtherHero = function(character) return character and character ~= caster end
    local elf
    for i, skill in {guardian, scatter, fan, lightning} do
        local at = origin+Vector3.xAxis*(i-2)*1.8
        local hero = i == 1 and caster or actor(stage, at)
        if skill == fan then elf = hero end
        local endpoints = Presentation.get(skill).fanLanes and Geometry.sector(at, aim, skill.range, skill.angle, 4)
        Visual.play(hero, skill.id, at, at+aim*8, 1, {}, nil, nil, nil, aim, nil, nil, endpoints)
    end
    local active, beams, _, glows, particles, surfaces = FX.count()
    warnings.update()
    local red = 0
    for _, edge in workspace.K0LocalTelegraphs:GetDescendants() do
        if edge:IsA("BasePart") and edge.Transparency < 1 and edge.Color == Color3.fromRGB(255, 73, 58) then red += 1 end
    end
    local hit = Hits.show(target, target.HumanoidRootPart.Position, 42, "elf", "Goblin", aim, fan.id, {attacker=elf})
    local number = workspace:FindFirstChild("K0HitEffect")
    report.overlap = {beams=beams, surfaces=surfaces, glows=glows, particles=particles, redSegments=red}
    check(active == 4 and glows == 0 and particles == 0, "Four releases retain their core shapes with no extra glow or particles")
    check(red == 16, "Enemy warning retains all 16 red segments")
    check(hit and number and number.K0DamageNumber.Amount.Text == "42", "Confirmed hit retains its damage number")
end

local ok, errorMessage = xpcall(function()
    poses()
    releases()
    overlap()
end, debug.traceback)
if warnings then warnings.destroy() end
clear()
floor:Destroy()
if ownBlockout then blockout:Destroy() end
if ownWorld then world:Destroy() end
stage:Destroy()
camera.CFrame, FX.isOtherHero = oldCamera, oldCompact
if not ok then table.insert(report.failures, errorMessage) end
report.pass = #report.failures == 0
print("HERO_DIRECTIONAL_RELEASES_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass, table.concat(report.failures, "\n"))
