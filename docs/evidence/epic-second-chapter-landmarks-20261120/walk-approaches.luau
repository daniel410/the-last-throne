-- Follow the authored inbound segment and return with a jump-disabled R15 rig.
local physics = game:GetService('PhysicsService')
local group = 'SecondChapterReviewR15'
physics:RegisterCollisionGroup(group)
physics:CollisionGroupSetCollidable(group, group, false)

local function walk(rig, target)
    local human, root = rig.Humanoid, rig.HumanoidRootPart
    human:MoveTo(target)
    local deadline = os.clock() + 8
    repeat
        local flat = (root.Position - target) * V(1, 0, 1)
        if flat.Magnitude < 2.5 and math.abs(root.Position.Y - target.Y) < 4.5 then
            return flat.Magnitude
        end
        task.wait(.1)
    until os.clock() > deadline
    return nil
end

local pending = #sites
for _, site in ipairs(sites) do
    local id = site[1]
    task.spawn(function()
        local ok, result = xpcall(function()
            local route = approaches[id]
            local from = route.from
            from = V(from.X, assert(bounds.surface(from.X, from.Z), id .. ' approach floor'), from.Z)
            local desc = Instance.new('HumanoidDescription')
            local rig = game.Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
            desc:Destroy()
            for _, part in ipairs(rig:GetDescendants()) do
                if part:IsA('BasePart') then part.CollisionGroup = group end
            end
            rig.Humanoid.WalkSpeed = 16
            rig.Humanoid.AutoJumpEnabled = false
            rig.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            rig:PivotTo(CFrame.new(from + V(0, 4, 0)))
            rig.Parent = workspace
            task.wait(.45)
            local inbound = walk(rig, route.target)
            local outbound = walk(rig, from)
            rig:Destroy()
            return {chapter = id, inbound = inbound, outbound = outbound,
                distance = ((route.target - from) * V(1, 0, 1)).Magnitude}
        end, debug.traceback)
        print('SECOND_CHAPTER_WALK ' .. game.HttpService:JSONEncode(ok and result or {chapter = id, error = result}))
        pending -= 1
    end)
end
while pending > 0 do task.wait(.1) end
