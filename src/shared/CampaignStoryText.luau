-- Current narrative continuity, reviewed 2026-11-10. IDs and substep counts are preserved.
local rows={
 {chapter="DW-07",goal="core_record",text="Orders: Carry the Crownheart through the old road in Gloamwood.",title="Read the convoy orders",step="cost"},
 {chapter="DW-07",goal="core_record",text="Eryn: Our scouts followed that convoy into Gloamwood. We have not heard from them. First, let us close this portal!",title="Share the clue with Eryn",step="replacement"},
 {chapter="DW-07",goal="separate",text="The orders mark the old road into Gloamwood. Return to Eryn with the news.",title="Take the delivery orders",step="secure"},
 {chapter="DW-07",field="outcome",text="The portal is closed and the convoy is home! Follow the Crownheart trail into Gloamwood and find the missing scouts."},
 {chapter="DW-07",goal="restoration",text="Eryn: Our friends and supplies are home! Shall we help the forest camp or deliver supplies to the village first? Both groups will get help. Then we can follow the Crownheart trail into Gloamwood!"},
 {chapter="GW-01",field="brief",text="Follow the Crownheart convoy trail into Gloamwood and help Maeve find the missing scouts."},
 {chapter="GW-01",goal="maeve",text="Maeve: Our scouts followed the Crownheart convoy along this old road. Now they are trapped in the webs. Follow their lantern marks!",title="Meet Maeve at the forest entrance",step="confirmed"},
 {chapter="GW-01",goal="marks",text="Wheel tracks pass a broken cart. Beside them, scout marks point deeper into the webs. Finn is waiting ahead.",title="Read the missing scout trail marks",step="confirmed"},
 {chapter="GW-02",goal="bindings",text="Tali: You found me! The Crownheart convoy passed before the spiders caught us. Our other scouts are still deeper in the forest.",title="Cut the web bindings",step="confirmed"},
 {chapter="GW-03",goal="wisp",text="Wispkeeper: The old road reaches the snowy mountains. Follow the lanterns past the roots, and bring your friends safely through.",title="Ask the Wispkeeper for the northern route",step="confirmed"},
 {chapter="GW-07",field="brief",text="Defeat the Widow Queen, free the northern exit, and learn where the Crownheart convoy went."},
 {chapter="GW-07",goal="exit",text="The old road is open. Beyond the clearing mist, snowy mountains rise above the forest.",title="Cut the web sealing the northern exit",step="confirmed"},
 {chapter="GW-07",goal="entrance",text="Tali: I saw them carry the Crownheart toward Frozen Vale. Take the northern road. We will keep this path safe for everyone!",title="Ask Tali where the convoy went",step="confirmed"},
 {chapter="GW-07",field="outcome",text="Every scout is safe! The northern road is open, and the Crownheart trail leads to Frozen Vale."},
 {chapter="FV-01",field="brief",text="Follow Tali's lead into Frozen Vale. Find Freya, rescue the stranded travelers, and relight the shelter lanterns."},
 {chapter="FV-07",goal="reunion",text="Ivo: The valley road is open! These records sent the Crownheart to Ember Caldera's furnace to fit it into a portal-key frame. Follow the freight road and find the dwarf crew!",title="Bring the good news to Ivo"},
 {chapter="FV-07",field="outcome",text="The storm has eased and the villages are reunited! The delivery records lead to the great furnace in Ember Caldera."},
 {chapter="EC-07",goal="courier",text="Suri: The dispatch says the framed Crownheart left before we reached the furnace. Veyr will use it at the royal tomb to attack Dawnspire. I sent Brann's route to Maeve; her scouts are securing the approach. Let us stop him together!",title="Meet Suri with the enemy delivery orders",step="confirmed"},
 {chapter="EC-07",field="outcome",text="The city is safe and the workshops are running again! Veyr's orders reveal the royal tomb and its approach. Your friends are ready. Set out for Haunted Graveyard!"},
 {chapter="HG-01",goal="rook",text="Rook: We followed the route Brann marked. The scouts you rescued in Gloamwood secured the approach. The elves and dwarves are ready. Let us stop Veyr together!",title="Meet Rook at the hidden entrance",step="confirmed"},
}
-- Every story has a distinct problem, earned result, and concrete next reason.
local chapters={
 ['DW-01']={'Dawnspire\'s Crownheart is missing. Help Eryn find the village supply convoy; its route may reveal who is moving through the forest.','The supplies identify the missing convoy. A cloth signal leads to survivors beside the broken cart.'},
 ['DW-02']={'Bring the recovered medicine to the survivors, rescue their missing driver, and mark the road to camp.','The survivors and driver are on the safe camp route. Tell Selene the rescue is complete, then follow the driver\'s watchtower clue.'},
 ['DW-03']={'Report the rescue to Selene and plan the missing workers\' rescue with Eryn. Selene\'s recruitment is free; story support is separate.','Selene is recruited. The driver\'s signal sketch gives Eryn a route to the watchtower and its captive forest friend.'},
 ['DW-04']={'Disable the watchtower devices, free the captive forest friend, and reconnect the camp signal.','Your forest friend has a safe way home. The restored signal and raiders\' map reveal cages in the occupied ruins.'},
 ['DW-05']={'Free the convoy workers, stop the barracks signal, and defeat the Orc Warlord blocking their escape.','The workers are safe. King Shaman\'s orders lead through a threatened forest village to the Black Root Altar.'},
 ['DW-06']={'Help the forest families disable the root devices and mark a route safe for residents and rescuers alike.','The families have a way back to camp. Their marked rootway leads to King Shaman\'s altar.'},
 ['DW-07']={'Defeat King Shaman, close the local monster portal, and check the stolen Crownheart\'s delivery orders.','The supply convoy is home and the altar portal is closed. The Crownheart cargo went into Gloamwood; Eryn\'s scouts followed and have not returned.'},
 ['GW-01']={'Help Maeve separate the Crownheart cargo trail from the missing scouts\' rescue marks.','The cargo wheels continue north, but the scout marks turn into the webs. Finn is waiting near the trapped Tali.'},
 ['GW-02']={'Help Finn hold a light for Tali, cut her bindings, and prepare her safe return.','Tali is free and confirms the cargo passed ahead of the scouts. Escort her to Maeve at Lantern Refuge.'},
 ['GW-03']={'Bring Tali to the refuge and use her map to plan a way in and a safe way out for the remaining scouts.','Maeve will hold the refuge. The Wispkeeper points to the rootway, the hunting ground, and the old road beyond.'},
 ['GW-04']={'Defeat Ancient Hollowbark and reconnect the inner rootway to the refuge.','The rootway is open. Its ropes and lanterns give the missing scouts a return route through the forest.'},
 ['GW-05']={'Defeat Venomcoil King and mark a crossing that keeps the scouts out of the hunting ground.','The crossing is secure. The last scout signals come from the edge of the queen\'s territory.'},
 ['GW-06']={'Free the last scouts, follow Finn\'s light, and hold off Hollowbark Sovereign while the group reaches safety.','The scouts reach the refuge route while you hold the rearguard. Finn keeps the group together; the northern exit still lies beyond the queen.'},
 ['GW-07']={'Defeat the Widow Queen, open the webbed northern exit, and check Tali\'s cargo marker.','The scouts are safe and the northern road is open. Tali confirms the Crownheart cargo went toward Frozen Vale.'},
 ['FV-01']={'Follow Tali\'s lead into the valley. Help Freya rescue the stormbound travelers and relight the refuge trail.','The travelers can reach Ember Refuge. Their relief supplies and broken village links need attention.'},
 ['FV-02']={'Deliver relief supplies and help Haldor, Nessa, and Freya plan a crossing between the two village beacons.','The refuge has medicine and a rescue plan. Restore the ravine crossing so the beacon teams can reach both sides.'},
 ['FV-03']={'Rescue the ravine keeper, restore the crossing, and relight both village beacons.','The ravine crossing is safe, but the fortress alarm still drives the storm. Follow the signal line into the archive.'},
 ['FV-04']={'Compare the false warning with the guardian\'s behavior. Help Ylva restore the archive\'s shelter signal.','The archive signal protects the refuge road again. The palace still repeats the false alarm; follow the cargo markers toward its fortress.'},
 ['FV-05']={'Identify the Crownheart sled marks and reopen the sheltered tunnel so Ivo can confirm their route.','Ivo recognizes the cargo sleds. The tunnel gives travelers a way home while you approach the citadel locks.'},
 ['FV-06']={'Open both ice locks, carry the restored signal to King Ice Golem, and calm its remaining storm magic.','King Ice Golem is resting. The palace road is open, but its final signal mirror still feeds the valley alarm.'},
 ['FV-07']={'Restore the palace mirrors, calm Queen Ice Elf, and end the false alarm across the valley.','The storm eases and the villages reunite. Ivo\'s records lead to Ember Caldera, where the Crownheart was sent to be fitted into a portal-key frame.'},
 ['EC-01']={'Recover the freight-lift gear and help the stranded workers reach Forge City.','The freight lift is working and the city road is open. Brann needs help bringing the trapped mine crew home.'},
 ['EC-02']={'Meet Brann and Ketta. Find the missing crew and prepare the tools needed to repair the city together.','Orik knows the mine, Dagna knows the cooling flow, and Brann knows the protection relay. Rescue Orik and the miners first.'},
 ['EC-03']={'Brace the mine, stop the magma worm, and guide Orik and the miners to the safe exit.','The miners can return to the city. Orik\'s map shows Dagna where the cooling channels have failed.'},
 ['EC-04']={'Help Dagna restore the supply and return channels, then recover the complete safety-circuit plan.','Coolant circulates again. The ancestral design vault holds the protection circuit needed for a safe restart.'},
 ['EC-05']={'Combine Dagna\'s inlet, Orik\'s return, and Brann\'s protection clues. Test their complete loop on the model.','The model works because the whole crew helped. Take the repair kit to the testworks before restarting the great furnace.'},
 ['EC-06']={'Clear Magma Golem from the testworks and check that the repaired cooling circuit protects the city.','The protected test succeeds. The crew can help you reclaim and restart the great furnace safely.'},
 ['EC-07']={'Use the repaired coolers, defeat Inferno Overlord, and reclaim the furnace. Check where the Crownheart cargo was sent.','The city is safe. The Crownheart left before your arrival, but Veyr\'s dispatch reveals the royal tomb. Brann\'s route and Maeve\'s scouts open the approach to Haunted Graveyard.'},
 ['HG-01']={'Follow the route secured by the rescued scouts and meet Rook at the graveyard entrance.','The scouts\' lanterns connect Brann\'s approach to the keeper shelter. Gather with the allies preparing the assault.'},
 ['HG-02']={'Learn the assault plan from Garrick, Eryn, Brann, and Elowen. Find out how Lumi can reach the inner gate.','The scouts hold the approach, the elves guide the return path, and the dwarves ready the gate rig. Take Lumi\'s service passage to the winch.'},
 ['HG-03']={'Help Lumi reopen the keeper passage so you can reach the fortress-side gate machinery.','The small passage reaches the winch, not the whole allied route. Secure Brann\'s gate so the crew can bring everyone through.'},
 ['HG-04']={'Secure the winch, stop Dread Commander, and answer Finn\'s signal to bring the allies through Brann\'s gate.','Brann\'s gate is secured. The people you rescued hold your way home while you advance to the throne devices.'},
 ['HG-05']={'Break the two outer shield links that block the route to Veyr\'s royal tomb.','Both outer links are broken. The tomb approach is exposed, but Veyr still holds the Crownheart inside.'},
 ['HG-06']={'Clear the tomb guards and learn how Veyr\'s binding frame forces the Crownheart to power his invasion gate.','The tomb seal is open and your retreat is secured. Defeat Veyr, release the Crownheart from his frame, then close the portal.'},
 ['HG-07']={'Defeat Veyr, recover the bound Crownheart, and close the invasion portal before returning to Dawnspire.','Veyr is defeated, the Crownheart is free, and the invasion portal is closed. Return to Dawnspire to restore the throne and meet your friends.'},
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
local revisions={
 {chapter='DW-01',goal='supplies',step='manifest',text='Eryn: Food and medicine for the village. This is our missing supply convoy. Let us find the people who carried it.'},
 {chapter='DW-03',goal='report',text='Selene: Everyone is safe at camp. I would like to help on your journey. Recruitment is free; your first one-story support is free too. Visit my supporter details when you are ready.'},
 {chapter='DW-03',goal='report',step='missing',text='Selene: We are friends now! Recruitment is free. Your first one-story support is free; later stories use saved support credits. You can travel without my support too.'},
 {chapter='DW-07',goal='core_record',text='The Crownheart cargo took Gloamwood\'s old road. Eryn\'s scouts followed those separate cargo tracks and have not returned.'},
 {chapter='DW-07',goal='core_record',step='purpose',text='This delivery label names the Crownheart, not the village food-and-medicine convoy. Both trails passed through the raiders\' camp.'},
 {chapter='DW-07',goal='exp_2',step='step1',text='The broken-crown stamp marks the enemy\'s cargo. It differs from the village supply convoy seal you recovered at the creek.'},
 {chapter='GW-01',goal='maeve',step='confirmed',text='Maeve: Eryn sent word about the stolen cargo. My scouts followed it along this old road, then turned into the webs to help each other. Finn is waiting ahead.'},
 {chapter='GW-03',goal='exp_1',step='step1',text='The lanterns confirm that more scouts are missing beyond the roots. We need a route for the whole group to return.'},
 {chapter='GW-06',goal='exp_2',step='step3',text='Finn: Everyone is on the refuge route. Hold the rear while I bring them to Maeve. Tali will mark the northern turn once our friends are safe.'},
 {chapter='GW-07',goal='exp_1',text='The Widow Queen holds this webbed road as her hunting ground. Defeat her so travelers can use the northern exit again.'},
 {chapter='GW-07',goal='exp_2',text='Tali: Finn brought everyone to Maeve. I followed the cleared rootway to mark this northern turn. The cargo went toward that snowy ridge.'},
 {chapter='GW-07',goal='exp_2',step='step3',text='Tali returned along the secured rescue route after the scouts reached the refuge. Her marker points toward the snowy ridge.'},
 {chapter='FV-02',goal='route',text='Freya: Someone has kept the fortress alarms awake. First reconnect the shelter beacons; then we can follow their signal and learn why the guardians are blocking us.'},
 {chapter='FV-02',goal='exp_2',text='The refuge has a plan: reconnect the ravine crossing, then follow the cargo trail through the valley.'},
 {chapter='FV-03',goal='exp_2',text='The ravine crossing now links both beacon teams to the refuge. The fortress alarm still blocks the roads farther into the valley.'},
 {chapter='FV-04',goal='relay_east',text='Both archive relays are ready. The fortress still repeats a false alarm; send the original shelter signal along this local road.'},
 {chapter='FV-06',goal='exp_1',text='The service walk links both ice locks. Open them in turn to carry the archive signal into the guardian court.'},
 {chapter='FV-06',goal='exp_1',step='step3',text='The service path reaches the second lock. The first lock stays open while you use it.'},
 {chapter='FV-06',goal='exp_2',step='step3',text='The gate guardian hears the rest signal, but its storm magic is still raging. Help calm it so it can settle.'},
 {chapter='FV-07',goal='exp_2',step='step3',text='Ivo: This dispatch matches the cargo sleds. They took the heart to Ember Caldera to fit it into a portal-key frame. The freight road leads there.'},
 {chapter='EC-02',goal='brann',step='confirmed',text='Brann: The monsters hold our furnace. Orik is missing in the mine, and Dagna needs his channel map. Help us bring the crew home so we can repair this together.'},
 {chapter='EC-05',goal='exp_1',step='step3',text='Brann: I traced the inlet but missed that closed return. Orik and Dagna caught it. My protection relay needs their complete loop.'},
 {chapter='EC-07',goal='exp_2',step='step1',text='The dispatch records the framed Crownheart leaving before your arrival. Its empty carrier and delivery time show how far ahead the cargo traveled.'},
 {chapter='EC-07',goal='exp_2',step='step2',text='Veyr\'s order names the royal tomb: Bind Dawnspire\'s heart into the gate. Send the army to the town it once protected.'},
 {chapter='EC-07',goal='exp_2',step='step3',text='Brann: Suri has sent my route to Maeve. Our scouts know how to secure a road now. My crew will bring the gate rig after them.'},
 {chapter='HG-01',goal='rook',step='confirmed',text='Rook: Suri sent Brann\'s route. Maeve sent Finn and Tali to mark it while the others guarded the forest refuge. Your friends are waiting at Garrick\'s shelter.'},
 {chapter='HG-02',goal='garrick',step='confirmed',text='Garrick: I keep this shelter. Our keeper friend Lumi found a service passage to the gate winch. Elowen can explain Veyr\'s binding frame; the scouts will keep our way home clear.'},
 {chapter='HG-02',goal='elowen',step='confirmed',text='Elowen: I read the keeper records. The frame forces the Crownheart to power Veyr\'s gate, but the heart is intact. Break the outer shield links, defeat Veyr, free the heart, then shut the portal.'},
 {chapter='HG-03',goal='lumi',step='confirmed',text='Lumi: Hello! I am a keeper ghost. These lanterns used to guide visitors home. My service passage reaches the gate winch; help me make that path safe again.'},
 {chapter='HG-03',goal='exp_2',text='The narrow keeper passage reaches the winch side. You can secure Brann\'s rig from inside so the allied crew can use the main gate.'},
 {chapter='HG-03',goal='passage',step='confirmed',text='Lumi: The winch is just ahead! I will guide the next helpers through this passage. Open Brann\'s main gate for the rest of our friends.'},
 {chapter='HG-05',goal='exp_2',text='The western shield line has failed. Reach the eastern control to remove the remaining outer link; Veyr still controls the heart inside.'},
 {chapter='HG-06',goal='exp_1',step='step2',text='The furnace-made frame redirects the intact Crownheart into Veyr\'s invasion gate. Freeing it after Veyr falls will let you close that gate.'},
 {chapter='HG-07',goal='crownheart',step='confirmed',text='The Crownheart comes free of the binding frame and shines again. Shut the portal control before leaving with your friends.'},
 {chapter='HG-07',goal='exp_2',step='step1',text='The heart is already free. Release the empty frame\'s last catch so the portal control can shut safely.'},
 {chapter='FV-Q3',goal='inspect',text='The lake stores sit beside old shore markers. Haldor can use this sheltered return route once its guardian is calm.'},
 {chapter='FV-Q3',goal='report',text='Haldor: The shore markers lead home again. I can guide the next travelers by the lake. Thank you!'},
 {chapter='FV-Q4',goal='inspect',text='The storm has ended, but this old watch is still receiving a local warning. Ylva needs its duty record and a safe way to the relay.'},
 {chapter='FV-Q4',goal='report',text='Ylva: The watch record matches the peaceful signal. We can keep this glacier path safe without waking the valley alarm again.'},
 {chapter='EC-Q3',goal='inspect',text='Crew stores were abandoned by the heat altar. The shaman blocks the service path the workers need to recover them.'},
 {chapter='EC-Q3',goal='report',text='Ketta: The heat-altar service path is clear. Our crew can bring those stores home without crossing the ritual ground.'},
 {chapter='EC-Q4',goal='inspect',text='The city furnace is safe. These ore sleds mark an older hauling route through the titan basin; Ketta wants it checked for the returning crew.'},
 {chapter='EC-Q4',goal='report',text='Ketta: I have your hauling record. We can reopen the freight landing while you follow the royal-tomb mission.'},
}
for _,row in ipairs(revisions)do table.insert(rows,row)end
local T={version=2}
function T.install(content)
 for _,row in ipairs(rows)do
  local chapter=assert(content.byId[row.chapter])
  if row.field then chapter.quest[row.field]=row.text
  else
   local goal
   for _,g in ipairs(chapter.goals)do if g.id==row.goal then goal=g;break end end
   assert(goal,'Unknown story goal')
   local target=goal
   if row.step then
    target=nil
    for _,step in ipairs(goal.activity.steps)do if step.id==row.step then target=step;break end end
    assert(target,'Unknown story step')
   end
   if row.title then target.title=row.title end;target.text=row.text
   if not row.step and goal.activity and #goal.activity.steps==1 then goal.activity.steps[1].text=row.text end
   -- Single-step objectives share the same authored instruction in HUD and phases.
   if row.step and #goal.activity.steps==1 then goal.title=target.title;goal.text=target.text end
   if row.title and (not row.step or #goal.activity.steps==1)then
    for _,phase in ipairs(chapter.quest.phases)do
     if #phase.goals==1 and phase.goals[1]==goal.id then phase.title=goal.title end
    end
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
