-- One field action can confirm a scene composed of several saved presentation stages.
local Actions = {}

local scenes = {
    ['DW-01'] = {
        [2] = {title = 'Reach the broken-cart clearing', arrival = 'trail_exit',
            hint = 'Stay with the wagon tracks until you see the cloth signal.'},
    },
    ['DW-02'] = {
        {title = 'Give Selene the medicine', prompt = 'Deliver medicine',
            hint = 'Bring the dry medicine case to Selene at the shelter.'},
    },
    ['DW-03'] = {
        {title = "Match the missing names to the driver's sketch", prompt = 'Check roster', atStep = 2,
            hint = "Check the outpost roster beside Eryn's supply yard."},
        {title = 'Reach the camp signal post', arrival = 'watchtower_order',
            hint = 'After speaking to Eryn, walk to the signal post where the watchtower flashes are visible.'},
    },
    ['GW-04'] = {
        {title = 'Examine the crushed trail lantern', prompt = 'Inspect lantern', atStep = 1,
            hint = 'Look at the roots around the crushed lantern before crossing the clearing.'},
    },
    ['GW-05'] = {
        [2] = {title = 'Secure the crossing handrail', prompt = 'Fasten handrail', atStep = 2,
            hint = 'After defeating Venomcoil King, fasten the handrail at the rope landing.'},
    },
    ['GW-06'] = {
        {title = 'Rendezvous with Finn', hint = 'Meet Finn on the main trail with the scout you freed.', arrival = 'courage'},
        {title = 'Take up the rearguard', hint = 'Reach the scout lantern and make a stand while Finn leads the others out.',
            arrival = 'rear_guard', rearguard = true},
    },
    ['GW-07'] = {
        [2] = {title = 'Reach Tali at the northern turn', arrival = 'entrance',
            hint = 'Once the webs are cut, follow the open road to Tali.'},
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
    ['FV-06'] = {
        [2] = {title = 'Send the archive rest signal', prompt = 'Send rest signal',
            hint = 'Open both citadel locks, then send the shelter signal from the guardian landing.'},
    },
    ['EC-05'] = {
        {title = "Read the crew's circuit plan", prompt = 'Review plan',
            hint = 'Compare the inlet, return and shield drawings at the same worktable.'},
    },
    ['EC-06'] = {
        [2] = {title = 'Check the live return pressure', prompt = 'Read pressure', atStep = 2,
            hint = 'Once the Magma Golem is down, check the return gauge before running the load test.'},
    },
    ['EC-07'] = {
        [2] = {title = 'Read the dispatch beside the empty carrier', prompt = 'Read dispatch', atStep = 2,
            hint = 'After restarting the furnace, inspect the dispatch at the freight exit.'},
    },
    ['HG-02'] = {
        {title = "Review the allies' assignments", prompt = 'Read route table', atStep = 1,
            hint = "At the route table, check where Eryn's scouts and Brann's crew will be stationed."},
        {title = 'Join Elowen at the departure point', arrival = 'elowen',
            hint = 'After Brann confirms the winch plan, find Elowen at the shelter exit.'},
    },
    ['HG-04'] = {
        {title = "Inspect Brann's gate rig", prompt = 'Check rig',
            hint = "Check the anchor and the scout signal together at Brann's workbench."},
        {title = "Answer Finn's entry signal", prompt = 'Signal the scouts',
            hint = 'Answer the three gold bars. The scouts will bring the allies through while you secure the gate.'},
    },
    ['HG-05'] = {
        {title = 'Trace the live western shield link', prompt = 'Trace power line', atStep = 2,
            hint = 'Trace the western feed to see which device still powers the shield.'},
    },
    ['HG-07'] = {
        [2] = {title = "Release the empty frame's last catch", prompt = 'Release catch', atStep = 1,
            hint = 'Once the Crownheart is free, release the empty frame so the portal control can shut.'},
    },
}

function Actions.install(content)
    for chapterId, rows in pairs(scenes) do
        local chapter = content.byId[chapterId]
        for index, row in pairs(rows) do
            local goal = chapter.expansionGoals[index]
            local activity = goal.activity
            local position = activity.steps[row.atStep or #activity.steps].position
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
                if key ~= 'arrival' and key ~= 'atStep' then finish[key] = value end
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
