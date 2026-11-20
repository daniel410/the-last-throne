-- Run after creating the campaign in an isolated Studio place.
local world = assert(workspace:FindFirstChild('DeepwoodCampaign'))
local cradle = assert(world.EpicWorldArt.EpicWorldArt_4['EC-07']:FindFirstChild('DispatchCarrierCradle'))
local rollerRows, saddles = {}, {}
for _, part in ipairs(cradle:GetChildren()) do
    if part.Name == 'CarrierIronRoller' then
        assert(part:IsA('Part') and part.Shape == Enum.PartType.Cylinder)
        assert(part.Anchored and not part.CanCollide and not part.CanQuery and not part.CanTouch)
        table.insert(rollerRows, part)
    elseif part.Name == 'CarrierSaddle' then
        table.insert(saddles, part)
    end
end
assert(#rollerRows == 6 and #saddles == 2)
for _, saddle in ipairs(saddles) do
    local stations = {}
    for _, roller in ipairs(rollerRows) do
        local center = saddle.CFrame:PointToObjectSpace(roller.Position)
        if math.abs(center.X) < .01 then
            local deck = saddle.Size.Y / 2
            local radius = roller.Size.Y / 2
            assert(center.Y - radius < deck and center.Y + radius > deck)
            assert(math.abs(roller.CFrame.RightVector:Dot(saddle.CFrame.RightVector)) > .999)
            assert(math.abs(center.Z) + radius < saddle.Size.Z / 2)
            table.insert(stations, center.Z)
        end
    end
    table.sort(stations)
    assert(#stations == 3 and stations[3] - stations[2] > .85 and stations[2] - stations[1] > .85)
end
print('TLT_DISPATCH_ROLLERS_OK', #rollerRows, #saddles)
