-- Authored en-US quest roles. Stable chapter/goal IDs and reward budgets are unchanged.
local Q={epic={title='Friends of the Forest',region='Deepwood',promise='Rescue the missing convoy, close the monster portal, and follow the Crownheart north.'}}
local function phase(title,ids) return {title=title,goals=ids} end
Q.stories={
 ['DW-01']={title='The Missing Supply Convoy',brief='Team up with Eryn. Find the supplies and follow the convoy trail.',outcome='You found the convoy trail. Survivors are waiting by the broken cart!',phases={phase('Open the forest trail',{'trail_guards'}),phase('Find the convoy supplies',{'supplies','supply_guards'}),phase('Follow the trail',{'tracks','trail_exit'})}},
 ['DW-02']={title='Friends to the Rescue',brief='Selene is helping the wounded. Guide the convoy survivors to safety.',outcome='The survivors are safe! Meet Selene and Eryn at the elder tree camp.',phases={phase('Reach the survivors',{'cart_guards'}),phase('Guide everyone to safety',{'survivors','escape_guards'}),phase('Find the safe camp',{'testimony','clearing_exit'})}},
 ['DW-03']={title='New Friends at Camp',brief='Share the rescue news with Selene. Invite her along if you like, then plan the next rescue with Eryn.',outcome='Selene is available as a free companion. Eryn has a plan to bring the other convoy workers home.',phases={phase('Meet Selene at the safe camp',{'report'}),phase('Team up with Eryn',{'erin'}),phase('Plan the next rescue',{'watchtower_order'})}},
 ['DW-04']={title='The Watchtower Rescue',brief='Stop two portal devices, free a forest friend, and find the convoy workers.',outcome='A forest friend is free! The route map leads to the occupied ruins.',phases={phase('Stop the portal devices',{'courtyard','west_link','east_link'}),phase('Free a forest friend',{'spirit'}),phase('Find the next rescue',{'link_record','shortcut'})}},
 ['DW-05']={title='Bring the Workers Home',brief='Free the convoy workers and defeat the Orc Warlord blocking their way.',outcome='The workers are safe. King Shaman is building a monster portal at the altar.',phases={phase('Rescue the workers',{'ruin_guards','prison_guards','prisoners'}),phase('Clear their way home',{'first_ogre','barracks','warlord'}),phase('Find King Shaman',{'transfer'})}},
 ['DW-06']={title='A Safe Path for Everyone',brief='Help the forest families stop the portal devices and light a safe path.',outcome='The path is open! Your new friends can return home while you head for the altar.',phases={phase('Meet the forest families',{'refugees'}),phase('Stop the portal devices',{'root_west','root_east','root_depth'}),phase('Light the safe path',{'ancient_network','altar_path'})}},
 ['DW-07']={title='The Forest Is Safe Again',brief='Defeat King Shaman, close his portal, and find the next clue to the stolen Crownheart.',outcome='The portal is closed and the convoy is home! The delivery orders lead north to Frozen Vale.',phases={phase('Defeat King Shaman',{'corridor','outer_west','outer_east','king_shaman'}),phase('Close the portal and find the clue',{'core_record','stabilize','separate'}),phase('Celebrate with your friends',{'restoration'})}},
}
Q.side={
 ['DW-Q1']={giver='Supply Survivor',brief='A waterproof log may identify the missing supply workers. Recover it and bring it back to a survivor.',outcome='The supply record and the missing workers\' names are preserved.',turnIn='marsh_report'},
 ['DW-Q2']={giver='Outpost Storekeeper',brief='Stolen food and prisoners are being held at the goblin camp. Recover the stores and return with news of the captives.',outcome='The stolen stores and the camp captives are accounted for at the outpost.',turnIn='food_report'},
 ['DW-Q3']={giver='Quarry Foreman',brief='The abandoned quarry still has working transport equipment. Investigate it and report what can be recovered.',outcome='The quarry transport record is preserved for the outpost.',turnIn='quarry_report'},
 ['DW-Q4']={giver='Outpost Scout',brief='A scout vanished near the old battlefield. Follow the trace, clear the danger, and report a safe return route.',outcome='The missing scout\'s trail and the safe return route are recorded.',turnIn='battlefield_report'},
}
function Q.install(content)
 for index,c in ipairs(content.chapters) do
  c.quest=c.side and Q.side[c.id] or Q.stories[c.id]
  if c.side and c.id~='DW-Q1' then
   local p=content.zones['DW-03'].center;c.quest.offerPosition={p[1]+(index-9)*18,p[2]+1,p[3]+72}
   for _,g in ipairs(c.goals) do if g.id==c.quest.turnIn then g.position={table.unpack(c.quest.offerPosition)};g.position[2]=p[2] end end
  end
 end
end
return Q
