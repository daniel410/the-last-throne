-- Append to the two embedded Finale modules and the shared Kit constructors.
local ids = {
    {'DW-07', 'Deepwood', 16, 21}, {'GW-07', 'Gloamwood', 9, 10},
    {'FV-07', 'FrozenVale', 13, 15}, {'EC-07', 'EmberCaldera', 27, 31},
    {'HG-07', 'HauntedGraveyard', 13, 16},
}
local function parts(scenery, row, geometry)
    local model = Instance.new('Model')
    model.WorldPivot = CFrame.identity
    local function part(name, size, at, color, material, solid, angles, shape)
        assert(not solid)
        local frame = CFrame.new(at)
        if angles then frame *= CFrame.Angles(angles.X, angles.Y, angles.Z) end
        return Kit.part(model, name, size, frame, color, material, shape)
    end
    local function beam(name, a, b, width, color, material, solid)
        assert(not solid)
        Kit.beam(model, name, a, b, width, color, material)
    end
    scenery.compose(row[1], Kit.palette[row[2]], part, beam)
    local count = 0
    local rollers, journals = 0, 0
    for _, object in ipairs(model:GetChildren()) do
        assert(object.Anchored and not object.CanCollide and not object.CanQuery and not object.CanTouch)
        if geometry then
            table.insert(geometry, {
                name = object.Name,
                shape = object:IsA('WedgePart') and 'Wedge' or object.Shape.Name,
                material = object.Material.Name,
                size = {object.Size.X, object.Size.Y, object.Size.Z},
                color = {object.Color.R, object.Color.G, object.Color.B},
                transform = {object.CFrame:GetComponents()},
            })
        end
        count += 1
        if object.Name == 'CarrierIronRoller' then
            assert(object.Shape == Enum.PartType.Cylinder)
            rollers += 1
        elseif object.Name == 'CarrierRollerJournal' then
            assert(object.Shape == Enum.PartType.Cylinder)
            journals += 1
        end
    end
    local cf, span = model:GetBoundingBox()
    assert(model:GetPivot() == CFrame.identity)
    local radius = Vector3.new(span.X / 2 + math.abs(cf.X), 0, span.Z / 2 + math.abs(cf.Z)).Magnitude
    model:Destroy()
    return count, cf.Position, span, radius, rollers, journals
end
local result = {}
local geometry = exportGeometry and {baseline = {}, candidate = {}}
for _, row in ipairs(ids) do
    local id = row[1]
    assert(prior.profiles[id].goal == candidate.profiles[id].goal)
    assert(prior.profiles[id].name == candidate.profiles[id].name)
    if geometry then
        geometry.baseline[id] = {}
        geometry.candidate[id] = {}
    end
    local oldCount, oldCenter, oldSize, oldRadius = parts(prior, row, geometry and geometry.baseline[id])
    local newCount, center, size, radius, rollers, journals = parts(candidate, row, geometry and geometry.candidate[id])
    assert(oldCount == row[3] and newCount == row[4])
    local centerDelta, sizeDelta, radiusDelta = (center - oldCenter).Magnitude, (size - oldSize).Magnitude, math.abs(radius - oldRadius)
    assert(centerDelta < .001 and sizeDelta < .001 and radiusDelta < .001, id)
    if id == 'EC-07' then assert(rollers == 6 and journals == 12) end
    result[id] = {baselineParts=oldCount, candidateParts=newCount, boundCenterDelta=centerDelta,
        boundSizeDelta=sizeDelta, placementRadiusDelta=radiusDelta, nonCollidableParts=newCount,
        rollers=rollers, journals=journals}
end
return geometry or result
