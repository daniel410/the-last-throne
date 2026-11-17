-- Player-facing chapter briefs, handoffs and dialogue. Stable IDs also serve returning players.
-- Every story has a distinct problem, earned result, and concrete next reason.
local chapters={
 ['DW-01']={"Someone stole the Crownheart that protects Dawnspire. Eryn, the forest scout captain, lost track of a village supply convoy on Goblin Forest Trail. Its crew may have seen the thieves.",'The supplies identify the missing convoy. A cloth signal leads to survivors beside the broken cart.'},
 ['DW-02']={"Someone is waving a strip of cloth by the broken cart. Take the medicine you found at the creek to Selene, the priestess treating the wounded there.","The driver and the wounded are on the camp road. Find Selene at Elder Tree Outpost and tell her everyone made it. Eryn will want to see the driver's sketch of the watchtower."},
 ['DW-03']={"The driver saw raiders taking workers toward the watchtower. Check in with Selene at Elder Tree Outpost, then help Eryn work out how to reach them.",'Selene is recruited. The driver\'s signal sketch gives Eryn a route to the watchtower and its captive forest friend.'},
 ['DW-04']={"The driver's sketch led Eryn to the abandoned watchtower. A forest friend is locked inside. Cut power to the cage and get word back to camp.",'Your forest friend has a safe way home. The restored signal and raiders\' map reveal cages in the occupied ruins.'},
 ['DW-05']={"The map from the watchtower shows where the raiders took the convoy workers. Reach the cages in the occupied ruins before the barracks can sound the alarm.",'The workers are safe. King Shaman\'s orders lead through a threatened forest village to the Black Root Altar.'},
 ['DW-06']={"The prisoner orders point to the altar, but the road runs through a village tangled in roots. Help the families on the path. They know which devices are keeping it closed.",'The families have a way back to camp. Their marked rootway leads to King Shaman\'s altar.'},
 ['DW-07']={"The families' trail marks lead to the Black Root Altar. Stop King Shaman, close his portal, and search the raiders' orders for the missing Crownheart.","The supply convoy is home and the portal is closed. The raiders took the Crownheart into Gloamwood. Meet Maeve, the captain of the scouts who followed it, at the entrance to Lantern Trail."},
 ['GW-01']={"Eryn lost contact with the scouts tracking the Crownheart in Gloamwood. Meet their captain, Maeve, at the entrance to Lantern Trail. Ask where she last heard from them.","The cargo wheels head north. At the broken cart, the scout marks turn toward the outer webs. Follow the three-bar lanterns to Finn. He stayed to help Tali get free."},
 ['GW-02']={"Finn, Maeve's lantern scout, stayed with Tali when the webs caught her. Follow the three-bar lanterns to the outer webs. He can show you where to cut her free.",'Tali is free and confirms the cargo passed ahead of the scouts. Escort her to Maeve at Lantern Refuge.'},
 ['GW-03']={"Tali saw the cargo pass, but other scouts are still missing. Walk her to Maeve at Lantern Refuge so she can mark where the search should start.",'Maeve will hold the refuge. The Wispkeeper points to the rootway, the hunting ground, and the old road beyond.'},
 ['GW-04']={"The Wispkeeper traced a way to the missing scouts through the Ancient Rootway. Hollowbark blocks it. Open the path and light a lantern the scouts can follow home.","The rootway lantern is lit. Maeve can bring the scouts home this way if you can get them across the hunting ground at Venomcoil Crossing."},
 ['GW-05']={"The lanterns now reach Venomcoil Crossing. The scouts still have to cross a hunting ground to get home. Drive off its king so the rescue rope can go up.",'The crossing is secure. The last scout signals come from the edge of the queen\'s territory.'},
 ['GW-06']={"The last scout signals came from the edge of the queen's territory. Cut the scouts loose, then stay behind Finn's lantern to guard their escape.",'The scouts reach the refuge route while you hold the rearguard. Finn keeps the group together; the northern exit still lies beyond the queen.'},
 ['GW-07']={"Finn has the scouts on the refuge road. Beyond the queen's nest, webs still seal the northern exit. Open it so Tali can show you where she saw the cargo go.","The northern road is open. Tali saw the Crownheart cargo take the snowy ridge into Frozen Vale. Look for Freya, the mountain pathfinder, at Blizzard Gate."},
 ['FV-01']={"Tali saw the cargo head for Frozen Vale. At Blizzard Gate, look for Freya, the mountain pathfinder. She knows the trail, but travelers are stranded below it.","Your lanterns lead the travelers to Ember Refuge. Haldor keeps a place for them there. Bring the medicine inside so Nessa, the field medic, can tend to the wounded."},
 ['FV-02']={"Your lanterns brought the travelers to Ember Refuge. Haldor keeps the shelter and Nessa treats the wounded. Bring them the medicine before setting out for the next village.",'The refuge has medicine and a rescue plan. Restore the ravine crossing so the beacon teams can reach both sides.'},
 ['FV-03']={"Freya traced the gap between the village beacons to Wolf Ravine. Find the stranded caravan keeper and get both sides of the crossing lit again.","Both beacons are lit, but the fortress alarm still sounds. Follow its signal into the Subglacial Archive. Ylva tends the guardians there. She may know why they still block the road."},
 ['FV-04']={"The beacons are lit, yet the guardians still block the refuge road. Follow the signal into the Subglacial Archive. Ylva tends the guardians and can read their response.",'The archive signal protects the refuge road again. The palace still repeats the false alarm; follow the cargo markers toward its fortress.'},
 ['FV-05']={"The shelter road is safe, but the altered alarm plate bore the cargo mark. Look for matching sled tracks on the Silent Battlefield and show them to Ivo, the caravan courier.",'Ivo recognizes the cargo sleds. The tunnel gives travelers a way home while you approach the citadel locks.'},
 ['FV-06']={"Ivo traced the cargo to Frost Citadel Gate. Its guardian is still on alert. Open both locks so the signal you restored at the archive can reach it.",'King Ice Golem is resting. The palace road is open, but its final signal mirror still feeds the valley alarm.'},
 ['FV-07']={"The gate guardian is resting, but the palace mirrors still carry the false alarm. Follow the open road to Ice Mirror Palace and quiet the storm at its source.",'The storm eases and the villages reunite. Ivo\'s records lead to Ember Caldera, where the Crownheart was sent to be fitted into a portal-key frame.'},
 ['EC-01']={"Ivo's records point to the great furnace. At Ash Gate the freight lift has stopped, stranding the workers who know the road into Forge City. Help them get it moving.","The lift carries the workers home to Forge City. Brann, their forge leader, is at the workshop. He needs help reaching the crew trapped below the city."},
 ['EC-02']={"The lift brought the crew home, but miners are still missing. Find Brann, the forge leader, at the city workshop. He knows who went underground and what they took.",'Orik knows the mine, Dagna knows the cooling flow, and Brann knows the protection relay. Rescue Orik and the miners first.'},
 ['EC-03']={"Brann marked the collapsed mine on your map. Orik, the mine foreman, is inside with his crew. Brace the tunnel so you can bring them and their channel map out.","Orik and the miners can get home. Their map shows two damaged valves. Find Dagna, the cooling engineer, at the Split Coolant Canals and show her where the flow stops."},
 ['EC-04']={"Orik's map shows where the coolant stopped. Take it to Dagna, the cooling engineer, at the Split Coolant Canals so she can get coolant flowing back to the furnace.",'Coolant circulates again. The ancestral design vault holds the protection circuit needed for a safe restart.'},
 ['EC-05']={"Coolant is flowing again. The crew still needs a way to keep the city safe when the furnace restarts. Take their plans to the model in the Ancestral Design Vault.",'The model works because the whole crew helped. Take the repair kit to the testworks before restarting the great furnace.'},
 ['EC-06']={"The model held when all three parts were connected. Carry the repair kit to the Geothermal Heart Testworks and see if the circuit holds under real heat.",'The protected test succeeds. The crew can help you reclaim and restart the great furnace safely.'},
 ['EC-07']={"The testworks held under heat. Use the same circuit at the Great Furnace, drive out the Inferno Overlord, and check the loading records for the Crownheart.","The city is safe. The Crownheart left before your arrival. Veyr's dispatch names the royal tomb. Follow Brann's map to Mist Gate in Haunted Graveyard, where Rook is scouting the way in."},
 ['HG-01']={"Veyr sent the Crownheart to the royal tomb. Follow Brann's map to Mist Gate and meet Rook, the alliance scout who knows the approach your friends marked.","The scouts' lanterns led you to shelter. Garrick, the grave keeper, has gathered your allies here. Ask him how to reach the tomb."},
 ['HG-02']={"The lantern trail ends at Garrick's shelter. The grave keeper has gathered the people who can get you into the tomb. Ask how your allies will reach the gate.","The scouts hold the approach and the dwarves have the gate rig. Find Lumi, the keeper ghost, at the lantern arch. The old service passage reaches the winch from inside."},
 ['HG-03']={"Lumi, the keeper ghost, remembers a passage too narrow for Brann's crew. Meet Lumi at the lantern arch and take that passage to the gate winch.",'The small passage reaches the winch, not the whole allied route. Secure Brann\'s gate so the crew can bring everyone through.'},
 ['HG-04']={"Lumi's passage got you to the inside of the gate. Secure the winch for Brann's crew, then answer Finn's lantern so the scouts know when to bring everyone through.",'Brann\'s gate is secured. The people you rescued hold your way home while you advance to the throne devices.'},
 ['HG-05']={"Your allies are holding the gate for the return trip. Two devices still shield the throne. Break their links so you can reach the royal tomb.",'Both outer links are broken. The tomb approach is exposed, but Veyr still holds the Crownheart inside.'},
 ['HG-06']={"With the outer shield down, you can reach the royal tomb. Read the keeper records inside and break the seal that stands between you and Veyr.",'The tomb seal is open and your retreat is secured. Defeat Veyr, release the Crownheart from his frame, then close the portal.'},
 ['HG-07']={"Your friends have secured the road home. Defeat Veyr at the black throne, lift Dawnspire's Crownheart out of its frame, and close the invasion portal.",'Veyr is defeated, the Crownheart is free, and the invasion portal is closed. Return to Dawnspire to restore the throne and meet your friends.'},
 ['DW-Q1']={'Recover the convoy\'s waterproof list so the survivors can account for their missing supplies and workers.','The survivors have their supply record and names list. They can account for the recovered stores and the workers who returned.'},
 ['DW-Q2']={'Recover Liora\'s stolen food and free the captives so the rescued camp can share a proper meal.','The recovered food reaches Liora\'s camp table. The rescued travelers prepare a proper meal together.'},
 ['DW-Q3']={'Inspect the quarry transport gear and secure a hauling route the outpost workers can use again.','Fen has the quarry findings. The old hauling route can help the outpost recover its supplies.'},
 ['DW-Q4']={'After the altar is closed, follow the missing scout\'s trail and stop the separate warband at the old battlefield.','The scout returns and Eryn records the safe route. This remaining warband cannot reopen King Shaman\'s closed altar portal.'},
 ['FV-Q1']={'Return the lost badge and luggage so Nessa can reunite Nell with their waiting friends.','Nessa returns Nell\'s belongings. The arrivals board and the badge help the traveler find their waiting friends.'},
 ['FV-Q2']={'Recover the stores from Frostfang Cave and calm the guardian blocking the hauling route.','Freya can bring the recovered cave supplies to the refuge along a safe hauling route.'},
 ['FV-Q3']={'Check the abandoned lake-side stores and calm the guardian so Haldor can reopen the sheltered shore route.','The shore markers connect Blue Lake to the refuge. Haldor has another safe return route for travelers.'},
 ['FV-Q4']={'After the valley storm ends, calm the glacier watch guardian and inspect its old signal route for Ylva.','Ylva has the peaceful watch record. The old glacier signal can guide travelers without restarting the false alarm.'},
 ['EC-Q1']={'Return the lost work mark and safety record so Ketta can welcome Jori back to the crew.','Ketta returns Jori\'s work mark. The rescued worker has their place on the crew board again.'},
 ['EC-Q2']={'Recover the stolen freight from the raider nest and secure Ketta\'s collection route.','Ketta can collect the stolen freight. The repair crew has its materials and a safe road back.'},
 ['EC-Q3']={'Stop the shaman blocking the heat-altar service path and recover the crew stores left there.','The heat-altar path is clear. Ketta\'s crews can reach the recovered stores without entering the old ritual ground.'},
 ['EC-Q4']={'After the furnace is safe, investigate the titan basin and secure the old ore-hauling route for Ketta.','The titan basin\'s hauling route is recorded. The city can use its old freight landing again without delaying the royal-tomb mission.'},
}
local rows={
 {chapter='DW-01',goal='supplies',step='manifest',text='Eryn: Food and medicine for the village. This is our missing supply convoy. Let us find the people who carried it.'},
 {chapter='DW-03',goal='report',text='Selene: Everyone is safe at camp. I would like to help on your journey. Recruitment is free; your first one-story support is free too. Visit my supporter details when you are ready.'},
 {chapter="DW-03",goal="report",step="account",approach="The camp priestess is counting the survivors.",text="Selene: I counted the last cart in. Everyone you brought off that road has a bed here. What do they need first?"},
 {chapter='DW-03',goal='report',step='missing',text='Selene: We are friends now! Recruitment is free. Your first one-story support is free; later stories use saved support credits. You can travel without my support too.'},
 {chapter="DW-03",goal="erin",step="trust",approach="The scout captain needs the driver's sketch.",text="Eryn: The driver drew this tower signal for me. If we can see it from camp, we can find the workers he saw there."},
 {chapter='DW-07',goal='exp_2',step='step1',text='The broken-crown stamp marks the enemy\'s cargo. It differs from the village supply convoy seal you recovered at the creek.'},
 {chapter='DW-07',goal='core_record',text='The Crownheart cargo took Gloamwood\'s old road. Eryn\'s scouts followed those separate cargo tracks and have not returned.'},
 {chapter="DW-07",goal="core_record",text="Orders: Carry the Crownheart through the old road in Gloamwood.",title="Read the convoy orders",step="cost"},
 {chapter="DW-07",goal="core_record",text="Eryn: Our scouts followed that convoy into Gloamwood. We have not heard from them. First, let us close this portal!",title="Share the clue with Eryn",step="replacement"},
 {chapter='DW-07',goal='core_record',step='purpose',text='This delivery label names the Crownheart, not the village food-and-medicine convoy. Both trails passed through the raiders\' camp.'},
 {chapter="DW-07",goal="separate",text="The orders mark the old road into Gloamwood. Return to Eryn with the news.",title="Take the delivery orders",step="secure"},
 {chapter="DW-07",goal="restoration",text="Eryn: The convoy is home! Who gets the first supplies, the camp or the village? We'll help both. Then meet Maeve on Gloamwood's Lantern Trail. Her scouts followed the stolen Crownheart."},
 {chapter="GW-01",goal="maeve",step="confirmed",title="Meet Captain Maeve on Lantern Trail",approach="Her missing scouts followed the stolen cargo.",text="Maeve: Finn is my lantern scout. His last signal said Tali was caught in the webs. He stayed with her. Start at the broken cart and look for lanterns marked with three gold bars."},
 {chapter="GW-01",goal="marks",step="confirmed",title="Read the marks by the broken cart",text="At the broken cart, wheel ruts run north. Boot prints turn under the low branches toward the webs. A lantern with three gold bars hangs over that trail."},
 {chapter="GW-01",goal="exp_2",text="A low lantern shines at the outer webs. Light the trail lantern so the rescue team can follow you to Finn."},
 {chapter="GW-01",goal="exp_2",step="step3",title="Spot Finn's light at the outer webs",text="From the lookout you can see a low light at the outer webs. Finn is keeping it where Tali can see it."},
 {chapter="GW-01",goal="lantern",step="confirmed",text="The fork is lit. Follow the three-bar lanterns under the branches to Finn at the edge of the webs."},
 {chapter="GW-02",goal="finn",step="confirmed",title="Meet Finn at the outer webs",approach="Maeve's lantern scout stayed to help Tali.",text="Finn: See that strand moving? Tali's caught just past it. I tried to go in, but my hands won't stop shaking. If I hold the light for her, can you get through?"},
 {chapter="GW-02",goal="bindings",text="Tali: You found me! The Crownheart convoy passed before the spiders caught us. Our other scouts are still deeper in the forest.",title="Cut the web bindings",step="confirmed"},
 {chapter='GW-03',goal='exp_1',step='step1',text='The lanterns confirm that more scouts are missing beyond the roots. We need a route for the whole group to return.'},
 {chapter="GW-03",goal="report",step="confirmed",text="Maeve: Tali marked the last place she saw the others. The roots block our way there. Ask the Wispkeeper here at the refuge. Our forest friend knows the old road."},
 {chapter="GW-03",goal="wisp",step="confirmed",title="Ask the Wispkeeper at Lantern Refuge",approach="This forest friend knows the old rootway.",text="Wispkeeper: These roots reach all the way to the hunting ground. Start at the Ancient Rootway. Light its lantern and the missing scouts will have a way back."},
 {chapter='GW-06',goal='exp_2',step='step3',text='Finn: Everyone is on the refuge route. Hold the rear while I bring them to Maeve. Tali will mark the northern turn once our friends are safe.'},
 {chapter='GW-07',goal='exp_1',text='The Widow Queen holds this webbed road as her hunting ground. Defeat her so travelers can use the northern exit again.'},
 {chapter="GW-07",goal="exit",text="The old road is open. Beyond the clearing mist, snowy mountains rise above the forest.",title="Cut the web sealing the northern exit",step="confirmed"},
 {chapter='GW-07',goal='exp_2',text='Tali: Finn brought everyone to Maeve. I followed the cleared rootway to mark this northern turn. The cargo went toward that snowy ridge.'},
 {chapter='GW-07',goal='exp_2',step='step3',text='Tali returned along the secured rescue route after the scouts reached the refuge. Her marker points toward the snowy ridge.'},
 {chapter="GW-07",goal="entrance",text="Tali: I saw them carry the Crownheart toward Frozen Vale. Take the northern road. We will keep this path safe for everyone!",title="Ask Tali where the convoy went",step="confirmed"},
 {chapter="FV-01",goal="pathfinder",step="confirmed",title="Meet Freya on the Blizzard Gate trail",approach="The mountain guide knows the shelter trail.",text="Freya: I guide people through this pass. See where the lanterns disappear below the ridge? Some travelers never made it back up. Come with me."},
 {chapter="FV-02",goal="welcome",step="confirmed",title="Find Haldor inside Ember Refuge",approach="The refuge keeper has room for the travelers.",text="Haldor: Come in out of the snow. I've made room for both villages. Nessa is our medic. Can you help her sort the supplies?"},
 {chapter='FV-02',goal='exp_2',text='The refuge has a plan: reconnect the ravine crossing, then follow the cargo trail through the valley.'},
 {chapter='FV-02',goal='route',text='Freya: Someone has kept the fortress alarms awake. First reconnect the shelter beacons; then we can follow their signal and learn why the guardians are blocking us.'},
 {chapter='FV-03',goal='exp_2',text='The ravine crossing now links both beacon teams to the refuge. The fortress alarm still blocks the roads farther into the valley.'},
 {chapter='FV-04',goal='relay_east',text='Both archive relays are ready. The fortress still repeats a false alarm; send the original shelter signal along this local road.'},
 {chapter="FV-04",goal="ylva",step="confirmed",approach="The guardian tender can read its response.",text="Ylva: See how the guardian settles when it hears the shelter signal? The palace mirrors are still sounding the alarm. We'll need this signal there too."},
 {chapter="FV-05",goal="courier",step="confirmed",title="Show Ivo the marks at the tunnel exit",approach="The caravan courier knows these sled tracks.",text="Ivo: I run freight on this road. I saw sleds with that mark go through the citadel. Open the fortress road and we can check their destination against the records."},
 {chapter='FV-06',goal='exp_1',text='The service walk links both ice locks. Open them in turn to carry the archive signal into the guardian court.'},
 {chapter='FV-06',goal='exp_1',step='step3',text='The service path reaches the second lock. The first lock stays open while you use it.'},
 {chapter='FV-06',goal='exp_2',step='step3',text='The gate guardian hears the rest signal, but its storm magic is still raging. Help calm it so it can settle.'},
 {chapter='FV-07',goal='exp_2',step='step3',text='Ivo: This dispatch matches the cargo sleds. They took the heart to Ember Caldera to fit it into a portal-key frame. The freight road leads there.'},
 {chapter="FV-07",goal="reunion",text="Ivo: The valley road is open! These records sent the Crownheart to Ember Caldera's furnace to fit it into a portal-key frame. Follow the freight road and find the dwarf crew!",title="Bring the good news to Ivo"},
 {chapter='FV-Q3',goal='inspect',title='Inspect the sheltered shore handrail',text='The lake stores sit beside old shore markers. Haldor can use this sheltered return route once its guardian is calm.'},
 {chapter='FV-Q3',goal='report',text='Haldor: The shore markers lead home again. I can guide the next travelers by the lake. Thank you!'},
 {chapter='FV-Q4',goal='inspect',title='Inspect the watch relay plate',text='The storm has ended, but this old watch is still receiving a local warning. Ylva needs its duty record and a safe way to the relay.'},
 {chapter='FV-Q4',goal='report',text='Ylva: The watch record matches the peaceful signal. We can keep this glacier path safe without waking the valley alarm again.'},
 {chapter="EC-02",goal="brann",step="confirmed",title="Meet Brann at the Forge City workshop",approach="The forge leader needs his missing crew.",text="Brann: The furnace is in monster hands. Orik, our mine foreman, is trapped with his crew. Dagna needs his map to fix the cooling lines. Ketta has tools here for the rescue."},
 {chapter="EC-02",goal="tools",step="confirmed",approach="The tool supplier has gear for the rescue.",text="Ketta: Take these from my bench. You'll need them to brace the mine before you bring Orik's crew out."},
 {chapter="EC-04",goal="engineer",step="confirmed",title="Meet Dagna at the Split Coolant Canals",approach="The cooling engineer needs Orik's map.",text="Dagna: Let me see Orik's map. Here, these two valves are stuck. Help me open them and we can get coolant back to the furnace."},
 {chapter='EC-05',goal='exp_1',step='step3',text='Brann: I traced the inlet but missed that closed return. Orik and Dagna caught it. My protection relay needs their complete loop.'},
 {chapter='EC-07',goal='exp_2',step='step1',text='The dispatch records the framed Crownheart leaving before your arrival. Its empty carrier and delivery time show how far ahead the cargo traveled.'},
 {chapter='EC-07',goal='exp_2',step='step2',text='Veyr\'s order names the royal tomb: Bind Dawnspire\'s heart into the gate. Send the army to the town it once protected.'},
 {chapter="EC-07",goal="exp_2",step="step3",text="Brann: Suri, our city courier, sent my map to Maeve. Look for Suri here at the furnace before you leave. My crew will bring the gate rig."},
 {chapter="EC-07",goal="courier",step="confirmed",title="Find Suri at the Great Furnace",approach="The city courier has word from the scouts.",text="Suri: Veyr sent the heart ahead to open a gate into Dawnspire. I sent Brann's map to Maeve. Take the tomb road to Mist Gate. Rook, our alliance scout, will meet you there."},
 {chapter='EC-Q3',goal='inspect',title='Inspect the abandoned service tools',text='Crew stores were abandoned by the heat altar. The shaman blocks the service path the workers need to recover them.'},
 {chapter='EC-Q3',goal='report',text='Ketta: The heat-altar service path is clear. Our crew can bring those stores home without crossing the ritual ground.'},
 {chapter='EC-Q4',goal='inspect',title='Inspect the old ore sleds',text='The city furnace is safe. These ore sleds mark an older hauling route through the titan basin; Ketta wants it checked for the returning crew.'},
 {chapter='EC-Q4',goal='report',text='Ketta: I have your hauling record. We can reopen the freight landing while you follow the royal-tomb mission.'},
 {chapter="HG-01",goal="rook",step="confirmed",title="Meet Rook at Mist Gate",approach="The alliance scout knows the way to shelter.",text="Rook: I scouted this road with Brann's map. Finn and Tali marked the turns with their lanterns. Follow them to Garrick, the grave keeper sheltering our friends."},
 {chapter="HG-02",goal="garrick",step="confirmed",title="Find Garrick at the keeper shelter",approach="The grave keeper gathered your allies here.",text="Garrick: I keep this shelter. Lumi, a keeper ghost, knows a passage to the winch. Before you go, speak to Elowen, our historian. She found the binding frame in the old records."},
 {chapter="HG-02",goal="elowen",step="confirmed",title="Ask Elowen about the binding frame",approach="The historian has the old keeper records.",text="Elowen: The heart is intact. The frame around it bends its light into Veyr's gate. Break the shield links and defeat him so you can free it. Lumi will meet you at the lantern arch."},
 {chapter="HG-03",goal="lumi",step="confirmed",title="Meet Lumi at the lantern arch",approach="The keeper ghost knows a way to the winch.",text="Lumi: I used to light these lanterns for visitors. I can take you through the keeper passage to the winch. Can you clear the way while I guide you?"},
 {chapter='HG-03',goal='exp_2',text='The narrow keeper passage reaches the winch side. You can secure Brann\'s rig from inside so the allied crew can use the main gate.'},
 {chapter='HG-03',goal='passage',step='confirmed',text='Lumi: The winch is just ahead! I will guide the next helpers through this passage. Open Brann\'s main gate for the rest of our friends.'},
 {chapter='HG-05',goal='exp_2',text='The western shield line has failed. Reach the eastern control to remove the remaining outer link; Veyr still controls the heart inside.'},
 {chapter='HG-06',goal='exp_1',step='step2',text='The furnace-made frame redirects the intact Crownheart into Veyr\'s invasion gate. Freeing it after Veyr falls will let you close that gate.'},
 {chapter='HG-07',goal='crownheart',step='confirmed',text='The Crownheart comes free of the binding frame and shines again. Shut the portal control before leaving with your friends.'},
 {chapter='HG-07',goal='exp_2',step='step1',text='The heart is already free. Release the empty frame\'s last catch so the portal control can shut safely.'},
}
local T={version=2}
function T.install(content)
 for _,row in ipairs(rows)do
  local chapter=assert(content.byId[row.chapter])
  local goal
  for _,g in ipairs(chapter.goals)do if g.id==row.goal then goal=g;break end end
  assert(goal,'Unknown story goal')
  local target=goal
  if row.step then
   target=nil
   for _,step in ipairs(goal.activity.steps)do if step.id==row.step then target=step;break end end
   assert(target,'Unknown story step')
  end
  if row.approach then goal.approach=row.approach end
  if row.title then target.title=row.title end;target.text=row.text
  if not row.step and goal.activity and #goal.activity.steps==1 then goal.activity.steps[1].text=row.text end
  -- Single-step objectives share the same authored instruction in HUD and phases.
  if row.step and #goal.activity.steps==1 then goal.title=target.title;goal.text=target.text end
  if row.title and (not row.step or #goal.activity.steps==1)then
   for _,phase in ipairs(chapter.quest.phases or {})do
    if #phase.goals==1 and phase.goals[1]==goal.id then phase.title=goal.title end
   end
  end
 end
 for id,words in pairs(chapters)do
  local chapter=assert(content.byId[id],'Unknown reviewed story '..id)
  chapter.quest.brief=words[1];chapter.quest.outcome=words[2]
 end
 for _,chapter in ipairs(content.chapters)do for _,goal in ipairs(chapter.goals)do
  if goal.activity and goal.activity.steps and #goal.activity.steps==1 then goal.text=goal.activity.steps[1].text end
 end end
end
return T
