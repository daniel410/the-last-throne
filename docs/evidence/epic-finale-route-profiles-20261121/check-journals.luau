local cradle = workspace.DeepwoodCampaign.EpicWorldArt.EpicWorldArt_4['EC-07'].DispatchCarrierCradle
local rollers, journals = {}, {}
for _, part in ipairs(cradle:GetChildren()) do
    if part.Name == 'CarrierIronRoller' then
        table.insert(rollers, part)
    elseif part.Name == 'CarrierRollerJournal' then
        table.insert(journals, part)
    end
end
assert(#rollers == 6 and #journals == 12)
local assigned = {}
for _, roller in ipairs(rollers) do
    local sides = {}
    for _, journal in ipairs(journals) do
        local center = roller.CFrame:PointToObjectSpace(journal.Position)
        if math.abs(center.Y) < .01 and math.abs(center.Z) < .01 and math.abs(center.X) < 2 then
            assert(not assigned[journal])
            assigned[journal] = true
            assert(journal.Shape == Enum.PartType.Cylinder)
            assert(journal.Anchored and not journal.CanCollide and not journal.CanTouch and not journal.CanQuery)
            assert(math.abs(roller.CFrame.RightVector:Dot(journal.CFrame.RightVector)) > .999)
            assert(journal.Size.Y < roller.Size.Y and journal.Size.Z < roller.Size.Z)
            local overlap = roller.Size.X / 2 - (math.abs(center.X) - journal.Size.X / 2)
            assert(overlap >= .02 and overlap < .1)
            local side = math.sign(center.X)
            assert(not sides[side])
            sides[side] = true
        end
    end
    assert(sides[-1] and sides[1])
end
print('TLT_FINALE_JOURNALS_OK', #rollers, #journals)
