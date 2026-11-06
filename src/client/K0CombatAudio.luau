-- Local presentation from accepted server attributes and confirmed damage only.
local RS = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Config = require(RS.Shared.K0Config)
local FXCatalog = require(RS.Shared.PixelFXCatalog)
local Catalog = require(RS.Shared.CombatAudioCatalog)
local Audio = {}
local active = {}
local seen = setmetatable({}, {__mode = "k"})
local impactCells = {}
local started = false
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < 1e7 end
local function vector(v) return typeof(v) == "Vector3" and finite(v.X) and finite(v.Y) and finite(v.Z) end

function Audio.play(kind, position, classId, skillId)
    local clip = Catalog.get(classId, skillId, kind)
    if not clip or not vector(position) then return false end
    local camera = workspace.CurrentCamera
    if camera and (camera.CFrame.Position - position).Magnitude > 80 then return false end
    local now = os.clock()
    -- A clustered AoE has one contact per short window, rather than a voice per target.
    for key, at in pairs(impactCells) do if now - at >= .07 then impactCells[key] = nil end end
    if kind == "impact" then
        local cell = clip.id .. ":" .. math.floor(position.X / 8) .. ":" .. math.floor(position.Z / 8)
        if impactCells[cell] then return false end
        impactCells[cell] = now
    end
    local count = 0
    for i = #active, 1, -1 do
        if not active[i].holder.Parent then table.remove(active, i)
        elseif active[i].kind == kind then count = count + 1 end
    end
    -- Reserve eight voices for each layer so a large hit cannot erase all releases.
    if count >= 8 then
        for i, entry in ipairs(active) do
            if entry.kind == kind then entry.holder:Destroy(); table.remove(active, i); break end
        end
    end
    local holder = Instance.new("Part")
    holder.Name, holder.Size, holder.Position = "K0CombatAudioEmitter", Vector3.one * .05, position
    holder.Anchored, holder.Transparency = true, 1
    holder.CanCollide, holder.CanTouch, holder.CanQuery, holder.CastShadow = false, false, false, false
    local sound = Instance.new("Sound")
    sound.Name = kind == "impact" and "K0HitSound" or "K0ReleaseSound"
    sound.SoundId, sound.Volume = clip.id, clip.volume
    sound.PlaybackSpeed = clip.speed * (.98 + math.random() * .04)
    sound.Looped = false
    sound.RollOffMode = Enum.RollOffMode.Linear
    sound.RollOffMinDistance, sound.RollOffMaxDistance = 8, 80
    sound.Parent = holder
    sound.Ended:Once(function() holder:Destroy() end)
    holder.Parent = workspace
    table.insert(active, {holder = holder, kind = kind})
    Debris:AddItem(holder, clip.duration)
    sound:Play()
    return true, holder
end

function Audio.renderCharacter(character, now)
    if not finite(now) or character:GetAttribute("K0State") ~= "Attack"
        or character:GetAttribute("TLTDeathFalling") then return false end
    local classId, skillId = character:GetAttribute("K0ClassId"), character:GetAttribute("K0SkillId")
    local row = FXCatalog.get(classId, skillId)
    if not row then return false end
    local profile = Config.BasicAttackProfiles[classId]
    local d = row.definition or profile and profile.attacks[character:GetAttribute("K0Combo") or 1]
    local at, seq = character:GetAttribute("K0AttackStartedAt"), character:GetAttribute("K0AttackSeq")
    local root = character:FindFirstChild("HumanoidRootPart")
    local rate = not row.definition and (character:GetAttribute("K0BasicAttackRate") or 1) or 1
    if not d or not finite(at) or not finite(seq) or not finite(rate) or rate <= 0
        or not root or not root:IsA("BasePart") then return false end
    local beat = FXCatalog.beat(d, (now - at) * rate)
    if beat == 0 then return false end
    local old = seen[character]
    if old and old.seq == seq and old.at == at and old.beat >= beat then return false end
    seen[character] = {seq = seq, at = at, beat = beat}
    return Audio.play("release", root.Position, classId, skillId)
end

function Audio.start()
    if started then return end
    started = true
    -- Fetch in the background; combat never waits for the network or an audio asset.
    task.spawn(function()
        local ids, used = {}, {}
        for _, profile in pairs(Catalog.profiles) do
            for _, clip in pairs(profile) do
                if not used[clip.id] then used[clip.id] = true; table.insert(ids, clip.id) end
            end
        end
        pcall(function() game:GetService("ContentProvider"):PreloadAsync(ids) end)
    end)
end
return Audio
