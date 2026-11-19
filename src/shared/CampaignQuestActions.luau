-- One field action can confirm a scene composed of several saved presentation stages.
local Actions = {}

local scenes = {
    ['DW-02'] = {
        {title = 'Give Selene the medicine', prompt = 'Deliver medicine',
            hint = 'Bring the dry medicine case to Selene at the shelter.'},
    },
    ['GW-06'] = {
        {title = 'Rendezvous with Finn', hint = 'Meet Finn on the main trail with the scout you freed.', arrival = 'courage'},
        {title = 'Take up the rearguard', hint = 'Reach the scout lantern and make a stand while Finn leads the others out.',
            arrival = 'rear_guard', rearguard = true},
    },
    ['FV-04'] = {
        {title = 'Read the alarm with Ylva', prompt = 'Compare signals',
            hint = 'Watch the guardian and compare the shelter sign with the warning beam.'},
        {title = "Redirect the guardian's signal", prompt = 'Route signal',
            hint = 'Use the archive controls. The warning beam points at the road we need to protect.',
            text = 'The warning beam makes the guardian block the refuge road. Which signal should the archive send to guide travelers to safety?',
            choices = {
                {id = 'shelter', title = 'SEND SHELTER SIGNAL'},
                {id = 'warning', title = 'REPEAT WARNING SIGNAL'},
            },
            solution = 'shelter',
            failure = 'The warning still points at the refuge road. To guide travelers to safety, send the shelter signal.'},
    },
    ['EC-05'] = {
        {title = "Read the crew's circuit plan", prompt = 'Review plan',
            hint = 'Compare the inlet, return and shield drawings at the same worktable.'},
    },
    ['HG-04'] = {
        {title = "Inspect Brann's gate rig", prompt = 'Check rig',
            hint = "Check the anchor and the scout signal together at Brann's workbench."},
        {title = "Answer Finn's entry signal", prompt = 'Signal the scouts',
            hint = 'Answer the three gold bars. The scouts will bring the allies through while you secure the gate.'},
    },
}

function Actions.install(content)
    for chapterId, rows in pairs(scenes) do
        local chapter = content.byId[chapterId]
        for index, row in ipairs(rows) do
            local goal = chapter.expansionGoals[index]
            local activity = goal.activity
            local last = activity.steps[#activity.steps]
            local position = last.position
            if row.arrival then
                for _, target in ipairs(chapter.goals) do
                    if target.id == row.arrival then position = target.position; break end
                end
            end
            if row.rearguard and chapter.combatRoutes then
                position = chapter.combatRoutes.rear_guard.points[1]
            end
            local finish = {}
            for key, value in pairs(row) do
                if key ~= 'arrival' then finish[key] = value end
            end
            finish.id = 'resolve'
            finish.position = position
            finish.onMainRoute = row.arrival ~= nil
            activity.finish = finish
            activity.clue = nil
            goal.title = row.title
        end
    end

    -- Keep the original battlefield reservations. The three physical choices
    -- now sit around one workshop bench, with each station on its own axis.
    local steps = content.byId['EC-05'].expansionGoals[2].activity.steps
    local x, y, z = table.unpack(steps[1].position)
    steps[2].position = {x + 6, y, z + 14}
    steps[3].position = {x - 4, y, z + 29}
end

return Actions
