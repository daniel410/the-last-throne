-- Exercise server cover, the release receiver and the target contact in Studio.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0, "Isolated Studio place required")
local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Catalog = require(game.ReplicatedStorage.Shared.PixelFXCatalog)
local Combat = require(game.ServerScriptService.Server.Combat.AdvancedCombat)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Geometry = require(Client.SkillEffectGeometry)
local Melee = require(Client.AdvancedSkillMotion)
local Bow = require(Client.K0BowMotion)
local Mage = require(Client.K0MageMotion)
local checks, failures = 0, {}
local stage = Instance.new("Folder", workspace)
local camera = workspace.CurrentCamera
local originalCamera, originalCompact = camera.CFrame, FX.isOtherHero
local origin, aim = Vector3.new(0, 890, 0), -Vector3.zAxis
local initial = {}
for _, node in workspace:GetChildren() do initial[node] = true end

local function check(condition, label)
    checks += 1
    if not condition then table.insert(failures, label) end
end

local function actor(at)
    local model = Instance.new("Model", stage)
    local root = Instance.new("Part", model)
    root.Name, root.Anchored, root.CanCollide, root.Position = "HumanoidRootPart", true, false, at
    return model, root
end

local function named(model, name)
    local found = {}
    if model then
        for _, item in model:GetDescendants() do
            if item.Name == name then table.insert(found, item) end
        end
    end
    return found
end

local function releaseModel(id)
    for _, item in workspace:GetChildren() do
        if item.Name == "HeroVFX" and item:GetAttribute("SkillId") == id then return item end
    end
end

local function clean()
    FX.clear()
    for _, item in workspace:GetChildren() do
        if not initial[item] then item:Destroy() end
    end
end

