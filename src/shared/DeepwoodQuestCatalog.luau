-- Authored en-US quest roles. Stable chapter/goal IDs and reward budgets are unchanged.
local Q={epic={title='The Black Roots',region='Deepwood',promise='Find the missing people and uncover what is draining the forest.'}}
local function phase(title,ids) return {title=title,goals=ids} end
Q.stories={
 ['DW-01']={title='The Missing Supply Convoy',brief='The food was left behind, but the people are gone. Find out what the raiders wanted.',outcome='Evidence points to captives being moved toward the broken cart.',phases={phase('Survive the ambush',{'trail_guards'}),phase('Investigate the raid',{'supplies','supply_guards'}),phase('Follow the captives',{'tracks','trail_exit'})}},
 ['DW-02']={title='Witnesses on the Road',brief='The survivors know where the missing people went. Get them to safety before collecting their account.',outcome='The survivors are safe, and their evidence leads to Erin at the elder tree.',phases={phase('Reach the survivors',{'cart_guards'}),phase('Protect the evacuation',{'survivors','escape_guards'}),phase('Learn what happened',{'testimony','clearing_exit'})}},
 ['DW-03']={title='A Promise to the Forest',brief='The crown needs the Seal Core. Erin needs proof that helping the crown will not destroy her people.',outcome='Erin agrees to an investigation of the spirit links at the watchtower.',phases={phase('Bring the survivors home',{'report'}),phase('Earn Erin\'s trust',{'erin'}),phase('Prepare the investigation',{'watchtower_order'})}},
 ['DW-04']={title='The Captive Spring',brief='The watchtower is draining a forest spirit. Break its links and learn where the stolen power goes.',outcome='The spirit returns to the spring, and the ritual record points to the occupied ruins.',phases={phase('Break the spirit links',{'courtyard','west_link','east_link'}),phase('Restore the spring',{'spirit'}),phase('Trace the ritual network',{'link_record','shortcut'})}},
 ['DW-05']={title='Prisoners of the Warlord',brief='Rescue the captives, dismantle the barracks ritual, and find who ordered the transfers.',outcome='The Warlord is defeated. The transfer orders name King Shaman.',phases={phase('Open the prison',{'ruin_guards','prison_guards','prisoners'}),phase('Break the occupation',{'first_ogre','barracks','warlord'}),phase('Recover the orders',{'transfer'})}},
 ['DW-06']={title='The Refugees\' Truth',brief='The goblin families are victims too. Hear them before following the buried seal network.',outcome='The network was built for protection. King Shaman has turned it against the forest.',phases={phase('Hear the refugees',{'refugees'}),phase('Stop the root devices',{'root_west','root_east','root_depth'}),phase('Find the original purpose',{'ancient_network','altar_path'})}},
 ['DW-07']={title='The Price of the Seal',brief='Stop King Shaman, preserve the regional seal, and decide who receives the remaining restoration power.',outcome='The core is secured without dropping the regional seal. Your restoration decision is recorded.',phases={phase('Reach King Shaman',{'corridor','outer_west','outer_east','king_shaman'}),phase('Secure the living seal',{'core_record','stabilize','separate'}),phase('Choose Deepwood\'s future',{'restoration'})}},
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
