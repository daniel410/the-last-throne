assert(game.PlaceId == 0, "Use a local review place")

local Client = game.StarterPlayer.StarterPlayerScripts.Client
local Shared = game.ReplicatedStorage.Shared
local Catalog = require(Shared.PixelFXCatalog)
local FX = require(Client.HeroVFX)
local Visual = require(Client.AdvancedSkillVisual)
local Motion = require(Client.AdvancedSkillMotion)
local Ranged = require(Client.RangedActionPoses)
local Mage = require(Client.K0MageMotion)
local Telegraphs = require(Client.K0Telegraphs)
local Hits = require(Client.K0HitEffects)

local rows = {
    {"knight.paladin.oath_challenge", "OathChallengeCrown", "OathChallengeContact", "OathSealBreak", 6, 4},
    {"dwarf.iron_axe.breaker_throw", "BreakerThrowWake", "BreakerThrowContact", "ArmorFaultBreak", 1, 1},
    {"elf.marksman.mark_breaker", "MarkBreakerWake", "MarkBreakerContact", "WeakpointBracketBreak", 1, 1},
    {"mage.pyro.magma_spear", "MagmaSpearWake", "MagmaSpearContact", "EmberVentBreak", 1, 1},
}

local stage = Instance.new("Folder", workspace)
local camera = workspace.CurrentCamera
local oldCamera = camera.CFrame
local origin = Vector3.new(0, 124, 0)
local aim = -Vector3.zAxis
local endpoint = origin + aim * 8
local socket = origin + Vector3.new(.6, .4, -1.4)
camera.CFrame = CFrame.lookAt(origin + Vector3.new(10, 7, 12), origin)
local floor = Instance.new("Part", stage)
floor.Size = Vector3.new(48, 1, 48)
floor.Position = origin - Vector3.yAxis * 3.5
floor.Anchored = true

local report = {checks = 0, failures = {}}
local function check(value, label)
    report.checks += 1
    if not value then table.insert(report.failures, label) end
end
local function matches(parent, name)
    local result = {}
    if parent then
        for _, child in parent:GetDescendants() do
            if child.Name == name then table.insert(result, child) end
        end
    end
    return result
end
local function part(name, position, parent)
    local p = Instance.new("Part", parent)
    p.Name = name
    p.Position = position
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    return p
end
local function near(a, b)
    return a and b and (a-b).Magnitude < .02
end
local function sample(d, classId, age, rig)
    if classId == "elf" then
        local pose = {angles = {}}
        Ranged.bow(pose, d, age, age>=d.windup and age-d.windup or nil, false, 1)
        return pose
    end
    if classId == "mage" then
        return Mage.sample(d, Mage.profile(d), age)
    end
    return Motion.sample(classId, d, age, rig)
end

