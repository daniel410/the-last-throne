-- en-US character setups, readable evidence and later payoffs. Stable journal IDs.
local B={version=1}
B.beats={
 ['DW-02:exp_1']={title='Bring the convoy medicine to the injured travelers',
  steps={
   {'Deliver the dry medicine case','Selene: You kept it dry! Help me set it beside our injured traveler.'},
   {'Help the traveler sit beneath the awning','Convoy Survivor: That is better. But our cart driver is still out there.'},
   {'Follow the travelers cloth trail mark','Convoy Survivor: He tied blue cloth to the branches. Follow it to bring him back.'}},
  outcome='Selene: The medicine helped him speak. His blue cloth marks will lead us to the missing driver.'},
 ['DW-02:exp_2']={actor='Cart Driver',title='Bring the missing cart driver back to safety',steps={
  {'Guide the cart driver past the fallen trunk','Cart Driver: My friend left cloth on the branches. You found his trail!'},
  {'Follow the cloth to the sheltered bend','Cart Driver: I thought no one would come back. The lanterns are close now.'},
  {'Bring the driver to the waiting survivors','Convoy Survivor: There you are! We saved a place for you under the awning.'}},
  outcome='Eryn: You brought back the medicine and the driver. He saw workers taken toward the old watchtower.'},
 ['DW-03:exp_1']={steps={
  {'Check the travelers recovered medicine','Selene: Your medicine is helping the camp. Now the travelers can tell us what happened.'},
  {'Compare the missing workers list','Eryn: I followed the loaded wheels. You noticed the people who left them.'},
  {'Match the drivers signal sketch','Cart Driver: That broken signal belongs to the watchtower. The workers need help there.'}},
  outcome='Eryn: Your clue changed our plan. We will reconnect the watchtower and bring those workers home.'},
 ['DW-07:exp_2']={steps={
  {'Compare the broken-crown convoy seal','The cargo seal carries a broken-crown mark. It was on the stolen convoy crates too.'},
  {'Trace the marked northern road','The same mark follows the cargo into Gloamwood. King Shaman\'s defeat has exposed the altar portal.'},
  {'Read Eryn\'s missing scout warning','Eryn: Our scouts followed those marks. They have not returned. We need to find our friends.'}},
  outcome='The convoy is safe and King Shaman is defeated. Secure the orders, close the altar portal, then follow the broken-crown trail to Eryn\'s missing scouts.'},
 ['GW-01:exp_1']={steps={
  {'Compare the wheel ruts with the light footprints','The deep wheels continue north. The scouts light footprints turn toward the webs.'},
  {'Find the three-bar scout lantern','Maeve: Three gold bars mark our scout lanterns. Finn carries one just like it.'},
  {'Match the marks beneath the branches','Someone left a scout mark facing the webs, away from the convoy. A friend needed help.'}},
  outcome='Maeve: The cargo went north. Our friends went into the webs. Follow the scout lanterns and bring them home.'},
 ['GW-02:exp_1']={steps={
  {'Follow Finn\'s low lantern mark','Finn: I can see Tali. I just wish those webs were a little less... full of spiders.'},
  {'Reach the web anchor lookout','Tali: Finn, keep your lantern where I can see it. I will follow your light.'},
  {'Stand beside Finn at the rescue opening','Finn: Right. One step. I can hold a light for my friend.'}},
  outcome='Finn keeps his three-bar lantern raised. Tali can see the safe opening while you release the web anchors.'},
 ['GW-06:exp_1']={outcome='The last scout reaches Finn. He lifts the same three-bar lantern that once shook in his hands.'},
 ['GW-06:exp_2']={steps={
  {'Follow Finn\'s raised scout lantern','Finn: I am still scared. Tali needs a light. I will go first.'},
  {'Keep the scouts together at the rope turn','Tali: We can all see your lantern, Finn. Keep going!'},
  {'Reach Finn\'s rearguard signal','Finn: Everyone is past the nests. Keep the rear clear; I will take our friends home.'}},
  outcome='Finn leads the scouts home beneath his three-bar lantern. Hold the rearguard clearing so every friend can leave safely.'},
 ['GW-07:exp_2']={outcome='Tali: The convoy went toward that snowy ridge. Finn and I will keep this road safe for everyone you send home.'},
 ['FV-02:exp_1']={outcome='Nessa: Both villages need this medicine. Freya has not given up on their travelers. Let us give her a way to bring them home.'},
 ['FV-04:exp_1']={steps={
  {'Compare the shelter sign with the warning beam','Ylva: Watch the guardian and the beam together. The shelter sign points to safety.'},
  {'Inspect the plate sending the wrong warning','The alarm beam points at the refuge road. The guardian turns to block that road, as if it were the danger.'},
  {'Compare the convoy seal with the altered plate','A stamped order says: Keep the valley alarms awake. Its broken-crown mark matches the convoy from Deepwood.'}},
  outcome='Ylva: The guardian is protecting the wrong road. Restore the shelter signal so it can protect the travelers again.'},
 ['FV-04:exp_2']={steps={
  {'Send the shelter sign along its original beam','The first beam points toward the shelter. The guardian turns away from the refuge entrance.'},
  {'Reconnect the two village road signs','Freya: That is our road! The warning is no longer aimed at our travelers.'},
  {'Send the guardian rest sign','The guardian lowers its warning stance and faces the outer road. The refuge approach is safe again.'}},
  outcome='Ylva: You saw what the warning was doing and corrected it. Carry this peaceful signal to the citadel guardians.'},
 ['FV-07:exp_2']={steps={
  {'Look through the clearing storm window','Freya: I was afraid we had lost the road for good. Look at the lights you brought back.'},
  {'Follow the two village beacon lights','Travelers from both villages follow the same safe road. No one has to cross the storm alone.'},
  {'Meet Ivo at the delivery table','Ivo: These records follow the broken-crown cargo to Ember Caldera. They were taking the heart to its furnace.'}},
  outcome='Freya guides the reunited travelers herself. Ivo\'s records reveal where the Crownheart was taken, and the valley roads remain open behind you.'},
 ['EC-02:exp_1']={outcome='Brann: I know these machines, but Orik knows the mine and Dagna knows the flow. We will need the whole crew to bring our city back.'},
 ['EC-05:exp_1']={steps={
  {'Compare Dagna\'s inlet drawing','Dagna: The triangle valve feeds the tank. Follow the arrow into the circuit.'},
  {'Read Orik\'s return-line drawing','Orik: The ring valve sends coolant back. A working city needs a way in and a way home.'},
  {'Inspect Brann\'s city protection relay','Brann: I missed that closed return. You both caught it. Let us test your complete loop.'}},
  outcome='Dagna found the inlet, Orik found the return, and Brann has the protection relay. Use their drawings to test the model safely.'},
 ['EC-05:exp_2']={steps={
  {'Trace the drawing to the tank inlet','Dagna: Look for the triangle and the arrow pointing INTO the tank. Turn that control.'},
  {'Trace the drawing back to the return tank','Orik: Find the ring and the arrow pointing BACK to the tank. We need a complete loop.'},
  {'Connect the city shield on the model','Brann: The shield relay protects the city. The broken relay leaves it exposed.'}},
  outcome='Brann: Your complete loop works! Dagna, Orik, take your stations. This time we will test the protection together.'},
 ['EC-07:exp_2']={steps={
  {'Inspect the empty key carrier','The Crownheart has already left the furnace. Its carrier bears the broken-crown mark you followed through the forest and snow.'},
  {'Read Veyr\'s invasion dispatch','The order names Veyr and the royal tomb. He plans to force the Crownheart into an invasion gate aimed at Dawnspire.'},
  {'Find the crew\'s royal tomb approach map','Brann: Our workshops are free. The scouts will mark the approach; we will bring the gate rig.'}},
  outcome='The city is working again. Veyr\'s plan is exposed, and the people you saved are preparing the route to stop him.'},
 ['HG-01:exp_1']={outcome='Rook: Those are Finn\'s three-bar lanterns and Brann\'s route marks. Our friends kept their promises. Follow the way they opened.'},
 ['HG-04:exp_2']={steps={
  {'Set Brann\'s winch safety catch','Brann: Orik checked the return catch. It will hold the gate while our friends come through.'},
  {'Answer Finn\'s three-bar entry lantern','Finn: The scouts are ready! Tali, show everyone the clear approach.'},
  {'Open the allies inner meeting point','The scouts bring the others through Brann\'s opened gate. The people you rescued have opened your way to the tomb.'}},
  outcome='Brann: That is Finn\'s lantern. Your forest rescue, the valley road and our workshop all brought us here. We have your way home.'},
 ['HG-06:exp_1']={steps={
  {'Read the keepers throne record','The Crownheart protects Dawnspire. Its light was never meant to open a monster gate.'},
  {'Inspect the invasion seal diagram','Veyr has forced the same protecting power into the invasion portal. The heart must be freed.'},
  {'Read the hurried tomb-road order','A fresh dispatch reads: The forest scouts and city crew have reached the gate. Seal the tomb road.'}},
  outcome='Lumi: Our friends got through, and now he is trying to shut us out. Open the tomb, free the heart, and stop his gate.'},
 ['HG-07:exp_2']={outcome='Lumi: The heart is safe, and our friends have the exit. Close the portal. Then let us take its light home.'},
 ['DW-Q2:exp_1']={outcome='Liora: The food is ready for the trip home. I promised the camp a proper meal. Soup made only of warm water was not very popular.'},
 ['FV-Q1:exp_1']={steps={
  {'Read the name on the recovered badge','The worn badge reads NELL. Its village mark matches the rescued travelers.'},
  {'Find Nell on Nessa\'s arrivals list','Nessa kept a place for Nell. Their friends are waiting at the refuge.'},
  {'Mark Nell\'s sheltered return road','The badge and the safe road can bring Nell back to their friends.'}},outcome='Nessa: Nell! That is the name on our arrivals list. Return this badge and Nell can find the friends waiting for them.'},
 ['EC-Q1:exp_1']={steps={
  {'Read Jori\'s number on the work mark','This work mark belongs to Jori, one of the missing mine workers.'},
  {'Find Jori\'s place on Ketta\'s crew board','Ketta never erased the name. Jori still has a place in the workshop.'},
  {'Mark the way back to the workshop','The crew can return the mark when Jori reaches the workshop.'}},outcome='Ketta: Jori! I kept a space for that name on the crew board. Bring the mark back; Jori has a workshop to come home to.'},
}
local briefs={
 ['DW-02']='Use the recovered medicine to help the travelers, then bring their missing cart driver home.',
 ['GW-06']='Finn has found the last scout. Help him lead his friends out, then hold the rearguard clearing.',
 ['FV-04']='Why are the guardians blocking their own refuge road? Compare the signal with their behavior.',
 ['EC-05']='Dagna, Orik and Brann each know part of the circuit. Read their drawings and test the complete loop.',
 ['HG-04']='The scouts and dwarves are ready. Connect Finn\'s signal to Brann\'s gate rig and let your friends through.',
 ['DW-Q2']='Liora promised the rescued camp a proper meal. Recover the stolen food and help it reach their table.',
 ['FV-Q1']='Nessa is searching for the owner of a lost badge. Its village mark may give a traveler their name back.',
 ['EC-Q1']='Ketta kept a place for a missing worker on the crew board. Return their mark so the workshop can welcome them home.',
}
function B.install(C)
 for key,row in pairs(B.beats)do
  local cid,gid=key:match('^([^:]+):(.+)$');local c=assert(C.byId[cid]);local g
  for _,v in ipairs(c.goals)do if v.id==gid then g=v;break end end
  assert(g and g.expansion,'Missing authored incident '..key)
  if row.title then g.title=row.title;g.activity.clue=row.title end
  if row.actor then g.activity.actor=row.actor end
  for i,words in ipairs(row.steps or {})do
   g.activity.steps[i].title=words[1];g.activity.steps[i].text=words[2]
  end
  if row.outcome then g.text=row.outcome end
 end
 for id,text in pairs(briefs)do C.byId[id].quest.brief=text end
 local outcomes={['DW-Q2']='The recovered food reaches Liora\'s camp table. The rescued travelers prepare a proper meal together.',
  ['FV-Q1']='Nessa returns the badge to its owner. A traveler has a name on the arrivals board and friends waiting beside it.',
  ['EC-Q1']='Ketta returns the worker\'s mark. The missing name is back on the crew board and the workshop has its worker again.'}
 for id,text in pairs(outcomes)do C.byId[id].quest.outcome=text end
end
return B