local function measureLanes()
    local character, root = actor(origin)
    local front, frontRoot = actor(origin+aim*2)
    local behind, behindRoot = actor(origin+aim*11)
    local ally, allyRoot = actor(origin+aim)
    allyRoot.CanCollide = true
    local wall = Instance.new("Part", stage)
    wall.Size, wall.Position, wall.Anchored = Vector3.new(1, 5, 1), origin+aim*5, true
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, front, behind, ally}
    params.RespectCanCollide = true
    local services = {
        enemies = {
            [front] = {id=1, model=front, root=frontRoot, humanoid=Instance.new("Humanoid", front)},
            [behind] = {id=2, model=behind, root=behindRoot, humanoid=Instance.new("Humanoid", behind)},
        },
        clear = function(a,b) return not workspace:Raycast(a,b-a,params) end,
        visualRayParams = function() return params end,
    }
    local cases = {
        {"dwarf.gunner.scatter_shot", "ScatterPelletTrace", 0, "ShotPellet"},
        {"elf.marksman.fan_break", "FanBreakShaft", 10, "ArrowWake"},
        {"elf.marksman.piercing_volley", "PiercingVolleyShaft", 10, "ArrowWake"},
    }
    for _, case in cases do
        local id, strokeName, arrowheads, fallbackName = unpack(case)
        local d = Catalog.byId[id].definition
        local state = {root=root, character=character}
        local cast = {origin=origin, center=frontRoot.Position}
        local endpoints, hitCount
        hitCount = 0
        services.damage = function(_, enemy, _, _, direction, pulse)
            hitCount += 1
            check(enemy.model == front and direction == aim and pulse == 1, id.." damage remains on visible target")
        end
        services.visual = function(_, _, at, center, _, points, direction, lanes)
            check(at == root.Position and center == frontRoot.Position and direction == aim, id.." confirmed cast inputs")
            check(#points == 1 and points[1] == frontRoot.Position, id.." hit positions remain separate")
            endpoints = lanes
        end
        Combat.resolve(state, {definition=d, direction=aim, advancedCast=cast}, 2, services, 1)
        check(hitCount == 1, id.." no extra damage")
        check(endpoints and #endpoints == 5, id.." server sends five visible endpoints")
        if endpoints then
            check((endpoints[3]-origin-aim*4.3).Magnitude < .01, id.." wall clips center independently")
            local open = Geometry.sector(origin,aim,d.range,d.angle,4)
            for _, index in {1,2,4,5} do
                check((endpoints[index]-open[index]).Magnitude < .01, id.." unobstructed lane "..index.." keeps reach")
            end
        else
            endpoints = Geometry.sector(origin,aim,d.range,d.angle,4)
            endpoints[3] = origin+aim*4.3
        end
        for _, compact in {false,true} do
            FX.isOtherHero = function() return compact end
            local before = {}
            for _, child in workspace:GetChildren() do before[child] = true end
            Visual.play(character,id,origin,frontRoot.Position,1,{frontRoot.Position},nil,nil,nil,aim,nil,nil,endpoints)
            local release = releaseModel(id)
            local strokes = named(release, strokeName)
            check(#strokes == 5, id.." one primary trace for each lane")
            check(#named(release, "VolleyArrowhead") == arrowheads, id.." arrowhead silhouette")
            check(#named(release,"SoftGlow") == 0, id.." trace excludes overlapping glow")
            for _, beam in strokes do
                local endpoint = beam.Attachment1.WorldPosition
                local matched = false
                for _, target in endpoints do
                    if (endpoint-target).Magnitude < .01 then matched = true end
                end
                check(matched, id.." beam stops at a confirmed endpoint")
                check((beam.Attachment0.WorldPosition-origin).Magnitude < .01, id.." starts at the caster")
            end
            for _, child in workspace:GetChildren() do
                if not before[child] then
                    check(child.Name ~= fallbackName and child.Name ~= "SkillContact", id.." no duplicate fallback or hit flare")
                    if child.Name ~= "HeroVFX" then child:Destroy() end
                end
            end
            FX.clear()
        end
        local muzzle = origin+aim*5
        local release = FX.skill(character,id,origin,frontRoot.Position,1,{},muzzle,aim,endpoints)
        local strokes = named(release,strokeName)
        check(#strokes == 5, id.." short cover still draws the five silhouettes")
        for _, beam in strokes do
            local endpoint = beam.Attachment1.WorldPosition
            local expect = (endpoint-endpoints[3]).Magnitude < .01 and origin or muzzle
            check((beam.Attachment0.WorldPosition-expect).Magnitude < .01, id.." clipped lane cannot start past wall")
        end
        local started=workspace:GetServerTimeNow()
        FX.step(started+.028)
        for _, beam in strokes do
            local endpoint = beam.Attachment1.WorldPosition
            local expect = (endpoint-endpoints[3]).Magnitude < .01 and origin or muzzle
            check((beam.Attachment0.WorldPosition-expect).Magnitude < .01, id.." readable launch connection at 28ms")
        end
        FX.step(started+.13)
        for _, beam in strokes do
            local endpoint = beam.Attachment1.WorldPosition
            local expect = (endpoint-endpoints[3]).Magnitude < .01 and origin or muzzle
            check((beam.Attachment0.WorldPosition-expect).Magnitude > .5, id.." trace recedes after release connection")
        end
        FX.step(workspace:GetServerTimeNow()+1)
        check(FX.count()==0, id.." releases expire")
    end
end

local function measureCulledRelease()
    FX.isOtherHero = function() return true end
    local character = actor(origin)
    local filler = "elf.marksman.piercing_volley"
    for _ = 1, 13 do FX.skill(character,filler,origin,origin+aim*8,1,{},nil,aim) end
    local id = "dwarf.gunner.scatter_shot"
    local d = Catalog.byId[id].definition
    local endpoints = Geometry.sector(origin,aim,d.range,d.angle,4)
    endpoints[3] = origin+aim*2
    local before = {}
    for _, node in workspace:GetChildren() do before[node] = true end
    Visual.play(character,id,origin,origin+aim*3,1,{},nil,nil,nil,aim,nil,nil,endpoints)
    check(releaseModel(id)==nil,"Fixture saturates the optional effect budget")
    local count, short = 0, 0
    for _, node in workspace:GetChildren() do
        if not before[node] and node.Name=="ShotPellet" then
            count += 1
            if math.abs(node.Size.Z-2)<.01 and (node.Position-origin-aim).Magnitude<.01 then short += 1 end
        end
    end
    check(count==5 and short==1,"Fallback pellet traces keep the clipped center lane")
    FX.clear()
end

local function measureOtherReleases()
    FX.isOtherHero = function() return false end
    local ground = Instance.new("Part", stage)
    ground.Size, ground.Position, ground.Anchored = Vector3.new(60,1,60),origin-Vector3.yAxis*3,true
    local releaseCases = {
        {"knight.steel_knight.rallying_slash","knight","RallyingSlashEdge","RallyingSlashContact",9},
        {"mage.pyro.steam_burst","mage","SteamFlashLip","SteamContactJets",6},
        {"dwarf.gunner.scatter_shot","dwarf","ScatterPelletTrace","ScatterPelletContact",5},
        {"elf.marksman.piercing_volley","elf","PiercingVolleyShaft","PiercingVolleyContact",5},
    }
    for _, sample in releaseCases do
        local id, class, stroke, contact, count = unpack(sample)
        local d = Catalog.byId[id].definition
        local caster = actor(origin)
        local center = origin+aim*5
        local release = FX.skill(caster,id,origin,center,1,{},nil,aim)
        local strokes = named(release,stroke)
        check(#strokes==count,id.." primary release geometry")
        if class == "knight" and #strokes == count then
            check(strokes[count].Attachment1.WorldPosition.Y-strokes[1].Attachment0.WorldPosition.Y>2,
                "Sword climbs from a low entry")
            check(#named(release,"BladeSurface")==0,"Sword arc leaves open space")
        elseif class == "mage" and #strokes == count then
            local wisps = named(release,"SteamWisp")
            check(#wisps==6,"Two rising steam paths")
            local lip = strokes[1].Attachment0.WorldPosition
            local high = wisps[#wisps].Attachment1.WorldPosition.Y
            FX.step(workspace:GetServerTimeNow()+.14)
            check((strokes[1].Attachment0.WorldPosition-lip).Magnitude>.6,"Steam pressure expands first")
            check(wisps[#wisps].Attachment1.WorldPosition.Y>high+.18,"Vapor visibly lifts")
        end
        FX.clear()
        local impact, distinct = FX.contact(center,class,id,aim,1,false)
        check(distinct and #named(impact,contact)==2,id.." distinct confirmed contact")
        FX.clear()
        local elapsed = d.windup+.057
        local pose
        if class == "elf" or class == "mage" then
            caster:SetAttribute("K0ClassId",class)
            caster:SetAttribute("K0AttackSeq",1)
            caster:SetAttribute("K0AttackStartedAt",10)
            caster:SetAttribute("K0State","Attack")
            caster:SetAttribute("K0SkillId",id)
            caster:SetAttribute("K0AttackAim","1|0|0|-1")
            if class == "elf" then
                Bow.confirmPulse(caster,id,1,1,10+d.windup,10,10+elapsed)
                pose = Bow.forCharacter(caster,10+elapsed)
                check(pose and math.abs(pose.angles.weapon.Z)<16,"Piercing Volley holds the bow near upright")
            else
                pose = Mage.forCharacter(caster,10+elapsed)
                check(pose ~= nil,"Steam Burst is sampled through the staff rig")
            end
        else
            for _, rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
                pose = Melee.sample(class,d,elapsed,rig)
                local load = Melee.sample(class,d,d.windup*.58,rig)
                check(pose and load and (pose.angles.torso-load.angles.torso).Magnitude>12,
                    id.." shifts weight through contact "..rig.Name)
                if class == "dwarf" then check(pose.offhand and pose.angles.leftElbow.X < -32,"Scatter firing elbow absorbs recoil") end
            end
        end
    end
end

camera.CFrame = CFrame.lookAt(origin + Vector3.new(8,13,18),origin)
local ok, err = xpcall(function()
    measureLanes()
    measureCulledRelease()
    measureOtherReleases()
end, debug.traceback)
clean()
stage:Destroy()
FX.isOtherHero, camera.CFrame = originalCompact, originalCamera
if not ok then table.insert(failures, err) end
print("HERO_RELEASE_SHAPES_NATIVE "..game.HttpService:JSONEncode({checks=checks, failures=failures}))
assert(#failures==0, table.concat(failures,"\n"))
