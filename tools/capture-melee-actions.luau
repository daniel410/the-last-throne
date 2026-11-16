-- Local Studio pose atlas. The driver installs tools/review-hero-skills-studio.luau
-- as ServerStorage.HeroReviewRigs. Each tile is one evenly timed sample.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local rigs = require(game.ServerStorage.HeroReviewRigs)
local client = game.StarterPlayer.StarterPlayerScripts.Client
local visual = require(client.K0SwordVisual)
local armor = require(game.ServerScriptService.Server.Cosmetics.ArmorAppearance)
local config = require(game.ReplicatedStorage.Shared.K0Config)
local rows = {
    {"knight", 1}, {"knight", 2}, {"knight", 3}, {"knight", "knight_driving_thrust"},
    {"knight", "knight.common.provoke"}, {"dwarf", 1}, {"dwarf", 2}, {"dwarf", 3},
    {"dwarf", "dwarf.common.overhead"}, {"dwarf", "dwarf.gunner.bomb_toss"},
}
if _G.MeleeCatalog then
    rows = {}
    for _, classId in {"knight","dwarf"} do
        for first=1,#config.Skills[classId],4 do
            table.insert(rows,{classId,first})
        end
    end
end
local camera = workspace.CurrentCamera
local center = Vector3.new(0, 1500, 0)
local view = CFrame.lookAt(center + Vector3.new(0.64, 0.28, -1).Unit * 140, center)
local tile = 9.8
local backdrop = Instance.new("Part", workspace)
backdrop.Size = Vector3.new(150, 130, 1)
backdrop.Anchored = true
backdrop.CFrame = view * CFrame.new(0, 0, -159)
backdrop.Color = Color3.fromRGB(48, 57, 70)
backdrop.Material = Enum.Material.SmoothPlastic
local platform = Instance.new("Part", workspace)
platform.Anchored = true
platform.Size = Vector3.new(30, 1, 30)
platform.CFrame = CFrame.new(0, 1000, 0)
if not game.RunService:IsRunning() then game.RunService:Run() end
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = view
for row, action in rows do
    local classId, key = unpack(action)
    local board = Instance.new("Folder", workspace)
    local template = rigs.template(classId)
    for index = 0, 11 do
        local combo = type(key) == "number" and key or 1
        local skillId = type(key) == "string" and key or nil
        local definition = config.BasicAttackProfiles[classId].attacks[combo]
        for _, skill in config.Skills[classId] do
            if skill.id == skillId then definition = skill end
        end
        local duration = definition.windup + definition.active + definition.recovery
        if _G.MeleeCatalog then
            definition = config.Skills[classId][key+math.floor(index/3)]
            combo, skillId = 1, definition.id
            duration = definition.windup+definition.active+definition.recovery
        end
        local actor = template:Clone()
        actor.Parent = board
        local position = center + view.RightVector * ((index % 4) - 1.5) * tile
            + view.UpVector * (1 - math.floor(index / 4)) * tile
        local root = actor.HumanoidRootPart
        local standingY = platform.Position.Y + .5 + actor.Humanoid.HipHeight + root.Size.Y/2
        actor.LowerTorso.CanCollide = true
        actor.UpperTorso.CanCollide = true
        actor:PivotTo(actor:GetPivot() + (Vector3.new(0, standingY+.12, 0)-root.Position))
        root.Anchored = false
        local settle = os.clock()+1.5
        repeat task.wait() until actor.Humanoid.FloorMaterial ~= Enum.Material.Air or os.clock()>settle
        assert(actor.Humanoid.FloorMaterial ~= Enum.Material.Air, "Standing reference needs floor contact")
        root.Anchored = true
        local age = duration * index / 12
        if _G.MeleeCatalog then
            local contact = definition.windup+(definition.hitDelay or 0)
            age = ({contact*.48,contact,contact+math.min(.10,definition.active*.8)})[index%3+1]
        end
        print("POSE_META",row,index,skillId or combo,age,duration)
        actor:SetAttribute("K0State", "Attack")
        actor:SetAttribute("K0SkillId", skillId)
        actor:SetAttribute("K0AttackStartedAt", 100)
        actor:SetAttribute("K0SkillStartedAt", 100)
        actor:SetAttribute("K0AttackSeq", row)
        actor:SetAttribute("K0AttackKind", "Melee")
        actor:SetAttribute("K0Combo", combo)
        actor:SetAttribute("K0AttackPhase", age < definition.windup and "Windup"
            or age < definition.windup + definition.active and "Active" or "Recovery")
        visual.renderArms(actor, 1/60, 100 + age)
        rigs.bake(actor)
        visual.renderCharacter(actor, 1/60, 100 + age)
        rigs.bake(actor)
        actor:PivotTo(CFrame.new(position))
        for slot, item in {Head="traveler_hood",Body="traveler_coat",Hands="traveler_gloves",Feet="traveler_boots"} do
            actor:SetAttribute("TLTEquipped"..slot,item)
        end
        armor.sync(actor)
        assert(actor:FindFirstChild("TLTArmor_body"),"Armor was not fitted")
        if definition.branch == "gunner" then
            require(client.AdvancedSkillVisual).play(actor, skillId, position, position - Vector3.zAxis * 20, 0, nil, row)
            if age >= definition.windup then
                require(client.AdvancedSkillVisual).play(actor, skillId, position, position - Vector3.zAxis * 20, 1, nil, row)
            end
            local prop = actor:FindFirstChild("BranchSkillProp")
            if prop then
                local frozen = prop:Clone()
                for _, piece in frozen:GetChildren() do
                    local live = prop:FindFirstChild(piece.Name)
                    piece.Transparency = math.max(piece.Transparency,live.LocalTransparencyModifier)
                end
                frozen.Parent = actor
                for _, piece in actor.ReviewAppearance:GetDescendants() do
                    if piece:IsA("BasePart") then piece.Transparency = 1 end
                end
            end
        end
        for _, node in actor:GetDescendants() do
            if node:IsA("BasePart") then node.Anchored = true end
            if node:IsA("Motor6D") or node:IsA("AnimationConstraint") or node:IsA("WeldConstraint") then node.Enabled = false end
        end
    end
    camera.CFrame = view
    local size = camera.ViewportSize
    local height = math.max(tile * 3, tile * 4 * size.Y / size.X)
    camera.FieldOfView = math.deg(2 * math.atan(height / 280))
    game.ContentProvider:PreloadAsync(board:GetDescendants())
    task.wait(1)
    local done = false
    game.CaptureService:CaptureScreenshot(function(id)
        local img = game.AssetService:CreateEditableImageAsync(Content.fromUri(id))
        local pixels = img:ReadPixelsBuffer(Vector2.zero, img.Size)
        local step = img.Size.Y * tile / height
        for frame = 0, 11 do
            local x0 = img.Size.X / 2 + ((frame % 4) - 2) * step
            local y0 = img.Size.Y / 2 + (math.floor(frame / 4) - 1.5) * step
            for y = 0, 159 do
                local hex = {}
                for x = 0, 159 do
                    local pos = 4 * (math.clamp(math.floor(y0 + (y+.5)*step/160),0,img.Size.Y-1)*img.Size.X
                        + math.clamp(math.floor(x0 + (x+.5)*step/160),0,img.Size.X-1))
                    hex[x+1] = string.format("%02x%02x%02x", buffer.readu8(pixels,pos),buffer.readu8(pixels,pos+1),buffer.readu8(pixels,pos+2))
                end
                print("POSE_ROW", row, frame, y, table.concat(hex))
                if y % 24 == 23 then task.wait() end
            end
        end
        img:Destroy()
        done = true
    end)
    local deadline = os.clock()+90
    repeat task.wait(.05) until done or os.clock()>deadline
    assert(done, "Missing screenshots")
    print("POSE_ACTION", row, classId, key)
    board:Destroy()
end
print("MELEE_CAPTURE_PASS")
