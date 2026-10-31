-- Only the server's actual health-loss pulse triggers this local presentation.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Feedback = {}
local pitches = {knight = .98, dwarf = .88, elf = 1.08, mage = 1.02}

function Feedback.create(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = "K0PlayerHitFeedback", true, false, 85
    gui.Parent = parent
    local panels, tweens = {}, {}
    local function panel(name, size, position, anchor, rotation)
        local p = Instance.new("Frame")
        p.Name, p.Size, p.Position, p.AnchorPoint = name, size, position, anchor
        p.BackgroundColor3, p.BackgroundTransparency, p.BorderSizePixel = Color3.fromRGB(200, 34, 46), 1, 0
        p.Active, p.Selectable, p.Parent = false, false, gui
        if rotation then
            local gradient = Instance.new("UIGradient")
            gradient.Rotation = rotation
            gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            gradient.Parent = p
        end
        table.insert(panels, p)
    end
    panel("Veil", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Vector2.zero)
    panel("Top", UDim2.fromScale(1, .12), UDim2.fromScale(0, 0), Vector2.zero, 90)
    panel("Bottom", UDim2.fromScale(1, .12), UDim2.fromScale(0, 1), Vector2.new(0, 1), 270)
    panel("Left", UDim2.fromScale(.10, 1), UDim2.fromScale(0, 0), Vector2.zero, 0)
    panel("Right", UDim2.fromScale(.10, 1), UDim2.fromScale(1, 0), Vector2.new(1, 0), 180)
    local sound = Instance.new("Sound")
    sound.Name, sound.SoundId, sound.Volume = "K0HurtGrunt", "rbxasset://sounds/ouch.ogg", .24
    sound.Parent = gui
    local controller = {gui = gui, sound = sound, pulses = 0, lastSound = -math.huge}
    function controller:clear()
        for _, tween in ipairs(tweens) do tween:Cancel() end
        table.clear(tweens)
        for _, p in ipairs(panels) do p.BackgroundTransparency = 1 end
        sound:Stop()
    end
    function controller:pulse(damage, maxHealth, classId, current)
        if type(damage) ~= "number" or damage ~= damage or damage <= 0 or damage > 1000000
            or type(maxHealth) ~= "number" or maxHealth ~= maxHealth or maxHealth <= 0 or maxHealth == math.huge
            or not pitches[classId] then return false end
        current = current or os.clock()
        self.pulses += 1
        gui:SetAttribute("PulseCount", self.pulses)
        gui:SetAttribute("LastDamage", damage)
        for _, tween in ipairs(tweens) do tween:Cancel() end
        table.clear(tweens)
        local ratio = math.clamp(damage / maxHealth, 0, .5)
        for i, p in ipairs(panels) do
            local opacity = i == 1 and (.025 + ratio * .04) or (.10 + ratio * .16)
            p.BackgroundTransparency = math.min(p.BackgroundTransparency, 1 - opacity)
            local tween = TweenService:Create(p, TweenInfo.new(.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
            table.insert(tweens, tween)
            tween:Play()
        end
        -- One voice at a time; a crowded hit burst never stacks grunts.
        if current - self.lastSound >= .55 then
            self.lastSound = current
            sound:Stop()
            sound.PlaybackSpeed = pitches[classId]
            sound:Play()
            gui:SetAttribute("GruntCount", (gui:GetAttribute("GruntCount") or 0) + 1)
        end
        return true
    end
    function controller:bind(character)
        if self.connection then self.connection:Disconnect(); self.connection = nil end
        self:clear()
        if not character then return end
        local last = character:GetAttribute("K0HurtAt") or 0
        self.connection = character:GetAttributeChangedSignal("K0HurtAt"):Connect(function()
            local at = character:GetAttribute("K0HurtAt")
            if type(at) ~= "number" or at <= last then return end
            last = at
            if character:GetAttribute("K0SpawnReady") ~= true then return end
            self:pulse(character:GetAttribute("K0HurtDamage"), character:GetAttribute("K0HurtMaxHealth"), character:GetAttribute("K0ClassId"))
        end)
    end
    function controller:destroy()
        self:bind(nil)
        gui:Destroy()
    end
    return controller
end

function Feedback.start()
    local player = Players.LocalPlayer
    local controller = Feedback.create(player:WaitForChild("PlayerGui"))
    task.spawn(function() pcall(function() game:GetService("ContentProvider"):PreloadAsync({controller.sound}) end) end)
    player.CharacterAdded:Connect(function(c) controller:bind(c) end)
    player.CharacterRemoving:Connect(function() controller:bind(nil) end)
    controller:bind(player.Character)
    return controller
end
return Feedback
