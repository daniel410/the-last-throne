-- Isolated HG-05 prototype; apply after refocus.luau.
assert(game.PlaceId == 0 and #game.Players:GetPlayers() == 0)
local root = assert(_G.Terraces)
assert(root:GetAttribute('PrototypeVersion') == 3, 'Requires memorial-focus candidate')
local report = {courses = 0, slabs = 0, maxJoint = 0.08, removed = 0}
local pending = {}
for courtIndex = 1, 3 do
 local court = assert(root:FindFirstChild('RetainedBurialCourt' .. courtIndex))
 for _, cap in ipairs(court:GetChildren()) do
  if cap:IsA('BasePart') and cap.Name == 'WeatheredCoping' then
   local tier = math.clamp(math.floor((cap.Position.Y-188)/6)+1,1,3)
   local count = 4 + ((courtIndex+tier)%2)
   local width = cap.Size.X/count
   local sum = 0
   for index = 1, count do
    local left = -cap.Size.X/2+(index-1)*width
    local right = left+width
    -- Preserve external boundaries; narrow internal joints only.
    if index > 1 then left += 0.04 end
    if index < count then right -= 0.04 end
    local slab = cap:Clone()
    slab.Name = 'CopingStone' .. tier .. '_' .. index
    slab.Size = Vector3.new(right-left,cap.Size.Y,cap.Size.Z)
    slab.CFrame = cap.CFrame*CFrame.new((left+right)/2,0,0)
    slab.Color = cap.Color:Lerp(Color3.fromRGB(115,117,111),((index+courtIndex+tier)%3)*0.035)
    slab:SetAttribute('AssetOrigin','Derived:WeatheredCoping/EpicEnvironmentKit.palette.HauntedGraveyard')
    slab.Parent = court
    sum += slab.Size.X
    report.slabs += 1
   end
   assert(math.abs(sum+(count-1)*0.08-cap.Size.X)<0.001)
   pending[#pending+1] = cap
   report.courses += 1
  end
 end
end
assert(report.courses == 9)
for _,cap in ipairs(pending) do cap:Destroy();report.removed += 1 end
root:SetAttribute('PrototypeVersion',4)
return report