local originalIsOther = FX.isOtherHero
local ok, err = xpcall(function()
    local actor = Instance.new("Model", stage)
    local weapon = Instance.new("Model", actor)
    weapon:SetAttribute("WeaponClassId", "dwarf")
    local axe = part("Weapon", socket, weapon)
    axe.LocalTransparencyModifier = .2
    part("NockedArrow", socket, actor)
    local grip = part("WeaponGrip", origin+Vector3.new(-.8,.8,-.3), actor)
    local tip = Instance.new("Attachment", grip)
    tip.Name = "WeaponTip"

    for _, compact in {false, true} do
        FX.isOtherHero = function() return compact end
        for _, item in rows do
            local id, release, normal, consumed, full, ally = unpack(item)
            local row = Catalog.byId[id]
            local d = row.definition
            local at = d.form=="cone" and origin + Vector3.xAxis*4 or endpoint
            local model = FX.skill(actor,id,origin,at,1,{},socket,aim)
            local edges = matches(model, release)
            check(#edges == (compact and ally or full), id .. " release edge count")
            check(model and not model:FindFirstChild("ElementalFlare",true)
                and #matches(model,"SoftGlow") == 0, id .. " has no generic flash or duplicate halo")
            if d.form=="cone" then
                local bounded = #edges>0
                for _, edge in edges do
                    for _, attachment in {edge.Attachment0,edge.Attachment1} do
                        local delta = attachment.WorldPosition-origin
                        local planar = Vector3.new(delta.X,0,delta.Z)
                        bounded = bounded and planar.Magnitude<=d.range
                            and planar.Unit:Dot(aim)>=math.cos(math.rad(d.angle*.5))
                    end
                end
                check(bounded,"alternate selected target leaves the crown on server aim")
            else
                local edge = edges[1]
                check(edge and near(edge.Attachment0.WorldPosition,socket)
                    and near(edge.Attachment1.WorldPosition,endpoint), id .. " uses the socket and confirmed endpoint")
                FX.step(workspace:GetServerTimeNow()+.10)
                check(edge and (edge.Attachment0.WorldPosition-socket).Magnitude>1
                    and near(edge.Attachment1.WorldPosition,endpoint), id .. " retracts toward impact")
            end
            if row.classId=="dwarf" then
                local moving = matches(model,"ThrownAxeSource")[1]
                check(axe.LocalTransparencyModifier==1 and #matches(model,"ThrownAxeSource")==1,
                    "one visible axe during release")
                check(moving and near(moving.Position,endpoint),"thrown axe arrives on the confirmed endpoint")
                FX.step(workspace:GetServerTimeNow()+.16)
                check(math.abs(axe.LocalTransparencyModifier-.2)<.001,"held axe restored in recovery")
            elseif row.classId=="mage" then
                check(#matches(model,"MagmaSpearLip")==2 and #matches(model,"MagmaBasaltCrust")==1
                    and #matches(model,"FlameTongue")==0,"Magma Spear renders a compact tapered head")
                check((#matches(model,"MagmaMoltenEdge")>0)~=compact,"only the owner receives the filled molten edge")
            end
            FX.clear()
            if d.form~="cone" then
                local clipped = origin+aim*.3
                local closeModel = FX.skill(actor,id,origin,clipped,1,{},socket,aim)
                local edge = matches(closeModel,release)[1]
                check(edge and near(edge.Attachment0.WorldPosition,origin)
                    and near(edge.Attachment1.WorldPosition,clipped),id .. " handles cover before the socket")
                FX.clear()
            end

            local ordinary = FX.contact(endpoint,row.classId,id,aim,1,compact)
            check(ordinary and ordinary:GetAttribute("ContactStyle")==normal and #matches(ordinary,normal)==2
                and #matches(ordinary,"ContactVolume")==0, id .. " two directional normal-hit edges")
            local wrong = FX.contact(endpoint,row.classId,id,aim,1,compact,"nature")
            check(wrong and wrong:GetAttribute("ContactStyle")==normal, id .. " ignores mismatched marks")
            local spend = FX.contact(endpoint,row.classId,id,aim,1,compact,d.consume)
            check(spend and spend:GetAttribute("ContactStyle")==consumed and #matches(spend,consumed)==2
                and #matches(spend,normal)==0,id .. " shows the confirmed spend by itself")
            if row.classId=="dwarf" then
                local posture = FX.contact(endpoint,row.classId,id,aim,1,compact,d.consume,nil,true)
                check(posture and #matches(posture,"PostureBreakEdge")==2 and #matches(posture,consumed)==2,
                    "fracture spend remains visible with posture break")
            end
            FX.clear()
        end
    end

    for _, row in rows do
        local id = row[1]
        local definition = Catalog.byId[id].definition
        local classId = Catalog.byId[id].classId
        local begin = definition.windup+(definition.hitDelay or 0)
        for _, rig in {Enum.HumanoidRigType.R6,Enum.HumanoidRigType.R15} do
            local load = sample(definition,classId,definition.windup*.57,rig)
            local follow = sample(definition,classId,begin+.064,rig)
            local relaxed = sample(definition,classId,definition.windup+definition.active+definition.recovery,rig)
            check((load.angles.torso-follow.angles.torso).Magnitude>18,id .. " winds and opens " .. rig.Name)
            check((follow.angles.leftKnee-relaxed.angles.leftKnee).Magnitude>12,id .. " plants then settles " .. rig.Name)
        end
    end

    FX.isOtherHero = originalIsOther
    local before = {}
    for _, p in workspace:GetChildren() do before[p]=true end
    Visual.play(actor,rows[1][1],origin,origin+Vector3.xAxis*4,1,{},nil,nil,nil,aim)
    Visual.play(actor,rows[3][1],origin,endpoint,1,{},nil,nil,nil,aim)
    local sectors, crescents, arrowWakes, arrows = 0,0,0,0
    for _, p in workspace:GetChildren() do
        if not before[p] then
            if p.Name=="SkillSector" then sectors+=1 end
            if p.Name=="BladeCrescent" then crescents+=1 end
            if p.Name=="ArrowWake" then arrowWakes+=1 end
            if p.Name=="ArrowShaft" or p.Name=="SkillSourceArrow" then arrows+=1 end
            if p:IsA("BasePart") then p:Destroy() end
        end
    end
    check(sectors==12 and crescents==0,"Oath Challenge retains range and removes the second crescent")
    check(arrowWakes==0 and arrows==1,"Mark Breaker still draws one arrow without another wake")
    FX.clear()

    local world = Instance.new("Folder",workspace)
    world.Name = "DeepwoodK0"
    local terrain = Instance.new("Folder",world)
    terrain.Name = "TerrainBlockout"
    floor.Parent = terrain
    local enemies = Instance.new("Folder",world)
    local target = Instance.new("Model",enemies)
    part("HumanoidRootPart",endpoint,target)
    target:SetAttribute("K0EnemyState","Windup")
    target:SetAttribute("K0Telegraph","Unblockable")
    target:SetAttribute("K0AttackOrigin",endpoint)
    target:SetAttribute("K0AttackDirection",aim)
    target:SetAttribute("K0AttackRange",9)
    target:SetAttribute("K0AttackAngle",360)
    local player = Instance.new("Folder",stage)
    player:SetAttribute("K0SessionPhase","Tutorial")
    actor.Name, actor.Parent = "Character", player
    local humanoid = Instance.new("Humanoid",actor)
    humanoid.RequiresNeck = false
    local warnings = Telegraphs.create(enemies,player)
    FX.isOtherHero = function(character) return character~=nil and character~=actor end
    local ally
    for i, row in rows do
        local caster = i==#rows and actor or Instance.new("Model",stage)
        local start = origin+Vector3.xAxis*(i-2.5)*1.5
        part("HumanoidRootPart",start,caster)
        Visual.play(caster,row[1],start,endpoint,1,{endpoint},nil,nil,nil,aim)
        if i==3 then ally=caster end
    end
    local active, beams, _, glows, particles, surfaces = FX.count()
    check(active==4 and glows==0 and particles==0,"four overlapping releases leave no redundant glow or particles")
    warnings.update()
    local red = 0
    for _, edge in workspace.K0LocalTelegraphs:GetDescendants() do
        if edge:IsA("BasePart") and edge.Transparency<1 and edge.Color==Color3.fromRGB(255,73,58) then red+=1 end
    end
    check(red==16,"all enemy warning segments remain visible")
    check(Hits.show(target,endpoint,42,"elf","Goblin",aim,rows[3][1],{attacker=ally,consumedMark="weakpoint"}),
        "confirmed allied Mark Breaker event renders")
    local number = workspace:FindFirstChild("K0HitEffect")
    check(number and number.K0DamageNumber.Amount.Text=="42","confirmed allied damage number remains visible")
    if number then number:Destroy() end
    report.overlap = {active=active,beams=beams,glows=glows,particles=particles,surfaces=surfaces,warningSegments=red}
    warnings.destroy()
    world:Destroy()
end, debug.traceback)

if not ok then table.insert(report.failures,tostring(err)) end
FX.isOtherHero = originalIsOther
FX.clear()
stage:Destroy()
camera.CFrame = oldCamera
report.pass = #report.failures==0
print("HERO_MARK_BREAK_RELEASES_NATIVE "..game.HttpService:JSONEncode(report))
assert(report.pass, "mark-break release regression")
